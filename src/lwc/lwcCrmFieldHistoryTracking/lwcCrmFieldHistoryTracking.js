import { LightningElement, track, wire, api } from 'lwc';
import getFieldHistoryRecords from '@salesforce/apex/CNT_CRM_FieldsHistory.getFieldHistoryRecords';
import getObjectName from '@salesforce/apex/CNT_CRM_FieldsHistory.getObjectName';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import TIMEZONE from '@salesforce/i18n/timeZone';
const columns = [
    {
        label: 'Date', fieldName: 'createdDate', sortable: "true", type: 'date',
        typeAttributes: { year: "numeric", month: "numeric", day: "2-digit", hour: "2-digit", minute: "2-digit", hour12: true }
    },
    { label: 'Field', fieldName: 'field', sortable: "true" },
    {
        label: 'User', fieldName: 'createdByName', type: 'url', sortable: "true",
        typeAttributes: { label: { fieldName: 'actionUserName' }, target: '_blank' }
    },
    { label: 'Original Value', fieldName: 'oldValue', sortable: "true", wrapText: true },
    { label: 'New Value', fieldName: 'newValue', sortable: "true", wrapText: true },
]

export default class Sorting extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api fieldsList;
    fieldHistoryRecords = [];
    column;
    sortedBy;
    sortedDirection = 'DESC';
    cardLabel = 'Field History(0)';
    objectLabel = '';
    showSpinner = false;
    isViewShow = true;
    showLimitedRecords = 6;
    error = false;
    errorMsg = 'Unexpected error !!!';
    userTimeZone = TIMEZONE;

    @wire(CurrentPageReference) currentPageReference;

    @wire(getObjectName, { recordId: '$recordId' })
    objectInfoData({ data, error }) {
        if (data) {
            this.objectLabel = data;
        }
    }

    connectedCallback() {
        this.showSpinner = true;
        this.recIdFromState();
        this.getFieldHistoryRecords();
    }

    recIdFromState() {
        if (this.currentPageReference && this.currentPageReference.state && this.currentPageReference.state.c__RecordId) {
            this.recordId = this.currentPageReference.state.c__RecordId;
            this.showLimitedRecords = null;
            this.isViewShow = false;
            this.getFieldHistoryRecords();
        }
    }

    getFieldHistoryRecords() {
        this.showSpinner = true;
        getFieldHistoryRecords({ recordId: this.recordId })
            .then(result => {
                let results = [];
                this.error = false;
                results = JSON.parse(JSON.stringify(result));
                results.forEach(res => {
                    res.createdByName = res.createdByName;
                    res.actionUserName = res.createdByName;
                    if (res.datatype === 'TimeOnly') {
                        if (res.oldValue) {
                            res.oldValue = new Date('1970-01-01T' + res.oldValue)
                                .toLocaleTimeString('en-US',
                                    { timeZone: 'UTC', hour12: true, hour: 'numeric', minute: 'numeric', second: 'numeric' });
                        }
                        if (res.newValue) {
                            res.newValue = new Date('1970-01-01T' + res.newValue)
                                .toLocaleTimeString('en-US',
                                    { timeZone: 'UTC', hour12: true, hour: 'numeric', minute: 'numeric', second: 'numeric' });
                        }
                        if (res.oldValue === "") {
                            return "";
                        }
                        if (res.newValue == '') {
                            res.newValue = new Date(0);
                        }
                    }

                    /*if(res.Type__c === 'Checkbox'){
                       // console.log('OUTPUT true: ',res.oldValue);
                    //  res.oldValue =  res.oldValue ? res.type = 'Boolean': null;
                     // res.oldValue = res.oldValue ? '<lightning-primitive-custom-cell><lst-any-type><lightning-input data-navigation="enable" variant="label-hidden" disabled="" tabindex="0" class="slds-form-element" lwc-66unc5l95ad-host=""><lightning-primitive-input-checkbox lwc-66unc5l95ad="" disabled=""><div class="slds-form-element__control slds-grow"><span class="slds-checkbox" part="input-checkbox"><input type="checkbox" part="checkbox" id="checkbox-406" name="OldValue" disabled="" value=""><label class="slds-checkbox__label" for="checkbox-406" part="label-container"><span part="indicator" class="slds-checkbox_faux"></span><span class="slds-form-element__label slds-assistive-text" part="label">Original Value</span></label></span></div></lightning-primitive-input-checkbox></lightning-input></lst-any-type></lightning-primitive-custom-cell>' : '<lightning-primitive-custom-cell><lst-any-type><lightning-input data-navigation="enable" variant="label-hidden" disabled="" tabindex="0" class="slds-form-element" lwc-66unc5l95ad-host=""><lightning-primitive-input-checkbox lwc-66unc5l95ad="" disabled=""><div class="slds-form-element__control slds-grow"><span class="slds-checkbox" part="input-checkbox"><input type="checkbox" part="checkbox" id="checkbox-406" name="OldValue" disabled="" value=""><label class="slds-checkbox__label" for="checkbox-406" part="label-container"><span part="indicator" class="slds-checkbox_faux"></span><span class="slds-form-element__label slds-assistive-text" part="label">Original Value</span></label></span></div></lightning-primitive-input-checkbox></lightning-input></lst-any-type></lightning-primitive-custom-cell>';
                      //res.newValue = res.newValue ? '<input type="checkbox" disabled checked/>' : '<input type="checkbox" disabled/>';  
                    }*/

                });
                this.fieldHistoryRecords = results;
                this.sortData('createdDate', 'DESC');

                let numberOfRecord = '';
                if (this.showLimitedRecords != null) {
                    numberOfRecord = (results.length > this.showLimitedRecords) ? (this.showLimitedRecords + '+') : this.showLimitedRecords;
                    this.fieldHistoryRecords = this.fieldHistoryRecords.slice(0, this.showLimitedRecords);
                } else {
                    numberOfRecord = this.fieldHistoryRecords.length;
                }
                this.cardLabel = this.objectLabel + ' Field History (' + numberOfRecord + ')'

                this.column = columns;
                this.column.forEach((res) => {
                    if (res.fieldName === 'createdDate') {
                        res.typeAttributes.timeZone = this.userTimeZone;
                    }
                })

            }).catch(error => {
                console.log('gfhr.error : ', error);
                this.error = true;
                var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
            }).finally(() => {
                this.showSpinner = false;
            });
    }

    @wire(getRecord, { recordId: '$recordId', fields: [{ "fieldApiName": "LastModifiedDate", "objectApiName": "" }] })
    getCurrentRecord({ data, error }) {
        if (data) {
            this.showSpinner = true;
            this.getFieldHistoryRecords();
            this.error = false;
        } else if (error) {
            console.log('gcr.error : ', error);
        }
    }

    onSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortedBy, this.sortedDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.fieldHistoryRecords));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === "asc" ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : "";
            y = keyValue(y) ? keyValue(y) : "";
            return isReverse * ((x > y) - (y > x));
        });
        this.fieldHistoryRecords = parseData;
    }

    viewAll() {
        window.open('/lightning/n/Field_History?c__RecordId=' + this.recordId, '_self');
    }

    get noRecordToDisplay() {
        return (this.fieldHistoryRecords == undefined || this.fieldHistoryRecords.length === 0);
    }

    get datatableClass() {
        return ((this.isViewShow == true && this.noRecordToDisplay == false) ? 'datatable-small-height' : 'datatable-large-height');
    }
}