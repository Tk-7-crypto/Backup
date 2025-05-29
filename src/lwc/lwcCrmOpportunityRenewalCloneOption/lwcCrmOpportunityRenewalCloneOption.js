import { api, wire } from 'lwc';
import handleSubmit from '@salesforce/apex/CNT_CRM_OpportunityRenewalDashboard.handleSubmit';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import RenewalTask_OBJECT from '@salesforce/schema/Renewal_Task__c';
import NoRenewReasonField from '@salesforce/schema/Renewal_Task__c.No_Renew_Reason__c';
import RenewalTaskChangeDetail_OBJECT from '@salesforce/schema/Renewal_Task_Change_Detail__c';
import DroppedReasonField from '@salesforce/schema/Renewal_Task_Change_Detail__c.Dropped_Reason__c';
import LightningModal from 'lightning/modal';

const HEADER_COL = new Set([
    { label: "Clone", fieldName: "clone", iniStyle: 'width:04rem' },
    { label: "Comments", fieldName: "saleType", iniStyle: 'width:10rem;' },
    { label: "SAP Code", fieldName: "sapCode", iniStyle: 'width:08rem' },
    { label: "Product Name", fieldName: "productName", iniStyle: 'width:12rem;' },
    { label: "Business Type", fieldName: "businessType", iniStyle: 'width:08rem;' },
    { label: "Data Period Start", fieldName: "dataPeriodStart", iniStyle: 'width:08rem;' },
    { label: "Data Period End", fieldName: "dataPeriodEnd", iniStyle: 'width:08rem;' },
    { label: "Sale Type", fieldName: "saleType", iniStyle: 'width:06rem;' },
    { label: "Revenue Type", fieldName: "revenueType", iniStyle: 'width:08rem;' },
    { label: "Delivery Country", fieldName: "delivery_cnty", iniStyle: 'width:08rem;' },
    { label: "Total Price", fieldName: "value", iniStyle: 'width:08rem;' },
]);
//https://developer.salesforce.com/docs/component-library/bundle/lightning-modal/documentation
export default class LwcCrmOpportunityRenewalCloneOption extends LightningModal {

    headerCol = HEADER_COL;
    showSpinner = false;
    @api rtRecord;
    renewalTask;
    olis;
    optionOppComment = [];
    optionOliComment = [];

    errorMessage = [];
    showError = false;

    renewalTaskToBeUpdate = new Object();
    rtcdListToBeUpdate = [];

    @wire(getObjectInfo, { objectApiName: RenewalTask_OBJECT })
    RenewalTask_ObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$RenewalTask_ObjectInfo.data.defaultRecordTypeId', fieldApiName: NoRenewReasonField })
    getPicklistValuesForNoRenewReason({ data, error }) {
        if (data) {
            this.showSpinner = true;
            let defaultValue = [{ label: '---None---', value: '' }];
            this.optionOppComment = defaultValue.concat([...data.values]);
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = true;
            this.optionOppComment = [
                { label: '---None---', value: '' },
                { label: 'Lost to Competition', value: 'Lost to Competition' },
                { label: 'Lost not to Competition', value: 'Lost not to Competition' },
                { label: 'Merger Impact', value: 'Merger Impact' },
                { label: 'Product switch out', value: 'Product switch out' },
                { label: 'IMS no longer Delivery service', value: 'IMS no longer Delivery service' },
                { label: 'Cost', value: 'Cost' },
                { label: 'Loss of Exclusivity', value: 'Loss of Exclusivity' },
                { label: 'Other', value: 'Other' }
            ];
            this.handleError(error, 'Error while fetching Opp No Renewa Reason');
            this.showSpinner = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: RenewalTaskChangeDetail_OBJECT })
    RenewalTaskChangeDetail_ObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$RenewalTaskChangeDetail_ObjectInfo.data.defaultRecordTypeId', fieldApiName: DroppedReasonField })
    getPicklistValuesForDropedReason({ data, error }) {
        if (data) {
            this.showSpinner = true;
            let defaultValue = [{ label: '---None---', value: '' }];
            this.optionOliComment = defaultValue.concat([...data.values]);
            this.showSpinner = false;
        } else if (error) {
            this.showSpinner = true;
            this.optionOliComment = [
                { label: '---None---', value: '' },
                { label: 'Lost to Competition', value: 'Lost to Competition' },
                { label: 'Lost not to Competition', value: 'Lost not to Competition' },
                { label: 'Merger Impact', value: 'Merger Impact' },
                { label: 'Product switch out', value: 'Product switch out' },
                { label: 'IMS no longer Delivery service', value: 'IMS no longer Delivery service' },
                { label: 'Cost', value: 'Cost' },
                { label: 'Loss of Exclusivity', value: 'Loss of Exclusivity' },
                { label: 'Other', value: 'Other' }
            ];
            this.handleError(error, 'Error while fetching Oli Droped Reason');
            this.showSpinner = false;
        }
    }

