import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/notification_service.dart';
import 'package:raising_india/features/admin/widgets/admin_responsive.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Please enter both Title and Message.',
            style: simple_text_style(color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    final error = await context.read<NotificationService>().sendBroadcast(
      title,
      body,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Broadcast sent successfully to all users!',
            style: simple_text_style(
              color: Colors.white,
              isEllipsisAble: false,
            ),
          ),
        ),
      );
      _titleController.clear();
      _bodyController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(error, style: simple_text_style(color: Colors.white)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColour.white,
        surfaceTintColor: AppColour.white,
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Send Broadcast',
                style: simple_text_style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: AdminPageShell(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop =
                  constraints.maxWidth >= AdminResponsive.desktopBreakpoint;
              final form = _buildComposer();
              final preview = _buildPreviewPanel();

              if (!isDesktop) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [preview, const SizedBox(height: 20), form],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: form),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: preview),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return _sectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.campaign_outlined, 'Notification Details'),
          const SizedBox(height: 20),
          _buildInput(
            controller: _titleController,
            label: 'Title',
            hint: '50% OFF Flash Sale',
            maxLength: 50,
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _bodyController,
            label: 'Message Body',
            hint: 'Write the customer-facing message',
            maxLength: 150,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: elevated_button_style(),
              onPressed: _isSending ? null : _sendBroadcast,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                _isSending ? 'SENDING...' : 'SEND BROADCAST',
                style: simple_text_style(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel() {
    return _sectionSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.notifications_active_outlined, 'Live Preview'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColour.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.campaign_outlined,
                    color: AppColour.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildLivePreviewText()),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.groups_outlined,
            'Audience',
            'All subscribed users',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.bolt_outlined, 'Delivery', 'Firebase push topic'),
        ],
      ),
    );
  }

  Widget _buildLivePreviewText() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _titleController,
      builder: (context, titleValue, _) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: _bodyController,
          builder: (context, bodyValue, _) {
            final displayTitle = titleValue.text.isEmpty
                ? 'Notification Title'
                : titleValue.text;
            final displayBody = bodyValue.text.isEmpty
                ? 'Your message will appear here...'
                : bodyValue.text;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: simple_text_style(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Now',
                      style: simple_text_style(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  displayBody,
                  style: simple_text_style(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    isEllipsisAble: false,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLength,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColour.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _sectionSurface({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColour.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: simple_text_style(color: Colors.grey.shade700, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
