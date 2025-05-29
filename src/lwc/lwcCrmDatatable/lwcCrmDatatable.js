import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcCrmDatatable extends NavigationMixin(LightningElement) {

    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;
    dtSelectedRow;
    dtSelectedRecordVisible = false;
    selectedIdList = [];

    @api showLoadingSpinner = false;
    @api searchedData;
    @api columns;

    //To Pass saveevent with selectedRecordIds to parent component via event to process record
    processSelectedRecord() {
        try {
            this.showLoadingSpinner = true;
            //var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
            if (this.dtSelectedRow.length > 0) {
                let ids = '';
                this.dtSelectedRow.forEach(currentItem => {
                    ids = ids + ',' + currentItem.Id;
                });
                this.selectedIds = ids.replace(/^,/, '');
                // save records
                const selectedEvent = new CustomEvent("saveevent", {
                    detail: { selectedRecordIds: this.selectedIds }
                });
                this.dispatchEvent(selectedEvent);
            } else {
                this.showLoadingSpinner = false;
            }
        } catch (e) {
            this.showLoadingSpinner = false;
            this.dispatchErrorMessage(e, 'Error');
        }
    }

    // To Pass cancelevent to Parent Component via event for cancellation
    cancelClick() {
        this.showLoadingSpinner = true;
        const selectedEvent = new CustomEvent("cancelevent", {
            detail: {}
        });
        this.dispatchEvent(selectedEvent);
    }

    // To Set dtSelectedRow
    handleRowSelection(event) {
        var selectedRows = event.detail.selectedRows;
        if (this.dtSelectedRow === undefined || this.dtSelectedRow === null) {
            this.dtSelectedRow = selectedRows;
        }


        if (event.detail.config.action == 'rowDeselect') {
            //remove Deselect row from this.dtSelectedRow
            if (this.dtSelectedRow.length > 0) {
                this.dtSelectedRow.splice(this.dtSelectedRow.findIndex(row => row.Id === event.detail.config.value), 1);
                this.dtSelectedRow = [...this.dtSelectedRow];
            }
        } else if (event.detail.config.action == 'rowSelect') {
            //add Select row from this.dtSelectedRow
            var foundElement = this.dtSelectedRow.find(ele => ele.Id == event.detail.config.value);
            if (foundElement === undefined || foundElement === null) {
                var eleRow = selectedRows.find(ele => ele.Id == event.detail.config.value);
                if (eleRow !== undefined && eleRow !== null) {
                    this.dtSelectedRow = [...this.dtSelectedRow, eleRow];
                }
            }
        } else if (event.detail.config.action == 'selectAllRows') {
            //remove AllSelect row from this.dtSelectedRow
            let selectedRecords = event.detail.selectedRows;
            selectedRecords.forEach(selectedRecord => {
                var foundElement = this.dtSelectedRow.find(ele => ele.Id == selectedRecord.Id);
                if (foundElement === undefined || foundElement === null) {
                    var eleRow = selectedRows.find(ele => ele.Id == selectedRecord.Id);
                    if (eleRow !== undefined && eleRow !== null) {
                        this.dtSelectedRow = [...this.dtSelectedRow, eleRow];
                    }
                }
            });
        } else if (event.detail.config.action == 'deselectAllRows') {
            this.dtSelectedRow = selectedRows;
        }
    }

    //To Show Only Selected Rows
    showSelectedRecordList() {
        this.refreshDatatableUI();
        this.dtSelectedRecordVisible = true;
    }

    // To show Search Result
    @api showSearchRecordList() {
        this.refreshDatatableUI();
        this.dtSelectedRecordVisible = false;
    }

    //Set Selected rows
    refreshDatatableUI() {
        // select the saved record to re-load form (in another thread for ui refersh)
        setTimeout(() => {
            // deselect all rows (in current thread for ui refresh)
            this.selectedIdList = [];
            if (this.dtSelectedRow != undefined && this.dtSelectedRow != null && this.dtSelectedRow.length > 0)
                this.selectedIdList = this.dtSelectedRow.map(currentItem => currentItem.Id);
        }, 1
        );
    }

    onHandleSort(event) {
        this.showLoadingSpinner = true;
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        if (this.dtSelectedRecordVisible == true) {
            const cloneData = [...this.dtSelectedRow];
            cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
            this.dtSelectedRow = cloneData;
        } else {
            const cloneData = [...this.searchedData];
            cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
            this.searchedData = cloneData;
        }
        this.showLoadingSpinner = false;
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

    dispatchErrorMessage(error, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title + (error.body ? error.body.errorCode : ''),
                message: (error.body ? error.body.message : 'Something Went Wrong!!!'),
                variant: 'error',
                mode: 'pester'
            })
        );
    }

    get disableSaveButton() {
        return !(this.dtSelectedRow && this.dtSelectedRow.length);
    }

    get showSelectedRowCount() {
        if (this.dtSelectedRow != null) {
            return 'Show Selected (' + this.dtSelectedRow.length + ')';
        } else {
            return 'Show Selected (0)';
        }
    }

    get selectedRowsHasData() {
        return (this.dtSelectedRow != undefined && this.dtSelectedRow != null && this.dtSelectedRow != '' && this.dtSelectedRow.length > 0);
    }

    get queriedRowsHasData() {
        return (this.searchedData != undefined && this.searchedData != null && this.searchedData != '' && this.searchedData.length > 0);

    }
}