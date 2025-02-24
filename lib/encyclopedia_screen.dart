import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
// ignore: unnecessary_import
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_info_screen.dart';
import 'home_screen.dart';

class Encyclopedia extends StatefulWidget {
  const Encyclopedia({super.key});

  @override
  State<Encyclopedia> createState() => _EncyclopediaState();
}

class _EncyclopediaState extends State<Encyclopedia> {
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
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => Encyclopedia(),
            //   ),
            // );
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AppInfoScreen(),
              ),
            );
          }
        },
        index: 0,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(
                          'assets/agrolabicon.svg',
                          width: 45,
                          height: 45,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
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
              LottieBuilder.asset(
                'assets/58375-plantas-y-hojas.json',
                width: 400,
                height: 100,
              ),
              GestureDetector(
                  onTap: () async {
                    String surl = 'https://www.agrifarming.in/honey-bee-farming-information-guide';
                    Uri url = Uri.parse(surl);
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                      height: 100,
                      width: 350,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 2,
                            color: Colors.black,
                          ),
                          image: const DecorationImage(
                            alignment: Alignment.centerLeft,
                            image: AssetImage('assets/bee.jpg'),
                          )),
                      padding: const EdgeInsets.only(left: 130, top: 10),
                      child: Container(
                        height: 90,
                        width: 200,
                        alignment: const Alignment(1.0, -1.0),
                        child: const Text(
                          'Increase production 3 times with bee pollination in farming with all organic cycles, improve quality and quantity',
                          style: TextStyle(fontFamily: 'intan', fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ))),
              //tabs
              const SizedBox(height: 10),
              Container(
                  height: 100,
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 2,
                        color: Colors.black,
                      ),
                      image: const DecorationImage(
                        alignment: Alignment.centerLeft,
                        image: AssetImage('assets/erice.jpg'),
                      )),
                  padding: const EdgeInsets.only(left: 130, top: 10),
                  child: Container(
                    height: 90,
                    width: 200,
                    alignment: const Alignment(1.0, -1.0),
                    child: const Text(
                      'Regenerative Agriculture: Imaginary or Future of Farming? New Agro-Ecosystem of Agriculture',
                      style: TextStyle(fontFamily: 'intan', fontSize: 17, fontWeight: FontWeight.w500),
                    ),
                  )),
              //tabs
              const SizedBox(height: 10),
              GestureDetector(
                  onTap: () async {
                    String surl = 'https://www.india.gov.in/spotlight/soil-health-card#tab=tab-1';
                    Uri url = Uri.parse(surl);
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                      height: 100,
                      width: 350,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 2,
                            color: Colors.black,
                          ),
                          image: const DecorationImage(
                            alignment: Alignment.centerLeft,
                            image: AssetImage('assets/farmer.jpg'),
                          )),
                      padding: const EdgeInsets.only(
                        left: 130,
                        top: 10,
                      ),
                      child: Container(
                        height: 90,
                        width: 200,
                        alignment: const Alignment(1.0, -1.0),
                        child: const Text(
                          'Farmers are eager to use new methods for soil reconstruction to learn how they can test and improve soil quality',
                          style: TextStyle(fontFamily: 'intan', fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ))),
              //tabs
              const SizedBox(height: 10),
              GestureDetector(
                  onTap: () async {
                    String surl = 'https://economictimes.indiatimes.com/news/new-updates/pm-modi-releases-13th-instalment-of-pm-kisan-check-for-more-details/articleshow/98263818.cms';
                    Uri url = Uri.parse(surl);
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                      height: 100,
                      width: 350,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            width: 2,
                            color: Colors.black,
                          ),
                          image: const DecorationImage(
                            alignment: Alignment.centerLeft,
                            image: AssetImage('assets/farmg.jpg'),
                          )),
                      padding: const EdgeInsets.only(left: 135, top: 10),
                      child: Container(
                        height: 90,
                        width: 200,
                        alignment: const Alignment(1.0, -1.0),
                        child: const Text(
                          'Latest PM-KISAN installment released; How beneficiaries can check status online',
                          style: TextStyle(fontFamily: 'intan', fontWeight: FontWeight.w600),
                        ),
                      ))),
              //tabs
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  String surl = 'https://www.fert.nic.in/fertilizer-movement-shipping';
                  Uri url = Uri.parse(surl);
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
                child: Container(
                    height: 100,
                    width: 350,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          width: 2,
                          color: Colors.black,
                        ),
                        image: const DecorationImage(
                          alignment: Alignment.centerLeft,
                          image: AssetImage('assets/pest.jpg'),
                        )),
                    padding: const EdgeInsets.only(left: 140, top: 10),
                    child: Container(
                      height: 90,
                      width: 200,
                      alignment: const Alignment(1.0, -1.0),
                      child: const Text(
                        'Breaking News: Process begins to normalize, connect and automate fertilizer distribution',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontFamily: 'intan', fontWeight: FontWeight.w600),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
