import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Convert from "@salesforce/apex/CNT_CSM_DocQCForm.Convert";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from "@salesforce/apex/CNT_CSM_DocQCForm.saveRecord";
import { CurrentPageReference } from 'lightning/navigation'

const columns = [
    {label: 'Section', fieldName: 'SectionName'},
    {label: 'Remediation Points', fieldName: 'RemediationPoints'},
    {label: 'Number Of Errors', fieldName: 'numberOfErrors', editable: true, type: 'number'}
]

export default class IssueTracker extends NavigationMixin(LightningElement) {
    section = 'Section 1';
    remediationPoint = 'Point 1';
    numberOfIssues = 0;
    data;
    column = columns;
    draftValues = [];
    @api recordId;


@wire(CurrentPageReference)
currentPageReference;

connectedCallback() {
    this.recordId = this.currentPageReference.state.c__caseId;
    console.log('c__caseId = '+ this.currentPageReference.state.c__caseId); 
}
@wire (Convert, {})
    getData(result) {        
        if(result.data) {
            this.data = JSON.parse(JSON.stringify(result.data));
        }
		console.log('recordId : '+this.recordId);
    }

    rows = Array.from({ length: 80 }, (_, index) => ({
        id: index + 1,
        section: `Section ${index + 1}`,
        remediationPoint: `Remediation Point ${index + 1}`,
        numberOfIssues: 0,
    }));

    toast(title, msg, variant, mode) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: mode ? mode : 'dismissable'
        })
        this.dispatchEvent(toastEvent)
    } 

    handleSubmit(event) {
        this.draftValues = JSON.parse(JSON.stringify(event.detail.draftValues));
        saveRecord({"jsonData": JSON.stringify(this.draftValues), "caseId": this.recordId, "ogData": JSON.stringify(this.data)}).then(res => {
            if(res == 'Success') {
                this.toast('SUCCESS', 'Record has been Created successfully', 'success');
            } else {
                this.toast('Error', res, 'error');
            }
        }).catch(err => {
            this.toast('Error', err, 'error');
        })
        this.draftValues = [];
    }
}
