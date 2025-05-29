({
    getDateFormatted: function(component,dateStr,datePattern){
        var parsedDate = $A.localizationService.formatDate(dateStr, datePattern);
        return parsedDate;
    },
	getCDARequestList: function (component, pNum, currentPCount, sortField, sortDirection, searchMap, isNegotiatorTab, isCSVExport) {
		console.log('In LXC_CDA_LookupReport helper : getCDARequestList method called');
		this.showSpinner(component);
		var action = component.get('c.getCDARequests');

		action.setParams({
			"pageNumber": pNum.toString(),
			"currnetPagesCount": currentPCount.toString(),
			"sortField": sortField,
			"sortDirection": sortDirection,
			"searchMap": searchMap,
			"isNegotiatorTab": isNegotiatorTab 
		});

		var self = this;
		action.setCallback(this, function (response) {
			var state = response.getState();
			console.log('in getCDARequestList method callback: '+JSON.stringify(response.getError()));
			if (component.isValid() && state === "SUCCESS") {
				console.log('getCDARequests callback method: ');
                var requests = response.getReturnValue();
                var datePattern = 'MM/DD/YYYY';
                for(var i=0;i<requests.length;i++){
                    if(requests[i].CDA_Effective_Date__c != null){
                    	requests[i].CDA_Effective_Date__c = this.getDateFormatted(component,requests[i].CDA_Effective_Date__c.toString(),datePattern);
                    }
                    requests[i].CreatedDate = this.getDateFormatted(component,requests[i].CreatedDate.toString().substring(0,10),datePattern);
                }
				component.set('v.cdaRequests', requests);
				this.hideSpinner(component);
				
				//this handles csv export functionality
				if (isCSVExport) {
					var stockData = response.getReturnValue();
					console.log('inside downloadCsv in getCDARequestList');
					console.log(stockData);
					// call the helper function which "return" the CSV data as a String   
					var csv = self.convertArrayOfObjectsToCSV(component, stockData);
					if (csv == null) { return; }

					// ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
					var hiddenElement = document.createElement('a');
					hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
					hiddenElement.target = '_self'; // 
					hiddenElement.download = 'MyCDALookupReportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
					document.body.appendChild(hiddenElement); // Required for FireFox browser
					hiddenElement.click(); // using click() js function to download csv file
				}
			}
		});
		$A.enqueueAction(action);
	},

	showSpinner: function (component) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
	},

	hideSpinner: function (component) {
		var spinner = component.find("mySpinner");
		$A.util.addClass(spinner, "slds-hide");
	},

	openPopup: function (component, event, popupType) {
		console.log('LXC_CDA_LookupReport: js helper: openPopup start');
		component.set("v.isPopupOpen", true);
		component.set("v.popupType", popupType);
		var tempMap = new Map();

		if (popupType == 'cancelRequestPopup') {
			tempMap['button1'] = 'Yes';
			tempMap['button2'] = 'No';
		}

		component.set("v.popupButtonMap", tempMap);
		console.log('LXC_CDA_LookupReport: js helper: openPopup End');
	},

	convertArrayOfObjectsToCSV: function (component, objectRecords) {
		// declare variables
		var csvStringResult, counter, keys, columnDivider, lineDivider;

		// check if "objectRecords" parameter is null, then return from function
		if (objectRecords == null || !objectRecords.length) {
			return null;
		}
		console.log('inside LXC_CDA_LookupReportHelper.convertArrayOfObjectsToCSV');
		console.log(objectRecords);
		// store ,[comma] in columnDivider variabel for sparate CSV values and 
		// for start next line use '\n' [new line] in lineDivider varaible  
		columnDivider = ',';
		lineDivider = '\n';

		// in the keys valirable store fields API Names as a key 
		// this labels use in CSV file header  
		keys = ['Name', 'CreatedDate', 'CDA_Type__c', 'Status__c', 'CDA_Effective_Date__c', 'Recipient_Account_Name_Formula__c', 'CDA_Source__c', 'CDA_Format__c', 'CreatedBy', 'Protocol_Number__c', 'Protocol_Title_Long_Textarea__c', 'Project_Description_Long_Textarea__c'];

		csvStringResult = '';
		csvStringResult += keys.join(columnDivider);
		csvStringResult += lineDivider;
		
		for (var i = 0; i < objectRecords.length; i++) {
			counter = 0;
			
			for (var sTempkey in keys) {
				var skey = keys[sTempkey];
				
				// add , [comma] after every String value,. [except first]
				if (counter > 0) {
					csvStringResult += columnDivider;
				}
				
				if(skey == 'CreatedBy'){
					csvStringResult += '"' + objectRecords[i][skey].Name + '"';
				}else{
					csvStringResult += '"' + objectRecords[i][skey] + '"';
				}
				counter++;
				
			} // inner for loop close 
			csvStringResult += lineDivider;
		}// outer main for loop close
		
		csvStringResult = csvStringResult.replace(/undefined/g, '');

		// return the CSV formate String 
		return csvStringResult;
	},
})