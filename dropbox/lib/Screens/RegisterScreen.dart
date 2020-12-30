import 'dart:convert';

import 'package:dropbox/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var error = "";
  bool load = false;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  var email = TextEditingController();
  var pass = TextEditingController();
  var cpass = TextEditingController();
  var username = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final key1 = GlobalKey<FormState>();

    return Scaffold(
      key: _scaffoldkey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.blue.shade800],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)),
            ),
            Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 120.0,
                ),
                child: Form(
                    key: key1,
                    child: Column(
                      children: <Widget>[
                        Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.black,
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 30.0,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black),
                            hintText: "Enter your username",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            labelText: "Username",
                          ),
                          controller: username,
                          keyboardType: TextInputType.text,
                          validator: (val) =>
                              val.isEmpty ? "Enter a username" : null,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.black),
                            hintText: "Enter your email",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            labelText: "Email",
                          ),
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) =>
                              val.isEmpty ? "Enter a email" : null,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          controller: pass,
                          decoration: InputDecoration(
                              labelText: "Enter password",
                              labelStyle: TextStyle(color: Colors.white),
                              hintStyle: TextStyle(color: Colors.black),
                              hintText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.white,
                              )),
                          obscureText: true,
                          validator: (val) {
                            return val.length >= 6
                                ? null
                                : "Enter a password of atleast 6 characters";
                          },
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Confirm password",
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            labelStyle: TextStyle(color: Colors.white),
                            hintStyle: TextStyle(color: Colors.black),
                            hintText: "Re-enter your password",
                          ),
                          obscureText: true,
                          controller: cpass,
                          validator: (val) {
                            return val == pass.text
                                ? null
                                : "Both passwords are different";
                          },
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        if (load == false)
                          Container(
                            width: double.infinity,
                            child: RaisedButton(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              onPressed: () {
                                if (key1.currentState.validate()) {
                                  setState(() {
                                    load = true;
                                  });
                                  createAccount(
                                      email.text, username.text, pass.text);
                                  email.clear();
                                  username.clear();
                                  pass.clear();
                                  cpass.clear();
                                }
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.blue.shade800,
                                    letterSpacing: 1.5),
                              ),
                            ),
                          )
                        else
                          SpinKitWave(
                            size: 40,
                            color: Colors.white,
                          ),
                        SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Already have an account? Log In",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getPublicIP() async {
    try {
      const url = 'https://api.ipify.org';
      var response = await http.get(url);
      if (response.statusCode == 200) {
        print(response.body);
        return response.body;
      } else {
        print(response.statusCode);
        print(response.body);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  void createAccount(String email, String username, String password) async {
    try {
      var result;
      getPublicIP().then((value) async {
        http.Response resp = await http.get(
            'http://192.168.1.209:5000/createaccount?email=$email&username=$username&password=$password&ip=$value');
        setState(() {
          result = json.decode(resp.body);
        });
        print(result);
        if (result["status"] == 404) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              result["msg"],
            ),
            duration: Duration(seconds: 8),
            backgroundColor: Colors.red,
          ));
          setState(() {
            load = false;
          });
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => HomeScreen(
                    email: email,
                  )));
        }
      });
    } catch (Exception) {
      setState(() {
        load = false;
      });
    }
  }
}
