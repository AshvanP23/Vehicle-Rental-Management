import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_booking_full_details.dart';
import 'admin_home_screen.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const AdminHomeScreen())
              );
            }
          },
        ),
        title: const Text("User Bookings", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('bookings').stream(primaryKey: ['id']).order('id', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          
          final bookings = snapshot.data!;
          
          if (bookings.isEmpty) {
            return const Center(child: Text("No Bookings Yet", style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index];
              return _buildAdminCard(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> data) {
    String status = data['status'] ?? 'Upcoming';
    String userName = data['user_name'] ?? "User";
    String bookingId = data['booking_id'] ?? data['id'].toString();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.yellow, size: 16),
                  const SizedBox(width: 6),
                  Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),

              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "BID: ",
                      style: TextStyle(color: Colors.yellow, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "#$bookingId",
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 90, height: 65,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImage(data['vehicle_image'] ?? ""),
                ),
              ),
              const SizedBox(width: 15),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['vehicle_name'] ?? "Vehicle", 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total: ₹${data['total_amount'] ?? "0"}", 
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white12, thickness: 1),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _getStatusColor(status), width: 1)
                ),
                child: Text(
                  status.toUpperCase(), 
                  style: TextStyle(color: _getStatusColor(status), fontSize: 11, fontWeight: FontWeight.bold)
                ),
              ),
              SizedBox(
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminBookingFullDetails(bookingId: data['id'].toString()))),
                  child: const Text("VIEW DETAILS", style: TextStyle(color: Colors.yellow, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == "Completed") return Colors.green;
    if (status == "Cancelled") return Colors.red;
    return Colors.blueAccent;
  }

  Widget _buildImage(String path) {
    if (path.isEmpty) return const Center(child: Icon(Icons.car_rental, color: Colors.white24));
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.contain);
    return Image.asset(path, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24));
  }
}