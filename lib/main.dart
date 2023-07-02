import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(NasaDailyApp());
}

class NasaDailyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nasa Daily',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.grey),
        ),
      ),
      home: NasaDailyScreen(),
    );
  }
}

class NasaDailyScreen extends StatefulWidget {
  @override
  _NasaDailyScreenState createState() => _NasaDailyScreenState();
}

class _NasaDailyScreenState extends State<NasaDailyScreen> {
  String _title = '';
  String _date = '';
  String _description = '';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchNasaDailyPhoto();
  }

  Future<void> fetchNasaDailyPhoto() async {
    final response = await http.get(Uri.parse('https://api.nasa.gov/planetary/apod?api_key=IORgClb8l9mBWULEl0XVw1HTPrMWaV98v4OqFl53&date=2023-06-03'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _title = jsonData['title'];
        _date = jsonData['date'];
        _description = jsonData['explanation'];
        _imageUrl = jsonData['url'];
      });
    } else {
      throw Exception('Failed to fetch NASA daily photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 50,
          title: Text(
              'Nasa Daily',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )
          )
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black,
                Colors.deepPurple,
              ],
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.purple,
              splashColor: Colors.purple,
              colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black26),
            ),
            child: Scrollbar(
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.black,
                showLeading: false,
                showTrailing: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_imageUrl.isNotEmpty)
                        Image.network(
                          _imageUrl,
                          fit: BoxFit.cover,
                          width: 380,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(38.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title,
                              style: TextStyle(
                                fontSize: 26,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _date,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white38,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _description,
                              style: TextStyle(
                                fontSize: 19,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.black,
                        width: 420,
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Credits: NASA',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}
