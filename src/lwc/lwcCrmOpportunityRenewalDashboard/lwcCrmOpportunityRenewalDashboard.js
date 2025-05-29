import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import CloneOptionPopup from "c/lwcCrmOpportunityRenewalCloneOption";
import deactiveRenewalTask from '@salesforce/apex/CNT_CRM_OpportunityRenewalDashboard.deactiveRenewalTask';
import reassignRenewalTask from '@salesforce/apex/CNT_CRM_OpportunityRenewalDashboard.reassignRenewalTask';
import generateRenewalTaskJson from '@salesforce/apex/CNT_CRM_OpportunityRenewalDashboard.generateRenewalTaskJson';
import searchRenwalTasks from '@salesforce/apex/CNT_CRM_OpportunityRenewalDashboard.searchRenwalTasks';
import findUsersBySearchKey from '@salesforce/apex/CNT_CRM_OpportunityRenewalDashboard.findUsersBySearchKey';

const PARENT_COLUMNS = [
    {
        label: "Products", type: 'button', fixedWidth: 80, typeAttributes: {
            variant: 'brand',
            label: '+',
            name: 'showInnerGridRecords'
        }
    },
    {
        label: 'Opportunity#', fieldName: 'oppURL', type: 'url', initialWidth: 140, sortable: true,
        typeAttributes: { tooltip: { fieldName: 'hoverOpp' }, label: { fieldName: 'oppNum', type: 'text' }, target: '_blank' }
    },
    {
        label: 'Cloning Status', fieldName: 'click', type: 'button', fixedWidth: 180, typeAttributes: {
            label: { fieldName: 'actionButtonLabel' },
            name: 'cloneActionButton',
            disabled: { fieldName: 'actionButton_disabled' }
        },
        cellAttributes: { iconName: { fieldName: 'actionButtonIcon' } }
    },
    {
        label: 'Account Name', fieldName: 'accURL', type: 'url', initialWidth: 140, sortable: true,
        typeAttributes: { label: { fieldName: 'accName', type: 'text' }, target: '_blank' }
    },
    {
        label: 'Contract Value', fieldName: 'contractValue', type: 'currency', initialWidth: 140, sortable: true,
        typeAttributes: { currencyCode: { fieldName: 'currencyCode' }, currencyDisplayAs: "code", step: '0.001' }
    },
    {
        label: 'Contract End Date', fieldName: 'contractEndDate', type: 'date', initialWidth: 160, sortable: true,
        typeAttributes: { month: "2-digit", day: "2-digit", year: "numeric" }
    },
    { label: 'Contract Type', fieldName: 'contractType', type: 'text', initialWidth: 140, sortable: true },
    //{ label: 'No Renew Comment', fieldName: 'noRenewComment', type: 'text', initialWidth: 180 },
    { label: 'Clone Type', fieldName: 'cloneType', type: 'text', initialWidth: 120 },
    {
        label: 'Original/Prior Opp', fieldName: 'orgPriOppURL', type: 'url', initialWidth: 160, sortable: true,
        typeAttributes: { label: { fieldName: 'org_pri_opp', type: 'text' }, target: '_blank' }
    },
    {
        label: 'Expected Close Date', fieldName: 'closeDate', type: 'date', initialWidth: 180, sortable: true,
        typeAttributes: { month: "2-digit", day: "2-digit", year: "numeric" }
    },
    { label: 'Data Period Shift', fieldName: 'dataPeriodShift', type: 'text', initialWidth: 150 },
    {
        label: 'Price Increment', fieldName: 'price_inc', type: 'percent', initialWidth: 140,
        typeAttributes: { step: '0.01', minimumFractionDigits: 2 },
    },
    { label: 'Round Up', fieldName: 'roundup_action', type: 'boolean', initialWidth: 80, cellAttributes: { alignment: 'center' } },
    {
        label: 'Cloned Opportunity', fieldName: 'cloneOppUrl', type: 'url', initialWidth: 180, sortable: true,
        typeAttributes: { tooltip: { fieldName: 'hoverClonedOpp' }, label: { fieldName: 'clonned_opportunity_num', type: 'text' }, target: '_blank' },
    }
];

