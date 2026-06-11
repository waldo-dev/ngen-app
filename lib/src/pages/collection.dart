import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';

class CollectionWidget extends StatefulWidget {
  @override
  _CollectionWidgetState createState() => _CollectionWidgetState();
}

class _CollectionWidgetState extends State<CollectionWidget> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            labelPadding: EdgeInsets.all(0),
            tabs: [
              Tab(text: AppLocalizations.of(context)!.downloads.toUpperCase()),
              Tab(text: AppLocalizations.of(context)!.liked.toUpperCase()),
              Tab(
                  text: AppLocalizations.of(context)!
                      .subscriptions
                      .toUpperCase()),
            ],
          ),
          elevation: 1,
          title: Text(
            AppLocalizations.of(context)!.collections,
            style: TextStyle(
                color: AppColors.font_black, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.white,
        ),
        body: const TabBarView(
          children: [
            Text(''),
            Text(''),
            Text(''),
          ],
        ),
      ),
    );
  }
}

