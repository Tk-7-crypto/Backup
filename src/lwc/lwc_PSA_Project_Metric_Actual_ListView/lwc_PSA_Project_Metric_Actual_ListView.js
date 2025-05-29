import { LightningElement,track,api,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getProjectMetricActualData from '@salesforce/apex/CNT_PSA_Project_Metric_Actual.getProjectMetricActualData';
const actions = [
    { label: 'Edit', name: 'edit'}
];

const COLUMNS = [
    { label: 'Project Metric Actual Name', fieldName: 'ProjectActualURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}  
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

export default class Lwc_PSA_Project_Metric_Actual_ListView extends NavigationMixin(LightningElement) {

    columns = COLUMNS;
    @api recordId;
    error = false;
    filteredRecord = [];
    errorMsg = 'Unexpected error !!!';
    defaultSortDirection = 'ASC';
    sortDirection = 'ASC';
    sortedBy;
    project_metric_actual;
    noOfRecords= 0;
    @track isViewShow = false;

    @wire(getProjectMetricActualData, {recordId: '$recordId' })
    wireMethod({ data, error }) {
        if (data) {
            var tempData = JSON.parse(JSON.stringify(data));
            if( tempData.length > 0 ){
                this.isViewShow = true;
            }
            this.project_metric_actual = JSON.parse(JSON.stringify(data));
            if (tempData.length > 0) {
                tempData.forEach(function (record) {
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

        } else if (error) {
            this.error = true;
            this.errorMsg = error.body ? (error.body.message ? error.body.message : JSON.stringify(error.body)) : JSON.stringify(error);
            console.log('error : ' + JSON.stringify(error));
        }
    }

    onHandleClick(event){

        const defaultValues = encodeDefaultFieldValues({
            Project__c : this.recordId
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Project_Metric_Actual__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
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
                objectApiName: 'Project_Metric_Actual__c',
                actionName: 'edit'
            }
        });
    }

    onHandleSort(event) {
        const {fieldName: sortedBy, sortDirection} = event.detail;
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
        window.open('/lightning/n/PSA_View_All?c__RecordId='+this.recordId+'&c__HeadingName=Project Metric Actual&c__IconName=custom:custom68','_self');
        
    }
       
}
