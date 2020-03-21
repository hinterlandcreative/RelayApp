import 'package:flutter/material.dart';

class ThreeDots extends StatelessWidget {
  final Function onTap;
  const ThreeDots({
    Key key, this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: Container(
                height: 3.00,
                width: 3.00,
                decoration: BoxDecoration(
                  color: Color(0xff707070),
                  shape: BoxShape.circle, ),),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: Container(
                height: 3.00,
                width: 3.00,
                decoration: BoxDecoration(
                  color: Color(0xff707070),
                  shape: BoxShape.circle, ),),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: Container(
                height: 3.00,
                width: 3.00,
                decoration: BoxDecoration(
                  color: Color(0xff707070),
                  shape: BoxShape.circle, ),),
            ),
          ],),
      ),
    );
  }
}