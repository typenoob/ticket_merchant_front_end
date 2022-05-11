import 'package:flutter/material.dart';
import 'package:ticket_merchant/widgets/button.dart';
import 'package:ticket_merchant/widgets/navigation_drawer.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        drawer: const NavigationDrawerWidget(),
        // endDrawer: NavigationDrawerWidget(),
        appBar: AppBar(
          title: const Text("管理员面板"),
        ),
        body: Builder(
          builder: (context) => Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ButtonWidget(
              icon: Icons.open_in_new,
              text: '打开菜单',
              onClicked: () {
                Scaffold.of(context).openDrawer();
                // Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ),
      );
}
