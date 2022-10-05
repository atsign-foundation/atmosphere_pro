import 'package:flutter/material.dart';
import 'trusted_sender_tile.dart';

class ScrollArea extends StatelessWidget {
  const ScrollArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RawScrollbar(
        thumbColor: const Color(0xFFE3E3E3),
        radius: const Radius.circular(10.0),
        minThumbLength: 273.0,
        trackColor: const Color(0xFFF3F3F3),
        trackBorderColor: Colors.transparent,
        trackRadius: const Radius.circular(10.0),
        thickness: 5.0,
        thumbVisibility: true,
        trackVisibility: true,
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: 20,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisExtent: 65.0,
              mainAxisSpacing: 15.0,
              crossAxisCount: 2),
          itemBuilder:
              (BuildContext context, int index) {
            return const TrustedSenderTile(
                atSign: '@airplanes45',
                name: 'Sarah Paul');
          },
        ),
      ),
    );
  }
}
