import 'package:flutter/material.dart';
import 'favorites_page.dart';
import 'recipes_page.dart';
import 'upload_page.dart';
import 'profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RecipesPage(),
    FavoritesPage(),
    UploadPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: "Recipes",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: "Favorites",
          ),
          NavigationDestination(
            icon: Icon(Icons.upload_outlined),
            label: "Upload",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
