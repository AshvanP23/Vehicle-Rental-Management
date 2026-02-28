import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:file_picker/file_picker.dart';
import 'payment_success_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> saveBooking({
    required String bookingId,
    required String transactionId,
    required Map vehicle,
    required DateTime fromDate,
    required DateTime toDate,
    required int totalDays,
    required int rentAmount,
    required int depositAmount,
    required int totalAmount,
    required PlatformFile licenseFile,
    required PlatformFile idFile,
    required String tripPurpose,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User not logged in";

      String fFrom = "${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}";
      String fTo = "${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}";

      String licenseUrl = await _uploadToSupabase(licenseFile, "license_$bookingId");
      String idUrl = await _uploadToSupabase(idFile, "id_$bookingId");

      final bookingData = {
        'booking_id': bookingId,
        'transaction_id': transactionId,
        'user_id': user.uid,
        'user_name': userName,
        'user_email': userEmail,
        'user_phone': userPhone,
        'vehicle_name': vehicle['name'],
        'vehicle_image': vehicle['image'],
        'pickup_date': fFrom,
        'return_date': fTo,
        'total_days': totalDays,
        'rent_amount': rentAmount,
        'deposit_amount': depositAmount,
        'total_amount': totalAmount,
        'trip_purpose': tripPurpose,
        'license_url': licenseUrl,
        'id_proof_url': idUrl,
        'status': 'Upcoming',
      };

      await _supabase.from('bookings').insert(bookingData);
      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> _uploadToSupabase(PlatformFile file, String fileName) async {
    final fileExt = file.extension ?? 'jpg';
    final path = '$fileName.$fileExt';
    final fileToUpload = File(file.path!);

    await _supabase.storage.from('documents').upload(path, fileToUpload);
    return _supabase.storage.from('documents').getPublicUrl(path);
  }
}

class UpiPinScreen extends StatefulWidget {
  final String appName;
  final int rentAmount;
  final int depositAmount;
  final int totalAmount;
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

  const UpiPinScreen({
    super.key,
    required this.appName,
    required this.rentAmount,
    required this.depositAmount,
    required this.totalAmount,
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
  State<UpiPinScreen> createState() => _UpiPinScreenState();
}

class _UpiPinScreenState extends State<UpiPinScreen> {
  final AuthService _authService = AuthService(); 
  String pin = "";
  bool isLoading = false;
  String? pinError; 

  void _onKeyPressed(String value) {
    if (pin.length < 4) setState(() { pin += value; pinError = null; });
  }

  void _onBackspace() {
    if (pin.isNotEmpty) setState(() { pin = pin.substring(0, pin.length - 1); pinError = null; });
  }

  Future<void> _onSubmit() async {
    if (pin.length < 4) {
      setState(() => pinError = "Enter your four digits PIN");
      return;
    }
    setState(() => isLoading = true);

    final String bId = "BK${(100000 + Random().nextInt(900000))}";
    final String tId = "TXN${(1000000000 + Random().nextInt(900000000))}";

    
    _authService.saveBooking(
      bookingId: bId,
      transactionId: tId,
      vehicle: widget.vehicle,
      fromDate: widget.fromDate,
      toDate: widget.toDate,
      totalDays: widget.totalDays,
      rentAmount: widget.rentAmount,
      depositAmount: widget.depositAmount,
      totalAmount: widget.totalAmount,
      licenseFile: widget.licenseFile,
      idFile: widget.idFile,
      tripPurpose: widget.tripPurpose,
      userName: widget.userName,
      userEmail: widget.userEmail,
      userPhone: widget.userPhone,
    ).then((_) {
      print("Background Save Completed for $bId");
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          amount: widget.totalAmount,
          bookingId: bId,
          transactionId: tId,
        ),
      ),
    );
  }

  void _onCancelPressed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Cancel Payment?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NO", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, 
            child: const Text("YES", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
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
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: _onCancelPressed),
        title: Text(widget.appName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 75, height: 75,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: ClipOval(
                      child: Image.asset(
                        widget.appName == "Google Pay" ? "assets/payment_icons/gpay.png" : 
                        widget.appName == "PhonePe" ? "assets/payment_icons/phonepe.png" : "assets/payment_icons/paytm.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text("ENTER YOUR UPI PIN", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    bool isFilled = pin.length > index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 16, height: 16,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: isFilled ? Colors.white : Colors.white12, border: Border.all(color: Colors.white24, width: 1.5)),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                if (pinError != null)
                  Text(pinError!, style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                  color: Colors.white.withOpacity(0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("PAYING TO", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("FLEXRIDE RENTALS", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text("AMOUNT", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("₹${widget.totalAmount}", style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  color: Colors.white.withOpacity(0.05),
                  child: Column(
                    children: [
                      _buildNumberRow(["1", "2", "3"]),
                      _buildNumberRow(["4", "5", "6"]),
                      _buildNumberRow(["7", "8", "9"]),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildKey("BACK", icon: Icons.backspace_outlined),
                            _buildKey("0"),
                            _buildKey("OK", icon: Icons.check_circle, isAction: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: SizedBox(
                    width: double.infinity, height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent, width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _onCancelPressed,
                      child: const Text("CANCEL PAYMENT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNumberRow(List<String> keys) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: keys.map((key) => _buildKey(key)).toList()));
  Widget _buildKey(String value, {IconData? icon, bool isAction = false}) {
    return InkWell(
      onTap: () { if (value == "BACK") _onBackspace(); else if (value == "OK") _onSubmit(); else _onKeyPressed(value); },
      borderRadius: BorderRadius.circular(40),
      child: Container(width: 80, height: 60, alignment: Alignment.center, child: icon != null ? Icon(icon, color: isAction ? Colors.greenAccent : Colors.white, size: 32) : Text(value, style: const TextStyle(color: Colors.white, fontSize: 26))),
    );
  }
}