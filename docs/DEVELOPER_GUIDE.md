# Add Quotation Feature - Developer Guide

## Quick Start

### Prerequisites
- Flutter SDK 3.7.2+
- Dart 3.0+
- Android Studio / VS Code
- Git

### Setup
1. Clone the repository
2. Run `flutter pub get`
3. Configure API endpoints in storage
4. Run `flutter run`

## Code Architecture

### Design Patterns

#### 1. Service Layer Pattern
```dart
// Service handles all API communication
class QuotationFormService {
  final Dio _dio = Dio();
  
  Future<List<QuotationBase>> fetchQuotationBases() async {
    // API call implementation
  }
}
```

#### 2. Model-View-Controller (MVC)
```dart
// Model: Data structures
class QuotationSubmissionData { ... }

// View: UI Components  
class AddQuotationPage extends StatefulWidget { ... }

// Controller: Business logic in service layer
class QuotationFormService { ... }
```

#### 3. Repository Pattern
```dart
// Abstract interface
abstract class QuotationRepository {
  Future<List<QuotationBase>> getQuotationBases();
}

// Implementation
class ApiQuotationRepository implements QuotationRepository {
  @override
  Future<List<QuotationBase>> getQuotationBases() async {
    // API implementation
  }
}
```

### State Management

#### Form State
```dart
class _AddQuotationPageState extends State<AddQuotationPage> {
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quoteToController = TextEditingController();
  
  // State variables
  bool _loading = true;
  bool _submitting = false;
  List<Map<String, dynamic>> _items = [];
  
  @override
  void dispose() {
    // Clean up controllers
    _quoteToController.dispose();
    super.dispose();
  }
}
```

#### Loading States
```dart
// Show loading indicator
if (_loading) {
  return const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );
}

// Disable form during submission
AbsorbPointer(
  absorbing: _submitting,
  child: Form(...)
)
```

### Error Handling Strategy

#### Layered Error Handling
```dart
// 1. Service Layer - Network errors
try {
  final response = await _dio.post(endpoint, data: body);
  return response.data;
} catch (e) {
  throw NetworkException('Failed to connect: $e');
}

// 2. Business Layer - API errors  
if (response['success'] != true) {
  throw ApiException(response['message'] ?? 'Unknown error');
}

// 3. UI Layer - User feedback
try {
  await _service.submitQuotation(data);
  showToast('Success!');
} catch (e) {
  showToast('Error: $e');
}
```

#### Custom Exceptions
```dart
class QuotationException implements Exception {
  final String message;
  final String? code;
  
  QuotationException(this.message, {this.code});
  
  @override
  String toString() => 'QuotationException: $message';
}

class ValidationException extends QuotationException {
  ValidationException(String message) : super(message, code: 'VALIDATION');
}

class NetworkException extends QuotationException {
  NetworkException(String message) : super(message, code: 'NETWORK');
}
```

## Code Organization

### File Structure
```
lib/pages/quotation/
├── pages/
│   ├── add_quotation_page.dart      # Main form UI
│   └── add_quotation_item_page.dart # Item management UI
├── models/                          # Data models (uses Quotation2)
├── services/                        # API services (uses Quotation2)
└── helper/
    └── quotation_helper.dart        # Utility functions

lib/pages/Quotation2/               # Shared models and services
├── models/
│   └── add_quotation.dart          # Core data models
└── services/
    └── quotation_service.dart      # API service implementation
```

### Naming Conventions

#### Classes
```dart
// PascalCase for classes
class AddQuotationPage extends StatefulWidget { }
class QuotationFormService { }
class QuotationSubmissionData { }
```

#### Variables and Methods
```dart
// camelCase for variables and methods
final TextEditingController _quoteToController;
bool _isInquiryReference;
Future<void> _loadInitialData() async { }
```

#### Constants
```dart
// UPPER_SNAKE_CASE for constants
static const String API_ENDPOINT = '/api/Quotation/QuotationCreate';
static const int MAX_ITEMS = 100;
```

