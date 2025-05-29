import { LightningElement, api, wire } from 'lwc';
import TASK_SUBJECT_FIELD from '@salesforce/schema/Task.Subject';
import TASK_PRIORITY_FIELD from '@salesforce/schema/Task.Priority';
import TASK_STATUS_FIELD from '@salesforce/schema/Task.Status';
import TASK_ACTIVITY_DATE_FIELD from '@salesforce/schema/Task.ActivityDate';
import getTasks from '@salesforce/apex/CNT_CRM_MQL_Tasks.getTasks';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

const COLUMNS = [
    { label: 'Subject', fieldName: 'recordURL', type: 'url', sortable: true,
      typeAttributes: { label: { fieldName: TASK_SUBJECT_FIELD.fieldApiName }, target: '_blank' }
    },
    { label: 'Status', fieldName: TASK_STATUS_FIELD.fieldApiName, type: 'text', sortable: true },
    { label: 'Campaign Name', fieldName: 'campaignName', type: 'text', sortable: true },
    { label: 'Priority', fieldName: TASK_PRIORITY_FIELD.fieldApiName, type: 'text', sortable: true },
    { label: 'Date', fieldName: TASK_ACTIVITY_DATE_FIELD.fieldApiName, type: 'Date', sortable: true },
    {
        label: 'Assigned To', fieldName: 'OwnerURL', type: 'url', sortable: true,
        typeAttributes: { label: { fieldName: 'OwnerName' }, target: '_blank' }
    },
    { label: 'Triaged By', fieldName: 'MQL_Triaged_By__c', type: 'text', sortable: true }
];

export default class Lwc_crm_mql_tasks extends LightningElement {
    userId = Id;
    userFullName;
    insideSalesUserId = '';
    columns = COLUMNS;

    tasks;
    filteredTasks;
    error;

    sortedBy;
    sortDirection = 'asc';

    taskListValue = 'all_tasks';
    errorMsg = 'Unexpected error !!!';

    @wire(getRecord, { recordId: Id, fields: ['User.Name'] })
    userData({ data, error }) {
        if (data) {
            this.userFullName = data.fields.Name.value;
        }
        else if (error) {
            this.handleError(error);
        }
    }

    get taskTypeOptions() {
        return [
            { label: 'All Tasks', value: 'all_tasks' },
            { label: 'Assigned to Me', value: 'assigned_to_me' },
            { label: 'Assigned to Inside Sales', value: 'assigned_to_inside_sales' },
            { label: 'Triaged by Me', value: 'triaged_by_Me' }
        ];
    }

    @wire(getTasks)
    wireTasks({ data, error }) {
        if (data) {
            //console.log(JSON.stringify(data));
            var tempData = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
            this.tasks = tempData.tasks;
            this.insideSalesUserId = tempData.hasOwnProperty('insideSalesUserId') == true ? tempData.insideSalesUserId : null;
            if (this.tasks.length > 0) {
                this.tasks.forEach(function (task) {
                    try {
                        task['recordURL'] = '/' + task.Id;
                        task['campaignName'] = task.hasOwnProperty('Campaign_Name2__r') == true ? task.Campaign_Name2__r.Name : '';
                        task['OwnerName'] = task.Owner.Name;
                        task['OwnerURL'] = '/' + task.OwnerId;
                    } catch (e) {
                        console.log(e);
                    }
                });
                this.filteredTasks = JSON.parse(JSON.stringify(this.tasks));
            }

            //console.log(this.tasks);   
        } else if (error) {
            this.handleError(error);
        }
    }

    handleTaskListChange(event) {
        //console.log(event.detail.value);
        this.taskListValue = event.detail.value;
        this.filterTasks();
    }

    filterTasks() {
        if (this.tasks) {
            this.filteredTasks = this.tasks.filter(function (item) {
                let flag = false;
                if (this.taskListValue == 'all_tasks') {
                    flag = true;
                } else if (this.taskListValue == 'assigned_to_me') {
                    flag = (item.OwnerId == this.userId);
                } else if (this.taskListValue == 'assigned_to_inside_sales') {
                    flag = (this.insideSalesUserId && item.OwnerId == this.insideSalesUserId);
                }
                else if (this.taskListValue == 'triaged_by_Me') {
                    flag = (item.MQL_Triaged_By__c == this.userFullName)
                }
                return flag;
            }.bind(this));
        }
    }

    handleError(error) {
        var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
        this.errorMsg = err == "{}" ? 'Unexpected error !!!' : err;
        this.error = true;
        this.tasks = [];
        console.log(JSON.stringify(error));
    }
}