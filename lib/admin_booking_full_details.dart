import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'admin_bookings_screen.dart'; 

class AdminBookingFullDetails extends StatefulWidget {
  final String bookingId;
  const AdminBookingFullDetails({super.key, required this.bookingId});

  @override
  State<AdminBookingFullDetails> createState() => _AdminBookingFullDetailsState();
}

class _AdminBookingFullDetailsState extends State<AdminBookingFullDetails> {
  final supabase = Supabase.instance.client;

  
  void _showDocumentsDialog(String? licenseUrl, String? idProofUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            height: 600,
            padding: const EdgeInsets.all(10),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      const Text("User Documents", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const TabBar(
                    indicatorColor: Colors.yellow,
                    labelColor: Colors.yellow,
                    unselectedLabelColor: Colors.white54,
                    tabs: [Tab(icon: Icon(Icons.drive_eta), text: "License"), Tab(icon: Icon(Icons.badge), text: "ID Proof")],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildDocumentViewer(licenseUrl),
                        _buildDocumentViewer(idProofUrl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  
  Widget _buildDocumentViewer(String? url) {
    if (url == null || url.isEmpty) {
      return const Center(child: Text("No Document Uploaded", style: TextStyle(color: Colors.white54)));
    }
    bool isPdf = url.toLowerCase().contains('.pdf');

    if (isPdf) {
      return const PDF(
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
      ).fromUrl(
        url,
        placeholder: (progress) => Center(child: CircularProgressIndicator(value: progress / 100, color: Colors.yellow)),
        errorWidget: (error) => const Center(child: Text("Error loading PDF", style: TextStyle(color: Colors.white))),
      );
    } else {
      return InteractiveViewer(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (c, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          },
          errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.red, size: 40)),
        ),
      );
    }
  }

  void _showRejectDialog(String bId) {
    String selectedReason = "Invalid License";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Reject Booking", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select a reason for rejection:", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 10),
              ...["Invalid License", "Invalid ID Proof", "Age Limit Issue", "Vehicle Unavailable", "Other"].map((r) => RadioListTile<String>(
                title: Text(r, style: const TextStyle(color: Colors.white)),
                value: r, groupValue: selectedReason, activeColor: Colors.red,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setDialogState(() => selectedReason = val!),
              )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("BACK", style: TextStyle(color: Colors.white))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
               
                await supabase.from('bookings').update({
                  'status': 'Cancelled', 
                  'cancel_reason': 'Rejected by Admin: $selectedReason'
                }).eq('id', bId);
                
                if(mounted) {
                 
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminBookingsScreen()),
                    (route) => false,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Rejected Successfully")));
                }
              },
              child: const Text("CONFIRM REJECT", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Booking Details", style: TextStyle(color: Colors.white))),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('bookings').stream(primaryKey: ['id']).eq('id', widget.bookingId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: CircularProgressIndicator(color: Colors.yellow));
          final data = snapshot.data![0];
          String status = data['status'] ?? "Upcoming";
          String displayId = data['booking_id'] ?? data['id'].toString();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(20), child: Container(height: 200, width: double.infinity, color: Colors.grey[900], child: _buildFullImage(data['vehicle_image'] ?? ""))),
                const SizedBox(height: 15),
                Text(data['vehicle_name'] ?? "Vehicle", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),

                _infoBox("USER INFORMATION", [
                  _row("Customer Name", data['user_name'] ?? "N/A"),
                  _row("Email Address", data['user_email'] ?? "N/A"),
                  _row("Phone Number", data['user_phone'] ?? "N/A"),
                ]),
                const SizedBox(height: 15),
                _infoBox("BOOKING INFORMATION", [
                  _row("Booking ID", "#$displayId", vColor: Colors.white, isBold: true),
                  _row("Pickup Date", data['pickup_date'] ?? "N/A"),
                  _row("Return Date", data['return_date'] ?? "N/A"),
                  _row("Total Days", "${data['total_days'] ?? 0} Days"),
                  _row("Purpose", data['trip_purpose'] ?? "N/A"),
                  _row("Status", status.toUpperCase(), vColor: status == "Cancelled" ? Colors.red : Colors.green),
                  if (status == "Cancelled") _row("Reason", data['cancel_reason'] ?? "N/A", vColor: Colors.redAccent),
                ]),
                
                const SizedBox(height: 15),
                _infoBox("PAYMENT DETAILS", [
                  _row("Transaction ID", data['transaction_id'] ?? "N/A"),
                  _row("Total Paid", "₹${data['total_amount'] ?? 0}", vColor: Colors.yellow, isBold: true),
                ]),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () => _showDocumentsDialog(data['license_url'], data['id_proof_url']), 
                    child: const Text("VIEW UPLOADED DOCUMENTS", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 13)), 
                  ),
                ),
                const SizedBox(height: 20),

                if (status != "Cancelled")
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () => _showRejectDialog(data['id'].toString()),
                      child: const Text("REJECT BOOKING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullImage(String path) {
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.contain);
    return Image.asset(path, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50));
  }

  Widget _infoBox(String t, List<Widget> c) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(color: Colors.yellow, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15), ...c
      ]),
    );
  }

  Widget _row(String l, String v, {Color vColor = Colors.white, bool isBold = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: Colors.white60, fontSize: 14)),
      Text(v, style: TextStyle(color: vColor, fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    ]));
  }
}