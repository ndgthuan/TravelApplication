// Phương thúc dùng để gửi hỗ trợ qua EmailJS
// ViewModel không gọi http hay Firebase, chỉ gọi service này

abstract class ISupportEmailService {
  // GỬi email, userName, userEmail
  // Return true nếu thành công còn false nếu lỗi
  Future<bool> sendSupportEmail({
    required String subject,
    required String message,
    required String userName,
    required String userEmail,
  });
}
