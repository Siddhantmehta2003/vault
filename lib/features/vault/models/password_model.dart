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

  @HiveField(6)
  String category;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? sharedVaultId;

  PasswordModel({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.url,
    required this.notes,
    this.category = 'Personal',
    this.sharedVaultId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PasswordModel.fromJson(Map<String, dynamic> json) {
    return PasswordModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      url: json['url'] ?? '',
      notes: json['notes'] ?? '',
      category: json['category'] ?? 'Personal',
      sharedVaultId: json['shared_vault_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
