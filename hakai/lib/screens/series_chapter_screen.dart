import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SeriesChapScreen extends StatelessWidget {
  final String chapType;

  SeriesChapScreen({ required this.chapType});

  Future<List<Map<String, dynamic>>> _fetchChapters() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('series')
        .doc(chapType)
        .collection('178') // "178" là tên collection con
        .get();

    return querySnapshot.docs
        .map((doc) => {'chapId': doc.id, ...doc.data()})
        .where((chapter) {
          try {
            int chapId = int.parse(chapter['chapId'].toString());
            return chapId >= 1;
          } catch (e) {
            print('Error parsing chapId: $e');
            return false;
          }
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Chương'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchChapters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi khi tải dữ liệu!'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có chương nào được tìm thấy!'));
          }

          final chapters = snapshot.data!;

          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              try {
                chapters.sort((a, b) => int.parse(a['chapId'].toString()).compareTo(int.parse(b['chapId'].toString())));
              } catch (e) {
                print('Error sorting chapters: $e');
              }
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Chương ${chapter['chapId']}'),
                  subtitle: Text(chapter['nameChap'] ?? 'Không có nội dung'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChapterDetailScreen(
                          content: chapter['content'] ?? 'Không có nội dung',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChapterDetailScreen extends StatelessWidget {
  final String content;

  ChapterDetailScreen({required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết chương'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
