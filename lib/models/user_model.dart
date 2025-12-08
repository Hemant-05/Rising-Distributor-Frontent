import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raising_india/models/address_model.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? mobileNumber;
  final String role;
  final bool? isMobileVerified;
  final GeoPoint? currentLocation;
  final List<AddressModel> addressList;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.role,
    this.isMobileVerified,
    this.currentLocation,
    required this.addressList,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'number': mobileNumber,
      'role': role,
      'isVerified': isMobileVerified,
      'currentLocation': currentLocation,
      'addressList' : addressList,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      name: map['name'],
      email: map['email'],
      mobileNumber: map['number'].toString(),
      role: map['role'],
      isMobileVerified: map['isVerified'],
      currentLocation: map['currentLocation'],
      addressList: _convertAddressList(map['addressList']),
    );
  }
  // Helper method to safely convert address list
  static List<AddressModel> _convertAddressList(dynamic addressData) {
    if (addressData == null) return [];

    try {
      final List<dynamic> dynamicList = addressData as List<dynamic>;
      return dynamicList
          .map((item) => AddressModel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error converting address list: $e');
      return [];
    }
  }
}
