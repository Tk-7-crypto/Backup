import { LightningElement, api } from 'lwc';
import getMetadata from '@salesforce/apex/CNT_CRM_List_View.getMetadata';

export default class LwcCrmListView extends LightningElement {

    @api filteredRecord = [];
    @api columns;
    @api getAllDataFromParent = false;
    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;
    showSpinner = true;
    error = false;
    errorMsg = 'Unexpected error !!!';

    @api objectApiName;
    @api fields;
    @api conditions = 'Id !=null';
    @api heading = 'My Records';
    iconName = 'standard:task';

    connectedCallback() {
        if (this.getAllDataFromParent) {
            this.showSpinner = false;
            this.error = false;
        } else {
            getMetadata({ objectApiName: this.objectApiName, fields: this.fields, conditions: this.conditions })
                .then(result => {
                    if (result != null) {
                        this.iconName = 'standard:' + this.objectApiName.toLowerCase();
                        if (result.showNameWithUrl) {
                            var tempData = JSON.parse(JSON.stringify(result.records)); // as cached object is not modifiable, create new object
                            tempData.forEach(function (record) {
                                record['recordURL'] = '/' + record.Id;
                            });
                            this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                        } else {
                            this.filteredRecord = result.records;
                        }
                        this.columns = JSON.parse(result.coloumnsJSON);
                        this.showSpinner = false;
                        this.error = false;
                    }
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.error = true;
                    var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                    this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                    this.showSpinner = false;
                });
        }
    }

    renderedCallback() {
        if (this.filteredRecord == undefined || this.filteredRecord.length === 0) {
            if (this.template.querySelector('.zeroRecord')) {
                this.template.querySelector('.zeroRecord').classList.add('zeroRecordCSS');
            }
            if (this.template.querySelector('.dataTable')) {
                this.template.querySelector('.dataTable').classList.remove('dataTableCSS');
            }
        } else {
            if (this.template.querySelector('.zeroRecord')) {
                this.template.querySelector('.zeroRecord').classList.remove('zeroRecordCSS');
            }
            if (this.template.querySelector('.dataTable')) {
                this.template.querySelector('.dataTable').classList.add('dataTableCSS');
            }
        }
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        const cloneData = [...this.filteredRecord];
        cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
        this.filteredRecord = cloneData;

    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    get noRecordToDisplay() {
        return (this.filteredRecord == undefined || this.filteredRecord.length === 0);
    }

}