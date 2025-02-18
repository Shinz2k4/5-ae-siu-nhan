import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:convert';

import 'package:hakai/screens/series_chapter_screen.dart';

class WordStoryScreen extends StatefulWidget {
  @override
  _WordStoryScreenState createState() => _WordStoryScreenState();
}

class _WordStoryScreenState extends State<WordStoryScreen> {
  List<Map<String, dynamic>> textProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchAllTextProducts();
  }

  Future<void> _fetchAllTextProducts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('seriesChap')
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
        title: Text('Danh sách truyện chữ'),
      ),
      body: _buildProductList(textProducts),
    );
  }
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
                        return _buildProductDetails(product,context);
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
                          child: product['imagecover'] != null && product['imagecover']!.isNotEmpty
                              ? Image.memory(
                                  base64Decode(product['imagecover']!),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Image.network(
                                  'https://via.placeholder.com/150', // Placeholder nếu không có ảnh
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
                                      '${product['rate']?.toStringAsFixed(1) ?? '0.0'}', // Hiển thị đánh giá
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenstextwidth * 0.025,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(width: screenstextwidth * 0.01),
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          final rating = product['rate'] ?? 0.0;
                                          if (index < rating.floor()) {
                                            // Sao đầy
                                            return Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: screenstextwidth * 0.03,
                                            );
                                          } else if (index < rating && rating - index > 0) {
                                            // Sao một phần
                                            return Icon(
                                              Icons.star_half,
                                              color: Colors.amber,
                                              size: screenstextwidth * 0.03,
                                            );
                                          } else {
                                            // Sao trống
                                            return Icon(
                                              Icons.star_border,
                                              color: Colors.grey,
                                              size: screenstextwidth * 0.03,
                                            );
                                          }
                                        }),
                                      ],
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


Widget _buildProductDetails(Map<String, dynamic> product, BuildContext context) {
  double rating = product['rate'] ?? 0.0;
  double screenWidth = MediaQuery.of(context).size.width; // Lấy kích thước màn hình

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Layout co giãn theo màn hình
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh có thể co giãn theo chiều ngang
                Flexible(
                  flex: screenWidth > 600 ? 3 : 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 6/9,
                      child: product['imagecover'] != null && product['imagecover']!.isNotEmpty
                          ? Image.memory(
                              base64Decode(product['imagecover']!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.network(
                              'https://via.placeholder.com/600x900',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Nội dung
                Expanded(
                  flex: 4, // Phần text rộng hơn ảnh
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tác giả: ${product['authorName'] ?? 'Không rõ'}',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Mô tả: ${product['description'] ?? 'Không có mô tả'}',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12),
                      // Hiển thị 5 ngôi sao đánh giá
                      Row(
                        children: List.generate(5, (index) {
                          if (index + 1 <= rating) {
                            return Icon(Icons.star, color: Colors.orange, size: 28);
                          } else if (index < rating && (rating - index) > 0) {
                            return Icon(Icons.star_half, color: Colors.orange, size: 28);
                          } else {
                            return Icon(Icons.star_border, color: Colors.orange, size: 28);
                          }
                        }),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${rating.toStringAsFixed(1)} / 5',
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                      SizedBox(height: 20),
                      // Nút "Đọc truyện"
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () {
                            print("charType: ${product['charType']}");
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SeriesChapScreen(
                                  chapType: product['charType'] ?? '2vmsDfhtKjXDna3czkLL',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Đọc truyện',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
