import 'package:atsign_atmosphere_pro/data_models/enums/contact_type.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyContactsWidget extends StatelessWidget {
  final ListContactType? contactsType;
  final Function() onTapAddButton;

  const EmptyContactsWidget({
    Key? key,
    this.contactsType,
    required this.onTapAddButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return contactsType == ListContactType.groups ||
            contactsType == ListContactType.contact
        ? _buildEmptyImage()
        : contactsType == ListContactType.trusted
            ? Padding(
                padding: const EdgeInsets.only(top: 100),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add contacts to trusted by",
                        style: TextStyle(
                          fontSize: 18,
                          color: ColorConstants.grey,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "selecting",
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorConstants.grey,
                            ),
                          ),
                          SvgPicture.asset(
                            AppVectors.icBigTrustActivated,
                          ),
                          Text(
                            "next to their name!",
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorConstants.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: 122,
                        width: 226,
                        child: Image.asset(
                          ImageConstants.emptyBox,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          "No Contacts",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }

  Widget _buildEmptyImage() {
    return Center(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 122,
              width: 226,
              child: Image.asset(
                ImageConstants.emptyBox,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                contactsType == ListContactType.groups
                    ? "No Groups"
                    : "No Contacts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.grey,
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(46),
              onTap: onTapAddButton,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorConstants.orange,
                  borderRadius: BorderRadius.circular(46),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                child: Text(
                  contactsType == ListContactType.groups
                      ? "Add Group"
                      : "Add Contact",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
