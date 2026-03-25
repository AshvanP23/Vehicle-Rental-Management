import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'booking_cancelled_screen.dart'; 

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId; 

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final supabase = Supabase.instance.client;

  final List<String> _cancelReasons = [
    "Change of plans",
    "Found a better deal",
    "Trip cancelled",
    "Other reasons"
  ];

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
                      const Text("Uploaded Documents", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const TabBar(
                    indicatorColor: Colors.yellow,
                    labelColor: Colors.yellow,
                    unselectedLabelColor: Colors.white54,
                    tabs: [
                      Tab(icon: Icon(Icons.drive_eta), text: "License"),
                      Tab(icon: Icon(Icons.badge), text: "ID Proof"),
                    ],
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
        errorWidget: (error) => Center(child: Text("Error loading PDF", style: TextStyle(color: Colors.white))),
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

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempReason = _cancelReasons[0]; 
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Cancel Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Please select a reason:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 15),
                  ..._cancelReasons.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(color: Colors.white)),
                      value: reason,
                      groupValue: tempReason,
                      activeColor: Colors.red,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => tempReason = val);
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back", style: TextStyle(color: Colors.white54))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.pop(context); 
                    _cancelBooking(tempReason!);
                  },
                  child: const Text("Confirm Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _cancelBooking(String reason) async {
    try {
      await supabase.from('bookings').update({
        'status': 'Cancelled',
        'cancel_reason': "User: $reason", 
      }).eq('id', widget.bookingId); 

      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BookingCancelledScreen(reason: reason)),
      );

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white), title: const Text("Booking Details", style: TextStyle(color: Colors.white)), centerTitle: true),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('bookings').stream(primaryKey: ['id']).eq('id', widget.bookingId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: CircularProgressIndicator(color: Colors.yellow));

          final data = snapshot.data![0]; 
          String status = data['status'] ?? 'Upcoming';
          String bookingIdDisplay = data['booking_id'] ?? data['id'].toString();
          String vehicleImage = data['vehicle_image'] ?? ""; 
          String vehicleName = data['vehicle_name'] ?? "Vehicle";
          String pickupDate = data['pickup_date'] ?? "N/A";
          String returnDate = data['return_date'] ?? "N/A";
          String totalAmount = data['total_amount'].toString();
          String transactionId = data['transaction_id'] ?? "N/A";
          String rentAmount = data['rent_amount']?.toString() ?? "0";
          String depositAmount = data['deposit_amount']?.toString() ?? "0";
          String totalDays = data['total_days']?.toString() ?? "1";
          String tripPurpose = data['trip_purpose'] ?? "Personal";
          String cancelReason = data['cancel_reason'] ?? "";
          
          bool isAdminRejection = cancelReason.toLowerCase().contains("admin") || cancelReason.toLowerCase().contains("rejected");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 200, width: double.infinity, color: Colors.grey[900],
                    child: _buildImage(vehicleImage),
                  ),
                ),
                const SizedBox(height: 25),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(vehicleName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.15), 
                        border: Border.all(color: _getStatusColor(status)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(status.toUpperCase(), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),

                if (status == "Cancelled") ...[
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: isAdminRejection ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15), 
                      border: Border.all(color: isAdminRejection ? Colors.redAccent : Colors.orangeAccent)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(isAdminRejection ? Icons.block : Icons.cancel, color: isAdminRejection ? Colors.red : Colors.orange, size: 20), 
                          const SizedBox(width: 10), 
                          Text(isAdminRejection ? "REJECTION DETAILS" : "BOOKING CANCELLED", style: TextStyle(color: isAdminRejection ? Colors.red : Colors.orange, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1))
                        ]),
                        const SizedBox(height: 10),
                        Text(isAdminRejection ? cancelReason : "Reason: ${cancelReason.replaceFirst("User: ", "")}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 25),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.greenAccent, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Your amount will be refunded within 3-5 business days.",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                  child: Column(
                    children: [
                      _sectionTitle("TRIP INFO"),
                      _detailRow("Booking ID", "#$bookingIdDisplay", vColor: Colors.white, isBold: true), 
                      _detailRow("Pickup Date", pickupDate),
                      _detailRow("Return Date", returnDate),
                      _detailRow("Duration", "$totalDays Days"),
                      _detailRow("Purpose", tripPurpose),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white24)),
                      _sectionTitle("PAYMENT BREAKDOWN"),
                      _detailRow("Transaction ID", transactionId),
                      _detailRow("Rent / Day", "₹$rentAmount"),
                      _detailRow("Deposit (Refundable)", "₹$depositAmount"),
                      const SizedBox(height: 5),
                      _totalRow("Total Paid", "₹$totalAmount"),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white24)),
                      
                      _sectionTitle("DOCUMENTS"),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                          onPressed: () => _showDocumentsDialog(data['license_url'], data['id_proof_url']), 
                          child: const Text("VIEW UPLOADED DOCUMENTS", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 13)), 
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                if (status != "Cancelled" && status != "Completed")
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 2)),
                      onPressed: _showCancelDialog,
                      child: const Text("CANCEL BOOKING", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildImage(String path) {
    if (path.isEmpty) return const Center(child: Icon(Icons.directions_car, size: 60, color: Colors.white24));
    if (path.startsWith('http')) return Image.network(path, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image, color: Colors.white24)));
    return Image.asset(path, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.image_not_supported, color: Colors.white24)));
  }

  Widget _sectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5))));

  Widget _detailRow(String label, String value, {Color vColor = Colors.white, bool isBold = false}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white60, fontSize: 15)), Text(value, style: TextStyle(color: vColor, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: 15))]));

  Widget _totalRow(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text(value, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 18))]));

  Color _getStatusColor(String status) {
    if (status == "Completed") return Colors.green;
    if (status == "Upcoming") return Colors.blueAccent;
    if (status == "In Progress") return Colors.orange;
    if (status == "Cancelled") return Colors.red;
    return Colors.grey;
  }
}