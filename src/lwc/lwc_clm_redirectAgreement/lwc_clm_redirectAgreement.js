import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import redirectAgreement from '@salesforce/apex/CNT_CLM_CommonController.redirectToIQVIAAgreement';

export default class Lwc_clm_redirectAgreement extends NavigationMixin(LightningElement) {
    @api recordId;
    targetId;

    connectedCallback() {
        redirectAgreement({agreementId : this.recordId}) 
        .then(result => { 
        this.targetId = result;
        this.navigate();
        })
        .catch(error => {
            this.error = error;
          });
    }

    navigate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.targetId,
                actionName: 'view'
            }
        });
    }










}