import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/data/services/user_service.dart';
import 'package:raising_india/models/model/customer.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {

  // --- 1. EDIT PROFILE BOTTOM SHEET ---
  void _showEditProfileSheet(BuildContext context, Customer user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to move up with keyboard
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          bool isSaving = false;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Avoid keyboard overlapping
              left: 24, right: 24, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit Profile", style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),

                // Name Field
                _buildInputField(nameController, "Full Name", Icons.person_outline),
                const SizedBox(height: 16),

                // Email Field
                _buildInputField(emailController, "Email Address", Icons.email_outlined),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColour.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSaving ? null : () async {
                      setSheetState(() => isSaving = true);

                      final error = await context.read<AuthService>().updateCustomerProfile(
                        nameController.text.trim(),
                        emailController.text.trim(),
                      );

                      setSheetState(() => isSaving = false);

                      if (error == null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: isSaving
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Save Changes", style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 2. ADD / VERIFY MOBILE BOTTOM SHEET ---
  void _showAddMobileSheet(BuildContext context, String? currentNumber) {
    final phoneController = TextEditingController(text: currentNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          bool isSending = false;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Verify Mobile", style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("We will send an OTP to verify your number.", style: simple_text_style(color: Colors.grey.shade600)),
                const SizedBox(height: 20),

                _buildInputField(phoneController, "Mobile Number", Icons.phone_android, isNumber: true),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColour.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSending ? null : () async {
                      if (phoneController.text.isEmpty) return;

                      setSheetState(() => isSending = true);

                      String number = phoneController.text.trim();
                      // Request OTP
                      final error = await context.read<UserService>().registerMobile('+91$number');

                      setSheetState(() => isSending = false);

                      if (error == null) {
                        Navigator.pop(context); // Close phone sheet
                        _showOtpSheet(context); // Open OTP sheet
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: isSending
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Send OTP", style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 3. ENTER OTP BOTTOM SHEET ---
  void _showOtpSheet(BuildContext context) {
    final otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          bool isVerifying = false;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Enter OTP", style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Enter the 6-digit code sent to your phone.", style: simple_text_style(color: Colors.grey.shade600)),
                const SizedBox(height: 20),

                _buildInputField(otpController, "OTP Code", Icons.message_outlined, isNumber: true),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColour.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isVerifying ? null : () async {
                      if (otpController.text.isEmpty) return;

                      setSheetState(() => isVerifying = true);

                      // Verify OTP
                      final error = await context.read<UserService>().verifyMobile(otpController.text.trim());

                      setSheetState(() => isVerifying = false);

                      if (error == null) {
                        // Refresh the AuthService to update the green badge globally!
                        await context.read<AuthService>().loadUserFromStorage();

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Phone Verified!"), backgroundColor: Colors.green),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: isVerifying
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text("Verify", style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper UI component for TextFields
  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          hintText: hint,
          hintStyle: simple_text_style(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // --- MAIN SCREEN BUILD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Personal Info', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // EDIT BUTTON IN APP BAR
          Consumer<AuthService>(
            builder: (context, authService, _) {
              if (authService.customer != null) {
                return TextButton.icon(
                  onPressed: () => _showEditProfileSheet(context, authService.customer!),
                  icon: Icon(Icons.edit_outlined, color: AppColour.primary, size: 18),
                  label: Text("Edit", style: simple_text_style(color: AppColour.primary, fontWeight: FontWeight.bold)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final user = authService.customer;

          if (user == null) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColour.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColour.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      user.name != null && user.name!.isNotEmpty
                          ? user.name![0].toUpperCase()
                          : "?",
                      style: simple_text_style(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColour.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildInfoCard(
                  icon: Icons.person_outline_rounded,
                  title: 'Full Name',
                  value: user.name ?? 'Not Provided',
                ),
                const SizedBox(height: 16),

                _buildInfoCard(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  value: user.email ?? 'Not Provided',
                ),
                const SizedBox(height: 16),

                // Phone Card (Interactive)
                _buildPhoneCard(
                  context: context,
                  icon: Icons.phone_android_rounded,
                  title: 'Mobile Number',
                  value: (user.mobileNumber == null || user.mobileNumber!.isEmpty) ? 'Not Provided' : user.mobileNumber!,
                  isVerified: user.isMobileVerified ?? false,
                  onVerifyTap: () => _showAddMobileSheet(context, user.mobileNumber),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColour.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColour.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: simple_text_style(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value, style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required bool isVerified,
    required VoidCallback onVerifyTap, // Triggers BottomSheet
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColour.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColour.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: simple_text_style(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value, style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Interactive Verification Badge
          InkWell(
            onTap: isVerified ? null : onVerifyTap, // Only tappable if NOT verified
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isVerified ? Colors.green.shade50 : AppColour.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isVerified ? Colors.green.shade200 : AppColour.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVerified ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                    color: isVerified ? Colors.green : AppColour.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVerified ? 'Verified' : 'Verify Now',
                    style: simple_text_style(
                      color: isVerified ? Colors.green.shade700 : AppColour.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}