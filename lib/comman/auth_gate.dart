import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/features/auth/screens/google_auth_choice_screen.dart';
import 'package:raising_india/features/auth/screens/mobile_verification_screen.dart';

Future<bool> ensureCustomerSignedIn(BuildContext context) async {
  if (context.read<AuthService>().isCustomer) return true;

  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      builder: (_) =>
          const GoogleAuthChoiceScreen(returnToPreviousOnSuccess: true),
    ),
  );

  if (!context.mounted) return false;
  return result == true || context.read<AuthService>().isCustomer;
}

Future<bool> ensureCustomerMobileVerified(BuildContext context) async {
  final customer = context.read<AuthService>().customer;
  final hasMobile = (customer?.mobileNumber ?? '').trim().isNotEmpty;
  if (hasMobile && (customer?.isMobileVerified ?? false)) return true;

  final result = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      builder: (_) =>
          MobileVerificationScreen(initialMobileNumber: customer?.mobileNumber),
    ),
  );

  if (!context.mounted) return false;
  final updatedCustomer = context.read<AuthService>().customer;
  return result == true ||
      (((updatedCustomer?.mobileNumber ?? '').trim().isNotEmpty) &&
          (updatedCustomer?.isMobileVerified ?? false));
}
