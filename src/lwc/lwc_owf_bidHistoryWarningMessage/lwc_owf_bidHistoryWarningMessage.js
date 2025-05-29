import { LightningElement, api } from 'lwc';
import { registerRefreshHandler } from 'lightning/refresh';
import getBidHistoryData from '@salesforce/apex/CNT_OWF_BidHistoryWarningMessage.getBidHistoryData';

export default class BidHistoryLwc extends LightningElement {
    @api recordId; 
    isCountMatching;
    error;
    refreshHandlerID;

    connectedCallback() {
        this.refreshHandlerID = registerRefreshHandler(this.template.host, this.refreshHandler.bind(this));
        this.getBidHistoryData();
    }

    getBidHistoryData() {
        getBidHistoryData({ recordId: this.recordId })
        .then(result => {
            this.isCountMatching = result;
        })
        .catch(error => {
            console.error('Error:', error);
            this.error = error.body ? error.body.message : error;
            this.message = null;
        });
    }

    refreshHandler() {
        return new Promise((resolve) => {
            this.getBidHistoryData();
            resolve(true);
        });
  }

}