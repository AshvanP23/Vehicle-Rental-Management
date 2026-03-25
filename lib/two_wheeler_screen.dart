import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'two_wheeler_data.dart';
import 'vehicle_detail_screen.dart';

class TwoWheelersScreen extends StatefulWidget {
  @override
  State<TwoWheelersScreen> createState() => _TwoWheelersScreenState();
}

class _TwoWheelersScreenState extends State<TwoWheelersScreen> {
  final supabase = Supabase.instance.client;
  
  String search = "";
  double min = 0, max = 3000;
  int selected = 0;

  late List<Map<String, dynamic>> shuffledBikes;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shuffleAll();
    _autoUploadVehicles(); 
  }

  Future<void> _autoUploadVehicles() async {
    try {
      final data = await supabase.from('vehicles').select('id').eq('type', 'Bike').limit(1);
      
      if (data.isEmpty) {
        print("Uploading Bikes to Database...");
        for (var v in twoWheelers) {
          await supabase.from('vehicles').insert({
            'name': v['name'],
            'image': v['image'],
            'price': v['price'],
            'available': true, 
            'type': 'Bike',
          });
        }
        if (mounted) setState(() {}); 
      }
    } catch (e) {
      print("Sync Error: $e");
    }
  }

  void _shuffleAll() {
    shuffledBikes = List<Map<String, dynamic>>.from(twoWheelers);
    shuffledBikes.shuffle(Random());
  }

  double rating(String name) {
    final r = Random(name.hashCode);
    return 3.8 + r.nextDouble() * 1.1;
  }

  @override
  Widget build(BuildContext context) {
    final list = shuffledBikes.where((v) {
      return v["name"].toLowerCase().contains(search.toLowerCase()) &&
          v["price"] >= min &&
          v["price"] <= max;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Two Wheelers",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      body: Column(
        children: [
          _search(),
          _filters(),
          Expanded(child: _list(list)),
        ],
      ),
    );
  }

  Widget _search() => Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search bike",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => setState(() => search = v),
        ),
      );

  Widget _filters() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _f(0, "All", 0, 3000),
            _f(1, "Budget", 300, 600),
            _f(2, "Standard", 601, 900),
            _f(3, "Performance", 901, 1500),
            _f(4, "Premium", 1501, 3000),
          ],
        ),
      );

  Widget _f(int i, String t, double a, double b) {
    final sel = selected == i;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (i == 0 || selected == i) {
                selected = 0;
                min = 0;
                max = 3000;
                search = "";
                _searchCtrl.clear();
                _shuffleAll();
              } else {
                selected = i;
                min = a;
                max = b;
              }
            });
          },
          child: Container(
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? Colors.yellow : Colors.grey[850],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              t,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: sel ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(List list) => ListView.builder(
        itemCount: list.length,
        itemBuilder: (_, i) => _card(list[i]),
      );

  Widget _card(Map v) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('vehicles').stream(primaryKey: ['id']).eq('name', v['name']),
      builder: (context, snapshot) {
        
        bool isAvailable = true;
        int displayPrice = v['price'];

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final dbData = snapshot.data![0];
          isAvailable = dbData['available'] ?? true;
          displayPrice = dbData['price'] ?? v['price'];
          
          v['price'] = displayPrice;
          v['available'] = isAvailable;
        }

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VehicleDetailScreen(v: v)),
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(v["image"], fit: BoxFit.cover),
                    ),
                    
                    if (!isAvailable)
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Unavailable", 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                          ),
                        ),
                      )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          v["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.star,
                          size: 15, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating(v["name"]).toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "₹$displayPrice / day",
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}