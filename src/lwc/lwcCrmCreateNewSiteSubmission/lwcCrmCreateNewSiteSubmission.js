import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findRecords from "@salesforce/apex/CNT_CRM_AutoCompleteSearch.findRecords";
import createSiteSubmissionRecords from "@salesforce/apex/CNT_CRM_CreateNewSiteSubmission.createSiteSubmissionRecords";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

const COLUMNS = [
    {
        label: 'Account Name', fieldName: 'recordURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Account Country', fieldName: 'AccountCountry__c', type: 'text', sortable: true }
];
export default class LwcCrmCreateNewSiteSubmission extends NavigationMixin(LightningElement) {

    objectApiName = 'Account';
    filterField = 'Name';
    fieldSet = 'Name, AccountCountry__c, Type__c';
    recordLimit = '100';

    columns = COLUMNS;
    @api recordId;
    @api searchedData;
    searchKey = '';
    showSpinner = false;
    sites = [];

    @wire(CurrentPageReference) currentPageRef;

    // To get Opportunity Id From URL and load default Data
    connectedCallback() {
        this.showSpinner = true;
        this.loadDefaultData();
    }

    // Helper Method to Load default data on Component initialization
    loadDefaultData() {
        findRecords({ searchKey: '', objectName: this.objectApiName, filterField: this.filterField, fieldSet: this.fieldSet, recordLimit: this.recordLimit })
            .then((result) => {
                this.handleTableRecords(result);
                this.showSpinner = false;
            }).catch((error) => {
                this.showSpinner = false;
                this.handleError(error, 'loadDefaultData');
            });
    }

    // To update datatable based on newly quired records
    handlelistdatachange(event) {
        this.handleTableRecords(event.detail.recordsListFull);
        this.template.querySelector('c-lwc-crm-datatable').showSearchRecordList();
    }

    handleTableRecords(data) {
        //var tempData = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
        //this.sites = tempData;
        this.sites = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
        if (this.sites && this.sites.length > 0) {
            this.sites.forEach(function (acc) {
                try {
                    acc['recordURL'] = '/' + acc.Id;
                } catch (error) {
                    this.handleError(error, 'handleTableRecords');
                }
            });
            this.searchedData = this.sites;
        } else {
            this.searchedData = [];
        }
    }

    // To handle Save Event from lwcCrmDatatable
    handleSave(event) {
        this.showSpinner = true;
        var selectedAccounts = event.detail.selectedRecordIds;
        createSiteSubmissionRecords({ selectedAccounts: selectedAccounts, parentId: this.recordId })
            .then(result => {
                this.showSpinner = false;
                if (result == true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Site Submission records created successfully',
                            variant: 'success'
                        })
                    );
                    this.handleCancel();
                }
            }).catch((error) => {
                this.handleError(error, 'handleSave');
                this.showSpinner = false;
            });
    }

    // To handle cancel event from lwcCrmDatatable
    handleCancel(event) {
        console.log('recordId: ', this.recordId);
        eval("$A.get('e.force:refreshView').fire();");
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                relationshipApiName: 'Site_Submissions__r',
                actionName: 'view'
            },
        });
    }

    get recordId() {
        return this.currentPageRef.state.c__recordId;
    }

    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        console.log(error);
        var errorMsg = new Array();

        var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
        var errorCode = (error.body && error.body.errorCode) ? error.body.errorCode : error.status ? error.status : '';

        if (JSON.parse(err).fieldErrors && Object.keys(JSON.parse(err).fieldErrors).length > 0) {
            let fieldError = JSON.parse(err).fieldErrors;
            for (let [key, value] of Object.entries(fieldError)) {
                errorMsg.push(key + ': ' + value[0].message);
                errorCode = value[0].statusCode;
            }
        } else if (JSON.parse(err).pageErrors && Object.keys(JSON.parse(err).pageErrors).length > 0) {
            let pageErrors = JSON.parse(err).pageErrors;
            for (let [key, value] of Object.entries(pageErrors)) {
                errorMsg.push(value.message);
                errorCode = value.statusCode;
            }
        } else {
            errorMsg.push(err == "{}" ? 'Unexpected error !!!' : err);
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error ' + errorCode,
                message: errorMsg[0],
                variant: 'error',
                mode: 'pester'
            })
        );
        this.showSpinner = false;
    }

    // To handle exceptions from child component
    errorCallback(error, stack) {
        console.log('Error in Child component error: ', error);
        console.log('stack: ', stack);
    }

    disconnectedCallback() {
        this.recordId = null;
    }
}