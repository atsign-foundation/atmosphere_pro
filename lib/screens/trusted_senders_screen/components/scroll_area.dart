import 'package:flutter/material.dart';
import 'trusted_sender_tile.dart';

class ScrollArea extends StatelessWidget {
  const ScrollArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sendersData = [
      {
        'A': [
          {
            'url': 'https://randomuser.me/api/portraits/men/24.jpg',
            'name': 'Aron Paul',
            'atSign': '@bikes13',
          },
        ],
      },
      {
        'C': [
          {
            'url': 'https://randomuser.me/api/portraits/men/27.jpg',
            'name': 'Charlie Harper',
            'atSign': '@cars69',
          },
        ],
      },
      {
        'R': [
          {
            'url': 'https://randomuser.me/api/portraits/women/28.jpg',
            'name': 'Rose',
            'atSign': '@chopper33',
          },
        ],
      },
      {
        'S': [
          {
            'url': 'https://randomuser.me/api/portraits/women/42.jpg',
            'name': 'Sarah Paul',
            'atSign': '@airplanes45',
          },
          {
            'url': 'https://randomuser.me/api/portraits/men/42.jpg',
            'name': 'Bruce Bane',
            'atSign': '@trucks47',
          },
        ],
      },
    ];

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
        interactive: true,
        trackVisibility: true,
        child: ListView.builder(
          itemCount: sendersData.length,
          itemBuilder: (BuildContext context, int index) {
            final alphabet = sendersData[index].keys.first;
            final senders = sendersData[index][alphabet];
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      alphabet,
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      height: 1.0,
                      width: 326,
                      color: const Color(0xFFD9D9D9),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: senders!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 65.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final sender = senders[index];
                    return TrustedSenderTile(
                      atSign: sender['atSign']!,
                      name: sender['name']!,
                      url: sender['url']!,
                    );
                  },
                ),
                const SizedBox(height: 12.0),
              ],
            );
          },
        ),
      ),
    );
  }
}
