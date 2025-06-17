import 'package:emerge_business/Product/productList.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StandardDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userImage;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final String loginRoute;

  const StandardDrawer({
    Key? key,
    this.userName = 'User Name',
    this.userEmail = 'user@example.com',
    this.userImage,
    this.onProfileTap,
    this.onSettingsTap,
    this.loginRoute = '/login',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // User Account Header
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              backgroundImage: userImage != null
                  ? NetworkImage(userImage!)
                  : null,
              child: userImage == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('My Products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductListPage()),
              );
            },
          ),

          // ListTile(
          //   leading: const Icon(Icons.person),
          //   title: const Text('Profile'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     onProfileTap?.call();
          //   },
          // ),

          // ListTile(
          //   leading: const Icon(Icons.favorite),
          //   title: const Text('Favorites'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),

          // ListTile(
          //   leading: const Icon(Icons.shopping_bag),
          //   title: const Text('Orders'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),

          // ListTile(
          //   leading: const Icon(Icons.notifications),
          //   title: const Text('Notifications'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),

          // const Divider(),

          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     onSettingsTap?.call();
          //   },
          // ),

          // ListTile(
          //   leading: const Icon(Icons.help),
          //   title: const Text('Help & Support'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),

          // ListTile(
          //   leading: const Icon(Icons.info),
          //   title: const Text('About'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     _showAboutDialog(context);
          //   },
          // ),

          // const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to login page and clear all previous routes
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
      }
    } catch (e) {
      // Handle logout error
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'My App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.apps),
      children: [const Text('This is a sample Flutter application.')],
    );
  }
}
