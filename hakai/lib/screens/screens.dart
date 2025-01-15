import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;


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

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'seller',
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
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'user', 
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




class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> textProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchTextProducts();
  }

  Future<void> _fetchTextProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(user.uid)
        .collection('textProducts')
        .get();

        setState(() {
          textProducts = querySnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data().cast<String, dynamic>()})
              .toList();
        });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cửa hàng của bạn'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Truyện chữ'),
            Tab(text: 'Truyện tranh'),
            Tab(text: 'Nhạc'),
            Tab(text: 'Video'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList(textProducts),
          Center(child: Text('Chức năng truyện tranh đang phát triển...')),
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
      : LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            int crossAxisCount = screenWidth < 600 ? 2 : 5;
            double screenstextwidth = screenWidth < 600 ? screenWidth*1 : screenWidth*0.4;
            double childAspectRatio =
                (screenWidth / crossAxisCount) / (screenWidth / crossAxisCount * 1.5);

            return GridView.builder(
              padding: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return _buildProductDetails(product);
                      },
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Image.network(
                              product['image'] ??
                                  'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02, 
                              vertical: screenWidth * 0.01,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                
                                Flexible(
                                  child: Text(
                                    product['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenstextwidth * 0.03, 
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: screenstextwidth * 0.01),
                                Flexible(
                                child: Row(
                                  children: [
                                    Text(
                                      '${product['price']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenstextwidth * 0.025, 
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(width: screenstextwidth * 0.01), 
                                    Icon(
                                      Icons.diamond,
                                      color: Colors.grey,
                                      size: screenstextwidth * 0.03, // Kích thước icon theo tỷ lệ màn hình
                                    ),
                                  ],
                                ),
                              ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
}


  Widget _buildProductDetails(Map<String, dynamic> product) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['name'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'Tác giả: ${product['author'] ?? 'Không rõ'}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Text(
          'Mô tả: ${product['description'] ?? 'Không có mô tả'}',
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 8),
        Text(
          'Đánh giá: ${product['rating']?.toStringAsFixed(1) ?? 'Chưa có đánh giá'} ⭐',
          style: TextStyle(fontSize: 14, color: Colors.orange),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng modal
            // Xử lý sự kiện đọc nội dung truyện
            print("Reading ${product['name']}...");
          },
          child: Text('Đọc truyện'),
        ),
      ],
    ),
  );
}



  Future<void> _showAddProductDialog() async {
    String? productType = 'text';
    String name = '';
    String description = '';
    int price = 0;
    String content = '';

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
                        DropdownMenuItem(value: 'text', child: Text('Truyện chữ')),
                        DropdownMenuItem(value: 'comic', child: Text('Truyện tranh')),
                        DropdownMenuItem(value: 'music', child: Text('Nhạc')),
                        DropdownMenuItem(value: 'video', child: Text('Video')),
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
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentEditorScreen(initialContent: content),
                          ),
                        );

                        if (result != null) {
                          content = result;
                        }
                      },
                      child: Text('Nội dung'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (productType == null || name.isEmpty || description.isEmpty || price <= 0 || content.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')));
                          return;
                        }

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          
                          if (user == null) throw Exception('User not logged in');
                          final sellerId = user.uid;
                         
                          final data = {
                            'name': name,
                            'description': description,
                            'price': price,
                            'content': content,
                            'sellerId': sellerId,
                            'createdAt': FieldValue.serverTimestamp(),
                          };

                          await FirebaseFirestore.instance
                              .collection('products')
                              .doc(sellerId)
                              .collection('textProducts')
                              .add(data);

                          _fetchTextProducts();
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
}

class ContentEditorScreen extends StatefulWidget {
  final String? initialContent;

  ContentEditorScreen({this.initialContent});

  @override
  _ContentEditorScreenState createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  late quill.QuillController _controller;

  @override
  void initState() {
    super.initState();
    try {
      if (widget.initialContent != null && widget.initialContent!.isNotEmpty) {
        final doc = quill.Document()..insert(0, widget.initialContent!);
        _controller = quill.QuillController(
          document: doc,
          selection: TextSelection.collapsed(offset: 0),
        );
      } else {
        _controller = quill.QuillController.basic();
      }
    } catch (e) {
      print("Error initializing content: $e");
      _controller = quill.QuillController.basic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa nội dung'),
        actions: [
          TextButton(
            onPressed: () {
              _saveContent();
            },
            child: Text(
              'LƯU',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCustomToolbar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: quill.QuillEditor(
                controller: _controller,
                scrollController: ScrollController(),
                focusNode: FocusNode(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomToolbar() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.format_bold),
            onPressed: () {
              _controller.formatSelection(quill.Attribute.bold);
            },
          ),
          IconButton(
            icon: Icon(Icons.format_italic),
            onPressed: () {
              _controller.formatSelection(quill.Attribute.italic);
            },
          ),
          IconButton(
            icon: Icon(Icons.format_color_text),
            onPressed: () {
              _changeTextColor();
            },
          ),
          IconButton(
            icon: Icon(Icons.format_size),
            onPressed: () {
              _changeFontSize();
            },
          ),
        ],
      ),
    );
  }

  void _changeTextColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn màu chữ'),
        content: Wrap(
          children: [
            _buildColorButton(Colors.black),
            _buildColorButton(Colors.red),
            _buildColorButton(Colors.green),
            _buildColorButton(Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return IconButton(
      icon: Icon(Icons.circle, color: color),
      onPressed: () {
        _controller.formatSelection(
          quill.Attribute.fromKeyValue(
            'color',
            '#${color.value.toRadixString(16).substring(2)}',
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  void _changeFontSize() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn kích thước chữ'),
        content: Wrap(
          children: [10, 14, 18, 24, 32].map((size) {
            return TextButton(
              onPressed: () {
                _controller.formatSelection(
                  quill.Attribute.fromKeyValue('size', size.toString()),
                );
                Navigator.pop(context);
              },
              child: Text(
                size.toString(),
                style: TextStyle(fontSize: size.toDouble()),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _saveContent() {
    try {
      final content = _controller.document.toPlainText();
      Navigator.pop(context, content);
    } catch (e) {
      print("Error saving content: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lưu nội dung. Vui lòng thử lại!')),
      );
    }
  }
}


class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String _content = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentEditorScreen(
                      initialContent: _content,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _content = result;
                  });
                }
              },
              child: Text('Chỉnh sửa nội dung'),
            ),
            SizedBox(height: 16),
            Text('Nội dung hiện tại:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(_content.isEmpty ? 'Chưa có nội dung' : _content),
            ),
          ],
        ),
      ),
    );
  }
}
