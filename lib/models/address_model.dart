class AddressModel {
  final int? id;
  final String userId;
  final String title;
  final String recipientName;
  final String phoneNumber;
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isPrimary;

  AddressModel({
    this.id,
    required this.userId,
    required this.title,
    required this.recipientName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.zipCode,
    this.isPrimary = false, // Default value matches your Java boolean default
  });

  // Factory method to create an Address from JSON (Backend -> App)
  factory AddressModel.fromMap(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userId: json['userId'] ?? '', // Handle potential nulls safely
      title: json['title'] ?? '',
      recipientName: json['recipientName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      streetAddress: json['streetAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      isPrimary: json['isPrimary'] ?? false,
    );
  }

  // Method to convert Address to JSON (App -> Backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'isPrimary': isPrimary,
    };
  }
}
