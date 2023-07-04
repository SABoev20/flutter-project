import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(NasaDailyApp());
}

class NasaDailyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StellarSync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.white12),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String _title = 'Welcome To StellarSync!';
  String _date = 'Here you can find NASA daily blogs.';
  String _description = '\n \n \n Select news and blogs from all over the years:';
  String _imageUrl = 'https://cdn.discordapp.com/attachments/900689339179216926/1125534624077062254/logo.jpg';

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  Map<DateTime, List<dynamic>> _events = {};

  Future<void> fetchNasaDailyPhoto(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await http.get(
      Uri.parse('https://api.nasa.gov/planetary/apod?api_key=IORgClb8l9mBWULEl0XVw1HTPrMWaV98v4OqFl53&date=$formattedDate'),
    );

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

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    fetchNasaDailyPhoto(selectedDay);
  }

  void _toggleCalendarVisibility() {
    setState(() {
      _calendarFormat = _calendarFormat == CalendarFormat.month ? CalendarFormat.week : CalendarFormat.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 60,
        title: Text(
          "StellarSync",
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
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
                      SizedBox(height: 18),
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2010, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        onDaySelected: _onDaySelected,
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.purpleAccent,
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: TextStyle(color: Colors.white),
                          weekendTextStyle: TextStyle(color: Colors.white),
                          holidayTextStyle: TextStyle(color: Colors.white),
                          outsideTextStyle: TextStyle(color: Colors.white70),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                          headerPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black,
                  width: 420,
                  height: 50,
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
    );
  }
}