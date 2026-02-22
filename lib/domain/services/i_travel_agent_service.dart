// Service gọi Travel Agent backend (edit-plan API).
abstract class ITravelAgentService {
  // Gửi yêu cầu chỉnh sửa kế hoạch đến AI. command: mô tả thay đổi; currentPlan: kế hoạch hiện tại để AI tham chiếu.
  Future<EditPlanResult> editPlan({
    required String command,
    required String tripId,
    List<Map<String, String>> conversationHistory = const [],
    Map<String, dynamic>? currentPlan,
  });
}

class EditPlanResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? newPlan;
  final String? error;

  // Khi AI cần hỏi lại (thiếu info hoặc trùng) - hiển thị message, giữ sheet mở
  final bool isAskUser;
  final List<String> askUserQuestions;
  // Nhiều mục trùng loại - hiện nút để user chọn; mỗi item: order, label, reply_suggestion
  final List<Map<String, dynamic>> askUserChoices;

  EditPlanResult({
    required this.success,
    this.message,
    this.newPlan,
    this.error,
    this.isAskUser = false,
    this.askUserQuestions = const [],
    this.askUserChoices = const [],
  });
}
