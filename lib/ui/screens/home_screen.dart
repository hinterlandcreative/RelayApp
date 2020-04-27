import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';
import 'package:provider/provider.dart';
import 'package:relay/mixins/route_aware_analytics_mixin.dart';
import 'package:relay/services/app_reviews_service.dart';
import 'package:relay/ui/screens/group_collection_screen.dart';

import 'package:relay/ui/screens/menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAwareAnalytics {
  @override
  String get screenClass => "HomeScreen";

  @override
  String get screenName => "/";

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) => shouldShowReviews(context));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleHiddenDrawer(
      contentCornerRadius: 40.0,
      menu: MenuScreen(),
      screenSelectedBuilder: (_, __) => GroupCollectionScreen(),
    );
  }

  void shouldShowReviews(BuildContext context) async {
    var reviews = Provider.of<AppReviewsService>(context, listen: false);
    if(await reviews.shouldRequestReviews()) {
      await reviews.requestReviews(context);
    }
  }
}