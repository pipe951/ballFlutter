import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:google_fonts/google_fonts.dart';

// Model for BallItem
class BallItem {
  final String name;
  final int price;
  final String image;
  final String? localImage;
  final String description;

  BallItem({
    required this.name,
    required this.price,
    required this.image,
    this.localImage,
    required this.description,
  });

  factory BallItem.fromJson(Map<String, dynamic> json) {
    return BallItem(
      name: json['name'],
      price: json['price'],
      image: json['image'],
      localImage: json['local_image'],
      description: json['description'],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ball List',
      theme: ThemeData(
        textTheme: GoogleFonts.maliTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<BallItem>> futureBallItems;

  @override
  void initState() {
    super.initState();
    futureBallItems = loadBallItems();
  }

  Future<List<BallItem>> loadBallItems() async {
    final jsonString =
        await rootBundle.rootBundle.loadString('assets/balls.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((json) => BallItem.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kick Off Store',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(2.0, 2.0),
                blurRadius: 5.0,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.pink,
      ),
      backgroundColor: Colors.pink,
      body: FutureBuilder<List<BallItem>>(
        future: futureBallItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => BallCard(item: items[index]),
            );
          }
        },
      ),
    );
  }
}

class BallCard extends StatelessWidget {
  final BallItem item;

  const BallCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: item.localImage != null
            ? Image.asset(item.localImage!) // ใช้รูปภาพจากเครื่องถ้ามี
            : Image.network(item.image), // ใช้รูปออนไลน์ถ้าไม่มีรูปในเครื่อง
        title: Text(item.name),
        subtitle: Text('\฿${item.price}'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(item: item)),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final BallItem item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          style: const TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.pink[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item.localImage != null
                  ? Image.asset(item.localImage!) // แสดงรูปจากเครื่องถ้ามี
                  : Image.network(
                      item.image), // แสดงรูปออนไลน์ถ้าไม่มีในเครื่อง
              const SizedBox(height: 16),
              Text(
                item.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('\฿${item.price}', style: const TextStyle(fontSize: 18)),

              const SizedBox(height: 16),
              Text(item.description),
            ],
          ),
        ),
      ),
    );
  }
}
