import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  Category({required this.name, required this.icon});
}

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final void Function(int) onTabSelected;

  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onTabSelected,
    this.activeColor = Colors.blueAccent,
    this.inactiveColor = Colors.grey,
    this.backgroundColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final isSelected = idx == selectedIndex;

          return GestureDetector(
            onTap: () => onTabSelected(idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(0.2) : backgroundColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey.shade800,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    cat.icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: isSelected ? 22 : 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: isSelected ? activeColor : inactiveColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: isSelected ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
