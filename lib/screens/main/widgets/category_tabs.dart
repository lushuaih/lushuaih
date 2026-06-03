import 'package:flutter/material.dart';
import '../../models/post_model.dart';

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: PostCategory.defaults.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildTab(
              label: '全部',
              isSelected: selectedCategory.isEmpty,
              onTap: () => onCategorySelected(''),
            );
          }

          final category = PostCategory.defaults[index - 1];
          return _buildTab(
            label: '${category.icon} ${category.name}',
            isSelected: selectedCategory == category.id,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue,
        showCheckmark: false,
      ),
    );
  }
}
