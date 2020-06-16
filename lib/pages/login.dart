import 'package:avatar_glow/avatar_glow.dart';
import 'package:pinmybus/delayed_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/stops.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    await GlobalFunctions.getStops();
    await _initializeData(user); //*
    return user;
  }

//*Dismantle after the backend is ready to use

  Future<void> _initializeData(FirebaseUser user) async {
    final FirebaseDatabase dataBase = FirebaseDatabase.instance;
    await dataBase
        .reference()
        .child("userInfo")
        .child(user.uid)
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        dataBase
            .reference()
            .child("userInfo")
            .child(user.uid)
            .set({
          "contactNumber": "",
          "dateOfCreation": DateTime.now().millisecondsSinceEpoch,
          "email": user.email,
          "status": "active",
          "userType": "default",
        });
      }
    });
  }
//*

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
                  endRadius: 150,
                  duration: Duration(seconds: 2),
                  glowColor: Color.fromRGBO(255, 171, 0, .9),
                  repeat: true,
                  repeatPauseDuration: Duration(seconds: 2),
                  startDelay: Duration(seconds: 1),
                  child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(100)),
                      child: Image.asset(
                        'assets/images/logo.png',
                      ))),
              DelayedAnimation(
                child: Text(
                  "PinMyBus",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35.0,
                      color: color),
                ),
                delay: 500 + 1000,
              ),
              SizedBox(
                height: 30.0,
              ),
              DelayedAnimation(
                child: Text(
                  "Track your Travel",
                  style: TextStyle(fontSize: 20.0, color: color),
                ),
                delay: 500 + 2000,
              ),
              SizedBox(
                height: 30.0,
              ),
              DelayedAnimation(delay: 500 + 2500, child: _signInButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        color: Colors.white,
      ),
      child: RaisedButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          _handleSignIn()
              .then((FirebaseUser user) =>
                  Navigator.pushNamed(context, '/home', arguments: user))
              .catchError((e) => print(e));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                  image: AssetImage("assets/images/google.png"), height: 35.0),
            ],
          ),
        ),
      ),
    );
  }
}
