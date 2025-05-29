import { api, wire } from "lwc";
import { LightningElement } from 'lwc';
import getApprovers from "@salesforce/apex/CNT_CPQ_DynamicApprovalProcess.getApprovers";
import submitApprovalRequest from "@salesforce/apex/CNT_CPQ_DynamicApprovalProcess.submitApprovalRequest";
import approveAndRejectProcessWorkItemRequest from "@salesforce/apex/CNT_CPQ_DynamicApprovalProcess.requestApprovedAndReject";
import checkForRecordLock from "@salesforce/apex/CPQ_QuoteUtilityWO.checkForRecordLock";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTE_PRICING_TOOL_FIELD from "@salesforce/schema/Quote__c.Pricing_Tools__c";
import updateMsaDiscountReasonOnQuote from "@salesforce/apex/CNT_CPQ_DynamicApprovalProcess.updateMsaDiscountReasonOnQuote";
import{ refreshApex } from '@salesforce/apex';
import{NavigationMixin} from 'lightning/navigation';

export default class LWC_CPQ_DynamicApprovalProcess extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api isManualApprover = false;
    @api withPriority = false;
    @api objectLabel;
    showApproverComment = false;
    comment;
    load = false;
    isApprove = false;
    isReject = false;
    approvalActionMsg = '';
    approverData;
    error;

    wiredData;
    
    @api quotePricingTool;

    @wire(getApprovers, {recordId: '$recordId', ojectName: '$objectApiName', withPriority: '$withPriority'})
    wiredApprovalData(result) {
        this.wiredData = result;
        if (result.data) {
            this.approverData = JSON.parse(result.data);
            if(this.approverData.isSuccess) {
                if(this.isManualApprover) {
                   var level = 'Level 1';
                   var approvalmatrixByPriority = this.approverData.approvalMatrixByPriorityByLevel[level];
                   var approversList = Object.values(approvalmatrixByPriority)[0].approverIds;
                   setTimeout(()=>{ 
                    this.dispatchEvent(new CustomEvent("getapprovers", {
                        bubbles : true,
                        composed: true,
                        detail: { approversList: this.approverData,
                        approvalMatrix : this.approverData.approvalMatrixByPriorityByLevel }

                    }));
                }, 0)
                }
            }
        } else {
            this.error = result.error;
            this.showToast('Error', this.error, 'error');
        }
    }

    @api submitForMSAApprovals(files) {
        let urlLink = null;
        if (files.length) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Quote__c',
                    relationshipApiName: 'AttachedContentDocuments',
                    actionName: 'view'
                }
            }).then(url => {
                const baseUrl = window.location.origin;
                urlLink = baseUrl + url;
                this.processDataForMsaApproval(urlLink);

            }).catch(error => {
                this.showToast('Error', error, 'Error');
            })
        }
    }

    async processDataForMsaApproval(urlLink) {
        try {
            await this.updateMsaDiscountReason(true, urlLink);
            await refreshApex(this.wiredData);
            this.submitForApproval();
        } catch (error) {
            this.showToast('Error', error, 'Error');
        }
    }
	
	async updateMsaDiscountReason(isChecked, urlLink) {
        await updateMsaDiscountReasonOnQuote({
            recordId: this.recordId,
            isMsaOrHistoricalDiscountReason: isChecked,
            urlLink: urlLink
        });
    };
	
    @api submitForStandardApproval() {
        refreshApex(this.wiredData).then(() => {
            this.submitForApproval();
        })
    }

    @api submitForApproval() {
        if (!this.approverData.isSuccess) {
            this.showToast('Error', this.approverData.errorMsg, 'error');
            return;
        }
        this.load = !this.load;
        var approversMapJSON = JSON.stringify(this.approverData);
        submitApprovalRequest({"recordId": this.recordId, "objectName": this.objectApiName, "approversMapJSON": approversMapJSON, "chosenApprovers": null}).then(res => {
            if(res == 'Success') {
                this.showToast(res, 'Quote submitted for approval successfully.', 'success');
                this.checkForRecordLock();
            } else {
                this.load = !this.load;
                this.showToast('error', res, 'error');
            }
        }).catch (error => {
            this.showToast('error', error, 'error');
            this.load = !this.load;
        })
    }

    checkForRecordLock() {
        setTimeout(() => {
            checkForRecordLock({'recordId': this.recordId}).then(res => {
                this.dispatchCustomEvent('appoval_process', 'Success');
                this.load = !this.load;
            });
        }, 5000);
    }

    dispatchCustomEvent(name, value) {
        this.dispatchEvent(new CustomEvent(name, {
            detail: value
        }));
    }

    @api handleApprove() {
        this.comment = '';
        this.showApproverComment  = !this.showApproverComment;
        this.approvalActionMsg = 'Approve';
        this.isApprove = true;
        this.isReject = false;
    }

    handleCancelConfirmation() {
        this.showApproverComment  = !this.showApproverComment;
        this.comment = '';
    }

    @api handelReject() {
        this.comment = '';
        this.showApproverComment  = !this.showApproverComment;
        this.approvalActionMsg = 'Reject';
        this.isApprove = false;
        this.isReject = true;
    }

    handleApprovalAction() {
        this.comment = this.template.querySelector('lightning-textarea').value;
        if(this.isApprove) {
            this.load = !this.load;
            this.showApproverComment  = !this.showApproverComment;
            approveAndRejectProcessWorkItemRequest({"recordId": this.recordId, "comment": this.comment, "action": 'Approve'}).then(res => {
                if(res == 'Approved') {
                    this.showToast(res, 'Approved Successfully', 'success');
                    this.checkForRecordLock();
                } else {
                    this.load = !this.load;
                    this.showToast(res, 'Something went wrong', 'error')
                }
            }).catch (error => {
                this.load = !this.load;
                this.showToast('error', error, 'error')
            })
        } else if (this.isReject) {
            this.load = !this.load;
            this.showApproverComment  = !this.showApproverComment;
            this.comment = this.comment != null ? this.comment.trim() : '';
            if (this.quotePricingTool == 'EMEA'&& (this.comment == undefined || this.comment == '')) {
                this.showToast('','Please provide the reason for the rejection.','error');
                this.load = !this.load;
                return;
            }
            approveAndRejectProcessWorkItemRequest({"recordId": this.recordId, "comment": this.comment, "action": 'Reject'}).then(res => {
                if(res == 'Rejected') {
                    this.load = !this.load;
                    this.showToast(res, 'Rejected Successfully', 'success');
                    this.dispatchCustomEvent('appoval_process', 'Success');
                } else {
                    this.load = !this.load;
                    this.showToast(res, 'Something went wrong', 'error')
                }
            }).catch (error => {
                this.load = !this.load;
                this.showToast('error', error, 'error')
            })
        }
    }

    showToast(title, message, variant) {
        var toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}