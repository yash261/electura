import 'dart:convert';
import 'dart:io';
import 'package:dropbox/Screens/LoginScreen.dart';
import 'package:dropbox/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomeScreen extends StatefulWidget {
  final email;
  HomeScreen({this.email});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool load = false;
  List files = [];
  bool filesload = true;
  GlobalKey<ScaffoldState> homestate = GlobalKey<ScaffoldState>();
  getfiles() async {
    var r;
    await http
        .get('http://192.168.1.209:5000/getfiles?email=${widget.email}')
        .then((value) {
      setState(() {
        r = json.decode(value.body);
        filesload = false;
      });
      for (int i = 0; i < r["files"].length; i++) {
        files.add(r["files"][i]);
      }
      print(files);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: homestate,
        appBar: AppBar(
          title: Text("DropBox"),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                Alert(
                  context: context,
                  type: AlertType.warning,
                  title: "Do you want to logout",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "NO",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.blue,
                    ),
                    DialogButton(
                      child: Text(
                        "YES",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen())),
                      color: Colors.red,
                    )
                  ],
                ).show();
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            gallery(context);
          },
        ),
        body: filesload
            ? Center(
                child: SpinKitRipple(
                  color: Colors.teal,
                  size: 50,
                ),
              )
            : Container(
                padding: EdgeInsets.only(top: 10),
                child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0, left: 8, right: 8),
                        child: Card(
                          elevation: 5,
                          color: Colors.grey.shade200,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(files[index]),
                          ),
                        ),
                      );
                    }),
              ));
  }

  void gallery(BuildContext context) async {
    var bytes;
    var url = "http://192.168.1.209:5000/file";
    File f = await Utils.pickImage();
    if (f == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No image selected"),
        backgroundColor: Colors.red,
      ));
    } else {
      setState(() {
        load = true;
      });
      var filename = f.path;
      print(basename(filename));
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(await http.MultipartFile.fromPath('picture', filename));
      request.fields['name'] = basename(filename).toString();
      request.fields['email'] = widget.email;
      var res = await request.send();
      var r = http.Response.fromStream(res);
      r.then((value) {
        setState(() {
          load = false;
        });
        if (value.body == "Uploaded") {
          files.add(basename(filename).toString());
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          value.body,
        )));
      });
      var resp = res.reasonPhrase;
      print(resp);
    }
  }
}
