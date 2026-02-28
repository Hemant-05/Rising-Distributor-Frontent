import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/elevated_button_style.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/notification_service.dart';

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
          content: Text('Please enter both Title and Message.', style: simple_text_style(color: Colors.white)),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    // Call your NotificationService
    final error = await context.read<NotificationService>().sendBroadcast(title, body);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Broadcast sent successfully to all users!', style: simple_text_style(color: Colors.white, isEllipsisAble: false)),
        ),
      );
      // Clear fields after sending
      _titleController.clear();
      _bodyController.clear();
      // Optional: Navigator.pop(context); if you want to close the screen
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
        elevation: 0,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Send Broadcast', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. LIVE PREVIEW CARD ---
            Text("Live Preview", style: simple_text_style(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                border: Border.all(color: AppColour.primary.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColour.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.campaign_outlined, color: AppColour.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _titleController,
                      builder: (context, titleValue, _) {
                        return ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _bodyController,
                          builder: (context, bodyValue, _) {
                            final displayTitle = titleValue.text.isEmpty ? "Notification Title" : titleValue.text;
                            final displayBody = bodyValue.text.isEmpty ? "Your message will appear here..." : bodyValue.text;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(displayTitle, style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 16))),
                                    Text("Now", style: simple_text_style(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(displayBody, style: simple_text_style(color: Colors.grey.shade700, fontSize: 14, isEllipsisAble: false)),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 2. INPUT FIELDS ---
            Text("Notification Details", style: simple_text_style(fontWeight: FontWeight.bold, color: AppColour.primary)),
            const SizedBox(height: 12),

            // Title Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Title (e.g., 50% OFF Flash Sale!)",
                  labelStyle: simple_text_style(color: Colors.grey.shade500),
                  counterText: "", // Hide the character counter
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Body Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _bodyController,
                maxLines: 4,
                maxLength: 150,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Message Body",
                  labelStyle: simple_text_style(color: Colors.grey.shade500),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- 3. SEND BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: elevated_button_style(),
                onPressed: _isSending ? null : _sendBroadcast,
                icon: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.white),
                label: Text(
                  _isSending ? "SENDING..." : "SEND BROADCAST NOW",
                  style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text(
                "This will instantly notify all subscribed users.",
                style: simple_text_style(color: Colors.grey.shade500, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}