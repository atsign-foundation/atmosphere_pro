import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/desktop_screens/desktop_group/desktop_new_group.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';

class DesktopEmptyGroup extends StatefulWidget {
  @override
  _DesktopEmptyGroupState createState() => _DesktopEmptyGroupState();
}

class _DesktopEmptyGroupState extends State<DesktopEmptyGroup> {
  bool createBtnTapped = false;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig().screenWidth - MixedConstants.SIDEBAR_WIDTH,
      color: ColorConstants.fadedBlue,
      // child: createBtnTapped
      //     ? Row(
      //         children: [
      //           Expanded(
      //             child: Navigator(
      //               key: NavService.groupLeftHalfNavKey,
      //               initialRoute: DesktopRoutes.DESKTOP_GROUP_LEFT_INITIAL,
      //               onGenerateRoute: (routeSettings) {
      //                 var routeBuilders =
      //                     DesktopSetupRoutes.groupLeftRouteBuilders(
      //                         context, routeSettings);
      //                 return MaterialPageRoute(builder: (context) {
      //                   return routeBuilders[routeSettings.name](context);
      //                 });
      //               },
      //             ),
      //           ),
      //           Expanded(
      //             child: Navigator(
      //               key: NavService.groupRightHalfNavKey,
      //               initialRoute: DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL,
      //               onGenerateRoute: (routeSettings) {
      //                 var routeBuilders =
      //                     DesktopSetupRoutes.groupRightRouteBuilders(
      //                   context,
      //                   routeSettings,
      //                   initialRouteOnArrowBackTap: () {
      //                     setState(() {
      //                       createBtnTapped = false;
      //                     });
      //                   },
      //                   initialRouteOnDoneTap:
      //                       _navigator(DesktopRoutes.DESKTOP_NEW_GROUP),
      //                 );
      //                 return MaterialPageRoute(builder: (context) {
      //                   return routeBuilders[routeSettings.name](context);
      //                 });
      //               },
      //             ),
      //           )
      //         ],
      //       )
      //     : _emptyGroup(),
    );
  }

  // _navigator(String _route) {
  //   switch (_route) {
  //     case DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL:
  //       return () {
  //         Navigator.of(NavService.groupRightHalfNavKey.currentContext)
  //             .pushNamed(DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL);
  //       };
  //     case DesktopRoutes.DESKTOP_GROUP_LIST:
  //       return () {
  //         Navigator.of(NavService.groupLeftHalfNavKey.currentContext)
  //             .pushReplacementNamed(DesktopRoutes.DESKTOP_GROUP_LIST,
  //                 arguments: {
  //               'onDone': _navigator(DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL),
  //             });
  //       };
  //     case DesktopRoutes.DESKTOP_GROUP_DETAIL:
  //       return () {
  //         Navigator.of(NavService.groupRightHalfNavKey.currentContext)
  //             .pushReplacementNamed(DesktopRoutes.DESKTOP_GROUP_DETAIL,
  //                 arguments: {});
  //       };

  //     case DesktopRoutes.DESKTOP_NEW_GROUP:
  //       return () {
  //         Navigator.of(NavService.groupRightHalfNavKey.currentContext)
  //             .pushNamed(DesktopRoutes.DESKTOP_NEW_GROUP, arguments: {
  //           'onPop': () {
  //             Navigator.of(NavService.groupRightHalfNavKey.currentContext)
  //                 .pop();
  //           },
  //           'onDone': () {
  //             Navigator.of(NavService.groupLeftHalfNavKey.currentContext)
  //                 .pushReplacementNamed(DesktopRoutes.DESKTOP_GROUP_LIST,
  //                     arguments: {
  //                   'onDone':
  //                       _navigator(DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL),
  //                 });
  //             Navigator.of(NavService.groupRightHalfNavKey.currentContext)
  //                 .pushReplacementNamed(DesktopRoutes.DESKTOP_GROUP_DETAIL,
  //                     arguments: {});
  //           }
  //         });
  //       };
  //   }
  // }

  Widget _emptyGroup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AllImages().EMPTY_GROUP,
          width: 181.toWidth,
          height: 181.toWidth,
          fit: BoxFit.cover,
          package: 'at_contacts_group_flutter',
        ),
        SizedBox(
          height: 15.toHeight,
        ),
        Text('No Groups!', style: CustomTextStyles.greyText16),
        SizedBox(
          height: 5.toHeight,
        ),
        Text(
          'Would you like to create a group?',
          style: CustomTextStyles.greyText16,
        ),
        SizedBox(
          height: 20.toHeight,
        ),
        TextButton(
          onPressed: () {
            setState(() {
              createBtnTapped = true;
            });
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return ColorConstants.orangeColor;
            },
          ), fixedSize: MaterialStateProperty.resolveWith<Size>(
            (Set<MaterialState> states) {
              return Size(160, 45);
            },
          )),
          child: Text(
            'Create',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    );
  }
}

// Container(
//             width: SizeConfig().screenWidth / 2 - 35,
//             child: DesktopNewGroup(),
//           )
