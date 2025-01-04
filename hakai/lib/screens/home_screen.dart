import 'package:flutter/material.dart';
import 'package:hakai/screens/expansion_tile_card.dart'; 

class HomePage extends StatefulWidget{
  
  @override
  
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('hello kitty'),
        
      ),
       
      drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      UserAccountsDrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.green,
        ),
        accountName: const Text(
          "Đỗ Đăng Minh",
          style: TextStyle(fontSize: 18),
        ),
        accountEmail: const Text("daikaminhz178@gmail.com"),
        currentAccountPictureSize: const Size.square(50),
        currentAccountPicture: const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 165, 255, 137),
          child: Text(
            "A",
            style: TextStyle(fontSize: 30.0, color: Colors.blue),
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text('My Profile'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.book),
        title: const Text('My Course'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.workspace_premium),
        title: const Text('Go Premium'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.video_label),
        title: const Text('Saved Videos'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.edit),
        title: const Text('Edit Profile'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Log Out'),
        onTap: () {        
         Navigator.of(context).pushReplacementNamed('/');
        },
      ),
    ],
  ),
),

         bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,   

          fixedColor: Colors.green,
          
          items: const [
            BottomNavigationBarItem(
              label: "Home",
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: "Search",
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: "Profile",
              icon: Icon(Icons.account_circle),
            ),
          ],
          onTap: (int indexOfItem) {}),
    );
    
  }
}
class MyAppState extends ChangeNotifier {

}
