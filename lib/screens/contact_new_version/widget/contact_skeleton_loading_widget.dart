import 'package:atsign_atmosphere_pro/screens/common_widgets/skeleton_loading_widget.dart';
import 'package:flutter/material.dart';

class ContactSkeletonLoadingWidget extends StatelessWidget {
  const ContactSkeletonLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 36,
        top: 24,
        right: 36,
      ),
      child: Column(
        children: [
          SkeletonLoadingWidget(
            height: 52,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              SkeletonLoadingWidget(
                height: 56,
                borderRadius: BorderRadius.circular(10),
              ),
              Positioned(
                top: 4,
                bottom: 4,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLoadingWidget(
                      height: 44,
                      width: 80,
                      borderRadius: BorderRadius.circular(48.3),
                    ),
                    SkeletonLoadingWidget(
                      height: 44,
                      width: 80,
                      borderRadius: BorderRadius.circular(48.3),
                    ),
                    SkeletonLoadingWidget(
                      height: 44,
                      width: 80,
                      borderRadius: BorderRadius.circular(48.3),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _buildContactSkeletonLoadingItem();
              },
              separatorBuilder: (context, index) {
                return SizedBox(height: 16);
              },
              itemCount: 6,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContactSkeletonLoadingItem() {
    return Stack(
      children: [
        SkeletonLoadingWidget(
          height: 72,
          borderRadius: BorderRadius.circular(10),
        ),
        Positioned(
          top: 8,
          bottom: 16,
          left: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonLoadingWidget(
                width: 48,
                height: 48,
                shape: BoxShape.circle,
              ),
              SizedBox(width: 16),
              SkeletonLoadingWidget(
                height: 36,
                width: 108,
                borderRadius: BorderRadius.circular(20),
              )
            ],
          ),
        )
      ],
    );
  }
}
