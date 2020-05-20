import 'package:avatar_glow/avatar_glow.dart';
import 'package:pinmybus/delayed_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    _initializeData(user); //*
    return user;
  }

//*Dismantle after the backend is ready to use

  Future<void> _initializeData(FirebaseUser user) async {
    final FirebaseDatabase dataBase = FirebaseDatabase.instance;
    dataBase
        .reference()
        .child("Drivers")
        .child(user.uid)
        .child("Approval")
        .set("No");
  }
//*

  @override
  Widget build(BuildContext context) {
    final color = Colors.black;
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 215, 0, .9),
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
                endRadius: 150,
                duration: Duration(seconds: 2),
                glowColor: Colors.white24,
                repeat: true,
                repeatPauseDuration: Duration(seconds: 2),
                startDelay: Duration(seconds: 1),
                child: Material(
                    elevation: 8.0,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      radius: 80,
                        backgroundColor: Colors.white,
                        // backgroundImage: NetworkImage('https://media.gettyimages.com/vectors/bus-with-navigation-location-map-pin-icon-vector-illustration-vector-id1208844814'),
                        child: Icon(IconData(58672, fontFamily: 'MaterialIcons')
                        ,size: 100,
                        color: Color.fromRGBO(255, 215, 0, .9),),
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
              .then((FirebaseUser user) => print(user))
              .catchError((e) => print(e));
          //Finish the OAuth consent to not get API Exception
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("assets/google.png"), height: 35.0),
            ],
          ),
        ),
      ),
    );
  }
}
