import { LightningElement,api } from 'lwc';
import insertViewStat from '@salesforce/apex/CNT_CSM_ViewStat.insertViewStat';
export default class lwc_prm_caseviewstat extends LightningElement {

    @api recordId

    connectedCallback() {
        //code
        console.log('RecordId::::', this.recordId);
        setTimeout(()=>{
            console.log('RecordId::::', this.recordId);
            insertViewStat({objectApiName : 'Case', recordId :this.recordId, source : 'PRM'}).then(res=>{
                console.log('Response:::', res);
            }).catch(ex=>{
                console.log('Exception::::', ex);
            });
        },200);
    }
}