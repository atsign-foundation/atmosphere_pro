import 'package:atsign_atmosphere_app/screens/blocked_users/widgets/blockusercard.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/app_bar.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/provider_handler.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/text_styles.dart';
import 'package:atsign_atmosphere_app/view_models/blockuser_provider.dart';
import 'package:flutter/material.dart';

class BlockedUsers extends StatefulWidget {
  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  BlockeduserProvider provider;

  @override
  void initState() {
    provider = BlockeduserProvider();
    provider.getBlockedUser();
    super.initState();
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: ColorConstants.scaffoldColor,
            appBar: CustomAppBar(
              showTitle: true,
              title: 'Blocked User',
            ),
            body: Container(
              color: ColorConstants.appBarColor,
              child: ProviderHandler<BlockeduserProvider>(
                functionName: provider.Blocked_USER,
                successBuilder: (provider) =>
                    (provider.blockedUser.isEmpty || provider.blockedUser == null)
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
                                    itemCount: provider.blockedUser.length,
                                    separatorBuilder: (context, index) => Divider(
                                          indent: 16.toWidth,
                                        ),
                                    itemBuilder: (context, index) => BlockedUserCard(
                                          blockeduser: provider.blockedUser[index],
                                        )),
                              ),
                            ],
                          ),
                errorBuilder: (provider) => Center(
                  child: Text('Some error occured'),
                ),
              ),
            )));
  }
}
