import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';

Future<void> showCancelOrderDialog(BuildContext context, void Function(String reason) onCancel) async {
  final TextEditingController reasonController = TextEditingController();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 8),
            Text('Cancel Order', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'If you cancel the order, you will be refunded the full amount except the platform fee (₹3).',
              style: simple_text_style(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Please tell us why...',
                hintStyle: simple_text_style(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColour.primary)),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Keep Order', style: simple_text_style(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(context).pop();
                onCancel(reason);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a reason')));
              }
            },
            child: Text('Yes, Cancel', style: simple_text_style(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}