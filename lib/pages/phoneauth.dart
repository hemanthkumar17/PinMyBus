import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuthScreen extends StatefulWidget {
  PhoneAuthScreen({Key key}) : super(key: key);

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  TextEditingController _otpController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  FirebaseUser _firebaseUser;
  String _status;

  String locale = "+91";

  AuthCredential _phoneAuthCredential;
  String _verificationId;
  int _code;

  @override
  void initState() {
    super.initState();
    _getFirebaseUser();
  }

  Future<void> _getFirebaseUser() async {
    this._firebaseUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      _status =
          (_firebaseUser == null) ? 'Not Logged In\n' : 'Already LoggedIn\n';
    });
    print(_firebaseUser);
  }

  Future<void> _login(BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(this._phoneAuthCredential)
          .then((AuthResult authRes) {
        _firebaseUser = authRes.user;
        print(_firebaseUser.toString());
      });
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      setState(() {
        _status += e.toString() + '\n';
      });
      print(e.toString());
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Failed"),
            content: Container(
              child: Text("Invalid OTP"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.popUntil(
                      context, ModalRoute.withName('/phoneauth'));
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _firebaseUser = null;
      setState(() {
        _status += 'Signed out\n';
      });
    } catch (e) {
      setState(() {
        _status += e.toString() + '\n';
      });
      print(e.toString());
    }
  }

  Future<void> _submitPhoneNumber() async {
    String phoneNumber = locale + _phoneController.text.toString().trim();
    print(phoneNumber);
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      print('verificationCompleted');
      setState(() {
        _status += 'verificationCompleted\n';
      });
      this._phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
    }

    void verificationFailed(AuthException error) {
      print('verificationFailed');
      setState(() {
        _status += '$error\n';
      });
      print(error.code);
      print(error.message);
    }

    void codeSent(String verificationId, [int code]) {
      print('codeSent');
      this._verificationId = verificationId;
      print(verificationId);
      this._code = code;
      print(code.toString());
      setState(() {
        _status += 'Code Sent\n';
      });
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
      setState(() {
        _status += 'codeAutoRetrievalTimeout\n';
      });
      print(verificationId);
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(milliseconds: 10000),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  void _submitOTP(BuildContext context) {
    /// get the `smsCode` from the user
    String smsCode = _otpController.text.toString().trim();
    this._phoneAuthCredential = PhoneAuthProvider.getCredential(
        verificationId: this._verificationId, smsCode: smsCode);

    _login(context);
  }

  _showPopUp(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'OTP Sent',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          content: Container(
            height: 175,
            padding: EdgeInsets.all(32),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Enter OTP",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[200])),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey[300])),
                        filled: true,
                        fillColor: Colors.grey[100],
                        hintText: "OTP"),
                    controller: _otpController,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Submit OTP'),
              onPressed: () {
                print('Submit OTP Pressed');
                _submitOTP(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 2,
              padding: EdgeInsets.all(32),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 36,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          prefix: Container(
                            height: 30,
                            child: DropdownButton<String>(
                              value: locale,
                              items: ['+91'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  locale = value;
                                });
                              },
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Colors.grey[200])),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: Colors.grey[300])),
                          filled: true,
                          fillColor: Colors.grey[100],
                          hintText: "Phone Number"),
                      controller: _phoneController,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                        child: Text("Login"),
                        textColor: Colors.white,
                        padding: EdgeInsets.all(16),
                        onPressed: () {
                          _submitPhoneNumber();
                          _otpController.clear();
                          _showPopUp(context);
                        },
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              ),
            ), /*
            Container(
              height: 300,
              child: ListView(
                padding: EdgeInsets.all(16),
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: _submitPhoneNumber,
                          child: Text('Submit'),
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            hintText: 'OTP',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Spacer(),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: _submitOTP,
                          child: Text('Submit'),
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 48),
                  Text('$_status'),
                  SizedBox(height: 48),
                  MaterialButton(
                    onPressed: _login,
                    child: Text('Login'),
                    color: Theme.of(context).accentColor,
                  ),
                  SizedBox(height: 24),
                  MaterialButton(
                    onPressed: _logout,
                    child: Text('Logout'),
                    color: Theme.of(context).accentColor,
                  )
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
