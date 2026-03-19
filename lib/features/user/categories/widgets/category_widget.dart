import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raising_india/comman/simple_text_style.dart';
import 'package:raising_india/models/model/category.dart';

Widget category_widget(BuildContext context, Category category, {required VoidCallback onTap}) {
  final String imageUrl = category.imageUrl ?? "";
  final bool hasImage = imageUrl.isNotEmpty;

  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque, // Ensures the whole block is clickable
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image Box (Matches the Swiggy/Zepto style)
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Soft grey background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.03)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasImage
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover, // Or BoxFit.contain depending on your images
                errorWidget: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                ),
              )
                  : const Center(
                child: Icon(Icons.category_outlined, color: Colors.grey, size: 32),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8), // Space between image and text

        // Text Section
        Text(
          category.name ?? "Category",
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: simple_text_style(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.2, // Tighter line height for multiline text
          ),
        ),
      ],
    ),
  );
}