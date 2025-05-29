import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import globalFlexipageStyles from '@salesforce/resourceUrl/PSAGlobalFlexipageStyles';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

import getAssignmentsByProgram from '@salesforce/apex/CNT_PSA_AssignmentMassUpdate.getAssignmentsByProgram';
import getProjectsByProgram from '@salesforce/apex/CNT_PSA_AssignmentMassUpdate.getProjectsByProgram';
import updateAssignmentSchedules from '@salesforce/apex/CNT_PSA_AssignmentMassUpdate.updateAssignmentSchedules';

const PROGRAM_FIELDS = [
    'Program__c.Id', 'Program__c.Name'
];

const PROJECT_FIELDS = [
    'Id', 'Name', 'RecordTypeId', 'Project_Code__c' 
];

const ASSIGNMENT_FIELDS = [
    'Id', 'Name', 'pse__Project__r.pse__Parent_Project__c', 'pse__Project__r.Service_Line__r.Name', 'pse__Resource__c', 'pse__Resource__r.Name', 'pse__Start_Date__c', 'pse__End_Date__c', 'pse__Schedule__r.Id', 
    'pse__Schedule__r.pse__Start_Date__c', 'pse__Schedule__r.pse__End_Date__c'
];

const ASSIGNMENT_COLUMNS_DEFAULT = [
    {label: 'Project', fieldName: 'Project_Code__c', type: 'text'},
    {label: 'Service Line', fieldName: 'pse__Project__r:Service_Line__r:Name', type: 'text'},
    {label: 'Assignment', fieldName: 'Name', type: 'text'},
    {label: 'Resource', fieldName: 'pse__Resource__r:Name', type: 'text'},
    {label: 'Start Date', fieldName: 'pse__Start_Date__c', type: 'date-local'},
    {label: 'End Date', fieldName: 'pse__End_Date__c', type: 'date-local'}
];

export default class Lwc_psa_assignmentMassUpdate  extends NavigationMixin (LightningElement){
    //Internal values
    earliestStartDate = null;
    latestEndDate = null;

    //Tracked values
    @track programId;
    @track projectId;
    @track serviceLineId;
    @track viewFilters = false;
    @track showModifyModal = false;
    @track newStartDate = '';
    @track newEndDate = '';
    @track staleTest = false;
    @track showPageSpinner = true;

    @track program = {};
    @track project = {};
    @track serviceLine = {};
    @track filterStartDate = null;
    @track filterEndDate = null;
    @track assignmentsUnfiltered = [];
    @track assignmentsFiltered = [];
    @track assignmentColumns = ASSIGNMENT_COLUMNS_DEFAULT;
    @track projects = [];
    @track serviceLines = [];

    @track selectedProjects = [];
    @track selectedServiceLines = [];
    @track selectedAssignments = [];
    @track filterByProjectProjects = [];
    @track filterByServiceLineServiceLines = [];

    //LIFECYCLE HOOKS
    connectedCallback() {
        Promise.all([ loadStyle(this, globalFlexipageStyles + '/PSAGlobalFlexipageStyles.css')]);
        this.staleTest = true;
    }

    //WIRE ADAPTERS
    @wire(CurrentPageReference)
        wiredCurrentPageReference(value){
            this.wiredCurrentPageReferenceValue = value;
            let {state, error} = value;
            if(state){
                this.programId = state.c__program;
                this.projectId = state.c__project;
                this.serviceLineId = state.c__serviceline;
                if(this.staleTest) {
                    this.staleTest = false;
                    eval ( "$A.get('e.force:refreshView').fire()" );
                    //refreshApex(this.wiredAssignmentDataValue);
                }
            } else if (error){
                this.dispatchError(error, 'Error loading page data: ');
            }
        }

    @wire(getRecord, {recordId: "$programId", fields: PROGRAM_FIELDS})
        wiredProgramData(value){
            this.wiredProgramDataValue = value;
            if(this.hasProgramData){
                this.program.Name = value.data.fields.Name.value;
            }
        }
    
