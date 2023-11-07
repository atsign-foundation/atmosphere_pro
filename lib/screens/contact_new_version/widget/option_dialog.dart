import 'package:flutter/material.dart';

class OptionDialog extends StatelessWidget {
  final Offset? position;
  final Function? editNickNameFunc, blockFunc, deleteFunc;

  const OptionDialog({
    Key? key,
    this.position,
    this.editNickNameFunc,
    this.blockFunc,
    this.deleteFunc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: position?.dy ?? 0,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildOptionCard(
                        context: context,
                        title: "Edit Nickname",
                        onTap: () {
                          editNickNameFunc?.call();
                        },
                      ),
                      _buildOptionCard(
                        context: context,
                        title: "Block",
                        onTap: () {
                          blockFunc?.call();
                        },
                      ),
                      _buildOptionCard(
                        context: context,
                        title: "Delete",
                        onTap: () {
                          deleteFunc?.call();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required Function onTap,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () {
        onTap.call();
        Navigator.of(context).pop();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
