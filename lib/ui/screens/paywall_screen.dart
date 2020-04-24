import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:commons/commons.dart';
import 'package:relay/mixins/route_aware_analytics_mixin.dart';
import 'package:waiting_dialog/waiting_dialog.dart';

import 'package:relay/translation/translations.dart';
import 'package:relay/services/purchases_service.dart';
import 'package:relay/ui/app_styles.dart';
import 'package:relay/ui/transitions/fade_route.dart';

class PaywallScreen extends StatefulWidget {
  final Widget Function() onSuccessBuilder;
  const PaywallScreen({Key key, this.onSuccessBuilder}) : super(key: key);

  @override
  _PaywallScreenState createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> with RouteAwareAnalytics {
  @override
  String get screenClass => "PaywallScreen";

  @override
  String get screenName => "/Paywall";

  @override
  Widget build(BuildContext context) {
    final double topSpace = MediaQuery.of(context).size.height * 0.20;

    return Consumer<PurchasesService>(
      builder: (context, purchases, _) => Scaffold(
          body: FutureBuilder<Offering>(
              future: purchases.getUnlimitedGroupsOfferings(),
              initialData: null,
              builder: (context, snapshot) {
                var offering = snapshot.data;
                if(offering == null) {
                  return Center(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      child: FlareActor(
                        "assets/animations/loading.flr", 
                        animation: "active",
                      ),
                    ),
                  );
                }
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: AppStyles.primaryGradientStart,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        top: MediaQuery.of(context).padding.top + topSpace,
                        child: new Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppStyles.primaryGradientEnd,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(MediaQuery.of(context).size.width * 0.75),
                            ),
                          ),
                        )
                      ),
                      Positioned(
                        height: MediaQuery.of(context).padding.top + topSpace + 80.0,
                        left: 80.0,
                        right: 80.0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            "assets/images/onboarding_messaging.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        top: MediaQuery.of(context).padding.top + topSpace + 100.0,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Unlimited Groups".i18n, 
                                style: AppStyles.heading1),
                              Box(height: 37.0),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppStyles.horizontalMargin),
                                child: Text(
                                  "product_description".i18n,
                                  style: AppStyles.paragraph),
                              ),
                              Box(height: 37.0)
                            ] +
                            offering.availablePackages.map<Widget>(
                              (package) => Padding(
                                padding: package == offering.availablePackages.last 
                                  ? EdgeInsets.symmetric(horizontal: AppStyles.horizontalMargin) 
                                  : EdgeInsets.only(left: AppStyles.horizontalMargin, right: AppStyles.horizontalMargin, bottom: 24.0),
                                child: Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: package.packageType == PackageType.lifetime ? AppStyles.brightGreenBlue : Colors.white,
                                    borderRadius: BorderRadius.circular(25.0)
                                  ),
                                  child: FlatButton(
                                    onPressed: () => _makePurchase(purchases, package, context),
                                    child: Center(
                                      child: Text(
                                        _getPackagePricing(package), 
                                        style: AppStyles.heading2Bold,),
                                    )
                                  )
                                ),
                              )
                            ).toList() + 
                            [
                              Box(height: 15.0,),
                              FlatButton(
                                onPressed: () async => await _restorePurchases(context, purchases),
                                child: Text(
                                  "Restore Purchases".i18n,
                                  style: AppStyles.heading2.copyWith(color: Colors.white),
                                ),
                              ),
                              Box(height: 15.0,),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppStyles.horizontalMargin),
                                child: Text(
                                  "subscription_tos".i18n,
                                  style: AppStyles.smallText.copyWith(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        )
                      ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 5.0,
                      left: 15.0,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 25.0,
                          width: 25.0,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 16.0,),
                        ),
                      )
                    )
                    ],
                  ));
              })),
    );
  }

  Future _restorePurchases(BuildContext context, PurchasesService purchases) async {
    showWaitingDialog(
      context: context, 
      onWaiting:() => purchases.restorePurchases(),
      onDone: () async {
        if(await purchases.hasUnlimitedGroupsEntitlement()) {
          await Navigator.of(context).pushReplacement(FadeRoute(page: widget.onSuccessBuilder()));
        } else {
          infoDialog(context, "Unlimited groups have not been purchased using this account.".i18n);
        }
      });
  }

  Future _makePurchase(PurchasesService purchases, Package package, BuildContext context) async {
    if(await purchases.purchaseUnlimitedGroupsPackage(package)) {
      await Navigator.of(context).pushReplacement(FadeRoute(page: widget.onSuccessBuilder()));
    } else {
      warningDialog(
        context, 
        "Purchase failed.".i18n,
        showNeutralButton: false,
        positiveText: "Okay".i18n,
        positiveAction: () => Navigator.of(context).pop()
      );
    }
  }

  String _getPackagePricing(Package package) {
    switch(package.packageType) { 
      case PackageType.lifetime:
        return "product_pricing: %s / %s".fill([package.product.priceString, "lifetime".i18n]);
        break;
      case PackageType.annual:
        return "product_pricing: %s / %s".fill([package.product.priceString, "year*".i18n]);
        break;
      case PackageType.sixMonth:
        return "product_pricing: %s / %s".fill([package.product.priceString, "six months*".i18n]);
        break;
      case PackageType.threeMonth:
        return "product_pricing: %s / %s".fill([package.product.priceString, "three months*".i18n]);
        break;
      case PackageType.twoMonth:
        return "product_pricing: %s / %s".fill([package.product.priceString, "two months*".i18n]);
        break;
      case PackageType.monthly:
        return "product_pricing: %s / %s".fill([package.product.priceString, "monthly*".i18n]);
        break;
      case PackageType.weekly:
        return "product_pricing: %s / %s".fill([package.product.priceString, "weekly*".i18n]);
        break;
      case PackageType.unknown:
      case PackageType.custom:
      default:
        return package.product.priceString;
        break;
    }
  }
}
