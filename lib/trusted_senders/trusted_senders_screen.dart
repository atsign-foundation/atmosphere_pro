import 'package:flutter/material.dart';
import 'components/add_button.dart';
import 'components/close_pill_button.dart';
import 'components/scroll_area.dart';
import 'components/search_field.dart';

class TrustedSendersScreen extends StatelessWidget {
  const TrustedSendersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Trusted Senders'),
          onPressed: () {
            showModalBottomSheet<dynamic>(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              context: context,
              builder: (BuildContext context) {
                return Container(
                  color: Colors.transparent,
                  child: Container(
                    height: 780.0,
                    decoration: BoxDecoration(
                      // color: Colors.white.withOpacity(0.8),
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 61,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 27, vertical: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 38),
                                child: Container(
                                  height: 2.0,
                                  width: 45,
                                  color: Colors.black,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: ClosePillButton(),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(
                              'Trusted Senders',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 25,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: SearchField(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'A',
                                  style: TextStyle(
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
                          ),
                          const SizedBox(height: 8.0),
                          const ScrollArea(),
                          const SizedBox(height: 35.0),
                          const Center(
                            child: AddButton(),
                          ),
                          const SizedBox(height: 35.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
