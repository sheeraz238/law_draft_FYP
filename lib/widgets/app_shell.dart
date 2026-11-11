import 'package:flutter/material.dart';
import '../screens/placeholder_screen.dart';
import '../screens/draft_library_screen.dart';
import '../services/auth_service.dart';
import '../screens/profile_screen.dart';
import '../screens/case_law_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/inheritance_screen.dart';
import '../screens/property_tax_screen.dart';
import '../screens/about_screen.dart';
import '../screens/history_screen.dart';
import '../screens/ask_ai_screen.dart';
import '../screens/guides_screen.dart';

class NavItem {
  final String title;
  final IconData icon;
  const NavItem(this.title, this.icon);
}

const navItems = [
  NavItem('Draft Library', Icons.menu_book_outlined),
  NavItem('Legal Guides', Icons.route_outlined),
  NavItem('Ask AI', Icons.auto_awesome),
  NavItem('Case Laws', Icons.description_outlined),
  NavItem('Property Tax Calc', Icons.apartment_outlined),
  NavItem('Inheritance Calc', Icons.calculate_outlined),
  NavItem('Favorites', Icons.star_border),
  NavItem('My Drafts', Icons.history),
  NavItem('Profile', Icons.person_outline),
  NavItem('About', Icons.balance_outlined),
];

class AppShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AppShell({super.key, required this.onToggleTheme});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  // jo pages pehli baar khul chuke hain (zinda rakhe jayenge)
  final Set<int> _visited = {0};
  // jin pages ko har baar taaza data chahiye (Favorites, My Drafts, Profile)
  bool _isFresh(int i) =>
      const {'Favorites', 'My Drafts', 'Profile'}.contains(navItems[i].title);

  Widget _screenFor(int i) {
    switch (i) {
      case 0:
        return const DraftLibraryScreen();
      case 1:
        return const GuidesScreen();
      case 2:
        return const AskAiScreen();
      case 3:
        return const CaseLawScreen();
      case 4:
        return const PropertyTaxScreen();
      case 5:
        return const InheritanceScreen();
      case 6:
        return const FavoritesScreen();
      case 7:
        return const HistoryScreen();
      case 8:
        return const ProfileScreen();
      case 9:
        return const AboutScreen();
      default:
        return PlaceholderScreen(title: navItems[i].title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    final body = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < navItems.length; i++)
          if (_isFresh(i))
            (i == _index ? _screenFor(i) : const SizedBox.shrink())
          else
            (_visited.contains(i) ? _screenFor(i) : const SizedBox.shrink()),
      ],
    );
    final appBar = AppBar(
      title: Text(navItems[_index].title),
      actions: [
        IconButton(
          icon: const Icon(Icons.brightness_6),
          onPressed: widget.onToggleTheme,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            AskAiScreen.clearChat();
            AuthService().signOut();
          },
        ),
      ],
    );

    if (wide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() {
                _index = i;
                _visited.add(i);
              }),
              destinations: [
                for (final n in navItems)
                  NavigationRailDestination(
                    icon: Icon(n.icon),
                    label: Text(n.title),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: ListView(
          children: [
            for (var i = 0; i < navItems.length; i++)
              ListTile(
                leading: Icon(navItems[i].icon),
                title: Text(navItems[i].title),
                selected: i == _index,
                onTap: () {
                  setState(() {
                    _index = i;
                    _visited.add(i);
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: body,
    );
  }
}
