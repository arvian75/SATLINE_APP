import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class FirebaseStorageManager {
  List<String> folderName = <String>[];
  List<Map<String, String>> downloadURL = <Map<String, String>>[];
  Map<String, String> recentImage = <String, String>{};

  Future getFolder() async {
    try {
      await fecthFolder();
      return folderName;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getImage(String folderName) async {
    try {
      await fetchImage(folderName);
      return downloadURL;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future getRecent() async {
    try {
      await fetchRecentImage();
      return recentImage;
    } catch (e) {
      debugPrint("Error - $e");
      return null;
    }
  }

  Future<void> fecthFolder() async {
    final storageRef = FirebaseStorage.instance.ref().child("images");
    final listResult = await storageRef.listAll();
    int counter = 0;

    for (var prefix in listResult.prefixes) {
      // The items under storageRef.
      folderName.insert(counter, prefix.name);
      counter++;
    }
  }

  Future<void> fetchImage(String folderName) async {
    final storageRef = FirebaseStorage.instance.ref().child("images/$folderName");
    final listResult = await storageRef.listAll();
    int counter = 0;
    for (var item in listResult.items) {
        // The items under storageRef.
        String url = await item.getDownloadURL();
        String dateTimeTaken = item.name.replaceAll(RegExp('.jpg'), '');
        downloadURL.insert(counter, {'dateTimeTaken': dateTimeTaken, 'url': url});
        counter++;
    }
  }

  Future<void> fetchRecentImage() async {
    final storageRef = FirebaseStorage.instance.ref().child("images");
    final listResult = await storageRef.listAll();
    var folderName = listResult.prefixes.last.name;
    final storageRef2 = FirebaseStorage.instance.ref().child("images/$folderName");
    final listResult2 = await storageRef2.listAll();
    var item = listResult2.items.last;
    String url = await item.getDownloadURL();
    String dateTimeTaken = item.name.replaceAll(RegExp('.jpg'), '');
    recentImage = {'dateTimeTaken': dateTimeTaken, 'url': url};
  }
}

class FirebaseDatabaseManager {
  Future<String> readDoorState() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final snapshot = await databaseReference.child('Send/DoorState').get();
    String doorState = '';
    doorState = snapshot.value.toString();
    return doorState;
  }

  Future<bool> readLock() async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final snapshot = await databaseReference.child('Receive/LockState').get();
    int? doorState;
    doorState = snapshot.value as int?;
    return doorState == 1 ? true : false;
  }

  void updateData(int value) async{
    final databaseReference = FirebaseDatabase.instance.ref("Receive");
    await databaseReference.update({
      'LockState': value,
    });
  }
}

