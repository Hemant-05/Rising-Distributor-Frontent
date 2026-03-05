import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/data/services/coupon_service.dart';
import 'package:raising_india/models/model/coupon.dart';
import 'admin_create_coupon_screen.dart'; // We will create this next

class AdminCouponsScreen extends StatefulWidget {
  const AdminCouponsScreen({super.key});

  @override
  State<AdminCouponsScreen> createState() => _AdminCouponsScreenState();
}

class _AdminCouponsScreenState extends State<AdminCouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CouponService>().fetchAllCoupons();
    });
  }

  void _deleteCoupon(int id, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Coupon', style: simple_text_style(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Are you sure you want to delete the coupon "$code"?', style: simple_text_style()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: simple_text_style(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColour.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await context.read<CouponService>().deleteCoupon(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Coupon deleted successfully'),
                    backgroundColor: error == null ? Colors.green : AppColour.red,
                  ),
                );
              }
            },
            child: Text('Delete', style: simple_text_style(color: Colors.white)),
          ),
        ],
      ),
    );
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
            Text('Manage Coupons', style: simple_text_style(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColour.primary,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCreateCouponScreen()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Create', style: simple_text_style(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<CouponService>(
        builder: (context, couponService, _) {
          if (couponService.isLoading && couponService.coupons.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColour.primary));
          }

          if (couponService.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("No Coupons Found", style: simple_text_style(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColour.primary,
            onRefresh: () => couponService.fetchAllCoupons(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16).copyWith(bottom: 80),
              itemCount: couponService.coupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final coupon = couponService.coupons[index];
                return _buildCouponCard(coupon);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isPercentage = coupon.discountType == 'PERCENTAGE';
    final isActive = coupon.isActive ?? false;
    final isExpired = coupon.expirationDate != null && coupon.expirationDate!.isBefore(DateTime.now());
    final displayActive = isActive && !isExpired;

    return Container(
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Left Side (Discount Info)
          SizedBox(width: 10,),
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: displayActive ? AppColour.primary.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPercentage ? '${coupon.discountValue?.toStringAsFixed(0)}%' : '₹${coupon.discountValue?.toStringAsFixed(0)}',
                  style: simple_text_style(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: displayActive ? AppColour.primary : Colors.grey.shade500,
                  ),
                ),
                Text('OFF', style: simple_text_style(color: displayActive ? AppColour.primary : Colors.grey.shade500, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Divider
          Container(width: 1, height: 80, color: Colors.grey.shade200),

          // Right Side (Details & Actions)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Text(
                          coupon.code ?? '',
                          style: simple_text_style(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _deleteCoupon(coupon.id!, coupon.code ?? ''),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (coupon.minOrderAmount != null && coupon.minOrderAmount! > 0)
                    Text('Min Order: ₹${coupon.minOrderAmount?.toStringAsFixed(0)}', style: simple_text_style(fontSize: 12, color: Colors.grey.shade600)),
                  if (coupon.maxDiscountAmount != null && coupon.maxDiscountAmount! > 0)
                    Text('Max Discount: ₹${coupon.maxDiscountAmount?.toStringAsFixed(0)}', style: simple_text_style(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        coupon.expirationDate != null ? 'Exp: ${DateFormat('MMM d, yyyy').format(coupon.expirationDate!)}' : 'No Expiry',
                        style: simple_text_style(fontSize: 12, color: isExpired ? Colors.red : Colors.grey.shade500, fontWeight: isExpired ? FontWeight.bold : FontWeight.normal),
                      ),
                      Text(
                        displayActive ? 'Active' : (isExpired ? 'Expired' : 'Inactive'),
                        style: simple_text_style(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: displayActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
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