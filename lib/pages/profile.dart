import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pinmybus/models/globals.dart';

// void main() => runApp(Profile());

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String name = GlobalFunctions.name;
    String mailId = GlobalFunctions.email;
    return MaterialApp(
        title: 'Profile',
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            title: Text('Profile'),
            backgroundColor: Color.fromRGBO(255, 171, 0, .9),
          ),
          body: Center(
            child: Container(
              child: Stack(children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Color.fromRGBO(255, 171, 0, .9),
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(name),
                          SizedBox(
                            height: 10,
                          ),
                          Text(mailId),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(0, -.5),
                  child: CircleAvatar(
                      backgroundImage: NetworkImage((GlobalFunctions.photoUrl !=
                              null)
                          ? GlobalFunctions.photoUrl
                          : 'https://d2x5ku95bkycr3.cloudfront.net/App_Themes/Common/images/profile/0_200.png'),
                      minRadius: 50,
                      maxRadius: 100),
                ),
              ]),
            ),
          ),
        ));
  }
}
