import { LightningElement, wire, track  } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference } from 'lightning/navigation';
import globalFlexipageStyles from '@salesforce/resourceUrl/PSAGlobalFlexipageStyles';

import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import TARGET_OBJECT from '@salesforce/schema/Target__c';

import getProjectsForProgram from '@salesforce/apex/CNT_PSA_TargetGrid.getProjectsForProgram';
import getTargets from '@salesforce/apex/CNT_PSA_TargetGrid.getTargets';
import getServiceLines from '@salesforce/apex/CNT_PSA_TargetGrid.getServiceLines';
import getProjectTargets from '@salesforce/apex/CNT_PSA_TargetGrid.getProjectTargets';
import createProjectTarget from '@salesforce/apex/CNT_PSA_TargetGrid.createProjectTarget';
import updateProjectTarget from '@salesforce/apex/CNT_PSA_TargetGrid.updateProjectTarget';
//import deleteProjectTarget from '@salesforce/apex/CNT_PSA_TargetGrid.deleteProjectTarget';

const PROGRAM_FIELDS = [
    'Program__c.Name',
];

const GRID_TYPE_OPTIONS = [
    { label: 'Project', value: 'project' },
    { label: 'Service Line', value: 'serviceLine' }
]

export default class Lwc_psa_targetGrid extends LightningElement {
    @track programId;
    @track gridType;
    @track programName;
    @track gridType = 'project';
    @track projectCode;
    @track recordType;
    @track recordTypeOptions = [];
    @track projectCodeOptions = [];
    @track tableRows = [];
    @track tableColumns = [];
    @track projectTableColumns = [];
    @track serviceLineTableColumns = [];
    @track projectTargetLookup = {};
    @track serviceLines = [];
    @track serviceLineIds = [];
    @track projects = [];
    @track projectIds = [];
    helper;
    @track pagination = {
        current: 1,
        previous: null,
        next: null,
        pageSize: 50,
        pageCount: 1
    }
    @track displayedtableRows = [];
    searchValue;
    filtereddata = [];
    //Need a queue for the spinner so we don't hide it if something else is still processing

    connectedCallback(){
        //Hide unwanted salesforce header
        Promise.all([
            loadStyle(this, globalFlexipageStyles + '/PSAGlobalFlexipageStyles.css'),
        ]);
    }

    /*
     * WIRE METHODS AND PROPERTIES
     */
    @wire (CurrentPageReference)
    getCurrentPageReference(pageReference) {
        this.currentPageReference = pageReference;
        if(typeof pageReference != 'undefined'){
            this.programId = pageReference.state.c__Program;
        }
    }

    @wire(getRecord, { recordId: '$programId', fields: PROGRAM_FIELDS })
    getProgramData(value) {
        this.wiredProgramValue = value;
        let { error, data } = value;
        if (typeof error != 'undefined') {
            this.lwcHelper.toastError(error.message);
        } else if (typeof data != 'undefined') {
            this.programName = data.fields.Name.value;
            console.log(data.fields);
        }
    }

    @wire(getObjectInfo, { objectApiName: TARGET_OBJECT })
    targetObjectInfo(value){
        let {error, data} = value;
        if(typeof data != 'undefined'){
            const rtis = data.recordTypeInfos;
            console.log('Target RecordTypes: ', rtis);
            this.recordTypeOptions = [];
            for( const rType in rtis){
                if(rtis.hasOwnProperty(rType) && rtis[rType].name != 'Master'){
                    this.recordTypeOptions.push({label: rtis[rType].name, value: rtis[rType].recordTypeId});
                }
            }
        }
        if(typeof error != 'undefined'){
            this.lwcHelper.toastError(error.message);
        }
    };

    @wire(getProjectsForProgram, {programId: '$programId'})
    getWiredProjects(value){
        this.wiredProjectsValue = value;
        let {error, data} = value;
        if(typeof data != 'undefined'){
            this.projects = data;
            this.projectIds = this.projects.map(p => {return p.Id});
            this.projectCodeOptions = this.projects.map(p => {return {label: p.Project_Code__c, value: p.Project_Code__c}});
            this.buildTableColumns('project', this.projects);
            this.applyTableColumns();
        }
        if(typeof error != 'undefined'){
            this.lwcHelper.toastError(error.message);
        }
    }

