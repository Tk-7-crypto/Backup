import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

import getArchiveEJData from '@salesforce/apex/CNT_PSA_ArchiveSsEjListView.getArchiveEJData';

// row actions
const actions = [
    { label: 'Edit', name: 'edit'}
];

const COLUMNS = [
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
export default class Lwc_psa_archiveeventjournallistview extends  NavigationMixin(LightningElement) {
    @api recordId;

    lrTypeError = true;
    @track isCompleted = false;
    @track isDataFromLRValid = false;
    @track isSSCreationPossible = false;

    @api columns = COLUMNS;
    error = false;
    filteredRecord = [];
    errorMsg = 'Unexpected error !!!';
    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;
    Archive_event_journal;
    noOfRecords= 0;

    lrId;
    accId;
    projectId;
    productId;
    lrType;
    @track isViewShow = false;
    
   @wire(getArchiveEJData, {recordId: '$recordId' })
    wireMethod({ data, error }) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data));
            if( tempData.length > 0 ){
                this.isViewShow = true;
            }
            this.Archive_event_journal = JSON.parse(JSON.stringify(data));
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

        } else if (error) {
            this.error = true;
            this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
            console.log('error : ' + JSON.stringify(error));
        }
    }

    /*onHandleClick(event){

        const defaultValues = encodeDefaultFieldValues({
        Account__c: result.Account__c,
                                    //LR_Project_Overview__c: result.Id,
                                    LR_Type__c: result.LR_Type__c,
                                    Project__c: result.Project__c,
                                    Product__c: result.Product__c

        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Archive_Event_Journal__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }*/

    handleRowActions(event){
        let actionName = event.detail.action.name;
        console.log(actionName);
        let row = event.detail.row;
        console.log(row);
        // eslint-disable-next-line default-case
        switch (actionName) {
            case 'edit':
                this.editCurrentRecord(row);
                break;
        }
        
    }

    editCurrentRecord(currentRow) {
        console.log(currentRow.Id);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: currentRow.Id,
                objectApiName: 'Archive_Event_Journal__c',
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
    @api viewAll(){
        //Set LocalStorage 
		let cols = JSON.stringify(COLUMNS);
        localStorage.setItem('CoulumnDetails', cols);
        window.open('/lightning/n/PSA_View_All?c__RecordId='+this.recordId+'&c__HeadingName=Archive Event Journals&c__IconName=custom:custom27','_self');
        
    }
    

}
