import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import 'encyclopedia_screen.dart';
import 'home_screen.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  Color backgroundColor = const Color(0xffe9edf1);
  Color secondaryColor = const Color(0xffe1e6ec);
  Color accentColor = const Color(0xff2d5765);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: CurvedNavigationBar(
        onTap: (index) {
          //todo implement transition to other screens
          // print(index);
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Encyclopedia(),
              ),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
          if (index == 2) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => AppInfoScreen(),
            //   ),
            // );
          }
        },
        index: 2,
        backgroundColor: backgroundColor,
        color: secondaryColor,
        buttonBackgroundColor: backgroundColor,
        animationDuration: const Duration(
          milliseconds: 300,
        ),
        items: [
          NeumorphicIcon(
            Icons.menu_book_rounded,
            style: NeumorphicStyle(
              color: accentColor,
              intensity: 20,
            ),
          ),
          NeumorphicIcon(
            Icons.home_rounded,
            style: NeumorphicStyle(
              color: accentColor,
              intensity: 20,
            ),
          ),
          NeumorphicIcon(
            Icons.info_rounded,
            style: NeumorphicStyle(
              color: accentColor,
              intensity: 20,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/agrolabicon.svg',
                        width: 45,
                        height: 45,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          "AgroLab",
                          style: TextStyle(
                            fontFamily: 'intan',
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: [
                      Neumorphic(),
                      LottieBuilder.asset(
                        'assets/58375-plantas-y-hojas.json',
                        height: 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Neumorphic(
                                margin: const EdgeInsets.only(
                                  left: 20,
                                ),
                                style: NeumorphicStyle(
                                  border: NeumorphicBorder(
                                    color: accentColor,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const Image(
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/abrar.jpg'),
                                  ),
                                ),
                              ),
                              Container(
                                width: 150,
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  left: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 5,
                                      ),
                                      child: NeumorphicText(
                                        'Md. Abrar',
                                        style: const NeumorphicStyle(
                                          color: Colors.black,
                                        ),
                                        textStyle: NeumorphicTextStyle(
                                          fontSize: 12,
                                          fontFamily: 'intan',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            String surl = 'https://www.linkedin.com/in/mohammad-abrar-a75523275/';
                                            Uri url = Uri.parse(surl);
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/linkedin.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            String surl = 'https://github.com/AbrarChhipa';
                                            Uri url = Uri.parse(surl);
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          },
                                          child: SvgPicture.asset(
                                            'assets/github.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Neumorphic(
                                margin: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                ),
                                style: NeumorphicStyle(
                                  border: NeumorphicBorder(
                                    color: accentColor,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const Image(
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/narendra.jpg'),
                                  ),
                                ),
                              ),
                              Container(
                                width: 150,
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  left: 20,
                                  right: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        right: 9,
                                      ),
                                      child: NeumorphicText(
                                        'Narendra Patel',
                                        style: const NeumorphicStyle(
                                          color: Colors.black,
                                        ),
                                        textStyle: NeumorphicTextStyle(
                                          fontSize: 12,
                                          fontFamily: 'intan',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            String surl = 'https://www.linkedin.com/in/narendra-patel-174985228/';
                                            Uri url = Uri.parse(surl);
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          },
                                          child: SvgPicture.asset(
                                            'assets/linkedin.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Neumorphic(
                            margin: const EdgeInsets.only(
                              top: 20,
                              left: 20,
                            ),
                            style: NeumorphicStyle(
                              border: NeumorphicBorder(
                                color: accentColor,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const Image(
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                image: AssetImage('assets/samandh.jpg'),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                              left: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: NeumorphicText(
                                    'Samandh Prajapat',
                                    style: const NeumorphicStyle(
                                      color: Colors.black,
                                    ),
                                    textStyle: NeumorphicTextStyle(
                                      fontSize: 12,
                                      fontFamily: 'intan',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        String surl = 'https://www.linkedin.com/in/samandhprajapat/';
                                        Uri url = Uri.parse(surl);
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/linkedin.svg',
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      Neumorphic(
                        padding: const EdgeInsets.all(
                          10,
                        ),
                        margin: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About AgroLab.co',
                              style: TextStyle(
                                fontFamily: 'intan',
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                              ),
                              child: const Text(
                                'AgroLab was created as part of our final year project work during the final year of our B.Tech. course.\n\nAgroLab was developed with an intention to reduce the time taken to identify various plant diseases with a high detection accuracy. Early detection and counter measures will help prevent large scale losses to the farmers, also improving crop productivity.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(
                          top: 20,
                          left: 20,
                        ),
                        child: SvgPicture.asset(
                          'assets/made-with-love-in-india.svg',
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.only(
                              top: 10,
                              left: 20,
                            ),
                            child: SvgPicture.asset(
                              'assets/flutter.svg',
                              width: 100,
                              height: 35,
                            ),
                          ),
                          Container(
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                            ),
                            child: SvgPicture.asset(
                              'assets/tensorflow.svg',
                              width: 100,
                              height: 35,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
