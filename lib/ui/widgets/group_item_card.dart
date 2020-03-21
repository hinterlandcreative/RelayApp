import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../app_styles.dart';
import 'three_dots.dart';
import '../../translation/translations.dart';

class GroupItemCard extends StatefulWidget {
  final GroupModel group;
  const GroupItemCard({
    Key key, @required this.group,
  }) : super(key: key);

  @override
  _GroupItemCardState createState() => _GroupItemCardState();
}

class _GroupItemCardState extends State<GroupItemCard> {
  double parentContainerHeight = 100.0;

  @override
  void initState() {
    widget.group.addListener(_updateContainerHeight);
    super.initState();
  }

  @override
  void dispose() { 
    widget.group.removeListener(_updateContainerHeight);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.fastLinearToSlowEaseIn,
        height: parentContainerHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70.00,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(1.00,1.00),
                      color: Color(0xff000000).withOpacity(0.16),
                      blurRadius: 25,),], 
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0), 
                    bottomRight: Radius.circular(20.0))),
                child: Padding(
                  padding: const EdgeInsets.only(top:28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        child: Text(
                          "%d Contacts".i18n.fill([widget.group.totalContactCount]),
                          style: AppStyles.heading2Bold.copyWith(color: Colors.white))),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          width: 2.00,
                          color: Color(0xffffffff).withOpacity(0.12),),
                      ),
                      GestureDetector(
                        child: Text(
                          "Compose".i18n,
                          style: AppStyles.heading2Bold.copyWith(color: AppStyles.brightGreenBlue)))
                  ],),
                ),),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: GestureDetector(
                onTap: () => widget.group.toggleSelected(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(2.00,2.00),
                        color: Color(0xff000000).withOpacity(0.16),
                        blurRadius: 25,),], 
                    borderRadius: BorderRadius.circular(20.00),),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                        Text(widget.group.title, style: AppStyles.heading2Bold),
                        Row(children: widget.group.imagePath.length > 5
                        ? widget.group.imagePath.take(5).map((path) => _getSmallContactImage(path)).toList() + [ThreeDots()]
                        : widget.group.imagePath.map((path) => _getSmallContactImage(path)).toList())
                        ],)
                      ),
                  ),
              ),
            ),
          ],
        ),
      ),
      );
  }

  Widget _getSmallContactImage(String path) {
    return Padding(
      padding: const EdgeInsets.only(right:10.0),
      child: Image(
        width: 25,
        height: 25,
        image: AssetImage(path)),
    );
  }

  void _updateContainerHeight() {
    setState(() {
      parentContainerHeight = widget.group.selected ? 142.0 : 100.0;
    });
  }
}