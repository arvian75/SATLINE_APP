import 'package:flutter/material.dart';
import '../widget/picture_item.dart';
import '/data/database_manager.dart';

class PictureScreen extends StatefulWidget {
  final String folderName;
  const PictureScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  _PictureScreenState createState() => _PictureScreenState();
}

class _PictureScreenState extends State<PictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
            color: Colors.white), // Change back arrow color to white
      ),
      body: FutureBuilder(
        future: FirebaseStorageManager().getImage(widget.folderName.toString()),
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
                String imageUrl =
                    snapshot.data[snapshot.data.length - index - 1]['url'];
                String dateTimeTaken = snapshot
                    .data[snapshot.data.length - index - 1]['dateTimeTaken'];
                return SizedBox(
                  height: 300,
                  width: 250,
                  child: PictureItem(
                    imageUrl: imageUrl,
                    dateTimeTaken: dateTimeTaken,
                  ),
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
