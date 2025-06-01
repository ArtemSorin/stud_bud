import 'package:flutter/material.dart';
import 'package:stud_bud/screens/chat_list_screen.dart';
import 'package:stud_bud/screens/create_post_screen.dart';
import 'package:stud_bud/screens/feed_screen.dart';
import 'package:stud_bud/screens/settings_screen.dart';
import 'package:stud_bud/screens/user_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FeedScreen(),
    ChatListScreen(),
    ProfilePage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true && _currentIndex == 0 && _screens[0] is FeedScreen) {
      setState(() {
        _screens[0] = FeedScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'StudBud',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          const Icon(Icons.notifications, color: Colors.black),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.door_front_door, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () => _onTabTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.black),
              onPressed: () => _onTabTapped(1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.black),
              onPressed: () => _onTabTapped(2),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () => _onTabTapped(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
