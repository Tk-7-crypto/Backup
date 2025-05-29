import { LightningElement, wire } from 'lwc';
import getUserBadgeList from '@salesforce/apex/CNT_CRM_UserBadgeList.getUserBadgeList';
import setMetaData from '@salesforce/apex/CNT_CRM_UserBadgeList.setMetaData';
import getMetaData from '@salesforce/apex/CNT_CRM_UserBadgeList.getMetaData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcCrmUserBadgeList extends LightningElement {
    data = [];
    columns = ['Badge', 'Status', 'Assigned on Date', 'Due Date', 'Finished Date', 'URL'];
    isEdit = false;
    showSpinner = false;
    statusSelectedValue = [];
    orderBy = 'trailheadapp__Assigned_Date__c';
    sortDirection = 'ASC';
    profile = '';

    connectedCallback() {
        this.showSpinner = true;
        getMetaData()
            .then(result => {
                if (result != undefined && result != null && result != '') {
                    this.statusSelectedValue = result.status;
                    this.profile = result.profile;
                    if (result.profile === 'RWS User')
                        this.columns = ['Badge', 'Status', 'Assigned on Date', 'Due Date', 'URL'];
                    this.getUserBadgeList();
                }
            })
            .catch(error => {
                console.log('get:' + JSON.stringify(error));
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
            });
    }

    getUserBadgeList() {
        getUserBadgeList({})
            .then(result => {
                var records = result;
                records.forEach(element => {
                    element.budgetName = element.trailheadapp__Badge__r.Name;
                });
                this.data = records;
                this.orderBy = 'trailheadapp__Assigned_Date__c';
                this.sortDirection = 'ASC'
                // add arrow icon to assigned header label default
                let buttonList = this.template.querySelectorAll(".headerButton");
                if (buttonList.length > 2)
                    buttonList[2].label = buttonList[2].value + ' ↑';
                this.showSpinner = false;
            })
            .catch(error => {
                console.log('userBadgeList:' + JSON.stringify(error));
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error',
                    }),
                );
            });
    }

    // Filter Changes
    enbleEdit(event) {
        this.isEdit = true;
    }

    // Filter Cancel
    handleCancel(event) {
        this.isEdit = false;
    }

    // Filter Save
    handleSave(event) {
        this.showSpinner = true;
        var statusSet = this.template.querySelector('[data-id="status"]').value;
        setMetaData({ statusSet: JSON.stringify(statusSet) })
            .then(result => {
                this.statusSelectedValue = statusSet;
                this.isEdit = false;
                this.getUserBadgeList();
            })
            .catch(error => {
                console.log('set :' + JSON.stringify(error));
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!',
                        message: error,
                        variant: 'error',
                    }),
                );
            });
    }

    get optionStatus() {
        return [
            { label: 'Assigned', value: 'Assigned' },
            { label: 'In-Progress', value: 'In-Progress' },
            { label: 'Completed', value: 'Completed' },
        ];
    }

    get isDataLengthZero() {
        return this.data.length === 0;
    }

    get isNotRWSUser() {
        return !(this.profile === 'RWS User');
    }

    updateColumnSorting(event) {
        this.showSpinner = true;
        // remove arrow icon from all header value
        let buttonList = this.template.querySelectorAll(".headerButton");
        buttonList.forEach(element => {
            element.label = element.value;
        });

        var colselected = event.target.dataset.id;
        if (this.sortDirection === 'DESC')
            this.sortDirection = 'ASC';
        else
            this.sortDirection = 'DESC';

        if (colselected === 'Badge') {
            this.orderBy = 'budgetName';
        }
        else if (colselected === 'Status') {
            this.orderBy = 'trailheadapp__Status__c';
        }
        else if (colselected === 'Assigned on Date') {
            this.orderBy = 'trailheadapp__Assigned_Date__c';
        }
        else if (colselected === 'Due Date') {
            this.orderBy = 'trailheadapp__Due_Date__c';
        }
        else if (colselected === 'Finished Date') {
            this.orderBy = 'trailheadapp__Finished_Date__c';
        }
        else if (colselected === 'URL') {
            this.orderBy = 'trailheadapp__URL__c';
        }
        let reverse = this.sortDirection !== 'ASC';
        let data_clone = JSON.parse(JSON.stringify(this.data));
        this.data = data_clone.sort(this.sortBy(this.orderBy, reverse));

        // add arrow icon to header label
        var label = event.target.value;
        var arrow = (this.sortDirection === 'ASC' ? '↑' : '↓');
        event.target.label = label + ' ' + arrow;
        this.showSpinner = false;
    }

    sortBy(field, reverse, primer) {
        var key = function (x) { return primer ? primer(x[field]) : x[field] };
        return function (a, b) {
            var A = key(a), B = key(b);

            if (A === undefined) A = '';
            if (B === undefined) B = '';

            return (A < B ? -1 : (A > B ? 1 : 0)) * [1, -1][+!!reverse];
        }
    }

}