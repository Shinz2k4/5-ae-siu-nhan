import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hakai/screens/screens.dart';
import 'package:hakai/screens/word_story_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    WordStoryScreen(),
    ComicScreen(),
    MusicScreen(),
    VideoScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Home Page'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                    ],
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Row(
                    children: [
                      Text(
                        '0',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.diamond,
                        color: Colors.white,
                      ),
                    ],
                  );
                }

                // Lấy số gem từ Firestore
                final int gems = snapshot.data!.get('gem') ?? 0;

                return Row(
                  children: [
                    Text(
                      gems.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.diamond,
                      color: Colors.white,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.green),
                    accountName: Text("Loading..."),
                    accountEmail: Text("Loading..."),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }

                final data = snapshot.data?.data();
                String role = data?['role'] ?? 'user'; // Vai trò mặc định là user
                Color roleColor;

                switch (role.toLowerCase()) {
                  case 'admin':
                    roleColor = Colors.red;
                  case 'seller':
                    roleColor = Colors.amber;
                  default:
                    roleColor = Colors.blue; // user
                }

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.green),
                  accountName: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data?['fullName'] ?? 'No Name'),
                      SizedBox(width: 5), // Khoảng cách giữa tên và vai trò
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        decoration: BoxDecoration(
                          color: roleColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          role.toUpperCase(), // Hiển thị vai trò (in hoa)
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  accountEmail: Text(data?['email'] ?? 'No Email'),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: data?['avatarUrl'] != null
                        ? NetworkImage(data!['avatarUrl'])
                        : null,
                    child: data?['avatarUrl'] == null
                        ? Text(
                            data?['fullName']
                                    ?.split(' ')
                                    .last
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                '',
                            style: TextStyle(fontSize: 30),
                          )
                        : null,
                  ),
                );
              },
            ),
            // Các mục chung cho mọi người
            ListTile(
              leading: Icon(Icons.person,
                  color: const Color.fromARGB(255, 77, 159, 252), size: 30),
              title: Text('Profile'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.amber, size: 30),
              title: Text('Premium'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PremiumScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Colors.green, size: 30),
              title: Text('Nạp tiền'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DepositScreen()),
                );
              },
            ),
            // Mục thêm theo vai trò
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data?.data();
                  String role = data?['role'] ?? 'user';

                  if (role.toLowerCase() == 'admin') {
                    return ListTile(
                      leading: Icon(Icons.group_add, color: Colors.red, size: 30),
                      title: Text('Cấp quyền Seller'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => GrantSellerScreen()),
                        );
                      },
                    );
                  } else if (role.toLowerCase() == 'seller') {
                    return ListTile(
                      leading: Icon(Icons.store, color: Colors.amber, size: 30),
                      title: Text('Cửa hàng của bạn'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => StoreScreen()),
                        );
                      },
                    );
                  } else {
                    return ListTile(
                      leading: Icon(Icons.business_center, color: Colors.blue, size: 30),
                      title: Text('Đăng ký làm Seller'),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ApplySellerScreen()),
                        );
                      },
                    );
                  }
                }
                return SizedBox.shrink(); // Không hiển thị gì khi đang tải
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: const Color.fromARGB(255, 0, 0, 0), size: 30),
              title: Text('Log Out'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
      ),



      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(label: "Truyện Chữ", icon: Icon(Icons.menu_book)),
          BottomNavigationBarItem(label: "Truyện Tranh", icon: Icon(Icons.art_track )),
          BottomNavigationBarItem(label: "Nhạc", icon: Icon(Icons.audiotrack)),
          BottomNavigationBarItem(label: "Video", icon: Icon(Icons.movie))
        ],
      ),
    );
  }
}


class ComicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comic Screen"),
        automaticallyImplyLeading: false,
      ),
      body: Center(child: Text("Comic Screen")),
    );
  }
}

class MusicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music Screen"),
      ),
      body: Center(child: Text("Music Screen")),
    );
  }
}

class VideoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Screen"),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.lightBlue[50],
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Video ngẫu nhiên nảy ra cặp chữ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Video này sẽ giúp bạn học cách phát âm và ghi nhớ các cặp chữ tiếng Anh một cách dễ dàng thông qua hình ảnh trực quan và âm thanh sống động. Nội dung được thiết kế đặc biệt để phù hợp với mọi trình độ, từ người mới bắt đầu đến người học nâng cao. Bạn sẽ được hướng dẫn chi tiết cách phát âm chuẩn và các mẹo ghi nhớ hiệu quả.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star_border, color: Colors.amber, size: 28),
                            SizedBox(width: 12),
                            Text('170 Views', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildInfoColumn(Icons.access_time, 'Duration:', '10 min'),
                            buildInfoColumn(Icons.calendar_today, 'Upload:', 'Today'),
                            buildInfoColumn(Icons.remove_red_eye, 'Views:', '1.2K'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Screenshot.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  Widget buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _avatarUrl;

  Future<void> _loadProfile() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    final data = userDoc.data();
    if (data != null) {
      setState(() {
        _nameController.text = data['fullName'] ?? '';
        _avatarUrl = data['avatarUrl'];
      });
    }
  }

  Future<void> _updateProfile() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({'fullName': _nameController.text});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null
                  ? Icon(Icons.person, size: 50)
                  : null,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}


class PremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('premium'),

        )
      
    );
  }
}


class DepositScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('deposit'),

        )
      
    );
  }
}