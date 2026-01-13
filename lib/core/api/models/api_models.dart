import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String username;
  final String password;
  @JsonKey(name: 'master_password')
  final String masterPassword;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
    required this.masterPassword,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  TokenResponse({required this.accessToken, required this.tokenType});

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}

@JsonSerializable()
class PasswordDto {
  final String? id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;
  final String category;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  PasswordDto({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url = '',
    this.notes = '',
    this.category = 'Personal',
    this.createdAt,
    this.updatedAt,
  });

  factory PasswordDto.fromJson(Map<String, dynamic> json) =>
      _$PasswordDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordDtoToJson(this);
}

@JsonSerializable()
class PasswordListResponse {
  final List<PasswordDto> passwords;
  final int total;

  PasswordListResponse({required this.passwords, required this.total});

  factory PasswordListResponse.fromJson(Map<String, dynamic> json) =>
      _$PasswordListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PasswordListResponseToJson(this);
}
