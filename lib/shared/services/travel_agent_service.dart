import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_app/domain/services/i_travel_agent_service.dart';

// Gọi Travel Agent backend. Chạy: cd backend/travel_agent && uvicorn main:api --port 5001. Android: adb reverse tcp:5001 tcp:5001
class TravelAgentService implements ITravelAgentService {
  // Port 5001 để tránh conflict với image_translate (5000)
  static const String _baseUrl = 'http://localhost:5001';

  @override
  Future<EditPlanResult> editPlan({
    required String command,
    required String tripId,
    List<Map<String, String>> conversationHistory = const [],
    Map<String, dynamic>? currentPlan,
  }) async {
    try {
      final body = <String, dynamic>{
        'command': command,
        'trip_id': tripId,
        'conversation_history': conversationHistory,
      };
      if (currentPlan != null && currentPlan.isNotEmpty) {
        body['current_plan'] = currentPlan;
      }
      final response = await http
          .post(
            Uri.parse('$_baseUrl/edit-plan'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final success = data['success'] as bool? ?? false;
        final action = data['action'] as String?;
        final isAskUser = action == 'ask_user';
        final questionsRaw = data['questions'];
        final askUserQuestions = questionsRaw is List
            ? (questionsRaw).map((e) => e.toString()).toList()
            : <String>[];
        final choicesRaw = data['choices'];
        final askUserChoices = <Map<String, dynamic>>[];
        if (choicesRaw is List) {
          for (final c in choicesRaw) {
            if (c is Map<String, dynamic> &&
                c['order'] != null &&
                c['label'] != null) {
              askUserChoices.add({
                'order': c['order'],
                'label': c['label'].toString(),
                'reply_suggestion':
                    c['reply_suggestion']?.toString() ?? 'điểm thứ ${c['order']}',
              });
            }
          }
        }

        return EditPlanResult(
          success: success,
          message: data['message'] as String?,
          newPlan: data['new_plan'] as Map<String, dynamic>?,
          error: success ? null : (data['message'] as String?),
          isAskUser: isAskUser,
          askUserQuestions: askUserQuestions,
          askUserChoices: askUserChoices,
        );
      }

      return EditPlanResult(
        success: false,
        error: data['message'] as String? ?? 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      return EditPlanResult(
        success: false,
        error: 'Không kết nối được server. Chạy: cd backend/travel_agent && uvicorn main:api --port 5001',
      );
    }
  }
}
