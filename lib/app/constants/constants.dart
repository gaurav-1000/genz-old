import 'package:flutter/cupertino.dart';

class Constants {
  Constants._();

  static const waveSteps = 10;

  static const zodiacs = {
    "aries": "♈",
    "taurus": "♉",
    "gemini": "♊",
    "cancer": "♋",
    "leo": "♌",
    "virgo": "♍",
    "libra": "♎",
    "scorpio": "♏",
    "sagittarius": "♐",
    "capricorn": "♑",
    "aquarius": "♒",
    "pisces": "♓"
  };

  static const double listTileLeadingSize = 60.0;
  static const double navBarHeight = 50.0;

  static final darkBackground = CupertinoColors.systemBackground.darkColor;

  static const googleMapsStyle = """[
    {
      "featureType": "all",
      "elementType": "geometry",
      "stylers": [
        {"color": "#202c3e"}
      ]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.fill",
      "stylers": [
        {"gamma": 0.01},
        {"lightness": 20},
        {"weight": "1.39"},
        {"color": "#ffffff"}
      ]
    },
    {
      "featureType": "all",
      "elementType": "labels.text.stroke",
      "stylers": [
        {"weight": "0.96"},
        {"saturation": "9"},
        {"visibility": "on"},
        {"color": "#000000"}
      ]
    },
    {
      "featureType": "all",
      "elementType": "labels.icon",
      "stylers": [
        {"visibility": "off"}
      ]
    },
    {
      "featureType": "landscape",
      "elementType": "geometry",
      "stylers": [
        {"lightness": 30},
        {"saturation": "9"},
        {"color": "#29446b"}
      ]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [
        {"saturation": 20}
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        {"lightness": 20},
        {"saturation": -20}
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        {"lightness": 10},
        {"saturation": -30}
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [
        {"color": "#193a55"}
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [
        {"saturation": 25},
        {"lightness": 25},
        {"weight": "0.01"}
      ]
    },
    {
      "featureType": "water",
      "elementType": "all",
      "stylers": [
        {"lightness": -20}
      ]
    }
  ]""";
}

enum PageIndex {
  map,
  list,
  winks,
  chats,
  settings,
}
