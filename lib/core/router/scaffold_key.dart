import 'package:flutter/material.dart';

final shellScaffoldKey = GlobalKey<ScaffoldState>();

void openMainDrawer() => shellScaffoldKey.currentState?.openDrawer();
