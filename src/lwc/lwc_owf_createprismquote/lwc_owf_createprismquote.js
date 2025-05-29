import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOpportunityFields from '@salesforce/apex/CNT_OWF_CreatePrismQuote.getOpportunityFields';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class LwcOwfCreateProposal extends NavigationMixin(LightningElement) {
    @api recordId;
    showSpinner = true;
    error = false;;
    errorMsg = 'Unexpected error !!!';


    @wire(getOpportunityFields, { recordId: '$recordId' })
    wireData({ data, error }) {
        var URL;
        if (data) {
            this.error = false;
            if(data.lqOwnerId != null && data.lqOpportunityId == null){
                URL ='https://' + data.lqLegacyOrgLink + '/lightning/o/Apttus_Proposal__Proposal__c/new?defaultFieldValues=OwnerId=' + data.lqOwnerId;
            }
            else if(data.lqOwnerId == null && data.lqOpportunityId != null){
                URL ='https://' + data.lqLegacyOrgLink + '/lightning/o/Apttus_Proposal__Proposal__c/new?defaultFieldValues=Apttus_Proposal__Opportunity__c=' + data.lqOpportunityId;
            }
            else if(data.lqOwnerId != null && data.lqOpportunityId != null){
                URL ='https://' + data.lqLegacyOrgLink + '/lightning/o/Apttus_Proposal__Proposal__c/new?defaultFieldValues=Apttus_Proposal__Opportunity__c=' + data.lqOpportunityId + ',OwnerId=' + data.lqOwnerId;
            }
            else{
                URL ='https://' + data.lqLegacyOrgLink + '/lightning/o/Apttus_Proposal__Proposal__c/new';
            }
            this.dispatchEvent(new CloseActionScreenEvent());
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": URL
                }
            });
        } else if (error) {
            this.handleError(error);
        }
    }

    handleError(error) {
        this.error = true;
        var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
        this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
        console.log(JSON.stringify(error));
        this.showSpinner = false;
    }

}