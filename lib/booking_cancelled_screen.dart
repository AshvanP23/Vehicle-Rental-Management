import 'package:flutter/material.dart';
import 'home_screen.dart';

class BookingCancelledScreen extends StatelessWidget {
  final String reason;

  const BookingCancelledScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 3),
              ),
              child: const Icon(Icons.check, color: Colors.red, size: 60),
            ),
            const SizedBox(height: 30),

            const Text(
              "Booking Cancelled",
              style: TextStyle(color: Colors.red, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 16),
                children: [
                  const TextSpan(
                    text: "Reason: ",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: reason,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24)
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.yellow, size: 32),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Refund Initiated", 
                          style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Amount will be refunded within 5-7 business days.",
                          style: TextStyle(color: Color.fromARGB(179, 243, 241, 241), fontSize: 14), 
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow, 
                  foregroundColor: Colors.black, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                ),
                onPressed: () {
                   Navigator.pushAndRemoveUntil(
                     context,
                     MaterialPageRoute(builder: (_) => const HomeScreen()),
                     (route) => false,
                   );
                },
                child: const Text("GO TO HOME", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}