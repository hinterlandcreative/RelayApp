import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:relay/mixins/route_aware_analytics_mixin.dart';

import 'package:relay/ui/models/onboarding/onboarding_model.dart';
import 'package:relay/translation/translations.dart';
import 'package:relay/ui/transitions/fade_route.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/ui/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({Key key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with RouteAwareAnalytics {
  final double topHeaderPaddingHeight = 100.0;
  final double indicatorBoxHeight = 50.0;
  final double nextOrCompleteBoxHeight = 100.0;
  final PageController pageController = PageController(initialPage: 0);
  int currentPage = 0;

  @override
  String get screenClass => "OnboardingScreen";

  @override
  String get screenName => "/Onboarding";

  @override
  void dispose() { 
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<OnboardingModel>(
        create: (_) => OnboardingModel(),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Container(
            height: double.infinity,
            width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppStyles.primaryGradientStart,
                AppStyles.primaryGradientEnd
              ])),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.0,
                height: topHeaderPaddingHeight,
                left: 0.0,
                right: 0.0,
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: Consumer<OnboardingModel>(
                    builder: (_, model, __) => FlatButton(
                      onPressed: () async {
                        await model.skip(currentPage);
                        Navigator
                          .of(context)
                          .pushReplacement(
                            FadeRoute(page: HomeScreen()));
                      },
                      child: Text(
                        "Skip".i18n,
                        style: AppStyles.heading2Bold.copyWith(color: Colors.white))),
                  ))),
              Positioned.fill(
                top: topHeaderPaddingHeight,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                bottom: indicatorBoxHeight + nextOrCompleteBoxHeight + MediaQuery.of(context).padding.bottom,
                child: Consumer<OnboardingModel>(
                  builder: (_, model, __) => PageView(
                    physics: ClampingScrollPhysics(),
                    controller: pageController,
                    children: buildOnboardingPages(model),
                    onPageChanged: (index) => setState(() => currentPage = index))
                  )
                ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                height: indicatorBoxHeight + nextOrCompleteBoxHeight + MediaQuery.of(context).padding.bottom,
                child: Consumer<OnboardingModel>(
                  builder: (context, model, __) => Column(children: <Widget>[
                    Box(
                      height: indicatorBoxHeight,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buildPageIndicator(model.items.length))),
                    currentPage < model.items.length  - 1
                    ? Box(
                      height: MediaQuery.of(context).padding.bottom + nextOrCompleteBoxHeight, 
                      width: double.infinity, 
                      alignment: Alignment.topRight,
                      child: FlatButton(
                        onPressed: () {
                          pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Next".i18n,
                              style: AppStyles.heading1.copyWith(fontSize: 22.0),
                            ),
                            SizedBox(width: 10.0),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ],
                        ),
                      ),
                    )
                    : Box(
                      height: MediaQuery.of(context).padding.bottom + nextOrCompleteBoxHeight, 
                      width: double.infinity, 
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () async {
                          await model.complete();
                          Navigator
                          .of(context)
                          .pushReplacement(
                            FadeRoute(page: HomeScreen()));
                        },
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 30.0),
                            child: Text(
                              "Get started".i18n,
                              style: TextStyle(
                                color: Color(0xFF5B16D0),
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    )
                  ]
                  ),
                )
              )
            ],
          ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildOnboardingPages(OnboardingModel model) {
    return model.items.map((item) => Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Center(
            child: Image(
              fit: BoxFit.fill,
              image: AssetImage(item.imageAssetPath)
            )
          )
        ),
        Box(height: 30.0,),
        Flexible(
          flex: 1,
          child: Box(
            height: double.infinity, 
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: AppStyles.heading1,
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    item.text,
                    style: AppStyles.paragraph,
                  ),
                  if(item.child != null) Center(child: item.child,)
                ]
              )
            )
          )
        ),
      ],
    )).toList();
  }

  List<Widget> buildPageIndicator(int length) {
    List<Widget> list = [];
    for (int i = 0; i < length; i++) {
      list.add(i == currentPage ? indicator(true) : indicator(false));
    }
    return list;
  }

  Widget indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}