const CHILD_COLUMNS = [
    { label: 'SAP Code', fieldName: 'sapCode', type: 'text', initialWidth: 120 },
    { label: 'Product Name', fieldName: 'productName', type: 'text', initialWidth: 140 },
    { label: 'Business Type', fieldName: 'businessType', type: 'text', initialWidth: 140 },
    {
        label: 'Data Period Start', fieldName: 'dataPeriodStart', type: 'date', initialWidth: 150,
        typeAttributes: { month: "2-digit", day: "2-digit", year: "numeric" }
    },
    {
        label: 'Data Period End', fieldName: 'dataPeriodEnd', type: 'date', initialWidth: 140,
        typeAttributes: { month: "2-digit", day: "2-digit", year: "numeric" }
    },
    { label: 'Sale Type', fieldName: 'saleType', type: 'text', initialWidth: 120 },
    { label: 'Revenue Type', fieldName: 'revenueType', type: 'text', initialWidth: 140 },
    { label: 'Delivery Country', fieldName: 'delivery_cnty', type: 'text', initialWidth: 150 },
    { label: 'Total Price', fieldName: 'totalPrice', type: 'text', initialWidth: 120 },
    { label: 'Status', fieldName: 'status', type: 'text', initialWidth: 80 },
    { label: 'Comments', fieldName: 'comment', type: 'text', initialWidth: 120 }
];
export default class LwcCrmOpportunityRenewalDashboard extends LightningElement {

    outerColumns = PARENT_COLUMNS;
    innerColumns = CHILD_COLUMNS;
    showSpinner = true;
    showSearchOptions = false;
    allData = [];

    // pagination Variable
    renewalTaskWrapperList = [];
    currentPageNumber = 1;
    pageSize = 10;
    startIndex = 0;
    endIndex = 0;

    //popup variables
    popupHeader = '';
    showTaskDetailOnPopup = false;
    renewalTaskDetailWrapperList = [];
    selectedRecordsNew = [];
    showReassignOnPopup = false;

    //Sorting variable
    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;

    connectedCallback() {
        this.refreshData();
        document.addEventListener("keydown", this.handleEscapeKey.bind(this));
    }


    refreshData() {
        this.showSpinner = true;
        let additionalFilter = ' ';
        generateRenewalTaskJson({ additionalFilter: additionalFilter })
            .then(result => {
                if (result) {
                    this.genrateRenewalTaskWrapperList(result);
                }
            }).catch(error => {
                this.handleError(error, 'refreshData');
            }).finally(() => {
                this.showSpinner = false;
            });
    }

    genrateRenewalTaskWrapperList(result) {
        var tempData = JSON.parse(JSON.stringify(result));
        if (tempData.length > 0) {
            tempData.forEach(function (record) {
                //record['contractValue'] = (record.currencyCode ? record.currencyCode : '') + ' ' + (record.contractValue ? record.contractValue : '0.00');
                record['oppURL'] = (record.oppId && record.oppNum) ? '/' + record.oppId : '';
                record['accURL'] = (record.acc_Id && record.accName) ? '/' + record.acc_Id : '';
                record['orgPriOppURL'] = (record.org_pri_opp_id && record.org_pri_opp) ? '/' + record.org_pri_opp_id : '';
                record['cloneOppUrl'] = (record.clonned_opportunity_id && record.clonned_opportunity_num) ? '/' + record.clonned_opportunity_id : '';
                record['cloneType'] = (record.cloning_action == '2') ? 'Basic Clone' : (record.cloning_action == '3') ? 'Detail Clone' : '';
                record['hideCheckBox'] = (record.cloning_status == "queued" || record.cloning_status == "cloned" || record.cloning_status == "Awaiting Details" || record.cloning_status == "No Renew" || record.cloning_status == "errored" || record.cloning_status == "Needs No Renew Reason") ? true : false;
                record['hoverOpp'] = (record.oppNum && record.oppName && record.name) ? ('Opp Name: ' + record.clonned_opportunity + '\n Task Name: ' + record.name) : '';
                record['hoverClonedOpp'] = (record.clonned_opportunity) ? record.clonned_opportunity : '';
                if (record['cloning_status'] === 'Awaiting Details') {
                    record['actionButtonIcon'] = 'utility:edit';
                    record['actionButtonLabel'] = 'Awaiting Details';
                    record['actionButton_disabled'] = false;
                } else if (record['cloning_status'] == '') {
                    record['actionButtonIcon'] = 'utility:settings';
                    record['actionButtonLabel'] = 'Cloning Options';
                    record['actionButton_disabled'] = false;
                } else {
                    if (record['cloning_status'] == 'cloned') {
                        record['actionButtonIcon'] = 'utility:lock';
                    } else if (record['cloning_status'] == 'queued') {
                        record['actionButtonIcon'] = 'utility:pause';
                    }
                    record['actionButtonLabel'] = record['cloning_status'];
                    record['actionButton_disabled'] = true;
                }
                if (record['innerGridRecords'] && record['innerGridRecords'].length > 0) {
                    record['innerGridRecords'].forEach(currentItem => {
                        currentItem['cloneCheckBox'] = (currentItem['status'] != 'dropped') ? true : false;
                        currentItem['totalPrice'] = (record.currencyCode ? record.currencyCode : '') + ' ' + (currentItem.value ? currentItem.value : '0.00');
                    });
                }
            });
            this.allData = JSON.parse(JSON.stringify(tempData));
            this.setPagination(1);
            //this.renewalTaskWrapperList = JSON.parse(JSON.stringify(tempData));
        } else {
            this.allData = [];
            this.setPagination(1);
        }

    }

