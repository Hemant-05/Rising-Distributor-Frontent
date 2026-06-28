import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/coupon_service.dart';
import 'package:raising_india/models/model/coupon.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key, required this.isSelectionMode});
  final bool isSelectionMode;

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch coupons on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assuming 'fetchAllCoupons' gets all available coupons
      // You might need a specific user-facing method in service if 'fetchAllCoupons' is admin-only
      // For now, using what we have in the service.
      context.read<CouponService>().fetchAllCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColour.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Coupons', style: simple_text_style(fontSize: 20)),
          ],
        ),
      ),
      body: Consumer<CouponService>(
        builder: (context, couponService, child) {
          if (couponService.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColour.primary),
            );
          }

          // You might want to filter active coupons locally if the API returns everything
          final coupons = couponService.coupons;

          if (coupons.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return _buildCouponCard(coupon);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined, // Changed icon
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No coupons available',
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    bool isExpired = false;
    if (coupon.expirationDate != null) {
      isExpired = coupon.expirationDate!.isBefore(DateTime.now());
    }
    bool isActive = (coupon.isActive ?? true) && !isExpired;

    final Color statusColor = isActive ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () => _showCouponDetails(coupon, isActive, statusColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColour.primary.withOpacity(0.2) : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColour.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_offer, color: AppColour.primary, size: 20),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.code ?? "NO CODE",
                    style: simple_text_style(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColour.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.discountType == 'PERCENTAGE'
                        ? '${coupon.discountValue?.toStringAsFixed(0)}% OFF'
                        : '₹${coupon.discountValue?.toStringAsFixed(0)} OFF',
                    style: simple_text_style(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Apply Button
            if (isActive)
              InkWell(
                onTap: () {
                  if (widget.isSelectionMode) {
                    Navigator.pop(context, coupon.code);
                  } else {
                    _copyCouponCode(coupon.code ?? "");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColour.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColour.primary),
                  ),
                  child: Text(
                    widget.isSelectionMode ? 'APPLY' : 'COPY',
                    style: simple_text_style(
                      color: AppColour.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Text(
                'EXPIRED',
                style: simple_text_style(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCouponDetails(Coupon coupon, bool isActive, Color statusColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Coupon Details',
                style: simple_text_style(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      coupon.code ?? "NO CODE",
                      style: simple_text_style(
                        color: AppColour.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      coupon.discountType == 'PERCENTAGE'
                          ? '${coupon.discountValue?.toStringAsFixed(0)}% OFF'
                          : '₹${coupon.discountValue?.toStringAsFixed(0)} OFF',
                      style: simple_text_style(
                        color: Colors.green.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (coupon.minOrderAmount != null)
                _buildDetailRow('Min Order', '₹${coupon.minOrderAmount!.toStringAsFixed(0)}'),
              if (coupon.discountType == 'PERCENTAGE' && coupon.maxDiscountAmount != null)
                _buildDetailRow('Max Discount', '₹${coupon.maxDiscountAmount!.toStringAsFixed(0)}'),
              if (coupon.expirationDate != null)
                _buildDetailRow('Expires', DateFormat('MMM d, yyyy').format(coupon.expirationDate!)),
              const SizedBox(height: 24),
              if (isActive)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close bottom sheet
                      if (widget.isSelectionMode) {
                        Navigator.pop(context, coupon.code);
                      } else {
                        _copyCouponCode(coupon.code ?? "");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColour.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.isSelectionMode ? 'APPLY COUPON' : 'COPY CODE',
                      style: simple_text_style(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: simple_text_style(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: simple_text_style(
              color: AppColour.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCouponCode(String couponCode) async {
    if (couponCode.isEmpty) return;
    try {
      await Clipboard.setData(ClipboardData(text: couponCode));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Code "$couponCode" copied!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Ignore copy errors
    }
  }
}