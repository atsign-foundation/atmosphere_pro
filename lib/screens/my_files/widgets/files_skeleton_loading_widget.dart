import 'package:atsign_atmosphere_pro/screens/common_widgets/skeleton_loading_widget.dart';
import 'package:flutter/material.dart';

class FilesSkeletonLoadingWidget extends StatelessWidget {
  const FilesSkeletonLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 28),
        Padding(
          padding: EdgeInsets.only(right: 36),
          child: SkeletonLoadingWidget(
            height: 56,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        SizedBox(height: 28),
        SkeletonLoadingWidget(
          height: 24,
          width: 100,
          borderRadius: BorderRadius.circular(79),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 84,
          width: double.infinity,
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return SkeletonLoadingWidget(
                width: 68,
                height: 84,
                borderRadius: BorderRadius.circular(10),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 12);
            },
            itemCount: 5,
          ),
        ),
        SizedBox(height: 28),
        SkeletonLoadingWidget(
          height: 24,
          width: 100,
          borderRadius: BorderRadius.circular(79),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(right: 36),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 100 / 100,
            ),
            itemBuilder: (context, index) {
              return SkeletonLoadingWidget(
                height: 100,
                width: 100,
                borderRadius: BorderRadius.circular(10),
              );
            },
          ),
        ),
        SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.only(right: 36),
          child: SkeletonLoadingWidget(
            height: 56,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
