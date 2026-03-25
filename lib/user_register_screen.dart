import 'package:flutter/material.dart';
import 'package:flexride_new/services/auth_service.dart';
import 'user_login_screen.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
   
  final AuthService _authService = AuthService();

  String _errorMessage = "";
  bool _isLoading = false;

  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;

  void _register() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = "Please fill all the fields");
      return;
    }

    if (!email.endsWith(".com") || !email.contains("@")) {
      setState(() => _errorMessage = "Email must be valid and end with .com");
      return;
    }

    if (phone.length != 10) {
      setState(() => _errorMessage = "Phone number must be 10 digits");
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final String? error = await _authService.registerUser(
        email: email, 
        password: password, 
        name: name, 
        phone: phone
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account Created Successfully!", style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.yellow,
          ),
        );
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const UserLoginScreen())
        );
      } else {
        setState(() => _errorMessage = error);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Something went wrong. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Register", style: TextStyle(color: Colors.yellow, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const Text("FlexRide", style: TextStyle(color: Colors.yellow, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              _field(hint: "Name", icon: Icons.person_outline, controller: _nameController),
              const SizedBox(height: 16),
              _field(hint: "Phone", icon: Icons.phone_outlined, controller: _phoneController, isNumber: true, maxLength: 10),
              const SizedBox(height: 16),
              _field(hint: "Email", icon: Icons.email_outlined, controller: _emailController),
              const SizedBox(height: 16),
              _passwordField(hint: "Password", controller: _passwordController, isObscure: _isPasswordObscure, onToggle: () => setState(() => _isPasswordObscure = !_isPasswordObscure)),
              const SizedBox(height: 16),
              _passwordField(hint: "Confirm Password", controller: _confirmPasswordController, isObscure: _isConfirmObscure, onToggle: () => setState(() => _isConfirmObscure = !_isConfirmObscure)),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required String hint, required IconData icon, required TextEditingController controller, bool isNumber = false, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(counterText: "", prefixIcon: Icon(icon, color: Colors.yellow), hintText: hint, hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    );
  }

  Widget _passwordField({required String hint, required TextEditingController controller, required bool isObscure, required VoidCallback onToggle}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline, color: Colors.yellow), suffixIcon: IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54), onPressed: onToggle), hintText: hint, hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    );
  }
}