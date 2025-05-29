import { LightningElement, api, wire } from 'lwc';
import TASK_SUBJECT_FIELD from '@salesforce/schema/Task.Subject';
import TASK_PRIORITY_FIELD from '@salesforce/schema/Task.Priority';
import TASK_TYPE_FIELD from '@salesforce/schema/Task.Type';
import TASK_STATUS_FIELD from '@salesforce/schema/Task.Status';
import TASK_ACTIVITY_DATE_FIELD from '@salesforce/schema/Task.ActivityDate';
import getTasks from '@salesforce/apex/CNT_CRM_Tasks.getTasks';
import Id from '@salesforce/user/Id';

const COLUMNS = [
    { label: 'Subject', fieldName: 'recordURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: TASK_SUBJECT_FIELD.fieldApiName }, target: '_blank'}  
    },
    { label: 'Status', fieldName: TASK_STATUS_FIELD.fieldApiName, type: 'text', sortable: true},
    { label: 'Priority', fieldName: TASK_PRIORITY_FIELD.fieldApiName, type: 'text', sortable: true},
    { label: 'Type', fieldName: TASK_TYPE_FIELD.fieldApiName, type: 'text', sortable: true},
    { label: 'Assigned To', fieldName: 'OwnerName', type:'text', sortable: true},
    { label: 'Date', fieldName: TASK_ACTIVITY_DATE_FIELD.fieldApiName, type: 'Date', sortable: true},
    { label: 'Name', fieldName: 'WhoName', type:'text', sortable: true},
    { label: 'Related To', fieldName: 'WhatName', type:'text', sortable: true}
];

export default class Lwc_crm_all_tasks extends LightningElement {
    @api recordId;
    userId = Id;
    columns = COLUMNS;

    tasks;
    filteredTasks;
    error;

    sortedBy;
    sortDirection = 'asc';

    recordTypeValue = 'All_Task';
    taskListValue = 'alltasks'

    get recordTypeOptions() {
        return [
            { label: 'All', value: 'All_Task' },
            { label: 'Standard', value: 'Standard_Task' },
            { label: 'CSM', value: 'CSM_Task' },
            { label: 'Call Plan', value: 'Call_Plan_Task' },
            { label: 'MQL', value: 'MQL_Task' },
        ];
    }

    get taskTypeOptions() {
        return [
            { label: 'All Tasks', value: 'alltasks' },
            { label: 'My Tasks', value: 'mytasks' },
            { label: 'Delegated Tasks', value: 'delegatedtasks' }
        ];
    }

    @wire(getTasks, {recordId : '$recordId'})
    wireTasks({data, error}) {
        if (data) {
            //console.log(data);
            this.tasks = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
            this.error = undefined;
            this.tasks.forEach(function(task){
                try{
                    task['recordURL'] = '/' + task.Id;
                    task['OwnerName'] = task.hasOwnProperty('Owner') == true ? task.Owner.Name : '';
                    task['WhoName'] = task.hasOwnProperty('Who') == true ? task.Who.Name : '';
                    task['WhatName'] = task.hasOwnProperty('What') == true ? task.What.Name : '';
                    task['RecordTypeName'] = task.hasOwnProperty('RecordType') == true ? task.RecordType.DeveloperName : '';
                }catch(e){
                    console.log(e);
                } 
            });
            this.filteredTasks = JSON.parse(JSON.stringify(this.tasks));
            //console.log(this.tasks);   
        } else if (error) {
            this.error = error;
            this.tasks = undefined;
            //console.log(this.error);  
        }
    }

    onHandleSort( event ) {
        //console.log(event.detail);
        const { fieldName: sortedBy, sortDirection } = event.detail;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.sort();
    }

    sort(){
        const cloneData = [...this.filteredTasks];
        cloneData.sort( this.sortBy( this.sortedBy, this.sortDirection === 'asc' ? 1 : -1 ) );
        this.filteredTasks = cloneData;
    }

     sortBy( field, reverse, primer ) {
        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };
    }

    handleRecordTypeChange(event) {
        //console.log(event.detail.value);
        this.recordTypeValue = event.detail.value;
        this.filterTasks();
        this.sort();
    }

    handleTaskListChange(event) {
        //console.log(event.detail.value);
        this.taskListValue = event.detail.value;
        this.filterTasks();
        this.sort();
    }

    filterTasks(){
        if(this.tasks){
            this.filteredTasks = this.tasks.filter(function(item){
                let flagA = (this.recordTypeValue == 'All_Task' || item.RecordTypeName == this.recordTypeValue);
                if(!flagA){
                    return false;
                } 
                let flagB = false;
                if(this.taskListValue == 'alltasks'){
                    flagB = true;
                }else if(this.taskListValue == 'mytasks'){
                    flagB = (item.OwnerId == this.userId);
                }else{
                    flagB = (item.CreatedById == this.userId && item.OwnerId != this.userId);
                }
                return flagA && flagB;  
            }.bind(this));
        } 
    }
}