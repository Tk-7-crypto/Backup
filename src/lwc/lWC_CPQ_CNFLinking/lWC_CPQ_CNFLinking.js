import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CONumber from '@salesforce/schema/Apttus_Proposal__Proposal__c.Change_Order_Number__c';
import getCNFRecords from "@salesforce/apex/CNT_CPQ_CNFLinking.getCNFRecords";
import updateCNFs from "@salesforce/apex/CNT_CPQ_CNFLinking.updateCNFs";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import customCSS from '@salesforce/resourceUrl/toastMessageCSS';
import { CloseActionScreenEvent } from 'lightning/actions';

const columns = [
    {
        label : 'Quote Name',
        fieldName: 'Name2URL',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }
    },
    {label : 'Scenario', fieldName : 'RFP_Scenario__c'},
    {label: 'CO Number', fieldName: 'Change_Order_Number__c', type: 'customPicklist', editable: true,
        typeAttributes: {
            label: 'CO Number',
            options: {fieldName: 'CONumberOptions'},
            value: {fieldName: 'CONumber'},
            context: {fieldName: 'Id'},
            isPickList: true,
        }
    },
    {label : 'Status', fieldName : 'CNF_Status__c'},
    {label : 'Currency', fieldName : 'CurrencyIsoCode', type : 'text'},
    {label : 'Actual Quote Amount', fieldName : 'Actual_Quote_Amount__c'},
    {label : 'Approval/Rejected/Completed Date', fieldName : 'CNF_Approval_Date__c'}
];

export default class LWC_CPQ_CNFLinking extends LightningElement {
    @api recordId;
    @api objectApiName = 'Apttus_Proposal__Proposal__c';
    recordTypeId;
    objectInfoData;
    @track page = 1;
    @track pageSize = 8;
    @track totalRecords;
    @track disablePrevious = true;
    @track disableNext = false;
    CONumberOptions;
    cnfData = [];
    data = [];
    columns = columns;
    draftValues = [];
    showRecords;
    header = 'CNF Linking';
    selectedRows = [];
    spinner = true;
    showPagination = false;
    cnfToUpdate = [];
    changeOrderId;
    connectedCallback() {
        setTimeout(() => {
            this.getRecords(this.recordId);
        }, 0.0005);
    }

    renderedCallback() {
        loadStyle(this, customCSS);
    }
    
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.objectInfoData = data; 
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.toast('Error', JSON.stringify(error), 'error');
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName:  CONumber})
    wiredCountryTypes({ error, data }) {
        if (data) {
            this.CONumberOptions = data.values.map(picklistValue => {
                return {
                    label: picklistValue.label,
                    value: picklistValue.value
                };
            });
        } else if (error) {
            this.toast('Error', JSON.stringify(error), 'error');
        }
    }

    getRecords(recordId) {
        getCNFRecords({recordId : recordId})
        .then(res => {
            var result = res.propList;
            var scenario = res.Scenario.replace('Change Order ', '');
            this.changeOrderId = res.coId;
            if(result && result.length > 0) {
                this.CONumberOptions?.splice(this.CONumberOptions?.findIndex(i => i.value === "00"), 1);
                result.forEach(record => {
                    record.Name2URL = record.Id != undefined ? `/lightning/r/${record.Id}/view` : "";
                    record.CONumberOptions = this.CONumberOptions;
                    this.data.push(record);
                    if (record.Change_Order_Number__c == scenario) {
                        this.cnfToUpdate.push(record);
                    }
                });
                this.cnfData = this.data?.slice(0, this.pageSize);
                this.totalRecords = this.data.length;
                this.disableNext = this.totalRecords <= this.pageSize;
                this.showPagination = !this.disableNext;
                this.showRecords = true;
                this.spinner = !this.spinner;
            } else {
                this.showRecords = false;
                this.spinner = !this.spinner;
            }
        }).catch(error => {
            this.showToast('error', 'Failed to get records. ' + error.message, 'error');
        })
    }

    handleCellChange(event) {
        var flag = false;
        if (this.selectedRows?.length > 0) {
            this.selectedRows.forEach(element => {
                if (element.Id == event.detail.draftValues[0].Id) {
                    element.Change_Order_Number__c = this.getPicklist(event.detail.draftValues[0].Change_Order_Number__c);
                    flag = true;
                }
            })
        }
        if (!flag) {
            event.detail.draftValues[0].Change_Order_Number__c = this.getPicklist(event.detail.draftValues[0].Change_Order_Number__c);
            this.selectedRows.push(event.detail.draftValues[0]);
        }
    }

    getPicklist(value) {
        if (value?.length === 1 && value * 1 >= 0) {
            return  0 + value;
        } else {
            return value;
        }
    }

    handleFinish() {
        this.spinner = !this.spinner;
        this.cnfToUpdate.forEach(record => {
            Object.keys(record).forEach((key) => { if (key != 'Id' && key != 'Related_Change_Order__c' && key != 'Change_Order_Number__c') delete record[key]});
        })
        if (this.validateInput()) {
            this.cnfRecords = this.selectedRows.concat(this.cnfToUpdate);
            updateCNFs({records : this.cnfRecords, flag : true, recordId : this.changeOrderId})
            .then(result => {
                if (result == 'Success') {
                    this.showToast('Success', 'Records updated successfully.', 'Success');
                    this.handleCancel();
                    window.open(window.location.origin + '/' + this.recordId, "_self");    
                } else {
                    this.showToast('Error', result, 'Error')
                }
                this.spinner = !this.spinner;
            }).catch(error => {
                this.spinner = !this.spinner;
                this.showToast('Error', 'Failed to update. ' + error.message, 'Error');
            })
        } else {
            this.spinner = !this.spinner;
            this.showToast('Error', 'Please input the value between 1 to 25.', 'Error');
        }
    }

    validateInput() {
        var flag = true;
        this.selectedRows.forEach(record => {
            if((1*record.Change_Order_Number__c) < 1 || (1*record.Change_Order_Number__c) > 25) {
                flag = false;
            }
        })
        return flag;
    }

    previousPage() {
        if (this.page > 1) {
            this.page--;
            this.updatePage();
        }
    }

    nextPage() {
        if ((this.page * this.pageSize) < this.totalRecords) {
            this.page++;
            this.updatePage();
        }
    }

    updatePage() {
        const start = (this.page - 1) * this.pageSize;
        const end = this.page * this.pageSize;
        this.cnfData = this.data.slice(start, end);
        this.disablePrevious = this.page === 1;
        this.disableNext = (this.page * this.pageSize) >= this.totalRecords;
    }

    showToast(title, msg, variant, mode) {
        const toastEvt = new ShowToastEvent({
            title : title,
            message : msg,
            variant : variant,
            mode: mode ? mode : 'dismissable'
        });
        this.dispatchEvent(toastEvt);
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
        const closeWindow = new CustomEvent("close");
        this.dispatchEvent(closeWindow);
    }
}
