from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Dict, Optional
import uvicorn
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv
import json

# Load .env: ưu tiên travel_agent/.env, fallback backend/.env
load_dotenv(dotenv_path=".env")
load_dotenv(dotenv_path="../.env")

# Create the FastAPI app
api = FastAPI()

# Add CORS middleware
api.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Define the request body model
class InvokeRequest(BaseModel):
    """
    Request model for the general invocation endpoint.

    Attributes:
        input (str): The user's input message.
        history (List[Dict[str, str]]): Conversation history, default is empty.
    """
    input: str
    history: List[Dict[str, str]] = []

# Define the request body model for plan editing
class PlanEditRequest(BaseModel):
    """
    Request model for editing an existing trip plan.

    Attributes:
        command (str): The user's command describing how to modify the plan.
        trip_id (str): The unique identifier of the trip to edit.
        conversation_history (List[Dict[str, str]]): Recent chat history for context.
        current_plan (Optional[Dict]): The current plan structure - trip_info + activities - so AI knows what exists.
    """
    command: str
    trip_id: str
    conversation_history: List[Dict[str, str]] = []
    current_plan: Optional[Dict] = None

# Define the request body model for trip planning
class TripPlanRequest(BaseModel):
    """
    Request model for generating a new trip plan.

    Attributes:
        prompt (str): The user's prompt describing the desired trip.
        user_id (Optional[str]): The user's ID, if authenticated.
    """
    prompt: str
    user_id: Optional[str] = None

# Define the API endpoint for general AI queries
@api.post("/invoke")
async def invoke_workflow(request: InvokeRequest):
    """
    General AI assistant endpoint for queries that don't involve plan modifications.
    
    This endpoint handles general conversation. Plan modifications are routed 
    separately to the /edit-plan endpoint.

    Args:
        request (InvokeRequest): The request payload containing user input.

    Returns:
        dict: A simple acknowledgment summary.
    """
    user_input = request.input.strip()

    # For now, just return a simple acknowledgment
    # All intelligent plan modifications are handled by Gemini AI in /edit-plan
    return {"summary": f"AI: Tôi đã nhận được yêu cầu của bạn. Hãy sử dụng tính năng chỉnh sửa kế hoạch thông minh nếu bạn muốn thay đổi kế hoạch du lịch!"}

