import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/models/model/category.dart';

Widget category_widget(BuildContext context, Category category, {required VoidCallback onTap}) {
  final String imageUrl = category.imageUrl ?? "";
  final bool hasImage = imageUrl.isNotEmpty;

  // Check if this category has children to show a visual hint
  final bool hasSubCategories = (category.subCategories != null && category.subCategories!.isNotEmpty);

  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppColour.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  hasImage
                      ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade50,
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                    ),
                  )
                      : Container(
                    color: Colors.grey.shade50,
                    child: const Icon(Icons.category_outlined, color: Colors.grey, size: 40),
                  ),

                  // Visual hint if it contains subcategories (a small folder/stack icon)
                  if (hasSubCategories)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_tree_outlined, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Text Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Text(
              category.name ?? "Category",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: simple_text_style(
                color: AppColour.black,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}