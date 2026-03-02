import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_generator/app/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFooter extends StatelessWidget {
  const ContactFooter({super.key});

  final String _contactPhone = '09760143260';
  final String _contactEmail = 'dejesusjerico528@gmail.com';

  void _showContactOptions(BuildContext context, String type, String value) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        decoration: const BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              type == 'phone' ? 'Phone Number' : 'Email Address',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.forest),
              title: Text('Copy to Clipboard'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$value copied to clipboard'),
                    backgroundColor: AppColors.forest,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                type == 'phone' ? Icons.phone_rounded : Icons.email_rounded,
                color: AppColors.forest,
              ),
              title: Text(type == 'phone' ? 'Open Dialer' : 'Send Email'),
              onTap: () async {
                Navigator.pop(ctx);
                final Uri url = type == 'phone'
                    ? Uri(scheme: 'tel', path: value)
                    : Uri(scheme: 'mailto', path: value);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Could not open application'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.charcoal.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Developer Info:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _showContactOptions(context, 'phone', _contactPhone),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone_rounded,
                    size: 13,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _contactPhone,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.forest,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          InkWell(
            onTap: () => _showContactOptions(context, 'email', _contactEmail),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_rounded,
                    size: 13,
                    color: AppColors.mediumGray,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _contactEmail,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.forest,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.mediumGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
