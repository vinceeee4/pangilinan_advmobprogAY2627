import 'package:flutter/material.dart';

const String kAppTitle = 'NubdExchange';
const String kDummyJsonBaseUrl = 'https://dummyjson.com';
const String kApiUrl = '$kDummyJsonBaseUrl/products';
const int kTestUserId = 5;
const String kCurrencySymbol = '₱';
const double kUsdToPhpConversionRate = 56.0;
const double kDefaultPadding = 16.0;
const double kBorderRadius = 12.0;
const double kCardElevation = 2.0;
const Color kLightBackground = Color(0xFFF8F9FA);
const Color kDarkBackground = Color(0xFF121212);
const Color kPrimaryColor = Color(0xFF495057);

const TextStyle kAppBarTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

const TextStyle kProductTitleStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
);

const TextStyle kProductSubtitleStyle = TextStyle(
  fontSize: 14,
  color: Colors.black54,
);

const TextStyle kProductPriceStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: Colors.green,
);
