// ignore: file_names
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiKey = "${dotenv.env['API_KEY']}";
  String city = "";
  String temperature = "";
  String description = "";
  String windSpeed = "";
  String errorMessage = "";

  Future<void> fetchWeather(String cityName) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);

      // Debug logs for response
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          city = data['name'];
          temperature = "${data['main']['temp']} °C";
          description = data['weather'][0]['description'];
          windSpeed = "${data['wind']['speed']} m/s";
          errorMessage = ""; // Clear any previous errors
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          city = "Error fetching data";
          temperature = "";
          description = "";
          windSpeed = "";
          errorMessage =
              "Error: ${errorData['message'] ?? 'Unknown error occurred'}";
        });
      }
    } catch (e) {
      setState(() {
        city = "Error fetching data";
        temperature = "";
        description = "";
        windSpeed = "";
        errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFA500),
              const Color.fromARGB(255, 77, 10, 139).withOpacity(0.6),
              const Color(0xFF000000),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Buttons for cities
            for (var cityName in ['New York', 'London', 'Tokyo', 'Colombo', 'Dubai'])
              ElevatedButton(
                onPressed: () => fetchWeather(cityName),
                child: Text(cityName),
              ),
            const SizedBox(height: 20),
            // Weather information display
            if (city.isNotEmpty && errorMessage.isEmpty)
              Column(
                children: [
                  Text(
                    "City: $city",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Temperature: $temperature",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "Description: $description",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    "Wind Speed: $windSpeed",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            if (errorMessage.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
