import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_details_screen.dart'; 

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("My Bookings", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('bookings')
            .stream(primaryKey: ['id']) 
            .eq('user_id', user?.uid ?? '') 
            .order('id', ascending: false), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No bookings yet!", style: TextStyle(color: Colors.white54)));
          }

          final bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _bookingCard(context, bookings[index]);
            },
          );
        },
      ),
    );
  }

  Widget _bookingCard(BuildContext context, Map<String, dynamic> data) {
    String status = data['status'] ?? 'Upcoming';
    String vehicleImage = data['vehicle_image'] ?? ""; 
    String vehicleName = data['vehicle_name'] ?? "Vehicle";
    
    String dateStr = data['pickup_date'] ?? "N/A";
    
    String totalAmount = data['total_amount'].toString();
    String bookingId = data['id'].toString();
    String displayId = data['booking_id'] ?? "#$bookingId";
    
    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20), 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900], 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey[800]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayId, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(6), 
                  border: Border.all(color: statusColor)
                ),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100, height: 80, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), 
                  color: Colors.grey[800],
                ),
                clipBehavior: Clip.hardEdge,
                child: _buildImage(vehicleImage), 
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(vehicleName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("Date: $dateStr", style: const TextStyle(color: Colors.white70, fontSize: 13)), 
                    const SizedBox(height: 6),
                    Text("Total: ₹$totalAmount", style: const TextStyle(color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold)),
                    
                    if (status == "Cancelled") ...[
                      const SizedBox(height: 6),
                      Text(
                        data['cancel_reason'] ?? "Cancelled", 
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500),
                        maxLines: 1, overflow: TextOverflow.ellipsis
                      ),
                    ]
                  ]
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800], 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => BookingDetailsScreen(bookingId: bookingId))
                );
              },
              child: const Text("VIEW DETAILS", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 13)), 
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return const Icon(Icons.car_rental, color: Colors.white54, size: 40);
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.white24));
    return Image.asset(path, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported, color: Colors.white24));
  }

  Color _getStatusColor(String status) {
    if (status == "Completed") return Colors.green;
    if (status == "Upcoming") return Colors.blueAccent;
    if (status == "Cancelled") return Colors.red;
    return Colors.orange; 
  }
}