    @wire(getServiceLines, {programId: '$programId'})
    getWiredServiceLines(value){
        this.wiredServiceLines = value;
        console.log('Service Lines: ',value);
        let {error, data} = value;
        if(typeof data != 'undefined'){
            this.serviceLines = data;
            this.serviceLineIds = this.serviceLines.map(sl => {return sl.Id});
            this.buildTableColumns('serviceLine', this.serviceLines);
            this.applyTableColumns();
        }
        if(typeof error != 'undefined'){
            this.lwcHelper.toastError(error.message);
        }
    };

    get manualRefreshButton(){
        return (this.showGrid) ? false : 'disabled';
    }

    get showProjectCodeBox(){
        return (this.gridType == 'serviceLine');
    }

    get showGrid(){
        return (this.gridType && this.recordType && (this.gridType == 'project' || this.projectCode));
    }

    get lwcHelper(){
        if(typeof this.helper == 'undefined'){
            this.helper = this.template.querySelector('c-lwc_helper')
        }
        return this.helper;
    }        

    get gridTypeOptions() {
        return GRID_TYPE_OPTIONS;
    }

    get showPagination(){
        if(!this.searchValue || 0 === this.searchValue.length){
            return (this.pagination.pageSize < this.tableRows.length);
        }
        else{
            return (this.pagination.pageSize < this.filtereddata.length);
        }
    }

    get onFirstPage(){
        return this.pagination.current == 1;
    }

    get onLastPage(){
        return this.pagination.current == this.pagination.pageCount;
    }

    //HANDLERS
    handleClick(event){
        let name = event.target.name;
        if(name == 'go-back'){
            this.lwcHelper.navigateToViewRecord(this.programId);
        }
        if(name == 'view-target-grid'){
            this.refreshTableData();
        }
    }

    handleTableClick(event){
        let name = event.target.name;
        let label = event.target.label;
        let ids = name.split('-');
        
        if (ids.length == 3) {
            this.lwcHelper.showModalSpinner('Activating...');
            createProjectTarget({targetId: ids[0], projectId: ids[1], serviceLineProjectId: ids[2], isActive: true})
            .then(result => {
                console.log('Create Project Target: ',result);
                this.refreshTableData();
            })
            .catch(error =>{
                this.lwcHelper.toastError(error.message);
                this.lwcHelper.hideModalSpinner();
            })
        }

        if (ids.length == 2) {
            this.lwcHelper.showModalSpinner('Activating...');
            createProjectTarget({targetId: ids[0], projectId: ids[1], serviceLineProjectId: null, isActive: true})
            .then(result => {
                console.log('Create Project Target: ',result);
                this.refreshTableData();
            })
            .catch(error =>{
                this.lwcHelper.toastError(error.message);
            })
            .finally(() => {
                this.lwcHelper.hideModalSpinner();
            })
        }

        if(ids.length == 1){
            this.lwcHelper.showModalSpinner('Deactivating...');
            let value;
            if(label == 'Inactive'){
                value = true;
            }
            if(label == 'Active'){
                value = false;
            }
            updateProjectTarget({projectTargetId: ids[0], isActive: value})
            .then(result => {
                if( result == 'success' ){
                    console.log('Finished updating ', result);
                    this.refreshTableData();
                }else{
                    console.log('Error ', result);
                    this.lwcHelper.toastError(result);
                    this.lwcHelper.hideModalSpinner();
                }
                
            })
            .catch(error =>{
                this.lwcHelper.toastError(error.message);
                this.lwcHelper.hideModalSpinner();
            })

            /*
            deleteProjectTarget({projectTargetId: ids[0]})
            .then(result => {
                console.log('Finished deleting ', result);
                this.refreshTableData();
            })
            .catch(error =>{
                this.lwcHelper.toastError(error.message);
                this.lwcHelper.hideModalSpinner();
            })
            */
        }
    }

