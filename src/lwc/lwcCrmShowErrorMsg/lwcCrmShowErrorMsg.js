import { LightningElement, api } from 'lwc';
import getQueryResult from '@salesforce/apex/CNT_CRM_ShowErrorMsg.getQueryResult';
export default class LwcCrmShowErrorMsg extends LightningElement {

    @api queryText;
    @api errorMsg;
    @api recordId;
    showErrorMsg = false;
    showSpinner = false;

    connectedCallback() {
        getQueryResult({ recordId: this.recordId, queryText: this.queryText })
            .then(result => {
                if (result === true) {
                    this.showErrorMsg = true;
                } else {
                    this.showErrorMsg = false;
                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
                var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                console.log(err == "{}" ? 'Unexpected error !!!' : err);
                this.showSpinner = false;
            });
    }

}