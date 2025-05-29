import { LightningElement, track , wire, api } from 'lwc';
import getApprovalSteps from '@salesforce/apex/CNT_CPQ_ApprovalProcessRLController.getAllApprovalSteps';
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
    },
    {
        label: 'Actual Approver',
        fieldName: 'actualApproverURL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'actualApproverName' },
            tooltip: { fieldName: 'actualApproverName' },
            target: '_blank'
        }
    },
    {
        label: 'Comments',
        fieldName: 'comment',
        type: 'test',
    }
];
export default class LWC_CPQ_ApprovalProcessRLFullView extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track approvalSteps = [];
    columns = columns;
    @track recordName = '';
    @track recordURL = '';
    allRecordsURL = '';
    objectLabel;
    showSpinner = true;   
    @wire(getApprovalSteps, { recordId: '$recordId', objectApiName: '$objectApiName'})
    wiredGetApprovalSteps({ error, data }) {
        if(data) {
            this.approvalSteps = data.approvalSteps.map(row => {
              const assignedToURL = `/lightning/r/${row.assignedToId}/view`;
              const actualApproverURL = `/lightning/r/${row.actualApproverId}/view`;
              return {...row , assignedToURL, actualApproverURL};
            })
            this.recordName = data.recordName;
            this.objectLabel = data.objectLabel + 's';
            this.recordURL = '/lightning/r/'+this.recordId+'/view';
            this.error = null;
            this.allRecordsURL = '/lightning/o/' + this.objectApiName + '/home';
            this.showSpinner = false;
            const nonproxy = JSON.parse(JSON.stringify(this.approvalSteps));
            var temMap = new Map();
            let temp = 1;
            nonproxy.slice().reverse().forEach(record => {      
                if (record.name != 'Approval Request Submitted' && temMap.has(record.name)) {
                    record.name = temMap.get(record.name);
                } else if (record.name != 'Approval Request Submitted' && !temMap.has(record.name)) {                
                    temMap.set(record.name, 'Step'+temp);
                    record.name = 'Step' + temp;
                    temp++;
                }
            });
            this.approvalSteps = [...nonproxy];
        }
        if(error) {
            this.error = error;
            this.approvalSteps = [];
            this.showSpinner = false;
        }
    }
}