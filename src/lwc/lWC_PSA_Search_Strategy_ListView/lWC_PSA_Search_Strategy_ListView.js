import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getSearchStrategyData from '@salesforce/apex/CNT_PSA_Search_Strategy_ListView.getSearchStrategyData';
import getLrData from '@salesforce/apex/CNT_PSA_Search_Strategy_ListView.getLRData';
import lrProjectOverviewValidation from '@salesforce/apex/CNT_PSA_Search_Strategy_ListView.lrProjectOverviewValidation';

// row actions
const actions = [
    { label: 'Edit', name: 'edit'}
];

const COLUMNS = [
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
export default class LWC_PSA_Search_Strategy_ListView extends  NavigationMixin(LightningElement) {
    @api recordId;

    lrTypeError = true;
    @track isCompleted = false;
    @track isDataFromLRValid = false;
    @track isSSCreationPossible = false;

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
    
    @wire(getSearchStrategyData, {recordId: '$recordId' })
    wireMethod({ data, error }) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data));
            if( tempData.length > 0 ){
                this.isViewShow = true;
            }
            this.search_strategy = JSON.parse(JSON.stringify(data));
            if (tempData.length > 0) {
                tempData.forEach(function (record) {
                    record['SearchStrategyURL'] = '/' + record.Id;
                    record['Name'] = record.Name;
                    record['Version_of_Search_Strategy__c'] = record.Version_of_Search_Strategy__c;
                    record['Date_Search_Strategy_got_Client_Approval__c'] = record.Date_Search_Strategy_got_Client_Approval__c;
                    record['Date_Annual_Search_Strategy_Due__c'] = record.Date_Annual_Search_Strategy_Due__c;
                    record['Comments__c'] = record.Comments__c;
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

        lrProjectOverviewValidation({ recordId: this.recordId })
                .then(result => {
                    if( result == 'NotValidForCompleteAndCancelled' ){
                        this.lrTypeError = true;
                        this.isCompleted = true;
                        this.isSSCreationPossible = false; 
                        this.isDataFromLRValid = false;
                    }else if ( result == 'NotValidForSearchStrategyCreated' ){
                        this.lrTypeError = true;
                        this.isSSCreationPossible = true;
                        this.isCompleted = false;
                        this.isDataFromLRValid = false;
                    }else if(result == 'NotValidDataFromLR'){
                        this.lrTypeError = true;
                        this.isDataFromLRValid = true;
                        this.isCompleted = false;
                        this.isSSCreationPossible = false; 
                    }else{
                        this.lrTypeError = false;
                        getLrData({ recordId: this.recordId })
                            .then(result => {
                                if (result) {
                                    const defaultValues = encodeDefaultFieldValues({
                                        Account__c: result.Account__c,
                                        //LR_Project_Overview__c: result.Id,
                                        LR_Type__c: result.LR_Type__c,
                                        Project__c: result.Project__c,
                                        Product__c: result.Product__c
                                    });
                                    console.log(defaultValues);
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__objectPage',
                                        attributes: {
                                            objectApiName: 'Search_Strategy__c',
                                            actionName: 'new'
                                        },
                                        state: {
                                            defaultFieldValues: defaultValues
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
                objectApiName: 'Search_Strategy__c',
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
        window.open('/lightning/n/PSA_View_All?c__RecordId='+this.recordId+'&c__HeadingName=Search Strategies&c__IconName=custom:custom68','_self');
        
    }

}
