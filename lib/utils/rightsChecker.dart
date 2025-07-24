import 'package:nhapp/utils/storage_utils.dart';

class RightsChecker {
  static Map<String, dynamic>? _cachedRights;

  // Key mappings for different features
  static const Map<String, String> _featureKeys = {
    'Functional Dashboard': '025009',
    'Director Dashboard': '025017',
    'Total Sales Region wise': '025000',
    'Purchase Order': '01139',
    'Purchase Order Print': '01109',
    'Service Order': '01112',
    'Service Order Print': '01125',
    'Labour PO': '01106',
    'Labour PO Print': '01109',
    'Lead': '06100',
    'Inquiry Print': '06101',
    'Follow Up': '06102',
    'Quotation': '06103',
    'Quotation Print': '06104',
    'Sales Order': '06105',
    'Sales Order Print': '06106',
    'Proforma Invoice': '06112',
    'Proforma Invoice Print': '06113',
  };

  // Rights constants
  static const String VIEW = 'I';
  static const String ADD = 'A';
  static const String EDIT = 'E';
  static const String DELETE = 'D';
  static const String AUTHORIZE = 'U';
  static const String PRINT = 'P';

  /// Initialize rights cache
  static Future<void> initializeRights() async {
    try {
      _cachedRights = await StorageUtils.readJson('user_rights');
    } catch (e) {
      _cachedRights = null;
    }
  }

  /// Check if user has specific right for a feature
  static bool hasRight(String featureName, String right) {
    if (_cachedRights == null) return false;

    final key = _featureKeys[featureName];
    if (key == null) return false;

    final userRights = _cachedRights!['userRights'] as List<dynamic>?;
    if (userRights == null) return false;

    for (final rightItem in userRights) {
      if (rightItem['key'] == key) {
        final rights = rightItem['rights'] as String?;
        return rights?.contains(right) ?? false;
      }
    }
    return false;
  }

  /// Check if user can view a feature
  static bool canView(String featureName) {
    return hasRight(featureName, VIEW);
  }

  /// Check if user can authorize a feature
  static bool canAuthorize(String featureName) {
    return hasRight(featureName, AUTHORIZE);
  }

  /// Check if user can add/create in a feature
  static bool canAdd(String featureName) {
    return hasRight(featureName, ADD);
  }

  /// Check if user can edit in a feature
  static bool canEdit(String featureName) {
    return hasRight(featureName, EDIT);
  }

  static bool canDelete(String featureName) {
    return hasRight(featureName, DELETE);
  }

  static bool canPrint(String featureName) {
    return hasRight(featureName, PRINT);
  }

  /// Get all visible features based on view rights
  static List<String> getVisibleFeatures() {
    final visibleFeatures = <String>[];
    for (final feature in _featureKeys.keys) {
      if (canView(feature)) {
        visibleFeatures.add(feature);
      }
    }
    return visibleFeatures;
  }

  /// Get features that user can authorize
  static List<String> getAuthorizableFeatures() {
    final authorizableFeatures = <String>[];
    for (final feature in _featureKeys.keys) {
      if (canAuthorize(feature)) {
        authorizableFeatures.add(feature);
      }
    }
    return authorizableFeatures;
  }
}
