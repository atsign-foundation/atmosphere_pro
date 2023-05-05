import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:flutter/material.dart';

class HistoryCardWidget extends StatefulWidget {
  final FileHistory? fileHistory;

  const HistoryCardWidget({
    Key? key,
    this.fileHistory,
  }) : super(key: key);

  @override
  State<HistoryCardWidget> createState() => _HistoryCardWidgetState();
}

class _HistoryCardWidgetState extends State<HistoryCardWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      width: double.infinity,
      margin: EdgeInsets.only(left: 36, right: 18),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isExpanded ? Color(0xFFD7D7D7) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "Anna",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                "04/07/23",
                style: TextStyle(
                  fontSize: 10,
                  color: ColorConstants.oldSliver,
                ),
              ),
              Container(
                width: 1,
                height: 8,
                color: Color(0xFFD7D7D7),
                margin: EdgeInsets.symmetric(
                  horizontal: 3,
                ),
              ),
              Text(
                "14:09",
                style: TextStyle(
                  fontSize: 10,
                  color: ColorConstants.oldSliver,
                ),
              ),
              SizedBox(width: 6),
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: ColorConstants.lightGreen,
                ),
                child: Icon(
                  Icons.check,
                  size: 8,
                  color: ColorConstants.textGreen,
                ),
              ),
              SizedBox(width: 4),
              Container(
                height: 16,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(33),
                  color: ColorConstants.lightGreen,
                ),
                child: Center(
                  child: Text(
                    "Received",
                    style: TextStyle(
                      color: ColorConstants.textGreen,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            "@Antartica45",
            style: TextStyle(
              fontSize: 8,
              color: Colors.black,
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                "message",
                style: TextStyle(
                  fontSize: 10,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
