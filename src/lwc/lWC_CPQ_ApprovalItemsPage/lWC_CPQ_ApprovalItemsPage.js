import { LightningElement,wire,track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getApprovalData from '@salesforce/apex/CNT_CPQ_ApprovalItemsPage.getApprovalData';
import checkForBNF from '@salesforce/apex/CNT_CPQ_ApprovalItemsPage.checkForBNF';
import updateApprover from '@salesforce/apex/CNT_CPQ_ApprovalItemsPage.updateApprover';
import createWorkItemOnApprove from '@salesforce/apex/CNT_CPQ_TSJapanWorkflowController.createWorkItemOnApprove';
import createWorkItemOnReject from '@salesforce/apex/CNT_CPQ_TSJapanWorkflowController.createWorkItemOnReject';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

    const actions = [
    { label: 'Approve', name: 'approve'},
    { label: 'Reject', name: 'reject'},
    { label: 'Reassign', name: 'reassign'},
    ];

    const columns = [
    { label: 'RelatedTo', fieldName: 'quotelink', type: 'url',
    typeAttributes: { label: { fieldName: 'RelatedTo' }, }
    },
    { label: 'Type', fieldName: 'objLabel',type: 'String'},
    { label: 'Opportunity Number', fieldName: 'OpportunityNumber',type: 'String' },
    { label: 'Opportunity Name', fieldName: 'OpportunityLink',type: 'url',
    typeAttributes: { label: { fieldName: 'OpportunityName'} }
    },
    { label: 'Most Recent Approver', fieldName: 'recentapproverlink',type: 'url',
    typeAttributes: { label: { fieldName: 'recentapprover' }, }},
    { label: 'Date Submitted', fieldName: 'date', type: 'String'},
    { label: 'Action', type: 'action', initialWidth:'50px', typeAttributes: { rowActions: actions },},
    ];

    export default class LWC_CPQ_ApprovalItemsPage extends NavigationMixin(LightningElement)  {
    @track data = [];
    @track columns = columns;
    handleApproveComment = false;
    handleRejectComment = false;  
    @track commentVar = '';
    recordId = '';
    @track openModal = false;
    @track isDataPresent = false;
    wiredData;
    showSpinner = false;
    withPriority;
    objectApiName;
    objectLabel;
    currentApprover;
    nextApprover;
    approverField;
    isReassign;
    pwiId;
    showSpinnerForReassign = true;
    

    @wire(getApprovalData)
    wiredApprovalData(result) {
        this.wiredData = result;
        if (result.data) {
            var newdata = JSON.parse(JSON.stringify(result.data));
            let fixeddata = [];
            newdata.forEach (row =>{
                let dataline = {};
                dataline.pwiId = row.pwiId;
                var url =   location.href; 
                var baseURL = url.substring(0, url.indexOf('/', 14));
                dataline.quotelink = baseURL +'/'+ row.quotelink;
                dataline.actionLink = row.actionLink;
                dataline.RelatedTo = row.quoteName;
                dataline.Type = row.type;
                dataline.objLabel = row.objLabel;
                dataline.OpportunityNumber = row.OpportunityNumber;
                dataline.OpportunityName = row.OpportunityName;
                dataline.recentapproverlink = baseURL +'/'+ row.recentapproverlink;
                dataline.recentApproverId = row.recentapproverlink;
                dataline.recentapprover= row.recentapproverName;
                dataline.date = row.approvaldate;
                dataline.pricingTool = row.pricingTool;
                dataline.OpportunityLink = baseURL +'/'+ row.OpportunityLink;
                dataline.hasEditAccess = row.hasEditAccess;
                fixeddata.push(dataline);
            });
            this.data = fixeddata;
            this.error = undefined;
            if (this.data == undefined || this.data.length === 0) {
                this.isDataPresent = false;
            } else {
                this.isDataPresent = true;
            }
        } else {
            this.error = result.error;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const rowData = event.detail.row;
        if(!rowData.hasEditAccess) {
            this.showToast('Error', 'You do not have permission to access this record.', 'error');
            return;
        }
        if (rowData.Type == 'BNF2__c' || rowData.Type == 'MIBNF_Component__c') {
            if (actionName == 'approve' || actionName == 'reject') {
                this.navigateToApproveRejectPage(rowData);
            }
            else if (actionName == 'reassign') {
                this.recordId = rowData.actionLink;
                this.navigateToReassignPage(rowData);
            }
        } else if (rowData.Type == 'Apttus_Proposal__Proposal__c' && (rowData.pricingTool == 'AMESA' || rowData.pricingTool == 'OCE')) {
                    if (actionName == 'approve') {
                        this.navigateToApprove(rowData);
                    }
                    else if (actionName == 'reject') {
                        this.navigateToReject(rowData);
                    }
                    else if (actionName == 'reassign') {
                        this.navigateToRecordPage(rowData);
                    }        
        } else if (rowData.Type == 'Quote__c') {
            this.pwiId = rowData.pwiId;
            this.recordId = rowData.actionLink;
            this.objectApiName = rowData.Type;
            this.withPriority = true;
            this.objectLabel = "Quote";
            if(actionName == 'approve') {
                this.template.querySelector('c-l-w-c_-c-p-q_-dynamic-approval-process').handleApprove();
            } else if(actionName == 'reject') {
                this.template.querySelector('c-l-w-c_-c-p-q_-dynamic-approval-process').handelReject();
            } else if(actionName == 'reassign') {
                this.approverField = 'Approver_1__c';
                this.currentApprover = rowData.recentApproverId;
                this.nextApprover = this.currentApprover;
                this.isReassign = true;
            }
        } else {
            this.navigateToProInstWorkItemRecord(rowData);
        }
    }

    updateApproversOnQuote() {
        if(this.nextApprover == null || this.nextApprover == undefined || this.nextApprover == '') {
            this.showToast('Error', 'Select the approver first', 'error');
            return;
        }
        if(this.nextApprover == this.currentApprover) {
            this.showToast('Error', 'Change the approver first', 'error');
            return;
        }
        this.showSpinner = true;
        this.isReassign = false;
        updateApprover({"piwId": this.pwiId, "newActorId": this.nextApprover})
        .then(result => {
            if(result == 'Success') {
                this.showToast(result, 'Reassigned SuccessFully', result);
                this.refreshData();
            }
        }).catch(error => {
            this.showToast('Error', error, 'error');
            this.showSpinner = false;
        })
    }

    disableSpinnerForReassign() {
        this.showSpinnerForReassign = false;
    }

    handleCancelConfirmation(event) {
        this.handleApproveComment = false;
        this.handleRejectComment = false;
        this.commentVar = '';
        this.isReassign = false;
    }

    handleApproverChange(event) {
        var value = event.target.value;
        this.nextApprover = value;
    }

    handleChange(event) {
        this.commentVar = event.detail.value;
    }

    handleApproveRequest(event) {
        createWorkItemOnApprove({recordId : this.recordId, comment : this.commentVar})
        .then(result => {
            if(result == 'Approved' || result == 'SUCCESS') {
                this.showToast('Success', 'Approved Successfully', 'Success');
                this.refreshData();
            } else {
                this.showToast('Failed', result, 'Error');
            }
            this.handleApproveComment = false;
            this.commentVar = '';
        })
        .catch(error => {
            this.showToast('Failed', error, 'Error');
            this.handleApproveComment = false;
            this.showToast('Failed', error, 'Error');
            this.commentVar = '';
        });
    }

    handleRejectRequest() {
        createWorkItemOnReject({recordId : this.recordId, comment : this.commentVar})
        .then(result => {
            this.handleRejectComment = false;
            this.commentVar = '';
            this.showToast('Success', 'Rejected Successfully', 'Success');
            this.refreshData();
        })
        .catch(error => {
            this.handleRejectComment = false;
            this.showToast('Failed', error, 'Error');
            this.commentVar = '';
        });
    }
  
    navigateToApprove(row) {
        this.recordId = row.actionLink;
        this.handleApproveComment = true;
    }

    navigateToReject(row) {
        this.recordId = row.actionLink;
        this.handleRejectComment = true;
    }

    navigateToProInstWorkItemRecord(row) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.pwiId,
                    objectApiName: 'ProcessInstanceWorkitem',
                    actionName: 'view'
                },
            });
    }

    navigateToRecordPage(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.actionLink,
                objectApiName: 'Apttus_Proposal__Proposal__c',
                actionName: 'view'
            },
        });
    }

    navigateToApproveRejectPage(row) {
        if (row.Type == 'BNF2__c'){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: "/apex/BNF_Approval?id=" + row.actionLink  
                },
            });
        }
        
        if (row.Type == 'MIBNF_Component__c'){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {    
                    url: "/apex/MI_BNF_Approval?id=" + row.actionLink   
                },
            });
        }
    }

    navigateToReassignPage(row) {
        if (row.Type == 'BNF2__c'){
            checkForBNF({bnfId: this.recordId})
            .then(result => {
                if(result !== undefined && result == true){
                    this.showToast('warning!', "BNF's assigned to GFSS RA's cannot be reassigned, they must be rejected and resubmitted", 'warning');
                } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {    
                    url: "/apex/BNF_Reassign?id=" + row.actionLink   
                },
            });
        }
            })
            .catch(error => {
                this.showToast('error!', error, 'error');
            }); 
        }
        if (row.Type == 'MIBNF_Component__c'){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {    
                    url: "/apex/MIBNF_Reassign?id=" + row.actionLink   
                },
            });
        }
    }

    showModal() {
        this.openModal = true;
    }
    closeModal() {
        this.openModal = false;
    }

    showToast(title, message, variant) {
        var toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    refreshData() {
        this.showSpinner = true;
        refreshApex(this.wiredData).then(() => {
            this.showSpinner = false;
            return true;
        })
        .catch(err => {
            this.showSpinner = false;
            return false;
        });
    }

    onApprovalProcess(event) {
        if(event.detail == 'Success') {
            this.refreshData();
        }
    }
}