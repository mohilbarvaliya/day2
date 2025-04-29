import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Showdata extends StatefulWidget {
  const Showdata({super.key});

  @override
  State<Showdata> createState() => _ShowdataState();
}

class _ShowdataState extends State<Showdata> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Data'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(  // Wrap StreamBuilder in Expanded to prevent infinite height issue
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("Dit").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text("${index + 1}"),
                          ),
                          title: Text(doc["email"] ?? "No email"),
                          subtitle: Text(doc["name"] ?? "No name"),
                        );
                      },
                    );
                    // return Text("Data Found: ${snapshot.data!.docs.length} documents");
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else {
                    return const Center(child: Text("No Data Found"));
                  }
                }

                return const Center(child: Text("Loading..."));
              },
            ),
          ),
        ],
      ),
    );
  }
}
