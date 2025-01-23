import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  // Hàm chọn ảnh từ thư viện và chuyển đổi thành Base64
  static Future<String?> pickImageAndConvertToBase64() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Đọc ảnh dưới dạng byte
      final bytes = await image.readAsBytes();
      // Chuyển byte thành Base64
      return base64Encode(bytes);
    }
    return null;
  }

  // Hàm chuyển Base64 thành dữ liệu ảnh (Uint8List)
  static Uint8List? convertBase64ToImage(String base64String) {
    try {
      // Chuyển Base64 thành byte
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding Base64: $e');
      return null;
    }
  }
}
