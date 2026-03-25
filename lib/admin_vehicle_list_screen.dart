import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_vehicle_edit_screen.dart';

class AdminVehicleListScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> vehicles;

  const AdminVehicleListScreen({
    super.key,
    required this.title,
    required this.vehicles,
  });

  @override
  State<AdminVehicleListScreen> createState() => _AdminVehicleListScreenState();
}

class _AdminVehicleListScreenState extends State<AdminVehicleListScreen> {
  late List<Map<String, dynamic>> filteredVehicles;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    filteredVehicles = widget.vehicles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search vehicle",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                setState(() {
                  filteredVehicles = widget.vehicles
                      .where((v) => v['name'].toString().toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredVehicles.isEmpty
                ? const Center(child: Text("No vehicles found", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final localVehicle = filteredVehicles[index];

                      return StreamBuilder<List<Map<String, dynamic>>>(
                        stream: supabase.from('vehicles').stream(primaryKey: ['id']).eq('name', localVehicle['name']),
                        builder: (context, snapshot) {
                          bool isAvailable = localVehicle['available'] ?? true;
                          int price = localVehicle['price'];

                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            final dbData = snapshot.data![0];
                            isAvailable = dbData['available'] ?? true;
                            price = dbData['price'] ?? price;
                            localVehicle['price'] = price;
                            localVehicle['available'] = isAvailable;
                          }

                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AdminVehicleEditScreen(vehicle: localVehicle)),
                              );
                              if (mounted) setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(14)),
                              child: Row(
                                children: [
                                  Container(
                                    width: 90, height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black,
                                      image: DecorationImage(image: AssetImage(localVehicle['image']), fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(localVehicle['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text("₹$price / day", style: const TextStyle(color: Colors.yellow, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isAvailable ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isAvailable ? "Available" : "Unavailable",
                                      style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}