# Define the plan editing endpoint with Gemini AI
@api.post("/edit-plan")
async def edit_plan(request: PlanEditRequest):
    """
    Handles intelligent plan editing using Gemini AI with conversation context.

    When a user wants to edit a plan, this endpoint uses an LLM to generate a 
    completely new plan structure that incorporates the requested changes 
    while maintaining the logic of the original plan.

    Args:
        request (PlanEditRequest): The request payload with edit command and context.

    Returns:
        dict: A response indicating success/failure and containing the new plan data.
    """
    try:
        command = request.command.strip()
        trip_id = request.trip_id.strip()
        conversation_history = request.conversation_history
        current_plan = request.current_plan

        print(f"PLAN_EDIT: Processing command '{command}' for trip {trip_id}")

        # Check if API key is configured
        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key or api_key == "your-actual-gemini-api-key-here":
            return {
                "success": False,
                "message": "Gemini API key chưa được cấu hình.",
                "command": command
            }

        # Use Gemini AI to process the plan modification request
        from services.llm_utils import get_llm, invoke_with_messages

        llm = get_llm()

        # Build conversation context
        context_messages = []
        if conversation_history:
            for msg in conversation_history[-10:]:  # Last 10 messages for context
                role = msg.get('role', 'user')
                content = msg.get('content', '')
                if role == 'user':
                    context_messages.append(f"User: {content}")
                elif role == 'assistant':
                    context_messages.append(f"Assistant: {content}")

        context_str = "\n".join(context_messages) if context_messages else "No previous context"

        # Build current plan context so AI knows what exists (để hiểu "chỗ này", "điểm thứ 2", v.v.)
        current_plan_str = "Không có thông tin kế hoạch hiện tại."
        if current_plan:
            current_plan_str = json.dumps(current_plan, ensure_ascii=False, indent=2)

        system_message = f"""
        Bạn là một chuyên gia lập kế hoạch du lịch thông minh. Nhiệm vụ của bạn là TẠO MỚI hoặc CHỈNH SỬA kế hoạch dựa trên yêu cầu của người dùng.

        === QUY TẮC 1: KHI THIẾU THÔNG TIN - HỎI LẠI ===
        Khi người dùng TẠO CHUYẾN MỚI hoặc CHỈNH SỬA mà thiếu thông tin quan trọng, BẠN PHẢI HỎI LẠI thay vì đoán mò.
        Các thông tin thường thiếu:
        - Ngày đi (start_date, end_date): CHỈ hỏi khi KẾ HOẠCH HIỆN TẠI KHÔNG có sẵn start_date/end_date trong trip_info. Nếu đã có start_date và end_date trong current_plan → TUYỆT ĐỐI KHÔNG hỏi lại "ngày đi từ ngày mấy đến ngày mấy", dùng luôn các ngày đó.
        - Điểm khởi hành: "Bạn xuất phát từ đâu? (vd: Sài Gòn, Hà Nội)"
        - Phương tiện ưa thích: "Bạn muốn di chuyển bằng gì? (máy bay, tàu, xe...)"

        Nếu thiếu → trả về action_type: "ask_user" với "questions" là danh sách câu hỏi (1-3 câu), KHÔNG trả new_plan.

        === QUY TẮC 2: KẾ HOẠCH HIỆN TẠI ===
        Khi có KẾ HOẠCH HIỆN TẠI: "chỗ này", "điểm thứ X", "quán café buổi sáng" → tham chiếu đúng hoạt động.
        Thực hiện ĐÚNG thay đổi: thay thế, thêm, xóa, đổi thứ tự - GIỮ NGUYÊN những gì không bị yêu cầu.

        === QUY TẮC 2b: ĐẢO THỨ TỰ HOẠT ĐỘNG ===
        Khi người dùng yêu cầu đảo thứ tự (vd: "đi Văn Miếu trước ăn trưa bún chả Hương Liên", "muốn đi X trước Y"):
        - Xác định các hoạt động tương ứng (Văn Miếu Quốc Tử Giám, Bún chả Hương Liên, v.v.)
        - Sắp xếp lại thứ tự trong daily_plans sao cho hoạt động được yêu cầu "trước" nằm trước hoạt động "sau"
        - Điều chỉnh start_time cho hợp lý (giữ khoảng cách thời gian giữa các hoạt động)
        - Trả full_replace với new_plan đã đảo thứ tự đúng yêu cầu

        === QUY TẮC 3: TRÁNH TRÙNG LẶP ===
        - Khi user yêu cầu THÊM hoạt động: kiểm tra kế hoạch hiện tại đã có địa điểm/loại hình tương tự chưa.
        - Nếu ĐÃ CÓ (vd: đã có bảo tàng, user lại "thêm bảo tàng") → trả action_type: "ask_user" hỏi: "Kế hoạch đã có [X]. Bạn muốn thay thế hay thêm địa điểm khác?"
        - KHÔNG tạo 2 hoạt động trùng địa điểm, trùng loại hình gần nhau trong cùng ngày.

        === QUY TẮC 4: XÓA/ĐỔI KHI CÓ NHIỀU MỤC TRÙNG LOẠI ===
        Khi user nói "xóa X" hoặc "đổi X" (vd: xóa ăn trưa) mà có NHIỀU hoạt động khớp (vd: 2 bữa trưa khác nhau) → KHÔNG đoán, trả ask_user kèm "choices" để user chọn:
        "choices": [{{"order": 1, "label": "Ăn trưa Phở Bát Đàn", "reply_suggestion": "xóa điểm thứ 1"}}, {{"order": 2, "label": "Ăn trưa Bún chả Hương Liên", "reply_suggestion": "xóa điểm thứ 2"}}]
        App sẽ hiện 2 nút; user bấm nút nào thì gửi lại reply_suggestion tương ứng. Label ngắn gọn, rõ (vd: "Ăn trưa Bát Đàn", "Ăn trưa Hương Liên").

        === QUY TẮC 5: THÊM ĐỊA ĐIỂM - HỎI GIỜ VÀ NGÀY ===
        Khi user yêu cầu "thêm địa điểm X" (vd: thêm Hồ Hoàn Kiếm) mà chưa nói rõ giờ và ngày → trả ask_user: "Bạn muốn thêm vào mấy giờ, ngày mấy trong chuyến đi?" Chỉ khi có đủ giờ + ngày mới trả full_replace với new_plan.

        === QUY TẮC 6: KHE THỜI GIAN CHẬT (<= 1 TIẾNG) ===
        Khi thêm hoạt động vào khe giữa hai hoạt động có khoảng cách <= 1 tiếng → trả ask_user: "Khoảng thời gian khá chật. Bạn có chắc muốn thêm? Điều này có thể làm lệch chuyến đi. Bạn có muốn tôi sửa lại lịch trình (tái phân bổ thời gian) sau khi thêm không?" Nếu user xác nhận thêm và muốn sửa lịch → trả new_plan đã tái cấu trúc thời gian cho hợp lý.

        KẾ HOẠCH HIỆN TẠI:
        {current_plan_str}

        THÔNG TIN NGỮ CẢNH:
        - ID chuyến đi: {trip_id}
        - Lịch sử cuộc trò chuyện:
        {context_str}

        YÊU CẦU ĐẦU RA:
        Tạo kế hoạch du lịch hoàn chỉnh mới với cấu trúc JSON chuẩn.
        QUAN TRỌNG: Mỗi hoạt động PHẢI có địa chỉ CHI TIẾT, đầy đủ để có thể load trên bản đồ và route đường đi.
        Địa chỉ phải bao gồm: tên địa điểm cụ thể, tên đường, phường/xã, quận/huyện, thành phố/tỉnh, mã bưu chính, quốc gia.
        Ví dụ: "Ar Ti So, Hồ Tùng Mậu, Ấp Xuân An, Da Lat, Phường Xuân Hương - Đà Lạt, Lâm Đồng Province, 02633, Vietnam" thay vì chỉ "Phố cổ Hà Nội".
        Tọa độ GPS PHẢI được cung cấp ở định dạng "latitude,longitude" với độ chính xác cao (ví dụ: "11.9404,108.4583" cho Đà Lạt).
        KHÔNG được để trống hoặc dùng placeholder - PHẢI cung cấp tọa độ GPS thực tế và chính xác.

        Cấu trúc JSON - CHỌN 1 TRONG 2:

        A) Khi thiếu thông tin HOẶC phát hiện trùng lặp cần xác nhận HOẶC nhiều lựa chọn (xóa cái nào) → trả:
        {{
            "action_type": "ask_user",
            "message": "Câu trả lời thân thiện kèm câu hỏi",
            "questions": ["Câu hỏi 1?", "Câu hỏi 2?"],
            "choices": [{{"order": 1, "label": "Nhãn hiển thị nút 1", "reply_suggestion": "xóa điểm thứ 1"}}, {{"order": 2, "label": "Nhãn nút 2", "reply_suggestion": "xóa điểm thứ 2"}}]
        }}
        (choices chỉ dùng khi user cần chọn 1 trong nhiều mục giống loại, ví dụ xóa ăn trưa nào trong 2 bữa trưa; nếu không có lựa chọn thì bỏ "choices" hoặc để [])

        B) Khi đủ thông tin và tạo được kế hoạch → trả:
        {{
            "action_type": "full_replace",
            "message": "Đã tạo kế hoạch mới dựa trên yêu cầu của bạn",
            "new_plan": {{
                "trip_info": {{
                    "name": "Tên chuyến đi mới",
                    "destination": "Điểm đến",
                    "start_date": "YYYY-MM-DD",
                    "end_date": "YYYY-MM-DD",
                    "duration_days": số,
                    "travelers_count": số,
                    "total_budget": số,
                    "currency": "VND"
                }},
                "daily_plans": [
                    {{
                        "day": số,
                        "date": "YYYY-MM-DD",
                        "activities": [
                            {{
                                "title": "Tên hoạt động",
                                "description": "Mô tả chi tiết",
                                "start_time": "HH:MM",
                                "duration_hours": số,
                                "activity_type": "activity|restaurant|lodging|flight|tour",
                                "estimated_cost": số,
                                "location": "Tên địa điểm",
                                "address": "Địa chỉ đầy đủ cho bản đồ (đường, quận/huyện, thành phố)",
                                "coordinates": "Tọa độ GPS (latitude,longitude) nếu có thể"
                            }}
                        ]
                    }}
                ],
                "summary": {{
                    "total_estimated_cost": số,
                    "recommendations": ["Lời khuyên"],
                    "tips": ["Mẹo du lịch"]
                }}
            }}
        }}

        QUAN TRỌNG:
        - action_type: "ask_user" khi thiếu info hoặc cần xác nhận (trùng lặp). "full_replace" khi tạo/sửa xong.
        - GIỮ NGUYÊN trip_info (name, destination, dates) trừ khi người dùng yêu cầu đổi
        - GIỮ NGUYÊN các hoạt động KHÔNG bị yêu cầu thay đổi - chỉ sửa đúng những gì người dùng chỉ định
        - Khi có current_plan, ƯU TIÊN giữ cấu trúc và chỉ thay đổi theo yêu cầu cụ thể
        - Chi phí tính bằng VND
        - Hoạt động phải đa dạng và thực tế

        CHỈ TRẢ VỀ JSON, KHÔNG CÓ TEXT KHÁC.
        """

        human_message = f"Yêu cầu chỉnh sửa kế hoạch của người dùng: {command}"

        try:
            print(f"Calling Gemini API for full plan replacement")
            response = invoke_with_messages(llm, system_message, human_message)
            print(f"Gemini API call successful for full plan replacement")
        except Exception as api_error:
            print(f"Gemini API error: {api_error}")
            return {
                "success": False,
                "message": f"Lỗi gọi Gemini API: {str(api_error)}",
                "command": command
            }

        # Parse the JSON response
        try:
            response_text = response.content.strip()

            # Find JSON in the response
            json_start = response_text.find('{')
            json_end = response_text.rfind('}') + 1

            if json_start >= 0 and json_end > json_start:
                json_str = response_text[json_start:json_end]
                result = json.loads(json_str)

                action_type = result.get('action_type', 'full_replace')
                message = result.get('message', 'Đã tạo kế hoạch mới')

                # AI muốn hỏi lại (thiếu info hoặc phát hiện trùng cần xác nhận hoặc nhiều lựa chọn)
                if action_type == 'ask_user':
                    questions = result.get('questions', [])
                    if not isinstance(questions, list):
                        questions = [str(questions)] if questions else []
                    choices_raw = result.get('choices', [])
                    choices = []
                    if isinstance(choices_raw, list):
                        for c in choices_raw:
                            if isinstance(c, dict) and 'order' in c and 'label' in c:
                                choices.append({
                                    "order": c.get("order"),
                                    "label": c.get("label", ""),
                                    "reply_suggestion": c.get("reply_suggestion", f"điểm thứ {c.get('order')}"),
                                })
                    return {
                        "success": False,
                        "action": "ask_user",
                        "message": message,
                        "questions": questions,
                        "choices": choices,
                        "command": command,
                        "trip_id": trip_id
                    }

                new_plan = result.get('new_plan', {}) or result.get('newPlan', {})
                # Chuẩn hóa camelCase -> snake_case
                if new_plan and 'dailyPlans' in new_plan and 'daily_plans' not in new_plan:
                    new_plan['daily_plans'] = new_plan.pop('dailyPlans', [])
                if new_plan and 'tripInfo' in new_plan and 'trip_info' not in new_plan:
                    new_plan['trip_info'] = new_plan.pop('tripInfo', {})

                # AI trả activities (flat) thay vì daily_plans → chuyển đổi
                if new_plan and 'activities' in new_plan and 'daily_plans' not in new_plan:
                    new_plan['daily_plans'] = _activities_to_daily_plans(new_plan.get('activities', []))

                if not new_plan or 'trip_info' not in new_plan or 'daily_plans' not in new_plan:
                    got_keys = list(result.keys()) if isinstance(result, dict) else []
                    np_keys = list(new_plan.keys()) if isinstance(new_plan, dict) else []
                    print(f"PLAN_EDIT_DEBUG: result keys={got_keys}, new_plan keys={np_keys}")
                    raise ValueError(
                        f"Invalid new plan structure: need trip_info and daily_plans, got {np_keys}"
                    )

                new_plan = _enrich_plan_with_flights(new_plan)

                return {
                    "success": True,
                    "action_type": action_type,
                    "message": message,
                    "new_plan": new_plan,
                    "command": command,
                    "trip_id": trip_id
                }
            else:
                raise ValueError("No JSON found in response")

        except json.JSONDecodeError as e:
            print(f"JSON parse error: {e}")
            return {
                "success": False,
                "message": f"Không thể phân tích kế hoạch mới: {str(e)}",
                "command": command,
                "raw_response": response.content
            }

    except Exception as e:
        print(f"PLAN_EDIT_ERROR: {e}")
        return {
            "success": False,
            "message": f"Có lỗi xảy ra khi tạo kế hoạch mới: {str(e)}",
            "command": command
        }

