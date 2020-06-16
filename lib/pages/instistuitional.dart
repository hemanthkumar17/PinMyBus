import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class Instituitional extends StatelessWidget {
  const Instituitional({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 171, 0, .9),
        ),
        body: Center(
            child: SingleChildScrollView(
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
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(100)),
                      child: Image.asset(
                        'assets/images/logo.png',
                      ))),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Enter Code of the Bus',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 350,
                    child: TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Instituitional Code",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide(),
                        ),
                        // fillColor: Colors.green
                      ),
                      validator: (val) {
                        // if (val.length == 0) {
                        //   return "Password cannot be empty";
                        // } else if (val != _password.text) {
                        //   return "Passwords do not match";
                        // } else {
                        //   return null;
                        // }
                      },
                      keyboardType: TextInputType.emailAddress,
                      style: new TextStyle(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/routeinfo');
                    },
                    color: Color.fromRGBO(255, 171, 0, .9),
                    child: Container(
                        height: 50,
                        width: 100,
                        child: Center(
                          child: Text(
                            'Search',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        )),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  SizedBox(
                    height : 10,
                  )
                ],
              )
            ]))));
  }
}
