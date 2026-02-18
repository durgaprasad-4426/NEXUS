import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Screens/HomePage/home_page.dart' show HomePage;
import 'package:nexus/Screens/ProfilePage/profile_page.dart';
import 'package:nexus/Screens/ChatBotPage/bot_screen.dart';
import 'package:nexus/Screens/ProjectHub/projectpage.dart';
import 'package:nexus/Screens/VideoHubScreen/videospage.dart';
import 'package:nexus/Screens/settings.dart';


class NavigationsBar extends StatefulWidget {
  final String uid;
  const NavigationsBar({super.key,required this.uid});

  @override
  State<NavigationsBar> createState() => _NavigationsBarState();
}

class _NavigationsBarState extends State<NavigationsBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    Videospage(),
    ChatScreen(),
    ProjectPage(),
    // Placeholder(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraint) {

      if (constraint.maxWidth >= 600) {
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                minWidth: 150,
                groupAlignment: 0.0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Nexus",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_)=>NexusSettingsScreen()));
                  },
                ),
                elevation: 5,
                backgroundColor: Colors.black,
                labelType: NavigationRailLabelType.all,
                selectedLabelTextStyle: const TextStyle(
                    color: Color.fromARGB(255, 255, 206, 223)),
                unselectedIconTheme:
                    const IconThemeData(color: Colors.blueGrey),
                selectedIconTheme: const IconThemeData(color: Colors.pinkAccent),
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Iconsax.home4), label: Text("Home")),
                  NavigationRailDestination(
                      icon: Icon(Iconsax.video), label: Text("Learn")),
                  NavigationRailDestination(
                      icon: Icon(Iconsax.message), label: Text("Bot")),
                  NavigationRailDestination(
                      icon: Icon(Icons.work_outline_outlined),
                      label: Text("ProjectHub")),
                  NavigationRailDestination(
                      icon: Icon(Iconsax.profile_circle), label: Text("Profile")),
                ],
                selectedIndex: _selectedIndex,
              ),
              Expanded(child: _pages[_selectedIndex]),
            ],
          ),
        );
      }

      return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: ConvexAppBar(
          backgroundColor: Colors.black,
          activeColor: Colors.pinkAccent,
          color: Colors.white,
          initialActiveIndex: _selectedIndex,
          items: const [
            TabItem(icon: Iconsax.home4, title: "Home"),
            TabItem(icon: Iconsax.video, title: "Learn"),
            TabItem(icon: Iconsax.message, title: "Bot"),
            TabItem(icon: Icons.work, title: "ProjectHub"),
            TabItem(icon: Iconsax.profile_circle, title: "Profile"),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      );
    });
  }
}



