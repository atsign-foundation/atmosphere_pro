/// This widget is a list tile to display contacts selected for sharing
/// it takes [onlyRemovemethod] as a boolean with default value as [false]
/// if [true] trailing icon remains [close] icon [onAdd] method is disabled
/// all [isSelected] functionalities are disabled

import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactListTile extends StatefulWidget {
  final String? name;
  final String? atSign;
  final Widget? image;
  final Function onAdd;
  final Function onRemove;
  final bool isSelected;
  final bool onlyRemoveMethod;
  final Function? onTileTap;
  final bool plainView;

  const ContactListTile(
      {Key? key,
      this.name,
      this.atSign,
      this.image,
      required this.onAdd,
      required this.onRemove,
      this.isSelected = false,
      this.onlyRemoveMethod = false,
      this.plainView = false,
      this.onTileTap})
      : super(key: key);

  @override
  _ContactListTileState createState() => _ContactListTileState();
}

class _ContactListTileState extends State<ContactListTile> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.toWidth,
        12.toHeight,
        14.toWidth,
        12.toHeight,
      ),
      margin: EdgeInsets.only(bottom: 10.toHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorConstants.textBoxBg,
        ),
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                18,
              ),
            ),
            child: widget.image,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.atSign ?? '',
                  style: TextStyle(
                    fontSize: 14.toFont,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  widget.name ?? '',
                  style: TextStyle(
                    fontSize: 12.toFont,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () {
              widget.onRemove.call();
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SvgPicture.asset(
                AppVectors.icClose,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
