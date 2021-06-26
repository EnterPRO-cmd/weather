import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature = 0;
  String location = 'San-Francisco';
  int woeid = 2487956;
  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl = 'https://www.metaweather.com/api/location/';
  String weather = "clear";
  String abbrevation = '';

  void fetchSearch(String input) async {
    var searchResult = await http.get(Uri.parse(searchApiUrl + input));
    var result = json.decode(searchResult.body)[0];

    setState(() {
      location = result["title"];
      woeid = result["woeid"];
    });
  }

  void fetchLocation() async {
    var locationResult =
        await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode(locationResult.body);
    var consolidated_weather = result["consolidated_weather"];
    var data = consolidated_weather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbrevation = data["weather_state_abbr"];
    });
  }

  void onTextFieldSubmitted(String input) {
    fetchSearch(input);
    fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/$weather.png'), fit: BoxFit.cover),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Center(
                    child: Image.network(
                      'https://www.metaweather.com/static/img/weather/png/' +
                          abbrevation +
                          '.png',
                      width: 100,
                    ),
                  ),
                  Center(
                    child: Text(
                      temperature.toString() + ' °C',
                      style: TextStyle(color: Colors.white, fontSize: 60.0),
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(color: Colors.white, fontSize: 40.0),
                  )
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input) {
                        onTextFieldSubmitted(input);
                      },
                      style: TextStyle(color: Colors.white, fontSize: 25.0),
                      decoration: InputDecoration(
                        hintText: 'Search another location...',
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 18.0),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),
                        border: const OutlineInputBorder(),
                        labelStyle: new TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
