import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SalesDashboardShimmer extends StatelessWidget {
  const SalesDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Filter Dropdown Placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildSkeletonBox(width: 200, height: 40, radius: 20),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Summary Cards Skeleton (Top Row)
            Row(
              children: [
                Expanded(child: _buildSkeletonBox(height: 120, radius: 16)),
                const SizedBox(width: 16),
                Expanded(child: _buildSkeletonBox(height: 120, radius: 16)),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Summary Cards Skeleton (Bottom Row)
            Row(
              children: [
                Expanded(child: _buildSkeletonBox(height: 120, radius: 16)),
                const SizedBox(width: 16),
                Expanded(child: _buildSkeletonBox(height: 120, radius: 16)),
              ],
            ),
            const SizedBox(height: 30),

            // 4. Chart Title Skeleton
            _buildSkeletonBox(width: 150, height: 24, radius: 4),
            const SizedBox(height: 16),

            // 5. The Big Chart Skeleton
            _buildSkeletonBox(height: 300, radius: 16),
          ],
        ),
      ),
    );
  }

  // Helper method to draw the grey boxes
  Widget _buildSkeletonBox({
    double? width,
    required double height,
    required double radius
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white, // The shimmer package handles turning this grey/shiny
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}