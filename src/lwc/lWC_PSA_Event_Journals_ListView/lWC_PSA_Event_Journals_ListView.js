import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getEventJournalData from '@salesforce/apex/CNT_PSA_Event_Journals_ListView.getEventJournalData';
import getLrData from '@salesforce/apex/CNT_PSA_Search_Strategy_ListView.getLRData';

// row actions
const actions = [
    { label: 'Edit', name: 'edit'}
];

const COLUMNS = [
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
export default class LWC_PSA_Event_Journals_ListView extends  NavigationMixin(LightningElement) {

     @api recordId;

    columns = COLUMNS;
    error = false;
    filteredRecord = [];
    errorMsg = 'Unexpected error !!!';
    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;
    search_strategy;
    noOfRecords= 0;

    lrId;
    accId;
    projectId;
    productId;
    lrType;
    @track isViewShow = false;

    @wire(getEventJournalData, {recordId: '$recordId' })
    wireMethod({ data, error }) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data));
            if( tempData.length > 0 ){
                this.isViewShow = true;
            }
            this.search_strategy = JSON.parse(JSON.stringify(data));
            if (tempData.length > 0) {
                tempData.forEach(function (record) {
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

        } else if (error) {
            this.error = true;
            this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
            console.log('error : ' + JSON.stringify(error));
        }
    }

    onHandleClick(event){        
        getLrData({ recordId: this.recordId })
                .then(result => {
                    if (result) {
                        this[NavigationMixin.Navigate]({
                            "type": "standard__webPage",
                            "attributes": {
                                "url": "/lightning/n/PSA_ADD_Journal?c__LR_Project_Overview="+result.Id
                            }
                        });
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

    handleRowActions(event){
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
                recordId: currentRow.Id,
                objectApiName: 'Event_Journals__c',
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
    viewAll(){
	  //Set LocalStorage 
	  let cols = JSON.stringify(COLUMNS);
        localStorage.setItem('CoulumnDetails', cols);
        // to resolved refresh problem
        window.open('/lightning/n/PSA_View_All?c__RecordId='+this.recordId+'&c__HeadingName=Event Journals&c__IconName=custom:custom27','_self');
    }
}
