import 'package:raising_india/models/model/address.dart';

double calculatePercentage(double? mrp, double price){
  double percent = 0;
  mrp == null? mrp = price + 5 : mrp = mrp;
  double offvalue = mrp - price;
  percent = (offvalue / mrp) * 100;
  return percent.floorToDouble();
}

String formatFullAddress(Address address) {
  List<String> parts = [
    address.streetAddress ?? '',
    address.city ?? '',
    address.state ?? '',
    address.zipCode ?? '',
  ];
  parts.removeWhere((part) => part.trim().isEmpty);
  return parts.join(', ');
}