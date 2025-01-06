# Nhóm 11 - DocNews-App

## Members:

- Đỗ Đăng Minh
- Nguyễn Chí Thanh
- Tạ Thành Phú

## Introduction

News and Articles Application

# Structural Diagram

Class Diagram

#![Image](<./hakai/assets/DocNews-App.png>)

```
Class User {
String userID;
String name;
String email;
String password;

void readArticle(){
//code

}
void saveArticle(){
//se phai su dung object la Article

}




}

```

# Behavioural Diagram

Sequence Diagram


[Activity Diagram]
# Screenshot my first app
![Image](<./hakai/assets/Screenshot.jpg>)


# Screen shot Bài kiểm tra giữa kỳ 
![Image](<./hakai/assets/Screenshot 2025-01-06 143824.png>)
![Image](<./hakai/assets/Screenshot 2025-01-06 143834.png>)
![Image](<./hakai/assets/Screenshot 2025-01-06 143857.png>)

# Code chính của User grid 
```
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
    User(username: "Dũng", password: "45346", role: "Editor"),
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

