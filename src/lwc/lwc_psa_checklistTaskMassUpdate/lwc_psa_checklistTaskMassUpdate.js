import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getProjectTasks from '@salesforce/apex/CNT_PSA_ChecklistTaskMassUpdate.getProjectTasks';
import updateChecklistTasks from '@salesforce/apex/CNT_PSA_ChecklistTaskMassUpdate.updateChecklistTasks'
import findContactsBySearchKey from '@salesforce/apex/CNT_PSA_ChecklistTaskMassUpdate.findContactsBySearchKey';
import isUserHavingEditablePermissionSet from '@salesforce/apex/CNT_PSA_ChecklistTaskMassUpdate.isUserHavingEditablePermissionSet';
import PROJECT_TASK from '@salesforce/schema/pse__Project_Task__c';
import TYPE_FIELD from '@salesforce/schema/pse__Project_Task__c.Type__c';


const TASK_FIELDS = ['Id', 'Name', 'pse__Status__c', 'pse__Project__c', 'pse__Project__r.Name', 'Type__c', 'Resource__c', 'Resource__r.Name', 'pse__Start_Date_Time__c', 'pse__End_Date_Time__c', 'pse__Start_Date__c', 'pse__End_Date__c', 'pse__Long_Description__c', 'Service_Line__c', 'Service_Line__r.Name']

const TASKS_COLUMNS_DEFAULT = [
    { label: 'Project', fieldName: 'ProjectName', sortable: true, type: 'text' },
    { label: 'Name', fieldName: 'Name', sortable: true, type: 'text' },
    { label: 'Type', fieldName: 'Type__c', sortable: true, type: 'text' },
    { label: 'Resource', fieldName: 'ResourceName', sortable: true, type: 'text' },
    { label: 'Status', fieldName: 'pse__Status__c', sortable: true, type: 'text' },
    { label: 'Long Description', fieldName: 'pse__Long_Description__c', type: 'text' },
    // {
    //     label: 'Planned Start Date', fieldName: 'pse__Start_Date_Time__c', type: 'date', typeAttributes: {
    //         day: 'numeric', month: 'short', year: 'numeric',
    //         hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true
    //     }
    // },
    // {
    //     label: 'Planned End Date', fieldName: 'pse__End_Date_Time__c', type: 'date', typeAttributes: {
    //         day: 'numeric', month: 'short', year: 'numeric',
    //         hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true
    //     }
    // },
    { label: 'Planned Start Date', fieldName: 'pse__Start_Date__c', sortable: true, type: 'date-local' },
    { label: 'Planned End Date', fieldName: 'pse__End_Date__c', sortable: true, type: 'date-local' }
];
const PROJ_TASK_STATUS_NOT_APPLICABLE = 'Not Applicable';
const PROJ_TASK_STATUS_COMPLETE = 'Complete';
const PROJ_TASK_STATUS_CANCELLED = 'Cancelled';
const PROJ_TASK_STATUS_IN_PROGRESS = 'In Progress';
const PROJ_TASK_STATUS_NOT_STARTED = 'Not Started';

export default class Lwc_psa_checklistTaskMassUpdate extends NavigationMixin(LightningElement) {

    @track tasks = [];
    @track tasksListToShow = [];
    @track error;
    @track tasksColumns;
    @track selectedTasks = [];
    @track newStartDate = '';
    @track newEndDate = '';
    @track newStatus = null;
    @track newDescription = '';
    @track newResource = '';
    wiredTasksDataValue;
    @track userHaveEditPermissionSet = false;
    @track showModifyModal = false;
    @track showPageSpinner = false;
    @track errorMessageString = '';
    @track gotData;
    @track selectedTasksString = [];
    @track descriptionFieldPlaceholder = ''
    currentPageReference = null;
    urlStateParameters = null;
    wiredTasksDataValue = null;

    @track sortBy;
    @track sortDirection;
    resourceErrors = [];
    @track typeOptions = [];
    @track serviceLineOptions = [];
    @track selectedTypes = [];
    @track selectedServiceLines = [];
    isShowServiceLine = false;
    @track recordTypeId;