    gridTypeChange(event){
        this.gridType = event.detail.value;
        if(this.showGrid){
            this.applyTableColumns();
            this.refreshTableData();
        }
    }

    projectCodeChange(event){
        this.projectCode = event.detail.value;
        if(this.showGrid){
            this.buildTableColumns('serviceLine', this.serviceLines);
            this.applyTableColumns();
            this.refreshTableData();
        }
    }

    recordTypeChange(event){
        this.recordType = event.detail.value;
        if(this.showGrid){
            this.applyTableColumns();
            this.refreshTableData();
        }
    }

    refreshTableData(){
        this.lwcHelper.showModalSpinner('Loading...');
        let ids = (this.gridType == 'serviceLine') ? this.serviceLineIds : this.projectIds;
        let targets = getTargets({programId: this.programId, recordTypeId: this.recordType});
        let projectTargets = getProjectTargets({mode: this.gridType, projectIds: ids});
        Promise.all([targets, projectTargets])
        .then( results => {
            this.targets = targets;
            this.projectTargets = projectTargets;
            this.buildProjectTargetLookup(results[1]);
            this.buildTableRows(results[0]);
            this.tableRows = JSON.parse(JSON.stringify(this.tableRows));
            this.displayedtableRows = this.applyPagination(this.tableRows);
        })
        .catch(error =>{
            this.lwcHelper.toastError(error.message);
        })
        .finally(() => {
            this.lwcHelper.hideModalSpinner();
        })
    }

    handlesearch(event){
        this.searchValue = event.target.value;  
        this.filtereddata = this.tableRows.filter(data =>  data.cells[0].name.toLowerCase().indexOf(this.searchValue.toLowerCase()) > -1);   
        this.pagination.current = 1;
        if(!this.searchValue || 0 === this.searchValue.length){
            this.displayedtableRows = this.applyPagination(this.tableRows);
        }
        else{
            this.displayedtableRows = this.applyPagination(this.filtereddata);
        }
     }

    buildTableColumns(mode, projects){
        let columns = [];
        columns.push({name:'blank', Id: 'blank', first: true});
        if(mode == 'serviceLine'){
            for(let serviceLine of projects){
                if(serviceLine.pse__Parent_Project__r.Project_Code__c == this.projectCode){
                    let name = serviceLine.pse__Parent_Project__r.Project_Code__c+' / '+serviceLine.Service_Line__r.Service_Line_Code__c;
                    columns.push({name: name, Id: serviceLine.Id, pse__Parent_Project__c: serviceLine.pse__Parent_Project__c});
                }
            }
            this.serviceLineTableColumns = columns;
        }
        if(mode == 'project'){
            for(let project of projects){
                columns.push({name: project.Project_Code__c, Id: project.Id });
            }
            this.projectTableColumns = columns;
        }
    }

    buildTableRows(targets){
        this.tableRows = [];
        let rows = [];

        for(let target of targets){
            let cells = [];
            let firstCell = {name: target.Name, label: target.Name, first: true, tooltip: this.getTooltip(target)};
            cells.push(firstCell);
            for(let column of this.tableColumns){
                if(column.name == 'blank'){
                    continue;
                }
                let cellKey = target.Id;
                if(this.gridType == 'serviceLine'){
                    cellKey = (column.pse__Parent_Project__c) ? cellKey+'-'+column.pse__Parent_Project__c : cellKey;
                }

                cellKey = (column.Id) ? cellKey+'-'+column.Id : cellKey;
                let existingProjectTarget = this.projectTargetLookup[cellKey];
                if(existingProjectTarget){
                    if(existingProjectTarget.Active__c){
                        cells.push({name: existingProjectTarget.Id, label: 'Remove', first: false, add: false, remove: true});
                    }
                    else{
                        //cells.push({name: cellKey , label: 'Add', first: false, add: true, remove: false});
                        cells.push({name: existingProjectTarget.Id, label: 'Add', first: false, add: true, remove: false});
                    }
                } else {
                    cells.push({name: cellKey , label: 'Add', first: false, add: true, remove: false});
                }
            }
            rows.push({Id: target.Id, cells: cells}); 
        }
        this.tableRows = rows;
    }

