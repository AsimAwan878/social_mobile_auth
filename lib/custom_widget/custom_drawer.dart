import 'package:during_interview/views/screens/home_screen.dart';
import 'package:during_interview/views/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  void share(BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    const text = "Hey, Check out Easy Plane";
    Share.share(text,
        subject: 'Easy_plane',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  final List<String> _svgAssets = <String>[
    'assets/images/Share.svg',
    'assets/images/Logout.svg',
  ];

  final List<Map> _drawerData = [
    {
      'icon': 'assets/images/Share.svg',
      'iconText': "Share App",
    },
    {
      'icon': 'assets/images/Logout.svg',
      'iconText': "Logout",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        width: sizeWidth(context) / 1.4,
        child: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: sizeHeight(context) / 1.8,
                child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _drawerData.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _drawerData[index]['isShare'] == 'yes'
                              ? Share.share('check out our app Easy Plan.')
                              : logout();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
                                child: SvgPicture.asset(
                                  _svgAssets[index],
                                  color: primaryColor,
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              Text(
                                _drawerData[index]["iconText"].toUpperCase(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("isLoggedIn", false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }
}
