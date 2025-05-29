import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getApprovalSteps from '@salesforce/apex/CNT_CPQ_ApprovalProcessRLController.getApprovalSteps';
const columns = [
    {
        label: 'Step Name',
        fieldName: 'name',
        type: 'text',
    },
    {
        label: 'Date',
        fieldName: 'aprDateStr',
        type: 'text',
    },
    {
        label: 'Status',
        fieldName: 'status',
        type: 'text',
    },
    {
        label: 'Assigned To',
        fieldName: 'assignedToURL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'assignedToName' },
            tooltip: { fieldName: 'assignedToName' },
            target: '_blank'
        }
    }
];
export default class LWC_CPQ_ApprovalProcessRL extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track approvalSteps = [];
    @track initialApprovalSteps = [];
    columns = columns;
    @track recordCount = '';
    @track isRecordExist = false;
    @wire(getApprovalSteps, { recordId: '$recordId' })
    wiredGetApprovalSteps({ error, data }) {
        if (data) {
            var temMap = new Map();
            const nonproxy = JSON.parse(JSON.stringify(data));
            nonproxy.forEach(entry => {
                entry = Object.assign(entry, {
                    assignedToURL: `/lightning/r/${entry.assignedToId}/view`,
                    actualApproverURL: `/lightning/r/${entry.actualApproverId}/view`
                })
            });
            this.approvalSteps = [...nonproxy];
            let temp = 1;
            this.approvalSteps.slice().reverse().forEach(record => {
                if (record.name != 'Approval Request Submitted' && temMap.has(record.name)) {
                    record.name = temMap.get(record.name);
                } else if (record.name != 'Approval Request Submitted' && !temMap.has(record.name)) {
                    temMap.set(record.name, 'Step'+temp);
                    record.name = 'Step' + temp;
                    temp++;
                }
            })
            this.initialApprovalSteps = this.approvalSteps.slice(0, 6);
            this.isRecordExist = this.approvalSteps.length > 0;
            this.recordCount = this.approvalSteps.length > 6 ? '(6+)' : '(' + this.approvalSteps.length + ')';
            this.error = null;
        }
        if (error) {
            this.error = error;
            this.approvalSteps = [];
        }
    }
    clickViewAll() {
        let cmpDef = {
            componentDef: "c:lWC_CPQ_ApprovalProcessRLFullView",
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objectApiName
            }
        };
        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef
            }
        });
    }
}