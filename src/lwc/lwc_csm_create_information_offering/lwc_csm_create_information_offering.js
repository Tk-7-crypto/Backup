import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import INFORMATION_OFFERING_ID_FIELD from '@salesforce/schema/Case.InformationOfferingFormId__c';
import getInformationOffering from '@salesforce/apex/CNT_CSM_CreateInformationOffering.getInformationOffering';
export default class Lwc_csm_create_information_offering extends NavigationMixin (LightningElement) {
    showSpinner = true;
    offeringUnavailable = true;
    offeringCheckSize = true;
    @track offeringWrapper;
    @api recordId;
    @track error;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [INFORMATION_OFFERING_ID_FIELD]
    }) wirecase({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           this.showErrorToast();
           this.showSpinner = false;
           
        } else if (data) {
            this.showSpinner = true;
            this.init();            
        }
    }

    init() {
        getInformationOffering({caseId: this.recordId})
        .then(result => {
            this.offeringWrapper = result;
            this.offeringUnavailable = !result.isOfferingAvailable;
            if(result.offering.length < 3){
                this.offeringCheckSize = true;
            }else{
                this.offeringCheckSize = false;
            }
            this.showSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.showErrorToast();
            this.showSpinner = false;
        });
    }

    openInformationOfferingForm(event) {
        var createRecord = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Information_Offering_Forms__c',
                actionName: 'new'                
            },
            state : {
                nooverride: '1',
                count: '1',
                defaultFieldValues:"Case__c="+this.recordId
            },
            
        };
        this[NavigationMixin.Navigate](createRecord);
    }

    openOffering(event) {
        var viewRecord = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Information_Offering_Forms__r',
                recordId: event.currentTarget.dataset.recordId,
                actionName: 'view'             
            }
        };
        this[NavigationMixin.Navigate](viewRecord);
    }

    navigateToOfferingRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Information_Offering_Forms__c',
                relationshipApiName: 'Information_Offering_Forms__r',
                actionName: 'view'
            },
        });
    }

    showErrorToast() {
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
