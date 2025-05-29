import { LightningElement, track , api, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getColumns from '@salesforce/apex/CNT_CPQ_RelatedListController.getColumns';
import getData from '@salesforce/apex/CNT_CPQ_RelatedListController.getData';
import updateRecords from '@salesforce/apex/CNT_CPQ_RelatedListController.updateRecords';

export default class LWC_CPQ_RelatedList extends  NavigationMixin(LightningElement) {

    @api recordId;
    @api pricingTool;
    @api quoteRequisiteType;
    @api objectApiName;
    @api isFullView = false;
    @track childObjectApiName;
    @track recordName;
    @track recordURL;
    @track records = [];
    @track initialRecords = [];
    @track lastSavedData = [];
    @track fieldSet = [];
    @track draftValues = [];
    columns = [];
    @track recordCount = '('+ 0 +')';
    @track viewLink = 'View All';
    @track nameField = 'Name';
    @track isRecordExist = false;
    isFullviewTemp = false;
    isLoading = true;
    privateChildren = {};
    recordFields = ["Quote__c.Name"];

    connectedCallback() {
        this.getColumns(this.quoteRequisiteType, this.pricingTool);
    }

    renderedCallback() {
        if (!this.isComponentLoaded) {
            window.addEventListener('click', (evt) => {
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
        }
    }

    disconnectedCallback() {
        window.removeEventListener('click', () => { });
    }

    @wire(getRecord, { recordId: "$recordId", fields: "$recordFields" })
    wiredRecord({ error, data }) {
        if (data) {
            if (!this.isFullviewTemp) {
                this.recordName = data.fields.Name.value;
                this.recordURL = '/lightning/r/'+this.recordId+'/view';
            }
        } else if (error) {
            this.error = error;
        }
    }

    getColumns(quoteRequisiteType, pricingTool) {
        getColumns({ quoteRequisiteType: quoteRequisiteType, pricingTool: pricingTool })
            .then((data) => {
                if (data && data.length > 0) {
                    data.sort((a, b) => a.orderNumber - b.orderNumber);
                    var tempData = [];
                    var tempFields = [];
                    const idSuffix = '.Id';
                    const typeURL = 'url';
                    data.forEach(element => {
                        this.childObjectApiName = element.objectApiName;
                        if(!this.isFullView && element.isCompact === true) {
                            if(element.columnWrapper.fieldName == 'Name') {
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName + idSuffix, type: element.columnWrapper.type, editable: element.columnWrapper.editable, typeAttributes: { label: { fieldName: element.columnWrapper.fieldName }, tooltip: { fieldName: element.columnWrapper.fieldName }}});
                            } else if(element.columnWrapper.type == 'lookup') {
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName.split('.')[0] + idSuffix, type: typeURL, editable: element.columnWrapper.editable, typeAttributes: { label: { fieldName: element.columnWrapper.fieldName }, tooltip: { fieldName: element.columnWrapper.fieldName }}});
                            } else if(element.columnWrapper.type == 'picklist'){
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName, type: element.columnWrapper.type, editable: element.columnWrapper.editable,
                                    typeAttributes: {
                                        label: element.columnWrapper.label,
                                        name: element.columnWrapper.fieldName,
                                        value: { fieldName: element.columnWrapper.fieldName },
                                        placeholder: 'Choose ' + element.columnWrapper.label,
                                        context: { fieldName: 'Id' },
                                        variant: 'label-hidden',
                                        editable: element.columnWrapper.editable,
                                        objectApiName: element.objectApiName,
                                        fieldApiName: {
                                            fieldApiName: element.columnWrapper.fieldName,
                                            objectApiName: element.objectApiName
                                        }
                                    },
                                    cellAttributes: {
                                        class: { fieldName: 'fieldCellClass' }
                                    }
                                });
                            } else {
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName, type: element.columnWrapper.type, editable: element.columnWrapper.editable});
                            }
                            tempFields.push(element.columnWrapper.fieldName);
                        } else if (this.isFullView) {
                            if(element.columnWrapper.fieldName == 'Name') {
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName + idSuffix, type: element.columnWrapper.type, editable: element.columnWrapper.editable, typeAttributes: { label: { fieldName: element.columnWrapper.fieldName }, tooltip: { fieldName: element.columnWrapper.fieldName }}});
                            } else if(element.columnWrapper.type == 'lookup') {
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName.split('.')[0] + idSuffix, type: typeURL, editable: element.columnWrapper.editable, typeAttributes: { label: { fieldName: element.columnWrapper.fieldName }, tooltip: { fieldName: element.columnWrapper.fieldName }}});
                            } else if(element.columnWrapper.type == 'picklist'){
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName, type: element.columnWrapper.type, editable: element.columnWrapper.editable,
                                    typeAttributes: {
                                        label: element.columnWrapper.label,
                                        name: element.columnWrapper.fieldName,
                                        value: { fieldName: element.columnWrapper.fieldName },
                                        placeholder: 'Choose ' + element.columnWrapper.label,
                                        context: { fieldName: 'Id' },
                                        variant: 'label-hidden',
                                        editable: element.columnWrapper.editable,
                                        objectApiName: element.objectApiName,
                                        fieldApiName: {
                                            fieldApiName: element.columnWrapper.fieldName,
                                            objectApiName: element.objectApiName
                                        }
                                    },
                                    cellAttributes: {
                                        class: { fieldName: 'fieldCellClass' }
                                    }
                                });
                            } else {
                                tempData.push({label: element.columnWrapper.label, fieldName: element.columnWrapper.fieldName, type: element.columnWrapper.type, editable: element.columnWrapper.editable});
                            }
                            tempFields.push(element.columnWrapper.fieldName);
                        }
                    });
                    this.columns = tempData;
                    this.fieldSet = tempFields;
                    this.getData(this.recordId, this.fieldSet, this.quoteRequisiteType, this.childObjectApiName);
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    getData(recordId, fieldSet, quoteRequisiteType, objectApiName) {
        getData({ recordId: recordId, fieldApiNames: fieldSet, quoteRequisiteType: quoteRequisiteType, objectApiName: objectApiName})
            .then((data) => {
                this.isLoading = false;
                this.isFullviewTemp = true;
                const nameField = 'Name';
                const lookupFieldSuffix = '__r';
                this.records = data.map(row => {
                    Object.keys(row).forEach(key => {
                        if (key === nameField) {
                            row[key + '.Id'] = `/lightning/r/${row.Id}/view`;
                        }
                        if (key.endsWith(lookupFieldSuffix) && row[key]) {
                            row[key + '.Id'] = `/lightning/r/${row[key].Id}/view`;
                            row[key + '.Name'] = row[key].Name;
                        }
                    });
                    return {...row};
                })
                this.isRecordExist = this.records.length > 0;
                if(!this.isFullView) {
                    this.initialRecords = this.records.slice(0, 6);
                    this.recordCount = this.records.length > 6 ? '(6+)' : '(' + this.records.length + ')';
                } else if (this.isFullView) {
                    this.initialRecords = this.records;
                    this.recordCount = '(' + this.records.length + ')' ;
                    this.viewLink = null;
                    this.isFullviewTemp = false;
                }
                this.error = null;
                this.lastSavedData = this.initialRecords;
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                this.records = [];
            });
    }

    clickViewAll() {
        this.isFullView = true;
        let cmpDef = {
            componentDef: "c:lWC_CPQ_RelatedList",
            attributes: {
                recordId: this.recordId,
                pricingTool: this.pricingTool,
                objectApiName: this.objectApiName,
                quoteRequisiteType: this.quoteRequisiteType,
                isFullView: this.isFullView
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

    handleSave(event) {
        event.preventDefault();
        if(this.isFullviewTemp) {
            this.isFullView = false;
        }
        this.isLoading = true;
        updateRecords({ recordsToUpdate: this.draftValues, objectApiName: this.childObjectApiName })
            .then(result => {
                if(result === true) {
                    this.getData(this.recordId, this.fieldSet, this.quoteRequisiteType, this.childObjectApiName);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: "Records updated successfully.",
                            variant: "success",
                        }),
                    );
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.handleCancel(event);
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Error",
                      message: error ? error.body ? error.body.message ? error.body.message : error.body : error : null,
                      variant: "error",
                    }),
                );
            });
            this.draftValues = [];
    }

    handleWindowOnclick(context) {
        this.resetPopups('c-lwc-cpq-custom-picklist', context);
    }

    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    }

    handleItemRegister(event) {
        event.stopPropagation();
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name)) {
            this.privateChildren[item.name] = {};
        }
        this.privateChildren[item.name][item.guid] = item;
    }


    handleCancel(event) {
        event.preventDefault();
        this.initialRecords = JSON.parse(JSON.stringify(this.lastSavedData));
        this.handleWindowOnclick('reset');
        this.draftValues = [];
    }
	
	handleCellChange(event) {
        event.preventDefault();
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleValueChange(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = {
            Id: dataRecieved.context,
            [dataRecieved.name]: !this.isEmpty(dataRecieved.value) ? dataRecieved.value : ''
        };
        this.setClassesOnData(
            dataRecieved.context,
            'fieldCellClass',
            'slds-cell-edit slds-is-edited'
        );
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.initialRecords));
        copyData.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        this.initialRecords = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
            
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    handleEdit(event) {
        event.preventDefault();
        let dataRecieved = event.detail.data;
        this.handleWindowOnclick(dataRecieved.context);
        this.setClassesOnData(
            dataRecieved.context,
            'fieldCellClass',
            'slds-cell-edit'
        );
    }

    setClassesOnData(id, fieldName, fieldValue) {
        this.initialRecords = JSON.parse(JSON.stringify(this.initialRecords));
        this.initialRecords.forEach((detail) => {
            if (detail.Id === id) {
                detail[fieldName] = fieldValue;
            }
        });
    }

    isEmpty(val) {
        if (val === undefined || val === '' || val === null) {
            return true;
        }
        return false;
    }

    sortDataByKey(a, b, key) {
        if (a[key] < b[key])
            return -1;
        if (a[key] > b[key])
            return 1;
        return 0;
    }
    get recordFields() {
        return [`${this.objectApiName}.${this.nameField}`];
    }
}