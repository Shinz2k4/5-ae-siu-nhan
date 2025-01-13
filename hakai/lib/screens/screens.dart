import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';


class ApplySellerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký làm Seller'),
      ),
    );
  }
}
class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> comicProducts = [];
  List<Map<String, dynamic>> textProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cửa hàng của bạn'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Truyện tranh'),
            Tab(text: 'Truyện chữ'),
            Tab(text: 'Nhạc'),
            Tab(text: 'Video'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList(comicProducts),
          _buildProductList(textProducts),
          Center(child: Text('Chức năng nhạc đang phát triển...')),
          Center(child: Text('Chức năng video đang phát triển...')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> products) {
    return products.isEmpty
        ? Center(child: Text('Chưa có sản phẩm nào.'))
        : ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: product['coverImage'] != null
                      ? Image.network(product['coverImage'], width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50),
                  title: Text(product['name']),
                  subtitle: Text(product['description']),
                  trailing: Text('${product['price']} Diamonds'),
                ),
              );
            },
          );
  }

  Future<void> _showAddProductDialog() async {
    String? productType;
    String name = '';
    String description = '';
    int price = 0;
    Uint8List? coverImage;
    List<Uint8List> images = [];
    File? contentFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thêm sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: productType,
                      onChanged: (value) {
                        setState(() {
                          productType = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(value: 'comic', child: Text('Truyện tranh')),
                        DropdownMenuItem(value: 'text', child: Text('Truyện chữ')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Chọn loại sản phẩm',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      onChanged: (value) => name = value,
                      decoration: InputDecoration(labelText: 'Tên sản phẩm', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      onChanged: (value) => description = value,
                      decoration: InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) => price = int.tryParse(value) ?? 0,
                      decoration: InputDecoration(labelText: 'Giá (Diamonds)', border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          setState(() => coverImage = bytes);
                        }
                      },
                      child: Text('Thêm ảnh bìa'),
                    ),
                    coverImage != null
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.memory(coverImage!, width: 100, height: 100),
                          )
                        : SizedBox(),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (productType == null || name.isEmpty || description.isEmpty || price <= 0 || coverImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')));
                          return;
                        }

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) throw Exception('User not logged in');
                          final sellerId = user.uid;

                          final coverImageUrl = await _uploadToStorage('coverImages', coverImage!);

                          final data = {
                            'name': name,
                            'description': description,
                            'price': price,
                            'coverImage': coverImageUrl,
                            'sellerId': sellerId,
                            'createdAt': FieldValue.serverTimestamp(),
                          };

                          await FirebaseFirestore.instance
                              .collection('products')
                              .doc(sellerId)
                              .collection(productType == 'comic' ? 'comicProducts' : 'textProducts')
                              .add(data);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sản phẩm đã được thêm!')));
                        } catch (e) {
                          print('Error adding product: $e');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi thêm sản phẩm: $e')));
                        }
                      },
                      child: Text('Thêm sản phẩm'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<String> _uploadToStorage(String folder, Uint8List bytes) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(folder).child('${DateTime.now()}.jpg');
      final uploadTask = ref.putData(bytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Lỗi khi tải lên Firebase Storage: $e');
    }
  }
}

class GrantSellerScreen extends StatelessWidget {
  final TextEditingController _userIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cấp quyền Seller'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập User ID:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                hintText: 'Nhập User ID tại đây',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _grantSellerRole(context),
              child: Text('Cấp quyền Seller'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _removeSellerRole(context),
              child: Text('Xóa quyền Seller'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _grantSellerRole(BuildContext context) async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập User ID')),
      );
      return;
    }

    try {
      // Cập nhật quyền role trong Firestore thành seller
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'seller', // Thay đổi quyền role thành seller
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cấp quyền Seller thành công!')),
      );
    } catch (e) {
      // Nếu có lỗi xảy ra
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }

  Future<void> _removeSellerRole(BuildContext context) async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập User ID')),
      );
      return;
    }

    try {
      // Cập nhật quyền role trong Firestore thành user (xóa quyền seller)
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'user', // Thay đổi quyền role thành user
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa quyền Seller thành công!')),
      );
    } catch (e) {
      // Nếu có lỗi xảy ra
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }
}
