import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'four_wheeler_data.dart';
import 'vehicle_detail_screen.dart';

class FourWheelersScreen extends StatefulWidget {
  @override
  State<FourWheelersScreen> createState() => _FourWheelersScreenState();
}

class _FourWheelersScreenState extends State<FourWheelersScreen> {
  final supabase = Supabase.instance.client;

  String search = "";
  double min = 0, max = 8000;
  int selectedPrice = 0;
  int? selectedSeat;

  late List<Map<String, dynamic>> shuffledCars;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _shuffleAll();
    _autoUploadVehicles(); 
  }

  Future<void> _autoUploadVehicles() async {
    try {
      final data = await supabase.from('vehicles').select('id').eq('type', 'Car').limit(1);
      
      if (data.isEmpty) {
        print("Uploading Cars to Database...");
        for (var v in fourWheelers) {
          await supabase.from('vehicles').insert({
            'name': v['name'],
            'image': v['image'],
            'price': v['price'],
            'available': true, 
            'type': 'Car',
          });
        }
        if (mounted) setState(() {});
      }
    } catch (e) {
      print("Sync Error: $e");
    }
  }

  void _shuffleAll() {
    shuffledCars = List<Map<String, dynamic>>.from(fourWheelers);
    shuffledCars.shuffle(Random());
  }

  double rating(String name) {
    final r = Random(name.hashCode);
    return 3.8 + r.nextDouble() * 1.1;
  }

  void _resetAll() {
    setState(() {
      search = "";
      selectedPrice = 0;
      selectedSeat = null;
      min = 0;
      max = 8000;
      _searchCtrl.clear();
      _shuffleAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = shuffledCars.where((v) {
      return v["name"].toLowerCase().contains(search.toLowerCase()) &&
          v["price"] >= min &&
          v["price"] <= max &&
          (selectedSeat == null || v["seats"] == selectedSeat);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Four Wheelers",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      body: Column(
        children: [
          _search(),
          _filters(),
          Expanded(
            child: list.isEmpty ? _emptyState() : _list(list),
          ),
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
            hintText: "Search Car",
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _priceBtn(0, "All", 110),
                _priceBtn(1, "Budget", 110),
                _priceBtn(2, "Family", 110),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _priceBtn(3, "Premium", 120),
                const SizedBox(width: 16),
                _priceBtn(4, "Luxury", 120),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _seatBtn(4),
                _seatBtn(5),
                _seatBtn(6),
                _seatBtn(7),
              ],
            ),
          ],
        ),
      );

  Widget _priceBtn(int id, String text, double w) {
    final isSelected = selectedPrice == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (id == 0 || selectedPrice == id) {
            _resetAll();
            return;
          }

          selectedPrice = id;
          if (id == 1) {
            min = 1000;
            max = 2000;
          } else if (id == 2) {
            min = 2001;
            max = 3500;
          } else if (id == 3) {
            min = 3501;
            max = 5500;
          } else if (id == 4) {
            min = 5501;
            max = 8000;
          }
        });
      },
      child: Container(
        width: w,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow : Colors.grey[850],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _seatBtn(int s) {
    final isSelected = selectedSeat == s;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSeat = selectedSeat == s ? null : s;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.yellow : Colors.grey[850],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            "$s Seater",
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car,
                size: 70,
              color: const Color(0xFFFFD54F)              ),
              const SizedBox(height: 16),
              const Text(
                "Vehicle Not Found",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Try Adjusting Search Budget or Seats."
                ,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _resetAll, 
                child: const Text(
                  "View All Vehicles",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _list(List list) => ListView.builder(
        physics: const BouncingScrollPhysics(),
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
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.asset(
                          v["image"],
                          fit: BoxFit.cover,
                        ),
                      ),
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
                      const EdgeInsets.only(left: 12, right: 12, bottom: 14),
                  child: Text(
                    "₹$displayPrice / day",
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
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