    setPagination(currentPageNumber) {
        this.currentPageNumber = currentPageNumber;
        let startIndex = (this.currentPageNumber - 1) * this.pageSize;
        let endIndex = (this.currentPageNumber) * this.pageSize;
        let selectedRecord = [];
        for (let i = startIndex; i < endIndex; ++i) {
            if (this.allData[i]) {
                selectedRecord.push(this.allData[i]);
                this.endIndex = i + 1;
            }
        }
        this.startIndex = startIndex + 1;
        this.renewalTaskWrapperList = JSON.parse(JSON.stringify(selectedRecord));

        // remove exiting style child Tag if any
        this.template.querySelectorAll('style').forEach(e => e.remove());

        // create new Style Child tag to hide checkbox
        let style = document.createElement('style');
        for (let i = 0; i < this.renewalTaskWrapperList.length; i++) {
            if (this.renewalTaskWrapperList[i].hideCheckBox == true) {
                style.innerText += '.rt-dataTable .slds-table tr:nth-child(' + (i + 1) + ') td:nth-child(1){visibility: hidden;}';
            }
        }
        this.template.querySelector('[data-id="rt-dataTable"]').appendChild(style);
        //this.template.querySelector('lightning-datatable').appendChild(style);

    }

    handleRowSelection(event) {
        if (event.detail.config.action == 'rowDeselect' || event.detail.config.action == 'deselectAllRows') {
            //row is UnChecked do nothing
            this.selectedRecordsNew = [];
            return;
        } else if (event.detail.config.action == 'rowSelect' || event.detail.config.action == 'selectAllRows') {
            this.selectedRecordsNew = event.detail.selectedRows.map(row => {
                if (row.hideCheckBox) {
                    return;
                } else {
                    return row.id;
                }
            });
        }
    }

    callRowAction(event) {
        const rowId = event.detail.row.id;
        if (event.detail.action.name === 'showInnerGridRecords') {
            for (var i = 0; i < this.renewalTaskWrapperList.length; i++) {
                if (this.renewalTaskWrapperList[i].id == rowId) {
                    this.renewalTaskDetailWrapperList = this.renewalTaskWrapperList[i].innerGridRecords;
                    this.showTaskDetailOnPopup = true;
                    this.popupHeader = 'Product Details';
                    break;
                }
            }
        } else if (event.detail.action.name === 'cloneActionButton') {
            let actionName = '';
            for (var i = 0; i < this.renewalTaskWrapperList.length; i++) {
                if (this.renewalTaskWrapperList[i].id == rowId) {
                    actionName = this.renewalTaskWrapperList[i].actionButtonLabel;
                    break;
                }
            }
            if (actionName == 'Awaiting Details') {
                window.open('/apex/VFP_CRM_OpportunityRenewal_PDetail?openFrom=lightning&id=' + rowId, 'Edit Products', 'height=500,width=1000,status=0,toolbar=0&location=0');
            } else if (actionName === 'Cloning Options') {
                this.openCloningOptionPopup(rowId);
            } else {
                alert('DEV issue.......... ' + actionName);
            }

        }
    }

