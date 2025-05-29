import { LightningElement, api , wire} from 'lwc';
import TASK_STATUS_FIELD from '@salesforce/schema/Task.Status';
import TASK_ACTIVITY_DATE_FIELD from '@salesforce/schema/Task.ActivityDate';
import getTaskDetails from '@salesforce/apex/CNT_CRM_Other_MQL_Tasks.getTaskDetails';

const COLUMNS = [
    { label: 'Subject', fieldName: 'TaskURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'TaskSubject' }, target: '_blank'}  
    },
    { label: 'Assigned To', fieldName: 'OwnerURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'OwnerName' }, target: '_blank'}  
    },
    { label: 'Campaign Name', fieldName: 'CampaignURL', type: 'url', sortable: true,
      typeAttributes: {label: { fieldName: 'CampaignName' }, target: '_blank'}  
    },
    { label: 'Status', fieldName: TASK_STATUS_FIELD.fieldApiName, type: 'text', sortable: true },
    { label: 'Due Date', fieldName: TASK_ACTIVITY_DATE_FIELD.fieldApiName, type: 'Date', sortable: true },

];

export default class Lwc_crm_mql_tasks_list_view extends LightningElement {
    @api recordId;
    columns = COLUMNS;

    tasks;
    filteredTasks;
    error;

    errorMsg = 'Unexpected error !!!';

    @wire(getTaskDetails, { recordId: '$recordId' })
    wireTasks({ data, error }) {
       
        if (data) {
            console.log(JSON.stringify(data));
            this.tasks = JSON.parse(JSON.stringify(data)); // as cached object is not modifiable, create new object
            this.filteredTasks = JSON.parse(JSON.stringify(this.tasks));

            if (this.tasks.length > 0) {
                this.tasks.forEach(function (task) {
                    try {
                        task['OwnerName'] = task.Owner.Name;
                        task['OwnerURL'] = "/"+ task.OwnerId;
                        task['CampaignName'] = task.hasOwnProperty('Campaign_Name2__r') == true ? task.Campaign_Name2__r.Name : '';
                        task['CampaignURL'] = task.hasOwnProperty('Campaign_Name2__c') == true ? "/"+ task.Campaign_Name2__c : '';
                        task['TaskSubject'] = task.Subject;
                        task['TaskURL'] = "/"+ task.Id;
                    } catch (e) {
                        console.log(e);
                    }
                });
                this.filteredTasks = JSON.parse(JSON.stringify(this.tasks));
            }
        } else if (error) {
            this.handleError(error);
        }
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