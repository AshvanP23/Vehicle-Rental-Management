import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flexride_new/services/auth_service.dart';
import 'payment_screen.dart'; 

class BookingSummaryScreen extends StatefulWidget {
  final Map vehicle;
  final DateTime fromDate;
  final DateTime toDate;
  final int totalDays;
  final int totalAmount;

  const BookingSummaryScreen({
    super.key,
    required this.vehicle,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.totalAmount,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final AuthService _authService = AuthService();

  String userName = "Loading...";
  String userPhone = "Loading...";
  String userEmail = "Loading...";

  String? tripPurpose;
  PlatformFile? licenseFile;
  PlatformFile? idFile;

  bool showTripError = false;
  bool showDocError = false;
  bool showPolicyError = false;

  bool isPolicy1Checked = false;
  bool isPolicy2Checked = false;

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    var data = await _authService.getUserDetails();
    if (data != null && mounted) {
      setState(() {
        userName = data['name'] ?? "User";
        userPhone = data['phone'] ?? "";
        userEmail = data['email'] ?? "";
      });
    }
  }

  Future<void> pickFile(bool isLicense) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (isLicense) {
          licenseFile = result.files.first;
        } else {
          idFile = result.files.first;
        }
      });
    }
  }

  void continuePayment() {
    setState(() {
      showTripError = tripPurpose == null;
      showDocError = licenseFile == null || idFile == null;
      showPolicyError = !isPolicy1Checked || !isPolicy2Checked;
    });

    if (!showTripError && !showDocError && !showPolicyError) {
      int pricePerDay = int.parse(widget.vehicle['price'].toString());
      bool isFourWheeler = pricePerDay > 1500; 

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            rentAmount: widget.totalAmount, 
            isCar: isFourWheeler,
            vehicle: widget.vehicle,
            fromDate: widget.fromDate,
            toDate: widget.toDate,
            totalDays: widget.totalDays,
            licenseFile: licenseFile!,
            idFile: idFile!,
            tripPurpose: tripPurpose!,
            userName: userName,
            userEmail: userEmail,
            userPhone: userPhone,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Booking Summary",
          style: TextStyle(color: Colors.yellow, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _section("User Details", [
              _line("Name", userName),
              _line("Phone", userPhone),
              _line("Email", userEmail),
            ]),
            _section("Vehicle Details", [
              _line("Vehicle", widget.vehicle["name"]),
              _line("Price / Day", "₹${widget.vehicle["price"]}"),
              _line("Pickup", "Chennai"),
            ]),
            _section("Booking Details", [
              _line("From", _fmt(widget.fromDate)),
              _line("To", _fmt(widget.toDate)),
              _line("Days", "${widget.totalDays}"),
              _line("Amount", "₹${widget.totalAmount}"),
            ]),
            _sectionWidget(
              "Documents",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _uploadBox("Upload Driving License", licenseFile, () => pickFile(true)),
                  const SizedBox(height: 8),
                  _uploadBox("Upload Aadhaar / PAN", idFile, () => pickFile(false)),
                  if (showDocError)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text("Please upload required documents", style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
            ),
            _sectionWidget(
              "Trip Info",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      value: tripPurpose,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: Colors.grey[900],
                      iconEnabledColor: Colors.white,
                      hint: const Text("Select Trip Purpose", style: TextStyle(color: Colors.white54, fontSize: 14)),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: "Trip", child: Text("Trip")),
                        DropdownMenuItem(value: "Office", child: Text("Office")),
                        DropdownMenuItem(value: "Family", child: Text("Family")),
                        DropdownMenuItem(value: "Personal", child: Text("Personal")),
                      ],
                      onChanged: (v) {
                        setState(() {
                          tripPurpose = v;
                          showTripError = false;
                        });
                      },
                    ),
                  ),
                  if (showTripError)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text("Please select trip purpose", style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Policies", style: TextStyle(color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _policyCheckbox(
                    "I agree to the Terms & Conditions and Damage Policy.",
                    isPolicy1Checked,
                    (v) => setState(() { isPolicy1Checked = v ?? false; showPolicyError = false; }),
                  ),
                  _policyCheckbox(
                    "I confirm that I possess a valid Original Driving License.",
                    isPolicy2Checked,
                    (v) => setState(() { isPolicy2Checked = v ?? false; showPolicyError = false; }),
                  ),
                  if (showPolicyError)
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 10),
                      child: Text("Please accept both policies to proceed", style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: continuePayment,
                child: const Text("CONTINUE TO PAYMENT", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _policyCheckbox(String text, bool val, Function(bool?) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24, height: 24,
          child: Checkbox(value: val, onChanged: onChanged, activeColor: Colors.yellow, checkColor: Colors.black, side: const BorderSide(color: Colors.white54, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4))),
      ],
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$k : ", style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(v, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 6), ...rows]),
    );
  }

  Widget _sectionWidget(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.yellow, fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 6), child]),
    );
  }

  Widget _uploadBox(String label, PlatformFile? file, VoidCallback onTap) {
    bool isUploaded = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey)),
        child: Center(
          child: isUploaded
              ? RichText(textAlign: TextAlign.center, text: TextSpan(style: const TextStyle(fontSize: 14), children: [const TextSpan(text: "Uploaded: ", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), TextSpan(text: file.name, style: const TextStyle(color: Colors.white))]))
              : Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}