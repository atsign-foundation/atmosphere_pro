import 'package:at_backupkey_flutter/utils/size_config.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:atsign_atmosphere_pro/data_models/menu_item.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_route_names.dart';
import 'package:atsign_atmosphere_pro/desktop_routes/desktop_routes.dart';
import 'package:atsign_atmosphere_pro/services/navigation_service.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';

class SidebarItem extends StatelessWidget {
  final MenuItem menuItem;
  final Map<String, dynamic>? arguments;
  final bool isUrlLauncher, isSidebarExpanded, isEmailLauncher;
  SidebarItem(
      {this.arguments,
      this.isUrlLauncher = false,
      this.isEmailLauncher = false,
      this.isSidebarExpanded = true,
      required this.menuItem});

  void onTapItem(MenuItem item, BuildContext context) async {
    if ((item.isUrl == true) && (item.routeName != null)) {
      await _launchInBrowser(item.routeName ?? "");
      return;
    }
    if ((item.isEmail == true)) {
      await _launchInEmail(arguments!['email']);
      return;
    }

    if (item.routeName != null && item.routeName != '') {
      if (item.routeName == DesktopRoutes.DESKTOP_HOME) {
        await DesktopSetupRoutes.nested_pop();
        return;
      }
      await DesktopSetupRoutes.nested_push(item.routeName,
          arguments: arguments);
    }
  }

  @override
  Widget build(BuildContext context) {
    var childRoutes =
        menuItem.children?.map((e) => e.routeName ?? "").toList() ?? [];

    SizeConfig().init(context);
    var nestedProvider = Provider.of<NestedRouteProvider>(
        NavService.navKey.currentContext!,
        listen: false);

    ExpandableController controller = ExpandableController(
        initialExpanded:
            childRoutes.contains(nestedProvider.current_route ?? "") ||
                nestedProvider.current_route == menuItem.routeName);

    return Container(
      child: menuItem.children?.isEmpty ?? true
          ? InkWell(
              onTap: () {
                onTapItem(menuItem, context);
              },
              child: BuildSidebarIconTitle(
                image: menuItem.image,
                route: menuItem.routeName ?? "",
                isSidebarExpanded: isSidebarExpanded,
                title: menuItem.title,
                nestedProvider: nestedProvider,
              ),
            )
          : InkWell(
              onTap: () {
                onTapItem(menuItem, context);
              },
              child: ExpandableNotifier(
                controller: controller,
                child: Column(
                  children: [
                    Expandable(
                      collapsed: ExpandableButton(
                        child: InkWell(
                          onTap: () {
                            onTapItem(menuItem, context);
                          },
                          child: BuildSidebarIconTitle(
                            image: menuItem.image,
                            route: menuItem.routeName ?? "",
                            isSidebarExpanded: isSidebarExpanded,
                            title: menuItem.title,
                            nestedProvider: nestedProvider,
                          ),
                        ),
                      ),
                      expanded: Column(
                        children: [
                          ExpandableButton(
                            child: InkWell(
                              child: BuildSidebarIconTitle(
                                image: menuItem.image,
                                route: menuItem.routeName ?? "",
                                isSidebarExpanded: isSidebarExpanded,
                                childRoutes: childRoutes,
                                title: menuItem.title,
                                nestedProvider: nestedProvider,
                              ),
                            ),
                          ),
                          ...menuItem.children!.map((item) {
                            return Container(
                              color: ColorConstants.raisinBlack,
                              child: Padding(
                                padding: isSidebarExpanded
                                    ? const EdgeInsets.symmetric(vertical: 5)
                                    : EdgeInsets.zero,
                                child: InkWell(
                                  onTap: () {
                                    onTapItem(item, context);
                                  },
                                  child: BuildSidebarIconTitle(
                                    image: item.image,
                                    route: item.routeName ?? "",
                                    isSidebarExpanded: isSidebarExpanded,
                                    isChildTile: true,
                                    title: item.title,
                                    nestedProvider: nestedProvider,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    try {
      await launchUrl(
        Uri(
          scheme: 'https',
          path: url,
        ),
      );
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInEmail(String email) async {
    await launchUrl(
      Uri(
        scheme: 'mailto',
        path: email,
      ),
    );
  }
}

class BuildSidebarIconTitle extends StatelessWidget {
  const BuildSidebarIconTitle({
    Key? key,
    required this.image,
    required this.route,
    required this.isSidebarExpanded,
    required this.title,
    required this.nestedProvider,
    this.childRoutes = const [],
    this.isChildTile = false,
  }) : super(key: key);

  final String? image;
  final String route;
  final bool isSidebarExpanded;
  final NestedRouteProvider nestedProvider;
  final List<String> childRoutes;
  final bool isChildTile;
  final String? title;

  @override
  Widget build(BuildContext context) {
    var isCurrentRoute;
    if (nestedProvider.current_route == route ||
        childRoutes.contains(nestedProvider.current_route)) {
      isCurrentRoute = true;
    } else {
      isCurrentRoute = false;
    }
    if (!isCurrentRoute) {
      isCurrentRoute = (nestedProvider.current_route == null &&
              route == DesktopRoutes.DESKTOP_HOME)
          ? true
          : false;
    }

    return Container(
      height: 40.toHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: isCurrentRoute
            ? Theme.of(context).primaryColor
            : ColorConstants.raisinBlack,
      ),
      padding: EdgeInsets.only(
          left: isChildTile ? 30 : 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: isSidebarExpanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Image.asset(
            image!,
            height: 22.toFont,
            color: isCurrentRoute
                ? Colors.white
                : ColorConstants.sidebarTextUnselected,
          ),
          SizedBox(width: isSidebarExpanded ? 10 : 0),
          isSidebarExpanded
              ? Flexible(
                  child: Text(
                    title!,
                    softWrap: true,
                    style: CustomTextStyles.desktopPrimaryRegular14.copyWith(
                      color: isCurrentRoute
                          ? Colors.white
                          : ColorConstants.sidebarTextUnselected,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
