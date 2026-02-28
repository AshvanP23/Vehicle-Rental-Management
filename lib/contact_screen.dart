import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _controller = TextEditingController();
  bool showBox = false;
  String message = "";

  Future<void> _send() async {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        message = "Please enter your message";
      });
      return;
    }

    setState(() {
      message = "Sending...";
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final String userEmail = user?.email ?? "Guest";
      final String userName = user?.displayName ?? "Unknown";

      await Supabase.instance.client.from('user_queries').insert({
        'user_name': userName,
        'user_email': userEmail,
        'message': _controller.text.trim(),
      });

      if (!mounted) return;

      setState(() {
        message = "Message sent to FlexRide";
        _controller.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        message = "Please check connection or RLS settings"; 
        debugPrint("Error: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Contact Us",
          style: TextStyle(color: Colors.yellow),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Phone", "+91 94666 94666"),
            _info("Email", "flexride@gmail.com"),
            _info("Address", "T.Nagar, Chennai, Tamil Nadu"),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                setState(() {
                  showBox = !showBox;
                  message = "";
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Send Queries / Feedback",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            if (showBox) ...[
              const SizedBox(height: 16),

              TextField(
                controller: _controller,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type your message here",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: message.startsWith("Please")
                            ? Colors.red
                            : Colors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        foregroundColor: Colors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _send,
                      child: const Text(
                        "SEND",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.yellow),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}