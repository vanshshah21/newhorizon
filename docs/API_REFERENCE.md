# Add Quotation API Reference

## Overview
This document provides detailed API specifications for the Add Quotation feature, including request/response formats, error codes, and usage examples.

## Base Configuration

### Headers
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
companyid: {company_id}
```

### Base URL
```
http://{server_url}
```

## API Endpoints

### 1. Get Default Document Detail

Retrieves document configuration for quotation creation.

**Endpoint**: `GET /api/Lead/GetDefaultDocumentDetail`

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| year | string | Yes | Financial year (e.g., "25-26") |
| type | string | Yes | Document type ("SQ") |
| subType | string | Yes | Document subtype ("SQ") |
| locationId | integer | Yes | Location ID |

**Example Request**:
```http
GET /api/Lead/GetDefaultDocumentDetail?year=25-26&type=SQ&subType=SQ&locationId=8
```

**Example Response**:
```json
{
  "data": [{
    "documentString": "YY-YY/GR/LOC/NNNNNN",
    "lastSrNo": "0",
    "groupCode": "QA",
    "locationId": 8,
    "locationCode": "CT2",
    "locationName": "CTPL Unit2",
    "isDefault": "N",
    "isLocationRequired": true,
    "isAutoNumberGenerated": true,
    "isAutorisationRequired": true,
    "groupDescription": "QUATATION ENTRY",
    "locationFullName": "CT2 - CTPL Unit2",
    "groupFullName": "QA - QUATATION ENTRY"
  }],
  "message": null,
  "errors": null,
  "success": true
}
```

### 2. Get Quotation Base List

Retrieves available quotation base options.

**Endpoint**: `GET /api/Quotation/QuotationBaseList`

**Example Request**:
```http
GET /api/Quotation/QuotationBaseList
```

**Example Response**:
```json
{
  "data": [
    {"Code": "I", "Name": "With Inquiry Reference"},
    {"Code": "O", "Name": "Without Inquiry Reference"}
  ],
  "success": true,
  "message": null,
  "errors": null
}
```

### 3. Search Customers

Searches for customers based on search criteria.

**Endpoint**: `POST /api/Quotation/QuotationGetCustomer`

**Request Body**:
```json
{
  "PageSize": 100,
  "PageNumber": 1,
  "SortField": "",
  "SortDirection": "",
  "SearchValue": "search_term"
}
```

**Example Response**:
```json
{
  "data": [
    {
      "customerCode": "003",
      "customerName": "ABC Company",
      "customerFullName": "003 - ABC Company"
    }
  ],
  "success": true,
  "message": null,
  "errors": null
}
```

### 4. Get Salesman List

Retrieves list of available salesmen.

**Endpoint**: `GET /api/Lead/LeadSalesManList`

**Example Response**:
```json
{
  "data": [
    {
      "salesmanCode": "006",
      "salesmanName": "John Doe",
      "salesManFullName": "006 - John Doe"
    }
  ],
  "success": true,
  "message": null,
  "errors": null
}
```

### 5. Get Open Inquiry Numbers

Retrieves open inquiry numbers for a specific customer.

**Endpoint**: `GET /api/Quotation/QuotationInquirygetOpenInquiryNumberList`

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| CustomerCode | string | Yes | Customer code |
| UserLocationCodes | string | Yes | Location codes (e.g., "'CT2'") |

**Example Request**:
```http
GET /api/Quotation/QuotationInquirygetOpenInquiryNumberList?CustomerCode=003&UserLocationCodes='CT2'
```

**Example Response**:
```json
{
  "data": ["000093", "000094", "000095"],
  "success": true,
  "message": null,
  "errors": null
}
```

### 6. Search Sales Items

Searches for sales items based on search criteria.

**Endpoint**: `POST /api/Lead/GetSalesItemList?flag=L`

**Request Body**:
```json
{
  "pageSize": 10,
  "pageNumber": 1,
  "sortField": "",
  "sortDirection": "",
  "searchValue": "search_term"
}
```

**Example Response**:
```json
{
  "data": [
    {
      "itemCode": "ITEM001",
      "itemName": "Sample Item",
      "salesUOM": "PCS",
      "salesItemFullName": "ITEM001 - Sample Item"
    }
  ],
  "success": true,
  "message": null,
  "errors": null
}
```

### 7. Get Discount Codes

Retrieves available discount codes.

**Endpoint**: `GET /api/Quotation/QuotationGetDiscount`

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| codeType | string | Yes | Code type ("DD") |
| codeValue | string | Yes | Code value ("GEN") |

**Example Response**:
```json
{
  "data": [
    {
      "code": "01",
      "codeFullName": "General Discount"
    }
  ],
  "success": true,
  "message": null,
  "errors": null
}
```

### 8. Get Rate Structures

Retrieves available rate structures for sales.

**Endpoint**: `GET /api/Quotation/QuotationGetRateStructureForSales`

**Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| companyID | integer | Yes | Company ID |
| currencyCode | string | Yes | Currency code ("INR") |

**Example Response**:
```json
{
  "data": [
    {
      "rateStructCode": "STD",
      "rateStructFullName": "Standard Rate Structure"
    }
  ],
  "success": true,
  "message": null,
  "errors": null
}
```

### 9. Calculate Tax

Calculates tax for an item based on rate structure.

**Endpoint**: `POST /api/Quotation/CalcRateStructure?RateStructureCode={code}`

**Request Body**:
```json
{
  "ItemAmount": 1000.00,
  "ExchangeRt": "1",
  "DomCurrency": "INR",
  "CurrencyCode": "INR",
  "DiscType": "Percentage",
  "BasicRate": 100.00,
  "DiscValue": 10.00,
  "From": "sales",
  "Flag": "",
  "TotalItemAmount": 1000.00,
  "LandedPrice": 0,
  "uniqueno": 0,
  "RateCode": "STD",
  "RateStructureDetails": [],
  "rateType": "S",
  "IsView": false
}
```

**Example Response**:
```json
{
  "data": {
    "itemLandedCost": 1080.00,
    "totalExclusiveDomCurrAmount": 80.00,
    "itemLandedInvCost": 1000.00
  },
  "success": true,
  "message": null,
  "errors": null
}
```

### 10. Create Quotation

Creates a new quotation with all details.

**Endpoint**: `POST /api/Quotation/QuotationCreate`

**Request Body**:
```json
{
  "AddOnDetails": null,
  "AuthorizationDate": "0001-01-01T00:00:00",
  "AuthorizationRequired": "Y",
  "AutoNumberRequired": "Y",
  "CompanyId": 1,
  "DiscountDetails": [
    {
      "AmendSrNo": 0,
      "CurrencyCode": "INR",
      "DiscountCode": "01",
      "DiscountType": "Percentage",
      "DiscountValue": 100.00,
      "SalesItemCode": "ITEM001"
    }
  ],
  "DocSubType": "SQ",
  "DocType": "SQ",
  "DomesticCurrencyCode": "INR",
  "EquipmentAttributeDetails": null,
  "FromLocationCode": "CT2",
  "FromLocationId": 8,
  "FromLocationName": "CTPL Unit2",
  "HistoryDetails": null,
  "IP": null,
  "MAC": null,
  "ModelDetails": [
    {
      "AgentCode": "",
      "AgentCommisionTypeText": "NONE",
      "AgentCommisionValue": 0,
      "AllQty": 0,
      "AlreadyInvoiceBasicValue": 0,
      "AmendmentCBOMChange": "A",
      "AmendmentCBOMChangeText": "NOTAPPLICABLE",
      "AmendmentChargable": "A",
      "AmendmentChargableText": "NOTAPPLICABLE",
      "AmendmentGroup": "",
      "AmendmentNo": "",
      "AmendmentSiteId": 0,
      "AmendmentSrNo": 0,
      "AmendmentYear": "",
      "ApplicationCode": "",
      "BasicPriceIUOM": 100.00,
      "BasicPriceSUOM": 100.00,
      "CancelQty": 0,
      "ConversionFactor": 1,
      "CurrencyCode": "INR",
      "CustomerPOItemSrNo": "1",
      "DeliveryDay": 0,
      "DiscountAmt": 10.00,
      "DiscountType": "Percentage",
      "DiscountTypeText": "PERCENTAGE",
      "DiscountValue": 10.00,
      "DrawingNo": "",
      "GroupId": 0,
      "InvoiceMethod": "Q",
      "InvoiceType": "Regular",
      "InvoiceTypeShortText": "R",
      "IsSubItem": false,
      "ItemAmountAfterDisc": 900.00,
      "ItemLineNo": 1,
      "ItemOrderQty": 0,
      "OriginalBasicPrice": 0,
      "QtyIUOM": 10,
      "QtySUOM": 10,
      "QuotationAmendNo": 0,
      "QuotationId": 0,
      "QuotationLineNo": 1,
      "RateStructureCode": "STD",
      "SalesItemCode": "ITEM001",
      "SalesItemDesc": "Sample Item",
      "SalesItemType": "S",
      "SectionId": 0,
      "SubGroupId": 0,
      "SubProjectId": 0,
      "TagNo": "",
      "Tolerance": 0
    }
  ],
  "NoteDetails": null,
  "QuotationDetails": {
    "AttachFlag": "",
    "BillToCustomerCode": "003",
    "CustomerCode": "003",
    "CustomerInqRefNo": "",
    "CustomerName": "ABC Company",
    "DiscountAmount": 100.00,
    "DiscountType": "None",
    "DiscountTypeText": "",
    "ExchangeRate": 1,
    "IsAgentAssociated": false,
    "IsBudgetaryQuotation": false,
    "ModValue": 0,
    "ProjectItemId": 0,
    "QtnStatus": "O",
    "QuotationDate": "2025-01-01T00:00:00",
    "QuotationGroup": "QA",
    "QuotationId": 0,
    "QuotationNumber": "0",
    "QuotationSiteCode": "CT2",
    "QuotationSiteId": 8,
    "QuotationStatus": "NS",
    "QuotationTypeConfig": "3",
    "QuotationTypeSalesOrder": "REG",
    "QuotationYear": "24-25",
    "SalesPersonCode": "006 - John Doe",
    "Subject": "Sample Quotation",
    "SubmittedDate": null,
    "TotalAmountAfterDiscountCustomerCurrency": 900.00,
    "TotalAmountAfterTaxCustomerCurrency": 980.00,
    "TotalAmounttAfterTaxDomesticCurrency": 980.00,
    "Validity": 30
  },
  "QuotationRemarks": null,
  "QuotationTextDetails": null,
  "RateStructureDetails": [],
  "SiteRequired": "Y",
  "StandardTerms": null,
  "SubItemDetails": null,
  "TermDetails": null,
  "UserId": 2,
  "msctechspecifications": false,
  "technicalspec": null
}
```

**Example Response**:
```json
{
  "data": {
    "quotationDetails": {
      "quotationId": 12345,
      "quotationNumber": "000190"
    }
  },
  "success": true,
  "message": "Quotation created successfully",
  "errors": null
}
```

### 11. Upload Attachments

Uploads attachments for a quotation.

**Endpoint**: `POST /api/Quotation/uploadAttachmentNew`

**Content-Type**: `multipart/form-data`

**Form Fields**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| LocationID | string | Yes | Location ID |
| CompanyID | string | Yes | Company ID |
| CompanyCode | string | Yes | Company code |
| LocationCode | string | Yes | Location code |
| DocYear | string | Yes | Document year |
| FormID | string | Yes | Form ID ("SQ") |
| DocumentNo | string | Yes | Quotation number |
| DocumentID | string | Yes | Quotation ID |
| AttachmentsFile | file[] | Yes | Files to upload |

**Example Response**:
```json
{
  "success": true,
  "message": "Attachments uploaded successfully",
  "errors": null
}
```

## Error Codes

### HTTP Status Codes
| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid token |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Endpoint not found |
| 500 | Internal Server Error |

### API Error Responses
```json
{
  "success": false,
  "message": "Error description",
  "errors": ["Detailed error messages"],
  "errorMessage": "User-friendly error message"
}
```

### Common Error Messages
| Error | Cause | Solution |
|-------|-------|----------|
| "Company not set" | Missing company in storage | Login again or set company |
| "Session token not found" | Missing authentication | Re-authenticate |
| "Failed to fetch quotation bases" | API connectivity issue | Check network/server |
| "Select Quotation Base" | Validation error | Select required field |
| "Date should be within the financial period" | Invalid date | Select date within period |

## Rate Limiting

### Limits
- Search APIs: 10 requests per second
- Create operations: 5 requests per minute
- File uploads: 2 concurrent uploads

### Headers
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Authentication

### Token Format
```
Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Token Refresh
Tokens expire after 24 hours. Refresh using:
```http
POST /api/Auth/RefreshToken
```

## Data Validation

### Field Constraints
| Field | Type | Min Length | Max Length | Pattern |
|-------|------|------------|------------|---------|
| customerCode | string | 1 | 20 | Alphanumeric |
| quotationYear | string | 5 | 5 | XX-XX format |
| subject | string | 1 | 500 | Any text |
| qty | number | 0.01 | 999999 | Positive decimal |
| rate | number | 0.01 | 999999 | Positive decimal |

### Business Rules
- Quotation date must be within financial period
- At least one item required
- Lead number required for inquiry reference
- Customer must exist in system
- Items must be active sales items

## Testing

### Test Environment
```
Base URL: http://test-server.company.com
Test Company ID: 999
Test Location ID: 1
```

### Sample Test Data
```json
{
  "testCustomer": {
    "customerCode": "TEST001",
    "customerName": "Test Customer"
  },
  "testItem": {
    "itemCode": "TEST-ITEM",
    "itemName": "Test Item",
    "uom": "PCS"
  }
}
```

### Postman Collection
A Postman collection with all endpoints and sample requests is available at:
`docs/postman/add-quotation-api.json`

---

**Last Updated**: December 2024
**API Version**: v1.0
**Contact**: api-support@company.com