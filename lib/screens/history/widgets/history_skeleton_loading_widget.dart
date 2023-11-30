import 'package:atsign_atmosphere_pro/screens/common_widgets/skeleton_loading_widget.dart';
import 'package:flutter/material.dart';

class HistorySkeletonLoadingWidget extends StatelessWidget {
  const HistorySkeletonLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 36,
        top: 28,
        right: 36,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              SkeletonLoadingWidget(
                borderRadius: BorderRadius.circular(10),
                height: 56,
              ),
              Positioned(
                top: 4,
                bottom: 4,
                right: 36,
                child: SkeletonLoadingWidget(
                  borderRadius: BorderRadius.circular(48.3),
                  height: 44,
                  width: 116,
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildSkeletonLoadingItem();
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 24);
              },
              itemCount: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoadingItem() {
    return Stack(
      children: [
        SkeletonLoadingWidget(
          height: 196,
          borderRadius: BorderRadius.circular(10),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonLoadingWidget(
                    height: 32,
                    width: 136,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  SkeletonLoadingWidget(
                    height: 24,
                    width: 56,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ],
              ),
              SizedBox(height: 8),
              SkeletonLoadingWidget(
                height: 24,
                borderRadius: BorderRadius.circular(99),
              ),
              SizedBox(height: 16),
              SkeletonLoadingWidget(
                height: 80,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        )
      ],
    );
  }
}
