import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_service.dart';
import '../../core/api/models/api_models.dart';
import '../auth/auth_provider.dart';
import 'models/password_model.dart';

final vaultProvider =
    StateNotifierProvider<VaultNotifier, AsyncValue<List<PasswordModel>>>(
        (ref) {
  return VaultNotifier(ref.read(apiServiceProvider));
});

class VaultNotifier extends StateNotifier<AsyncValue<List<PasswordModel>>> {
  final ApiService _apiService;

  VaultNotifier(this._apiService) : super(const AsyncValue.loading()) {
    loadPasswords();
  }

  Future<void> loadPasswords() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.getPasswords();
      final passwords =
          response.passwords.map((dto) => _dtoToModel(dto)).toList();
      state = AsyncValue.data(passwords);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addPassword(PasswordModel password) async {
    try {
      final dto = _modelToDto(password);
      await _apiService.createPassword(dto);
      await loadPasswords();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePassword(PasswordModel password) async {
    try {
      final dto = _modelToDto(password);
      await _apiService.updatePassword(password.id, dto);
      await loadPasswords();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deletePassword(PasswordModel password) async {
    try {
      await _apiService.deletePassword(password.id);
      await loadPasswords();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.getPasswords(search: query);
      final passwords =
          response.passwords.map((dto) => _dtoToModel(dto)).toList();
      state = AsyncValue.data(passwords);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Conversion helpers
  PasswordModel _dtoToModel(PasswordDto dto) {
    return PasswordModel(
      id: dto.id ?? '',
      title: dto.title,
      username: dto.username,
      password: dto.password,
      url: dto.url,
      notes: dto.notes,
      category: dto.category,
      createdAt: dto.createdAt,
    );
  }

  PasswordDto _modelToDto(PasswordModel model) {
    return PasswordDto(
      id: model.id,
      title: model.title,
      username: model.username,
      password: model.password,
      url: model.url,
      notes: model.notes,
      category: model.category,
    );
  }
}
