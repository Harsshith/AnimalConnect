import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/pawcare_provider.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PawCareProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications Center'),
        actions: [
          if (provider.unreadNotificationCount > 0)
            TextButton(
              onPressed: () {
                provider.markAllNotificationsRead();
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: provider.notifications.isEmpty
          ? const Center(child: Text('No notifications available.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.notifications.length,
              itemBuilder: (context, index) {
                final notif = provider.notifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: notif.isRead ? Colors.white : AppColors.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.isRead ? AppColors.cardBorder : AppColors.primaryLight.withOpacity(0.4),
                    ),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: ListTile(
                    onTap: () {
                      provider.markNotificationAsRead(notif.id);
                    },
                    leading: CircleAvatar(
                      backgroundColor: notif.isRead ? Colors.grey.shade200 : AppColors.actionOrange,
                      child: Icon(
                        notif.category == 'Case'
                            ? Icons.assignment
                            : notif.category == 'Funding'
                                ? Icons.volunteer_activism
                                : notif.category == 'Donation'
                                    ? Icons.favorite
                                    : Icons.notifications,
                        size: 20,
                        color: notif.isRead ? AppColors.textMuted : Colors.white,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notif.body,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM, hh:mm a').format(notif.timestamp),
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
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
