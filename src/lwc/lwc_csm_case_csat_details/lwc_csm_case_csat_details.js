import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import {getRecord} from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';
import getCustomerRatings from '@salesforce/apex/CNT_CSM_CaseCSATDetails.getCustomerRatings';
import saveCase from '@salesforce/apex/CNT_CSM_CaseCSATDetails.saveCase';

export default class Lwc_csm_case_csat_details extends NavigationMixin(LightningElement) {
    readOnlyRating = true;
    isEditable = false;
    showSpinner = true;
    @track isCheckboxDisable = true;
    @api recordId;
    @track customerRatings;
    @track error;
    currentUser;
    overallSatisfactionForContact;
    lowestResponseScore;
    avgSatisfactionForCase;
    showEditButton;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, PROFILE_NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           this.showToast();
        } else if (data) {
            var currentUser = {userName: '', userProfile: ''};
            currentUser.userName = data.fields.Name.value;
            currentUser.userProfile = data.fields.Profile.value.fields.Name.value;
            this.currentUser = currentUser;
        }
    }

    connectedCallback() {
        getCustomerRatings({caseId : this.recordId})
            .then(result => {
                this.customerRatings = result;
                this.overallSatisfactionForContact = Math.floor(result.overallSatisfactionForContact);
                this.lowestResponseScore = Math.floor(result.lowestResponseScore);
                this.avgSatisfactionForCase = Math.floor(result.avgSatisfactionForCase);
                if(this.currentUser.userProfile === 'System Administrator') {
                    this.showEditButton = true;
                } else {
                    if(this.customerRatings.isCSATResponseAvailable) {
                        this.showEditButton = this.customerRatings.caseRecord.CSAT_Responded__c === 1? true : false;
                    }
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
                this.showToast();
                this.showSpinner = false;
        });
    }

    editReviewer() {
        this.isCheckboxDisable = false;
        this.isEditable = true;
    }

    saveReviewer() {
        this.showSpinner = true;
        var caseRecord = this.customerRatings.caseRecord;
        this.customerRatings.caseRecord.CSAT_Reviewed_by__c = caseRecord.CSAT_Reviewed__c ? caseRecord.CSAT_Reviewed_by__c : '';
        caseRecord.CSAT_Reviewed_by__c = caseRecord.CSAT_Reviewed__c ? this.currentUser.userName : '';
        saveCase({caseRecord : caseRecord})
            .then(result => {
                this.customerRatings.caseRecord = result;
                if(this.currentUser.userProfile === 'System Administrator') {
                    this.showEditButton = true;
                } else {
                    if(this.customerRatings.isCSATResponseAvailable) {
                        this.showEditButton = this.customerRatings.caseRecord.CSAT_Responded__c === 1? true : false;
                    }
                }
                this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
                this.showToast();
                this.showSpinner = false;
        });
        this.isEditable = false;
        this.isCheckboxDisable = true;
    }

    navigateToCSAT(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                relationshipApiName: 'CSAT_Responses__r',
                actionName: 'view'
            }
        });
    }

    onCheckboxChange(event) {
        this.customerRatings.caseRecord.CSAT_Reviewed__c = event.target.checked;
    } 

    cancelEdit() {
        this.isEditable = false;
        this.isCheckboxDisable = true;
    }

    showToast() {
        var error = this.error;
        if(error != undefined && error != null && error != '' && error.body != undefined && error.body != null && error.body != '') {
            var errorMessage = error.body.message;
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }
}