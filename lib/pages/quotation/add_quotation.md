## API Flow
GetCompanyCurrentYearDatesData -> GetDefaultDocumentDetail -> QuotationBaseList -> LeadSalesManList -> Page Loaded -> QuotationGetCustomer

## Flow

When user will click on Floating Action button the Add Quotation page will open and display a loading indicator while calling the follwing apis GetCompanyCurrentYearDatesData, GetDefaultDocumentDetail, QuotationBaseList, LeadSalesManList after successfully calling all the apis and setting the values of dropdown the user will be shown the form with following fields Quotation Base(dropdown), Quote to and Bill to a typeahead fields, Salesman(dropdown), Subject To (user input), Date (Date Picker with restriction dates from GetCompanyCurrentYearDatesData response) default date will be current date, Items List (user can add, edit and remove items) we will use a seperate form and page for this, Add item form will cnitains