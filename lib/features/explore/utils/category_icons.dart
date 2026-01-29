// Extract category riêng ra để tái sử dụng chung
import 'package:flutter/material.dart';

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
    case 'Mall':
      return Icons.local_mall_rounded;
    case 'Market':
      return Icons.maps_home_work_outlined;
    default:
      return Icons.apps;
  }
}
