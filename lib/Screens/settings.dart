import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nexus/Providers/user_provider.dart';
import 'package:nexus/Screens/login_screen.dart';
import 'package:provider/provider.dart';

class NexusSettingsScreen extends StatefulWidget {
  const NexusSettingsScreen({super.key});

  @override
  State<NexusSettingsScreen> createState() => _NexusSettingsScreenState();
}

class _NexusSettingsScreenState extends State<NexusSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isOfflineMode = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkOfflineMode();
  }

  Future<void> _checkOfflineMode() async {
    final conceptBox = await Hive.openBox('conceptsBox');
    setState(() {
      _isOfflineMode = conceptBox.isNotEmpty;
    });
  }

  Future<void> _toggleOfflineMode() async {
    if (_isOfflineMode) {
      await _clearOfflineData();
    } else {
      await _downloadConcepts();
    }
  }

  Future<void> _downloadConcepts() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final conceptBox = await Hive.openBox('conceptsBox');
      final snapshot = await _firestore.collection('concepts').get();

      final totalDocs = snapshot.docs.length;

      for (int i = 0; i < totalDocs; i++) {
        final doc = snapshot.docs[i];
        await conceptBox.put(doc.id, doc.data());

        setState(() {
          _downloadProgress = (i + 1) / totalDocs;
        });
      }

      setState(() {
        _isOfflineMode = true;
        _isDownloading = false;
      });

      _showSnackBar('Concepts downloaded successfully', isSuccess: true);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showSnackBar('Failed to download concepts: $e', isSuccess: false);
    }
  }

  Future<void> _clearOfflineData() async {
    final shouldClear = await _showConfirmDialog(
      title: 'Clear Offline Data',
      message:
          'This will remove all downloaded concepts. You\'ll need internet to access them again.',
      confirmText: 'Clear',
    );

    if (shouldClear == true) {
      try {
        final conceptBox = await Hive.openBox('conceptsBox');
        await conceptBox.clear();

        setState(() {
          _isOfflineMode = false;
        });

        _showSnackBar('Offline data cleared', isSuccess: true);
      } catch (e) {
        _showSnackBar('Failed to clear data: $e', isSuccess: false);
      }
    }
  }

  Future<void> _clearProgress() async {
    final shouldClear = await _showConfirmDialog(
      title: 'Clear Progress',
      message:
          'This will reset all your learning progress, completed topics, and statistics. This action cannot be undone.',
      confirmText: 'Clear Progress',
    );

    if (shouldClear == true) {
      try {
        final box = Hive.box('userBox');
        final provider = Provider.of<UserProvider>(context, listen: false);
        final userId = provider.user?.uid;

        if (userId != null) {
          await box.delete("userProfile");
          if(!mounted) return;
          await _firestore.collection('users').doc(userId).set({
            "photoUrl": "",
            "level": 0,
            "points": 0,
            "streak": 0,
            "badges": [],
            "stats": {},
            "lastActivity": {},
            "streakMap": {},
            "completedTopics": [],
            "dailyChallenges": {},
            "conceptProgress": {},
          }, SetOptions(merge: true));
        }
        if(!mounted) return;
         final collection =  _firestore.collection('users').doc(userId).collection('conceptProgress');
         final snapShot = await collection.get();
         for(final doc in snapShot.docs){
          await doc.reference.delete();
         }

          if(!mounted) return;
          
        _showSnackBar('Progress cleared successfully', isSuccess: true);
      } catch (e) {
        _showSnackBar('Failed to clear progress: $e', isSuccess: false);
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await _showConfirmDialog(
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );

    if (shouldLogout == true) {
      try {
        await _auth.signOut();
        final userBox = await Hive.openBox('userBox');
        await userBox.put("isLoggedIn", false);

        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        }
      } catch (e) {
        _showSnackBar('Failed to logout: $e', isSuccess: false);
      }
    }
  }

  Future<void> _deleteAccount() async {
    final shouldDelete = await _showConfirmDialog(
      title: 'Delete Account',
      message:
          'This will permanently delete your account and all associated data. This action cannot be undone.',
      confirmText: 'Delete Forever',
      isDangerous: true,
    );

    if (shouldDelete == true) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).delete();
          await user.delete();

          final userBox = await Hive.openBox('userBox');
          await userBox.clear();

          final conceptBox = await Hive.openBox('conceptsBox');
          await conceptBox.clear();

          if (mounted) {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
          }
        }
      } catch (e) {
        _showSnackBar('Failed to delete account: $e', isSuccess: false);
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDangerous
                          ? const Color(0xFFFF4757).withOpacity(0.3)
                          : const Color(0xFF6C63FF).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDangerous
                        ? Icons.warning_rounded
                        : Icons.info_outline_rounded,
                    color:
                        isDangerous
                            ? const Color(0xFFFF4757)
                            : const Color(0xFF6C63FF),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogButton(
                          label: 'Cancel',
                          onTap: () => Navigator.of(context).pop(false),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDialogButton(
                          label: confirmText,
                          onTap: () => Navigator.of(context).pop(true),
                          isPrimary: true,
                          isDangerous: isDangerous,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDialogButton({
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    bool isDangerous = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isPrimary
                  ? (isDangerous
                      ? const Color(0xFFFF4757)
                      : const Color(0xFF6C63FF))
                  : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isPrimary ? Colors.transparent : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isSuccess ? const Color(0xFF6C63FF) : const Color(0xFFFF4757),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'SETTINGS',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1a1a2e).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('DATA & STORAGE'),
                const SizedBox(height: 12),
                _buildSettingCard(
                  icon: Icons.cloud_download_rounded,
                  title: 'Offline Mode',
                  subtitle:
                      _isOfflineMode
                          ? 'Concepts downloaded'
                          : 'Download for offline access',
                  trailing:
                      _isDownloading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              value: _downloadProgress,
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF6C63FF),
                              ),
                            ),
                          )
                          : Switch(
                            value: _isOfflineMode,
                            onChanged: (_) => _toggleOfflineMode(),
                            activeColor: const Color(0xFF6C63FF),
                            inactiveThumbColor: Colors.white.withOpacity(0.3),
                          ),
                ),
                const SizedBox(height: 12),
                _buildSettingCard(
                  icon: Icons.refresh_rounded,
                  title: 'Clear Progress',
                  subtitle: 'Reset all learning data',
                  onTap: _clearProgress,
                  iconColor: const Color(0xFFFFB800),
                ),

                const SizedBox(height: 32),

                _buildSectionHeader('ACCOUNT'),
                const SizedBox(height: 12),
                _buildSettingCard(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: _logout,
                  iconColor: const Color(0xFF6C63FF),
                ),
                const SizedBox(height: 12),
                _buildSettingCard(
                  icon: Icons.delete_forever_rounded,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your account',
                  onTap: _deleteAccount,
                  iconColor: const Color(0xFFFF4757),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: AssetImage("assets/imgs/NexusLogo.jpg")),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'NEXUS',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 6,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Courier',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 3,
          color: Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF6C63FF)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFF6C63FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null && onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
