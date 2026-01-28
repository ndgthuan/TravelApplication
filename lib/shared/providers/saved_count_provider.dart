import 'package:flutter/material.dart';

class SavedCountProvider extends ChangeNotifier {
  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  int _unseenCount = 0;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  int get unseenCount => _unseenCount;

  //==========================================================================//
  //                        PRIVATE HELPERS                                   //
  //==========================================================================//
  void increment() {
    _unseenCount++;
    notifyListeners();
  }

  void reset() {
    _unseenCount = 0;
    notifyListeners();
  }
}
