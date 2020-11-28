import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class CircularContacts extends StatelessWidget {
  final Widget image;
  final String name;
  final String atSign;
  final Function onTap;

  const CircularContacts(
      {Key key, this.image, this.name, this.atSign, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 20.toWidth),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 50.toHeight,
                width: 50.toHeight,
                child: image,
                // child:
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onTap,
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
              ),
            ],
          ),
          SizedBox(height: 10.toHeight),
          Container(
            width: 40.toWidth,
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 10.toHeight),
          Container(
            width: 40.toWidth,
            child: Text(
              // provider.contactList[index].atSign,
              atSign,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
