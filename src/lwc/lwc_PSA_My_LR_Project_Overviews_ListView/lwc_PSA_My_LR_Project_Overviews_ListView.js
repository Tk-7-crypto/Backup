import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyLRProjectOverviews from '@salesforce/apex/CNT_PSA_My_LR_Project_Overviews_ListView.getMyLRProjectOverviews';

// row actions
const actions = [
    { label: 'Edit', name: 'edit' }
];

const RECORDS_LIMIT_PER_PAGE = 5;

const COLUMNS = [
    { label: 'ID', fieldName: 'lrRecordUrl', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'name' } } },
    { label: 'Status', fieldName: 'status', sortable: true, type: 'text' },
    { label: 'Countries', fieldName: 'countries', sortable: true, type: 'text' },
    { label: 'Product', fieldName: 'productUrl', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'productName' } } },
    { label: 'Project', fieldName: 'projectUrl', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'projectName' } } },
    { label: 'Client', fieldName: 'accountUrl', sortable: true, type: 'url', typeAttributes: { label: { fieldName: 'accountName' } } },
    { label: 'LR Type', fieldName: 'lrType', sortable: true, type: 'text' },
    { label: 'LR Review Period Frequency', fieldName: 'lrReviewPeriodFrequency', sortable: true, type: 'text' },
    { label: 'LR Review Period Start Date', fieldName: 'lrReviewPeriodStartDate', sortable: true, type: 'date' },
    { label: 'LR Review Period Stop Date', fieldName: 'lrReviewPeriodStopDate', sortable: true, type: 'date' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

export default class Lwc_PSA_My_LR_Project_Overviews_ListView extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    @track defaultSortDirection = 'ASC';
    @track sortDirection = 'ASC';
    @track sortedBy;
    @track error = false;
    @track errorMsg = 'Unexpected Error !';
    @track filteredRecord = [];

    @track isLoaded = false;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track pageSize = RECORDS_LIMIT_PER_PAGE;
    @track isPrev = true;
    @track isNext = true;
    @track noItemsToDisplay = false;

    //used to hide pagination section
    @track totalRecordsLessOrEqualsRecordsPerPageLimit = true;

    connectedCallback() {
        this.loadData();
    }

    loadData() {
        getMyLRProjectOverviews({
            pageSize: this.pageSize,
            pageNumber: this.pageNumber,
            totalRecords: this.totalRecords,
            toCheckForLoggedInUser: true
        }).then(result => {
            if (result) {
                var resultData = JSON.parse(result);
                this.filteredRecord = resultData.lrRecords;
                this.recordEnd = resultData.recordEnd;
                this.totalRecords = resultData.totalRecords;
                this.recordStart = resultData.recordStart;
                this.pageNumber = resultData.pageNumber;
                this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
                if (this.totalRecords === 0 || resultData.lrRecords === null || resultData.totalRecords === null) {
                    this.noItemsToDisplay = true;
                } else {
                    this.noItemsToDisplay = false;
                }
                if (this.totalRecords <= RECORDS_LIMIT_PER_PAGE) {
                    this.totalRecordsLessOrEqualsRecordsPerPageLimit = true;
                } else {
                    this.totalRecordsLessOrEqualsRecordsPerPageLimit = false;
                }
                this.isLoaded = true;
            }
        }).catch(error => {
            this.error = true;
            let err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
            let errorMsgForLog = err == "{}" ? 'Unexpected Error !' : err;
            console.error(errorMsgForLog);
            this.errorMsg = 'You do not have permission to view/edit LR Project Overview Records.'
            this.isLoaded = true;
        });
    }

    handlePageNextAction() {
        this.isLoaded = false;
        this.pageNumber = this.pageNumber + 1;
        this.loadData();
    }
    handlePagePrevAction() {
        this.isLoaded = false;
        this.pageNumber = this.pageNumber - 1;
        this.loadData();
    }

    handleNewClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'LR_Project_Overview__c',
                actionName: 'new'
            }
        });
    }

    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
        }

    }

    editCurrentRecord(currentRow) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: currentRow.id,
                objectApiName: 'LR_Project_Overview__c',
                actionName: 'edit'
            }
        });
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
}
