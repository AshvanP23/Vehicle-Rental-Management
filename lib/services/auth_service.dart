import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String adminUid = "Your Admin ID";

  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
          
      if (result.user != null) {
        if (result.user!.uid != adminUid) {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(result.user!.uid).get();
          if (!userDoc.exists) {
            await _auth.signOut(); 
            throw "User not available or blocked by Admin"; 
          }
        }
      }

      return result.user;
    } catch (e) {
      debugPrint("Login Error: $e");
      throw e; 
    }
  }

  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> saveBooking({
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
      User? user = _auth.currentUser;
      if (user == null) return "User not logged in";

      String bookingId = "BK${DateTime.now().millisecondsSinceEpoch}";
      
      String formattedFromDate = "${fromDate.day.toString().padLeft(2, '0')}/${fromDate.month.toString().padLeft(2, '0')}/${fromDate.year}";
      String formattedToDate = "${toDate.day.toString().padLeft(2, '0')}/${toDate.month.toString().padLeft(2, '0')}/${toDate.year}";

      String licenseUrl = await _uploadFile(licenseFile, "bookings/$bookingId/license");
      String idUrl = await _uploadFile(idFile, "bookings/$bookingId/id_proof");

      Map<String, dynamic> bookingData = {
        'bookingId': bookingId,
        'userId': user.uid,
        'userName': userName,
        'userEmail': userEmail,
        'userPhone': userPhone,
        'vehicleName': vehicle['name'],
        'vehicleImage': vehicle['image'],
        'pickupDate': formattedFromDate,
        'returnDate': formattedToDate,
        'totalDays': totalDays,
        'rentAmount': rentAmount,
        'depositAmount': depositAmount,
        'totalAmount': totalAmount,
        'tripPurpose': tripPurpose,
        'licenseUrl': licenseUrl,
        'idProofUrl': idUrl,
        'status': 'Upcoming',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('bookings').doc(bookingId).set(bookingData);
      await _firestore.collection('users').doc(user.uid).collection('my_bookings').doc(bookingId).set(bookingData);

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> _uploadFile(PlatformFile file, String path) async {
    File f = File(file.path!);
    Reference ref = _storage.ref().child("$path.${file.extension}");
    UploadTask uploadTask = ref.putFile(f);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}