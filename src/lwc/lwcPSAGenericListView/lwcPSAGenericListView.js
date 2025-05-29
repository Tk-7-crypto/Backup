import { LightningElement, track, wire, api } from 'lwc';
import getFilterData from '@salesforce/apex/CNT_PSA_Search_Strategy_ListView.getFilterData';
import getAllRecordsForListView from '@salesforce/apex/CNT_PSA_Project_Metric_Actual.getAllRecordsForListView';
import delMetricRecords from '@salesforce/apex/CNT_PSA_Project_Metric_Actual.delMetricRecords';
import getProjectMetricActualData from '@salesforce/apex/CNT_PSA_Project_Metric_Actual.getProjectMetricActualData';
import getEventJournalDataForView from '@salesforce/apex/CNT_PSA_Event_Journals_ListView.getEventJournalDataForView';
import getAllArchiveSSRecordsForListView from '@salesforce/apex/CNT_PSA_ArchiveSsEjListView.getAllArchiveSSRecordsForListView';
import getAllActiveQCRecordsForListView from '@salesforce/apex/CNT_PSA_QC_Tracker_List_View.getAllActiveQCRecordsForListView';
import getAllArchiveEJRecordsForListView from '@salesforce/apex/CNT_PSA_ArchiveSsEjListView.getAllArchiveEJRecordsForListView';

import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";

const actions = [
    { label: 'Edit', name: 'edit' }
];



