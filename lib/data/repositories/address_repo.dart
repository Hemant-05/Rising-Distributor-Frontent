import 'package:raising_india/data/rest_client.dart';
import 'package:raising_india/error/exceptions.dart';
import 'package:raising_india/models/model/address.dart';
import 'package:raising_india/services/service_locator.dart';

class AddressRepository with RepoErrorHandler {
  final RestClient _client = getIt<RestClient>();

  Future<List<Address>> getAllAddresses() async {
    try {
      final response = await _client.getAddresses();
      return response.data ?? [];
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Address> addAddress(Address address) async {
    try {
      final response = await _client.addAddress(address);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<Address> updateAddress(int id, Address address) async {
    try {
      final response = await _client.updateAddress(id, address);
      return response.data!;
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _client.deleteAddress(id);
    } catch (e) {
      throw handleError(e);
    }
  }

  Future<void> setPrimaryAddress(int id) async {
    try {
      await _client.setPrimaryAddress(id);
    } catch (e) {
      throw handleError(e);
    }
  }
}