    @wire(getObjectInfo, { objectApiName: PROJECT_TASK })
    wiredObjectInfo({error, data}) {
        if (error) {
            // handle Error
        } else if (data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'RDS Project Task');
        }
    };

    //lifecycle hook
    connectedCallback() {
        this.tasksColumns = TASKS_COLUMNS_DEFAULT;
        this.selectedTypes = [];
        this.selectedServiceLines = [];
        //enabling/disabling 'Modify Tasks' button based on edit access of current user
        isUserHavingEditablePermissionSet()
            .then(response => {
                this.userHaveEditPermissionSet = response
            })
            .catch(error => {
                this.dispatchError(error, 'There was a problem getting permission set of current user');
            });
    }

    // Params from Url
    @track programId = null;
    @track rdsProjectId = '';
    @track serviceLineProjectId = '';


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.template.querySelectorAll("c-lwc_multi-select-picklist").forEach((element)=>{
                element.removeOptions();
            });
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.programId = this.urlStateParameters.c__program || null;
        this.rdsProjectId = this.urlStateParameters.c__project || null;
        this.serviceLineProjectId = this.urlStateParameters.c__serviceline || null;
        if( this.serviceLineProjectId ){
            this.isShowServiceLine = false;
        }else{
            this.isShowServiceLine = true;
        }
    }

    // Getting RDS/Service Line Project Tasks
    @wire(getProjectTasks, { rdsProjectId: "$rdsProjectId", 
                             serviceLineProjectId: "$serviceLineProjectId",
                             fieldsList: TASK_FIELDS })
    wiredTasksData(result) {
        this.wiredTasksDataValue = result;
        this.tasksListToShow = [];
        this.serviceLineOptions = [];
        const serviceLineSet = new Set();
        if (result.data) {
            this.gotData = JSON.stringify(result)
            this.tasks = result.data.map(row => {
                if (row.pse__Project__c && row.Resource__c) {
                    return { ...row, ProjectName: row.pse__Project__r.Name, ResourceName: row.Resource__r.Name }
                } else if (row.pse__Project__c) {
                    return { ...row, ProjectName: row.pse__Project__r.Name }
                } else if (row.Resource__c) {
                    return { ...row, ResourceName: row.Resource__r.Name }
                } else {
                    return { ...row, ProjectName: '', ResourceName: '' }
                }
            })
            this.tasksListToShow = [...this.tasks];
            //getting service line options
            result.data.forEach(element => {
                if (element.Service_Line__c) {
                    if (!serviceLineSet.has(element.Service_Line__r.Name)) {
                        serviceLineSet.add(element.Service_Line__r.Name);
                        this.serviceLineOptions.push({ label: element.Service_Line__r.Name, value: element.Service_Line__r.Name });
                    }
                }
            });
            this.error = '';
            
        } else if (result.error) {
            this.error = result.error;
            this.data = [];
        }
    }

    // assigning selected rows
    tasksSelected(event) {
        this.selectedTasks = event.detail.selectedRows;
        //to be removed
        this.selectedTasksString = JSON.stringify(event.detail.selectedRows)
    }

    //disbale/enable modify button
    get modifyButtonDisabled() {
        if (this.selectedTasks.length > 0) {
            return false;
        }
        return true;
    }

    //disbale/enable apply button
    get applyButtonDisabled() {
        if (this.newStatus === PROJ_TASK_STATUS_NOT_APPLICABLE) {
            if (!this.newDescription) {
                return true;
            }
        } else if (!this.newStatus && !this.newStartDate && !this.newEndDate && !this.newDescription && !this.newResource) {
            return true;
        }
        return false;
    }


    //handling button click
    handleClick(event) {
        
        let buttonName = event.target.name;
        if (buttonName === 'GO_BACK_TO_RECORD_PAGE') {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.serviceLineProjectId || this.rdsProjectId || this.programId,
                    actionName: 'view'
                }
            });
        } else if (buttonName === 'OPEN_MODIFY_TASKS') {
            this.showModifyModal = true;
        } else if (buttonName === 'MODIFY_TASKS_CANCEL') {
            this.showModifyModal = false;
            this.newStartDate = '';
            this.newEndDate = '';
            this.newStatus = null;
            this.newDescription = '';
            this.newResource = '';
        } else if (buttonName === 'MODIFY_TASKS_APPLY') {
            let startDate = (this.newStartDate != null) ? this.newStartDate : null;
            let endDate = (this.newEndDate != null) ? this.newEndDate : null;
            let status = (this.newStatus != null) ? this.newStatus : null;
            let description = (this.newDescription != null) ? this.newDescription : null;
            let resource = (this.newResource != null) ? this.newResource : null;
            let updatedTasksList = [];
            for (let task of this.selectedTasks) {
                if (task.Id) {
                    updatedTasksList.push(task.Id);
                }
            }
            this.modifyModalClosed();
            this.showPageSpinner = true;
            updateChecklistTasks({ updatedTaskList: this.selectedTasks, startDate: startDate, endDate: endDate, status: status, description: description, resourceId: resource })
                .then(response => {
                    if (response === 'success') {
                        this.dispatchSuccess('Tasks updated successfully', 'Success');
                        this.showPageSpinner = false;
                        this.newStartDate = '';
                        this.newEndDate = '';
                        this.newStatus = null;
                        this.newDescription = '';
                        this.newResource = '';
                        refreshApex(this.wiredTasksDataValue);
                    } else {
                        this.showPageSpinner = false;
                        this.errorMessageString = this.getErrorMessageString(response);
                        this.dispatchError(this.errorMessageString, 'Error Updating Tasks ');
                    }
                })
                .catch(error => {
                    this.showPageSpinner = false;
                    this.errorMessageString = this.getErrorMessageString(error);
                    this.dispatchError(this.errorMessageString, 'Error Updating Tasks ');
                });
        }
    }

    //get error message
    getErrorMessageString(error) {
        let errorString = '';
        try {
            Object.keys(error["body"]["fieldErrors"]).forEach(function (key) {
                errorString = errorString + error["body"]["fieldErrors"][key][0].message + '. ';
            });
        } catch (err) {
            errorString = '';
            return errorString;
        }
        return errorString;
    }

    //toggle modify modal
    modifyModalClosed() {
        this.showModifyModal = false;
        this.newStartDate = '';
        this.newEndDate = '';
        this.newStatus = null;
        this.newResource = '';
        this.newDescription = '';
    }

    //assign selected ne date value from modal
    newDateApplied(event) {
        if (event.target.name === 'NEW_START_DATE') {
            this.newStartDate = event.detail.value;
            if (this.newEndDate !== '' && this.newStartDate > this.newEndDate) {
                this.newEndDate = this.newStartDate;
            }
        }
        if (event.target.name === 'NEW_END_DATE') {
            this.newEndDate = event.detail.value;
            if (this.newStartDate !== '' && this.newEndDate < this.newStartDate) {
                this.newStartDate = this.newEndDate;
            }
        }
    }

    //assigning selected new status from modal
    get options() {
        return [
            { label: '--None--', value: null },
            { label: PROJ_TASK_STATUS_NOT_APPLICABLE, value: PROJ_TASK_STATUS_NOT_APPLICABLE },
            { label: PROJ_TASK_STATUS_NOT_STARTED, value: PROJ_TASK_STATUS_NOT_STARTED },
            { label: PROJ_TASK_STATUS_IN_PROGRESS, value: PROJ_TASK_STATUS_IN_PROGRESS },
            { label: PROJ_TASK_STATUS_COMPLETE, value: PROJ_TASK_STATUS_COMPLETE },
            { label: PROJ_TASK_STATUS_CANCELLED, value: PROJ_TASK_STATUS_CANCELLED }
        ];
    }


    //assign on change of modal inputs
    handleStatusChange(event) {
        this.newStatus = event.detail.value;
        if (event.detail.value == PROJ_TASK_STATUS_NOT_APPLICABLE) {
            this.descriptionFieldPlaceholder = `Please enter a reason why these task(s) are ${PROJ_TASK_STATUS_NOT_APPLICABLE}`;
        } else {
            this.descriptionFieldPlaceholder = '';
        }
    }

    handleDescriptionChange(event) {
        this.newDescription = event.detail.value;
    }

    //toast messages
    dispatchError(errorString, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorString,
                variant: 'error',
                mode: 'pester'
            })
        );
    }

    dispatchSuccess(message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'success'
            })
        );
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.tasksListToShow));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.tasksListToShow = [...parseData];
    }

    handleResourceLookupChange(event) {
        event.detail.value = (event.detail.length > 0) ? event.detail : [null];
        this.newResource = event.detail.value[0];
    }

    handleResourceSearch(event) {
        if (this.resourceErrors.length > 0) {
            this.resourceErrors = [];
        }
        const target = event.target;
        findContactsBySearchKey({ searchKey: event.detail.searchTerm })
            .then(results => {
                target.setSearchResults(results);
            })
            .catch(error => {
                this.resourceErrors = [error]
                this.dispatchError(this.resourceErrors, 'Error searching resource.');
            });
    }

    get optionsType() {
        return [
            { label: PROJ_TASK_STATUS_NOT_APPLICABLE, value: PROJ_TASK_STATUS_NOT_APPLICABLE },
            { label: PROJ_TASK_STATUS_NOT_STARTED, value: PROJ_TASK_STATUS_NOT_STARTED },
            { label: PROJ_TASK_STATUS_IN_PROGRESS, value: PROJ_TASK_STATUS_IN_PROGRESS },
            { label: PROJ_TASK_STATUS_COMPLETE, value: PROJ_TASK_STATUS_COMPLETE },
            { label: PROJ_TASK_STATUS_CANCELLED, value: PROJ_TASK_STATUS_CANCELLED }
        ];
    }

    @wire(getObjectInfo, { objectApiName: PROJECT_TASK })
    getProjectTask;

    /**
     * Method used to get picklist values of Type field of Project Task Object
     */
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId',
                               fieldApiName: TYPE_FIELD })
    setTypePicklist({ data, error }) {
        if (data) {
            this.typeOptions = [...data.values];
        } else if (error) {
            this.showToast('Error Occured!', JSON.stringify(error), 'error');
        }
    }

    handleTypeSelection(event) {
        this.selectedTypes = [];
        let selectedTypeList = []
        event.detail.forEach(element => {
            selectedTypeList.push(element.label)
        });
        this.selectedTypes = [...selectedTypeList];
        this.filterProjectTasks();
    }

    handleServiceLineNameSelection(event) {
        this.selectedServiceLines = [];
        let selectedServiceLinesList = [];
        event.detail.forEach(element => {
            selectedServiceLinesList.push(element.label)
        });
        this.selectedServiceLines = [...selectedServiceLinesList];
        this.filterProjectTasks();
    }

    filterProjectTasks() {
        this.tasksListToShow = [];
        if ((this.selectedTypes === null || this.selectedTypes.length === 0) && (this.selectedServiceLines === null || this.selectedServiceLines.length === 0)) {
            //no filter applied
            this.tasksListToShow = [...this.tasks];
        } else {
            //any of the filter is applied
            const filteredProjectTasksList = [];
            this.tasks.forEach(task => {
                if( this.isShowServiceLine ){
                    if (((this.selectedTypes != null && this.selectedTypes.length > 0) ? this.selectedTypes.includes(task.Type__c) : true)
                        && ((this.selectedServiceLines != null && this.selectedServiceLines.length > 0) ? this.selectedServiceLines.includes(task.Service_Line__r.Name) : true)) {
                        filteredProjectTasksList.push(task);
                    }
                }else{
                    if ((this.selectedTypes != null && this.selectedTypes.length > 0) ? this.selectedTypes.includes(task.Type__c) : true) {
                        filteredProjectTasksList.push(task);
                    }
                }
                
            });

            if (filteredProjectTasksList != null && filteredProjectTasksList.length > 0) {
                this.tasksListToShow = [...filteredProjectTasksList];
            }
        }
    }
}
