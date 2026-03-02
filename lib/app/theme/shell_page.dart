import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../features/qr_generator/presentation/pages/generate_page.dart';
import '../../../features/scanner/presentation/pages/scanner_page.dart';
import '../../../features/files/presentation/pages/files_page.dart';
import '../../../features/auth/presentation/widgets/app_drawer.dart';
import '../../../core/widgets/frosted_nav_bar.dart';
import 'app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/permissions/bloc/permissions_bloc.dart';
import '../../../core/permissions/bloc/permissions_event.dart';

/// Shell page wrapping the bottom nav and drawer.
/// Intercepts back button to show an exit confirmation dialog.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check permissions on app launch
    context.read<PermissionsBloc>().add(const CheckAppPermissions());
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return const GeneratePage();
      case 1:
        return const ScannerPage();
      case 2:
        return const FilesPage();
      default:
        return const GeneratePage();
    }
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: AppColors.orange),
            SizedBox(width: 8),
            Text('Exit App'),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit QR Generator?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (shouldExit == true) {
      SystemNavigator.pop(); // graceful exit
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onWillPop();
      },
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        drawer: Builder(
          builder: (drawerContext) => AppDrawer(
            onLogoTap: () {
              Navigator.pop(drawerContext); // close drawer
              setState(() => _currentIndex = 0); // go to Generate tab
            },
          ),
        ),
        drawerEnableOpenDragGesture: false,
        appBar: _currentIndex == 1
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.teal, AppColors.darkTeal],
                    ),
                  ),
                ),
                iconTheme: const IconThemeData(color: AppColors.white),
                titleTextStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: Text(_getTitle()),
              ),
        extendBody: true,

        // 👇 ADD THIS
        resizeToAvoidBottomInset: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: _buildPage(),

        bottomNavigationBar: FrostedNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Generate';
      case 1:
        return 'Scanner';
      case 2:
        return 'Files';
      default:
        return '';
    }
  }
}
