import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageUtils {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Write a string value to secure storage
  static Future<void> writeValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a string value from secure storage
  /// Returns null if the key doesn't exist
  static Future<String?> readValue(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a value from secure storage
  static Future<void> deleteValue(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all values from secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Write a JSON object to secure storage
  /// The object will be converted to a JSON string
  static Future<void> writeJson(String key, dynamic jsonObject) async {
    if (jsonObject != null) {
      final jsonString = jsonEncode(jsonObject);
      await writeValue(key, jsonString);
    }
  }

  /// Read a JSON object from secure storage
  /// Returns null if the key doesn't exist or if the value isn't valid JSON
  static Future<dynamic> readJson(String key) async {
    final jsonString = await readValue(key);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error parsing JSON from storage key $key: $e');
      return null;
    }
  }

  /// Read a specific value from a stored JSON object
  /// Example: await StorageUtils.readJsonValue('user_data', 'email');
  static Future<dynamic> readJsonValue(String key, String field) async {
    final jsonData = await readJson(key);
    if (jsonData == null || jsonData is! Map) {
      return null;
    }

    return jsonData[field];
  }

  /// Check if a key exists in secure storage
  static Future<bool> hasKey(String key) async {
    final value = await readValue(key);
    return value != null;
  }

  /// Update a specific field in a stored JSON object
  /// If the object doesn't exist, it will create a new one
  static Future<void> updateJsonField(
    String key,
    String field,
    dynamic value,
  ) async {
    Map<String, dynamic> jsonData = await readJson(key) ?? {};
    jsonData[field] = value;
    await writeJson(key, jsonData);
  }

  /// Delete a specific field from a stored JSON object
  static Future<void> deleteJsonField(String key, String field) async {
    Map<String, dynamic> jsonData = await readJson(key) ?? {};
    if (jsonData.containsKey(field)) {
      jsonData.remove(field);
      await writeJson(key, jsonData);
    }
  }

  /// save a boolean value to secure storage
  static Future<void> writeBool(String key, bool value) async {
    await _storage.write(key: key, value: value.toString());
  }

  /// read a boolean value from secure storage
  static Future<bool> readBool(String key) async {
    final value = await _storage.read(key: key);
    return value != null ? value.toLowerCase() == 'true' : false;
  }

  /// delete a boolean value from secure storage
  static Future<void> deleteBool(String key) async {
    await _storage.delete(key: key);
  }
}
