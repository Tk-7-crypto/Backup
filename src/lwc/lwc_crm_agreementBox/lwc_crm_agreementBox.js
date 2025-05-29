import { LightningElement,wire,api } from 'lwc';
import fetchAgreement from '@salesforce/apex/CNT_CRM_AgreementBox.fetchAgreement';
export default class Lwc_crm_agreementBox extends LightningElement {
    @api recordId;
    agreementLink = '';
    isErrorFound = false;
    agreementData;
    @wire(fetchAgreement, { recordId: '$recordId' })
    wiredMethod({ error, data }) {
        if (data) { 
            if(data.success != undefined && data.success != null){
                this.agreementData = data.success;
                this.agreementLink = window.location.origin+"/"+ data.success.Id;
                this.isErrorFound = false;
            }else{
                this.isErrorFound = true;
            }
         }else if (error) { 
            console.log(error);
         }
    }

}