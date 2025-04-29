import 'dart:io';

import 'package:day2/auth/login.dart';
import 'package:day2/auth/showdata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? pickedImage;
  bool isUploading = false;

  // Logout Function
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage())); // Make sure route exists
  }

  // Image Picker Function
  Future<void> pickImage(ImageSource imageSrc) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageSrc);
      if (photo == null) return;

      setState(() {
        pickedImage = File(photo.path);
      });
    } catch (ex) {
      debugPrint("Error picking image: $ex");
    }
  }

  // Alert Box for Image Picker
  void showAlertBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick an Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
              ),
              ListTile(
                onTap: () {
                  pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Upload Image to Firebase Storage
  Future<void> uploadImage() async {
    if (pickedImage == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Image Selected'),
            content: const Text('Please select an image before uploading.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      setState(() => isUploading = true);
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: "User not logged in",
          message: "Please login before uploading images.",
        );
      }

      // Upload image to Firebase Storage
      String fileName = "profile_${user.uid}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_pics/$fileName');
      UploadTask uploadTask = storageRef.putFile(pickedImage!);

      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store the URL in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        "profilePic": downloadUrl,
        "email": user.email,
      });

      setState(() => isUploading = false);

      // Success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Upload Successful'),
            content: const Text('Your profile image has been uploaded successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() => isUploading = false);
      debugPrint("Error uploading image: $e");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Upload Failed'),
            content: Text("Error: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Welcome to the Home Page!', style: TextStyle(fontSize: 18)),

          // Profile Picture (Tap to Pick Image)
          InkWell(
            onTap: showAlertBox,
            child: pickedImage != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(pickedImage!),
                  )
                : const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 80),
                  ),
          ),

          const SizedBox(height: 20),

          // Upload Button
          ElevatedButton(
            onPressed: isUploading ? null : uploadImage,
            child: isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Upload Image'),
          ),

          const SizedBox(height: 20),

          // Logout Button
          ElevatedButton(
            onPressed: logout,
            child: const Text('Logout'),
          ),

          const SizedBox(height: 20),

          // Showdata Section - Wrapping with Expanded to Prevent Overflow
          Expanded(child: Showdata()),
        ],
      ),
    );
  }
}
