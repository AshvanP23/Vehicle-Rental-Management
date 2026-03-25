import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'booking_page.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Map v;

  const VehicleDetailScreen({super.key, required this.v});

  double getRating(String name) {
    final r = Random(name.hashCode);
    return 3.8 + r.nextDouble() * 1.1;
  }

  int getDistance(String name) {
    final r = Random(name.hashCode + 77);
    final int steps = 10 + r.nextInt(90);
    return steps * 100;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('vehicles')
          .stream(primaryKey: ['id'])
          .eq('name', v['name']),
      builder: (context, snapshot) {

        bool isAvailable = v['available'] ?? true;
        int price = v['price'];

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          isAvailable = snapshot.data![0]['available'] ?? true;
          price = snapshot.data![0]['price'] ?? price;
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              v["name"],
              style: const TextStyle(color: Colors.yellow),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.black,
                      child: Image.asset(
                        v["image"],
                        fit: BoxFit.contain,
                      ),
                    ),

                    if (!isAvailable)
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "UNAVAILABLE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              v["name"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            getRating(v["name"])
                                .toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹$price / day",
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      _row("Type", v["type"] ?? "Vehicle"),
                      _row("Fuel", v["fuel"] ?? "Petrol"),
                      _row("Seats",
                          (v["seats"] ?? 2).toString()),
                      _row("Distance",
                          "${getDistance(v["name"])} km Driven"),

                      const SizedBox(height: 16),

                      const Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        v["description"] ??
                            "No description available.",
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (v["features"] != null) ...[
                        const Text(
                          "Features",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            v["features"].length,
                            (i) => Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        Colors.grey[700]!),
                              ),
                              child: Text(
                                v["features"][i],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? Colors.yellow
                                : Colors.grey[800],
                            foregroundColor: isAvailable
                                ? Colors.black
                                : Colors.white38,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),
                          onPressed: isAvailable
                              ? () {
                                  v['price'] = price;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookingPage(
                                              vehicle: v),
                                    ),
                                  );
                                }
                              : null,
                          child: Text(
                            isAvailable
                                ? "BOOK NOW"
                                : "CURRENTLY UNAVAILABLE",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String t, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$t: ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            v,
            style:
                const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
