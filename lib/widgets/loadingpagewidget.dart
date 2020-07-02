import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:pinmybus/delayed_animation.dart';

class LoadingPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
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
                      // color: Colors.blacks.white,
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
                  color: Colors.black),
            ),
            delay: 500 + 1000,
          ),
          DelayedAnimation(
            child: Text(
              "Loading ...",
              style: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                  color: Color.fromRGBO(255, 171, 0, .9)),
            ),
            delay: 500 + 2000,
          ),
          SizedBox(
            height: 10.0,
          ),
        ]));
  }
}
