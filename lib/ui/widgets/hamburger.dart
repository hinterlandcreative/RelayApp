import 'package:flutter/material.dart';

class Hamburger extends StatelessWidget {
  final double width;
  final Function onTap;
  const Hamburger({
    Key key, 
    this.width = 16.0, 
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width + 15.0,
        height: width + 15.0,
        child: Center(
          child: SizedBox(
            width: width,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Container(
                    height: 2.00,
                    color: Colors.white)),
                ),
                LayoutBuilder(
                  builder: (_, cc) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      height: 2.00,
                      width: cc.maxWidth,
                      color: Colors.white),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.7,
                    child: Container(
                    height: 2.00,
                    color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}