# Define flight search endpoint (Amadeus)
@api.get("/search-flights")
async def search_flights_endpoint(
    origin: str,
    destination: str,
    departure_date: str,
    adults: int = 1,
    max_results: int = 5,
    debug: int = 0,
):
    """
    Tìm chuyến bay thực tế qua Amadeus (dữ liệu test).
    Thêm ?debug=1 để xem phản hồi thô từ Amadeus.
    """
    try:
        from services.flights import search_flights_raw
        offers, raw = search_flights_raw(origin, destination, departure_date, adults, max_results)
        out = {"success": True, "offers": offers}
        if debug:
            out["_debug"] = raw
        return out
    except Exception as e:
        print(f"FLIGHT_SEARCH_ERROR: {e}")
        return {"success": False, "offers": [], "message": str(e), "_debug": {"error": str(e)}}


def _activities_to_daily_plans(activities: list) -> list:
    """Chuyển danh sách activities phẳng thành daily_plans (nhóm theo ngày)."""
    if not activities:
        return []
    from collections import defaultdict
    by_date = defaultdict(list)
    for a in activities:
        if not isinstance(a, dict):
            continue
        date_str = a.get('date') or a.get('dateStr') or ''
        if not date_str and a.get('time'):
            # Có thể có DateTime ISO
            t = a.get('time')
            if isinstance(t, str) and 'T' in t:
                date_str = t[:10]
        if not date_str:
            continue
        start_time = a.get('start_time') or '09:00'
        if isinstance(a.get('time'), str) and ':' in str(a['time'])[:8]:
            start_time = str(a['time'])[:5]
        act = {
            'title': a.get('title') or a.get('name') or a.get('location') or 'Hoạt động',
            'start_time': start_time,
            'address': a.get('address') or a.get('location') or '',
            'coordinates': a.get('coordinates') or '',
            'activity_type': a.get('activity_type') or a.get('type') or 'activity',
            'duration_hours': a.get('duration_hours', 1),
            'estimated_cost': a.get('estimated_cost', 0),
            'description': a.get('description', ''),
        }
        by_date[date_str].append(act)
    start_dates = sorted(by_date.keys()) if by_date else []
    return [
        {'day': i + 1, 'date': d, 'activities': by_date[d]}
        for i, d in enumerate(start_dates)
    ]


