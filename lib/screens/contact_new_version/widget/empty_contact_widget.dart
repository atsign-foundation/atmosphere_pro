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
                padding: const EdgeInsets.only(top: 76),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add contacts to trusted by selecting",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 52, vertical: 12),
                        decoration: BoxDecoration(
                          color: ColorConstants.unbleachedSilk,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Add To Trusted",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.portlandOrange,
                              ),
                            ),
                            SizedBox(width: 16),
                            SvgPicture.asset(
                              AppVectors.icBigTrustActivated,
                              color: ColorConstants.portlandOrange,
                              width: 20,
                              height: 20,
                            ),
                          ],
                        ),
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
