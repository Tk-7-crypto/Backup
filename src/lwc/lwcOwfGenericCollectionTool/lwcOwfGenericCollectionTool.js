import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getCollectionData from '@salesforce/apex/CNT_OWF_GenericCollectionTool.getCollectionData';
import saveCollectionData from '@salesforce/apex/CNT_OWF_GenericCollectionTool.saveCollectionData';
import COLLECTION_TOOL from "@salesforce/schema/CollectionTool__c";

export default class LwcOwfGenericCollectionTool extends NavigationMixin(LightningElement) {
    @track collectionData = null;
    @api config;
    @api enableRedirect;
    collectionRecordTypeName = null;
    collectionRecordTypeId = null;
    isLoading = true;
    showFixedRow = false;
    dynamicClassForHeading = 'slds-size_4-of-12 slds-text-align_center';
    dynamicClassForButton = 'slds-size_4-of-12 slds-text-align_right';
    _bidHistoryId;
    get bidHistoryId() {
        return this._bidHistoryId;
    }
    set bidHistoryId(value) {
        this.isLoading = true;
        this._bidHistoryId = value;
        this.collectionRecordTypeName = null;
        this.collectionRecordTypeId = null;
        this.collectionData = null;
        this.getCollectionData();
    } 
    connectedCallback() {
        if(!this.config) {
            this.config = null;
        }
    } 

