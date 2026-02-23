import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/auth_service.dart';
import 'package:raising_india/models/model/admin.dart';
import 'package:raising_india/features/on_boarding/screens/welcome_screen.dart'; // Update import if needed

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings, we'll populate them in build
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    // Safely populate initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AuthService>().admin;
      if (admin != null) {
        _nameController.text = admin.name ?? '';
        _emailController.text = admin.email ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Basic validation
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Email cannot be empty'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call the AuthService to update the profile
    final error = await context.read<AuthService>().updateAdminProfile(newName, newEmail);

    if (mounted) {
      setState(() => _isLoading = false);

      if (error == null) {
        // Success!
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Failure (e.g., email already taken)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleLogout(AuthService authService) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text('Logout', style: simple_text_style(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Are you sure you want to log out?', style: simple_text_style()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: simple_text_style(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await context.read<AuthService>().signOut();
              if (authService.admin != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Logged out : ${authService.admin!.name}',
                    ),
                  ),
                );
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                );
              }
            },
            child: Text('Logout', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final Admin? admin = authService.admin;

        if (admin == null) {
          return const Scaffold(
            body: Center(child: Text("Admin profile not found")),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                back_button(),
                const SizedBox(width: 8),
                Text('Profile', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: 'Edit Profile',
                )
              else
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Reset fields to original if canceled
                      _nameController.text = admin.name ?? '';
                      _emailController.text = admin.email ?? '';
                    });
                  },
                  tooltip: 'Cancel Edit',
                ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ✅ Profile Header / Avatar
                    _buildProfileHeader(admin),
                    const SizedBox(height: 32),

                    // ✅ Form Fields Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Information', style: simple_text_style(fontSize: 16, fontWeight: FontWeight.bold, color: AppColour.primary)),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            controller: _nameController,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),
                          // Role is never editable, so we use a visual badge instead of a text field
                          _buildRoleBadge(admin.role ?? "ADMIN"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ✅ Save Button (Only visible when editing)
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColour.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Save Changes', style: simple_text_style(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      )
                    // ✅ Logout Button (Visible when NOT editing)
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton.icon(
                          onPressed: (){_handleLogout(authService);},
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: Text('Logout', style: simple_text_style(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Loading Overlay
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColour.primary),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Admin admin) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColour.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColour.primary.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Text(
                  _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'A',
                  style: simple_text_style(fontSize: 40, fontWeight: FontWeight.bold, color: AppColour.primary),
                ),
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColour.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text,
          style: simple_text_style(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          admin.uid ?? "No UID",
          style: simple_text_style(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: simple_text_style(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: enabled ? AppColour.primary : Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: simple_text_style(fontSize: 14, color: enabled ? Colors.black : Colors.grey.shade700),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: enabled ? AppColour.primary : Colors.grey.shade400, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Account Role", style: simple_text_style(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                role.toUpperCase(),
                style: simple_text_style(color: Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}