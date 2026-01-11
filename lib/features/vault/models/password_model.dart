import 'package:hive/hive.dart';

part 'password_model.g.dart';

@HiveType(typeId: 1)
class PasswordModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String username;

  @HiveField(3)
  String password;

  @HiveField(4)
  String url;

  @HiveField(5)
  String notes;

  PasswordModel({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    required this.notes,
  });
}