# Add Quotation Feature - Technical Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [API Integration](#api-integration)
4. [User Interface](#user-interface)
5. [Data Models](#data-models)
6. [Validation Rules](#validation-rules)
7. [Error Handling](#error-handling)
8. [Usage Guide](#usage-guide)
9. [Testing](#testing)
10. [Troubleshooting](#troubleshooting)

## Overview

The Add Quotation feature allows users to create quotations either standalone or from existing leads. The implementation includes comprehensive form validation, API integration, and seamless lead-to-quotation conversion.

### Key Features
- ✅ Create quotations with/without inquiry reference
- ✅ Prefill quotation data from leads
- ✅ Dynamic form validation
- ✅ File attachment support
- ✅ Real-time totals calculation
- ✅ Date range validation
- ✅ Customer and item search

## Architecture

### File Structure
```
lib/pages/quotation/
├── pages/
│   ├── add_quotation_page.dart          # Main quotation form
│   └── add_quotation_item_page.dart     # Item management form
├── helper/
│   └── quotation_helper.dart            # Calculation utilities
└── models/ (uses Quotation2 models)

lib/pages/Quotation2/
├── models/
│   └── add_quotation.dart               # Data models
└── services/
    └── quotation_service.dart           # API service layer

lib/pages/leads/
└── pages/
    └── lead_details_page.dart           # Lead integration point
```

### Component Hierarchy
```
AddQuotationPage
├── Form Validation Layer
├── API Service Layer (QuotationFormService)
├── UI Components
│   ├── Lead Info Card (conditional)
│   ├── Form Fields
│   ├── Items Management
│   ├── Totals Summary
│   └── Attachments
└── Navigation Handler
```

## API Integration

### Required APIs (per app.md specifications)

#### 1. Document Settings
```dart
GET /api/Lead/GetDefaultDocumentDetail
Parameters:
- year: String (financial year)
- type: "SQ"
- subType: "SQ" 
- locationId: int

Response: Document configuration for quotation creation
```

#### 2. Quotation Base Options
```dart
GET /api/Quotation/QuotationBaseList

Response: [
  {"Code": "I", "Name": "With Inquiry Reference"},
  {"Code": "O", "Name": "Without Inquiry Reference"}
]
```

#### 3. Customer Search
```dart
POST /api/Quotation/QuotationGetCustomer
Body: {
  "PageSize": 100,
  "PageNumber": 1,
  "SearchValue": "search_term"
}

Response: List of customers with codes and names
```

#### 4. Salesman List
```dart
GET /api/Lead/LeadSalesManList

Response: List of salesmen with codes and full names
```

#### 5. Lead Numbers (Inquiry Reference)
```dart
GET /api/Quotation/QuotationInquirygetOpenInquiryNumberList
Parameters:
- CustomerCode: String
- UserLocationCodes: String

Response: List of open inquiry numbers for customer
```

#### 6. Item Search
```dart
POST /api/Lead/GetSalesItemList
Parameters: flag=L
Body: {
  "pageSize": 10,
  "pageNumber": 1,
  "searchValue": "search_term"
}

Response: List of sales items with codes, names, and UOM
```

#### 7. Tax Calculation
```dart
POST /api/Quotation/CalcRateStructure
Parameters: RateStructureCode
Body: {
  "ItemAmount": double,
  "BasicRate": double,
  "DiscType": string,
  "DiscValue": double,
  // ... other fields
}

Response: Calculated tax amounts and totals
```

#### 8. Quotation Submission
```dart
POST /api/Quotation/QuotationCreate
Body: {
  "QuotationDetails": { /* quotation header */ },
  "ModelDetails": [ /* item details */ ],
  "DiscountDetails": [ /* discount info */ ],
  // ... other sections
}

Response: Created quotation with ID and number
```

#### 9. Attachment Upload
```dart
POST /api/Quotation/uploadAttachmentNew
Content-Type: multipart/form-data
Fields:
- LocationID, CompanyID, DocumentNo, etc.
- AttachmentsFile: File[]

Response: Upload success status
```

## User Interface

### Form Layout

#### 1. Lead Information Card (Conditional)
```dart
// Shown only when creating from lead
Card(
  child: Column([
    Text('Lead Information'),
    Text('Lead No: ${leadData.inquiryNumber}'),
    Text('Customer: ${leadData.customerCode} - ${leadData.customerName}'),
    Text('Salesman: ${leadData.salesmanCode} - ${leadData.salesmanName}'),
  ])
)
```

#### 2. Main Form Fields
- **Quotation Base**: Dropdown (Required)
- **Quote To**: TypeAhead search (Required, min 4 chars)
- **Bill To**: TypeAhead search (Required, min 4 chars)
- **Salesman**: Dropdown (Required)
- **Lead Number**: Dropdown (Conditional - only for inquiry reference)
- **Subject To**: Text field (Required)
- **Date**: Date picker with validation (Required)

#### 3. Items Section
- Dynamic list of items
- Add/Edit/Delete functionality
- Real-time totals calculation

#### 4. Summary Card
```dart
Card(
  child: Column([
    Text('Basic Amount: ₹${totals.basic}'),
    Text('Discount: ₹${totals.discount}'),
    Text('Tax Amount: ₹${totals.tax}'),
    Divider(),
    Text('Total Amount: ₹${totals.total}', style: bold),
  ])
)
```

#### 5. Attachments Section
- File picker integration
- Multiple file support
- File list with remove option

### Navigation Flow

#### From Lead Details
```
Lead Details Page
    ↓ (Click "Create Quotation")
Add Quotation Page (prefilled)
    ↓ (Submit)
Success/Error Feedback
    ↓ (Success)
Return to Lead Details
```

#### Standalone Creation
```
Navigation Menu
    ↓ (Select "Add Quotation")
Add Quotation Page (empty)
    ↓ (Fill form and submit)
Success/Error Feedback
    ↓ (Success)
Return to previous page
```

## Data Models

### Core Models

#### QuotationBase
```dart
class QuotationBase {
  final String code;        // "I" or "O"
  final String name;        // Display name
  
  factory QuotationBase.fromJson(Map<String, dynamic> json);
}
```

#### QuotationCustomer
```dart
class QuotationCustomer {
  final String customerCode;
  final String customerName;
  final String customerFullName;  // Combined display
  
  factory QuotationCustomer.fromJson(Map<String, dynamic> json);
}
```

#### Salesman
```dart
class Salesman {
  final String salesmanCode;
  final String salesmanName;
  final String salesManFullName;  // Combined display
  
  factory Salesman.fromJson(Map<String, dynamic> json);
}
```

#### QuotationSubmissionData
```dart
class QuotationSubmissionData {
  final Map<String, dynamic> docDetail;
  final QuotationCustomer quoteTo;
  final QuotationCustomer billTo;
  final Salesman salesman;
  final String subject;
  final DateTime quotationDate;
  final String quotationYear;
  final int siteId;
  final int userId;
  final List<Map<String, dynamic>> items;
}
```

### Item Structure
```dart
Map<String, dynamic> item = {
  'itemCode': String,
  'itemName': String,
  'qty': double,
  'uom': String,
  'rate': double,
  'discountType': String,      // 'None', 'Percentage', 'Value'
  'discountValue': double,
  'rateStructure': String,
  'basicAmount': double,       // qty * rate
  'discountAmount': double,    // calculated discount
  'taxAmount': double,         // calculated tax
  'totalAmount': double,       // final amount after tax
};
```

## Validation Rules

### Form Validation

#### Required Fields
```dart
// All these fields must be filled
- Quotation Base: Must select from dropdown
- Quote To: Must select from search results
- Bill To: Must select from search results  
- Salesman: Must select from dropdown
- Subject To: Must enter text
- Date: Must select valid date
- Items: Must add at least one item
- Lead Number: Required only for inquiry reference
```

#### Date Validation
```dart
bool _validateDate() {
  // Must be within financial period
  if (_date.isBefore(_minDate)) return false;
  if (_date.isAfter(_maxDate)) return false;
  
  // Must not be in future
  if (_date.isAfter(DateTime.now())) return false;
  
  return true;
}
```

#### Business Rules
```dart
// Inquiry Reference Flow
if (_isInquiryReference) {
  // Lead number becomes required
  // Customer search may use different API
  // Additional validation for inquiry data
}

// Item Validation
if (_items.isEmpty) {
  showToast('Please add at least one item');
  return false;
}
```

### Input Validation

#### Customer Search
- Minimum 4 characters required
- TypeAhead with debouncing
- Selection required (not just text)

#### Item Management
- Item must be selected from search results
- Quantity must be positive number
- Rate must be valid number
- Discount percentage: 0-100
- Discount value: cannot exceed item amount

## Error Handling

### Error Categories

#### 1. Network Errors
```dart
try {
  final response = await _service.submitQuotation(data);
} catch (e) {
  showToast('Network error: Please check connection');
  setState(() => _submitting = false);
}
```

#### 2. API Errors
```dart
if (response['success'] != true) {
  final errorMessage = response['message'] ?? 
                      response['errorMessage'] ?? 
                      'Failed to create quotation';
  showToast(errorMessage);
}
```

#### 3. Validation Errors
```dart
if (!_formKey.currentState!.validate()) {
  showToast('Please fill all required fields');
  return;
}
```

#### 4. Business Logic Errors
```dart
if (_isInquiryReference && _selectedLeadNumber == null) {
  showToast('Please select a lead number');
  return;
}
```

### Error Recovery

#### Graceful Degradation
- Form remains editable after errors
- Data is preserved during error states
- User can retry operations
- Clear error messages guide user actions

#### Loading States
```dart
// Prevent multiple submissions
AbsorbPointer(
  absorbing: _submitting,
  child: Form(...)
)

// Show progress indicators
ElevatedButton(
  onPressed: _submitting ? null : _submit,
  child: _submitting 
    ? CircularProgressIndicator()
    : Text('Create Quotation'),
)
```

## Usage Guide

### For Developers

#### Adding New Validation Rules
```dart
// In _submit() method, add before API call
if (!_customValidation()) {
  showToast('Custom validation failed');
  return;
}

bool _customValidation() {
  // Add your validation logic
  return true;
}
```

#### Extending Form Fields
```dart
// Add new field to form
TextFormField(
  controller: _newFieldController,
  decoration: InputDecoration(labelText: 'New Field'),
  validator: (val) => val?.isEmpty == true ? 'Required' : null,
),

// Add to submission data
final submissionData = QuotationSubmissionData(
  // ... existing fields
  newField: _newFieldController.text,
);
```

#### Customizing Lead Prefill
```dart
void _prefillFromLead() {
  // Modify this method to add new prefill logic
  if (widget.leadData != null) {
    // Add custom prefill logic here
  }
}
```

### For Users

#### Creating Quotation from Lead
1. Navigate to Leads → View Lead Details
2. Click "Create Quotation" button
3. Review prefilled information
4. Modify or add items as needed
5. Add attachments if required
6. Click "Create Quotation"

#### Creating Standalone Quotation
1. Navigate to Quotations → Add New
2. Select quotation base (with/without inquiry)
3. Search and select customers
4. Choose salesman
5. Enter subject and select date
6. Add items using "Add Item" button
7. Review totals and submit

#### Item Management
1. Click "Add Item" to open item form
2. Search for item (minimum 4 characters)
3. Select item from dropdown
4. Enter quantity and rate
5. Choose discount type and value
6. Select rate structure
7. Save item

## Testing

### Unit Tests

#### Service Layer Tests
```dart
group('QuotationFormService', () {
  test('should fetch quotation bases', () async {
    final service = QuotationFormService();
    final bases = await service.fetchQuotationBases();
    expect(bases, isNotEmpty);
  });
  
  test('should search customers', () async {
    final service = QuotationFormService();
    final customers = await service.searchCustomers('test');
    expect(customers, isList);
  });
});
```

#### Validation Tests
```dart
group('Form Validation', () {
  test('should validate required fields', () {
    final formKey = GlobalKey<FormState>();
    // Test form validation logic
  });
  
  test('should validate date range', () {
    final page = AddQuotationPageState();
    // Test date validation
  });
});
```

### Integration Tests

#### End-to-End Flow
```dart
testWidgets('should create quotation from lead', (tester) async {
  // 1. Navigate to lead details
  // 2. Tap create quotation button
  // 3. Verify prefilled data
  // 4. Fill remaining fields
  // 5. Submit form
  // 6. Verify success
});
```

#### API Integration Tests
```dart
group('API Integration', () {
  test('should submit quotation successfully', () async {
    // Mock API responses
    // Test complete submission flow
  });
});
```

### Manual Testing Checklist

#### Form Validation
- [ ] All required fields show validation errors
- [ ] Date picker respects min/max dates
- [ ] Customer search requires 4+ characters
- [ ] Item validation works correctly
- [ ] Lead number appears for inquiry reference

#### Lead Integration
- [ ] Button appears in lead details
- [ ] Navigation works correctly
- [ ] Data prefills accurately
- [ ] Items transfer properly
- [ ] Success feedback displays

#### Error Scenarios
- [ ] Network errors handled gracefully
- [ ] API errors show user-friendly messages
- [ ] Form remains usable after errors
- [ ] Loading states prevent double submission

## Troubleshooting

### Common Issues

#### 1. "Failed to fetch quotation bases"
**Cause**: API endpoint not accessible or authentication issue
**Solution**: 
- Check network connectivity
- Verify API base URL in storage
- Confirm authentication token validity

#### 2. "Please select an item from the list"
**Cause**: User typed item name but didn't select from dropdown
**Solution**: 
- Clear the field and search again
- Select item from the dropdown list
- Don't manually type item names

#### 3. "Date should be within the financial period"
**Cause**: Selected date is outside company's financial year
**Solution**:
- Check company financial period settings
- Select date within the allowed range
- Contact admin if period seems incorrect

#### 4. "No Open Inquiry Found"
**Cause**: Customer has no open inquiries for quotation
**Solution**:
- Verify customer has active inquiries
- Check if inquiries are in correct status
- Use "Without Inquiry Reference" option

#### 5. Attachment upload fails
**Cause**: File size too large or network issues
**Solution**:
- Check file size limits
- Retry upload with stable connection
- Contact support if issue persists

### Debug Information

#### Logging
```dart
// Enable debug logging in service
class QuotationFormService {
  QuotationFormService() {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true, 
        responseBody: true, 
        error: true
      ),
    );
  }
}
```

#### Storage Inspection
```dart
// Check stored data
final docDetail = await StorageUtils.readJson("docDetail");
final userDetails = await StorageUtils.readJson('user_details');
final companyDetails = await StorageUtils.readJson('selected_company');
```

#### Network Debugging
- Check API responses in browser dev tools
- Verify request headers include authentication
- Confirm request body format matches API expectations

### Performance Optimization

#### Caching Strategies
```dart
// Cache dropdown data
class QuotationFormService {
  List<QuotationBase>? _cachedBases;
  
  Future<List<QuotationBase>> fetchQuotationBases() async {
    if (_cachedBases != null) return _cachedBases!;
    
    _cachedBases = await _fetchFromAPI();
    return _cachedBases!;
  }
}
```

#### Memory Management
- Dispose controllers in dispose() method
- Clear large data structures when not needed
- Use const constructors where possible

---

## Support

For technical support or feature requests:
1. Check this documentation first
2. Review error logs and debug information
3. Test with minimal reproduction case
4. Contact development team with detailed information

**Last Updated**: December 2024
**Version**: 1.0.0
**Author**: Development Team