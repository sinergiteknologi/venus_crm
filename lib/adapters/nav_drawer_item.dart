import 'package:flutter/material.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final String count;
  final bool isSpinner;
  final bool showBadge;

  DrawerItem({
    required this.title,
    required this.icon,
    this.count = "0",
    this.isSpinner = false,
    this.showBadge = false,
  });
}

class NavDrawerItem extends StatelessWidget {
  final DrawerItem item;
  final VoidCallback onTap;
  final bool selected;

  const NavDrawerItem({
    super.key,
    required this.item,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isSpinner) {
      // In Flutter, we'd typically use a UserAccountsDrawerHeader or a custom widget for the profile section
      return const SizedBox.shrink(); 
    }

    if (item.title == "Login") {
      return const SizedBox.shrink();
    }

    final hasBadge = item.showBadge || item.count != "0";

    return Container(
      color: selected ? const Color(0xFFB7C8F3) : const Color(0xFFEDEDED),
      child: ListTile(
        dense: true,
        leading: Icon(item.icon, color: const Color(0xFF1E4CCB)),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Color(0xFF1E4CCB),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: hasBadge
            ? Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  item.count == "0" ? "+" : item.count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
