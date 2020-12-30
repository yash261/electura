import 'dart:convert';
import 'package:dropbox/Screens/HomeScreen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:dropbox/Screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _loginState();
  }
}

GlobalKey<ScaffoldState> skey = GlobalKey<ScaffoldState>();

class _loginState extends State<LoginScreen> {
  bool load = false;
  int c = 0;
  String error = "";
  var email = TextEditingController();
  var pass = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    return Scaffold(
      key: skey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.blue.shade800],
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
                    key: key,
                    child: Column(
                      children: <Widget>[
                        Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.black,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          validator: (val) =>
                              val.isEmpty ? "Enter Email" : null,
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            hintText: " Enter your email",
                            labelText: "Email",
                            contentPadding: EdgeInsets.only(top: 15),
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          validator: (val) =>
                              val.isNotEmpty ? null : "Enter correct password",
                          controller: pass,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.black),
                              labelStyle: TextStyle(color: Colors.white),
                              contentPadding: EdgeInsets.only(top: 14),
                              labelText: "Password",
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                              hintText: " Enter your password"),
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        if (load == false)
                          Container(
                            width: double.infinity,
                            child: RaisedButton(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                                onPressed: () {
                                  if (key.currentState.validate()) {
                                    loginAccount(email.text, pass.text);
                                    email.clear();
                                    pass.clear();
                                  }
                                },
                                child: Text(
                                  "LOGIN",
                                  style: TextStyle(
                                      color: Colors.blue, letterSpacing: 1.5),
                                )),
                          )
                        else
                          SpinKitWave(
                            size: 40,
                            color: Colors.white,
                          ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          child: Text(
                            "-OR-",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Sign in with",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    image: AssetImage("images/google.png")),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 6,
                                  )
                                ],
                                shape: BoxShape.circle),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => RegisterScreen()));
                          },
                          child: Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        //   Text(error,style: TextStyle(color: Colors.red,),)
                      ],
                    )),
              ))
        ]),
      ),
    );
  }

  void loginAccount(String email, String password) async {
    setState(() {
      load = true;
    });
    try {
      var result;
      http.Response resp = await http.get(
          'http://192.168.1.209:5000/login?email=$email&password=$password');
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
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen(email: email)));
      }
    } catch (e) {
      print(e);
      setState(() {
        load = false;
      });
    }
  }
}