#### Files
```dart
// snake_case for files
add_quotation_page.dart
quotation_service.dart
lead_detail_data.dart
```

## API Integration

### Service Implementation

#### Base Service Setup
```dart
class QuotationFormService {
  final Dio _dio = Dio();
  
  QuotationFormService() {
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }
  
  Future<void> _setupHeaders() async {
    final baseUrl = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    final tokenDetails = await StorageUtils.readJson('session_token');
    
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'companyid': companyDetails['id'].toString(),
      'Authorization': 'Bearer ${tokenDetails['token']['value']}',
    };
    
    _dio.options.baseUrl = 'http://$baseUrl';
  }
}
```

#### API Method Pattern
```dart
Future<List<T>> _fetchList<T>(
  String endpoint,
  T Function(Map<String, dynamic>) fromJson,
  {Map<String, dynamic>? queryParams}
) async {
  try {
    await _setupHeaders();
    final response = await _dio.get(endpoint, queryParameters: queryParams);
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => fromJson(e))
          .toList();
    }
    
    throw ApiException('Failed to fetch data: ${response.data['message']}');
  } catch (e) {
    debugPrint('Error fetching $endpoint: $e');
    rethrow;
  }
}

// Usage
Future<List<QuotationBase>> fetchQuotationBases() async {
  return _fetchList(
    '/api/Quotation/QuotationBaseList',
    QuotationBase.fromJson,
  );
}
```

### Response Handling

#### Standard Response Format
```dart
class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final List<String>? errors;
  
  ApiResponse({this.data, required this.success, this.message, this.errors});
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      success: json['success'] ?? false,
      message: json['message'],
      errors: json['errors']?.cast<String>(),
    );
  }
}
```

#### Error Response Handling
```dart
Future<T> _handleResponse<T>(
  Future<Response> request,
  T Function(Map<String, dynamic>) fromJson,
) async {
  try {
    final response = await request;
    final apiResponse = ApiResponse.fromJson(response.data, fromJson);
    
    if (apiResponse.success && apiResponse.data != null) {
      return apiResponse.data!;
    }
    
    throw ApiException(
      apiResponse.message ?? 'Unknown error',
      errors: apiResponse.errors,
    );
  } on DioException catch (e) {
    throw NetworkException(_getDioErrorMessage(e));
  }
}

String _getDioErrorMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return 'Connection timeout';
    case DioExceptionType.receiveTimeout:
      return 'Receive timeout';
    case DioExceptionType.badResponse:
      return 'Server error: ${e.response?.statusCode}';
    default:
      return 'Network error: ${e.message}';
  }
}
```

## UI Development

### Form Validation

#### Custom Validators
```dart
class QuotationValidators {
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }
  
  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '${fieldName ?? 'This field'} must be a positive number';
    }
    
    return null;
  }
  
  static String? dateRange(DateTime? date, DateTime? min, DateTime? max) {
    if (date == null) return 'Date is required';
    
    if (min != null && date.isBefore(min)) {
      return 'Date must be after ${DateFormat('dd/MM/yyyy').format(min)}';
    }
    
    if (max != null && date.isAfter(max)) {
      return 'Date must be before ${DateFormat('dd/MM/yyyy').format(max)}';
    }
    
    return null;
  }
}
```

#### Form Field Widgets
```dart
class QuotationFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool required;
  final TextInputType? keyboardType;
  
  const QuotationFormField({
    Key? key,
    required this.label,
    required this.controller,
    this.validator,
    this.required = false,
    this.keyboardType,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}
```

### TypeAhead Implementation

#### Custom TypeAhead Widget
```dart
class QuotationTypeAhead<T> extends StatelessWidget {
  final TextEditingController controller;
  final Future<List<T>> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T) onSelected;
  final String? Function(String?)? validator;
  final String labelText;
  final int minCharsForSuggestions;
  
  const QuotationTypeAhead({
    Key? key,
    required this.controller,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSelected,
    required this.labelText,
    this.validator,
    this.minCharsForSuggestions = 4,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      controller: controller,
      suggestionsCallback: (pattern) async {
        if (pattern.length < minCharsForSuggestions) return [];
        return await suggestionsCallback(pattern);
      },
      builder: (context, controller, focusNode) => TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
      itemBuilder: itemBuilder,
      onSelected: onSelected,
      emptyBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Type at least $minCharsForSuggestions characters to search'),
      ),
    );
  }
}
```

