import { LightningElement, api } from 'lwc';
export default class LwcOwfGenericCollectionToolCell extends LightningElement {
    @api column;
    @api row;
    @api tableNumber;

    get isPickList() {
        if(this.column.options){
        return this.column.type === 'picklist';
    }
}
    get isLookup(){
        return this.column.options && this.column.type === 'picklist-lookup';
    }
    get isDate() {
        return this.column.type === 'date';
    }
    get isTextBox() {
        return this.column.type === 'textbox';
    }
    get isTextArea() {
        return this.column.type === 'textarea';
    }
    get isRecordPicker() {
        return this.column.type === 'record-picker';
    }

    get cellValue() {
        return this.row.cells[this.column.apiName] ? this.row.cells[this.column.apiName].value : '';
    }

    get isFormula() {
        return this.column.type === 'formula';
    }
    get filter(){
        const filter = {};
        filter.criteria = this.column.recordPicker.criteria;
        return filter;
    }
    get isNumber() {
        return this.column.type === 'number';
    }
    get isPercentage() {
        return this.column.type === 'percentage';
    }

    get isMultiSelectPicklist(){
        return this.column.multiSelect;
    }

    get errorClass() {
        let hasError = this.row.cells[this.column.apiName] ? this.row.cells[this.column.apiName].error : false;
        return hasError ? 'slds-has-error' : '';
    }
    get maxSelectedValue()
    {
        return this.column.maxSelectedValue;
    }
    get validateSelectedValue()
    {
        return this.column.validateSelectedValue;
    }
    handleChange(event) {
        let colValue;
        if(event.detail.values != undefined && event.detail.values !=''){
             colValue = (event.detail.values).toString().replaceAll(",", ";");
        }
        else if(event.detail.value != undefined && event.detail.value !=''){
             colValue = event.detail.value;
        }
        else if(this.isRecordPicker) {
            colValue = event.detail.recordId;
        }
        else{
             colValue = event.target.value;
        }
        const updateEvent = new CustomEvent("updateaction", {detail : {
            value: colValue, 
            tableNumber: this.tableNumber,
            rowNumber: this.row.rowNumber,
            column: this.column.apiName,
            type: 'value'
        }});
        this.dispatchEvent(updateEvent);
    }

    handleBlur(event) {
        const colValue = event.target.value;
        const updateEvent = new CustomEvent("updateaction", {detail : {
            value: colValue, 
            tableNumber: this.tableNumber,
            rowNumber: this.row.rowNumber,
            column: this.column.apiName,
            type: 'error'
        }});
        this.dispatchEvent(updateEvent);
    }

    @api
    checkValidity() {
        let isValidated = false;
        isValidated = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        
        return isValidated;
    }
    @api
    clearRecordPickerData() {
        this.template.querySelector('lightning-record-picker').clearSelection();
        this.template.querySelector('lightning-record-picker').value =this.row.cells[this.column.apiName] ? this.row.cells[this.column.apiName].value : '';
    }
}
