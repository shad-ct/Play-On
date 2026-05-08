import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NearestTurfSlider extends StatelessWidget {
  const NearestTurfSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final turfs = [
      {'name': 'Green Valley Turf', 'distance': '1.2 km', 'rating': '4.5', 'emoji': '🌿'},
      {'name': 'City Sports Arena', 'distance': '2.8 km', 'rating': '4.2', 'emoji': '🏟'},
      {'name': 'PlayZone Pro', 'distance': '3.5 km', 'rating': '4.7', 'emoji': '⚡'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: turfs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final turf = turfs[index];
          return Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(turf['emoji']!,
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        turf['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.near_me,
                            color: AppColors.primaryBlue, size: 13),
                        const SizedBox(width: 4),
                        Text(turf['distance']!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 13),
                        const SizedBox(width: 2),
                        Text(turf['rating']!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
