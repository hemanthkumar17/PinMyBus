import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:pinmybus/delayed_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/stops.dart';
import 'package:pinmybus/utils/reminder.dart';

import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoggedIn;
  @override
  void initState() {
    super.initState();
  }

  bool disabled = false;
  Future<FirebaseUser> _handleSignIn() async {
    setState(() {
      disabled = true;
    });
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
    await GlobalFunctions.getInstitutes();
    Scheduler.initNotifications();
    _initializeData(user); //*
    return user;
  }

  Future<void> _facebookLogin() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logInWithReadPermissions(['email']);
    print(result.errorMessage);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = jsonDecode(graphResponse.body);
        print("Profile");
        print(profile);
        setState(() {
          final userProfile = profile;
          _isLoggedIn = true;
        });
        break;

      case FacebookLoginStatus.cancelledByUser:
        setState(() => _isLoggedIn = false);
        break;
      case FacebookLoginStatus.error:
        setState(() => _isLoggedIn = false);
        break;
    }
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
        dataBase.reference().child("userInfo").child(user.uid).set({
          "contactNumber": "",
          "dateOfCreation": DateTime.now().millisecondsSinceEpoch,
          "email": user.email,
          "status": true,
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
              DelayedAnimation(
                  delay: 500 + 2500,
                  child: RaisedButton(onPressed: () {
                    _facebookLogin();
                  }))
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    if (disabled == false) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.white,
        ),
        child: RaisedButton(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
                    image: AssetImage("assets/images/google.png"),
                    height: 35.0),
              ],
            ),
          ),
        ),
      );
    } else
      return Container();
  }
}