    connectedCallback() {
        this.showSpinner = true;
        this.renewalTask = JSON.parse(JSON.stringify(this.rtRecord));
        this.olis = this.renewalTask.innerGridRecords;
        this.showSpinner = false;
    }

    handleCloneOptionChange(event) {
        try {
            // set comment to null if Clone is Selected
            if (event.target.value != 'No Renew') {
                this.template.querySelector('[data-id="noRenewComment"]').value = '';
            }
        } catch (error) {
            this.handleError(error, 'error while handling clone option radiobox');
            this.showSpinner = false;
        }
    }

    handleNoRenewCommentChange(event) {
        try {
            // auto Select No Renew if No Renew Comment is selected
            if (event.target.value != '') {
                this.template.querySelector('lightning-radio-group').value = 'No Renew';
            }
        } catch (error) {
            this.handleError(error, 'error while handling No Renew picklist selection');
            this.showSpinner = false;
        }
    }

    handleOliCloneCheckbox(event) {
        try {
            this.showSpinner = true;
            let index = event.currentTarget.dataset.index;
            this.olis[index].cloneCheckBox = event.target.checked;
            let queryTag = '[data-id="droppedReason"][data-index="' + index + '"]';
            setTimeout(() => {
                let commentBox = this.template.querySelector(queryTag);
                if (commentBox && !commentBox.value) {
                    commentBox.reportValidity();
                }
            }, 500);
            this.showSpinner = false;
        } catch (error) {
            this.handleError(error, 'error while handling oli clone checkbox');
            this.showSpinner = false;
        }
    }

    async handleSaveClick() {
        if (this.validateData()) {
            this.disableClose = true; // standardVariableThatNot let User Close Popup
            handleSubmit({ rt: this.renewalTaskToBeUpdate, rtcdList: this.rtcdListToBeUpdate })
                .then(result => {
                    this.disableClose = false;
                    if (result && result === 'true') {
                        this.closeModal('success');
                    } else {
                        this.handleError(result, 'handleSubmit JS');
                    }
                }).catch(error => {
                    this.disableClose = false;
                    this.handleError(error, 'handleSubmit apex');
                }).finally(() => {
                    this.disableClose = false;
                    this.showSpinner = false;
                });
        }
    }

    validateData() {
        this.errorMessage = [];
        if (!this.template.querySelector('[data-id="price_inc"]').value) {
            this.template.querySelector('[data-id="price_inc"]').value = 0.0;
        }
        if (!this.template.querySelector('[data-id="cloning_status"]').value) {
            this.template.querySelector('[data-id="cloning_status"]').value = '';
        }

        this.renewalTaskToBeUpdate = new Object();
        this.renewalTaskToBeUpdate.Id = this.renewalTask.id;
        this.renewalTaskToBeUpdate.Cloning_Status__c = this.template.querySelector('[data-id="cloning_status"]').value;
        this.renewalTaskToBeUpdate.No_Renew_Reason__c = this.template.querySelector('[data-id="noRenewComment"]').value;
        this.renewalTaskToBeUpdate.Targeted_Close_Date__c = this.template.querySelector('[data-id="closeDate"]').value;
        this.renewalTaskToBeUpdate.Data_Period_Shift__c = this.template.querySelector('[data-id="dataPeriodShift"]').value;
        this.renewalTaskToBeUpdate.Price_Increase__c = this.template.querySelector('[data-id="price_inc"]').value;
        this.renewalTaskToBeUpdate.Round_Up__c = this.template.querySelector('[data-id="roundup_action"]').checked;


        if (this.renewalTaskToBeUpdate.Cloning_Status__c === '' && this.renewalTaskToBeUpdate.No_Renew_Reason__c === '') {
            this.errorMessage.push('No Renew Comment must be specified or choose some other cloning action');
        }
        if (this.renewalTaskToBeUpdate.Cloning_Status__c === 'No Renew' && this.renewalTaskToBeUpdate.No_Renew_Reason__c == '') {
            this.errorMessage.push('No Renew Comment must be specified.');
        }
        if (this.renewalTaskToBeUpdate.Cloning_Status__c != 'No Renew' && this.renewalTaskToBeUpdate.No_Renew_Reason__c != '') {
            this.errorMessage.push('Please remove No Renew Comment.');
        }
        if (this.renewalTaskToBeUpdate.Targeted_Close_Date__c == '') {
            this.errorMessage.push('Targeted Close Date must be specified.');
        } else {
            let todayDate = new Date();
            let minAllowedDate = todayDate.setDate(todayDate.getDate() - 1);
            let maxAllowedDate = todayDate.setFullYear(todayDate.getFullYear() + 5);
            let selectedCloseDate = new Date(this.renewalTaskToBeUpdate.Targeted_Close_Date__c);
            if (selectedCloseDate < minAllowedDate) {
                this.errorMessage.push('Targeted close date should not be less then current date..');
            } else if (selectedCloseDate > maxAllowedDate) {
                this.errorMessage.push('Target close date can not be more than 5 years in the future.');
            }
        }
        if (this.renewalTaskToBeUpdate.Price_Increase__c < -999) {
            this.errorMessage.push('%Price Incremant can not be less than -999.');
        } else if (this.renewalTaskToBeUpdate.Price_Increase__c > 999) {
            this.errorMessage.push('%Price Incremant can not be more than 999.');
        }

        this.rtcdListToBeUpdate = [];
        if (this.renewalTaskToBeUpdate.Cloning_Status__c != 'No Renew' && this.olis.length > 0) {
            for (let i = 0; i < this.olis.length; i++) {
                let currentItem = this.olis[i];
                let rtdc = new Object();
                rtdc.Id = currentItem.renewalTaskDetailId;
                rtdc.Opportunity_Line_Item_Id__c = currentItem.id;
                rtdc.Dropped_Reason__c = null;
                if (currentItem.cloneCheckBox === false) {
                    let queryTag = '[data-id="droppedReason"][data-index="' + i + '"]';
                    let commentBox = this.template.querySelector(queryTag);
                    let droppedReason = commentBox.value;
                    if (droppedReason) {
                        rtdc.Dropped_Reason__c = droppedReason;
                    } else {
                        commentBox.setCustomValidity('Reason for not renewing must be specified for product');
                        commentBox.reportValidity();
                        this.errorMessage.push('Under Comment, reason for not renewing must be specified for products: ' + currentItem.productName)
                    }
                }
                this.rtcdListToBeUpdate.push(rtdc);
            }
        }
        if (this.errorMessage.length > 0) {
            this.showError = true;
            this.renewalTaskToBeUpdate = new Object();
            this.rtcdListToBeUpdate = [];
            return false;
        }
        return true;
    }

