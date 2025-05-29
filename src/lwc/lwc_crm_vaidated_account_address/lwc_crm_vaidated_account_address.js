import { LightningElement, wire, api } from 'lwc';
import getValidatedAddress from '@salesforce/apex/CNT_CRM_Show_Address_Message.getValidatedAddress';
import getOpportunityDetails from '@salesforce/apex/CNT_CRM_Show_Address_Message.getOpportunityDetails';
import Banner_Message from '@salesforce/label/c.LWC_Account_Address_banner';
export default class Account_addressLWCComponent extends LightningElement {

    @api recordId;
    @api objectApiName;

    isValidated = false;
    message = '' ;

    connectedCallback() {
        if (this.objectApiName === 'Account') {
            this.handleAccount();
        } else if (this.objectApiName === 'Opportunity') {
            this.handleOpportunity();
        }
    }

    handleAccount() {
        getValidatedAddress({ accountId: this.recordId })
            .then((result) => {
                this.isValidated = result;
                if (this.isValidated) {
                    this.message = Banner_Message;
                }
            })
            .catch((error) => {
                console.error('Error fetching account visibility:', error);
            });
    }

    handleOpportunity() {
        getOpportunityDetails({ opportunityId: this.recordId })
            .then((result) => {
                if (result != null) {
                    this.isValidated = true;
                    this.message = result ;
                }
            })
            .catch((error) => {
                console.error('Error fetching opportunity message:', error);
            });
    }
}