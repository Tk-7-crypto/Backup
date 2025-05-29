import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

import PROJECT_TASK_OBJECT from '@salesforce/schema/pse__Project_Task__c';
import PROJECT_TASK_ASSIGNMENT_OBJECT from '@salesforce/schema/pse__Project_Task_Assignment__c';
import { getUrlVars } from 'c/urlVars';

import getProjectTasksByMilestone from '@salesforce/apex/CNT_PSA_ManageDeliverables.getProjectTasksByMilestone';
import getTaskAssignmentsByMilestone from '@salesforce/apex/CNT_PSA_ManageDeliverables.getTaskAssignmentsByMilestone';
import getProjectsByProgram from '@salesforce/apex/CNT_PSA_ManageDeliverables.getProjectsByProgram';
import getMilestonesByProject from '@salesforce/apex/CNT_PSA_ManageDeliverables.getMilestonesByProject';
import getLightningFilterByProgram from '@salesforce/apex/CNT_PSA_ManageDeliverables.getLightningFilterByProgram';
import createLightningFilter from '@salesforce/apex/CNT_PSA_ManageDeliverables.createLightningFilter';

import getServiceLineDeliverableFields from '@salesforce/apex/CNT_PSA_ManageDeliverables.getServiceLineDeliverableFields';

import checkDateOffset from '@salesforce/apex/CNT_PSA_ManageDeliverables.checkDateOffset';
import getGeneralDeliverableFields from '@salesforce/apex/CNT_PSA_ManageDeliverables.getGeneralDeliverableFields';
import getBillingDeliverableFields from '@salesforce/apex/CNT_PSA_ManageDeliverables.getBillingDeliverableFields';
import getGeneralTaskFields from '@salesforce/apex/CNT_PSA_ManageDeliverables.getGeneralTaskFields';
import getServiceLineTaskFields from '@salesforce/apex/CNT_PSA_ManageDeliverables.getServiceLineTaskFields';
import getServiceLineInfo from '@salesforce/apex/CNT_PSA_ManageDeliverables.getServiceLineInfo';
import globalFlexipageStyles from '@salesforce/resourceUrl/PSAGlobalFlexipageStyles';

import getDrugDependentOptions from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getDrugDependentOptions'
import getProjectDependentOptions from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getProjectDependentOptions'
import apexSearch from '@salesforce/apex/CNT_PSA_filteredDetailsTab.searchDrug';

import getValidMetricsForService from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getValidMetricsForService';
import createMisses from '@salesforce/apex/CNT_PSA_filteredDetailsTab.createMisses';
import { buildErrorMessage, ShowToast } from 'c/utils'
import getExistingMisses from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getExistingMisses';

import getFieldIsEditableForBillingSection from '@salesforce/apex/CNT_PSA_ManageDeliverables.getFieldIsEditableForBillingSection';


//const DELIVERABLE_TYPE = 'Deliverable';
const TASK_TYPE = 'Deliverable Task';
const DELIVERABLE_TYPE = 'Deliverable';
const ESC_KEY = 27;
const MILESTONE_FIELDS = [
    'pse__Milestone__c.Name',
    'pse__Milestone__c.pse__Project__c',
    'pse__Milestone__c.pse__Project__r.pse__Is_Billable__c',
    'pse__Milestone__c.pse__Project__r.pse__Parent_Project__c',
    'pse__Milestone__c.pse__Project__r.Program__c',
    'pse__Milestone__c.Service_Code__c',
    'pse__Milestone__c.Service__c',
    'pse__Milestone__c.Service__r.Service_Line__c',
    'pse__Milestone__c.Service_Line__c',
    'pse__Milestone__c.Service_Line__r.Service_Line_Code__c',
    'pse__Milestone__c.Budget_Hours__c',
    'pse__Milestone__c.Start_Date__c',
    'pse__Milestone__c.End_Date__c'
];
const PRESET_DELIVERABLE_FIELDS = [
    'Program__c',
    'Parent_Project__c',
    'pse__Project__c',
    'pse__Milestone__c',
    'Service_Line__c',
    'Service__c',
    'Type__c'
];
const PRESET_DELIVERABLE_CLONE_FIELDS = [
    'Target__c'
];
const DELIVERABLE_EXTRA_FIELDS = [
    'Id',
    'Name',
    'pse__Parent_Task__c',
    'Parent_Project__c',
    'pse__Project__c',
    'Program__c',
    'Service__c',
    'Service__r.Name',
    'Service_Line__c',
    'pse__Status__c',
    'Type__c',
    'pse__Milestone__c',
    'Start_Date_Planned__c',
    'End_Date_Planned__c',
    'Start_Date_Actual__c',
    'End_Date_Actual__c',
    'pse__Start_Date__c',
    'pse__End_Date__c',
    'pse__Actual_End_Date__c',
    'Resource__r.Name',
    'Target__r.Name',
    'Drug__c',
    'Drug__r.Name',
    'pse__Assigned_Resources__c',
    'Template_Task_ID__c'
];
const PRESET_TASK_FIELDS = [
    'Service_Line__c',
    'Service__c'
];
const TASK_ASSIGNMENT_FIELDS = [
    'Id',
    'Name',
    'pse__Resource__c',
    'pse__Resource__r.Name',
    'pse__Resource_Role__c',
    'Resource_Location__c',
    'Is_Primary__c',
    'pse__Start_Date__c',
    'pse__End_Date__c',
    'pse__Project_Task__c'
];

const deliverableRowActions = [
    { label: 'Open Detail', name: 'open_deliverable'},
    { label: 'Edit', name: 'edit_deliverable' },
    { label: 'Clone', name: 'clone_deliverable' },
    { label: 'Delete', name: 'delete_deliverable' }
];
const deliverableRowActionsReadOnly = [
    { label: 'Edit', name: 'edit_deliverable' }
];

