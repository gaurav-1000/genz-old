import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:genz/app/constants/firebase.dart';

class CustomPosition {
  String? geohash;
  GeoPoint? geopoint;

  CustomPosition({this.geohash, this.geopoint});

  factory CustomPosition.fromFirestore(Map<String, dynamic> json) {
    return CustomPosition(
      geohash: json['geohash'] ?? "",
      geopoint: json['geopoint'] ?? const GeoPoint(0, 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geohash': geohash,
      'geopoint': geopoint,
    };
  }
}

class PinnedUser {
  Timestamp? timestamp;
  String? id;
  CustomPosition? position;

  PinnedUser({this.timestamp, this.id, this.position});

  factory PinnedUser.fromFirestore(Map<String, dynamic> json) {
    return PinnedUser(
      id: json['id'],
      timestamp: json['timestamp'],
      position: CustomPosition.fromFirestore(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'position': position?.toJson(),
    };
  }
}

class PinnedInfo {
  Timestamp day;
  int count;

  PinnedInfo({required this.day, required this.count});

  factory PinnedInfo.fromFirestore(Map<String, dynamic> json) {
    return PinnedInfo(
      day: json['day'] ?? Timestamp.now(),
      count: json['count'] ?? 0,
    );
  }
}

class UserModel {
  String id;
  DocumentReference<Map<String, dynamic>> get ref => firebaseFirestore.collection("users").doc(id);
  String? email;
  String? name;
  String? phoneNumber;
  String? imageUrl;
  String? thumbnail;
  CustomPosition? position;
  int? winksCount;
  int? premiumWinks;
  int? remainingWinks;
  List<PinnedUser>? pinnedUsers;
  List<String>? currentWinks;
  String? bio;
  bool? ghostMode;
  List<String>? winkedTo;
  String? zodiac;
  PinnedInfo? pinnedInfo;
  String? fcmToken;
  bool unlimited;
  bool admin;

  UserModel(
      {required this.id,
      this.email,
      this.name,
      this.phoneNumber,
      this.imageUrl,
      this.admin = false,
      this.unlimited = false,
      this.position,
      this.winksCount,
      this.fcmToken,
      this.remainingWinks,
      this.thumbnail,
      this.pinnedUsers,
      this.currentWinks,
      this.premiumWinks,
      this.ghostMode,
      this.winkedTo,
      this.zodiac,
      this.pinnedInfo,
      this.bio});

  factory UserModel.fromFirestore({
    required Map<String, dynamic> json,
    required String id,
  }) {
    return UserModel(
      id: id,
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      imageUrl: json['image_url'],
      thumbnail: json['thumbnail'],
      admin: json['admin'] ?? false,
      unlimited: json['unlimited'] ?? false,
      fcmToken: json["fcm_token"],
      position: CustomPosition.fromFirestore(json['position'] ?? {}),
      winksCount: json['winks_count'],
      premiumWinks: json['premium_winks'],
      remainingWinks: json['remaining_winks'] ?? 0,
      pinnedUsers: json['pinned_users'] != null
          ? (json['pinned_users'] as List<dynamic>).map((e) => PinnedUser.fromFirestore(e)).toList()
          : [],
      pinnedInfo: PinnedInfo.fromFirestore(json['pinned_info'] ?? {}),
      currentWinks: json['current_winks'] != null
          ? (json['current_winks'] as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      winkedTo: json['winked_to'] != null
          ? (json['winked_to'] as List<dynamic>).map((e) => e.toString()).toList()
          : [],
      ghostMode: json['ghost_mode'] ?? false,
      zodiac: json['zodiac'],
      bio: json['bio'],
    );
  }
}