    handleCloseClick() {
        this.closeModal('canceled');
    }

    closeModal(message) {
        this.close(message);
    }

    get optionCloning() {
        return [
            { label: 'Basic Clone', value: 'Basic Clone' },
            { label: 'Detail Clone', value: 'Detail Clone' },
            { label: 'No Renew', value: 'No Renew' }
        ];
    }

    get optionDataPeriodShift() {
        return [
            { label: '1', value: '1' }, { label: '2', value: '2' }, { label: '3', value: '3' }, { label: '4', value: '4' },
            { label: '5', value: '5' }, { label: '6', value: '6' }, { label: '7', value: '7' }, { label: '8', value: '8' },
            { label: '9', value: '9' }, { label: '10', value: '10' }, { label: '11', value: '11' }, { label: '12', value: '12' },
            { label: '24', value: '24' }, { label: '36', value: '36' }, { label: '48', value: '48' }, { label: '60', value: '60' },
            { label: '72', value: '72' }
        ];
    }

    get zeroOlis() {
        return (this.olis && this.olis.length > 0) ? false : true;
    }

    errorCallback(error, stack) {
        this.showError = true;
        this.errorMessage = error;
    }

    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        console.log(error);
        var errorMsg = new Array();
        if (Array.isArray(error)) {
            error.forEach(currentError => {
                errorMsg.push(currentError);
            });
        } else {
            var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
            var errorCode = (error.body && error.body.errorCode) ? error.body.errorCode : error.status ? error.status : '';
            if (JSON.parse(err).fieldErrors && Object.keys(JSON.parse(err).fieldErrors).length > 0) {
                let fieldError = JSON.parse(err).fieldErrors;
                for (let [key, value] of Object.entries(fieldError)) {
                    errorMsg.push(key + ': ' + value[0].message);
                    errorCode = value[0].statusCode;
                }
            } else if (JSON.parse(err).pageErrors && Object.keys(JSON.parse(err).pageErrors).length > 0) {
                let pageErrors = JSON.parse(err).pageErrors;
                for (let [key, value] of Object.entries(pageErrors)) {
                    errorMsg.push(value.message);
                    errorCode = value.statusCode;
                }
            } else {
                errorMsg.push(err == "{}" ? 'Unexpected error !!!' : err);
            }
        }

        this.errorMessage = errorMsg;
        this.showError = true;
    }

    disconnectedCallback() {
        this.rtRecord = null;
        this.renewalTask = null;
        this.olis = null;
        this.optionOppComment = [];
        this.optionOliComment = [];
        this.errorMessage = [];
        this.showError = false;
        this.renewalTaskToBeUpdate = new Object();
        this.rtcdListToBeUpdate = [];
    }

}