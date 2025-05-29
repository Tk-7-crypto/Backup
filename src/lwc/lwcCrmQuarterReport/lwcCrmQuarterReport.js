import { LightningElement, api, wire } from 'lwc';
import generateQuarterReport from '@salesforce/apex/CNT_CRM_QuarterPerformance.generateCurrentQuarterReport';

const COLUMNS = [
    { label: 'Stage', fieldName: 'StageName', type: 'text', sortable: true, wrapText: true },
    {
        label: 'Opportunity Owner', fieldName: 'ownerUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'OwnerName' }, target: '_blank' }
    },
    {
        label: 'Inside Sales', fieldName: 'insideSalesUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'insideSalesName' }, target: '_blank' }
    },
    {
        label: 'Account Name', fieldName: 'accountUrl', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'AccountName' }, target: '_blank' }
    },
    {
        label: 'Opportunity Name', fieldName: 'recordURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Amount', fieldName: 'Amount', type: 'currency', 
        typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: "code", step: '0.001'}, sortable: true
    },
    { label: 'Inside Sales Transfer Date', fieldName: 'Inside_Sales_Transfer_Date__c', type: 'date-local', sortable: true },
    { label: 'Expected Close Date', fieldName: 'CloseDate', type: 'date-local', sortable: true },
    { label: 'Advance Plan / Next Steps', fieldName: 'Advanced_Plan__c', type: 'text', sortable: true, wrapText: true }

];

export default class LwcCrmQuarterReport extends LightningElement {
    columns = COLUMNS;
    Opportunities;
    @api reportName;
    filteredOppty;
    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;
    error;
    sortedBy;
    sortDirection = 'asc';
    errorMsg = 'Unexpected error !!!';
    showSpinner = false;
    reportTitle = 'This Quarter Report';

    connectedCallback() {
        this.setReportTitle();
    }

    @wire(generateQuarterReport, { reportName: '$reportName' })
    wireTasks({ data, error }) {
        this.showSpinner = true;
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
            this.Opportunities = tempData;
            if (this.Opportunities.length > 0) {
                this.Opportunities.forEach(function (oppty) {
                    try {
                        oppty['recordURL'] = '/' + oppty.Id;
                        oppty['OwnerName'] = oppty.hasOwnProperty('Owner') == true ? oppty.Owner.Full_User_Name__c : '';
                        oppty['AccountName'] = oppty.hasOwnProperty('Account') == true ? oppty.Account.Name : '';
                        oppty['insideSalesName'] = oppty.hasOwnProperty('Inside_Sales__c') == true ? oppty.Inside_Sales__r.Full_User_Name__c : '';
                        oppty['accountUrl'] = '/' + oppty.AccountId;
                        oppty['ownerUrl'] = '/' + oppty.OwnerId;
                        oppty['insideSalesUrl'] = '/' + oppty.Inside_Sales__c;
                    } catch (e) {
                        console.log('wireTasks', e);
                    }
                });
                this.filteredOppty = JSON.parse(JSON.stringify(this.Opportunities));
            }
        } else if (error) {
            this.handleError(error);
        }
        this.showSpinner = false;
    }

    handleError(error) {
        this.showSpinner = false;
        var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
        this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
        this.error = true;
        this.Opportunities = [];
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        const cloneData = [...this.filteredOppty];
        cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
        this.filteredOppty = cloneData;
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
        return (this.filteredOppty == undefined || this.filteredOppty.length === 0);
    }

    setReportTitle() {
        if (this.reportName == 'ISOpsCommit') {
            this.reportTitle = 'GIS Opps- Commit';
        } else if (this.reportName == 'ISOpsCall') {
            this.reportTitle = 'GIS Opps- Call';
        } else if (this.reportName == 'ISOpsBest') {
            this.reportTitle = 'GIS Opps- Best';
        } else {
            this.errorMsg = 'Report Name Mentioned is incorrect!!!';
            this.error = true;
        }
    }
}