    async openCloningOptionPopup(rowId) {
        let rtRecord = '';
        this.renewalTaskWrapperList.forEach(currentItem => {
            if (currentItem.id === rowId) {
                rtRecord = currentItem;
            }
        });
        CloneOptionPopup.open({
            size: 'large',
            label: 'Cloning Options',
            description: 'Cloning Options to Clone Opportunity',
            rtRecord: rtRecord,
        }).then((result) => {
            if (result === 'success') {
                this.refreshData();
            }
            console.log('then:', result);
        });
    }

    handleReassign() {
        let selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
        if (selectedRecord.length == 0) {
            this.showToast('Error Message', 'Please select at least one task for reassignment.', 'error',)
            return;
        } else {
            this.showReassignOnPopup = true;
            this.popupHeader = 'Select User to Reassign.'
        }
    }

    handleResourceSearch(event) {
        const target = event.target;
        findUsersBySearchKey({ searchKey: event.detail.searchTerm })
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.handleError(error, 'handleResourceSearch');
            });

    }

    handleResourceLookupChange(event) {
        this.reassignUserId = (event.detail.length > 0) ? event.detail[0] : null;
    }

    reassignRenewalTask(event) {
        this.showSpinner = true;
        let selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
        let rtToBeReassign = [];

        selectedRecord.forEach(currentItem => {
            rtToBeReassign.push(currentItem.id);
        });

        reassignRenewalTask({ reassignUserId: this.reassignUserId, renewalTaskIdToReassigne: rtToBeReassign })
            .then(result => {
                if (result === 'true') {
                    this.refreshData();
                } else {
                    this.handleError(result, 'reassignRenewalTask');
                }
            }).catch(error => {
                this.handleError(error, 'reassignRenewalTask');
            }).finally(() => {
                this.showSpinner = false;
                this.closePopup();
            });

    }

    handleEscapeKey(event) {
        if (event.key === 'Escape' && this.showPopup) {
            this.closePopup();
        }
    }

    closePopup() {
        this.popupHeader = '';
        this.showTaskDetailOnPopup = false;
        this.renewalTaskDetailWrapperList = [];
        this.showReassignOnPopup = false;
    }

    handleSubmit() {
        let selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
        if (selectedRecord.length != 0) {
            this.showToast('Error Message', 'Please select at least one task for cloning.', 'error',)
            return;
        } else {
            //todo: handleSubmit()
            //this.handleConfirmClick('offline', 'Are you sure?', 'offline');
            //this.handleConfirmClick('error', 'Are you sure?', 'error');
            //this.handleConfirmClick('info', 'Are you sure?', 'info');
        }
    }

    handleAddOpp() {
        window.open('/apex/VFP_CRM_OpportunityRenewals_AddDBOpp?openFrom=lightning', 'Add Opportunity', 'height=500,width=1000,status=0,toolbar=0&location=0');
        //window.open('/apex/VFP_CRM_OpportunityRenewals_AddDBOpp?' + 'currentPage=' + this.currentPageNumber + '&sortingField=' + this.sortedBy + '&sortingDir=' + this.sortDirection + '&openFrom=lightning', 'Add Opportunity', 'height=500,width=1000,status=0,toolbar=0&location=0');
    }

    handleRemoveOpp() {
        let selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
        if (selectedRecord.length == 0) {
            this.showToast('Error Message', 'Please select at least one task to remove.', 'error',)
            return;
        } else {
            this.handleConfirmClick('Delete', 'Are you sure?', 'warning', 'removeOpp');
        }
    }

    async handleConfirmClick(title, message, theme, ifOkActionName) {
        await LightningConfirm.open({
            label: title,
            message: message,
            theme: theme,
        }).then((result) => {
            if (result === true && ifOkActionName === 'removeOpp') {
                this.deactiveRenewalTask();
            }
        });

    }

    deactiveRenewalTask() {
        this.showSpinner = true;
        let selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
        let rtToBeRemoved = [];

        selectedRecord.forEach(currentItem => {
            rtToBeRemoved.push(currentItem.id);
        });

        deactiveRenewalTask({ renewalTaskToDeactivate: rtToBeRemoved })
            .then(result => {
                if (result === 'true') {
                    this.refreshData();
                } else {
                    this.handleError(result, 'deactiveRenewalTask');
                }
            }).catch(error => {
                this.handleError(error, 'deactiveRenewalTask');
            }).finally(() => {
                this.showSpinner = false;
            });
    }

    handleSearchOpp() {
        this.showSearchOptions = !(this.showSearchOptions);
    }

    handleKeyPress(event) {
        if (event.which == 13) {
            this.handleSearchRenwalTasks();
        }
    }

    handleSearchRenwalTasks() {
        this.showSpinner = true;
        let sOppNumber = this.template.querySelector('[data-id="sOppNumber"]').value;
        let sOppName = this.template.querySelector('[data-id="sOppName"]').value;
        let sAccName = this.template.querySelector('[data-id="sAccName"]').value;
        let sPOppName = this.template.querySelector('[data-id="sPOppName"]').value;
        let sPOppNumber = this.template.querySelector('[data-id="sPOppNumber"]').value;

        searchRenwalTasks({ sOppNumber: sOppNumber, sOppName: sOppName, sAccName: sAccName, sPOppName: sPOppName, sPOppNumber: sPOppNumber })
            .then(result => {
                this.genrateRenewalTaskWrapperList(result);
                this.showSearchOptions = false;
            }).catch(error => {
                this.handleError(error, 'refreshData');
            }).finally(() => {
                this.showSpinner = false;
            });
    }

    onFirst() {
        this.setPagination(1);
    }

    onPrev() {
        this.disbleFirstPageButton ? this.setPagination(1) : this.setPagination(this.currentPageNumber - 1);
    }

    onNext() {
        this.disbleLastPageButton ? this.setPagination(this.totalPages) : this.setPagination(this.currentPageNumber + 1);
    }

    onLast() {
        this.setPagination(this.totalPages);
    }

    showToast(title, errorMsg, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMsg,
                variant: variant,
            }),
        );
    }

    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        console.log(error);
        var errorMsg = new Array();
        if (Array.isArray(error)) {
            error.forEach(currentError => {
                errorMsg.push(currentError);
            });
        } else {
            var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
            var errorCode = (error.body && error.body.errorCode) ? error.body.errorCode : error.status ? error.status : '';
            if (JSON.parse(err).fieldErrors && Object.keys(JSON.parse(err).fieldErrors).length > 0) {
                let fieldError = JSON.parse(err).fieldErrors;
                for (let [key, value] of Object.entries(fieldError)) {
                    errorMsg.push(key + ': ' + value[0].message);
                    errorCode = value[0].statusCode;
                }
            } else if (JSON.parse(err).pageErrors && Object.keys(JSON.parse(err).pageErrors).length > 0) {
                let pageErrors = JSON.parse(err).pageErrors;
                for (let [key, value] of Object.entries(pageErrors)) {
                    errorMsg.push(value.message);
                    errorCode = value.statusCode;
                }
            } else {
                errorMsg.push(err == "{}" ? 'Unexpected error !!!' : err);
            }
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error ' + errorCode,
                message: errorMsg[0],
                variant: 'error',
                mode: 'pester'
            })
        );
        this.showSpinner = false;
    }

    get disbleFirstPageButton() {
        return (this.currentPageNumber == 1) ? true : false;
    }

    get disbleLastPageButton() {
        return (this.currentPageNumber == this.totalPages) ? true : false;
    }

    get totalPages() {
        return Math.ceil(this.allData.length / this.pageSize);
    }

    get showPopup() {
        return (this.showTaskDetailOnPopup || this.showReassignOnPopup) ? true : false;
    }

    get isRenewalTaskNotExist() {
        return (this.renewalTaskWrapperList == undefined || this.renewalTaskWrapperList.length === 0);
    }

    get isRenewalTaskDetailNotExist() {
        return (this.renewalTaskDetailWrapperList == undefined || this.renewalTaskDetailWrapperList.length === 0);
    }

    onHandleSort(event) {
        this.showSpinner = true;
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        const cloneData = [...this.renewalTaskWrapperList];
        cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
        this.renewalTaskWrapperList = cloneData;
        this.showSpinner = false;
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