    buildProjectTargetLookup(projectTargets){
        console.log('Got some project targets to index: ',projectTargets);
        let lookup = [];
        for(let pt of projectTargets){
            let ptKey = pt.Target__c;
            ptKey = (pt.Project__c) ? ptKey+'-'+pt.Project__c : ptKey;
            ptKey = (pt.Service_Line_Project__c) ? ptKey+'-'+pt.Service_Line_Project__c : ptKey;
            lookup[ptKey] = pt;
        }
        this.projectTargetLookup = lookup;
    }

    applyTableColumns(){
        this.tableColumns = (this.gridType == 'project') ? this.projectTableColumns : this.serviceLineTableColumns;
    }

    getTooltip(target){
        for(let rType of this.recordTypeOptions){
            if(rType.value == target.RecordTypeId){
                if(rType.label == 'RDS Protocol'){
                    return '*Protocol Number: '+target.Protocol_Number__c+' *Therapeutic Area: '+target.Therapeutic_Area__c+' *Indication: '+target.Indication__c+' *Product Id: '+target.Investigational_Product_Id__c+' *Clinical Phase: '+target.Clinical_Phase__c;
                } else if(rType.label == 'RDS Product Line') {
                    return '*API: '+target.API__c+' *Trade Name: '+target.Trade_Name__c+' *Generic Name: '+target.Generic_Name__c+' *Strength: '+target.Strength__c+' *Dosage Form: '+target.Dosage_Form__c+' *Single Country: '+target.Single_Country__c;
                } else if(rType.label == 'PV Agreement') {
                    return '*Customer Reference Number: '+target.Customer_Reference_Number__c+' *Partner: '+target.Partner__c+' *Agreement Status: '+target.Agreement_Status__c;
                }
            }
        }
        //Nothing found
        return '';
    }

    applyPagination(targets){
        let start = (this.pagination.current - 1)*this.pagination.pageSize;
        let end = start+this.pagination.pageSize;
        this.pagination.pageCount = Math.ceil(this.tableRows.length / this.pagination.pageSize);
        this.pagination.next = (this.pagination.pageCount > this.pagination.current) ? this.pagination.current+1 : null;
        this.pagination.previous = (this.pagination.current > 1) ? this.pagination.current-1 : null;
        return targets.slice(start,end);
    }
    
    previousPage(){
        this.pagination.current -= 1;
        if(!this.searchValue || 0 === this.searchValue.length){
            this.displayedtableRows = this.applyPagination(this.tableRows);
        }
        else{
            this.displayedtableRows = this.applyPagination(this.filtereddata);
        }
    }
    
    nextPage(){
        this.pagination.current += 1;
        if(!this.searchValue || 0 === this.searchValue.length){
            this.displayedtableRows = this.applyPagination(this.tableRows);
        }
        else{
            this.displayedtableRows = this.applyPagination(this.filtereddata);
        }
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
        if(!this.searchValue || 0 === this.searchValue.length){
            this.displayedtableRows = this.applyPagination(this.tableRows);
        }
        else{
            this.displayedtableRows = this.applyPagination(this.filtereddata);
        }
        
    }
    
    firstPage(){
        this.pagination.current = 1;
        if(!this.searchValue || 0 === this.searchValue.length){
            this.displayedtableRows = this.applyPagination(this.tableRows);
        }
        else{
            this.displayedtableRows = this.applyPagination(this.filtereddata);
        }
    }
    
    lastPage(){
        this.pagination.current = this.pagination.pageCount;
        if(!this.searchValue || 0 === this.searchValue.length){
            this.displayedtableRows = this.applyPagination(this.tableRows);
        }
        else{
            this.displayedtableRows = this.applyPagination(this.filtereddata);
        }
    }
}
