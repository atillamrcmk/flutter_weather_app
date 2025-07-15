import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/weather_model.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      title: 'Material App',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> sehirler = [
    "Ankara",
    "Bursa",
    "İzmir",
    "Erzurum",
    "Samsun",
    "İstanbul",
  ];

  String? secilenSehir;
  Future<WeatherModel>? weatherFuture;

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      queryParameters: {
        "appid": 'ae5a434218e9c542df459eb2c0b18de6',
        "lang": 'tr',
        "units": "metric",
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hava Durumu')),
      body: Column(
        children: [
          if (weatherFuture != null)
            FutureBuilder<WeatherModel>(
              future: weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("❌ Hata oluştu"),
                  );
                } else if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("⚠️ Veri alınamadı"),
                  );
                } else {
                  final weather = snapshot.data!;
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "📍 ${weather.name}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "🌡️ Sıcaklık: ${weather.main?.temp?.toStringAsFixed(1) ?? '-'}°C",
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "💧 Nem: ${weather.main?.humidity?.toStringAsFixed(0) ?? '-'}%",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => selectedcity(sehirler[index]),
                  child: Card(
                    child: Center(
                      child: Text(
                        sehirler[index],
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                );
              },
              itemCount: sehirler.length,
            ),
          ),
        ],
      ),
    );
  }

  void selectedcity(String sehir) {
    setState(() {
      secilenSehir = sehir;
      weatherFuture = getWeather(sehir);
    });
  }

  Future<WeatherModel> getWeather(String secilenSehir) async {
    final response = await dio.get(
      '/weather',
      queryParameters: {"q": secilenSehir},
    );
    final model = WeatherModel.fromJson(response.data);
    debugPrint("Şehir: ${model.name}, Sıcaklık: ${model.main?.temp}");
    return model;
  }
}
