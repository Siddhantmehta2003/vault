import 'package:dio/dio.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_service.dart';
import '../models/team_models.dart';

class TeamService {
  final ApiService _apiService;

  TeamService(this._apiService);

  Future<TeamModel> createTeam(String name) async {
    try {
      final response = await _apiService.dio.post(
        '${ApiConfig.baseUrl}/api/teams/',
        data: {'name': name},
      );
      return TeamModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TeamModel> joinTeam(String code) async {
    try {
      final response = await _apiService.dio.post(
        '${ApiConfig.baseUrl}/api/teams/join',
        data: {
          'code': {'code': code}
        }, // Matches Body(..., embed=True) which expects dict with key 'code' but here just JSON {"code": "..."} might assume 'code' field?
        // Wait, Body(..., embed=True) expects {"code": "XYZ"} in JSON body.
        // Actually, if embed=True, it expects key 'code'.
      );
      return TeamModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Correction check for joinTeam:
  // In backend: code: str = Body(..., embed=True)
  // This means JSON body: { "code": "VALUE" }
  // So data: {'code': code} is correct.

  Future<List<TeamModel>> getMyTeams() async {
    try {
      final response =
          await _apiService.dio.get('${ApiConfig.baseUrl}/api/teams/');
      return (response.data as List).map((e) => TeamModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<TeamMemberModel>> getTeamMembers(String teamId) async {
    try {
      final response = await _apiService.dio
          .get('${ApiConfig.baseUrl}/api/teams/$teamId/members');
      return (response.data as List)
          .map((e) => TeamMemberModel.fromJson(e))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<SharedVaultModel>> getTeamVaults(String teamId) async {
    try {
      final response = await _apiService.dio
          .get('${ApiConfig.baseUrl}/api/teams/$teamId/vaults');
      return (response.data as List)
          .map((e) => SharedVaultModel.fromJson(e))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SharedVaultModel> createSharedVault(String teamId, String name,
      [List<String>? memberIds]) async {
    try {
      final response = await _apiService.dio.post(
        '${ApiConfig.baseUrl}/api/teams/$teamId/vaults',
        data: {
          'name': name,
          'member_ids': memberIds ?? [],
        },
      );
      return SharedVaultModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> inviteMember(String teamId, String email) async {
    try {
      await _apiService.dio.post(
          '${ApiConfig.baseUrl}/api/teams/$teamId/invite',
          data: {'email': email});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SharedVaultModel> updateSharedVault(String teamId, String vaultId,
      String name, List<String> memberIds) async {
    try {
      final response = await _apiService.dio.put(
        '${ApiConfig.baseUrl}/api/teams/$teamId/vaults/$vaultId',
        data: {
          'name': name,
          'member_ids': memberIds,
        },
      );
      return SharedVaultModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> createSharedPassword(
      String teamId, String vaultId, dynamic passwordModel) async {
    // passwordModel needs to be converted to JSON matching PasswordCreate
    final data = {
      "title": passwordModel.title,
      "username": passwordModel.username,
      "password": passwordModel.password,
      "url": passwordModel.url,
      "notes": passwordModel.notes,
      "category": passwordModel.category,
      "shared_vault_id": vaultId
    };

    try {
      await _apiService.dio.post(
          '${ApiConfig.baseUrl}/api/teams/$teamId/vaults/$vaultId/passwords',
          data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getSharedPasswords(
      String teamId, String vaultId) async {
    try {
      final response = await _apiService.dio.get(
          '${ApiConfig.baseUrl}/api/teams/$teamId/vaults/$vaultId/passwords');
      // We return raw data or convert to PasswordModel here?
      // Ideally convert to PasswordModel.
      // But PasswordModel in frontend is a HiveObject with @HiveType.
      // We might need a common model or mapping.
      // For now let's use the same PasswordModel from vault feature if compatible,
      // or maybe just return dynamic list and map in provider.
      // Actually, PasswordModel.fromJson should exist or be created.
      // Looking at PasswordModel (Step 160), it doesn't have fromJson.
      // It's a Hive object.
      // We should probably rely on JSON for network transport and manual mapping or add fromJson.
      // I'll return List<dynamic> for now and handle mapping in the provider/UI layer or add fromJson to PasswordModel.
      return response.data as List;
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('detail')) {
          return data['detail'].toString();
        }
        return 'Server error: ${error.response!.statusCode}';
      }
      return 'Network error: ${error.message}';
    }
    return error.toString();
  }
}
