import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tugas_rancang_fin/widget/picture_item.dart';
import '../data/database_manager.dart';
import 'dart:async';

var _periodicTimer;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void dispose() {
    _periodicTimer.cancel();
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _doorState = '', oldValue = '';
  bool _switchValue = false;
  String lock = 'Locked';
  var _unlockTimer;

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Redirect to the login screen or any other screen after successful logout
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  void fetchDataPeriodically() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      FirebaseDatabaseManager().readDoorState().then((value) {
        checkChanges(value);
      });
    });
  }

  void checkChanges(String value) {
    if (value != oldValue) {
      oldValue = value;
      setState(() {
        _doorState = value;
      });
    }
  }

  void setUnlockTimer() {
    _unlockTimer = Timer(const Duration(minutes: 5), () {
      setState(() {
        _switchValue = false;
        FirebaseDatabaseManager().updateData(0);
        lock = 'Locked';
      });
      disposeUnlockTimer();
    });
  }

  void disposeUnlockTimer() {
    _unlockTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    fetchDataPeriodically();
    FirebaseDatabaseManager().readLock().then((value) {
      _switchValue = value;
      if (_switchValue == true && lock == 'Locked') {
        lock = 'Unlocked';
      } else if (_switchValue == false && lock == 'Unlocked') {
        lock = 'Locked';
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 250,
              width: 300,
              child: FutureBuilder(
                future: FirebaseStorageManager().getRecent(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      "Something went wrong",
                    );
                  }
                  if (snapshot.hasData) {
                    String imageUrl = snapshot.data['url'];
                    String dateTimeTaken = snapshot.data['dateTimeTaken'];
                    return PictureItem(
                      imageUrl: imageUrl,
                      dateTimeTaken: dateTimeTaken,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: Text('Door $_doorState'),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 80,
                  child: Switch(
                    value: _switchValue,
                    activeColor: Colors.black, // Set switch color to black
                    inactiveThumbColor: Colors.black,
                    activeTrackColor: Colors.green,
                    inactiveTrackColor: Colors.red,
                    onChanged: (newValue) {
                      setState(() {
                        _switchValue = newValue;
                        if (_switchValue == true) {
                          FirebaseDatabaseManager().updateData(1);
                          lock = 'Unlocked';
                          setUnlockTimer();
                        } else {
                          FirebaseDatabaseManager().updateData(0);
                          lock = 'Locked';
                          if (_unlockTimer.isActive) {
                            disposeUnlockTimer();
                          }
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(lock),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 50,
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black, // Set button color to black
                  onPrimary: Colors.white, // Set font color to white
                ),
                child: const Text('Update Image'),
                onPressed: () {
                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        child: Icon(Icons.logout),
        backgroundColor: Colors.red,
      ),
    );
  }
}
