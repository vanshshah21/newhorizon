/// Optimized function to parse web response into mobile rights
Map<String, dynamic> parseMobileRights(
  Map<String, dynamic> webResponse, [
  List<String>? customKeys,
]) {
  // Default mobile keys from user rights.txt
  final keys =
      customKeys ??
      [
        "025009",
        "025017",
        "025000",
        "01139",
        "01109",
        "01112",
        "01125",
        "01106",
        "06100",
        "06101",
        "06102",
        "06103",
        "06104",
        "06105",
        "06106",
        "06112",
        "06113",
      ];

  try {
    final features = <Map<String, dynamic>>[];

    /// Recursive function to extract features
    void extract(List items) {
      for (final item in items) {
        if (item['key'] != null && keys.contains(item['key'])) {
          features.add({
            'title': item['title'],
            'url': item['url'],
            'rights': item['rights'],
            'key': item['key'],
            'order': item['order'],
            'pageUrl': item['pageUrl'],
          });
        }
        if (item['childs'] is List) extract(item['childs']);
      }
    }

    // Parse all menu items
    for (final group in (webResponse['data'] as List? ?? [])) {
      if (group['menuItems'] is List) extract(group['menuItems']);
    }

    // Sort by order
    features.sort(
      (a, b) => (int.tryParse(a['order'] ?? '0') ?? 0).compareTo(
        int.tryParse(b['order'] ?? '0') ?? 0,
      ),
    );

    return {
      'success': true,
      'message': 'Filtered user rights retrieved successfully',
      'totalItems': features.length,
      'userRights': features,
      'metadata': {
        'filteredAt': DateTime.now().toIso8601String(),
        'filterCriteria': 'user_rights_keys',
        'originalResponseSuccess': webResponse['success'] == true,
      },
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Failed to filter user rights',
      'totalItems': 0,
      'userRights': <Map>[],
      'metadata': {
        'filteredAt': DateTime.now().toIso8601String(),
        'filterCriteria': 'error',
        'originalResponseSuccess': false,
        'error': e.toString(),
      },
    };
  }
}
