import { LightningElement, api, wire } from 'lwc';
import Opportunity_Name_FIELD from '@salesforce/schema/Opportunity.Name';
import Opportunity_StageName_FIELD from '@salesforce/schema/Opportunity.StageName';
import Opportunity_Amount_FIELD from '@salesforce/schema/Opportunity.Amount';
import Opportunity_CloseDate_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import getOpportunity from '@salesforce/apex/CNT_Crm_My_Opportunity_View.getOpportunity';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

const COLUMNS = [
    {
        label: 'Opportunity Owner', fieldName: 'OwnerURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'OwnerName' }}
    },
    {
        label: 'Account', fieldName: 'AccountURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'AccountName' }}
    },
    {
        label: 'Opportunity Name', fieldName: 'OpportunityURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: Opportunity_Name_FIELD.fieldApiName }}
    },
    { label: 'Stage', fieldName: Opportunity_StageName_FIELD.fieldApiName, type: 'text', sortable: true },
    { label: 'Amount', fieldName: Opportunity_Amount_FIELD.fieldApiName, type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: "code", step: '0.001'}, sortable: true},
    { label: 'Expected Close Date', fieldName: Opportunity_CloseDate_FIELD.fieldApiName, type: 'date-local', sortable: true },
    { label: 'Inside Sales Transfer Date', fieldName: 'Inside_Sales_Transfer_Date__c', type: 'date-local', sortable: true }
];

export default class Lwc_Crm_My_Opportunity_View extends LightningElement {
    userId = Id;
    userFullName;
    insideSalesUserId = '';
    columns = COLUMNS;
    opportunity;
    filteredOpportunity;
    error;
    sortedBy;
    sortDirection = 'asc';
    OpportunityListValue = 'all';
    errorMsg = 'Unexpected error !!!';
    @wire(getRecord, { recordId: Id, fields: ['User.Name'] })
    userData({ data, error }) {
        if (data){
            this.userFullName = data.fields.Name.value;
        }
        else if (error){
            this.handleError(error);
        }
    }

    get opportunityTypeOptions(){
        return [
            { label: 'All', value: 'all' },
            { label: 'This Quarter', value: 'this_Quarter' },
            { label: 'Next Quarter', value: 'next_Quarter' }
        ];
    }

    @wire(getOpportunity)
    wireOpportunity({ data, error }) {
        if (data) {
			var tempData = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
            this.opportunity = tempData.opportunity;
            this.insideSalesUserId = tempData.hasOwnProperty('insideSalesUserId') == true ? tempData.insideSalesUserId : null;
            if (this.opportunity.length > 0) {
								this.opportunity.forEach(function (opportunity) {
										try{
												opportunity['AccountName'] = opportunity.Account.Name;
												opportunity['AccountURL'] = '/' + opportunity.AccountId;
												opportunity['OwnerName'] = opportunity.Owner.Name;
												opportunity['OwnerURL'] = '/' + opportunity.OwnerId;
												opportunity['OpportunityURL'] = '/' + opportunity.Id;
												if(opportunity.Inside_Sales_Transfer_Date__c == undefined )
													opportunity['Inside_Sales_Transfer_Date__c'] = '';
												if(opportunity.Amount == undefined )
													opportunity['Amount'] = '';
										}catch (e){
												console.log(e);
                    }
                });				
                this.filteredOpportunity = JSON.parse(JSON.stringify(this.opportunity));
            } 
        } else if (error) {
            this.handleError(error);
        }
    }

    handleOpportunityListChange(event) {
        this.OpportunityListValue = event.detail.value;
        this.filterOpportunity();
    }
	
	getCurrentQuater(closeDate, flag) {
		var result = false;
		// Current Quater
		var todayDate = new Date();
		var year = todayDate.getFullYear();
		var month = todayDate.getMonth();
		var quater = Math.floor((month)/3);
		//var quater = 3;
		// Opportunity Clsoe Date Quater
		var fields = closeDate.split('-');
		var closeDateYear = parseInt(fields[0]);
		var closeDatemonth = parseInt(fields[1]);
		var closeDatQuater = Math.floor((closeDatemonth-1)/3);
		if(flag){// Next Quater            
            if((year == closeDateYear && (quater+1) == closeDatQuater) || ( (year+1) == closeDateYear && quater == 3 && closeDatQuater == 0 )){
                result = true;
            }            
        }else{// Current Quater            
            if(year == closeDateYear && quater == closeDatQuater){
                result = true;
            }            
        }
        return result;		
    }
	
    filterOpportunity() {
        if (this.opportunity) {
            this.filteredOpportunity = this.opportunity.filter(function (item) {
                let flag = false;
                if (this.OpportunityListValue == 'all') {
                    flag = true;
                } else if (this.OpportunityListValue == 'this_Quarter') {
                    flag = this.getCurrentQuater(item.CloseDate, false);
                } else if (this.OpportunityListValue == 'next_Quarter') {
                    flag = this.getCurrentQuater(item.CloseDate, true);
                }
                return flag;
            }.bind(this));
        }
    }

    handleError(error) {
        var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
        this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
        this.error = true;
        this.tasks = [];
        console.log(JSON.stringify(error));
    }
}