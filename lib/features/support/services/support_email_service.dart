import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/domain/services/i_support_email_service.dart';

class SupportEmailService implements ISupportEmailService {
  @override
  Future<bool> sendSupportEmail({
    required String subject,
    required String message,
    required String userName,
    required String userEmail,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['PRIVATE_KEY']}',
        },
        body: json.encode({
          'service_id': dotenv.env['SERVICE_ID'],
          'template_id': dotenv.env['TEMPLATE_ID'],
          'user_id': dotenv.env['PUBLIC_KEY'],
          'accessToken': dotenv.env['PRIVATE_KEY'],
          'template_params': {
            'title': subject,
            'message': message,
            'name': userName,
            'email': userEmail,
          },
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
