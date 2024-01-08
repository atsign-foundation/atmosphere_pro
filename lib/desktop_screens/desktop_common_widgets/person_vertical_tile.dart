import 'dart:typed_data';

import 'package:at_contacts_flutter/at_contacts_flutter.dart';
import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/contact_initial.dart';
import 'package:atsign_atmosphere_pro/screens/common_widgets/triple_dot_loading.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';

// import 'package:atsign_atmosphere_pro/services/size_config.dart' ;
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/view_models/file_transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomPersonVerticalTile extends StatefulWidget {
  final ShareStatus shareStatus;
  final bool isFailedAtSignList;
  final FileHistory? fileHistory;
  @override
  final Key? key;

  CustomPersonVerticalTile(
      {this.key,
      required this.shareStatus,
      required this.fileHistory,
      this.isFailedAtSignList = false});

  @override
  _CustomPersonVerticalTileState createState() =>
      _CustomPersonVerticalTileState();
}

class _CustomPersonVerticalTileState extends State<CustomPersonVerticalTile> {
  Uint8List? image;
  String? contactName;

  @override
  void initState() {
    super.initState();
    getAtSignImage();
  }

  // ignore: always_declare_return_types
  getAtSignImage() async {
    if (widget.shareStatus.atsign == null) return;
    var contact = await getAtSignDetails(widget.shareStatus.atsign!);

    // ignore: unnecessary_null_comparison
    if (contact != null) {
      if (mounted) {
        setState(() {
          image = CommonUtilityFunctions().getContactImage(contact);
        });
      }

      if (contact.tags != null && contact.tags!['name'] != null) {
        if (mounted) {
          setState(() {
            contactName = contact.tags!['name'];
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Stack(
                children: [
                  SizedBox(
                    height: 50.toHeight,
                    width: 50.toHeight,
                    child: image != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.toFont)),
                            child: Image.memory(
                              image!,
                              width: 50.toFont,
                              height: 50.toFont,
                              fit: BoxFit.fill,
                              errorBuilder: (BuildContext _context, _, __) {
                                return Container(
                                  child: Icon(
                                    Icons.image,
                                    size: 30.toFont,
                                  ),
                                );
                              },
                            ),
                          )
                        : ContactInitial(
                            initials: widget.shareStatus.atsign ?? ' ',
                          ),
                  ),
                  widget.isFailedAtSignList
                      ? Positioned(
                          child: Container(
                          height: 50.toHeight,
                          width: 50.toHeight,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50.toWidth),
                          ),
                          child: InkWell(
                            onTap: () async {
                              print(
                                  'selectedFileHistory : ${widget.fileHistory!.fileTransferObject!.transferId}, atSign: ${widget.shareStatus.atsign}');

                              await Provider.of<FileTransferProvider>(context,
                                      listen: false)
                                  .reSendFileNotification(widget.fileHistory!,
                                      widget.shareStatus.atsign!);
                            },
                            child: widget.shareStatus.isSendingNotification!
                                ? TypingIndicator(showIndicator: true)
                                : Icon(Icons.refresh,
                                    color: Colors.white, size: 30.toHeight),
                          ),
                        ))
                      : SizedBox(),
                ],
              ),
            ],
          ),
          SizedBox(height: 2),
          contactName != null
              ? SizedBox(
                  width: 100.toFont,
                  child: Text(
                    contactName!,
                    style: CustomTextStyles.grey15,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                )
              : SizedBox(),
          SizedBox(height: 2),
          widget.shareStatus.atsign != null
              ? SizedBox(
                  width: 100.toFont,
                  child: Text(
                    widget.shareStatus.atsign!,
                    style: CustomTextStyles.grey13,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                )
              : SizedBox(),
          SizedBox(height: 2),
        ],
      ),
    );
  }
}
