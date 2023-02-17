/// This widget is a list tile to display contacts selected for sharing
/// it takes [onlyRemovemethod] as a boolean with default value as [false]
/// if [true] trailing icon remains [close] icon [onAdd] method is disabled
/// all [isSelected] functionalities are disabled

import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/images.dart';

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: (widget.onlyRemoveMethod)
            ? () {
                widget.onTileTap!();
              }
            : () {
                setState(() {
                  selected = !selected;
                  !selected ? widget.onRemove() : widget.onAdd();
                });
              },
        title: Text(
          widget.atSign!,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.toFont,
            letterSpacing: 0.1,
            fontWeight: FontWeight.normal,
          ),
        ),
        subtitle: Text(
          widget.name!,
          style: TextStyle(
            color: ColorConstants.fadedText,
            fontSize: 14.toFont,
            letterSpacing: 0.1,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: (widget.plainView)
            ? SizedBox()
            : (widget.isSelected)
                ? GestureDetector(
                    onTap: () {
                      widget.onRemove();
                    },
                    child: SvgPicture.asset(
                      AppVectors.icClose,
                    ),
                  )
                : Icon(
                    Icons.add,
                    color: Colors.black,
                  ),
        leading: Stack(
          children: [
            Container(
              height: 40.toHeight,
              width: 40.toHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: widget.image,
            ),
          ],
        ),
      ),
    );
  }
}
