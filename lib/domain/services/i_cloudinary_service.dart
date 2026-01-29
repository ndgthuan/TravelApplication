import 'dart:io';

// Interface cho Cloudinary upload service
// Các ViewModel sẽ inject interface này thay vì gọi static method
abstract class ICloudinaryService {
  // Upload ảnh lên Cloudinary
  // [image] - File ảnh cần upload
  // Returns URL của ảnh đã upload, hoặc null nếu thất bại
  Future<String?> uploadImage(File image);
}
