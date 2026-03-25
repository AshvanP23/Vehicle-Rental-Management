import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "FAQ",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            _faqItem(
              "Is FlexRide available for bikes and cars?",
              "Yes, FlexRide supports both two wheelers and four wheelers.",
            ),

            _faqItem(
              "How do I book a vehicle?",
              "Choose a vehicle category, select a vehicle, pick dates and confirm your booking.",
            ),

            _faqItem(
              "What documents are required?",
              "A valid driving license and a government-issued ID proof are required at pickup.",
            ),

            _faqItem(
              "Do I need to refuel the vehicle?",
              "Yes. Please return the vehicle with the same fuel level as provided during pickup to avoid extra charges.",
            ),

            _faqItem(
              "Can I cancel my booking?",
              "Yes, bookings can be cancelled before the pickup time as per cancellation policy.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
