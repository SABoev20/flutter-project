import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Place {
  final String name;
  final String address;
  final double rating;
  final String photoUrl;

  Place(this.name, this.address, this.rating, this.photoUrl);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _placeTypeController = TextEditingController();
  List<Place> _places = [];

  Future<void> fetchPlaces(String country, String placeType) async {
    final apiKey = 'AIzaSyD1TZWjPHsTiVIZXcuB2Oan7ZPiyWg4WWw'; // Replace with your actual API key
    final baseUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json';
    final url = '$baseUrl?query=$placeType+in+$country&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final placesData = jsonData['results'] as List<dynamic>;

      final places = placesData.map((placeData) {
        final name = placeData['name'];
        final address = placeData['formatted_address'];
        final rating = placeData['rating'] != null ? placeData['rating'].toDouble() : 0.0;
        final photoReference = placeData['photos'][0]['photo_reference'];
        final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';

        return Place(name, address, rating, photoUrl);
      }).toList();

      places.sort((a, b) => b.rating.compareTo(a.rating));

      setState(() {
        _places = places.take(6).toList();
      });
    } else {
      throw Exception('Failed to fetch places');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Places App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Places App'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _countryCodeController,
                decoration: InputDecoration(
                  labelText: 'Country Code (e.g., US)',
                ),
              ),
              TextField(
                controller: _placeTypeController,
                decoration: InputDecoration(
                  labelText: 'Place Type (e.g., restaurant)',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final country = _countryCodeController.text;
                  final placeType = _placeTypeController.text;
                  fetchPlaces(country, placeType);
                },
                child: Text('Search'),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    return ListTile(
                      leading: Image.network(place.photoUrl),
                      title: Text(place.name),
                      subtitle: Text(place.address),
                      trailing: Text('Rating: ${place.rating}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
