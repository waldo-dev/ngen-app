import 'package:app/src/pages/map/route/route_option_selector.dart';
import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:im_stepper/stepper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:app/src/util/globals.dart' as globals;

class RouteBuilder extends StatefulWidget {
  final VoidCallback callback;

  RouteBuilder(this.callback);
  @override
  _RouteBuilderState createState() => _RouteBuilderState();
}

class _RouteBuilderState extends State<RouteBuilder> {
  // THE FOLLOWING TWO VARIABLES ARE REQUIRED TO CONTROL THE STEPPER.
  int activeStep = 0;

  int upperBound = 2; // upperBound MUST BE total number of icons minus 1.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              IconStepper(
                stepReachedAnimationEffect: Curves.fastLinearToSlowEaseIn,
                stepReachedAnimationDuration: Duration(seconds: 1),
                activeStepColor: AppColors.primary,
                icons: [
                  Icon(
                    MdiIcons.weatherHazy,
                    color: AppColors.white,
                  ),
                  Icon(
                    MdiIcons.weatherSunny,
                    color: AppColors.white,
                  ),
                  Icon(
                    MdiIcons.weatherNight,
                    color: AppColors.white,
                  ),
                ],

                // activeStep property set to activeStep variable defined above.
                activeStep: activeStep,

                // This ensures step-tapping updates the activeStep.
                onStepReached: (index) {
                  setState(() {
                    activeStep = index;
                  });
                },
              ),
              header(),
              Visibility(visible: activeStep == 0, child: RouteOptionSelector("park", 0)),
              Visibility(visible: activeStep == 1, child: RouteOptionSelector("restaurant", 1)),
              Visibility(visible: activeStep == 2, child: RouteOptionSelector("bar", 2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  cancelButton(),
                  activeStep == 2 ? confirmButton() : nextButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the next button.
  Widget confirmButton() {
    return MaterialButton(
      height: 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: Text(
        AppLocalizations.of(context)!.confirmRoute,
        style: new TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15.0,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        widget.callback();
        Navigator.of(context).pop();
      },
      splashColor: Colors.white,
    );
  }

  /// Returns the previous button.
  Widget cancelButton() {
    return MaterialButton(
      height: 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: Text(
        AppLocalizations.of(context)!.cancelRoute,
        style: new TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15.0,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
      splashColor: Colors.white,
    );
  }

  /// Returns the previous button.
  Widget nextButton() {
    return MaterialButton(
      height: 30,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: Text(
        AppLocalizations.of(context)!.nextRoute,
        style: new TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15.0,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        setState(() {
          activeStep = activeStep + 1;
        });
      },
      splashColor: Colors.white,
    );
  }

  /// Returns the header wrapping the header text.
  Widget header() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              headerText(),
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Returns the header text based on the activeStep.
  String headerText() {
    switch (activeStep) {
      case 1:
        return AppLocalizations.of(context)!.midday;
      case 2:
        return AppLocalizations.of(context)!.evening;
      default:
        return AppLocalizations.of(context)!.morning;
    }
  }
}

