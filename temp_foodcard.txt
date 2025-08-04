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
        height: 1407,
        child: Stack(
          children: [
            Positioned(
              left: 72,
              width: 31,
              top: 316,
              height: 14,
              child: Text(
                '12:07',
                textAlign: TextAlign.center,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 149,
              width: 98,
              top: 1338,
              height: 24,
              child: Text(
                'Save',
                textAlign: TextAlign.center,
                style: TextStyle(decoration: TextDecoration.none, fontSize: 20, color: const Color(0xffffffff), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                maxLines: 9999,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 1407,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 276,
                    height: 854,
                    child: Image.asset('images/image1_138628.png', height: 854, fit: BoxFit.cover,),
                  ),
                  Positioned(
                    left: -10,
                    top: -10,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image2_473384.png',),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    top: 283,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image3_473383.png',),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    width: 39,
                    top: 66,
                    height: 39,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 3, top: 2, right: 3, bottom: 2),
                      child: Image.asset('images/image4_473321.png', width: 39, height: 39,),
                    ),
                  ),
                  Positioned(
                    left: 318,
                    width: 39,
                    top: 66,
                    height: 39,
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset('images/image5_473323.png', width: 39, height: 39,),
                    ),
                  ),
                  Positioned(
                    left: 271,
                    width: 39,
                    top: 66,
                    height: 39,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6, top: 5, right: 6, bottom: 5),
                      child: Image.asset('images/image6_473322.png', width: 39, height: 39,),
                    ),
                  ),
                  Positioned(
                    left: 38,
                    top: 313,
                    child: Image.asset('images/image7_473325.png',),
                  ),
                  Positioned(
                    left: 275,
                    top: 310,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset('images/image1_19135.png', width: 25, height: 25, fit: BoxFit.cover,),
                        SizedBox(
                          width: 31,
                          height: 24,
                          child: Text(
                            '1',
                            textAlign: TextAlign.center,
                            style: TextStyle(decoration: TextDecoration.none, fontSize: 20, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                            maxLines: 9999,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Image.asset('images/image2_19134.png', width: 25, height: 25, fit: BoxFit.cover,),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 38,
                    width: 135,
                    top: 821,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Ingredients',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 26, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 238),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'More',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 26, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
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
                    left: 38,
                    width: 318,
                    top: 503,
                    child: Image.asset('images/image8_473364.png', width: 318,),
                  ),
                  Positioned(
                    left: 38,
                    width: 318,
                    top: 872,
                    child: Image.asset('images/image9_473371.png', width: 318,),
                  ),
                  Positioned(
                    left: 99,
                    width: 243,
                    top: 770,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 109,
                    width: 223,
                    top: 755,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Health Score',
                          textAlign: TextAlign.left,
                          style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 104),
                        Text(
                          '8/10',
                          textAlign: TextAlign.left,
                          style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                          maxLines: 9999,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 66,
                    width: 91,
                    top: 880,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Cheesecake',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  '100g',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  '300 kcal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
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
                    left: 87,
                    width: 49,
                    top: 985,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Jam',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  '10g',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  '20 kcal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
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
                    left: 256,
                    width: 52,
                    top: 880,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Berries',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  '20g',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  '10 kcal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
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
                    left: 256,
                    width: 56,
                    top: 655,
                    height: 14,
                    child: Text(
                      'Carbs',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 256,
                    width: 56,
                    top: 673,
                    height: 12,
                    child: Container(
                      width: 56,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 255,
                    width: 58,
                    top: 689,
                    height: 13,
                    child: Text(
                      '125g',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 11, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 136,
                    width: 121,
                    top: 520,
                    height: 121,
                    child: Image.asset('images/image10_19151.png', width: 121, height: 121,),
                  ),
                  Positioned(
                    left: 169,
                    width: 56,
                    top: 655,
                    height: 14,
                    child: Text(
                      'Fat',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 169,
                    width: 56,
                    top: 673,
                    height: 12,
                    child: Container(
                      width: 56,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 169,
                    width: 56,
                    top: 689,
                    height: 13,
                    child: Text(
                      '32g',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 11, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 99,
                    width: 22,
                    top: 689,
                    height: 13,
                    child: Text(
                      '30g',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 11, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 82,
                    width: 56,
                    top: 655,
                    height: 10,
                    child: Text(
                      'Protein',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 84,
                    width: 56,
                    top: 673,
                    height: 12,
                    child: Container(
                      width: 56,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 169,
                    width: 54,
                    top: 563,
                    height: 21,
                    child: Text(
                      '500',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 18, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 169,
                    width: 54,
                    top: 584,
                    height: 14,
                    child: Text(
                      'Calories',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 12, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 45,
                    top: 742,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image11_473362.png',),
                    ),
                  ),
                  Positioned(
                    left: 267,
                    width: 30,
                    top: 985,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Add',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Image.asset('images/image_383248.png', height: 30, fit: BoxFit.cover,),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 38,
                    width: 318,
                    top: 1141,
                    child: Image.asset('images/image12_473372.png', width: 318,),
                  ),
                  Positioned(
                    left: 90,
                    top: 1190,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image13_473377.png',),
                    ),
                  ),
                  Positioned(
                    left: 88,
                    top: 1136,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image14_473378.png',),
                    ),
                  ),
                  Positioned(
                    left: 137,
                    width: 122,
                    top: 1151,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'In-Depth Nutrition ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 33),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Fix Manually',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 33),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Fix with AI',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
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
                    left: 89,
                    top: 1241,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image15_473376.png',),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    width: 393.423,
                    top: 1309,
                    height: 97.887,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 29, top: 14, right: 29, bottom: 14),
                      child: Image.asset('images/image16_473379.png', width: 393.423, height: 97.887,),
                    ),
                  ),
                  Positioned(
                    left: 39,
                    width: 175,
                    top: 351,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Delicious Cake',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 26, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Bold', fontWeight: FontWeight.normal),
                                  maxLines: 9999,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: Text(
                                  'Rusty Pelican is so good',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
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
                    left: 39,
                    width: 316,
                    top: 430,
                    child: Image.asset('images/image17_473357.png', width: 316,),
                  ),
                  Positioned(
                    left: 59,
                    top: 431,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image18_473353.png',),
                    ),
                  ),
                  Positioned(
                    left: 176,
                    top: 435,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image19_473355.png',),
                    ),
                  ),
                  Positioned(
                    left: 289,
                    top: 435,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('images/image20_473356.png',),
                    ),
                  ),
                  Positioned(
                    left: 98,
                    width: 25,
                    top: 448,
                    height: 23,
                    child: Text(
                      '2',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    left: 210,
                    width: 25,
                    top: 448,
                    height: 23,
                    child: Text(
                      '2',
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.none, fontSize: 16, color: const Color(0xff000000), fontFamily: 'SFProDisplay-Regular', fontWeight: FontWeight.normal),
                      maxLines: 9999,
                      overflow: TextOverflow.ellipsis,
                    ),
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
