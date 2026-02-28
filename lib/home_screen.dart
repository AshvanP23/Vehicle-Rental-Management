import 'package:flutter/material.dart';
import 'package:flexride_new/services/auth_service.dart';
import 'two_wheeler_screen.dart';
import 'four_wheeler_screen.dart';
import 'my_bookings_screen.dart';
import 'faq_screen.dart';
import 'contact_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    var data = await _authService.getUserDetails();
    if (data != null && mounted) {
      setState(() {
        userName = data['name'] ?? "User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            "FlexRide",
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.yellow, size: 20),
                  SizedBox(width: 6),
                  Text("Chennai", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 6),
                  Text("· Pickup Only", style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),

              const SizedBox(height: 29),

              Text(
                "Welcome, $userName",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 38),

              const Text(
                "Select Your Vehicle",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 20),

              _vehicleBox(
                icon: Icons.two_wheeler,
                title: "Two Wheeler",
                subtitle: "Bikes & Scooters",
                page: TwoWheelersScreen(),
              ),

              const SizedBox(height: 16),

              _vehicleBox(
                icon: Icons.directions_car,
                title: "Four Wheeler",
                subtitle: "Cars & SUVs",
                page: FourWheelersScreen(),
              ),

              const Spacer(), 

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5, 
                children: [
                  _homeGridBox("My Bookings", Icons.calendar_month, Colors.blue, "View Bookings", MyBookingsScreen()),
                  _homeGridBox("FAQ", Icons.help_outline, Colors.orange, "Common Queries", FAQScreen()),
                  _homeGridBox("Contact", Icons.phone, Colors.green, "Send Queries & Feedback", ContactScreen()),
                  _homeGridBox("About", Icons.info_outline, Colors.purple, "App Info", AboutScreen()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vehicleBox({required IconData icon, required String title, required String subtitle, required Widget page}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20), 
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.yellow, size: 36), 
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), 
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _homeGridBox(String title, IconData icon, Color color, String subtitle, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20, 
              backgroundColor: color.withOpacity(0.15), 
              child: Icon(icon, color: color, size: 20)
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}