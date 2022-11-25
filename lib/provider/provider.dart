import 'package:flutter/cupertino.dart';

class PageProvider with ChangeNotifier {
  int _index = 0;
  int get indexno => _index;
  nextPage(val) {
    _index = val;
    notifyListeners();
  }
}
