import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/database_manager.dart';
import 'picture_screen.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({Key? key}) : super(key: key);

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Redirect to the login screen or any other screen after a successful logout
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: FirebaseStorageManager().getFolder(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "Something went wrong",
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PictureScreen(
                          folderName:
                              snapshot.data[snapshot.data.length - index - 1],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Button color
                    onPrimary: Colors.white, // Text color
                  ),
                  child: Text(snapshot.data[snapshot.data.length - index - 1]),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
