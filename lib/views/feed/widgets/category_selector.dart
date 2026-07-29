import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../theme/app_theme.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({Key? key}) : super(key: key);

  static IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hotels':
        return Icons.hotel_rounded;
      case 'Venues':
        return Icons.nature_people_rounded;
      case 'Photography':
        return Icons.camera_alt_rounded;
      case 'Catering':
        return Icons.restaurant_rounded;
      case 'Gyms':
        return Icons.fitness_center_rounded;
      case 'Events':
        return Icons.confirmation_number_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketplace = Provider.of<MarketplaceProvider>(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: marketplace.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = marketplace.categories[index];
          final isSelected = cat == marketplace.selectedCategory;

          return InkWell(
            onTap: () => marketplace.selectCategory(cat),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.borderLight,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(cat),
                    size: 18,
                    color: isSelected ? Colors.white : AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textDark,
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