const COLUMNS = [
    {
        label: 'Project Metric Actual Name', fieldName: 'ProjectActualURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'PSA Metric', fieldName: 'PSA_Metric__c.Name', type: 'text', sortable: true },
    { label: 'Project Metric', fieldName: 'Project_Metric__c.Name', type: 'text', sortable: true },
    { label: 'Date', fieldName: 'Date__c', type: 'Date', sortable: true },
    { label: 'Value', fieldName: 'Quantity__c', type: 'Number', sortable: true },
    { label: 'Comments', fieldName: 'Comments__c', type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];
const AREJ_COLUMNS = [
    { label: 'Archive Event Journal Name', fieldName: 'ArchiveEventJournalURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}  
    },
    { label: 'Country', fieldName: 'Country__c', type: 'Picklist', sortable: true },
    { label: 'Journal Name', fieldName: 'Journal_Name__c', type: 'text', sortable: true },
    { label: 'URL', fieldName: 'URL__c', type: 'text', sortable: true },
	{ label: 'Date Initial Search Started', fieldName: 'Date_Initial_Search_Started__c', type: 'Date', sortable: true },
	{ label: 'Date Last Journal Search was Performed', fieldName: 'Date_Last_Journal_Search_was_Performed__c', type: 'Date', sortable: true },
	{ label: 'Date Next Journal Search is Due', fieldName: 'Date_Next_Journal_Search_is_Due__c', type: 'Date', sortable: true },
    { label: 'Active', fieldName: 'Active__c', type: 'Text', sortable: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

const ARSS_COLUMNS = [
    { label: 'Archive Search Strategy Name', fieldName: 'ArchiveSearchStrategyURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}  
    },
    { label: 'Version #of Search Strategy', fieldName: 'Version_of_Search_Strategy__c', type: 'Number', sortable: true },
    { label: 'Date Search Strategy got Client Approval', fieldName: 'Date_Search_Strategy_got_Client_Approval__c', type: 'Date', sortable: true },
    { label: 'Date Annual Search Strategy Due', fieldName: 'Date_Annual_Search_Strategy_Due__c', type: 'Date', sortable: true },
    { label: 'Comments', fieldName: 'Comments__c', type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

const SS_COLUMNS = [
    { label: 'Search Strategy Name', fieldName: 'SearchStrategyURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}  
    },
    { label: 'Version #of Search Strategy', fieldName: 'Version_of_Search_Strategy__c', type: 'Number', sortable: true },
    { label: 'Date Search Strategy got Client Approval', fieldName: 'Date_Search_Strategy_got_Client_Approval__c', type: 'Date', sortable: true },
    { label: 'Date Annual Search Strategy Due', fieldName: 'Date_Annual_Search_Strategy_Due__c', type: 'Date', sortable: true },
    { label: 'Comments', fieldName: 'Comments__c', type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

const EJ_COLUMNS = [
    { label: 'Unique ID', fieldName: 'EventJournalURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}  
    },
    { label: 'Country', fieldName: 'Country__c', type: 'text', sortable: true },
    { label: 'Journal Name', fieldName: 'Journal_Name__c', type: 'text', sortable: true },
    { label: 'URL', fieldName: 'URL__c', type: 'url', sortable: true },
    { label: 'Date Initial Search Started', fieldName: 'Date_Initial_Search_Started__c', type: 'Date', sortable: true },
    { label: 'Date Last Journal Search was Performed', fieldName: 'Date_Last_Journal_Search_was_Performed__c', type: 'Date', sortable: true },
    { label: 'Date Next Journal Search is Due', fieldName: 'Date_Next_Journal_Search_is_Due__c', type: 'Date', sortable: true },
    { label: 'Active?', fieldName: 'Active__c', type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

const QC_COLUMNS = [
    { label: 'REP_SARA Report ID', fieldName: 'SaraReportURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}  
    },
    { label: 'REP_QC ID', fieldName: 'REP_QC_ID__c', type: 'Text', sortable: true },
    { label: 'REP_QC Form Type', fieldName: 'REP_QC_Form_Type__c', type: 'Text', sortable: true },
    { label: 'REP_Author', fieldName: 'REP_Author__c', type: 'Text', sortable: true },
    { label: 'REP_Date QC Completed', fieldName: 'REP_Date_QC_Completed__c', type: 'Date', sortable: true },
    { label: 'Date Deleted', fieldName: 'Date_Deleted__c', type: 'Date', sortable: true },
    { label: 'REP_QC Completed By', fieldName: 'REP_QC_Completed_By__c', type: 'Text', sortable: true },
    { label: 'REP_Error Free?', fieldName: 'REP_Error_Free__c', type: 'text', sortable: true },
    { label: 'REP_QC URL?', fieldName: 'REP_QC_URL__c', type: 'text', sortable: true },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];

export default class LwcPSAGenericListView extends NavigationMixin(LightningElement) {
    headingName;
    @track columns = [];
    recordId;
    componentIcon;
    error = false;
    @track filteredRecord = [];
    errorMsg = 'Unexpected error !!!';
    defaultSortDirection = 'ASC';
    @track sortDirection = 'ASC';
    @track sortedBy;
    @track loaded = true;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track error = null;
    @track pageSize = 50;
    @track isPrev = true;
    @track isNext = true;
    @track isEdit;
    isDelete = false;
    @api selectedMetriclist = [];
    @track confirmation;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const urlRecordId = currentPageReference.state.c__RecordId;
            if (urlRecordId) {
                this.recordId = urlRecordId;
            }

            const urlHeadingName = currentPageReference.state.c__HeadingName;
            if (urlHeadingName === 'Project Metric Actual') {
                this.headingName = urlHeadingName;
                this.isDelete = true;
                this.columns = COLUMNS;
            } else {
                this.isDelete = false;
                this.headingName = urlHeadingName;
                //this.retrieveLocalStorage();
            }
            const urlIconName = currentPageReference.state.c__IconName;
            if (urlIconName) {
                this.componentIcon = urlIconName;
            }
        }
        if (this.headingName === 'QC Tracker Results') {
            this.sortedBy = 'REP_Date_QC_Completed__c';
            this.sortDirection = 'DESC';
            this.columns = QC_COLUMNS;
        } else if (this.headingName === 'Archive Event Journals') {
            this.sortedBy = 'CreatedDate';
            this.sortDirection = 'DESC'
            this.columns = AREJ_COLUMNS;
        } else if (this.headingName === 'Archive Search Strategies') {
            this.sortedBy = 'CreatedDate';
            this.sortDirection = 'DESC'
            this.columns = ARSS_COLUMNS;
        }
        else if (this.headingName === 'Search Strategies') {
            this.sortedBy = 'CreatedDate';
            this.sortDirection = 'DESC'
            this.columns = SS_COLUMNS;
        }
        else if (this.headingName === 'Event Journals') {
            this.sortedBy = 'CreatedDate';
            this.sortDirection = 'DESC'
            this.columns = EJ_COLUMNS;
        }
        this.load(this.headingName);
    }

    getSelectedId(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedMetriclist = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedMetriclist.push(selectedRows[i].Id);
        }
    }

    async handleDelete() {
        this.loaded = true;
        if (this.selectedMetriclist.length > 0) {
            const result = await LightningConfirm.open({
                message: "Are you sure you want to delete this Project Metric Actuals",
                variant: "default",
                label: "Delete record"
            });

            if (result) {
                delMetricRecords({ selecRecords: this.selectedMetriclist, recordId: this.recordId })
                    .then(() => {
                        this.selectedMetriclist = [];
                        this.recordEnd = 0;
                        this.totalRecords = 0;
                        this.recordStart = 0;
                        this.pageNumber = 0;
                        this.totalPages = 0;
                        this.isNext = 0;
                        this.isPrev = 0;
                        this.refresh();
                    })
                    .catch((error) => {
                        this.errorMessage = error;
                        console.log('unable to delete the record due to' + JSON.stringify(this.errorMessage));
                    });
            } else {
                this.refresh();
            }

        } else {
            this.loaded = false;
            this.showErrorToast('Please Select a Record for Deletion');
        }
    }

    connectedCallback() {
        if (this.headingName === 'QC Tracker Results') {
            this.sortedBy = 'REP_Date_QC_Completed__c';
            this.sortDirection = 'DESC'
        } else if (this.headingName === 'Archive Event Journals') {
            this.sortedBy = 'CreatedDate';
            this.sortDirection = 'DESC'
        } else if (this.headingName === 'Archive Search Strategies') {
            this.sortedBy = 'CreatedDate';
            this.sortDirection = 'DESC'
        }
        this.load(this.headingName);
    }

    retrieveLocalStorage() {
        if (localStorage.getItem('CoulumnDetails')) {
            this.columns = JSON.parse(localStorage.getItem('CoulumnDetails'));
            //Clear local storage after getting the values
            localStorage.clear();
        }
    }

    load(sobjectName) {
        if (sobjectName === 'Search Strategies') {
            getFilterData({
                recordId: this.recordId,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber,
                totalRecords: this.totalRecords
            })
                .then(result => {
                    if (result) {
                        var resultData = JSON.parse(result);
                        this.recordEnd = resultData.recordEnd;
                        this.totalRecords = resultData.totalRecords;
                        this.recordStart = resultData.recordStart;
                        this.pageNumber = resultData.pageNumber;
                        this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                        let tempData = resultData.searchStrategies;
                        if (tempData.length > 0) {
                            tempData.forEach(function (record) {
                                record['Id'] = record.Id;
                                record['SearchStrategyURL'] = '/' + record.Id;
                                record['Name'] = record.Name;
                                record['Version_of_Search_Strategy__c'] = record.Version_of_Search_Strategy__c;
                                record['Date_Search_Strategy_got_Client_Approval__c'] = record.Date_Search_Strategy_got_Client_Approval__c;
                                record['Date_Annual_Search_Strategy_Due__c'] = record.Date_Annual_Search_Strategy_Due__c;
                                record['Comments__c'] = record.Comments__c;
                            });
                            this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                        }
                        this.loaded = false;
                    } else if (error) {
                        this.error = true;
                        this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
                        console.log('error : ' + JSON.stringify(error));
                        this.loaded = false;
                    }
                })
                .catch(error => {
                    this.loaded = false;
                    this.error = true;
                    let err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                    this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                    this.loaded = false;
                });
        } else if (sobjectName === 'Event Journals') {
            getEventJournalDataForView({
                recordId: this.recordId,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber,
                totalRecords: this.totalRecords
            }
            ).then(result => {
                if (result) {
                    //console.log('@result ' + result);
                    var resultData = JSON.parse(result);
                    this.recordEnd = resultData.recordEnd;
                    this.totalRecords = resultData.totalRecords;
                    this.recordStart = resultData.recordStart;
                    this.pageNumber = resultData.pageNumber;
                    this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                    this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                    this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                    let tempData = resultData.eventJournals;
                    if (tempData.length > 0) {
                        tempData.forEach(function (record) {
                            record['Id'] = record.Id;
                            record['EventJournalURL'] = '/' + record.Id;
                            record['Name'] = record.Name;
                            record['Journal_Name__c'] = record.Journal_Name__c;
                            record['URL__c'] = record.URL__c;
                            record['Date_Initial_Search_Started__c'] = record.Date_Initial_Search_Started__c;
                            record['Date_Last_Journal_Search_was_Performed__c'] = record.Date_Last_Journal_Search_was_Performed__c;
                            record['Date_Next_Journal_Search_is_Due__c'] = record.Date_Next_Journal_Search_is_Due__c;
                            record['Active__c'] = record.Active__c;
                        });
                        this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                    }
                    this.loaded = false;
                } else if (error) {

                    this.error = true;
                    this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
                    console.log('@error : ' + JSON.stringify(error));
                    this.loaded = false;
                }

            }).catch(error => {

                console.log('@error :' + JSON.stringify(error));
                this.error = true;
                let err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                this.loaded = false;
            });
        } else if (sobjectName === 'Project Metric Actual') {

            getAllRecordsForListView({
                recordId: this.recordId,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber,
                totalRecords: this.totalRecords
            })
                .then(result => {
                    if (result) {
                        //console.log('@result ' + result);
                        var resultData = JSON.parse(result);
                        this.recordEnd = resultData.recordEnd;
                        this.totalRecords = resultData.totalRecords;
                        this.recordStart = resultData.recordStart;
                        this.pageNumber = resultData.pageNumber;
                        this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                        let tempData = resultData.projectMetric;
                        if (tempData.length > 0) {
                            tempData.forEach(function (record) {
                                record['Id'] = record.Id;
                                record['ProjectActualURL'] = '/' + record.Id;
                                record['Name'] = record.Name;
                                record['PSA_Metric__c.Name'] = record.PSA_Metric__r.Name;
                                record['Project_Metric__c.Name'] = record.Project_Metric__r.Name;
                                record['Date__c'] = record.Date__c;
                                record['Quantity__c'] = record.Quantity__c;
                                record['Comments__c'] = record.Comments__c;
                            });
                            this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                        }
                        this.loaded = false;
                    } else if (error) {

                        this.error = true;
                        this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
                        console.log('error : ' + JSON.stringify(error));
                        this.loaded = false;
                    }
                })
                .catch(error => {
                    this.loaded = false;
                    console.log('error :' + JSON.stringify(error));
                    this.error = true;
                    let err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                    this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                    this.loaded = false;
                });
        } else if (sobjectName === 'Archive Search Strategies') {

            getAllArchiveSSRecordsForListView({
                recordId: this.recordId,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber,
                totalRecords: this.totalRecords,
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection
            })
                .then(result => {
                    if (result) {
                        //console.log('@result ' + result);
                        var resultData = JSON.parse(result);
                        this.recordEnd = resultData.recordEnd;
                        this.totalRecords = resultData.totalRecords;
                        this.recordStart = resultData.recordStart;
                        this.pageNumber = resultData.pageNumber;
                        this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                        let tempData = resultData.archiveSs;
                        if (tempData.length > 0) {
                            tempData.forEach(function (record) {
                                record['ArchiveSearchStrategyURL'] = '/' + record.Id;
                                record['Name'] = record.Name;
                                record['Version_of_Search_Strategy__c'] = record.Version_of_Search_Strategy__c;
                                record['Date_Search_Strategy_got_Client_Approval__c'] = record.Date_Search_Strategy_got_Client_Approval__c;
                                record['Date_Annual_Search_Strategy_Due__c'] = record.Date_Annual_Search_Strategy_Due__c;
                                record['Comments__c'] = record.Comments__c;
                            });
                            this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                            
                        }
                        this.loaded = false;
                    } else if (error) {

                        this.error = true;
                        this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
                        console.log('error : ' + JSON.stringify(error));
                        this.loaded = false;
                    }
                })
                .catch(error => {
                    this.loaded = false;
                    console.log('error :' + JSON.stringify(error));
                    this.error = true;
                    let err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                    this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                    this.loaded = false;
                });
        } else if (sobjectName === 'Archive Event Journals') {

            getAllArchiveEJRecordsForListView({
                recordId: this.recordId,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber,
                totalRecords: this.totalRecords,
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection
            })
                .then(result => {
                    if (result) {
                        //console.log('@result ' + result);
                        var resultData = JSON.parse(result);
                        this.recordEnd = resultData.recordEnd;
                        this.totalRecords = resultData.totalRecords;
                        this.recordStart = resultData.recordStart;
                        this.pageNumber = resultData.pageNumber;
                        this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                        let tempData = resultData.archiveEj;
                        if (tempData.length > 0) {
                            tempData.forEach(function (record) {
                                record['ArchiveEventJournalURL'] = '/' + record.Id;
                                record['Name'] = record.Name;
                                record['Country__c'] = record.Country__c;
                                record['Journal_Name__c'] = record.Journal_Name__c;
                                record['URL__c'] = record.URL__c;
                                record['Date_Initial_Search_Started__c'] = record.Date_Initial_Search_Started__c;
                                record['Date_Last_Journal_Search_was_Performed__c'] = record.Date_Last_Journal_Search_was_Performed__c;
                                record['Date_Next_Journal_Search_is_Due__c'] = record.Date_Next_Journal_Search_is_Due__c;
                                record['Active__c'] = record.Active__c;
                            });
                            this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                        }
                        this.loaded = false;
                    } else if (error) {

                        this.error = true;
                        this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
                        console.log('error : ' + JSON.stringify(error));
                        this.loaded = false;
                    }
                })
                .catch(error => {
                    this.loaded = false;
                    console.log('error :' + JSON.stringify(error));
                    this.error = true;
                    let err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                    this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                    this.loaded = false;
                });
        } else if (sobjectName === 'QC Tracker Results') {
            getAllActiveQCRecordsForListView({
                recordId: this.recordId,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber,
                totalRecords: this.totalRecords,
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection
            })
                .then(result => {
                    if (result) {
                        //console.log('@result ' + result);
                        var resultData = JSON.parse(result);
                        this.recordEnd = resultData.recordEnd;
                        this.totalRecords = resultData.totalRecords;
                        this.recordStart = resultData.recordStart;
                        this.pageNumber = resultData.pageNumber;
                        this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                        let tempData = resultData.qcTrackerList;
                        if (tempData && tempData.length > 0) {
                            tempData.forEach(function (record) {
                                record['SaraReportURL'] = '/' + record.Id;
                                record['Name'] = record.Name;
                                record['REP_QC_ID__c'] = record.REP_QC_ID__c;
                                record['REP_QC_Form_Type__c'] = record.REP_QC_Form_Type__c;
                                record['REP_Author__c'] = record.REP_Author__c;
                                record['REP_Date_QC_Completed__c'] = record.REP_Date_QC_Completed__c;
                                record['Date_Deleted__c'] = record.Date_Deleted__c;
                                record['REP_QC_Completed_By__c'] = record.REP_QC_Completed_By__c;
                                record['REP_Error_Free__c'] = record.REP_Error_Free__c;
                                record['REP_QC_URL__c'] = record.REP_QC_URL__c;
                            });
                            this.filteredRecord = JSON.parse(JSON.stringify(tempData));
                        }
                        this.loaded = false;
                    } else if (error) {
                        this.error = true;
                        this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
                        console.log('error : ' + JSON.stringify(error));
                        this.loaded = false;
                    }
                })
                .catch(error => {
                    this.loaded = false;
                    console.log('error :' + JSON.stringify(error));
                    this.error = true;
                    let err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
                    this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
                    this.loaded = false;
                });
        }
        this.isEdit = false;
    }

    onHandleSort(event) {
        if (this.headingName === 'QC Tracker Results' || this.headingName === 'Archive Search Strategies' || this.headingName === 'Archive Event Journals') {
            console.log('Hi ', event.detail.fieldName, ' ', event.detail.sortDirection);
            this.loaded = true;
            this.sortedBy = event.detail.fieldName;
            this.sortDirection = event.detail.sortDirection;
            this.load(this.headingName);
            //this.sortData(this.sortBy, this.sortDirection);
        } else {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            console.log('sorting ', event.detail);
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;
            const cloneData = [...this.filteredRecord];
            cloneData.sort(this.sortBy(this.sortedBy, this.sortDirection === 'asc' ? 1 : -1));
            this.filteredRecord = cloneData;
        }

    }
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let row = event.detail.row;
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
                recordId: currentRow.Id,
                objectApiName: 'Search_Strategy__c',
                actionName: 'edit'
            }
        });
        this.isEdit = true;

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
    backToLR() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "LR_Project_Overview__c",
                actionName: "view",
                recordId: this.recordId
            }
        });
    }

    findIndexByProperty(data, value) {
        for (let i = 0; i < data.length; i++) {
            if (data[i] == value) {
                return i;
            }
        }
        return -1;
    }
    handlePageNextAction() {
        this.loaded = true;
        this.pageNumber = this.pageNumber + 1;
        this.load(this.headingName);
    }
    handlePagePrevAction() {
        this.loaded = true;
        this.pageNumber = this.pageNumber - 1;
        this.load(this.headingName);
    }
    get isDisplayNoRecords() {
        var isDisplay = true;
        if (this.contacts) {
            if (this.contacts.length == 0) {
                isDisplay = true;
            } else {
                isDisplay = false;
            }
        }
        return isDisplay;
    }
    refresh() {
        this.filteredRecord = [];
        this.loaded = true;
        this.pageNumber = 1;
        this.load(this.headingName);
    }
    disconnectedCallback() {
        this.filteredRecord = [];
    }
    showErrorToast(msg) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: msg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}
