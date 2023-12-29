import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:atsign_atmosphere_pro/desktop_screens_new/welcome_screen/widgets/sidebar_new.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/constants.dart';
import 'package:atsign_atmosphere_pro/view_models/side_bar_provider.dart';

class HomeScreenDesktop extends StatefulWidget {
  const HomeScreenDesktop({Key? key}) : super(key: key);

  @override
  State<HomeScreenDesktop> createState() => _HomeScreenDesktopState();
}

class _HomeScreenDesktopState extends State<HomeScreenDesktop> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          SideBarNew(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<SideBarProvider>(
                  builder: (_context, _sideBarProvider, _) {
                return SizedBox(
                  width: _sideBarProvider.isSidebarExpanded
                      ? MixedConstants.SIDEBAR_WIDTH_EXPANDED
                      : MixedConstants.SIDEBAR_WIDTH_COLLAPSED,
                );
              }),
              Expanded(
                child: Navigator(
                  key: NavService.nestedNavKey,
                  initialRoute: DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL,
                  onGenerateRoute: (routeSettings) {
                    var routeBuilders = DesktopSetupRoutes.routeBuilders(
                        context, routeSettings);
                    return MaterialPageRoute(builder: (context) {
                      return routeBuilders[routeSettings.name!]!(context);
                    });
                  },
                ),
              ),
            ],
          ),
          Consumer<SideBarProvider>(builder: (_context, _provider, _) {
            return Positioned(
              bottom: 96,
              left: _provider.isSidebarExpanded
                  ? MixedConstants.SIDEBAR_WIDTH_EXPANDED - 16
                  : MixedConstants.SIDEBAR_WIDTH_COLLAPSED - 16,
              child: Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () {
                      Provider.of<SideBarProvider>(context, listen: false)
                          .updateSidebarWidth();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 12,
                            color: Colors.black.withOpacity(0.25),
                          )
                        ],
                      ),
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                          _provider.isSidebarExpanded
                              ? Icons.arrow_back_ios
                              : Icons.arrow_forward_ios_sharp,
                          size: 16,
                          color: Colors.black),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
