// Extract category riêng ra để tái sử dụng chung
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Hotel':
      return Icons.hotel;
    case 'Restaurant':
      return Icons.restaurant;
    case 'Cafe':
      return Icons.coffee;
    case 'Attraction':
      return Icons.location_on;
    case 'Malls':
      return Icons.local_mall_rounded;
    case 'Market':
      return Icons.maps_home_work_outlined;
    default:
      return Icons.apps;
  }
}

String getCategoryName(String category) {
  if (category.isEmpty) return "explore.all".tr();
  return "explore.categories.$category".tr();
}
