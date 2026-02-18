
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nexus/Screens/settings.dart';

class HeaderBar extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const HeaderBar({super.key, this.controller, this.onChanged});

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  bool showMobileSearch = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                        width: 38,
                        height: 38,
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
              SizedBox(width: 8),
              Text(
                'Nexus',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Spacer(),
          if (!isMobile || showMobileSearch)
            Expanded(
              flex: 2,
              child: Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurpleAccent]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    width: 2, color: Colors.purpleAccent
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.shade900,
                      spreadRadius: 5,
                      blurRadius: 5
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        onChanged: widget.onChanged,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          border: InputBorder.none,
                        ),
                        autofocus: isMobile,
                      ),
                    ),
                    if (isMobile)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 12,),
                        onPressed: () {
                          setState(() {
                            showMobileSearch = false;
                            widget.controller?.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  showMobileSearch = true;
                });
              },
            ),
            if(isMobile)
            IconButton(
              icon: Icon(Iconsax.setting_2),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NexusSettingsScreen(),
                          ),
                        );
                      },),
        ],
      ),
    );
  }
}
