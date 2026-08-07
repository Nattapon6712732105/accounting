import 'package:flutter/material.dart';

IconData categoryIcon(String iconName) {
  switch (iconName) {
    case 'payments':
      return Icons.payments_outlined;
    case 'storefront':
      return Icons.storefront_outlined;
    case 'trending_up':
      return Icons.trending_up;
    case 'work':
      return Icons.work_outline;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'add_circle':
      return Icons.add_circle_outline;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'directions_car':
      return Icons.directions_car_outlined;
    case 'shopping_bag':
      return Icons.shopping_bag_outlined;
    case 'receipt_long':
      return Icons.receipt_long_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'movie':
      return Icons.movie_outlined;
    case 'medical_services':
      return Icons.medical_services_outlined;
    case 'school':
      return Icons.school_outlined;
    case 'remove_circle':
      return Icons.remove_circle_outline;
    default:
      return Icons.category_outlined;
  }
}
