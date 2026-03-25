import 'package:flutter/material.dart';
import 'booking_summary_screen.dart';

class BookingPage extends StatefulWidget {
  final Map vehicle;
  const BookingPage({super.key, required this.vehicle});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? fromDate;
  DateTime? toDate;

  bool showDateError = false;

  DateTime get today => DateTime.now();

  int get totalDays {
    if (fromDate == null || toDate == null) return 0;
    return toDate!.difference(fromDate!).inDays + 1;
  }

  int get totalAmount {
    if (totalDays == 0) return 0;
    return totalDays * (widget.vehicle["price"] as int);
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 14)),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
        showDateError = false;

        if (toDate != null) {
          final diff = toDate!.difference(fromDate!).inDays;
          if (diff < 0 || diff >= 15) {
            toDate = null;
          }
        }
      });
    }
  }

  Future<void> pickToDate() async {
    if (fromDate == null) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate!,
      firstDate: fromDate!,
      lastDate: fromDate!.add(const Duration(days: 14)),
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
        showDateError = false;
      });
    }
  }

  void continueBooking() {
    if (fromDate == null || toDate == null) {
      setState(() {
        showDateError = true;
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSummaryScreen(
          vehicle: widget.vehicle,
          fromDate: fromDate!,
          toDate: toDate!,
          totalDays: totalDays,
          totalAmount: totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Booking",
          style: TextStyle(color: Colors.yellow),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.asset(
                widget.vehicle["image"],
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.vehicle["name"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "₹${widget.vehicle["price"]} / day",
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Pickup Location",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Chennai",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Dates",
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _dateBox(
                    text: fromDate == null
                        ? "Select From Date"
                        : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
                    onTap: pickFromDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateBox(
                    text: toDate == null
                        ? "Select To Date"
                        : "${toDate!.day}/${toDate!.month}/${toDate!.year}",
                    onTap: pickToDate,
                  ),
                ),
              ],
            ),

            if (showDateError) ...[
              const SizedBox(height: 6),
              const Text(
                "Please select From and To dates",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                const Text(
                  "Days : ",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                Text(
                  totalDays == 0 ? " " : "$totalDays",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Text(
                  "Amount : ",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                Text(
                  totalAmount == 0 ? " " : "₹$totalAmount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: continueBooking,
                child: const Text(
                  "Continue to Booking Summary",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dateBox({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
