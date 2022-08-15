// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      credentialProvider: json['credentialProvider'] as String,
      profileIMG: json['profileIMG'] as String,
      phoneNumber: json['phoneNumber'] as String,
      created: UserModel._fromJsonCreated(json['created'] as Timestamp?),
      updated: UserModel._fromJsonUpdated(json['updated'] as Timestamp?),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'credentialProvider': instance.credentialProvider,
      'profileIMG': instance.profileIMG,
      'phoneNumber': instance.phoneNumber,
      'created': UserModel._toJsonCreated(instance.created),
      'updated': UserModel._toJsonUpdated(instance.updated),
    };
