import 'package:flutter/material.dart';
import 'package:flexride_new/services/auth_service.dart';
import 'user_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); 
  }

  void _fetchData() async {
    var data = await _authService.getUserDetails();
    if (data != null && mounted) {
      setState(() {
        _nameController.text = data['name'] ?? "";
        _emailController.text = data['email'] ?? "";
        _phoneController.text = data['phone'] ?? "";
        _isLoading = false;
      });
    } else {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UserLoginScreen()),
        (route) => false,
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900], 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Logout", 
          style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)
        ),
        content: const Text(
          "Are you sure you want to logout?", 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); 
              _logout(); 
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "FlexRide",
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  const Text(
                    "Rent. Ride. Repeat.",
                    style: TextStyle(
                      color: Color.fromARGB(242, 255, 255, 255),
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 60),

                  _field(
                    icon: Icons.person_outline,
                    hint: "Name",
                    controller: _nameController,
                  ),

                  const SizedBox(height: 16),

                  _field(
                    icon: Icons.phone_outlined,
                    hint: "Phone Number",
                    controller: _phoneController,
                  ),

                  const SizedBox(height: 16),

                  _field(
                    icon: Icons.email_outlined,
                    hint: "Email",
                    controller: _emailController,
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _showLogoutDialog, 
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _field({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.yellow),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}