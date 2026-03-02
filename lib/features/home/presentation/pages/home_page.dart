import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/glassmorphism.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../history/presentation/bloc/history_bloc.dart';
import '../../../qr_generator/presentation/bloc/qr_generator_bloc.dart';

/// Home page — dashboard with quick actions and recent activity.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<QrGeneratorBloc>().add(const LoadGeneratedItems());
    context.read<HistoryBloc>().add(const LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forest,
          onRefresh: () async {
            context.read<QrGeneratorBloc>().add(const LoadGeneratedItems());
            context.read<HistoryBloc>().add(const LoadHistory());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ─── Header ──────────────────────────────────
                Text(
                  'QR Generator',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Create, Scan & Organize',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.sage),
                ),
                const SizedBox(height: 24),

                // ─── Quick Actions ───────────────────────────
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // ─── Stats ───────────────────────────────────
                _buildStatsRow(),
                const SizedBox(height: 24),

                // ─── Recent Activity ─────────────────────────
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoaded && state.history.isNotEmpty) {
                      final recent = state.history.take(5).toList();
                      return Column(
                        children: recent.map((scan) {
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.amber.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    scan.scanType == 'qr'
                                        ? Icons.qr_code_rounded
                                        : Icons.view_week_rounded,
                                    color: AppColors.amber,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scan.scannedData,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                      Text(
                                        'Scanned ${_timeAgo(scan.timestamp)}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          color: AppColors.mediumGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return GlassCard(
                      margin: EdgeInsets.zero,
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 40,
                              color: AppColors.mediumGray.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No recent activity',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100), // Space for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.view_week_rounded,
        'label': 'Barcode',
        'color': AppColors.sage,
      },
      {
        'image': 'assets/App-Logo-No-Background.png', // <-- your asset path
        'label': 'QR Code',
        'color': AppColors.forest,
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'label': 'Batch',
        'color': AppColors.forest,
      },
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GlassCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 20),
              opacity: 0.18,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: action.containsKey('image')
                        ? Image.asset(
                            action['image'] as String,
                            width: 24,
                            height: 24,
                            color:
                                action['color']
                                    as Color, // remove if you don't want tint
                          )
                        : Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 24,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsRow() {
    return BlocBuilder<QrGeneratorBloc, QrGeneratorState>(
      builder: (context, state) {
        int totalItems = 0;
        int qrCount = 0;
        int barcodeCount = 0;
        if (state is QrGeneratorItemsLoaded) {
          totalItems = state.items.length;
          qrCount = state.items.where((i) => i.type == 'qr').length;
          barcodeCount = state.items.where((i) => i.type == 'barcode').length;
        }

        return Row(
          children: [
            _buildStatCard(
              'Total',
              totalItems.toString(),
              Icons.grid_view_rounded,
              AppColors.forest,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'QR',
              qrCount.toString(),
              Icons.qr_code_rounded,
              AppColors.amber,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              'Barcode',
              barcodeCount.toString(),
              Icons.view_week_rounded,
              AppColors.sage,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: Glassmorphism.floating(tint: color),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 8),
                Text(
                  count,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}
