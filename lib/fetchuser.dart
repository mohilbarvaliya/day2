import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FetchUsersPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User List")),
      body: FutureBuilder<QuerySnapshot>(
        future: firestore.collection('users').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(user['name'] ?? 'No Name'),
                subtitle: Text(user['email'] ?? 'No Email'),
              );
            },
          );
        },
      ),
    );
  }
}
