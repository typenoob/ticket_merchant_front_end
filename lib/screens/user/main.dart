import 'package:flutter/material.dart';
import 'home.dart';
import 'order.dart';
import 'passenger.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _bottomNavPages = []; // 底部导航栏各个可切换页面组

  @override
  void initState() {
    super.initState();
    _bottomNavPages
      ..add(const PageHome('首页'))
      ..add(PageOrder('订单'))
      ..add(const PagePassenger('乘客'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bottomNavPages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '订单'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '乘客'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
