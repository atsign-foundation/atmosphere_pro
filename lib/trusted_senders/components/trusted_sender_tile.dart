import 'package:flutter/material.dart';
import 'pop_up.dart';

class TrustedSenderTile extends StatelessWidget {
  final String atSign;
  final String name;
  const TrustedSenderTile({required this.atSign, required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9.0),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => PopUp(atSign: atSign),
          );
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 65),
          height: 65,
          width: 170,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            border: Border.all(
              color: const Color(0xFFF2F2F2),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  // fit: StackFit.passthrough,
                  alignment: AlignmentDirectional.center,
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage(
                        "assets/images/placeholder_image.png",
                      ),
                      radius: 18,
                    ),
                    Positioned(
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 23.5, right: 25.0),
                        child: const ImageIcon(
                          AssetImage("assets/images/verified_icon.png"),
                          color: Color(0xFFF07C50),
                          size: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 7.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atSign,
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 10.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
