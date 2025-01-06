import 'package:flutter/material.dart';

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
    Center(child: 
    Text("vào phần drawer và bấm vào user grid hoặc vào user tại bottom navigation bar item để xem user grid",
    style: TextStyle(
      fontSize: 40,
      color: Colors.red,
      ),
    )),
    Center(child: Text("Search Page")),
    UserScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              accountName: const Text("Đăng Minh"),
              accountEmail: const Text("daikaminhz178@gmail.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text("ĐM", style: TextStyle(fontSize: 30)),
              ),
            ),
            ListTile(
              leading: Icon(Icons.grid_view),
              title: Text('User grid'),
              onTap: () {
                Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => UserScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Search", icon: Icon(Icons.search)),
          BottomNavigationBarItem(label: "Users Grid", icon: Icon(Icons.people)),
        ],
      ),
    );
  }
}

class User {
  String username;
  String password;
  String role;

  User({required this.username, required this.password, required this.role});

  @override
  String toString() {
    return 'User(username: $username, role: $role)';
  }
}

class UserScreen extends StatelessWidget {
  final List<User> users = [
    User(username: "Tuấn", password: "123", role: "Admin"),
    User(username: "Dũng", password: "456", role: "Editor"),
    User(username: "Thành", password: "789", role: "Viewer"),
    User(username: "Quang", password: "101", role: "Contributor"),
    User(username: "Hiếu", password: "202", role: "Guest"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text("User Grid"),
  automaticallyImplyLeading: false,
  leading: IconButton(
    onPressed: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    },
    icon: Icon(Icons.arrow_left_sharp),
  ),
),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 10,
          ),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Center(
                child: Text(
                  "Username: ${user.username}\nRole: ${user.role}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
