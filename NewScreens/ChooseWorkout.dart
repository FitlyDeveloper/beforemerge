import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';

class CodiaPage extends StatefulWidget {
  CodiaPage({super.key});

  @override
  State<StatefulWidget> createState() => _CodiaPage();
}

class _CodiaPage extends State<CodiaPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SizedBox(
        width: 393,
        height: 852,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              width: 393,
              top: 0,
              height: 852,
              child: Image.asset('images/image1_202265.png', width: 393, height: 852, fit: BoxFit.cover,),
            ),
            Positioned(
              left: 135,
              top: 58,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Workout',
                      textAlign: TextAlign.left,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 26, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 30,
              top: 119,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Log Workout',
                      textAlign: TextAlign.left,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 24, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 28,
              width: 338,
              top: 99,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image2_49284.png', width: 338,),
              ),
            ),
            Positioned(
              left: 28,
              width: 338,
              top: 169,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image3_49270.png', width: 338,),
              ),
            ),
            Positioned(
              left: 28,
              width: 338,
              top: 281,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image4_49275.png', width: 338,),
              ),
            ),
            Positioned(
              left: 28,
              width: 338,
              top: 393,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image5_49283.png', width: 338,),
              ),
            ),
            Positioned(
              left: 42,
              top: 187,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image6_49267.png',),
              ),
            ),
            Positioned(
              left: 42,
              top: 299,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image7_49274.png',),
              ),
            ),
            Positioned(
              left: 99,
              top: 192,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Weight Lifting',
                      textAlign: TextAlign.left,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 18, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 99,
              top: 217,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 196,
                      child: Text(
                        'Build strength with machines or free weights',
                        textAlign: TextAlign.left,
                        style: TextStyle(decoration: TextDecoration.none, fontSize: 11, color: const Color(0x82000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 42,
              top: 411,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image8_49282.png',),
              ),
            ),
            Positioned(
              left: 99,
              top: 304,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Running',
                      textAlign: TextAlign.left,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 18, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 99,
              top: 329,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 144,
                      child: Text(
                        'Track your runs, jogs, sprints etc',
                        textAlign: TextAlign.left,
                        style: TextStyle(decoration: TextDecoration.none, fontSize: 11, color: const Color(0x82000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 99,
              top: 416,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'More',
                      textAlign: TextAlign.left,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 18, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 99,
              top: 441,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 112,
                      child: Text(
                        'Create custom exercises',
                        textAlign: TextAlign.left,
                        style: TextStyle(decoration: TextDecoration.none, fontSize: 11, color: const Color(0x82000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                        maxLines: 9999,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 48,
              top: 189,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image9_49266.png',),
              ),
            ),
            Positioned(
              left: 49,
              top: 305,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image10_49271.png',),
              ),
            ),
            Positioned(
              left: -10,
              width: 413,
              bottom: -13,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image11_434140.png', width: 413,),
              ),
            ),
            Positioned(
              left: 30,
              top: 792,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Home',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0x66000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 33,
              top: 759,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image12_434144.png',),
              ),
            ),
            Positioned(
              left: 99,
              top: 792,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Social',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0x66000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 99,
              top: 752,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image13_434149.png',),
              ),
            ),
            Positioned(
              left: 161,
              width: 63,
              top: 792,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Nutrition',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0x66000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 169,
              width: 47,
              top: 756,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image14_434153.png', width: 47,),
              ),
            ),
            Positioned(
              left: 231,
              top: 792,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Workout',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 236,
              top: 749,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image15_434157.png',),
              ),
            ),
            Positioned(
              left: 298,
              width: 77,
              top: 762,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('images/image_434160.png', width: 32, height: 32, fit: BoxFit.cover,),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 27,
                          child: Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0x66000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                            maxLines: 9999,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 52,
              top: 423,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('images/image16_49281.png',),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
