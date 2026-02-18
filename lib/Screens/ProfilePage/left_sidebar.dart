import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Models/user_model.dart';
import 'package:nexus/Providers/badges_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeftSidebar extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onUpdate;

  const LeftSidebar({super.key, required this.user, required this.onUpdate});

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  bool isEditing = false;
  late TextEditingController _nameController;
  String? _newImage;
  late Box userBox;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    userBox = Hive.box('userBox');
    _loadLocalUserData();
    final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
    if (badgesProvider.allBadges.isEmpty) {
      badgesProvider.fetchBadges();
    }
  }

  void _loadLocalUserData() {
    final localUser = userBox.get('userProfile');
    if (localUser != null) {
      _nameController.text = localUser['name'] ?? widget.user.name;
      widget.user.photoUrl = localUser['photoUrl'] ?? widget.user.photoUrl;
    }
  }

 Future<void> pickImage() async {
  if (kIsWeb) return;

  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 70,
  );

  if (picked == null) return;

  final file = File(picked.path);
  const bucketName = 'user_profile_imgs';
  final fileName = "profile_${widget.user.name}_${widget.user.uid}.jpg";
  final bucket = supabase.storage.from(bucketName);

  try {
    final existingUrl = userBox.get('userProfile')?['photoUrl'] as String?;
    if (existingUrl != null && existingUrl.isNotEmpty) {
      final oldName = existingUrl.split('/').last;
      try {
        await bucket.remove([oldName]);
        debugPrint("Deleted old image from Supabase");
      } catch (e) {
        debugPrint("Error deleting old image: $e");
      }
    }

    await bucket.upload(
      fileName,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    final publicUrl = bucket.getPublicUrl(fileName);

    userBox.put('userProfile', {'photoUrl': publicUrl});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .set({'photoUrl': publicUrl}, SetOptions(merge: true));

    setState(() {
      _newImage = publicUrl;
    });

    debugPrint("============= Image Uploaded Successfully =============");
  } catch (e) {
    debugPrint("Error uploading image: $e");
  }
}


  void saveChanges() async {
    final updatedUser = widget.user.copyWith(
      name: _nameController.text.isEmpty ? 'User' : _nameController.text,
      photoUrl: _newImage != null ? _newImage! : widget.user.photoUrl,
    );
    widget.onUpdate(updatedUser);
    await userBox.put('userProfile', {
      'uid': updatedUser.uid,
      'name': updatedUser.name,
      'email': updatedUser.email,
      'photoUrl': updatedUser.photoUrl,
      'points': updatedUser.points,
      'level': updatedUser.level,
      'streak': updatedUser.streak,
    });

    FirebaseFirestore.instance.collection('users').doc(updatedUser.uid).set({
      'name': updatedUser.name,
      'photoUrl': updatedUser.photoUrl,
    }, SetOptions(merge: true));
    setState(() {
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final badgesProvider = Provider.of<BadgesProvider>(context);
    final localUser = userBox.get('userProfile');

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(widget.user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final userBadges = List<String>.from(userData['badges'] ?? []);
        final userName =
            localUser?['name'] ?? userData['name'] ?? widget.user.name;
        final userEmail =
            localUser?['email'] ?? userData['email'] ?? widget.user.email;
        final userLevel =
            localUser?['level'] ?? userData['level'] ?? widget.user.level;
        final userPoints =
            localUser?['points'] ?? userData['points'] ?? widget.user.points;
        final userPhoto =
            localUser?['photoUrl'] ??
            userData['photoUrl'] ??
            widget.user.photoUrl;
        final userStreak = localUser?['streak'] ?? userData['streak'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B1B2F), Color(0xFF1E1E2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // ===== Profile Avatar =====
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.6),
                          Colors.purpleAccent.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[900],
                      child: _buildProfileImage(userPhoto),
                    ),
                  ),
                  if (!kIsWeb)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.purpleAccent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== Name =====
              isEditing
                  ? TextField(
                    controller: _nameController..text = userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Enter name",
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                    ),
                  )
                  : Text(
                    userName.isEmpty ? "User" : userName,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // ===== Level & Points =====
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Text(
                  "Level $userLevel | Points $userPoints",
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ===== 🔥 Streak Count =====
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, Colors.amberAccent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Streak: $userStreak",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ===== Edit / Save Button =====
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                onPressed: () {
                  if (isEditing) {
                    saveChanges();
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
                child: Text(
                  isEditing ? "Save Changes" : "Edit Profile",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== Badges Section =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Badges & Awards",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 90,
                child:
                    badgesProvider.allBadges.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                              userBadges.isEmpty
                                  ? [
                                    _buildBadge(
                                      "Newbie",
                                      Iconsax.star,
                                      Colors.grey,
                                    ),
                                  ]
                                  : userBadges.map((badgeId) {
                                    final badge = badgesProvider.getBadgeById(
                                      badgeId,
                                    );
                                    if (badge == null) return const SizedBox();
                                    return _buildBadge(
                                      badge.name,
                                      Iconsax.star,
                                      Color(badge.colorValue),
                                    );
                                  }).toList(),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(String? photoUrl) {
    final imageUrl = _newImage ?? photoUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(
        Iconsax.profile_circle,
        color: Colors.white30,
        size: 60,
      );
    }
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBadge(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.4), Colors.black12],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