    @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const urlValue = currentPageReference.state.c__Bid_History;      
            if (urlValue) {
                this.bidHistoryId = urlValue;
            } else {
                this.showToast('Error', 'Invalid Parameters, please try again.', 'Error', 'dismissable');
            }
        }
    }

    @wire(getObjectInfo, {recordTypeName: '$collectionRecordTypeName', objectApiName: COLLECTION_TOOL }) 
    wireAccountData(objectInfo, error){
        if(this.collectionRecordTypeName){            
            let recordTypeInfo = objectInfo?.data?.recordTypeInfos;
            if(recordTypeInfo){             
                this.collectionRecordTypeId = Object.keys(recordTypeInfo).find(rtype=>(recordTypeInfo[rtype].name === this.collectionRecordTypeName));
            }
        }
    }

    @wire(getPicklistValuesByRecordType, {recordTypeId : '$collectionRecordTypeId', objectApiName: COLLECTION_TOOL})
    picklistValuesOfCountries({error,data}) {
        if(data){
            this.fillPicklistOptions(data);
        } 
        else if(error){ 
            console.log(JSON.parse(JSON.stringify(error)));
            this.error = error;
            this.isLoading = false;   
        }
    } 

    fillPicklistOptions(data) {
        let config = {...this.collectionData.config};        
        config.columns.forEach((col) => {
            if(col.type === 'picklist' || col.type === 'picklist-lookup' ) {
                let options = [];
                if(col.fetchOptionsFromOtherField) {
                    const fields = col.fetchOptionsOtherFieldName.split('.');
                    const optionValues = this.collectionData.bidHistory[fields[0]][fields[1]];
                    if(optionValues) {
                        optionValues.split(';').forEach(value => {
                            options.push(
                                {
                                    label: value,
                                    value: value
                                }
                            );
                        })
                    } else {
                        options = data.picklistFieldValues[col.apiName].values;
                    }                
                }
                else if(col.dependentField && col.controllingValue){
                    let dependentPickList = data.picklistFieldValues[col.apiName];
                    let controllerFieldIndex = dependentPickList.controllerValues[col.controllingValue];
                    dependentPickList.values.forEach(val=>{
                        if(val.validFor.includes(controllerFieldIndex)){
                            options.push(
                                 {
                                     label: val.value,
                                     value: val.value
                                 }); 
                        }
                    })
                }
                else {
                    options = data.picklistFieldValues[col.apiName].values;
                }
                col.options = options;
            } 
        });
        this.collectionData.config = config;
        this.isLoading = false;       
    }

    getCollectionData() {      
        getCollectionData({ bidHistoryId: this.bidHistoryId , config: this.config})
        .then(result => {
            this.collectionData = JSON.parse(JSON.stringify(result));
            this.collectionData.tables.forEach(table => {
                if(table.rows.length === 0) {
                    this.addNewRow(table.tableNumber);
                }
                this.setCloneButtonVisibility(table);
                this.setDefaultValue(table);
            });
            let picklistExists = this.collectionData.config.columns.some((x) => x.type === 'picklist' || x.type === 'picklist-lookup');
            if(picklistExists) {
                    this.collectionRecordTypeName = this.collectionData.config.collectionRecordTypeName;
            }
            this.addIndex();
            this.isLoading = false;
        })
        .catch(error => {   
            this.isLoading = false;       
            console.log(JSON.stringify(error));  
            this.showToast('Error', error.body?.message, 'Error', 'dismissable');
            this.isLoading = false;
        }).finally(() => {
        });
    }
    addIndex(){
        for(let i=0; i<this.collectionData.tables.length; i++) {
            if(Object.keys(this.collectionData.tables[i].fixedRow.cells).length > 0 ){
                this.dynamicClassForHeading = 'slds-size_4-of-12 slds-text-align_center slds-border_bottom';
                this.dynamicClassForButton = 'slds-size_4-of-12 slds-text-align_right slds-border_bottom';
                this.showFixedRow = true;
                
            }
            
            let rowIndexValue = 1;
            for(let j=0; j<this.collectionData.tables[i].rows.length; j++) {
                if(!this.collectionData.tables[i].rows[j].isDeleted) {
                    this.collectionData.tables[i].rows[j].rowIndex = rowIndexValue++;
                }
                
            }
        }
    }
    saveCollectionData() { 
        const hasErrors  = this.checkErrors(); 
        if(!hasErrors) {
            this.isLoading = true;
            saveCollectionData({ bidHistoryId: this.bidHistoryId, collectionTablesJSON: JSON.stringify(this.collectionData.tables), config: this.config})
            .then(result => {
                result.forEach(table => {
                    this.setCloneButtonVisibility(table);
                });
                this.collectionData.tables = result;
                this.addIndex();
                this.showToast('Success', 'Records have been saved successfully.', 'Success', 'dismissable');
                if(this.collectionData.config.redirectToBid && this.enableRedirect){
                    this.navigateToRecord(); 
                }
            }).catch(error => {
                if(error && error.body.message) {
                    const errorMessage = (error.body.message).split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                    // Extract the message if it exists
                    if (errorMessage.length > 1) {
                        const displayError = errorMessage[1].replace(": []","");
                        this.showToast('Error', displayError , 'Error', 'dismissable');
                   }else {
                    this.showToast('Error', error.body.message , 'Error', 'dismissable');
                   }
                }
                console.log(error);
                this.isLoading = false;
            }).finally(() => {
                this.isLoading = false;
            });
        }        
    }
    
    checkErrors(){
        let hasError = this.validateRequiredFields();
        if (hasError){
            this.showToast('Error', this.collectionData.config.requiredErrorMessage, 'Error', 'dismissable');
            return hasError;
        }
        else {
            hasError = this.checkIfAnyInputMismatch();
            if(!hasError){
                this.showToast('Error', 'Please update the invalid entries and try again.', 'Error', 'dismissable');
                return true;
            } 
            else{
                hasError = this.checkIfAnythingToSave();
            }
        }
        if (hasError) {
            this.showToast('Info', 'Nothing to save, please update the values and then save.', 'info', 'dismissable');
            return hasError;
        }
        return hasError;
    }
    
    get disableSave() {
        return this.checkIfAnythingToSave();
    }
    get isUnsaveData() {
        return this.collectionData.config.displayUnsaveDataMessage && !this.checkIfAnythingToSave();
    }
    
    checkIfAnyInputMismatch(){
        let isChildValidated = true;
        [...this.template.querySelectorAll("c-lwc-owf-generic-collection-tool-row")].forEach((element) => {
            if (element.checkValidity() === false) {
                isChildValidated = false;
            }
        });
        return isChildValidated;
    }

    checkIfAnythingToSave() {
        let nothingToSave = true;
        this.collectionData.tables.forEach(table => {
            table.rows.forEach(row => {
                if(row.action === 'INSERT' || row.action === 'DELETE' || row.action === 'UPDATE') {
                    nothingToSave = false;
                    return;
                }
            });
        });
        return nothingToSave;
    }

    validateRequiredFields() {
        let hasError = false;
        if(this.collectionData.config.requiredValidationFirstRowOnly) {
            this.collectionData.tables.forEach(table => {
                let rows = table.rows.filter((row) => (row.action === 'INSERT' || row.action === 'UPDATE'));  
                if(rows.length > 0 && this.validateRow(rows[0])) {
                    hasError = true;
                }
            });
        } else {
            this.collectionData.tables.forEach(table => {
                table.rows
                .filter((row) => (row.action === 'INSERT' || row.action === 'UPDATE'))
                .forEach(row => {
                    if(this.validateRow(row)) {
                        hasError = true;
                    }                
                });   
                if(this.validateRow(table.fixedRow)) {
                    hasError = true; 
                }             
            });
        }

        return hasError;
    }

    validateRow(row) {
        let hasError = false; 
        this.collectionData.config.columns.forEach(col => {
            if(col.required) {   
                if(row.cells[col.apiName]) {
                    if(!row.cells[col.apiName].value) {
                        hasError = true;
                        row.cells[col.apiName]["error"] = true;               
                    } else {
                        row.cells[col.apiName]["error"] = false;
                    }
                }  
                
            }
        });
        return hasError;
    }

    handleNewRowClick(event) {
        const tableNumber = event.target.dataset.tableNumber;
        this.addNewRow(tableNumber);
    }

    addNewRow(tableNumber) {
        let rows = this.collectionData.tables[tableNumber-1].rows;
        const rowNumber = rows.length > 0 ? 
            Math.max(...rows.map(r => r.rowNumber)) + 1 : 1;
        const rowIndex = rows.length > 0 ? 
            Math.max(...rows.map(r => r.rowIndex)) + 1 : 1;
        const row = {rowNumber: rowNumber, rowIndex: rowIndex, action: 'INSERT', cells: {}};
        this.collectionData.config.columns.forEach(col => {
            if(col.type === 'formula') {
                row.cells[col.apiName] = {value: rows[0].cells[col.apiName].value};
            } 
            else if('fetchOptionsFromOtherField' in col ){
                if(col.showOnlyOnce && col.fetchOptionsFromOtherField !=null && col.fetchOptionsFromOtherField) {
                    row.cells[col.apiName] = {value: this.collectionData.tables[0].rows[0].cells[col.fetchOptionsOtherFieldName].value}; 
                } 
            }
            else {
                row.cells[col.apiName] = {};
            }            
        });
        this.collectionData.tables[tableNumber - 1].rows.push(row);
    }

    handleCloneTable(event){
        let tableNumber = parseInt(event.target.dataset.tableNumber);
        this.cloneTable(tableNumber);
        if(this.collectionData.config.showSumOfRows){
            this.calculateSum(tableNumber);
        }
    }

    cloneTable(tableNumber) {
        [...this.template.querySelectorAll("c-lwc-owf-generic-collection-tool-row")].forEach((element) => {
            if(element.tableNumber == tableNumber) {
                element.clearSelection();
            }
        });
        let tableToBeCloned = JSON.parse(JSON.stringify(this.collectionData.tables.find(t => t.tableNumber === tableNumber).rows));
        let existingRowsClone = JSON.parse(JSON.stringify(tableToBeCloned));
        tableToBeCloned.forEach(row => {
            this.deleteRow(tableNumber, row, true);
        });
        tableToBeCloned = [];
        tableToBeCloned = JSON.parse(JSON.stringify(this.collectionData.tables.find(t => t.tableNumber === tableNumber).rows));
        let rowNumber = tableToBeCloned.length > 0 ? 
            Math.max(...tableToBeCloned.map(r => r.rowNumber)) + 1 : 1;
        
        let rowIndex = tableToBeCloned.length > 0 ? 
            Math.max(...tableToBeCloned.map(r => r.rowIndex)) + 1 : 1;

        let previousTableRows = JSON.parse(JSON.stringify(this.collectionData.tables.find(t => t.tableNumber === (tableNumber -1)).rows));
        previousTableRows.forEach(row => {
            if(row.action != 'DELETE') {                
                delete row.recordId;
                row.rowNumber = rowNumber;
                rowNumber++;
                this.collectionData.config.columns.forEach(col => {
                    if(col.type === 'formula') {
                        row.cells[col.apiName].value = existingRowsClone[0].cells[col.apiName].value;                
                    }            
                });
                row.action = 'INSERT';
                tableToBeCloned.push(row);
            }
        }); 
        this.collectionData.tables.find(t => t.tableNumber === tableNumber).rows = tableToBeCloned;  
    }
    setCloneButtonVisibility(table) {
        if(this.collectionData.config.enableCloneTable) {
            if(table.tableNumber === 1) {
                table["displayCloneButton"] = false;
            } else {
                table["displayCloneButton"] = true;
            }
        }
    }
    setDefaultValue(table){ 
        this.collectionData.config.columns.forEach((col) => {
           if(col.defaultValue){  
               table.rows.forEach(row=>{
                   if(row.cells[col.apiName].value == null || row.cells[col.apiName].value == ''){
                           row.cells[col.apiName].value = col.defaultValue;
                   }
               })
               }
         })
    }
    handleDeleteAtion(event) {
        const params = event.detail;
        this.deleteRow(params.tableNumber, params.row, false);
    }
    handleClearAction(event){
        const params = event.detail;
        this.clearRow(params.tableNumber, params.row);
    }

    clearRow(tableNumber, row) {
        let table = this.collectionData.tables.find(
            (t) => t.tableNumber === tableNumber
        );
        const rowIndex = table.rows.findIndex((r) => r.rowNumber === row.rowNumber);
        this.collectionData.config.columns.forEach((col) => {
            if (col.type != "formula") {
                table.rows[rowIndex].cells[col.apiName] = {};
            }
        });
        if (
            table.rows[rowIndex].recordId &&
            table.rows[rowIndex].action != "INSERT"
        ) {
            table.rows[rowIndex].action = "UPDATE";
        }
    }
    deleteRow(tableNumber, row, skipValidationOnDelete) {
		let data = JSON.parse(JSON.stringify(this.collectionData.tables));
        let table = data
            .find(t => t.tableNumber === tableNumber);
        if(!skipValidationOnDelete && this.validateOnDelete(table)){
            this.showToast('Error', 'Table '+ table.tableNumber+' must have atleast one row' , 'Error', 'dismissable');
        }
        else{
            const rowIndex = table.rows.findIndex(r => r.rowNumber === row.rowNumber);
            if(rowIndex > -1) {
                if(row.recordId) {
                    table.rows[rowIndex].isDeleted = true; 
                    table.rows[rowIndex].action = 'DELETE';
                } 
                else {
                    table.rows.splice(rowIndex, 1);
                } 
            }
            let rowIndexValue = 1;
            for(let j=0; j<data[tableNumber-1].rows.length; j++) {
                if(!data[tableNumber-1].rows[j].isDeleted) {
                    data[tableNumber-1].rows[j].rowIndex = rowIndexValue++;
                }
                else{
                    data[tableNumber-1].rows[j].rowIndex = 0;
                } 
            } 
        }
        if(this.collectionData.config.showSumOfRows && table){
            this.calculateSum(tableNumber);
           
        }
		this.collectionData.tables = data;
    }

    handleUpdateAction(event) {
        const params = event.detail;
        let table = this.collectionData.tables
            .find(t => t.tableNumber === params.tableNumber);
        const rowIndex = table.rows.findIndex(r => r.rowNumber === params.rowNumber);
        if(rowIndex > -1) {
            let row = table.rows[rowIndex];
            if(params.type === 'value') {
                row.cells[params.column]['value'] = params.value;    
            }
            else {
                row.cells[params.column]['error'] = false;
            }
            if(row.recordId && params.type!=='error' && row.action != 'INSERT') {
                row.action = 'UPDATE';
            }
        }
        if(params.rowNumber == 0){
            if(params.type === 'value') {
                table.fixedRow.cells[params.column]['value'] = params.value;
            }
            else{
                table.fixedRow.cells[params.column]['error'] = false;
            }  
            table.rows.forEach(row => {
                if(params.type === 'value') {
                    row.cells[params.column]['value'] = params.value;    
                }
                else {
                    row.cells[params.column]['error'] = false;
                }
                if(row.recordId && params.type!=='error' && row.action != 'INSERT') {
                       row.action = 'UPDATE';
                 }
            });
        }
        if(this.collectionData.config.showSumOfRows && table){
            this.calculateSum(params.tableNumber);
           
        }
    }
    calculateSum(tableNumber){
        let collection = JSON.parse(JSON.stringify(this.collectionData));
        let table = collection.tables
            .find(t => t.tableNumber === tableNumber);
        
        collection.config.columns.forEach(col => {
            if(!col.showOnlyOnce){
                let count = 0;
                table.rows.forEach(row => {
                    if(row.action != 'DELETE') {
                        let cell = row.cells[col.apiName];
                        if(cell.value){
                            if(isNaN(parseInt(cell.value))){
                                count += 1;
                                return;
                            }
                            else{
                                count += parseInt(cell.value);
                            }
                        }
                    }
                });
                let sum = table.sums.find(s => s.column == col.apiName);
                sum.value = count;
            }
        });

        this.collectionData =collection;
    }

    showToast(title,message,variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    navigateToRecord(){
        this.collectionToolRecForOthers=[];
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.bidHistoryId,
                actionName: 'view'
            }
        }); 
    }

    validateOnDelete(table,skipValidationOnDelete){
        var tableLength = 0;
        table.rows.forEach(row => {
            if(!row.isDeleted){
                tableLength ++;
            }
        });
        return (tableLength === 1 && this.collectionData.config.allowAllRowDeletion != undefined && !this.collectionData.config.allowAllRowDeletion)
    }
    
    get displayActionColumn() {
        return this.collectionData.config.enableClearRow || this.collectionData.config.enableDeleteRow;
    }

    get actionColumnWidth() {
        let w = 0;
        if(this.collectionData.config.enableDeleteRow) w += 50;
        if(this.collectionData.config.enableClearRow) w += 50;
        return "width:" + w + "px";
    }
}