const DEFAULT_DELIVERABLE_UNIT_COLUMNS = [
    {type: 'action', typeAttributes: {rowActions: deliverableRowActions, menuAlignment: 'auto'}, fieldName: 'action'},
    {label: 'Name', fieldName: 'Name', type: 'text', initialWidth: 375},
    {label: 'Drug', fieldName: 'linkDrug', type: 'url', initialWidth: 375, typeAttributes: { label: {fieldName: 'Drug__r:Name'}, target: '_blank'}},
    {label: 'Target', fieldName: 'linkTarget', type: 'url', initialWidth: 375, typeAttributes: { label: {fieldName: 'Target__r:Name'}, target: '_blank'}},
    {label: 'Status', fieldName: 'pse__Status__c', type: 'text'},
    {label: 'Resource', fieldName: 'linkResource', type: 'url', typeAttributes: { label: {fieldName: 'Resource__r:Name'}, target: '_blank'}},
    {label: 'Start Planned', fieldName: 'pse__Start_Date__c', type: 'date-local', fixedWidth: 122, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Planned', fieldName: 'pse__End_Date__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Actual', fieldName: 'pse__Actual_End_Date__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}}
];
const READONLY_DELIVERABLE_UNIT_COLUMNS = [
    {type: 'action', typeAttributes: {rowActions: deliverableRowActionsReadOnly, menuAlignment: 'auto'}, fieldName: 'action'},
    {label: 'Name', fieldName: 'Name', type: 'text', initialWidth: 375},
    {label: 'Drug', fieldName: 'linkDrug', type: 'url', initialWidth: 375, typeAttributes: { label: {fieldName: 'Drug__r:Name'}, target: '_blank'}},
    {label: 'Target', fieldName: 'linkTarget', type: 'url', initialWidth: 375, typeAttributes: { label: {fieldName: 'Target__r:Name'}, target: '_blank'}},
    {label: 'Status', fieldName: 'pse__Status__c', type: 'text'},
    {label: 'Resource', fieldName: 'linkResource', type: 'url', typeAttributes: { label: {fieldName: 'Resource__r:Name'}, target: '_blank'}},
    {label: 'Start Planned', fieldName: 'pse__Start_Date__c', type: 'date-local', fixedWidth: 122, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Planned', fieldName: 'pse__End_Date__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Actual', fieldName: 'pse__Actual_End_Date__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}}
];
const DEFAULT_PROJECT_TASK_COLUMNS = [
    {label: 'Task Description', fieldName: 'linkName', type: 'url', initialWidth: 330, typeAttributes: { label: {fieldName: 'Name'}, target: '_blank'}},
    {label: 'Start Planned', fieldName: 'pse__Start_Date__c', type: 'date-local', fixedWidth: 100, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Planned', fieldName: 'pse__End_Date__c', type: 'date-local', fixedWidth: 100, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'Status', fieldName: 'pse__Status__c', type: 'text'},
    {label: 'Primary Resource', fieldName: 'linkResource', type: 'url', typeAttributes: { label: {fieldName: 'Resource__r:Name'}, target: '_blank'}},
    {label: 'Assignees', fieldName: 'pse__Assigned_Resources__c', type: 'text', initialWidth: 212}
];
const DEFAULT_DELIVERABLE_UNIT_COLUMNS_PVA = [
    {type: 'action', typeAttributes: {rowActions: deliverableRowActions, menuAlignment: 'auto'}, fieldName: 'action'},
    {label: 'Name', fieldName: 'Name', type: 'text', initialWidth: 375},
    {label: 'Target', fieldName: 'linkTarget', type: 'url', initialWidth: 375, typeAttributes: { label: {fieldName: 'Target__r:Name'}, target: '_blank'}},
    {label: 'Status', fieldName: 'pse__Status__c', type: 'text'},
    {label: 'Resource', fieldName: 'linkResource', type: 'url', typeAttributes: { label: {fieldName: 'Resource__r:Name'}, target: '_blank'}},
    {label: 'Start Planned', fieldName: 'Start_Date_Planned__c', type: 'date-local', fixedWidth: 122, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Planned', fieldName: 'End_Date_Planned__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Actual', fieldName: 'End_Date_Actual__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}}
];
const READONLY_DELIVERABLE_UNIT_COLUMNS_PVA = [
    {type: 'action', typeAttributes: {rowActions: deliverableRowActionsReadOnly, menuAlignment: 'auto'}, fieldName: 'action'},
    {label: 'Name', fieldName: 'Name', type: 'text', initialWidth: 375},
    {label: 'Target', fieldName: 'linkTarget', type: 'url', initialWidth: 375, typeAttributes: { label: {fieldName: 'Target__r:Name'}, target: '_blank'}},
    {label: 'Status', fieldName: 'pse__Status__c', type: 'text'},
    {label: 'Resource', fieldName: 'linkResource', type: 'url', typeAttributes: { label: {fieldName: 'Resource__r:Name'}, target: '_blank'}},
    {label: 'Start Planned', fieldName: 'Start_Date_Planned__c', type: 'date-local', fixedWidth: 122, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Planned', fieldName: 'End_Date_Planned__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Actual', fieldName: 'End_Date_Actual__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}}
];
const DEFAULT_PROJECT_TASK_COLUMNS_PVA = [
    {label: 'Task Description', fieldName: 'linkName', type: 'url', initialWidth: 330, typeAttributes: { label: {fieldName: 'Name'}, target: '_blank'}},
    {label: 'Start Planned', fieldName: 'Start_Date_Planned__c', type: 'date-local', fixedWidth: 100, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Planned', fieldName: 'End_Date_Planned__c', type: 'date-local', fixedWidth: 100, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'Status', fieldName: 'pse__Status__c', type: 'text'},
    {label: 'Primary Resource', fieldName: 'linkResource', type: 'url', typeAttributes: { label: {fieldName: 'Resource__r:Name'}, target: '_blank'}},
    {label: 'Assignees', fieldName: 'pse__Assigned_Resources__c', type: 'text', initialWidth: 212}
];
const DEFAULT_TASK_ASSIGNMENT_COLUMNS = [
    {label: 'Resource', fieldName: 'linkResource', type: 'url', typeAttributes: { label: {fieldName: 'pse__Resource__r:Name'}, target: '_blank'}},
    {label: 'Role', fieldName: 'pse__Resource_Role__c', type: 'text'},
    {label: 'Primary', fieldName: 'Is_Primary__c', type: 'boolean'},
    {label: 'Location', fieldName: 'Resource_Location__c', type: 'text'},
    {label: 'Planned Start', fieldName: 'pse__Start_Date__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'Planned End', fieldName: 'pse__End_Date__c', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}}
];

const DEFAULT_PROJECT_COLUMNS = [
    {label: 'Project', fieldName: 'Name', type: 'text', initialWidth: 375},
    {label: 'Stage', fieldName: 'Stage', type: 'text'},
    {label: 'Start Date', fieldName: 'Start Date', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'End Date', fieldName: 'End Date', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}}
]

const DEFAULT_MILESTONE_COLUMNS = [
    {label: 'Milestone', fieldName: 'Name', type: 'text', initialWidth: 250},
    {label: 'Project', fieldName: 'Project', type: 'text', initialWidth: 250},
    {label: 'Target Date', fieldName: 'Target Date', type: 'date-local', fixedWidth: 120, typeAttributes: {month: '2-digit', day: '2-digit'}},
    {label: 'Status', fieldName: 'Status', type: 'text'}
]

const DEFAULT_STATUS = {label: 'None', value: ''};

const makeDateString = function(date){
    return date.toISOString();
}

export default class Lwc_psa_manageDeliverables extends NavigationMixin(LightningElement) {
    @api isReadOnly; // set in app page builder!

    //Non-reactive properties
    ICON_CLOSE = 'utility:close';
    TARGET_LABEL = 'Target';
    TARGET_FIELD_NAME = 'Target__c';
    TASK_TYPE = TASK_TYPE;
    serviceLineName;
    serviceLineId;
    serviceId;
    serviceCode;
    serviceLineCode;
    filtersLoaded = false;
    earliestStartDate;
    latestEndDate;
    openEditorAfterLoad = false;
    openAddTaskAfterLoad = false;
    hasLoadedDeliverableFromUrl = false;
    clientNoficationDate;
    draftDueDate;
    endDateTime;
    usePackageDates = true;

    @track projectColumns = DEFAULT_PROJECT_COLUMNS;
    @track milestoneColumns = DEFAULT_MILESTONE_COLUMNS;
    @track selectedProject;
    @track deliverableUnitColumns = DEFAULT_DELIVERABLE_UNIT_COLUMNS;
    @track projectTaskColumns = DEFAULT_PROJECT_TASK_COLUMNS;
    @track taskAssignmentColumns = DEFAULT_TASK_ASSIGNMENT_COLUMNS;
    @track displayedDeliverables = [];
    @track filteredDeliverables = [];
    @track unfilteredDeliverables = [];
    @track taskAssignmentsByTaskId;
    @track selectedTasks = [];
    @track selectedTaskAssignments = [];
    @track editedRow;
    @track editedTask;
    @track editedTasks = [];
    @track editedTaskAssignment;
    @track editedTaskAssignments = [];
    @track parentTaskId;
    @track projectId;
    @track parentProjectId;
    @track programId = getUrlVars().c__program;
    @track projectBillable;
    @track milestoneId = getUrlVars().c__milestone;
    @track preselectedDeliverableId = getUrlVars().c__deliverable;
    @track targetId = getUrlVars().c__target;
    @track addDeliverableMode = (getUrlVars().c__add_deliverable === "true");
    @track milestoneName;
    @track milestoneBudgetedHours;
    @track defaultDeliverableUnitValues = {};
    @track generalDeliverableFields = [];
    @track generalTaskFields = [];
    @track serviceLineDeliverableFields = [];
    @track serviceLineTaskFields = [];
    @track billingDeliverableFields = [];
    @track selectedTarget;
    @track filterByServiceServices = [];
    @track selectedServices = [];
    @track filterByStatusStatuses = [DEFAULT_STATUS];
    @track selectedStatuses = [];
    @track filterStartDate;
    @track filterEndDate;
    @track filterVisibleCount = 0;
    @track filterHiddenCount = 0;
    @track defaultDeliverableStartDate = new Date();
    @track newDeliverableTaskRecordTypeId;
    @track newTaskRecordTypeId;
    @track newTaskAssignmentRecordTypeId;
    @track lightningFilterId;

    @track projectsByProgram = [];
    @track milestonesByProject = [];
    //UI Element visibility controls
    @track addDeliverableDialog = false;

    @track addFromTarget = false;
    @track selectMilestoneDialog = false;
    @track addTaskDialog = false;
    @track cloneDeliverableDialog = false;
    @track editDeliverableDialog = false;
    @track confirmDeleteDeliverableDialog = false;
    @track confirmDeleteTaskDialog = false;
    @track editTaskDialog = false;
    @track editTaskAssignmentsDialog = false;
    @track addTaskAssignmentDialog = false;
    @track changeTaskAssignmentDialog = false;
    @track viewTasksDialog = false;
    @track viewFilters = false;
    @track viewServiceFilter = false;
    @track showPageSpinner = true;
    @track showModalSpinner = false;
    @track activeSections = ['general'];
    @track showTestModal = false;
    showMetricsModal = false;
    activeRecordForMisses;
    existingMisses = [];
    @track newlyCreatedDeliverableId;
    drugErrors = [];

    @track modalButtonStatus = {
        addDeliverable: false,
        editDeliverable: false,
        cloneDeliverable: false,
        deleteDeliverable: false,
        deleteTask: false,
        addTask: false,
        editTask: false,
        metrics: false
    }
    @track state = {
        adding: false,
        saving: false,
        cloning: false,
        deleting: false,
        addingTask: false,
        savingTask: false,
        busy: false,
        metrics: false
    }

    @track pagination = {
        current: 1,
        previous: null,
        next: null,
        pageSize: 50,
        pageCount: 1
    }
    @track disableBillingSectionField = true;
    
    @track filterResource = {
        options: [{ label: '--None--', value: null }],
        selected: null
    }

    //Lifecycle hooks
    connectedCallback() {
        if(this.isReadOnly) {
            this.deliverableUnitColumns = READONLY_DELIVERABLE_UNIT_COLUMNS;
        }

        Promise.all([
            loadStyle(this, globalFlexipageStyles + '/PSAGlobalFlexipageStyles.css'),
        ]);

        if (this.targetId != null){
            this.selectedTarget = this.targetId;
            this.addFromTarget = true;
            this.getProjectsForProgram();
        }
    }

    //@wire properties and methods
    // @wire(getProjectTasksByMilestone, { milestoneId: getUrlVars().c__milestone, additionalFields: DELIVERABLE_EXTRA_FIELDS})
    @wire(getLightningFilterByProgram, {programId: '$programId'})
    wiredLightningFilter(value){

        let handleFilter = (value) => {
            let {error, data} = value;
            if(data){
                console.log('Got lightning filter: ', data);
                this.lightningFilterId = data.Id;
            }
            if(error){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading lightning filters: ',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            }
        }
        handleFilter = handleFilter.bind(this);

        if(value.data == null){
            createLightningFilter({programId: this.programId})
            .then(result => {
                handleFilter({data: result});
            })
            .catch(error => {
                handleFilter({error: error});
            });
        } else {
            handleFilter(value);
        }

    }

    @wire(getProjectTasksByMilestone, { milestoneId: '$milestoneId', additionalFields: DELIVERABLE_EXTRA_FIELDS })
    wiredTaskList(value){
        this.wiredTaskListValue = value;
        let {error, data} = value;
        if(data){
            //Data pulled down is read-only and must be copied before it can be formatted for display
            let taskCopies = [];
            let tasksByParent = {};
            let servicesById = {};
            let statusesByStatus = {};
            let deliverables = [];
            let deliverablesById = {};
            for(let task of data){
                let taskCopy = {...task};
                for(let field in taskCopy){
                    if(typeof taskCopy[field] === 'object' && Object.prototype.toString.call(taskCopy[field]) === '[object Object]'){
                        this.mapNestedFields(taskCopy, field);
                    }
                }
                taskCopy.linkName = '/'+taskCopy.Id;
                if(typeof taskCopy.Target__c != 'undefined') {
                    taskCopy.linkTarget = '/'+taskCopy.Target__c;
                }
                if(typeof taskCopy.Drug__c != 'undefined') {
                    taskCopy.linkDrug = '/'+taskCopy.Drug__c;
                }
                if(typeof taskCopy.Resource__c != 'undefined') {
                    taskCopy.linkResource = '/'+taskCopy.Resource__c;
                }
                taskCopies.push(taskCopy);
                if(taskCopy.Type__c === 'Deliverable'){
                    deliverables.push(taskCopy);
                }
                if(typeof taskCopy.pse__Parent_Task__c != 'undefined') {
                    if(typeof tasksByParent[taskCopy.pse__Parent_Task__c] === 'undefined'){
                        tasksByParent[taskCopy.pse__Parent_Task__c] = [];
                    }
                    tasksByParent[taskCopy.pse__Parent_Task__c].push(taskCopy);
                }
                if( task.Type__c === 'Deliverable' &&
                    typeof task.Service__c != 'undefined' &&
                    task.Service__c &&
                    typeof servicesById[task.Service__c] == 'undefined' )
                {
                    servicesById[task.Service__c] = {label: task.Service__r.Name, value: task.Service__c};
                }
                if( task.Type__c === 'Deliverable' &&
                    typeof task.pse__Status__c != 'undefined' &&
                    task.pse__Status__c &&
                    typeof statusesByStatus[task.pse__Status__c] == 'undefined' )
                {
                    statusesByStatus[task.pse__Status__c] = {label: task.pse__Status__c, value: task.pse__Status__c};
                }
                let startDate = (this.usePackageDates) ? task.pse__Start_Date__c : task.Start_Date_Planned__c;
                if(typeof this.earliestStartDate === 'undefined' || this.earliestStartDate > startDate) {
                    this.earliestStartDate = startDate;
                }
                let endDate = (this.usePackageDates) ? task.pse__End_Date__c : task.End_Date_Planned__c;
                if(typeof this.latestEndDate === 'undefined' || this.latestEndDate < endDate) {
                    this.latestEndDate = endDate;
                }

                if(this.hasLoadedDeliverableFromUrl == false && typeof this.preselectedDeliverableId !== 'undefined' && this.preselectedDeliverableId == task.Id){
                    console.log('Loading deliverable '+this.preselectedDeliverableId);
                    this.hasLoadedDeliverableFromUrl = true;
                    this.openEditorAfterLoad = true;
                    this.editedRow = task;
                }

            }
            //Set up task hierarchies
            for(let parent of taskCopies){
                if(typeof tasksByParent[parent.Id] != 'undefined'){
                    parent._children = tasksByParent[parent.Id];
                    parent.children = tasksByParent[parent.Id];
                }
            }
            //Set up filters
            this.filterByServiceServices = Object.values(servicesById);
            this.filterByStatusStatuses = Object.values(statusesByStatus);
            this.filterByStatusStatuses.push(DEFAULT_STATUS);
            if(this.filtersLoaded === false){
                this.filtersLoaded = true;
                this.selectedServices = Object.keys(servicesById);
                this.selectedStatuses = Object.keys(statusesByStatus);
                this.selectedStatuses.push('');
                this.filterStartDate = this.earliestStartDate;
                this.filterEndDate = this.latestEndDate;
            }
            if(!this.filterStartDate || !this.filterEndDate){
                this.filterStartDate = this.earliestStartDate;
                this.filterEndDate = this.latestEndDate;
            }

            this.unfilteredDeliverables = deliverables;
            this.filteredDeliverables = this.applyFilters(deliverables);
            this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);

            //Setup resource filter
            const uniqueResourceOfDeliverables = new Map();
            for (let deliverableItem of deliverables) {
                if (!(deliverableItem.Resource__c == null || typeof deliverableItem.Resource__c == 'undefined')) {
                    uniqueResourceOfDeliverables.set(deliverableItem.Resource__r.Name, { label: deliverableItem.Resource__r.Name, value: deliverableItem.Resource__r.Name });
                }
            }
            this.filterResource.options = [{ label: '--None--', value: null }];
            for (const resource of uniqueResourceOfDeliverables.values()) {
                this.filterResource.options.push(resource);
            }

            this.refreshModals();
            this.showPageSpinner = false;
        } else if(error){
            this.showPageSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading deliverables for this milestone: ',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }

    // @wire(getTaskAssignmentsByMilestone, {milestoneId: getUrlVars().c__milestone,fields: TASK_ASSIGNMENT_FIELDS})
    @wire(getTaskAssignmentsByMilestone, { milestoneId: '$milestoneId', fields: TASK_ASSIGNMENT_FIELDS })
    wiredTaskAssignmentList(value){
        this.wiredTaskAssignmentListValue = value;
        let {error, data} = value;
        if(data){
            let taskAssignmentsByTaskId = {};
            for(let taskAssignment of data){
                let taskAssignmentCopy = {...taskAssignment};
                for(let field in taskAssignmentCopy){
                    if(typeof taskAssignmentCopy[field] === 'object' && Object.prototype.toString.call(taskAssignmentCopy[field]) === '[object Object]'){
                        this.mapNestedFields(taskAssignmentCopy, field);
                    }
                }
                if(typeof taskAssignmentCopy.pse__Resource__c != 'undefined') {
                    taskAssignmentCopy.linkResource = '/'+taskAssignmentCopy.pse__Resource__c;
                }
                if(typeof taskAssignmentsByTaskId[taskAssignmentCopy.pse__Project_Task__c] === 'undefined'){
                    taskAssignmentsByTaskId[taskAssignmentCopy.pse__Project_Task__c] = [];
                }
                taskAssignmentsByTaskId[taskAssignmentCopy.pse__Project_Task__c].push(taskAssignmentCopy);
            }
            this.taskAssignmentsByTaskId = taskAssignmentsByTaskId;
            this.editedTaskAssignments = (typeof this.editedTask != 'undefined' && this.taskAssignmentsByTaskId[this.editedTask.Id]) ? this.taskAssignmentsByTaskId[this.editedTask.Id] : [];
        } else if(error){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading project task assignments',
                    message: error.message,
                    variant: 'error'
                })
            );
        }
    }

    // @wire(getRecord, { recordId: getUrlVars().c__milestone, fields: MILESTONE_FIELDS})
    @wire(getRecord, { recordId: '$milestoneId', fields: MILESTONE_FIELDS })
    getMilestoneData(value) {
        this.wiredMilestoneValue = value;
        let { error, data } = value;
        if (typeof error != 'undefined') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading milestone',
                    message: error.message,
                    variant: 'error'
                })
            );
        } else if (typeof data != 'undefined') {
            this.milestoneName = data.fields.Name.value;
            this.defaultDeliverableStartDate = new Date(data.fields.Start_Date__c.value);
            this.milestoneBudgetedHours = data.fields.Budget_Hours__c.value;
            this.projectId = data.fields.pse__Project__c.value;
            this.parentProjectId = data.fields.pse__Project__r.value.fields.pse__Parent_Project__c.value;
            this.programId = data.fields.pse__Project__r.value.fields.Program__c.value;
            this.projectBillable = data.fields.pse__Project__r.value.fields.pse__Is_Billable__c.value;
            this.serviceLineId = data.fields.Service_Line__c.value;
            this.serviceId = data.fields.Service__c.value;
            this.serviceCode = data.fields.Service_Code__c.value;
            this.serviceLineCode = data.fields.Service_Line__r.value.fields.Service_Line_Code__c.value;
            if( this.serviceLineCode == 'PVA' ){
                this.deliverableUnitColumns = (this.isReadOnly) ? READONLY_DELIVERABLE_UNIT_COLUMNS_PVA : DEFAULT_DELIVERABLE_UNIT_COLUMNS_PVA;
                this.projectTaskColumns = DEFAULT_PROJECT_TASK_COLUMNS_PVA;
                this.usePackageDates = false;
            }
            this.updateDeliverableFields();
            this.updateServiceLineInfo();
        }
    }

    @wire(getObjectInfo, { objectApiName: PROJECT_TASK_OBJECT })
    projectTaskObjectInfo(value){
        let {error, data} = value;
        if(typeof data != 'undefined'){
            const rtis = data.recordTypeInfos;
            this.newDeliverableTaskRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'RDS Deliverable');
            this.newTaskRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'RDS Deliverable Task');
        }
    };

    @wire(getObjectInfo, { objectApiName: PROJECT_TASK_ASSIGNMENT_OBJECT })
    projectTaskAssignmentObjectInfo(value){
        let {error, data} = value;
        if(typeof data != 'undefined'){
            const rtis = data.recordTypeInfos;
            this.newTaskAssignmentRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'RDS Project Task Assignment');
        }
    };

    @wire(getExistingMisses, {deliverableId: '$activeRecordForMisses'})
    wiredGetExistingMisses(value) {
        this.wiredExistingMissesValue = value;
        let {error, data} = value;
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {
            let misses = [];
            for(let miss of data){
                misses.push(miss.Project_Metric__r.PSA_Metric__c);
            }
            this.existingMisses = misses;
        }
    }

    @wire(getFieldIsEditableForBillingSection)
    getFieldIsEditableForBillingSection(value){
        let {error, data} = value;
        this.disableBillingSectionField = data;
    };

    //COMPUTED PROPERTIES
    get taskDefaultValues(){
        return {
            'pse__Project__c': this.projectId,
            'pse__Milestone__c': this.milestoneId,
            'Type__c': TASK_TYPE,
            'Activity_Controlling_Picklist__c': this.serviceCode,
            'pse__Parent_Task__c': this.parentTaskId,
            'Service__c': this.serviceId,
            'Service_Line__c': this.serviceLineId
        }
    }
    get deliverableDefaultValues(){
        return {
            'pse__Project__c': this.projectId,
            'Parent_Project__c': this.parentProjectId,
            'Program__c': this.programId,
            'pse__Milestone__c': this.milestoneId,
            'Activity_Controlling_Picklist__c': this.serviceCode,
            'Service_Line__c': this.serviceLineId,
            'Type__c': DELIVERABLE_TYPE,
            'Billable__c': this.projectBillable,
            'Service__c': this.serviceId,
            'Budgeted_Hours__c': this.milestoneBudgetedHours,
            'pse__Start_Date_Time__c': makeDateString(this.deliverableStartDate)
        };
    }

    get deliverableAttributes(){
        return {
            'Program__c': { 'disabled': 'disabled', 'hidden': true},
            'Drug__c': {'isCustomLookup': true},
            'Parent_Project__c': { 'disabled': 'disabled', 'hidden': true},
            'pse__Project__c': { 'disabled': 'disabled', 'hidden': true},
            /*'Type__c': { 'disabled': 'disabled'},*/
            'pse__Milestone__c': { 'disabled': 'disabled'},
            'Service_Line__c': { 'disabled': 'disabled'},
            'Service__c': { 'disabled': 'disabled'},
            'Billing_Milestone__c': { 'disabled': 'disabled'},
            'Total_Billable_Amount__c': { 'disabled': 'disabled'},
            'Unit_Price__c': { 'disabled': 'disabled'},
            'Billable__c': { 'disabled': 'disabled'},
            'pse__Start_Date_Time__c': {'autocomplete': 'off', 'disabled': this.disableStartEndDates },
            'pse__End_Date_Time__c': {'autocomplete': 'off', 'disabled': this.disableStartEndDates },
            'pse__Start_Date__c': {'disabled': (this.editDeliverableDialog) ? 'disabled' : 'false'},
            'pse__End_Date__c': {'disabled': (this.editDeliverableDialog) ? 'disabled' : 'false'},
            'pse__Actual_Start_Date_Time__c': {'autocomplete': 'off', 'disabled': this.disableStartEndDates },
            'pse__Actual_End_Date_Time__c': {'autocomplete': 'off', 'disabled': this.disableStartEndDates },
            'pse__End_Date_Time__c': {'autocomplete': 'off', 'disabled': this.disableStartEndDates },
            'Activity_Controlling_Picklist__c': {'disabled': 'disabled', 'className': 'slds-hidden' },
            'Target__c': {'disabled': (this.cloneDeliverableDialog) ? 'disabled' : 'false'},
            'Billing_Hold__c': {'disabled' : this.disableBillingSectionField},
            'Exclude_from_Billing__c': {'disabled' : this.disableBillingSectionField}
        }
    }

    get taskAttributes(){
        return {
            'Service__c': {'disabled': 'disabled', 'className': 'slds-hidden'},
            'Service_Line__c': {'disabled': 'disabled', 'className': 'slds-hidden'},
            'pse__Assigned_Resources__c': {'disabled': 'disabled'},
            'Resource__c': {'disabled': 'disabled'},
            'pse__Start_Date_Time__c': {'autocomplete': 'off'},
            'Activity_Controlling_Picklist__c': {'disabled': 'disabled', 'className': 'slds-hidden' },
            'pse__End_Date_Time__c': {'autocomplete': 'off'},
        }
    }

    get deliverableStartDate(){
        let startDate = this.defaultDeliverableStartDate;
        startDate.setHours(8);
        startDate.setMinutes(0);
        startDate.setSeconds(0);
        return startDate;
    }

    get generalTaskFieldsWithData(){
        if(this.addTaskDialog){
            let taskFields = PRESET_TASK_FIELDS.concat(this.generalTaskFields);
            return this.applyDefaultValuesToFieldList(taskFields,this.taskDefaultValues, this.taskAttributes);
        }
        if(this.editTaskDialog){
            return this.applyDefaultValuesToFieldList(this.generalTaskFields,this.editedTask, this.taskAttributes);
        }
        return this.applyDefaultValuesToFieldList(this.generalTaskFields,[], this.taskAttributes);
    }

    get serviceLineTaskFieldsWithData(){
        if(this.addTaskDialog){
            return this.applyDefaultValuesToFieldList(this.serviceLineTaskFields, this.taskDefaultValues, this.taskAttributes);
        }
        if(this.editTaskDialog){
            return this.applyDefaultValuesToFieldList(this.serviceLineTaskFields, this.editedTask, this.taskAttributes);
        }
        return this.applyDefaultValuesToFieldList(this.serviceLineTaskFields, [], this.taskAttributes);
    }

    get presetDeliverableFieldsWithData(){
        if(this.editDeliverableDialog){
            return this.applyDefaultValuesToFieldList(PRESET_DELIVERABLE_FIELDS,this.editedRow, this.deliverableAttributes);
        }
        if(this.cloneDeliverableDialog){
            let clonePresets = PRESET_DELIVERABLE_FIELDS.concat(PRESET_DELIVERABLE_CLONE_FIELDS);
            return this.applyDefaultValuesToFieldList(clonePresets,this.editedRow, this.deliverableAttributes);
        }
        if(this.addDeliverableDialog){
            return this.applyDefaultValuesToFieldList(PRESET_DELIVERABLE_FIELDS,this.deliverableDefaultValues, this.deliverableAttributes);
        }
        return this.applyDefaultValuesToFieldList(PRESET_DELIVERABLE_FIELDS,[], this.deliverableAttributes);
    }

    get generalDeliverableFieldsWithData(){
        if(this.cloneDeliverableDialog || this.editDeliverableDialog){
            return this.applyDefaultValuesToFieldList(this.generalDeliverableFields,this.editedRow, this.deliverableAttributes);
        }
        if(this.addDeliverableDialog){
            return this.applyDefaultValuesToFieldList(this.generalDeliverableFields,this.deliverableDefaultValues, this.deliverableAttributes);
        }
        return this.applyDefaultValuesToFieldList(this.generalDeliverableFields,[], this.deliverableAttributes);
    }

    get billingDeliverableFieldsWithData(){
        if(this.cloneDeliverableDialog || this.editDeliverableDialog){
            return this.applyDefaultValuesToFieldList(this.billingDeliverableFields,this.editedRow, this.deliverableAttributes);
        }
        if(this.addDeliverableDialog){
            return this.applyDefaultValuesToFieldList(this.billingDeliverableFields,this.deliverableDefaultValues, this.deliverableAttributes);
        }
        return this.applyDefaultValuesToFieldList(this.billingDeliverableFields,[], this.deliverableAttributes);
    }

    get serviceLineDeliverableFieldsWithData(){
        if(this.cloneDeliverableDialog){
            return this.applyDefaultValuesToFieldList(this.serviceLineDeliverableFields,this.editedRow, this.deliverableAttributes);
        }
        if(this.addDeliverableDialog){
            return this.applyDefaultValuesToFieldList(this.serviceLineDeliverableFields,this.deliverableDefaultValues, this.deliverableAttributes);
        }
        return this.applyDefaultValuesToFieldList(this.serviceLineDeliverableFields,[], this.deliverableAttributes);
    }

    get showEditDeliverableFooter(){
        return (this.editDeliverableDialog &&
                !this.editTaskAssignmentsDialog &&
                !this.editTaskDialog &&
                !this.addTaskDialog &&
                !this.addTaskAssignmentDialog &&
                !this.changeTaskAssignmentDialog);
    }

    get showDeliverableGeneralInfo(){
        return ((this.addDeliverableDialog || this.cloneDeliverableDialog) && this.generalDeliverableFields.length > 0);
    }

    get showEditDeliverableGeneralInfo(){
        return (this.editDeliverableDialog && this.generalDeliverableFields.length && this.showEditDeliverableFooter);
    }

    get showEditDeliverableServiceLineInfo(){
        return (this.editDeliverableDialog && this.serviceLineDeliverableFields.length && this.showEditDeliverableFooter);
    }

    get showDeliverableServiceLineInfo(){
        return ((this.addDeliverableDialog || this.cloneDeliverableDialog) && this.serviceLineDeliverableFields.length);
    }

    get deliverableServiceLineInfoClass(){
        let cssClass = 'slds-section service-line-section';
        return (this.showDeliverableGeneralInfo || this.showEditDeliverableGeneralInfo) ? cssClass : cssClass+' slds-is-open';
    }

    get showDeliverableBillingInfo(){
        return ((this.addDeliverableDialog || this.cloneDeliverableDialog) && this.billingDeliverableFields.length);
    }

    get showEditDeliverableBillingInfo(){
        return (this.billingDeliverableFields.length &&
                this.showEditDeliverableFooter);
    }

    get deliverableBillingInfoClass(){
        let cssClass = 'slds-section billing-section';
        return (this.showEditDeliverableServiceLineInfo || this.showEditDeliverableGeneralInfo || this.showDeliverableGeneralInfo || this.showDeliverableServiceLineInfo) ? cssClass : cssClass+' slds-is-open';
    }

    get showEditDeliverableTasks(){
        return this.showEditDeliverableFooter;
    }

    get disableEditTask(){
       return (this.selectedTasks.length !== 1);
    }

    get disableDeleteTask(){
       return (this.selectedTasks.length === 0);
    }

    get disableAddChildTask(){
       return (this.selectedTasks.length !== 1);
    }

    get disableAddTaskAssignment(){
       return (this.selectedTasks.length !== 1);
    }

    get disableDeleteTaskAssignment(){
        return (this.selectedTaskAssignments.length !== 1);
    }

    get disableEditTaskAssignment(){
        return (this.selectedTaskAssignments.length !== 1);
    }

    get disableStartEndDates(){
        return (this.editedTasks && this.editedTasks.length > 0);
    }

    get showDataTable(){
        return (!this.addDeliverableMode);
    }

    get showHeader(){
        return (!this.addDeliverableMode);
    }

    get showCreateAndAddTask(){
        return (!this.addDeliverableMode);
    }

    get showPagination(){
        return (this.pagination.pageSize < this.filteredDeliverables.length);
    }

    get onFirstPage(){
        return this.pagination.current == 1;
    }

    get onLastPage(){
        return this.pagination.current == this.pagination.pageCount;
    }

    //METHODS
    applyDefaultValuesToFieldList(fieldList, defaults, attributes){
        let fieldsWithData = [];
        let keys = Object.keys(defaults);
        for(let field of fieldList){
            let fieldWithData = {fieldName: field, hasDefault: false};
            if(keys.includes(field)){
                fieldWithData.value = defaults[field];
                fieldWithData.hasDefault = true;
            }
            fieldsWithData.push(fieldWithData);
        }
        if(typeof attributes !== 'undefined'){
            this.applyPresetAttributesToFields(fieldsWithData, attributes);
        }

        // @@ Depedent lookup - prepare for workaround!
        this.buildFieldsDependentLookupWorkaround(fieldsWithData)
//        console.log('fieldsWithData?', fieldsWithData)
        return fieldsWithData;
    }

    applyPresetAttributesToFields(fields, attributes){
        let keys = Object.keys(attributes);
        for(let field of fields){
            let fieldName = field.fieldName;
            if(keys.includes(fieldName)){
                for(let attribute in attributes[fieldName]){
                    if(attributes[fieldName].hasOwnProperty(attribute)){
                        field[attribute] = attributes[fieldName][attribute];
                    }
                }
            }

        }
    }

    applyFilters(deliverables){
        let filteredDeliverables = [];
        for(let deliverable of deliverables){
            let startDate = ( this.usePackageDates ) ? deliverable.pse__Start_Date_Time__c : deliverable.Start_Date_Planned__c;
            let endDate = ( this.usePackageDates ) ? deliverable.pse__End_Date_Time__c : deliverable.End_Date_Planned__c;
            let status = (deliverable.pse__Status__c == null || typeof deliverable.pse__Status__c == 'undefined') ? '' : deliverable.pse__Status__c;
            let resource = (deliverable.Resource__c == null || typeof deliverable.Resource__c == 'undefined') ? '' : deliverable.Resource__r.Name;
            if( !this.selectedServices.includes(deliverable.Service__c ||
                !this.selectedStatuses.includes(status ||
                startDate < this.filterStartDate))){
                continue;
            }
            if(!this.selectedStatuses.includes(status)){
                continue;
            }
            if (this.filterResource.selected) {
                if (resource != null && resource != '' && resource != ' ') {
                    if (!this.filterResource.selected.includes(resource)) {
                        continue;
                    }
                } else {
                    continue;
                }
            }
            if(startDate > this.filterEndDate){
                continue;
            }
            if(endDate < this.filterStartDate){
                continue;
            }
            filteredDeliverables.push(deliverable);
        }
        this.filterHiddenCount = deliverables.length - filteredDeliverables.length;
        this.filterVisibleCount = filteredDeliverables.length;
        return filteredDeliverables;
    }

    applyPagination(deliverables){
        let start = (this.pagination.current - 1)*this.pagination.pageSize;
        let end = start+this.pagination.pageSize;
        this.pagination.pageCount = Math.ceil(this.filteredDeliverables.length / this.pagination.pageSize);
        this.pagination.next = (this.pagination.pageCount > this.pagination.current) ? this.pagination.current+1 : null;
        this.pagination.previous = (this.pagination.current > 1) ? this.pagination.current-1 : null;
        return deliverables.slice(start,end);
    }

    previousPage(){
        this.pagination.current -= 1;
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    nextPage(){
        this.pagination.current += 1;
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    changePage(event){
        let userInput = Number.parseInt(event.detail.value, 10);
        if(userInput < 1){
            userInput = 1;
        }
        if(userInput > this.pagination.pageCount){
            userInput = this.pagination.pageCount;
        }
        this.pagination.current = userInput;
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    firstPage(){
        this.pagination.current = 1;
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    lastPage(){
        this.pagination.current = this.pagination.pageCount;
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    mapNestedFields(targetRecord, fieldName){
        //Applies nested object fields to parent object using a : as a separator-- so they can be displayed in table columns
        for(let field in targetRecord[fieldName]){
            if(targetRecord[fieldName].hasOwnProperty(field)){
                let mappedName = fieldName + ':' + field;
                targetRecord[mappedName] = targetRecord[fieldName][field];
            }
        }
    }

    updateDeliverableFields() {
        getServiceLineDeliverableFields({serviceCode: this.serviceCode, serviceLineCode: this.serviceLineCode})
            .then(result => {
                this.serviceLineDeliverableFields = result;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading service line deliverable fields',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });

        getGeneralDeliverableFields({serviceLineCode: this.serviceLineCode})
            .then(result => {
                this.generalDeliverableFields = result;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading general deliverable fields',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });

        getBillingDeliverableFields({serviceLineCode: this.serviceLineCode})
            .then(result => {
                this.billingDeliverableFields = result;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading billing deliverable fields',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });

        getServiceLineTaskFields({serviceLineId: this.serviceLineId})
            .then(result => {
                this.serviceLineTaskFields = result;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading service line deliverable fields',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });

        getGeneralTaskFields({serviceLineCode: this.serviceLineCode})
            .then(result => {
                this.generalTaskFields = result;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading general task fields',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });

    }

    getMilestonseForProject(){
        getMilestonesByProject({projectId: this.selectedProject})
            .then(result => {
                let msList = [];
                for(let ms of result){
                    msList.push({label: ms.Name, value: ms.Id, Id: ms.Id, 'Target Date': ms.pse__Target_Date__c,
                                Status: ms.pse__Status__c, Project: ms.pse__Project__r.Name, Name: ms.Name});
                }
                this.milestonesByProject = msList;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading project milestones',
                        message: error.message,
                        variant: 'error'
                    })
                );
            })
    }

    checkDateOffset(){
        checkDateOffset({serviceLineCode: this.serviceLineCode, serviceCode: this.serviceCode, programId: this.programId, clientNotificationDate:
        this.clientNoficationDate, endDate: this.endDateTime, draftDueDate: this.draftDueDate})
            .then(result => {
                console.log(result);
                console.log(result.Draft_Due_Date__c);
                console.log(result.End_Date_Planned__c);
                let formType = null;
                if (this.addDeliverableDialog){
                    formType = "add";
                }else if (this.editDeliverableDialog){
                    formType = "edit";
                }else if (this.cloneDeliverableDialog){
                    formType = "clone";
                }
                if (formType){
                    if (result.Draft_Due_Date__c){
                        let queryString = "[data-id-".concat(formType, "='Draft_Due_Date__c']");
                        if (this.template.querySelector(queryString)){
                            this.template.querySelector(queryString).value = result.Draft_Due_Date__c;
                        }
                    }
                    if (result.End_Date_Planned__c){
                        let queryString = "[data-id-".concat(formType, "='End_Date_Planned__c']");
                        if (this.template.querySelector(queryString)){
                            this.template.querySelector(queryString).value = result.End_Date_Planned__c;
                        }
                    }
                }
                this.showModalSpinner = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading offset dates',
                        message: error.message,
                        variant: 'error'
                    })
                );
                this.showModalSpinner = false;
            })
    }

    getProjectsForProgram(){
        getProjectsByProgram({programId: this.programId})
            .then(result => {
                let projList = [];
                for(let proj of result){
                    projList.push({label: proj.Name, value: proj.Id, name: proj.Id, Id: proj.Id,
                        Name: proj.Name, Stage: proj.pse__Stage__c, 'End Date': proj.pse__End_Date__c, 'Start Date': proj.pse__Start_Date__c
                    });
                }
                this.projectsByProgram = projList;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading program projects',
                        message: error.message,
                        variant: 'error'
                    })
                );
            })
    }

    updateServiceLineInfo() {
        getServiceLineInfo({serviceLineId: this.serviceLineId})
            .then(result => {
                this.serviceLineName = result.Name;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading service line info',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }

    clearModals(){
        this.addDeliverableDialog = false;
        this.addTaskDialog = false;
        this.cloneDeliverableDialog = false;
        this.editDeliverableDialog = false;
        this.confirmDeleteDeliverableDialog = false;
        this.editTaskDialog = false;
        this.viewTasksDialog = false;
        this.editTaskAssignmentsDialog = false;
        this.addTaskAssignmentDialog = false;
        this.changeTaskAssignmentDialog = false;
        this.showPageSpinner = false;
    }

    collapseDeliverableSections(){
        let sections = this.template.querySelectorAll('lightning-record-edit-form.edit-deliverable .slds-section, .tasks-section');
        for(let section of sections){
            section.classList.remove('slds-is-open');
        }
    }

    expandDeliverableSections(){
        let sections = this.template.querySelectorAll('lightning-record-edit-form.edit-deliverable .slds-section, .tasks-section');
        for(let section of sections){
            section.classList.add('slds-is-open');
        }
    }

    expandSection(event){
        let sections = this.template.querySelectorAll('.'+event.target.name);
        for(let section of sections){
            section.classList.toggle('slds-is-open');
        }
    }

    refreshModals(){
        if(typeof this.editedRow != 'undefined'){
            for(let deliverable of this.filteredDeliverables){
                let rowId = (this.editedRow.Id) ? this.editedRow.Id : this.editedRow.id;
                if(rowId === deliverable.Id){
                    this.editedRow = deliverable;
                    this.editedTasks = deliverable.children;
                    break;
                }
            }
            if(this.openEditorAfterLoad === true){
                this.openEditorAfterLoad = false;
                this.showModalSpinner = true;
                this.editDeliverableDialog = true;
                this.parentTaskId = this.editedRow.Id;
                this.activeRecordForMisses = this.editedRow.Id;
                this.selectedTasks = [];
                this.selectedTaskAssignments = [];
            }
            if(this.openAddTaskAfterLoad){
                this.openAddTaskAfterLoad = false;
                this.modalButtonStatus.addTask = true;
                this.addTaskDialog = true;
            }
        }
    }

    //EVENT HANDLERS
    selectTask(event){
        this.selectedTasks = event.detail.selectedRows;
    }

    selectTaskAssignment(event){
        this.selectedTaskAssignments = event.detail.selectedRows;
    }

    deliverableRowAction(event){
        const action = event.detail.action;
        const row = event.detail.row;
        this.editedRow = row;
        switch (action.name){
            case 'open_deliverable':
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view'
                    }
                });
                break;
            case 'edit_deliverable':
                this.modalButtonStatus.editDeliverable = true;
                this.editedTasks = row.children;
                this.editDeliverableDialog = true;
                this.activeRecordForMisses = this.editedRow.Id;
                this.parentTaskId = row.Id;
                this.selectedTasks = [];
                this.selectedTaskAssignments = [];
                break;
            case 'clone_deliverable':
                this.modalButtonStatus.cloneDeliverable = true;
                this.showPageSpinner = true;
                let blankRecord;
                this.activeRecordForMisses = blankRecord;
                this.cloneDeliverableDialog = true;
                break;
            case 'delete_deliverable':
                this.showModalSpinner = true;
                this.confirmDeleteDeliverableDialog = true;
                break;
            case 'view_tasks':
                this.showModalSpinner = true;
                this.editedTasks = row.children;
                this.editDeliverableDialog = true;
                this.parentTaskId = row.Id;
                break;
            default:
                break;
        }
    }

    projectTaskRowAction(event){
        const action = event.detail.action;
        const task = event.detail.row;
        switch (action.name){
            case 'edit_task':
                this.editedTask = task;
                this.modalButtonStatus.editTask = true;
                this.editTaskDialog = true;
                this.collapseDeliverableSections();
                break;
            case 'add_child_task':
                this.parentTaskId = task.Id;
                this.modalButtonStatus.addTask = true;
                this.addTaskDialog = true;
                this.collapseDeliverableSections();
                break;
            case 'edit_task_assignments':
                this.editedTask = task;
                this.editedTaskAssignments = (this.taskAssignmentsByTaskId[this.editedTask.Id]) ? this.taskAssignmentsByTaskId[this.editedTask.Id] : [];
                this.editTaskAssignmentsDialog = true;
                this.collapseDeliverableSections();
                break;
            case 'delete_task':
                deleteRecord(task.Id)
                .then(result => {
                    //eslint-disable-next-line
                    console.log('task deletion for '+task.Id, result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record deleted',
                            variant: 'success'
                        })
                    );
                })
                .catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                break;
            default:
                break;
        }
    }

    taskAssignmentRowAction(event){
        const action = event.detail.action;
        const taskAssignment = event.detail.row;
        //const taskAssignment = event.detail.row;
        switch (action.name){
            case 'delete_task_assignment':
                deleteRecord(taskAssignment.Id)
                .then(result => {
                    console.log(result);
                    refreshApex(this.wiredTaskListValue);
                    refreshApex(this.wiredTaskAssignmentListValue);
                    this.editTaskAssignmentsDialog = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record deleted',
                            variant: 'success'
                        })
                    );
                })
                .catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                break;
            default:
                break;
        }
    }

    closeTestModal(){
        this.showTestModal = false;
    }

    handleClientNotificationChangeEdit(event){
        console.log("Change Value: " + event.detail.value);
        console.log("Change Fields: " + event.target.fieldName);
        if (event.target.fieldName === 'Client_Notification_Date__c'){
            if (event.detail.value){
                this.clientNoficationDate = event.detail.value;
                //get the other date fields
                let formType = null;
                if (this.addDeliverableDialog){
                    formType = 'add';
                }else if (this.editDeliverableDialog){
                    formType = 'edit';
                }else if (this.cloneDeliverableDialog){
                    formType = 'clone';
                }
                if (formType){
                    let queryString = "[data-id-".concat(formType, "='Draft_Due_Date__c']");
                    let dueDate = this.template.querySelector(queryString);
                    if(dueDate){
                        this.draftDueDate = this.template.querySelector(queryString).value;
                    }else{
                        this.draftDueDate = null;
                    }
                    queryString = "[data-id-".concat(formType, "='End_Date_Planned__c']");
                    let endDateTime = this.template.querySelector(queryString);
                    if(endDateTime){
                        this.endDateTime = this.template.querySelector(queryString).value;
                    }else{
                        this.endDateTime = null;
                    }
                }

                this.showModalSpinner = true;
                //make the call to server
                this.checkDateOffset();

            }
        }

    }

    handleClick(event){
        switch(event.target.name) {
            case 'ADD_DELIVERABLE':
                this.modalButtonStatus.addDeliverable = true;
                //eslint-disable-next-line
                console.log('Program: '+this.programId+' Project: '+this.projectId+' Milestone: '+this.milestoneId);
                //RK
                if (this.targetId != null){
                    this.selectedTarget = this.targetId;
                    this.addFromTarget = true;
                    this.getProjectsForProgram();
                }else{
                    this.addDeliverableDialog = true;
                }

                break;
            case 'RETURN_TO_SERVICE':
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        recordId: getUrlVars().c__milestone,
                        actionName: 'view'
                    }
                });
                break;
            case 'RETURN_TO_TARGET':
                this.returnToTarget(event);
                break;
            case 'ADD_TASK_SUBMIT':
                this.state.addingTask = true;
                this.modalButtonStatus.addTask = true;
                this.template.querySelector('lightning-record-edit-form.add-task').submit();
                break;
            case 'ADD_TASK_CANCEL':
                this.addTaskDialog = false;
                this.selectedTasks = [];
                break;
            case 'EDIT_TASK_SUBMIT':
                this.modalButtonStatus.editTask = true;
                this.state.savingTask = true;
                this.template.querySelector('lightning-record-edit-form.edit-task').submit();
                break;
            case 'EDIT_TASK_CANCEL':
                this.editTaskDialog = false;
                this.selectedTasks = [];
                break;
            case 'ADD_DELIVERABLE_CANCEL':
            case 'EDIT_DELIVERABLE_CANCEL':
                if(this.addDeliverableMode == true) {
                    this.returnToTarget(event);
                } else {
                    this.clearModals();
                }
                break;
            case 'CLONE_DELIVERABLE_CANCEL':
            case 'CLOSE':
                this.clearModals();
                break;
            case 'DELETE_DELIVERABLE_CANCEL':
            case 'DELETE_TASK_CANCEL':
                this.modalButtonStatus.deleteDeliverable = false;
                this.modalButtonStatus.editDeliverable = false;
                this.confirmDeleteDeliverableDialog = false;
                this.confirmDeleteTaskDialog = false;
                break;
            case 'CLONE_DELIVERABLE_SUBMIT':
                this.state.cloning = true;
                this.modalButtonStatus.cloneDeliverable = true;
                this.openEditorAfterLoad = false;
                this.openAddTaskAfterLoad = false;
                this.template.querySelector('lightning-record-edit-form .CLICK-CLONE-DELIVERABLE').click();
                //this.template.querySelector('lightning-record-edit-form.clone-deliverable').submit();
                break;
            case 'CLONE_DELIVERABLE_SUBMIT_WITH_TASK':
                this.state.cloning = true;
                this.modalButtonStatus.cloneDeliverable = true;
                this.openEditorAfterLoad = true;
                this.openAddTaskAfterLoad = true;
                //this.template.querySelector('lightning-record-edit-form.clone-deliverable').submit();
                this.template.querySelector('lightning-record-edit-form .CLICK-CLONE-DELIVERABLE').click();
                break;
            case 'ADD_DELIVERABLE_SUBMIT':
                this.state.adding = true;
                this.modalButtonStatus.addDeliverable = true;
                this.openEditorAfterLoad = false;
                this.openAddTaskAfterLoad = false;
                //this.template.querySelector('lightning-record-edit-form.add-deliverable').submit();
                this.template.querySelector('lightning-record-edit-form .CLICK-ADD-DELIVERABLE').click();
                break;
            case 'ADD_DELIVERABLE_SUBMIT_WITH_TASK':
                this.state.adding = true;
                this.modalButtonStatus.addDeliverable = true;
                this.openEditorAfterLoad = true;
                this.openAddTaskAfterLoad = true;
                //this.template.querySelector('lightning-record-edit-form.add-deliverable').submit();
                this.template.querySelector('lightning-record-edit-form .CLICK-ADD-DELIVERABLE').click();
                break;
            case 'EDIT_DELIVERABLE_SUBMIT':
                this.state.saving = true;
                this.modalButtonStatus.editDeliverable = true;
                this.template.querySelector('lightning-record-edit-form .CLICK-EDIT-DELIVERABLE').click();
                //this.template.querySelector('lightning-record-edit-form.edit-deliverable').submit();
                break;
            case 'DELETE_DELIVERABLE_SUBMIT':
                this.state.deleting = true;
                this.modalButtonStatus.deleteDeliverable = true;
                this.template.querySelector('lightning-record-edit-form.delete-deliverable').submit();
                break;
            case 'DELETE_TASK_SUBMIT':
                this.state.deleting = true;
                this.modalButtonStatus.deleteDeliverable = true;
                this.template.querySelector('lightning-record-edit-form.delete-task').submit();
                break;
            case 'EXPAND_ALL':
                this.template.querySelector('lightning-tree-grid.task-display').expandAll();
                break;
            case 'COLLAPSE_ALL':
                this.template.querySelector('lightning-tree-grid.task-display').collapseAll();
                break;
            case 'ADD_NEW_TASK':
                this.modalButtonStatus.addTask = true;
                this.addTaskDialog = true;
                break;
            case 'EDIT_TASK':
                this.modalButtonStatus.editTask = true;
                this.editedTask = this.selectedTasks[0];
                this.editTaskDialog = true;
                this.collapseDeliverableSections();
                break;
            case 'ADD_CHILD_TASK':
                this.showModalSpinner = true;
                this.editedTask = this.selectedTasks[0];
                this.parentTaskId = this.editedTask.Id;
                this.addTaskDialog = true;
                this.collapseDeliverableSections();
                break;
            case 'EDIT_TASK_ASSIGNMENTS':
                this.showModalSpinner = true;
                this.editedTask = this.selectedTasks[0];
                this.editedTaskAssignments = (this.taskAssignmentsByTaskId[this.editedTask.Id]) ? this.taskAssignmentsByTaskId[this.editedTask.Id] : [];
                this.editTaskAssignmentsDialog = true;
                this.collapseDeliverableSections();
                break;
            case 'DELETE_TASK':
                this.editedTask = this.selectedTasks[0];
                this.modalButtonStatus.deleteDeliverable = true;
                this.modalButtonStatus.editDeliverable = true;
                this.confirmDeleteTaskDialog = true;
                break;
            case 'FILTER_DELIVERABLES':
                this.viewFilters = !this.viewFilters;
                break;
            case 'RESET_START_DATE':
                event.preventDefault();
                this.filterStartDate = this.earliestStartDate;
                this.filteredDeliverables = this.applyFilters(this.unfilteredDeliverables);
                this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
                break;
            case 'RESET_END_DATE':
                event.preventDefault();
                this.filterEndDate = this.latestEndDate;
                this.filteredDeliverables = this.applyFilters(this.unfilteredDeliverables);
                this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
                break;
            case 'EDIT_TASK_ASSIGNMENT':
                this.showModalSpinner = true;
                this.editTaskAssignmentsDialog = false;
                this.addTaskAssignmentDialog = false;
                this.editedTaskAssignment = this.selectedTaskAssignments[0];
                this.changeTaskAssignmentDialog = true;
                this.collapseDeliverableSections();
                break;
            case 'EDIT_TASK_ASSIGNMENT_CLOSE':
                this.editTaskAssignmentsDialog = true;
                this.changeTaskAssignmentDialog = false;
                break;
            case 'DELETE_TASK_ASSIGNMENT':
                deleteRecord(this.selectedTaskAssignments[0].Id)
                .then(result => {
                    console.log(result);
                    refreshApex(this.wiredTaskListValue);
                    refreshApex(this.wiredTaskAssignmentListValue);
                    this.editTaskAssignmentsDialog = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record deleted',
                            variant: 'success'
                        })
                    );
                })
                .catch(error =>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error deleting record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                break;
            case 'EDIT_TASK_ASSIGNMENTS_CLOSE':
                this.editTaskAssignmentsDialog = false;
                this.expandDeliverableSections();
                break;
            case 'ADD_TASK_ASSIGNMENT':
                this.showModalSpinner = true;
                this.addTaskAssignmentDialog = true;
                break;
            case 'ADD_TASK_ASSIGNMENT_CLOSE':
                this.addTaskAssignmentDialog = false;
                break;
            case 'SELECT_PROJECT_CANCEL':
                window.location = '/lightning/r/Target__c/'+getUrlVars().c__target + '/view'+'?eraseCache=true';
                break;
            case 'SELECT_MILESTONE_CANCEL':
                this.returnToTarget(event);
                break;
            case 'SELECT_MILESTONE_BACK':
                this.selectMilestoneDialog = false;
                this.addFromTarget = true;
                this.milestonesByProject = [];
                break;
            default:
                break;
        }
    }

    interruptSubmit(event){
        event.preventDefault();
        this.commitFields = event.detail.fields;
        //console.log('Submit interrupted', JSON.parse(JSON.stringify(event.detail)));
        getValidMetricsForService({projectId: this.parentProjectId, serviceLineId: this.serviceLineId, serviceId: this.serviceId})
        .then(result => {
            if (typeof result != 'undefined') {
                console.log('Metrics:',result);
                let filteredMetrics = [];
                for(let metric of result){
                    filteredMetrics.push(metric);
                }
                if(filteredMetrics.length > 0 && this.hasMiss(this.commitFields, filteredMetrics)){
                    this.showMetricsModal = true;
                } else {
                    if(this.state.saving == true){
                        this.template.querySelector('lightning-record-edit-form.edit-deliverable').submit(this.commitFields);
                    }
                    if(this.state.adding == true){
                        this.template.querySelector('lightning-record-edit-form.add-deliverable').submit(this.commitFields);
                    }
                    if(this.state.cloning == true){
                        this.template.querySelector('lightning-record-edit-form.clone-deliverable').submit(this.commitFields);
                    }
                }
            }
        })
        .catch(error => {
            ShowToast.error(this, buildErrorMessage(error))
        });
    }

    hasMiss(fields, metrics){
        let failures = [];
        let actualDates = {};
        for(let metric of metrics){

            if(this.missAlreadyExists(metric)){
                continue;
            }

            let actual = metric.PSA_Metric__r.Validation_Actual_Field__c;
            let planned = metric.PSA_Metric__r.Validation_Target_Field__c;
            let type = metric.PSA_Metric__r.Validation_Type__c;
            if( actual && planned && type){
                console.log("Actual("+actual+"): "+fields[actual]);
                console.log("Planned("+planned+"): "+fields[planned]);
                console.log("Type: "+type);
                let targetValue;
                const parsedInt = Number.parseInt(planned,10);
                const parsedFloat = Number.parseFloat(planned)
                if(!Number.isNaN(parsedInt)){
                    targetValue = parsedInt;
                } else if(!Number.isNaN(parsedFloat)){
                    targetValue = parsedFloat;
                } else {
                    targetValue = fields[planned];
                }

                if(typeof fields[actual] == 'undefined' || (typeof targetValue == 'undefined' && typeof planned == 'undefined')){
                    continue;
                }

                switch(type){
                    case 'Actual = Target':
                        if(fields[actual] == targetValue || fields[actual] == planned){
                            console.log('Actual = Target')
                            failures.push(metric);
                        }
                        break;
                    case 'Actual date is late':
                        actualDates[actual] = fields[actual];
                    case 'Actual > Target':
                    default:
                        if(fields[actual] > targetValue){
                            failures.push(metric);
                        }
                }
            }
        }
        this.failedMetrics = failures;
        this.missActualDates = actualDates;
        return (failures != null && failures.length > 0);
    }

    missAlreadyExists(metric){
        return this.existingMisses.includes(metric.PSA_Metric__c);
    }

    returnToTarget(event){
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: getUrlVars().c__target,
                actionName: 'view'
            }
        });
    }

    targetChanged(event){
        console.log(event.detail.value[0]);
        this.selectedTarget = event.detail.value[0];
    }

    selectProjectSuccess(event){
        const rows = event.detail.selectedRows[0];
        console.log(rows.Id);
        console.log(rows.value);
        console.log(rows.name);
        this.selectedProject = rows.Id;
        this.addFromTarget = false;
        this.getMilestonseForProject();
        this.selectMilestoneDialog  = true;

    }

    selectMilestoneSuccess(event){
        const rows = event.detail.selectedRows[0];
        this.milestoneId = rows.Id;
        this.selectMilestoneDialog = false;
        this.addDeliverableDialog = true;
        this.modalButtonStatus.addDeliverable = true;
        console.log(this.milestoneId);
    }

     // Searches the object for the item containing a key of the provided name that contains the value provided
     findNested(obj, key, value) {
        // Base case
        if (obj[key] === value) {
            return obj;
        }


        // otherwise
        const objKeys = Object.keys(obj);
        for (const k of objKeys) {
            if (typeof obj[k] === 'object' || Array.isArray(obj[k])) {
                const found = this.findNested(obj[k], key, value);

                if (found) {
                    // If the object was found in the recursive call, bubble it up.
                    return found;
                }
            }
        }

        return null;
    }

    addTaskSuccess(event){
        this.state.addingTask = false;
        this.addTaskDialog = false;
        let startValue = (this.usePackageDates == true) ? event.detail.fields.pse__Start_Date_Time__c.value : event.detail.fields.Start_Date_Planned__c.value;
        let endValue = (this.usePackageDates == true) ? event.detail.fields.pse__End_Date_Time__c.value : event.detail.fields.End_Date_Planned__c.value;
        if(startValue != null && endValue != null){
            let startDateTime = startValue.substr(0,10);
            let endDateTime = endValue.substr(0,10);
            this.updateFilterDatesFromNew(startDateTime, endDateTime);
        }
        this.expandDeliverableSections();
        refreshApex(this.wiredTaskListValue);
    }

    editTaskSuccess(event){
        this.state.savingTask = false;
        this.modalButtonStatus.editTask = false;
        this.editTaskDialog = false;
        let startValue = (this.usePackageDates == true) ? event.detail.fields.pse__Start_Date_Time__c.value : event.detail.fields.Start_Date_Planned__c.value;
        let endValue = (this.usePackageDates == true) ? event.detail.fields.pse__End_Date_Time__c.value : event.detail.fields.End_Date_Planned__c.value;
        if(startValue != null && endValue != null){
            let startDateTime = startValue.substr(0,10);
            let endDateTime = endValue.substr(0,10);
            this.updateFilterDatesFromNew(startDateTime, endDateTime);
        }
        this.expandDeliverableSections();
        refreshApex(this.wiredTaskListValue);
    }

    addDeliverableSuccess(event){
        if(this.openEditorAfterLoad === false && this.addDeliverableMode == true){
            this.returnToTarget();
            return;
        }

        if(this.showMetricsModal == true){
            createMisses({metrics: this.failedMetrics, deliverableId: event.detail.id, serviceLine: this.serviceLineName, actualDates: this.missActualDates})
            .then(result => {
                console.log(result);
                ShowToast.success(this, 'Your issues have been created and attached to this deliverable.')
                this.cleanupAfterAdd(event);
            })
            .catch(error => {
                this.cleanupAfterAdd(event);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Metric Issues',
                        message: error.message,
                        variant: 'error'
                    })
                );
            })
        } else {
            this.cleanupAfterAdd(event);
        }
    }
    
    cleanupAfterAdd(event){
        this.showMetricsModal = false;
        this.modalButtonStatus.metrics = false;
        this.state.adding = false;
        this.modalButtonStatus.addDeliverable = false;
        this.clearModals();
        let startValue = (this.usePackageDates == true) ? event.detail.fields.pse__Start_Date_Time__c.value : event.detail.fields.Start_Date_Planned__c.value;
        let endValue = (this.usePackageDates == true) ? event.detail.fields.pse__End_Date_Time__c.value : event.detail.fields.End_Date_Planned__c.value;
        if(startValue != null){
            let startDateTime = startValue.substr(0,10);
            let endDateTime = endValue == null ? null : endValue.substr(0,10);
            this.updateFilterDatesFromNew(startDateTime, endDateTime);
        }
        if(!this.selectedServices.includes(event.detail.fields.Service__c.value)){
            this.selectedServices.push(event.detail.fields.Service__c.value);
        }
        this.updateFilterStatusFromNew(event.detail.fields.pse__Status__c.value);
        this.editedRow = event.detail;
        refreshApex(this.wiredTaskListValue);
    }

    addDeliverableError(event){
        this.state.adding = false;
        this.modalButtonStatus.addDeliverable = false;
    }

    cloneDeliverableError(event){
        this.state.cloning = false;
        this.modalButtonStatus.cloneDeliverable = false;
    }

    deleteDeliverableError(event){
        this.state.deleting = false;
        this.modalButtonStatus.deleteDeliverable = false;
    }

    addTaskError(event){
        this.state.addingTask = false;
        this.modalButtonStatus.addTask = false;
    }

    editTaskError(event){
        this.state.savingTask = false;
        this.modalButtonStatus.editTask = false;
    }

    updateFilterDatesFromNew(start, end){
        if(this.filterStartDate > start){
            this.filterStartDate = start;
        }
        if(this.filterEndDate < end){
            this.filterEndDate = end;
        }
    }

    updateFilterStatusFromNew(status){
        if(!this.selectedStatuses.includes(status)){
            this.selectedStatuses.push(status);
        }
    }

    addDeliverableLoad(){
        if(this.state.adding == false){
            this.modalButtonStatus.addDeliverable = false;
        }

        // @@ Depedent lookup - prepare for workaround!
        this.buildFieldsDependentLookupWorkaround()
    }

    cloneDeliverableLoad(){
        if(this.state.cloning == false){
            this.modalButtonStatus.cloneDeliverable = false;
        }
    }

    editDeliverableLoad(event){
        if(this.state.saving == false){
            this.modalButtonStatus.editDeliverable = false;
        }
        // @@ Depedent lookup - prepare for workaround!
        this.recordLoadedDependentLookupWorkaround(event)
    }

    addTaskLoad(){
        if(this.state.addingTask == false){
            this.modalButtonStatus.addTask = false;
        }
    }

    editTaskLoad(){
        if(this.state.savingTask == false){
            this.modalButtonStatus.editTask = false;
        }
    }

    changeTaskAssignmentLoad(){
        this.showModalSpinner = false;
    }

    addTaskAssignmentLoad(){
        this.showModalSpinner = false;
    }

    editTaskAssignmentsLoad(){
        this.showModalSpinner = false;
    }

    deleteDeliverableLoaded() {
        if(this.state.deleting == false) {
            this.modalButtonStatus.deleteDeliverable = false;
        }
    }

    editDeliverableSuccess(event){
        if(this.showMetricsModal == true){
            createMisses({metrics: this.failedMetrics, deliverableId: event.detail.id, serviceLine: this.serviceLineName, actualDates: this.missActualDates})
            .then(result => {
                console.log(result);
                ShowToast.success(this, 'Your issues have been created and attached to this deliverable.')
                this.cleanupAfterEdit(event);
            })
            .catch(error => {
                this.cleanupAfterEdit(event);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Metric Issues',
                        message: error.message,
                        variant: 'error'
                    })
                );
            })
        } else {
            this.cleanupAfterEdit(event);
        }
    }

    cleanupAfterEdit(event){
        this.showMetricsModal = false;
        this.modalButtonStatus.metrics = false;
        this.state.saving = false;
        this.editDeliverableDialog = false;
        this.newlyCreatedDeliverableId = null;
        let startValue = (this.usePackageDates == true) ? event.detail.fields.pse__Start_Date_Time__c.value : event.detail.fields.Start_Date_Planned__c.value;
        let endValue = (this.usePackageDates == true) ? event.detail.fields.pse__End_Date_Time__c.value : event.detail.fields.End_Date_Planned__c.value;
        if(startValue != null){
            let startDateTime = startValue.substr(0,10);
            let endDateTime = endValue == null ? null : endValue.substr(0,10);
            this.updateFilterDatesFromNew(startDateTime, endDateTime);
        }
        this.updateFilterStatusFromNew(event.detail.fields.pse__Status__c.value);
        refreshApex(this.wiredTaskListValue);
    }

    editDeliverableError(event){
        this.state.saving = false;
        this.modalButtonStatus.editDeliverable = false;
    }

    cloneDeliverableSuccess(event){
        if(this.showMetricsModal == true){
            createMisses({metrics: this.failedMetrics, deliverableId: event.detail.id, serviceLine: this.serviceLineName, actualDates: this.missActualDates})
            .then(result => {
                console.log(result);
                ShowToast.success(this, 'Your issues have been created and attached to this deliverable.')
                this.cleanupAfterClone(event);
            })
            .catch(error => {
                this.cleanupAfterClone(event);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Metric Issues',
                        message: error.message,
                        variant: 'error'
                    })
                );
            })
        } else {
            this.cleanupAfterClone(event);
        }
    }

    cleanupAfterClone(event){
        this.showMetricsModal = false;
        this.modalButtonStatus.metrics = false;
        this.state.cloning = false;
        this.clearModals();
        let startValue = (this.usePackageDates == true) ? event.detail.fields.pse__Start_Date_Time__c.value : event.detail.fields.Start_Date_Planned__c.value;
        let endValue = (this.usePackageDates == true) ? event.detail.fields.pse__End_Date_Time__c.value : event.detail.fields.End_Date_Planned__c.value;
        if(startValue != null){
            let startDateTime = startValue.substr(0,10);
            let endDateTime = endValue == null ? null : endValue.substr(0,10);
            this.updateFilterDatesFromNew(startDateTime, endDateTime);
        }
        if(!this.selectedServices.includes(event.detail.fields.Service__c.value)){
            this.selectedServices.push(event.detail.fields.Service__c.value);
        }
        this.updateFilterStatusFromNew(event.detail.fields.pse__Status__c.value);
        this.editedRow = event.detail;
        refreshApex(this.wiredTaskListValue);
    }

    addTaskAssignmentSubmit(){
        this.showModalSpinner = true;
    }

    addTaskAssignmentSuccess(event){
        console.log(event.detail);
        this.editedTaskAssignments.push(event.detail);
        refreshApex(this.wiredTaskListValue);
        refreshApex(this.wiredTaskAssignmentListValue);
        this.addTaskAssignmentDialog = false;
        this.editTaskAssignmentsDialog = true;
    }

    changeTaskAssignmentSuccess(event){
        refreshApex(this.wiredTaskListValue);
        refreshApex(this.wiredTaskAssignmentListValue);
        this.changeTaskAssignmentDialog = false;
        this.editTaskAssignmentsDialog = true;
    }
    setDeleteReasonSuccess(event){
        //If we get the message set, go ahead and delete
        if(!this.confirmDeleteDeliverableDialog && !this.confirmDeleteTaskDialog) {
            return;
        }
        let toDelete;
        if (this.confirmDeleteDeliverableDialog){
            toDelete=this.editedRow.Id;
        }
        if (this.confirmDeleteTaskDialog){
            toDelete=this.editedTask.Id;
        }
        deleteRecord(toDelete)
        .then(result => {
            this.state.deleting = false;
            this.modalButtonStatus.deleteDeliverable = false;
            this.confirmDeleteDeliverableDialog = false;
            this.confirmDeleteTaskDialog = false;
            this.modalButtonStatus.editDeliverable = false;
            console.log(result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted',
                    variant: 'success'
                })
            );
            refreshApex(this.wiredTaskListValue);
        })
        .catch(error =>{
            this.state.deleting = false;
            this.modalButtonStatus.deleteDeliverable = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    modalCancelSave(){
        this.modalButtonStatus.metrics = false;
        this.showMetricsModal = false;
    }
    modalConfirmSave(){
        this.modalButtonStatus.metrics = true;
        if(this.state.saving == true){
            this.template.querySelector('lightning-record-edit-form.edit-deliverable').submit(this.commitFields);
        }
        if(this.state.adding == true){
            this.template.querySelector('lightning-record-edit-form.add-deliverable').submit(this.commitFields);
        }
        if(this.state.cloning == true){
            this.template.querySelector('lightning-record-edit-form.clone-deliverable').submit(this.commitFields);
        }
    }
    handleKeyDown(event){
        if(event.keyCode === ESC_KEY ){
            this.clearModals();
        }
    }

    serviceFilterApplied(event){
        this.selectedServices = event.detail;
        this.filteredDeliverables = this.applyFilters(this.unfilteredDeliverables);
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    resourceFilterApplied(event){
        this.pagination.current = 1;
        this.filterResource.selected = event.detail.value
        this.filteredDeliverables = this.applyFilters(this.unfilteredDeliverables);
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    statusFilterApplied(event){
        this.selectedStatuses = event.detail;
        this.filteredDeliverables = this.applyFilters(this.unfilteredDeliverables);
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }
    dateFilterApplied(event){
        if(event.target.name === 'FILTER_START_DATE'){
            this.filterStartDate = event.detail.value;
            if(this.filterStartDate > this.filterEndDate){
                this.filterEndDate = this.filterStartDate;
            }
        }
        if(event.target.name === 'FILTER_END_DATE'){
            this.filterEndDate = event.detail.value;
            if(this.filterEndDate < this.filterStartDate){
                this.filterStartDate = this.filterEndDate;
            }
        }
        this.filteredDeliverables = this.applyFilters(this.unfilteredDeliverables);
        this.displayedDeliverables = this.applyPagination(this.filteredDeliverables);
    }

    handleLookupChange(event){
        const fieldName = event.currentTarget.dataset.idFieldname // data-id-fieldname
        event.detail.value = (event.detail.length > 0) ? event.detail : [null];
        this.writeHiddenLookupField(fieldName, event.detail.value[0]);
        this.fieldChangedDependentLookupWorkaround(event) // !
    }
    handleSearch(event){
        if(this.drugErrors.length > 0){
            this.drugErrors = [];
        }
        const target = event.target;
        apexSearch({searchTerm: event.detail.searchTerm, selectedIds: [this.programId]})
        .then(results => {
            target.setSearchResults(results);
        })
        .catch(error => {
            ShowToast.error(this, buildErrorMessage(error))
            this.drugErrors = [{'id': '1', 'message': buildErrorMessage(error)}]
        });
    }
    // ------------------------------------------------------------------------
    // ------ DependentLookupWorkaround
    // ------------------------------------------------------------------------
    selected_Drug__c    // the value for the selected lookup drug to control our custom comboboxes
    selected_pse__Project__c // the value for the selected lookup project to control our custom comboboxes

    /* track our dependant lookups
     *  Field Name:
     *    options - list of combobox options
     *    selected - Id for the selected value
     *    depends_on_field - object name of controlling lookup for dependent options
     */
    @track dependentLookupItems = {
        Trade_Name__c: { options: [], selected: null, depends_on_field: 'Drug__c' },
        Formulation__c: { options: [], selected: null, depends_on_field: 'Drug__c' },
        Resource__c: { options: [], selected: null, depends_on_field: 'pse__Project__c' },
    }

    // returns unique list of depends_on_fields from dependent lookup items
    get dependsOnFields() {
        return ['Drug__c', 'pse__Project__c']
    }

    // returns unique list of fields depending on 'depends-on-field'
    findDependentFields(dependsOnField) {
        let keySet = new Set()
        Object.keys(this.dependentLookupItems).forEach(key => {
            if (this.dependentLookupItems[key].depends_on_field === dependsOnField) {
                keySet.add(key)
            }
        })
        return [...keySet]
    }

    @wire(getDrugDependentOptions, { drugId: '$selected_Drug__c' })
    wiredGetDrugDependentOptions(value) {
        this.wiredDrugDependentOptions = value
        const { error, data } = value
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {
            this.dependentLookupItems.Trade_Name__c.options = data.Trade_Name__c.options
            this.dependentLookupItems.Formulation__c.options = data.Formulation__c.options
        }
    }

    @wire(getProjectDependentOptions, { projectId: '$selected_pse__Project__c' })
    wiredGetProjectDependentOptions(value) {
        this.wiredProjectDependentOptions = value
        const { error, data } = value
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {
            console.log('selected project resources?', data.Resource__c.options)
            this.dependentLookupItems.Resource__c.options = data.Resource__c.options
        }
    }

    /**
     * Dependent Lookup  Workaround
     *  # Trade_Name__c, Formulation__c DEPENDS on Drug__c lookup
     *  # Resource__c DEPENDS ON pse__Project__c lookup
     *
     * Called when building fields, indicate dependent fields should be custom
     * comboboxes based on value of the current "depends-on" lookup field
     *
     * @param {*} fields
     */
    buildFieldsDependentLookupWorkaround(fields) {
        if (typeof fields === 'undefined' || fields === null)  {
            // add form load
            this.selected_pse__Project__c = this.projectId
            this.selected_Drug__c = null
            this.dependentLookupItems.Resource__c.selected = null
            return
        }
        const fieldsWithDependencies = this.dependsOnFields
        fieldsWithDependencies.forEach(fldDep => {
            const hasDependsOnField = fields.some(e => e.fieldName === fldDep)
            if (hasDependsOnField || fldDep === 'pse__Project__c') { //  since dependecy is on underlying page project and not in the loaded form
                this.findDependentFields(fldDep).forEach(dfld => {
                    let field = fields.find(f => f.fieldName === dfld)
                    if (field) {
                        const fieldName = field.fieldName
                        field.fieldLabel = fieldName.replace('__c', '').replace('_', ' ')
                        field.isCustomComboField = true
                        field.placeholder = `Select ${field.fieldLabel}...`
                        // for quickly adding now (used in html template).. (todo..genericize up!!)
                        field.is_Trade_Name__c = fieldName === 'Trade_Name__c'
                        field.is_Formulation__c = fieldName === 'Formulation__c'
                        field.is_Resource__c = fieldName === 'Resource__c'
                        // field[`is_${fieldName}`] = true
                    }
                })
            }
        })
    }
    /**
     * When the controlliing lookup field is changed then load/refresh the dependent options
     * @param {*} event
     */
    fieldChangedDependentLookupWorkaround(event) {
        const fieldName = event.currentTarget.dataset.idFieldname // data-id-fieldname
        const fieldsWithDependencies = this.dependsOnFields
        if (fieldsWithDependencies.indexOf(fieldName) > -1) {
            const changedValue = event.detail.value[0] || null
            if (changedValue === null) {
                // when field is cleared then clear dependent options, selections, and hidden values
                Object.keys(this.dependentLookupItems).forEach(key => {
                    if (key.depends_on_field === fieldName) {
                        this.dependentLookupItems[key] = { options: [], selected: null }
                        this.writeHiddenLookupField(key, '') // clear hidden lookup fields!
                    }
                })
            }
            this[`selected_${fieldName}`] = changedValue // set to trigger wire adapter
        }
    }
    /**
     * When the edit form / lightning-input-record is loaded, check for
     * fields with dependencies and update for the custom comboboxes
     *
     * set selected_Drug__c and/or selected_Project__c
     * and fields that depends-on- these fields
     *
     * @param {*} event
     */
    recordLoadedDependentLookupWorkaround(event) {
        // manually set project controlling field for resource!
        this.selected_pse__Project__c = this.projectId

        const record = event.detail.records
        if(typeof record === 'undefined'){
            return
        }
        //The following line will need to be modified for Add Deliverable case
        const fields = record[this.editedRow.Id].fields
        if (typeof fields === 'undefined') {
            return
        }

        // lookup controlling fields from underlying fields!
        const fieldsWithDependencies = this.dependsOnFields
        fieldsWithDependencies.forEach(mstrLookupFld => {
            if (typeof fields[mstrLookupFld] !== 'undefined') {
                const fldValue = fields[mstrLookupFld].value
                this[`selected_${mstrLookupFld}`] = fldValue // set selected_* value to trigger wire adapter
            }
            // now inject values for dependent lookup combobox items!
            Object.keys(this.dependentLookupItems).forEach(fldNm => {
                if (typeof fields[fldNm] !== 'undefined') {
                    this.dependentLookupItems[fldNm].selected = fields[fldNm].value
                }
            })
        })
    }
    /**
     * When custom combobox is changed, update the hidden dependant lookup with
     * the new value
     * @param {*} event
     */
    handleCustomComboboxChange(event) {
        const fieldName = event.detail.name || event.target.name
        const value = event.detail.value
        //  update the hidden lookup input-field value and selected item
        this.writeHiddenLookupField(fieldName, value)
        if (typeof this.dependentLookupItems[fieldName] !== 'undefined') {
            this.dependentLookupItems[fieldName].selected = value
        }
    }
    /**
     * Updates underlying hidden dependent lookup input-fields value
     * @param {*} fieldName
     * @param {*} value
     */
    writeHiddenLookupField(fieldName, value) {
        const hiddenLookupField = this.template.querySelector(`lightning-input-field.${fieldName}`)
        if (typeof hiddenLookupField !== 'undefined' && hiddenLookupField !== null) {
            hiddenLookupField.value = value
        }
    }
    // ------------------------------------------------------------------------
}
