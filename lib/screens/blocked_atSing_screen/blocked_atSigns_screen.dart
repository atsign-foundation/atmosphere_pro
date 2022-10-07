import 'package:flutter/material.dart';
import 'components/unblock_button.dart';
import 'components/close_pill_button.dart';
import 'components/search_field.dart';

class BlockedAtSignsScreen extends StatelessWidget {
  const BlockedAtSignsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blockedData = [
      '@airplanes45',
      '@bikes13',
      '@cars69',
    ];

    return Container(
      color: Colors.transparent,
      child: Container(
        height: 780.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 61,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 38),
                    child: Container(
                      height: 2.0,
                      width: 45,
                      color: Colors.black,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: ClosePillButton(),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Blocked atSigns',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              Container(
                height: 95,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            'Refresh',
                            style: TextStyle(
                              color: Color(0xFFA4A4A5),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 10.58),
                          Text(
                            'Search',
                            style: TextStyle(
                              color: Color(0xFFA4A4A5),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // tap function here
                            },
                            child: Container(
                              height: 48.0,
                              width: 48.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF939393),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const ImageIcon(
                                AssetImage("assets/images/confirm_icon.png"),
                                color: Color(0xFF939393),
                                size: 16.68,
                              ),
                            ),
                          ),
                          const SizedBox(width: 23.0),
                          const SearchField(
                              height: 48.0,
                              width: 265.0,
                              label: 'Search History by atSign')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 27.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.5),
                child: Container(
                  height: 37.0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 24.0),
                      const Text(
                        'atSign',
                        style: TextStyle(
                          color: Color(0xFFA4A4A5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5.67),
                      GestureDetector(
                        onTap: () {
                          // tap function here
                        },
                        child: const ImageIcon(
                          AssetImage("assets/images/path_icon.png"),
                          color: Color(0xFFA4A4A5),
                          size: 13.33,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: blockedData.length,
                itemBuilder: (BuildContext context, int index) {
                  final blocked = blockedData[index];
                  return Container(
                    height: 50.0,
                    padding: const EdgeInsets.only(left: 19.0, right: 48.0),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                              color: Color(0xFFF2F2F2),
                            )
                        )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          blocked,
                          style: const TextStyle(
                            color: Color(0xFF414141),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        UnblockButton(atSign: blocked),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
