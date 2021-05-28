import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = "https://owlbot.info/api/v4/dictionary/";
  // Get your API key from https://owlbot.info/
  String token = "API KEY";
  TextEditingController _controller = TextEditingController();
  StreamController _streamController;
  Stream _stream;
  Timer _timer;

  search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
    }
    _streamController.add("waiting");
    http.Response response = await http.get(
      Uri.parse(
        url + _controller.text.trim(),
      ),
      headers: {"Authorization": "Token " + token},
    );
    print(response.body);
    if (response.body.contains("message")) {
      _streamController.add(null);
    } else {
      _streamController.add(json.decode(response.body));
    }
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dictionary",
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 12.0,
                    bottom: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextFormField(
                    onChanged: (String text) {
                      if (_timer?.isActive ?? false) {
                        _timer.cancel();
                      }
                      _timer = Timer(
                        Duration(
                          milliseconds: 1000,
                        ),
                        () {
                          search();
                        },
                      );
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: EdgeInsets.only(
                        left: 24.0,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  search();
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text(
                  "Enter a searchable word",
                ),
              );
            }
            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.teal,
                ),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: <Widget>[
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]
                                    ["image_url"] ==
                                null
                            ? null
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                  snapshot.data["definitions"][index]
                                      ["image_url"],
                                ),
                              ),
                        title: Text(
                          _controller.text.trim() +
                              "(" +
                              snapshot.data["definitions"][index]["type"] +
                              ")",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        snapshot.data["definitions"][index]["definition"],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}