def _enrich_plan_with_flights(trip_plan: dict) -> dict:
    """
    Nếu kế hoạch có flight activity và trip_info có origin/dest/date,
    gọi Amadeus và thay thế bằng dữ liệu chuyến bay thực tế.
    """
    try:
        from services.flights import search_flights, city_to_iata, format_flight_for_activity
    except ImportError:
        return trip_plan

    trip_info = trip_plan.get("trip_info") or {}
    start_date = trip_info.get("start_date") or ""
    dest_raw = trip_info.get("destination") or trip_info.get("destination_city") or ""
    origin_raw = trip_info.get("starting_point") or trip_info.get("origin") or ""

    if not all([start_date, dest_raw, origin_raw]):
        return trip_plan

    origin_code = city_to_iata(origin_raw) or (origin_raw.upper() if len(origin_raw.strip()) == 3 else None)
    dest_code = city_to_iata(dest_raw) or (dest_raw.upper() if len(dest_raw.strip()) == 3 else None)
    if not origin_code or not dest_code:
        return trip_plan

    offers = search_flights(origin_code, dest_code, start_date, adults=1, max_results=1)
    if not offers:
        return trip_plan

    # Tìm activity flight đầu tiên trong daily_plans và thay thế
    daily_plans = trip_plan.get("daily_plans") or []
    for day_data in daily_plans:
        activities = day_data.get("activities") or []
        for i, act in enumerate(activities):
            if (act.get("activity_type") or "").lower() == "flight":
                act.update(format_flight_for_activity(offers[0]))
                break
        else:
            continue
        break

    return trip_plan


