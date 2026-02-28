import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'upi_pin_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int rentAmount;
  final bool isCar;
  final Map vehicle;
  final DateTime fromDate;
  final DateTime toDate;
  final int totalDays;
  final PlatformFile licenseFile;
  final PlatformFile idFile;
  final String tripPurpose;

  final String userName;
  final String userEmail;
  final String userPhone;

  const PaymentScreen({
    super.key, 
    required this.rentAmount, 
    required this.isCar,
    required this.vehicle,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.licenseFile,
    required this.idFile,
    required this.tripPurpose,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedApp;

  int get depositAmount => widget.isCar ? 3000 : 1500;
  int get totalPayable => widget.rentAmount + depositAmount;

  final List<Map<String, String>> paymentOptions = [
    {"name": "Google Pay", "imagePath": "assets/payment_icons/gpay.png"},
    {"name": "PhonePe", "imagePath": "assets/payment_icons/phonepe.png"},
    {"name": "Paytm", "imagePath": "assets/payment_icons/paytm.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bill Details", style: TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _billRow("Rental Charges", "₹${widget.rentAmount}"),
                  const SizedBox(height: 10),
                  
                  _billRow("Caution Deposit (Refundable)", "₹$depositAmount", isGreen: true),
                  
                  const Divider(color: Colors.grey),
                  _billRow("Total Payable", "₹$totalPayable", isBold: true, size: 20),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
             ...paymentOptions.map((option) {
              return _paymentOption(option["name"]!, option["imagePath"]!);
            }),
            
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selectedApp == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpiPinScreen(
                              appName: selectedApp!,
                              rentAmount: widget.rentAmount,
                              depositAmount: depositAmount,
                              totalAmount: totalPayable,
                              vehicle: widget.vehicle,
                              fromDate: widget.fromDate,
                              toDate: widget.toDate,
                              totalDays: widget.totalDays,
                              licenseFile: widget.licenseFile,
                              idFile: widget.idFile,
                              tripPurpose: widget.tripPurpose,
                              userName: widget.userName,
                              userEmail: widget.userEmail,
                              userPhone: widget.userPhone,
                            ),
                          ),
                        );
                      },
                child: Text("PAY ₹$totalPayable", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _billRow(String label, String value, {bool isBold = false, bool isGreen = false, double size = 15}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: TextStyle(color: isGreen ? Colors.greenAccent : (isBold ? Colors.yellow : Colors.white), fontSize: size, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }

  Widget _paymentOption(String name, String imagePath) {
    bool isSelected = selectedApp == name;
    return GestureDetector(
      onTap: () => setState(() => selectedApp = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(color: Colors.grey[900], border: Border.all(color: isSelected ? Colors.yellow : Colors.transparent, width: 2), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
            Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: ClipOval(child: Image.asset(imagePath, width: 36, height: 36, fit: BoxFit.cover))),
            const SizedBox(width: 20),
            Text(name, style: TextStyle(color: isSelected ? Colors.yellow : Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.yellow : Colors.grey),
        ]),
      ),
    );
  }
}