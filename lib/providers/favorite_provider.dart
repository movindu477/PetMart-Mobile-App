import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  Set<int> _favoriteIds = {};
  bool _isLoading = false;

  Set<int> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  bool isFavorite(int petId) => _favoriteIds.contains(petId);

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favoriteIds = await FavoriteService.fetchFavorites();
      debugPrint(
        "--- FAVORITE PROVIDER: Loaded ${_favoriteIds.length} favorites",
      );
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int petId) async {
    // Optimistic UI update
    final wasFavorite = _favoriteIds.contains(petId);
    if (wasFavorite) {
      _favoriteIds.remove(petId);
    } else {
      _favoriteIds.add(petId);
    }
    notifyListeners();

    try {
      final isNowFavorite = await FavoriteService.toggleFavorite(petId);

      // Sync with server response if needed
      if (isNowFavorite) {
        _favoriteIds.add(petId);
      } else {
        _favoriteIds.remove(petId);
      }
    } catch (e) {
      // Revert on error
      if (wasFavorite) {
        _favoriteIds.add(petId);
      } else {
        _favoriteIds.remove(petId);
      }
      debugPrint('Error toggling favorite: $e');
    } finally {
      notifyListeners();
    }
  }
}