### Loading States

#### Loading Overlay
```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  
  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
```

## Testing

### Unit Testing

#### Service Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('QuotationFormService', () {
    late QuotationFormService service;
    late MockDio mockDio;
    
    setUp(() {
      mockDio = MockDio();
      service = QuotationFormService();
      // Inject mock dio
    });
    
    test('should fetch quotation bases successfully', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'success': true,
          'data': [
            {'Code': 'I', 'Name': 'With Inquiry Reference'}
          ]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      
      when(mockDio.get(any)).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await service.fetchQuotationBases();
      
      // Assert
      expect(result, isA<List<QuotationBase>>());
      expect(result.length, 1);
      expect(result.first.code, 'I');
    });
    
    test('should handle API errors', () async {
      // Arrange
      when(mockDio.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      
      // Act & Assert
      expect(
        () => service.fetchQuotationBases(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

#### Widget Tests
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddQuotationPage', () {
    testWidgets('should show loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddQuotationPage(),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddQuotationPage(),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Try to submit without filling fields
      await tester.tap(find.text('Create Quotation'));
      await tester.pump();
      
      // Should show validation errors
      expect(find.text('Select Quotation Base'), findsOneWidget);
      expect(find.text('Select Quote To'), findsOneWidget);
    });
  });
}
```

### Integration Testing

#### End-to-End Tests
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Quotation Creation Flow', () {
    testWidgets('should create quotation from lead', (tester) async {
      // Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to leads
      await tester.tap(find.text('Leads'));
      await tester.pumpAndSettle();
      
      // Open first lead
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      // Tap create quotation
      await tester.tap(find.text('Create Quotation'));
      await tester.pumpAndSettle();
      
      // Verify prefilled data
      expect(find.textContaining('Lead Information'), findsOneWidget);
      
      // Add an item
      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();
      
      // Fill item form
      await tester.enterText(find.byType(TypeAheadField).first, 'test item');
      await tester.pump(Duration(milliseconds: 500));
      await tester.tap(find.text('TEST-ITEM - Test Item'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(Key('qty_field')), '10');
      await tester.enterText(find.byKey(Key('rate_field')), '100');
      
      await tester.tap(find.text('Save Item'));
      await tester.pumpAndSettle();
      
      // Submit quotation
      await tester.tap(find.text('Create Quotation'));
      await tester.pumpAndSettle();
      
      // Verify success
      expect(find.text('Quotation created successfully!'), findsOneWidget);
    });
  });
}
```

## Performance Optimization

### Caching Strategies

#### Memory Caching
```dart
class CachedQuotationService extends QuotationFormService {
  static final Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  
  Future<List<QuotationBase>> fetchQuotationBases() async {
    const cacheKey = 'quotation_bases';
    
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey];
      if (DateTime.now().difference(cached['timestamp']) < _cacheExpiry) {
        return cached['data'] as List<QuotationBase>;
      }
    }
    
    final data = await super.fetchQuotationBases();
    _cache[cacheKey] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
    
    return data;
  }
}
```

#### Persistent Caching
```dart
class PersistentCache {
  static const String _keyPrefix = 'quotation_cache_';
  
  static Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_keyPrefix$key');
    
    if (jsonString != null) {
      final data = json.decode(jsonString);
      final timestamp = DateTime.parse(data['timestamp']);
      
      if (DateTime.now().difference(timestamp) < Duration(hours: 1)) {
        return fromJson(data['value']);
      }
    }
    
    return null;
  }
  
  static Future<void> set<T>(
    String key,
    T value,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'value': toJson(value),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString('$_keyPrefix$key', json.encode(data));
  }
}
```

### Memory Management

#### Dispose Pattern
```dart
class _AddQuotationPageState extends State<AddQuotationPage> {
  late final List<TextEditingController> _controllers;
  late final List<StreamSubscription> _subscriptions;
  
  @override
  void initState() {
    super.initState();
    _controllers = [
      _quoteToController,
      _billToController,
      _subjectToController,
    ];
  }
  
  @override
  void dispose() {
    // Dispose controllers
    for (final controller in _controllers) {
      controller.dispose();
    }
    
    // Cancel subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    
    super.dispose();
  }
}
```

#### Image and File Handling
```dart
class AttachmentManager {
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedExtensions = ['.pdf', '.jpg', '.png', '.doc'];
  
  static Future<List<PlatformFile>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions.map((e) => e.substring(1)).toList(),
    );
    
    if (result != null) {
      // Filter by size
      final validFiles = result.files.where((file) {
        return file.size <= maxFileSize;
      }).toList();
      
      if (validFiles.length != result.files.length) {
        showToast('Some files were too large and were excluded');
      }
      
      return validFiles;
    }
    
    return [];
  }
}
```

## Debugging

### Logging

#### Custom Logger
```dart
class QuotationLogger {
  static const String _tag = 'QUOTATION';
  
  static void debug(String message) {
    if (kDebugMode) {
      print('[$_tag] DEBUG: $message');
    }
  }
  
  static void info(String message) {
    print('[$_tag] INFO: $message');
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('[$_tag] ERROR: $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('Stack: $stackTrace');
  }
  
  static void api(String method, String url, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      print('[$_tag] API: $method $url');
      if (data != null) print('Data: ${json.encode(data)}');
    }
  }
}
```

#### Debug Utilities
```dart
class DebugUtils {
  static void printFormData(GlobalKey<FormState> formKey) {
    if (kDebugMode) {
      final form = formKey.currentState;
      if (form != null) {
        print('Form valid: ${form.validate()}');
        // Print field values
      }
    }
  }
  
  static void printApiResponse(Response response) {
    if (kDebugMode) {
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Data: ${json.encode(response.data)}');
    }
  }
}
```

### Error Tracking

#### Crash Reporting
```dart
class CrashReporter {
  static void initialize() {
    FlutterError.onError = (details) {
      // Send to crash reporting service
      _reportError(details.exception, details.stack);
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack);
      return true;
    };
  }
  
  static void _reportError(Object error, StackTrace? stack) {
    // Implementation depends on crash reporting service
    // e.g., Firebase Crashlytics, Sentry, etc.
  }
  
  static void recordError(String context, Object error, [StackTrace? stack]) {
    _reportError('$context: $error', stack);
  }
}
```

## Deployment

### Build Configuration

#### Environment Variables
```dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
  static const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING');
}
```

#### Build Commands
```bash
# Development build
flutter build apk --debug --dart-define=API_BASE_URL=http://dev-server.com

# Production build
flutter build apk --release --dart-define=API_BASE_URL=http://prod-server.com --dart-define=PRODUCTION=true

# Build with logging disabled
flutter build apk --release --dart-define=ENABLE_LOGGING=false
```

### Code Obfuscation
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

---

## Best Practices

### Code Quality

#### 1. Follow Dart Style Guide
- Use `dart format` for consistent formatting
- Follow naming conventions
- Add documentation comments

#### 2. Error Handling
- Always handle exceptions
- Provide user-friendly error messages
- Log errors for debugging

#### 3. Performance
- Dispose resources properly
- Use const constructors where possible
- Implement caching for frequently accessed data

#### 4. Testing
- Write unit tests for business logic
- Add widget tests for UI components
- Include integration tests for critical flows

#### 5. Security
- Validate all user inputs
- Sanitize data before API calls
- Store sensitive data securely

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] All methods have proper error handling
- [ ] Resources are disposed properly
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] Performance impact is considered
- [ ] Security implications are reviewed

---

**Last Updated**: December 2024
**Version**: 1.0.0
**Maintainer**: Development Team