import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  String id;
  String email;
  String name;
  String credentialProvider;
  String profileIMG;
  String phoneNumber;

  @JsonKey(fromJson: _fromJsonCreated, toJson: _toJsonCreated)
  Timestamp? created;
  @JsonKey(fromJson: _fromJsonUpdated, toJson: _toJsonUpdated)
  Timestamp? updated;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.credentialProvider,
    required this.profileIMG,
    required this.phoneNumber,
    required this.created,
    required this.updated,
  });

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  static Timestamp? _fromJsonCreated(Timestamp? created) {
    return created;
  }

  static Timestamp? _toJsonCreated(Timestamp? created) {
    return created;
  }

  static Timestamp? _fromJsonUpdated(Timestamp? updated) {
    return updated;
  }

  static Timestamp? _toJsonUpdated(Timestamp? updated) {
    return updated;
  }

}

/*
UserModel _$UserBikeModelFromJson(Map<String, dynamic> json) =>
    UserModel(
      bluetoothName: json['bluetoothName'] as String,
      model: json['model'] as String,
      macAddr: json['macAddr'] as String,
      created: UserModel._fromJsonCreated(json['created'] as Timestamp?),
      updated: UserModel._fromJsonUpdated(json['updated'] as Timestamp?),
    );

Map<String, dynamic> _$UserBikeModelToJson(UserModel instance) =>
    <String, dynamic>{
      'bluetoothName': instance.bluetoothName,
      'model': instance.model,
      'macAddr': instance.macAddr,
      'created': UserModel._toJsonCreated(instance.created),
      'updated': UserModel._toJsonUpdated(instance.updated),
    };


 */