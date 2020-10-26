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

import '../delayed_animation.dart';

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
    GlobalFunctions.email = user.email;
    GlobalFunctions.name = user.displayName;
    GlobalFunctions.photoUrl = user.photoUrl;
    await _initializeData(user); //*
    return user;
  }

  Future<void> _facebookLogin() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseUser _user = (await _auth.signInWithCredential(
            FacebookAuthProvider.getCredential(
                accessToken: result.accessToken.token)))
        .user;

    print(_user);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        final profile = jsonDecode(graphResponse.body);
        print("Profile");
        print(profile);
        GlobalFunctions.email = profile["email"];
        GlobalFunctions.name = profile["name"];
        GlobalFunctions.photoUrl = profile["picture"]["data"]["url"];
        _initializeData(_user);
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
    Navigator.pushReplacementNamed(context, '/loading');

    final FirebaseDatabase dataBase = FirebaseDatabase.instance;
    dataBase
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
                  "Not PinMyBus",
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
              Container(
                width: 300,
                height: 300,
                // color: Color.fromRGBO(255, 171, 0, .9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Color.fromRGBO(255, 171, 0, .9),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    DelayedAnimation(
                      child: Text(
                        "Sign in using your ...",
                        style: TextStyle(fontSize: 15.0, color: color),
                      ),
                      delay: 500 + 2500,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DelayedAnimation(delay: 500 + 2500, child: _signInButton()),
                    SizedBox(
                      height: 10.0,
                    ),
                    DelayedAnimation(
                      delay: 500 + 2500,
                      child: RaisedButton(
                        // color: Color.fromRGBO(255, 171, 0, .9),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        onPressed: () {
                          _facebookLogin();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 50,
                                height: 50,
                                // color: Colors.white,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0),
                                  color: Colors.white,
                                ),
                                child: Image(
                                    image: AssetImage(
                                        "assets/images/facebook.png"),
                                    height: 35.0),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Facebook account',
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DelayedAnimation(
                      delay: 500 + 2500,
                      child: _phoneAuthButton(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneAuthButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        color: Colors.white,
      ),
      child: RaisedButton(
        // color: Color.fromRGBO(255, 171, 0, .9),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          Navigator.pushNamed(context, '/phoneauth');
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                // color: Colors.white,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                ),
                child: Icon(Icons.phone_android),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Phone Number',
                style: TextStyle(color: Colors.black),
              )
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
        // color: Color.fromRGBO(255, 171, 0, .9),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () async {
          await _handleSignIn();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                // color: Colors.white,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                ),
                child: Image(
                    image: AssetImage("assets/images/google.png"), height: 5.0),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Google account',
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}
