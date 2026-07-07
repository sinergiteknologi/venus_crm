import 'package:flutter/material.dart';
import '../shared/widgets/app_logo.dart';

class HeaderItem {
  final int id;
  final String nis;
  final String name;
  final dynamic img; // Can be a path or a Bitmap/ImageProvider

  HeaderItem({required this.id, required this.nis, required this.name, this.img});
}

class CustomHeaderItem extends StatelessWidget {
  final HeaderItem item;

  const CustomHeaderItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: item.img is String
                ? ClipOval(
                    child: Image.asset(
                      item.img as String,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : const ClipOval(
                    child: AppLogo(size: 40, fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item.nis,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
