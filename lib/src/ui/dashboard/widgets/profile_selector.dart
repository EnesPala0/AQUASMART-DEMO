import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/water_control_provider.dart';
import '../../../models/models.dart';
import '../../../constants/app_theme.dart';

class ProfileSelector extends ConsumerWidget {
  const ProfileSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    final currentUser = ref.watch(waterControlProvider).currentUser;

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isSelected = user.id == currentUser.id;

          return GestureDetector(
            onTap: () {
              ref.read(waterControlProvider.notifier).selectUser(user);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.primaryBlue, width: 3)
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: user.color.withOpacity(0.2),
                      child: Icon(user.icon, color: user.color, size: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.name,
                    style: AppTextStyles.body.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.greyText,
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
