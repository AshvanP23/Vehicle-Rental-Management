import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVehicleEditScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;
  const AdminVehicleEditScreen({super.key, required this.vehicle});

  @override
  State<AdminVehicleEditScreen> createState() => _AdminVehicleEditScreenState();
}

class _AdminVehicleEditScreenState extends State<AdminVehicleEditScreen> {
  late bool isAvailable;
  late TextEditingController priceController;
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isAvailable = widget.vehicle['available'] ?? true;
    priceController = TextEditingController(text: widget.vehicle['price'].toString());
  }

  void _confirmAndSave() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Confirm Changes", style: TextStyle(color: Colors.yellow)),
        content: const Text("Are you sure you want to update this vehicle?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveVehicle();
            },
            child: const Text("UPDATE", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVehicle() async {
    setState(() => isLoading = true);
    int newPrice = int.tryParse(priceController.text) ?? widget.vehicle['price'];

    try {
      await supabase.from('vehicles').update({
        'price': newPrice, 
        'available': isAvailable
      }).eq('name', widget.vehicle['name']);


      widget.vehicle['price'] = newPrice;
      widget.vehicle['available'] = isAvailable;

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Updated Successfully"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Update failed")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Edit Vehicle", style: TextStyle(color: Colors.yellow)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(widget.vehicle['image'], height: 200, fit: BoxFit.cover),
            ),
            const SizedBox(height: 10),
            Text(
              widget.vehicle['name'],
              style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Availability Status", style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: isAvailable,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.withOpacity(0.3),
                    onChanged: (v) => setState(() => isAvailable = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Daily Rent (₹)",
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
                onPressed: isLoading ? null : _confirmAndSave,
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("UPDATE VEHICLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}