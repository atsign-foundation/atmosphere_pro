import 'package:atsign_atmosphere_pro/utils/images.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/services/size_config.dart';
import 'package:atsign_atmosphere_pro/view_models/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LimitAlert extends StatefulWidget {
  final bool limitReached;
  final ValueChanged<bool> onChange;
  const LimitAlert({Key key, this.limitReached, this.onChange})
      : super(key: key);

  @override
  _LimitAlertState createState() => _LimitAlertState();
}

class _LimitAlertState extends State<LimitAlert> {
  bool limit = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<ContactProvider>(
      builder: (context, provider, _) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: (!provider.limitReached)
            ? Container(
                color: Colors.transparent,
                height: 70.toHeight,
              )
            // : Container()
            : Container(
                color: Color(0xffFFC4C4),
                height: 70.toHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 25.toHeight,
                          width: 25.toHeight,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xFFFF7474)),
                          child: Center(
                            child: Image.asset(ImageConstants.exclamation),
                          ),
                        ),
                        SizedBox(
                          width: 10.toWidth,
                        ),
                        Text(
                          'You have reached the limit of 3',
                          style: CustomTextStyles.primaryRegular16,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // setState(() {
                            limit = true;
                            // widget.onChange(limitReached);
                            print('LIMIT===>${limit}');
                            // });
                          },
                          child: Container(
                            height: 25.toHeight,
                            width: 25.toHeight,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFF7474)),
                            child: Center(
                              child: Image.asset(ImageConstants.close),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
