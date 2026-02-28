import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "About Us",
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            const Text(
              "FlexRide",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "FlexRide is your premium vehicle rental partner. "
              "We provide top-quality bikes and cars for your daily commute "
              "and weekend trips at affordable rates.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Our mission is to make transportation easy, accessible, "
              "and hassle-free for everyone.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),
            const Divider(color: Colors.grey),
            const SizedBox(height: 20),

            const Text(
              "Terms & Conditions",
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 20),

            _policyBox(
              title: "1. Eligibility Criteria",
              content:
                  "• Age Requirement: Users must be at least 21 years old to book and ride a vehicle.",
            ),

            _policyBox(
              title: "2. Damage Policy",
              content:
                  "• Minor Damages: The user is fully liable to pay repair costs for any minor damages, scratches, or dents incurred during the trip.",
            ),

            _policyBox(
              title: "3. Late Return Policy",
              content:
                  "• Grace Period: A grace period of 30 minutes is allowed.\n"
                  "• Penalty: Returns delayed beyond 30 mins will incur an hourly penalty charge.",
            ),

            _policyBox(
              title: "4. Speed Limit & Safety",
              content:
                  "• Speed Restrictions: Max speed is 80 kmph for Two-Wheelers and 100 kmph for Four-Wheelers for your safety.",
            ),

            _policyBox(
              title: "5. Security Deposit",
              content:
                  "• Refundable Deposit: A security deposit is required during payment.\n"
                  "• Refund: It will be refunded immediately upon safe return of the vehicle.",
            ),

            const SizedBox(height: 30),
            
            const Text(
              "© 2024 FlexRide Inc.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _policyBox({required String title, required String content}) {
    List<String> lines = content.split('\n');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.yellow, 
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          ...lines.map((line) {
            int splitIndex = line.indexOf(":");
            
            if (splitIndex != -1) {
              String label = line.substring(0, splitIndex + 1);
              String value = line.substring(splitIndex + 1);

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, height: 1.4),
                    children: [
                      TextSpan(
                        text: label,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          color: Colors.grey[400], 
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              
              return Text(
                line,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  height: 1.4,
                ),
              );
            }
          }).toList(),
        ],
      ),
    );
  }
}