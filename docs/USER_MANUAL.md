# Add Quotation Feature - User Manual

## Table of Contents
1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Creating Quotations](#creating-quotations)
4. [Managing Items](#managing-items)
5. [Attachments](#attachments)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)

## Overview

The Add Quotation feature allows you to create professional quotations for your customers. You can create quotations in two ways:
- **From a Lead**: Convert an existing lead into a quotation with prefilled information
- **Standalone**: Create a new quotation from scratch

### Key Features
- ✅ Automatic data prefilling from leads
- ✅ Customer and item search functionality
- ✅ Real-time total calculations
- ✅ File attachment support
- ✅ Date validation
- ✅ Multiple discount options

## Getting Started

### Prerequisites
Before creating quotations, ensure you have:
- Valid login credentials
- Selected company and location
- Appropriate permissions for quotation creation

### Navigation
1. **From Lead**: Go to Leads → View Lead Details → Click "Create Quotation"
2. **Standalone**: Go to Quotations → Add New Quotation

## Creating Quotations

### Method 1: From Lead (Recommended)

#### Step 1: Access Lead Details
1. Navigate to the **Leads** section
2. Find and tap on the lead you want to convert
3. Review the lead information

#### Step 2: Create Quotation
1. In the lead details page, look for the **"Create Quotation"** button (blue button with business icon)
2. Tap the button to open the quotation form
3. The form will automatically prefill with lead information:
   - Customer details (Quote To and Bill To)
   - Salesman information
   - Lead number
   - Subject line
   - Items from the lead

#### Step 3: Review Prefilled Data
- **Lead Information Card**: Shows the source lead details
- **Customer Information**: Verify Quote To and Bill To are correct
- **Salesman**: Confirm the assigned salesman
- **Subject**: Modify if needed (default: "Quotation for Inquiry [Lead Number]")
- **Items**: Review items transferred from the lead

### Method 2: Standalone Creation

#### Step 1: Open Add Quotation Form
1. Navigate to **Quotations** section
2. Tap **"Add New Quotation"**
3. The form opens with empty fields

#### Step 2: Fill Required Information
1. **Quotation Base**: Select from dropdown
   - "With Inquiry Reference": For existing leads/inquiries
   - "Without Inquiry Reference": For new quotations

2. **Quote To**: Search and select customer
   - Type at least 4 characters
   - Select from the dropdown list
   - Don't manually type the name

3. **Bill To**: Search and select billing customer
   - Usually same as Quote To
   - Can be different if needed

4. **Salesman**: Select from dropdown
   - Choose the responsible salesperson

5. **Lead Number** (if "With Inquiry Reference" selected):
   - Select from available open inquiries
   - Only shows inquiries for the selected customer

6. **Subject To**: Enter quotation subject
   - Brief description of the quotation purpose

7. **Date**: Select quotation date
   - Must be within the financial period
   - Cannot be in the future
   - Use the calendar picker

## Form Fields Guide

### Required Fields (marked with *)
All fields marked with an asterisk (*) must be filled before submission:

| Field | Description | Notes |
|-------|-------------|-------|
| Quotation Base* | Type of quotation | Choose based on whether you have an inquiry reference |
| Quote To* | Customer receiving the quotation | Search by typing 4+ characters |
| Bill To* | Billing customer | Often same as Quote To |
| Salesman* | Responsible salesperson | Select from company salespeople |
| Subject To* | Quotation description | Brief, descriptive text |
| Date* | Quotation date | Must be valid business date |
| Items* | Quotation items | At least one item required |

### Optional Fields
| Field | Description | Notes |
|-------|-------------|-------|
| Lead Number | Reference inquiry | Only for "With Inquiry Reference" |
| Attachments | Supporting files | PDF, images, documents |

### Date Validation Rules
- ✅ Must be within the current financial period
- ✅ Cannot be in the future
- ✅ Must be a valid date
- ❌ Weekends and holidays are allowed

## Managing Items

### Adding Items

#### Step 1: Open Item Form
1. In the quotation form, scroll to the **Items** section
2. Tap **"Add Item"** button
3. The item form opens

#### Step 2: Search for Item
1. In the **Item Name** field, type at least 4 characters
2. Wait for the dropdown to appear
3. Select the desired item from the list
4. The item code and UOM will auto-fill

#### Step 3: Enter Quantities and Pricing
1. **Quantity**: Enter the required quantity
   - Must be a positive number
   - Supports decimal values

2. **UOM**: Unit of Measure (auto-filled, read-only)

3. **Basic Rate**: Enter the unit price
   - Must be a positive number
   - Supports decimal values

#### Step 4: Configure Discounts
1. **Discount Type**: Choose from dropdown
   - **None**: No discount
   - **Percentage**: Discount as percentage (0-100%)
   - **Value**: Fixed discount amount

2. **Discount Value**: Enter discount amount
   - For percentage: Enter 0-100
   - For value: Enter fixed amount (cannot exceed item total)

3. **Discount Code**: Select from available codes
   - Choose appropriate discount category

#### Step 5: Select Rate Structure
1. **Rate Structure**: Choose tax calculation method
   - Select from available rate structures
   - Affects tax calculation

#### Step 6: Save Item
1. Review all entered information
2. Tap **"Save Item"**
3. The item is added to the quotation

### Editing Items
1. In the items list, tap the **edit icon** (pencil) next to the item
2. Modify the required fields
3. Tap **"Save Item"** to update

### Removing Items
1. In the items list, tap the **delete icon** (trash) next to the item
2. Confirm the deletion
3. The item is removed from the quotation

### Items Validation
- ✅ Item must be selected from search results (not manually typed)
- ✅ Quantity must be positive
- ✅ Rate must be positive
- ✅ Discount percentage must be 0-100
- ✅ Discount value cannot exceed item amount

## Totals Calculation

The system automatically calculates totals as you add items:

### Summary Card Shows:
- **Basic Amount**: Sum of all item amounts (Qty × Rate)
- **Discount**: Total discount applied
- **Tax Amount**: Calculated tax based on rate structures
- **Total Amount**: Final amount after discounts and taxes

### Real-time Updates
- Totals update automatically when you add/edit/remove items
- Tax calculations happen in real-time
- All amounts are displayed in the company's base currency

## Attachments

### Adding Attachments
1. Scroll to the **Attachments** section
2. Tap **"Add Attachment"**
3. Select files from your device
4. Multiple files can be selected at once

### Supported File Types
- **Documents**: PDF, DOC, DOCX
- **Images**: JPG, JPEG, PNG
- **Spreadsheets**: XLS, XLSX
- **Text**: TXT

### File Size Limits
- Maximum file size: 10MB per file
- Maximum total attachments: 50MB per quotation

### Managing Attachments
- **View**: Tap on a file name to preview
- **Remove**: Tap the delete icon next to unwanted files
- **Replace**: Remove old file and add new one

## Submitting Quotations

### Pre-submission Checklist
Before submitting, verify:
- [ ] All required fields are filled
- [ ] At least one item is added
- [ ] Date is valid and within period
- [ ] Customer information is correct
- [ ] Items have correct quantities and prices
- [ ] Attachments are relevant and under size limits

### Submission Process
1. Review all information in the form
2. Check the totals in the summary card
3. Tap **"Create Quotation"**
4. Wait for the submission to complete
5. You'll see a success message when done

### After Submission
- The quotation is saved in the system
- A quotation number is automatically generated
- Attachments are uploaded (if any)
- You're returned to the previous screen
- A success notification is displayed

## Error Handling

### Common Validation Errors

#### "Please fill all required fields"
**Cause**: One or more required fields are empty
**Solution**: Check all fields marked with (*) and fill them

#### "Please add at least one item"
**Cause**: No items have been added to the quotation
**Solution**: Add at least one item using the "Add Item" button

#### "Date should be within the financial period"
**Cause**: Selected date is outside the company's financial year
**Solution**: Select a date within the allowed period (shown in the date field)

#### "Date should not be in the future"
**Cause**: Selected date is after today's date
**Solution**: Select today's date or an earlier date

#### "Please select a lead number"
**Cause**: "With Inquiry Reference" is selected but no lead number chosen
**Solution**: Select a lead number from the dropdown, or change to "Without Inquiry Reference"

#### "Select Quote To"
**Cause**: Customer not properly selected
**Solution**: 
1. Clear the field
2. Type at least 4 characters
3. Select from the dropdown (don't type manually)

#### "Please select an item from the list"
**Cause**: Item name typed manually instead of selected
**Solution**:
1. Clear the item name field
2. Type at least 4 characters
3. Select from the dropdown list

### Network Errors

#### "Failed to load data"
**Cause**: Network connectivity issues
**Solution**:
1. Check your internet connection
2. Try again after a few moments
3. Contact IT support if problem persists

#### "Server error"
**Cause**: Server-side issues
**Solution**:
1. Wait a few minutes and try again
2. Contact technical support if error continues

### Performance Issues

#### Slow loading
**Cause**: Large amounts of data or slow network
**Solution**:
1. Ensure stable internet connection
2. Close other apps to free memory
3. Restart the app if needed

#### App crashes
**Cause**: Memory issues or app bugs
**Solution**:
1. Restart the app
2. Clear app cache if available
3. Update to the latest version
4. Contact support with error details

## Troubleshooting

### Cannot Find Customer
**Problem**: Customer doesn't appear in search results
**Solutions**:
1. Check spelling of customer name/code
2. Try searching with partial names
3. Ensure customer is active in the system
4. Contact admin to verify customer setup

### Cannot Find Items
**Problem**: Items don't appear in search results
**Solutions**:
1. Check item name spelling
2. Try searching with item codes
3. Ensure items are active for sales
4. Contact admin to verify item setup

### Lead Number Not Available
**Problem**: No lead numbers show for customer
**Solutions**:
1. Verify customer has open inquiries
2. Check if inquiries are in correct status
3. Use "Without Inquiry Reference" option
4. Contact sales team to verify inquiry status

### Attachment Upload Fails
**Problem**: Files won't upload
**Solutions**:
1. Check file size (max 10MB per file)
2. Verify file format is supported
3. Ensure stable internet connection
4. Try uploading files one at a time

### Date Picker Issues
**Problem**: Cannot select desired date
**Solutions**:
1. Check if date is within financial period
2. Ensure date is not in the future
3. Try selecting a different date first, then your desired date
4. Contact admin about financial period settings

## FAQ

### General Questions

**Q: Can I edit a quotation after submission?**
A: No, once submitted, quotations cannot be edited through this form. Contact your administrator for quotation modifications.

**Q: How long does it take to create a quotation?**
A: Typically 2-5 minutes, depending on the number of items and attachments.

**Q: Can I save a draft quotation?**
A: Currently, the system doesn't support draft saving. Complete the quotation in one session.

**Q: What happens if I close the app while creating a quotation?**
A: All unsaved data will be lost. You'll need to start over.

### Technical Questions

**Q: Why do I need to type 4 characters to search?**
A: This prevents excessive server requests and ensures more accurate search results.

**Q: Can I create quotations offline?**
A: No, an internet connection is required for all quotation operations.

**Q: What's the difference between Quote To and Bill To?**
A: Quote To is who receives the quotation; Bill To is who gets invoiced. They're often the same customer.

**Q: Why can't I select future dates?**
A: Business rule prevents backdating or future-dating quotations beyond today.

### Business Questions

**Q: When should I use "With Inquiry Reference"?**
A: When creating quotations for existing leads or customer inquiries.

**Q: When should I use "Without Inquiry Reference"?**
A: For new quotations not related to existing leads or inquiries.

**Q: Can I add custom items not in the system?**
A: No, all items must be pre-configured in the system. Contact admin to add new items.

**Q: How are taxes calculated?**
A: Based on the selected rate structure and item configuration. The system calculates automatically.

## Tips for Efficient Use

### Best Practices
1. **Use Lead Conversion**: When possible, create quotations from leads for faster data entry
2. **Prepare Information**: Gather all required information before starting
3. **Check Connectivity**: Ensure stable internet before beginning
4. **Review Before Submit**: Double-check all information before submission
5. **Organize Attachments**: Prepare and organize files before uploading

### Time-Saving Tips
1. **Search Shortcuts**: Use item codes for faster item search
2. **Copy Customer**: Bill To often same as Quote To - use copy function
3. **Standard Subjects**: Develop standard subject line templates
4. **Batch Items**: Add all items before reviewing totals
5. **File Preparation**: Optimize file sizes before attaching

### Common Workflows

#### Lead to Quotation (Fastest)
1. Navigate to lead details
2. Tap "Create Quotation"
3. Review prefilled data
4. Modify items if needed
5. Add attachments
6. Submit

#### New Customer Quotation
1. Open Add Quotation
2. Select "Without Inquiry Reference"
3. Search and select customer
4. Fill salesman and subject
5. Add items one by one
6. Review totals
7. Submit

#### Inquiry-Based Quotation
1. Open Add Quotation
2. Select "With Inquiry Reference"
3. Search and select customer
4. Choose lead number
5. Add/modify items
6. Submit

---

## Support

### Getting Help
- **In-App**: Look for help icons (?) next to fields
- **Documentation**: Refer to this manual
- **Technical Support**: Contact IT department
- **Business Support**: Contact sales management

### Reporting Issues
When reporting problems, include:
1. What you were trying to do
2. What happened instead
3. Error messages (if any)
4. Screenshots (if helpful)
5. Your user ID and company

### Training Resources
- User training videos (if available)
- Practice environment for testing
- Regular training sessions
- User community forums

---

**Last Updated**: December 2024
**Version**: 1.0.0
**For Support**: Contact your system administrator