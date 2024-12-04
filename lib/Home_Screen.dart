import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load .env variables
  await dotenv.load();
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
  final String apiKey = dotenv.env['API_KEY'] ?? ""; // Ensure API key is loaded
  String city = "Colombo"; // Default city
  String temperature = "";
  String description = "";
  String windSpeed = "";
  String errorMessage = "";
  String weatherIcon = "assets/images/sunny.png"; // Default icon for weather

  Future<void> fetchWeather(String cityName) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          city = data['name'];
          temperature = "${data['main']['temp']} °C";
          description = data['weather'][0]['description'];
          windSpeed = "${data['wind']['speed']} m/s";
          errorMessage = "";

          // Update weather icon based on description
          weatherIcon = getWeatherIcon(description);
        });
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          city = "Error fetching data";
          temperature = "";
          description = "";
          windSpeed = "";
          weatherIcon = "assets/images/unknown.png"; // Default error icon
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
        weatherIcon = "assets/images/unknown.png"; // Default error icon
        errorMessage = "Error: ${e.toString()}";
      });
    }
  }

  String getWeatherIcon(String description) {
    if (description.contains("clear")) {
      return "assets/images/sunny.png";
    } else if (description.contains("cloud")) {
      return "assets/images/cloudy.png";
    } else if (description.contains("rain")) {
      return "assets/images/rainy.png";
    } else if (description.contains("snow")) {
      return "assets/images/snowy.png";
    } else if (description.contains("storm")) {
      return "assets/images/storm.png";
    } else {
      return "assets/images/unknown.png";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city); // Fetch default city weather on startup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        width: double.infinity, // Ensure container spans full width
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center, // Center content
          children: [
            // Weather Icon
            if (weatherIcon.isNotEmpty)
              Image.asset(
                weatherIcon,
                height: 250,
                width: 250,
                // Increased size
              ),
            // Weather information display
            if (city.isNotEmpty && errorMessage.isEmpty)
              Column(
                children: [
                  Text(
                    "City: $city",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFF700),
                    ),
                  ),
                  const SizedBox(height: 10), // Adds margin below the city text
                  Text(
                    "Temperature: $temperature",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Description: $description",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Wind Speed: $windSpeed",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            if (errorMessage.isNotEmpty)
              Column(
                children: [
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
            // City Selection Buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (var cityName in ['New York', 'London', 'Tokyo', 'Colombo', 'Dubai'])
                  ElevatedButton(
                    onPressed: () => fetchWeather(cityName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Set button background color to black
                      foregroundColor: Colors.white, // Set text color to white
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Optional rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ), // Adjust padding for better look
                    ),
                    child: Text(cityName),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