    @wire(getAssignmentsByProgram, {programId: "$programId", fieldsList: ASSIGNMENT_FIELDS})
    wiredAssignmentData(value){
        this.wiredAssignmentDataValue = value;
        if(value.data){
            let filterOptions = {};
            let serviceLineProjectIdToServiceLineIdMap = {};
            for(let assignment of value.data){
                filterOptions[assignment.pse__Project__r.Service_Line__c] = {label: assignment.pse__Project__r.Service_Line__r.Name, value: assignment.pse__Project__r.Service_Line__c};
                serviceLineProjectIdToServiceLineIdMap[assignment.pse__Project__c] = assignment.pse__Project__r.Service_Line__c;
            }
            this.filterByServiceLineServiceLines = Object.values(filterOptions);
            if(this.serviceLineId && serviceLineProjectIdToServiceLineIdMap[this.serviceLineId]){
                this.selectedServiceLines = [serviceLineProjectIdToServiceLineIdMap[this.serviceLineId]];
            } else {
                this.selectedServiceLines = Object.keys(filterOptions); 
            }
        }
        this.createAssignments(value, this.wiredProjectsDataValue);
        this.filterAssignments();
        this.showPageSpinner = false;
        let {error} = value;
        if(error){
            this.dispatchError(error, 'Error loading assignments: ');
        }
    }

    @wire(getProjectsByProgram, {programId: "$programId", fieldsList: PROJECT_FIELDS})
    wiredProjectsData(value){
        this.wiredProjectsDataValue = value;
        let {error} = value;
        if(value.data){
            let filterOptions = {};
            for(let project of value.data){
                filterOptions[project.Id] = {label: project.Project_Code__c, value: project.Id};
            }
            this.filterByProjectProjects = Object.values(filterOptions);
            if(this.projectId){
                this.selectedProjects = [this.projectId];
            } else {
                this.selectedProjects = Object.keys(filterOptions); 
            }
            this.createAssignments(this.wiredAssignmentDataValue, value);
            this.filterAssignments();
        }
        if(error){
            this.dispatchError(error, 'Error loading projects: ');
        }
    }

    //COMPUTED PROPERTIES
    get hasProgramData(){
        return this.wiredProgramDataValue && this.wiredProgramDataValue.data && this.wiredProgramDataValue.data.fields;
    }

    get modifyButtonDisabled(){
        if(this.selectedAssignments.length > 0){
            return false;
        }
        return true;
    }

