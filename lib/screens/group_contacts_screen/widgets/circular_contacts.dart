import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class CircularContacts extends StatelessWidget {
  final Widget image;
  final String name;
  final String atSign;
  final Function onCrossPressed;
  final bool showCross;
  final Function onTap;

  const CircularContacts(
      {Key key,
      this.image,
      this.name,
      this.atSign,
      this.onCrossPressed,
      this.showCross = true,
      this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? onTap : () {},
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 20.toWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                Container(
                  height: 50.toHeight,
                  width: 50.toHeight,
                  child: image,
                  // child:
                ),
                (showCross)
                    ? Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: onCrossPressed,
                          child: Container(
                            height: 12.toHeight,
                            width: 12.toHeight,
                            decoration: BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                            child: Icon(
                              Icons.close,
                              size: 10.toHeight,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(height: 10.toHeight),
            Container(
              width: 80.toWidth,
              child: Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 10.toHeight),
            Container(
              width: 60.toWidth,
              child: Text(
                // provider.contactList[index].atSign,
                atSign, textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
