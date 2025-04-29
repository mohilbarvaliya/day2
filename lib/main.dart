import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day2/auth/login.dart';
import 'package:day2/fetchuser.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    var emailcontroller = TextEditingController();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home:LoginPage()
      home:const MyHomePage(title:"sender Page"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var emailcontroller = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> getSingleUser(String docId) async {
  DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(docId).get();

  if (doc.exists) {
    print("User data: ${doc.data()}");
  } else {
    print("No such document!");
  }
}


  void uploadData() {
    print("Uploading data to Firestore...");
    firestore.collection('users').add({
      'name': 'mohil',
      'email': emailcontroller.text.toString(),
      'age': 20,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      print("Data uploaded with ID: ${value.id}");
      // emailcontroller.clear(); // Clear the text field after upload
    }).catchError((error) {
      print("Failed to upload data: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: [
          Container(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: emailcontroller,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Perform action on button press
            uploadData();
            print(emailcontroller.text.toString());
            setState(() {
              emailcontroller.clear(); // Clear the text field after upload
            });
          },
          child: const Text('Submit'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Perform action on button press
            getSingleUser("lmBcDiMHe9ooDeONY7tz");
            print(emailcontroller.text.toString());
            setState(() {
              emailcontroller.clear(); // Clear the text field after upload
            });
          },
          child: const Text('Get User'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(child:Text("click to view all user"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FetchUsersPage()));
          },
        ),
        ],)
        
      )
      );
  }
}
