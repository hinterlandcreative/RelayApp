import 'dart:io';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:relay/models/group_sort.dart';
import 'package:relay/translation/translations.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/mixins/color_mixin.dart';
import 'package:relay/ui/models/app_settings_model.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettingsModel model;
  const SettingsScreen({Key key, @required this.model}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController signatureTextController = TextEditingController();
  final FocusNode signatureFocusNode = FocusNode();

  @override
  void dispose() { 
    signatureTextController.dispose();
    signatureFocusNode.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    signatureTextController.text = widget.model.signature;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double headerHeight = MediaQuery.of(context).padding.top + 230.0;

    return Consumer<AppSettingsModel>(
      builder: (context, model, __) {
        return FocusWatcher(
          child: Scaffold(
            body: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [HexColor.fromHex("#626672"), HexColor.fromHex("#6B7899")]
                )
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    height: headerHeight,
                    child: Container(
                      height: 230.00,
                      decoration: BoxDecoration(
                        color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0.00, 15.00),
                              color: Color(0xff000000).withOpacity(0.16),
                              blurRadius: 30,
                            ),
                          ], 
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40.00), bottomRight: Radius.circular(40.00), ), 
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 15.0,
                            top: MediaQuery.of(context).padding.top),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios, color: AppStyles.darkGrey),
                                onPressed: () {
                                  model.signature = signatureTextController.text;
                                  return Navigator.of(context).pop();
                                },
                              ),
                              Text("Your Profile".i18n, style: AppStyles.heading1.copyWith(color: AppStyles.darkGrey)),
                              Expanded(
                                child: Container()),
                              FlatButton(
                                onPressed: () => _changeName(context, model),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                  Container(
                                    width: 5.0,
                                    height: 5.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppStyles.darkGrey
                                    ),
                                  ),
                                  Box(height: 45.0, width: 6.0,),
                                  Container(
                                    width: 5.0,
                                    height: 5.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppStyles.darkGrey
                                    ),
                                  ),
                                  Box(width: AppStyles.horizontalMargin,)
                                ],),
                              ),
                          ],),
                        ),
                        Box(height: 60.0,),
                        Padding(
                          padding: EdgeInsets.only(left: AppStyles.horizontalMargin),
                          child: Row(
                            children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                if(await Permission.photos.isGranted == false) {
                                  var status = await Permission.photos.request();
                                  if(status == PermissionStatus.denied) {
                                    showToast("Can't access photos. Please grant photos access in settings.".i18n);
                                  }
                                }
                                var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                                await model.updateImagePath(image);
                              },
                              child: Column(children: <Widget>[
                                Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: model.imagePath != null && model.imagePath.isNotEmpty
                                      ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(File(model.imagePath)))
                                      : null,
                                    color: AppStyles.darkGrey
                                  ),
                                      child: model.imagePath == null || model.imagePath.isEmpty
                                      ? Center(
                                        child: Icon(Icons.person, color: Colors.white, size: 30.0,),)
                                      : null,
                                ),
                                SizedBox(height: 10.0,),
                                Text(
                                  "change".i18n, 
                                  style: AppStyles.smallText.copyWith(color: AppStyles.primaryGradientStart))
                              ],),
                            ),
                            Box(width: 20.0,),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 24.0, right: AppStyles.horizontalMargin),
                                child: GestureDetector(
                                  onTap: () => _changeName(context, model),
                                  child: TextOneLine(
                                    model.name == null || model.name.isEmpty ? "Enter Name".i18n : model.name,
                                    style: AppStyles.heading1.copyWith(fontWeight: FontWeight.w100, color: Colors.black)
                                  ),
                                ),
                              ),
                            )
                          ],),
                        ),
                      ],
                    ) 
                    )
                  ),
                  Positioned.fill(
                    top: headerHeight + 40.0,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppStyles.horizontalMargin),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Group Sorting".i18n, style: AppStyles.heading2.copyWith(color: AppStyles.lightGrey),),
                            Box(height: 6.0,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.0),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                color: AppStyles.lightGrey.withAlpha(20)
                              ),
                              child: DropdownButton<GroupSort>(
                                isExpanded: true,
                                value: model.defaultGroupSort,
                                underline: Container(height: 0.0, color: Colors.transparent,),
                                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30.0,),
                                selectedItemBuilder: (_) => GroupSort.valueStrings.map<Widget>((s) => 
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        s.toString(), 
                                        style: AppStyles.heading2.copyWith(color: Colors.white)
                                      ),
                                    )
                                  )
                                ).toList(),
                                onChanged: (sort) => model.defaultGroupSort = sort,
                                items: GroupSort.values
                                  .map((v) => DropdownMenuItem<GroupSort>(
                                    value: v,
                                    child: Text(v.toString(), style: AppStyles.heading2
                                  )
                                )
                              ).toList()),
                            ),
                            Box(height: 30.0,),
                            Text("Signature".i18n, style: AppStyles.heading2.copyWith(color: AppStyles.lightGrey),),
                            Box(height: 6.0,),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal:15.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.0),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                color: AppStyles.lightGrey.withAlpha(20)
                              ),
                              child: TextFormField(
                                autocorrect: true,
                                focusNode: signatureFocusNode,
                                controller: signatureTextController,
                                textCapitalization: TextCapitalization.sentences,
                                maxLines: 6,
                                style: AppStyles.paragraph,
                                decoration: InputDecoration(
                                  border: InputBorder.none
                                ),
                              ),
                            ),
                            Box(height: 15.0,),
                            Row(children: <Widget>[
                              Theme(
                                data: ThemeData(unselectedWidgetColor: Colors.white),
                                child: Checkbox(
                                  value: model.autoIncludeSignature, 
                                  activeColor: Colors.white,
                                  checkColor: AppStyles.darkGrey,
                                  onChanged: (value) => model.autoIncludeSignature = value,),
                              ),
                              GestureDetector(
                                onTap: () => model.autoIncludeSignature = !model.autoIncludeSignature,
                                child: Text(
                                  "Include signature on every message.".i18n, 
                                  style: AppStyles.paragraph))
                            ],)
                          ],),
                      ),))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _changeName(BuildContext context, AppSettingsModel model) {
    singleInputDialog(
      context,
      label: "",
      title: "Enter Name".i18n,
      maxLines: 1,
      validator: (s) => s != null && s.isNotEmpty ? null : "Name can't be empty!",
      value: model.name,
      positiveText: "Save".i18n,
      positiveAction: (name) => model.name = name,
      negativeText: "Cancel".i18n
    );
  }
}