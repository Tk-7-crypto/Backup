import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import finalizeQuoteForSingleTool from '@salesforce/apex/CNT_CPQ_QuoteWorkflow.finalizeQuoteForSingleTool';
import { NavigationMixin } from 'lightning/navigation';

export default class LWC_CPQ_FinalizeIqviaQuote extends NavigationMixin (LightningElement) {
    @api recordId;
    @api objectApiName;
    quoteId;

    connectedCallback() {
        finalizeQuoteForSingleTool({recordId: this.recordId})
        .then(result=>{
            if (result != 'Fail') {
                this.quoteId = result;
                this.NavigateToRecord(this.quoteId, 'Quote__c', 'view');
            }
         }).catch(error=>{
            this.toast('ERROR', error.body.message, 'error');
         })
    }
    toast(title, msg, variant, mode){
        const toastEvent = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: mode ? mode : 'dismissable'
        })
        this.dispatchEvent(toastEvent)
    }

    NavigateToRecord(recordId, objectName, actionName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectName,
                actionName: actionName
            },
        });
    }
}