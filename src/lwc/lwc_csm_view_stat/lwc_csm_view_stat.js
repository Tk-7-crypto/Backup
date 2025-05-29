import { LightningElement, api } from 'lwc';
import insertViewStat from '@salesforce/apex/CNT_CSM_ViewStat.insertViewStat';

export default class Lwc_csm_view_stat extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api source;

    connectedCallback() {
        this.insertViewStat();
    }

    insertViewStat() {
        insertViewStat({
            objectApiName: this.objectApiName,
            recordId: this.recordId,
            source: this.source
        })
            .then(result => {
                console.log('insertViewStat done');
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }

}