# Define the trip planning endpoint
@api.post("/generate-trip-plan")
async def generate_trip_plan(request: TripPlanRequest):
    """
    Generates a complete trip plan based on user prompt using AI.
    
    This endpoint uses a comprehensive prompt to generate a detailed day-by-day
    itinerary, including logistics, estimated costs, and specific addresses.

    Args:
        request (TripPlanRequest): The request payload containing the trip prompt.

    Returns:
        dict: A structured JSON trip plan or an error message.
    """
    try:
        from services.llm_utils import get_llm, get_default_prompt

        prompt = request.prompt.strip()
        user_id = request.user_id

        print(f"TRIP_PLAN: Generating plan for prompt: '{prompt}'")

        # Check if API key is configured
        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key or api_key == "your-actual-gemini-api-key-here":
            return {
                "success": False,
                "message": "Gemini API key chưa được cấu hình. Vui lòng thêm GOOGLE_API_KEY vào file .env"
            }

        # Use Gemini to generate comprehensive trip plan
        llm = get_llm()

        system_message = """
        Bạn là một chuyên gia lên kế hoạch du lịch chuyên nghiệp với kiến thức thực tế về Việt Nam. Nhiệm vụ của bạn là tạo ra một kế hoạch du lịch hoàn chỉnh và chi tiết dựa trên yêu cầu của người dùng.

        Yêu cầu đầu ra:
        1. Phân tích yêu cầu và trích xuất thông tin chính (điểm đến, thời gian, số người, ngân sách, ĐIỂM KHỞI HÀNH, PHƯƠNG TIỆN DI CHUYỂN ƯA THÍCH)
        2. Tạo kế hoạch chi tiết cho từng ngày với các hoạt động cụ thể THEO TRẬT TỰ ĐỊA LÝ LOGIC
        3. Ước tính chi phí cho từng hoạt động và tổng cộng
        4. Gợi ý phương tiện di chuyển và chỗ ở phù hợp
        5. Trả về JSON với cấu trúc chuẩn để ứng dụng có thể import

        QUAN TRỌNG VỀ TỔ CHỨC ĐƯỜNG ĐI:
        - XÁC ĐỊNH ĐIỂM KHỞI HÀNH từ yêu cầu người dùng (ví dụ: ga xe lửa Hồ Chí Minh, sân bay, nhà ga...)
        - XÁC ĐỊNH MÚI GIỜ: Tự động xác định múi giờ của điểm khởi hành và điểm đến (ví dụ: VN UTC+7, Mỹ UTC-5, châu Âu UTC+1)
        - CHUYỂN ĐỔI THỜI GIAN: Điều chỉnh giờ khởi hành và hoạt động theo múi giờ địa phương
        - XỬ LÝ JET LAG: Cân nhắc thời gian bay dài và hiệu ứng jet lag khi lên lịch hoạt động
        - SẮP XẾP HOẠT ĐỘNG THEO MÚI GIỜ: Đảm bảo giờ hoạt động hợp lý theo thời gian địa phương
        - TÍNH TOÁN THỜI GIAN DI CHUYỂN THỰC TẾ: Sử dụng khoảng cách địa lý và phương tiện để ước lượng chính xác
        - TRÁNH nhảy cóc giữa các địa điểm xa xôi không hợp lý
        - ĐẢM BẢO kế hoạch có thể thực hiện được về mặt logistics và múi giờ

        QUAN TRỌNG VỀ ƯỚC LƯỢNG THỜI GIAN DI CHUYỂN:
        - TÍNH TOÁN DỰA TRÊN KHOẢNG CÁCH THỰC TẾ: Sử dụng khoảng cách địa lý và tốc độ di chuyển hợp lý
        - ĐI BỘ: ~5km/h trong thành phố, cộng thêm thời gian chờ đèn đỏ và đường cong
        - XE CỘ: Tùy traffic, giờ cao điểm có thể chậm hơn 2-3 lần so với bình thường
        - PHƯƠNG TIỆN CÔNG CỘNG: Bao gồm thời gian chờ, mua vé, di chuyển đến điểm dừng
        - MÁY BAY: Thời gian bay thực tế + thời gian sân bay (check-in, security, boarding, lấy hành lý)
        - TÀU/XE BUÝT LIÊN THÀNH PHỐ: Tra cứu lịch trình thực tế, cộng thời gian lên/xuống phương tiện
        - THỜI GIAN DỰ PHÒNG: Cộng thêm 15-30 phút cho các yếu tố bất ngờ (traffic, thời tiết, nghỉ ngơi)
        - CẬP NHẬT THEO THỜI GIAN THỰC: Xem xét điều kiện traffic hiện tại, mùa vụ, giờ cao điểm

        QUAN TRỌNG VỀ LỰA CHỌN PHƯƠNG TIỆN DI CHUYỂN THEO KHOẢNG CÁCH:
        - ĐÁNH GIÁ KHOẢNG CÁCH: Tính toán khoảng cách địa lý giữa các điểm đến để chọn phương tiện phù hợp
        - KHOẢNG CÁCH NGẮN (< 5km): Đi bộ, xe đạp, xe máy, taxi/Grab - ưu tiên đi bộ nếu thời tiết thuận lợi
        - KHOẢNG CÁCH TRUNG BÌNH (5-50km): Xe buýt, tàu điện ngầm, taxi, xe thuê - cân nhắc thời gian và chi phí
        - KHOẢNG CÁCH DÀI (50-500km): Tàu hỏa, máy bay nội địa - ưu tiên máy bay nếu muốn nhanh, tàu nếu muốn tiết kiệm
        - KHOẢNG CÁCH RẤT DÀI (>500km): Máy bay quốc tế - thường là lựa chọn duy nhất thực tế
        - CÂN NHẮC YẾU TỐ: Thời gian, chi phí, tiện nghi, sở thích người dùng, điều kiện thời tiết, giờ cao điểm
        - ƯU TIÊN PHƯƠNG TIỆN NGƯỜI DÙNG CHỌN: Nếu người dùng chỉ định phương tiện cụ thể, ưu tiên phương tiện đó nhưng vẫn xem xét tính thực tế

        QUAN TRỌNG VỀ PHƯƠNG TIỆN DI CHUYỂN CỤ THỂ:
        - BAY: Sử dụng lịch bay thực tế (Vietnam Airlines, VietJet, Bamboo Airways) - phù hợp cho >50km
        - TÀU: Ga Sapa, Hà Nội, Đà Nẵng, Hồ Chí Minh - phù hợp cho 100-800km, tiết kiệm và thoải mái
        - XE BUÝT: The Sinh Tourist, Sapaco Tourist, Kumho Samco - phù hợp cho 5-200km, giá rẻ
        - XE Ô TÔ/XE MÁY: Thuê xe hoặc Grab - phù hợp cho <50km trong thành phố
        - KHÔNG sáng tạo lịch trình không tồn tại - chỉ đề xuất phương tiện có thực tại điểm đến

        QUAN TRỌNG VỀ ƯỚC LƯỢNG CHI PHÍ THỰC TẾ:
        - NGHIÊN CỨU GIÁ THỰC TẾ: Sử dụng kiến thức cập nhật về giá cả tại điểm đến cụ thể
        - ĐIỀU CHỈNH THEO QUỐC GIA: Sử dụng đơn vị tiền tệ phù hợp (VND ở VN, USD ở Mỹ, EUR ở châu Âu, etc.)
        - PHÙ HỢP VỚI MỨC ĐỘ SANG TRỌNG: Budget (tiết kiệm), Mid-range (trung cấp), Luxury (sang trọng) (tính toán dựa trên total budget và số người)
        - CẬP NHẬT THEO THỜI GIAN: Giá có thể thay đổi theo mùa, sự kiện đặc biệt

        QUAN TRỌNG VỀ ĐỊA CHỈ: Mỗi hoạt động PHẢI có địa chỉ CHI TIẾT, đầy đủ để có thể load trên bản đồ và route đường đi.
        Địa chỉ phải bao gồm: tên địa điểm cụ thể, tên đường, phường/xã, quận/huyện, thành phố/tỉnh, mã bưu chính, quốc gia.
        Ví dụ: "Ar Ti So, Hồ Tùng Mậu, Ấp Xuân An, Da Lat, Phường Xuân Hương - Đà Lạt, Lâm Đồng Province, 02633, Vietnam" thay vì chỉ "Phố cổ Hà Nội".
        Tọa độ GPS PHẢI được cung cấp ở định dạng "latitude,longitude" với độ chính xác cao (ví dụ: "11.9404,108.4583" cho Đà Lạt).
        KHÔNG được để trống hoặc dùng placeholder - PHẢI cung cấp tọa độ GPS thực tế và chính xác.

        Cấu trúc JSON phải bao gồm:
        {{
            "trip_info": {{
                "name": "Tên chuyến đi",
                "destination": "Điểm đến",
                "start_date": "YYYY-MM-DD",
                "end_date": "YYYY-MM-DD",
                "duration_days": số,
                "travelers_count": số,
                "total_budget": số,
                "currency": "VND",
                "starting_point": "Điểm khởi hành từ yêu cầu người dùng"
            }},
            "daily_plans": [
                {{
                    "day": số,
                    "date": "YYYY-MM-DD",
                    "activities": [
                        {{
                            "title": "Tên hoạt động",
                            "description": "Mô tả chi tiết với thông tin di chuyển từ điểm trước",
                            "start_time": "HH:MM",
                            "duration_hours": số,
                            "activity_type": "activity|restaurant|lodging|flight|tour",
                            "estimated_cost": số,
                            "location": "Tên địa điểm",
                            "address": "Địa chỉ đầy đủ cho bản đồ (đường, quận/huyện, thành phố)",
                            "coordinates": "Tọa độ GPS (latitude,longitude) nếu có thể",
                            "travel_from_previous": "Mô tả cách di chuyển từ hoạt động trước với thời gian thực tế"
                        }}
                    ]
                }}
            ],
            "summary": {{
                "total_estimated_cost": số,
                "recommendations": ["Lời khuyên hữu ích về logistics và di chuyển với thông tin thực tế"],
                "tips": ["Mẹo du lịch và tối ưu hóa đường đi dựa trên kinh nghiệm thực tế"]
            }}
        }}

        Lưu ý:
        - Thời gian bắt đầu tính từ ngày hiện tại + 7 ngày
        - Chi phí tính bằng VND
        - Hoạt động phải đa dạng và thực tế
        - Bao gồm ăn uống, di chuyển, tham quan, nghỉ ngơi
        - SỬ DỤNG THÔNG TIN PHƯƠNG TIỆN DI CHUYỂN THỰC TẾ, không bịa đặt
        - ĐẶC BIỆT CHÚ Ý đến điểm khởi hành và sắp xếp hoạt động theo thứ tự địa lý hợp lý

        Trả về CHỈ JSON, không có text khác.
        """

        human_message = f"Hãy lên kế hoạch du lịch cho yêu cầu sau: {prompt}"

        chat_prompt = get_default_prompt(system_message, human_message)
        chain = chat_prompt | llm

        # Get AI response with timeout
        try:
            print(f"Calling Gemini API with model: {os.getenv('LLM_MODEL', 'gemini-2.5-flash')}")
            print(f"API Key configured: {bool(os.getenv('GOOGLE_API_KEY'))}")
            response = chain.invoke({})
            print(f"Gemini API call successful")
        except Exception as api_error:
            print(f"Gemini API error details: {api_error}")
            print(f"Error type: {type(api_error)}")
            return {
                "success": False,
                "message": f"Lỗi gọi Gemini API: {str(api_error)}. Vui lòng kiểm tra API key và model."
            }

        # Parse the JSON response
        try:
            # Extract JSON from the response
            response_text = response.content.strip()

            # Find JSON in the response (might be wrapped in text)
            json_start = response_text.find('{')
            json_end = response_text.rfind('}') + 1

            if json_start >= 0 and json_end > json_start:
                json_str = response_text[json_start:json_end]
                trip_plan = json.loads(json_str)

                # Validate required fields
                if "trip_info" not in trip_plan or "daily_plans" not in trip_plan:
                    raise ValueError("Invalid trip plan structure")

                # Enrich with real flight data from Amadeus when possible
                trip_plan = _enrich_plan_with_flights(trip_plan)

                return {
                    "success": True,
                    "trip_plan": trip_plan,
                    "message": "Đã tạo kế hoạch du lịch thành công!"
                }
            else:
                raise ValueError("No JSON found in response")

        except json.JSONDecodeError as e:
            print(f"JSON parse error: {e}")
            return {
                "success": False,
                "message": f"Không thể phân tích kế hoạch du lịch: {str(e)}",
                "raw_response": response.content
            }

    except Exception as e:
        print(f"❌ TRIP_PLAN_ERROR: {e}")
        return {
            "success": False,
            "message": f"Có lỗi xảy ra khi tạo kế hoạch: {str(e)}"
        }

# No longer need helper functions - Gemini AI handles all plan modifications

# To run this API, use the command:
# uvicorn main:api --reload --port 5001
# Android emulator: adb reverse tcp:5001 tcp:5001
if __name__ == "__main__":
    uvicorn.run(api, host="0.0.0.0", port=5001)
