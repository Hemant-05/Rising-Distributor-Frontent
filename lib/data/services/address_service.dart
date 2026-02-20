import 'package:flutter/material.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/data/repositories/address_repo.dart';
import 'package:raising_india/models/model/address.dart';

class AddressService extends ChangeNotifier {
  final AddressRepository _repo = AddressRepository();

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _addresses = await _repo.getAllAddresses();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to load addresses.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addAddress(Address address) async {
    try {
      await _repo.addAddress(address);
      await fetchAddresses(); // Refresh list
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to add address.";
    }
  }

  Future<String?> updateAddress(int id, Address address) async {
    try {
      await _repo.updateAddress(id, address);
      await fetchAddresses();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to update address.";
    }
  }

  Future<String?> deleteAddress(int id) async {
    try {
      await _repo.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      notifyListeners();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to delete address.";
    }
  }

  Future<String?> setPrimary(int id) async {
    try {
      await _repo.setPrimaryAddress(id);
      await fetchAddresses();
      return null;
    } on AppError catch (e) {
      return e.message;
    } catch (e) {
      return "Failed to set primary address.";
    }
  }
}