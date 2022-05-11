import 'package:flutter/material.dart';
import 'package:ticket_merchant/screens/admin/station.dart';
import 'package:ticket_merchant/screens/admin/ticket.dart';
import 'package:ticket_merchant/screens/admin/train.dart';
import '../screens/login.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  const NavigationDrawerWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const name = 'admin';
    const email = 'admin@admin.com';
    const urlImage = 'https://www.gravatar.com/avatar/?d=mp';

    return Drawer(
      child: Stack(children: [
        Material(
          color: const Color.fromRGBO(50, 75, 205, 1),
          child: ListView(
            children: <Widget>[
              buildHeader(
                urlImage: urlImage,
                name: name,
                email: email,
                onClicked: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const StationPage(),
                )),
              ),
              Container(
                padding: padding,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    buildMenuItem(
                      text: '车站管理',
                      icon: Icons.railway_alert,
                      onClicked: () => selectedItem(context, 0),
                    ),
                    const SizedBox(height: 16),
                    buildMenuItem(
                      text: '车次管理',
                      icon: Icons.schedule_outlined,
                      onClicked: () => selectedItem(context, 1),
                    ),
                    const SizedBox(height: 16),
                    buildMenuItem(
                      text: '票务管理',
                      icon: Icons.airplane_ticket_outlined,
                      onClicked: () => selectedItem(context, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          child: BackButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
          bottom: 0,
          left: padding.left,
        ),
      ]),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(const EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color.fromRGBO(30, 60, 168, 1),
                child: Icon(Icons.add_comment_outlined, color: Colors.white),
              )
            ],
          ),
        ),
      );

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: const TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const StationPage(),
        ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const TrainPage(),
        ));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const TicketPage(),
        ));
        break;
    }
  }
}
