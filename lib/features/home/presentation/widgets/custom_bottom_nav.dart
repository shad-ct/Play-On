import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_rounded, label: 'HOME'),
    _NavItem(icon: Icons.search_rounded, label: 'EXPLORE'),
    _NavItem(icon: Icons.add_circle_outline_rounded, label: 'CREATE'),
    _NavItem(icon: Icons.notifications_outlined, label: 'ALERTS'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_items.length, (index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: _NavChip(
              item: _items[index],
              selected: selected,
            ),
          );
        }),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final _NavItem item;
  final bool selected;

  const _NavChip({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: selected
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? Colors.black : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: selected ? Colors.white : Colors.black87,
            size: 22,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: selected
                ? Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
