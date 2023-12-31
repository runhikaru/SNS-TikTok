import 'package:flutter/material.dart';
import 'package:firebase_tiktok_clone/constants.dart';
import 'package:firebase_tiktok_clone/views/widgets/custom_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (idx) {
          setState(() {
            pageIdx = idx;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white,
        currentIndex: pageIdx,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'ホーム',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.search, size: 30),
          //   label: '検索',
          // ),
          BottomNavigationBarItem(
            icon: CustomIcon(),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.message, size: 30),
          //   label: 'メッセージ',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'プロフィール',
          ),
        ],
      ),
      body: pages[pageIdx],
    );
  }
}
