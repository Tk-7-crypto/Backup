import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQCTrackerResultData from '@salesforce/apex/CNT_PSA_QC_Tracker_List_View.getQCTrackerResultData';
// row actions
const actions = [
    { label: 'Edit', name: 'edit'}
];

const COLUMNS = [
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

export default class Lwc_psa_qc_tracker_list_view extends NavigationMixin(LightningElement) {
    @api recordId;
    columns = COLUMNS;
    error = false;
    filteredRecord = [];
    errorMsg = 'Unexpected error !!!';
    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;
    noOfRecords= 0;
    @track isViewShow = false;
    
    @wire(getQCTrackerResultData, {recordId: '$recordId'})
    wireMethod({data, error}) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data));
            if(tempData.length > 0){
                this.isViewShow = true;
            }
            if (tempData.length > 0) {
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
        } else if (error) {
            this.error = true;
            this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
            console.log('error : ' + JSON.stringify(error));
        }
    }
    
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
                objectApiName: 'QC_Tracker_Result__c',
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
        window.open('/lightning/n/PSA_View_All?c__RecordId='+this.recordId+'&c__HeadingName=QC Tracker Results&c__IconName=custom:custom87','_self');        
    }

}
