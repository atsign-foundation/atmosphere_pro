import 'package:at_common_flutter/services/size_config.dart';
import 'package:atsign_atmosphere_pro/data_models/file_modal.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class FilterTabBar extends StatelessWidget {
  final TabController tabController;
  final HistoryType currentFilter;
  final Function(int) setType;

  const FilterTabBar({
    required this.tabController,
    required this.currentFilter,
    required this.setType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.toHeight,
      decoration: BoxDecoration(
        color: ColorConstants.backgroundTab,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(
        left: 36,
        right: 36,
        top: 4,
      ),
      child: TabBar(
        controller: tabController,
        indicatorColor: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: 13.toWidth,
          vertical: 7.toHeight,
        ),
        labelPadding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        tabs: [
          buildTabBarItem(index: 1),
          buildTabBarItem(index: 2),
        ],
        onTap: setType,
      ),
    );
  }

  Widget buildTabBarItem({
    required int index,
  }) {
    final bool isCurrentTab = HistoryType.values[index] == currentFilter;
    return Tab(
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentTab ? ColorConstants.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(125),
        ),
        child: Center(
          child: Text(
            HistoryType.values[index].text,
            style: TextStyle(
              color: isCurrentTab ? Colors.white : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
