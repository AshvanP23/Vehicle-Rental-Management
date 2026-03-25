import 'package:flutter/material.dart';
import 'user_login_screen.dart';
import 'admin_vehicle_type_screen.dart';
import 'admin_bookings_screen.dart';
import 'admin_users_screen.dart';
import 'admin_queries_screen.dart';

class AdminHomeScreen extends StatefulWidget {
const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to logout?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NO", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const UserLoginScreen()), (route) => false);
            },
            child: const Text("YES", style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text("FlexRide", style: TextStyle(color: Colors.yellow, fontSize: 26, fontWeight: FontWeight.w800)),
          actions: [
            IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
          ],
        ),
        body: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                const SizedBox(height: 42), 

                const Center(
                  child: Text(
                    "Admin Panel",
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(height: 30), 
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1, 
                  children: [
                    _adminGridBox(title: "Vehicles", icon: Icons.directions_car, subtitle: "Manage Vehicles & Pricing", page: const AdminVehicleTypeScreen(), color: Colors.blue),
                    _adminGridBox(title: "Bookings", icon: Icons.calendar_today, subtitle: "Manage Bookings", page: const AdminBookingsScreen(), color: Colors.orange),
                    _adminGridBox(title: "Users", icon: Icons.people_alt, subtitle: "User Information", page: const AdminUsersScreen(), color: Colors.green),
                    _adminGridBox(title: "Messages", icon: Icons.chat_bubble, subtitle: "User Queries & Feedback", page: const AdminQueriesScreen(), color: Colors.purple),
                  ],
                ),
                
                const SizedBox(height: 30), 
                
                const Text(
                  "Booking Analysis",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _salesProgressBar("Two-Wheelers", " (Bikes/Scooters)", 0.64, Colors.yellow),
                _salesProgressBar("Four-Wheelers", " (Cars/SUVs)", 0.78, Colors.blue),
                
                const SizedBox(height: 15),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 28),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Weekly Growth", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            Text("Sales increased by 12% this week", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Text("+12%", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 30), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _salesProgressBar(String title, String details, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    TextSpan(
                      text: details,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text("${(percentage * 100).toInt()}%", style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[850],
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminGridBox({required String title, required IconData icon, required String subtitle, required Widget page, required Color color}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 25, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 25)),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}