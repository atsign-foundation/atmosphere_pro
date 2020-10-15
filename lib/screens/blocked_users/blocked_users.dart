import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_circle_avatar.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';

class BlockedUsers extends StatelessWidget {
  final List blockedUserList;

  const BlockedUsers({Key key, this.blockedUserList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstants.scaffoldColor,
        appBar: CustomAppBar(
          showTitle: true,
          title: 'Blocked User',
        ),
        body: (blockedUserList.isEmpty || blockedUserList == null)
            ? Center(
                child: Container(
                  child: Text(
                    'No blocked users',
                    style: CustomTextStyles.blueRegular16,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 40.toHeight),
                      itemCount: 10,
                      separatorBuilder: (context, index) => Divider(
                        indent: 16.toWidth,
                      ),
                      itemBuilder: (context, index) => ListTile(
                        leading: CustomCircleAvatar(
                          image: ImageConstants.barbara,
                        ),
                        title: Container(
                          width: 300.toWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Levina Thomas',
                                style: CustomTextStyles.primaryRegular16,
                              ),
                              Text(
                                '@levinaTt',
                                style: CustomTextStyles.secondaryRegular12,
                              ),
                            ],
                          ),
                        ),
                        trailing: GestureDetector(
                          onTap: () {},
                          child: Container(
                            child: Text(
                              'Unblock',
                              style: CustomTextStyles.blueRegular14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
