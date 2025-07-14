check if gps is turned on or not
Create api -> response : {"data":"#332269","message":"Inquiry_details_SavedKey#25-26/SL/RM/#332269","errors":null,"success":true,"errorMessage":null}

{{baseUrl}}/api/Quotation/InsertLocation: strFunction : LD, intFunctionID: 332269, Longitude, Latitude

geoLocation: functioncode: LD, 

There is a little change in submission process first we have to detect if the device has location permission and if gps is turned on. If location is off then show a snackbar and ask the user to turn on the location then only move to next step. If location is off then don't let user submit the data 

Create a utility for location like taking user permission for location, check if gps is turned on or not, get user current location.
As submission process flow will be first check if gps is on or not if not and if location is ogg then open the settings page of location so user can turn on the location easily, and if the user don't turn on the location don't move to build submission payload.

If user turns on the location then start the submission process and if the data is submitted succesfully the api CreateLeadEntry response will be like this {"data":"#332269","message":"Inquiry_details_SavedKey#25-26/SL/RM/#332269","errors":null,"success":true,"errorMessage":null} now we need to use 332269 (id) for submitting location data to {{baseUrl}}/api/Quotation/InsertLocation and if possible do it in parallel with attachment api (if there are nay attachment) get the highest possible setting to get the user's percise location (longitude and latidude) in android and ios both the location will be taken when the buildsubmissionpayload function is called. 