    //EVERNT HANDLERS
    handleClick(event){
        let buttonName = event.target.name;
        if(buttonName === 'GO_BACK_TO_RECORD_PAGE'){
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.serviceLineId || this.projectId || this.programId,
                    actionName: 'view'
                }
            });
        } else if(buttonName === 'FILTER_ASSIGNMENTS'){
            this.viewFilters = !this.viewFilters;
        } else if(buttonName === 'OPEN_MODIFY_ASSIGNMENTS'){
            this.showModifyModal = true;
        } else if(buttonName === 'MODIFY_ASSIGNMENTS_CANCEL'){
            this.showModifyModal = false;
        } else if(buttonName === 'MODIFY_ASSIGNMENTS_APPLY'){
            let startDate = (this.newStartDate.length) ? this.newStartDate : null;
            let endDate = (this.newEndDate.length) ? this.newEndDate : null;
            let schedules = [];
            for(let assignment of this.selectedAssignments){
                if(assignment.pse__Schedule__c){
                    schedules.push(assignment.pse__Schedule__c);
                }
            }
            this.modifyModalClosed();
            this.showPageSpinner = true;
            updateAssignmentSchedules({scheduleIds: schedules, startDate: startDate, endDate: endDate})
            .then(response => {
                if(response === 'success'){
                    this.dispatchSuccess('Assignments updated successfully', 'Success');
                    refreshApex(this.wiredAssignmentDataValue);
                } else {
                    this.showPageSpinner = false;
                    this.dispatchError(response,'There as a problem updating the assignments');
                }
            })
            .catch(error =>{
                this.showPageSpinner = false;
                this.dispatchError(error,'There as a problem updating the assignments');
            });
        } else if(buttonName === 'RESET_START_DATE'){
            this.filterStartDate = null;
            this.filterAssignments();
        } else if(buttonName === 'RESET_END_DATE'){
            this.filterEndDate = null;
            this.filterAssignments();
        }
    }

    modifyModalClosed(){
        this.showModifyModal = false;
    }

    projectFilterApplied(event){
        this.selectedProjects = event.detail;
        this.filterAssignments();
    }

    serviceLineFilterApplied(event){
        this.selectedServiceLines = event.detail;
        this.filterAssignments();
    }

    dateFilterApplied(event){
        if(event.target.name === 'FIRST_MONTH_DATE'){
            this.filterStartDate = (event.detail.value === '') ? null : event.detail.value;
            if(this.filterStartDate > this.filterEndDate){
                this.filterEndDate = this.filterStartDate;
            }
        }
        if(event.target.name === 'LAST_MONTH_DATE'){
            this.filterEndDate = (event.detail.value === '') ? null : event.detail.value;
            if(this.filterEndDate < this.filterStartDate){
                this.filterStartDate = this.filterEndDate;
            }
        }
        this.filterAssignments();
    }

    //UTILITY METHODS
    createAssignments(assignmentData, projectData){
        let assignments = (assignmentData && assignmentData.data) ? this.copyObjecsForTable(assignmentData.data) : [];
        let projects = (projectData && projectData.data) ? this.copyObjecsForTable(projectData.data) : [];
        if(projects.length && assignments.length){
            this.copyProjectDataIntoAssignments(projects, assignments);
        }

        this.assignmentsUnfiltered = assignments;
    }

    copyFieldsToLocalObject(localObject, fields){
        for(let fieldName in fields){
            if(fields.hasOwnProperty(fieldName)){
                localObject[fieldName] = fields[fieldName].value;
            }
        }
        return localObject;
    }

    copyObjecsForTable(toCopy){
        let copied = [];
        for(let original of toCopy){
            let copy = {...original};
            //
            let keepSearchingNests = true;
            while(keepSearchingNests){
                keepSearchingNests = false;
                for(let field in copy){
                    if(typeof copy[field] === 'object' && Object.prototype.toString.call(copy[field]) === '[object Object]'){
                        keepSearchingNests = (this.mapNestedFields(copy, field)) ? true : keepSearchingNests;
                    }
                }
            }
            copy.bob = 'Testing';
            copied.push(copy);
        }
        return copied;
    }
    
    mapNestedFields(targetRecord, fieldName){
        //Applies nested object fields to parent object using a : as a separator-- so they can be displayed in table columns
        let mappedNewField = false;
        for(let field in targetRecord[fieldName]){
            if(targetRecord[fieldName].hasOwnProperty(field)){
                let mappedName = fieldName + ':' + field;
                if(typeof targetRecord[mappedName] == 'undefined'){
                    targetRecord[mappedName] = targetRecord[fieldName][field];
                    mappedNewField = true;
                }
            }
        }
        return mappedNewField;
    }

    copyProjectDataIntoAssignments(projects, assignments){
        let projectsById = {};
        for(let original of projects){
            projectsById[original.Id] = original;
        }
        for(let assignment of assignments){
            let project = projectsById[assignment['pse__Project__r:pse__Parent_Project__c']];
            if(project){
                assignment.Project_Code__c = project.Project_Code__c;
            }
        }
    }

    filterAssignments(){
        let filteredAssignments = [];
        for(let assignment of this.assignmentsUnfiltered){
            if( this.selectedProjects.includes(assignment['pse__Project__r:pse__Parent_Project__c']) && 
                this.selectedServiceLines.includes(assignment['pse__Project__r:Service_Line__c']) &&
                (this.filterStartDate === null || assignment['pse__End_Date__c'] >= this.filterStartDate) &&
                (this.filterEndDate === null || assignment['pse__Start_Date__c'] <= this.filterEndDate) ){
               filteredAssignments.push(assignment); 
            }
        }
        this.assignmentsFiltered = filteredAssignments;
    } 

    assignmentsSelected(event){
        this.selectedAssignments = event.detail.selectedRows;
    }

    newDateApplied(event){
        if(event.target.name === 'NEW_START_DATE'){
            this.newStartDate = event.detail.value;
            if(this.newEndDate !== '' && this.newStartDate > this.newEndDate){
                this.newEndDate = this.newStartDate;
            }
        }
        if(event.target.name === 'NEW_END_DATE'){
            this.newEndDate = event.detail.value;
            if(this.newStartDate !== '' && this.newEndDate < this.newStartDate){
                this.newStartDate = this.newEndDate;
            }
        }
    }

    dispatchError(error, title){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title+error.body.errorCode,
                message: error.body.message,
                variant: 'error',
                mode: 'pester'
            })
        );
    }

    dispatchSuccess(message, title){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: 'success'
            })
        );
    }
}