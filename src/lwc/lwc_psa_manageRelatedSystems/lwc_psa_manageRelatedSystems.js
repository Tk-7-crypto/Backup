import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

//Import custom libraries
import { DataTableHelper } from 'c/utils'
import { getUrlVars } from 'c/urlVars';
import globalFlexipageStyles from '@salesforce/resourceUrl/PSAGlobalFlexipageStyles';
import getPSARelatedSystems from '@salesforce/apex/CNT_PSA_manageRelatedSystems.getPSARelatedSystems';
import getProjectRelatedSystems from '@salesforce/apex/CNT_PSA_manageRelatedSystems.getProjectRelatedSystems';
import getJunctions from '@salesforce/apex/CNT_PSA_manageRelatedSystems.getJunctions';
import addRelatedSystems from '@salesforce/apex/CNT_PSA_manageRelatedSystems.addRelatedSystems';
import removeRelatedSystems from '@salesforce/apex/CNT_PSA_manageRelatedSystems.removeRelatedSystems';
import updateRelatedSystems from '@salesforce/apex/CNT_PSA_manageRelatedSystems.updateRelatedSystems';

const PROJECT_FIELDS = [
    'pse__Proj__c.Name'
];

const DEFAULT_COLUMNS = [
    {type: 'button', label: 'Status', initialWidth: 150, sortable: true, fieldName: 'status', typeAttributes: 
        { name: 'status_button', iconName: {fieldName: 'statusIcon'}, label: {fieldName: 'statusLabel'}, variant: {fieldName: 'statusVariant'}} },
    {type: 'text', label: 'Type', fieldName: 'type', initialWidth: 250, sortable: true},
    {type: 'text', label: 'System Name', fieldName: 'systemName', initialWIdth: 175, sortable: true },
    {type: 'text', label: 'Hosted By', fieldName: 'hostedBy', initialWidth: 200, sortable: true, editable: true},
    {type: 'text', label: 'Client System Name', fieldName: 'clientSystemName', initialWidth: 200, sortable: true, editable: true},
    {type: 'text', label: 'Service Lines', fieldName: 'ServiceLines', initialWidth: 200, sortable: false, editable: false},
    {type: 'text', label: 'Addtional Info', fieldName: 'additionalInfo', initialWidth: 375, editable: true},
    {label: 'Action', fieldName: 'recordLink', type: 'url', initialWidth: 100, typeAttributes: {label: 'Edit'}},
];

const DUMMY_DATA = [
    {systemName: 'Argus', active: true, type: 'Safety DB', hostedBy: 'IQVIA', clientSystemName: 'Client System Name', ServiceLines: 'CEVA', recordLink: '/1234567890', additionalInfo: 'Some info here...'}
];

const DUMMY_SERVICE_LINES = [
    {label: 'Safety Operations', value: 'SOP'},
    {label: 'PV Solutions', value: 'PVS'}
];

const DUMMY_SYSTEM_TYPES = [
    {label: 'Safety Database', value: 'Safety Database'},
    {label: 'EDC', value: 'EDC'}
]

export default class Lwc_psa_manageRelatedSystems extends NavigationMixin(LightningElement) {

    @track projectId = null;
    projectName;
    @track relatedSystems = [];
    filteredSystems = [];
    unfilteredSystems = [];
    relatedSystemsColumns = DEFAULT_COLUMNS;
    viewFilters = false;
    serviceLineOptions = [];
    selectedServiceLines = [];
    systemTypeOptions = [];
    selectedSystemTypes = [];
    rawData = {
        PSA_Related_System__c: null,
        Project_Related_System__c: null,
        PSA_Related_Systems_Service_Lines__c: null 
    };
    tableSortedBy='systemName';
    tableSortedDirection='asc';

    //Lifecycle hooks
    connectedCallback() {
        Promise.all([
            loadStyle(this, globalFlexipageStyles + '/PSAGlobalFlexipageStyles.css'),
        ]);
    }

    currentPageReference = null;
    urlStateParameters = null;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          console.log(this.urlStateParameters);
          this.projectId = this.urlStateParameters.c__Project || null;
          console.log('projectId', this.projectId)
       }
    }

    @wire(getRecord, { recordId: '$projectId', fields: PROJECT_FIELDS })
    wiredProjectData(value) {
        this.wiredProjectValue = value;
        let { error, data } = value;
        if (typeof error != 'undefined') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading project',
                    message: error.message,
                    variant: 'error'
                })
            );
        } else if (typeof data != 'undefined') {
            this.projectName = data.fields.Name.value;
        }
    }

    @wire(getPSARelatedSystems)
    wiredPSARelatedSystems(value) {
        this.wiredPSARelatedSystemsValue = value;
        let { error, data } = value;
        if (typeof error != 'undefined') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading PSA Related Systems',
                    message: error.message,
                    variant: 'error'
                })
            );
        } else if (typeof data != 'undefined') {
            this.rawData.PSA_Related_System__c = data;
            this.buildRelatedSystems();
        }
    }

    @wire(getProjectRelatedSystems, {projectId: '$projectId'})
    wiredProjectRelatedSystems(value) {
        this.wiredProjectRelatedSystemsValue = value;
        let { error, data } = value;
        if (typeof error != 'undefined') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Project Related Systems',
                    message: error.message,
                    variant: 'error'
                })
            );
        } else if (typeof data != 'undefined') {
            this.rawData.Project_Related_System__c = data;
            this.buildRelatedSystems();
        }
    }

    @wire(getJunctions)
    wiredJunctions(value) {
        this.wiredJunctionsValue = value;
        let { error, data } = value;
        if (typeof error != 'undefined') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Service Line Relationships',
                    message: error.message,
                    variant: 'error'
                })
            );
        } else if (typeof data != 'undefined') {
            this.rawData.PSA_Related_Systems_Service_Lines__c = data;
            this.buildRelatedSystems();
        }
    }

    handleClick(event){
        switch(event.target.name) {
            case 'RETURN_TO_PROJECT':
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        recordId: getUrlVars().c__Project,
                        actionName: 'view'
                    }
                });
                break;
            case 'FILTER_SYSTEMS':
                this.viewFilters = !this.viewFilters;
            default:
                break;
        }
    }

    /**
     * The method onsort event handler for the datatable
     */
    tableOnSort(event) {
        this.tableSortedBy = event.detail.fieldName
        this.tableSortedDirection = event.detail.sortDirection
        this.relatedSystems = DataTableHelper.sortRecords(this.relatedSystems, this.relatedSystemsColumns, this.tableSortedBy, this.tableSortedDirection)
    }

    relatedSystemsRowAction(event){
        const action = event.detail.action.name;
        const row = event.detail.row;
        console.log('Action: '+action.name);
        console.log('Status: '+row.status);
        row.status = !row.status;
        row.statusLabel = (row.status) ? 'Active' : 'Add';
        row.statusIcon = (row.status) ? 'utility:check' : 'utility:add';
        row.statusHoverIcon = (row.status) ? 'utility:exit' : 'utility:add';
        row.statusHoverText = (row.status) ? 'Remove' : 'Add';
        row.statusVariant = (row.status) ? 'brand' : 'neutral';

        this.relatedSystems = [...this.relatedSystems];

        if(row.status){
            addRelatedSystems({rows: [row], projectId: this.projectId} )
            .then(result => {
                refreshApex(this.wiredProjectRelatedSystemsValue);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error adding Project Related System',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        } else if(row.projectRelatedSystem != null){
            removeRelatedSystems({systemIds: [row.id], projectId: this.projectId})
            .then(result => {
                refreshApex(this.wiredProjectRelatedSystemsValue);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting Project Related System',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        }
    }

    cellChanged(event){
        let change = event.detail.draftValues[0];
        let id = change.id;
        let keys = Object.keys(change);
        let changedKey;
        for(let key of keys){
            if(key != 'id'){
                changedKey = key;
                break;
            }
        }
        let toUpdate = [];
        for(let system of this.relatedSystems){
            if(system.id == id){
                system[changedKey] = change[changedKey];
                if(system.status == true){
                    toUpdate.push(system);
                }
            }
        }
        if(toUpdate.length > 0){
            updateRelatedSystems({rows: toUpdate})
            .then(result => {
                refreshApex(this.wiredProjectRelatedSystemsValue);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating Project Related System',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            })
        }
    }

    serviceLineFilterApplied(event){

    }

    systemTypeFilterApplied(event){
        this.selectedSystemTypes = event.detail;
        this.applyFilters();
    }

    applyFilters(){
        let filteredSystems = [];
        for(let relatedSystem of this.unfilteredSystems){
            if(this.selectedSystemTypes.includes(relatedSystem.type)){
                filteredSystems.push(relatedSystem);
            }
        }
        this.filteredSystems = filteredSystems;
        this.relatedSystems = DataTableHelper.sortRecords(this.filteredSystems, this.relatedSystemsColumns, this.tableSortedBy, this.tableSortedDirection);
    }

    buildRelatedSystems(){
        if(this.rawData.PSA_Related_System__c == null){
            return;
        }

        let projectRelatedSystems = {};
        if(this.rawData.Project_Related_System__c != null){
            for(let prs of Object.values(this.rawData.Project_Related_System__c)){
                projectRelatedSystems[prs.PSA_Related_System__c] = {...prs};
            }
        }

        let newServiceLineMapping = {
            Any: []
        };
        let newServiceLineOptions = {
            Any: {label: 'Any', value: 'Any'}
        };

        if(this.rawData.PSA_Related_Systems_Service_Lines__c != null){
            for(let prssl of this.rawData.PSA_Related_Systems_Service_Lines__c){
                //Build list of service lines for filter
                if(typeof newServiceLineOptions[prssl.Service_Line__c] == 'undefined'){
                    newServiceLineOptions[prssl.Service_Line__c] = {label: prssl.Service_Line__r.Name, value: prssl.Service_Line__c};
                }
                //Build a mapping, for applying the filter by PSA Related System
                if(typeof newServiceLineMapping[prssl.Service_Line__c] == 'undefined'){
                    newServiceLineMapping[prssl.Service_Line__c] = [];
                }
                newServiceLineMapping[prssl.Service_Line__c].push(prssl.PSA_Related_System__c);
            }

            this.serviceLineOptions = Object.values(newServiceLineOptions);
        }

        let newRelatedSystems = [];
        let newTypeOptions = {};
        let tempSelection = [];
        for(let psars of Object.values(this.rawData.PSA_Related_System__c)){
            let prs = projectRelatedSystems[psars.Id];
            let relatedSystem = {
                id: psars.Id,
                projectRelatedSystem: null,
                project: this.projectId,
                systemName: psars.System_Name__c,
                type: psars.Type__c,
                hostedBy: (typeof psars.Hosted_By__c != 'undefined') ? psars.Hosted_By__c : null,
                clientSystemName: null,
                ServiceLines: null,
                recordLink: null,
                additionalInfo: null,
                status: (typeof prs != 'undefined'),
                statusLabel: (typeof prs != 'undefined') ? 'Active' : 'Add',
                statusIcon: (typeof prs != 'undefined') ? 'utility:check' : 'utility:add',
                statusVariant: (typeof prs != 'undefined') ? 'brand' : 'neutral',
                statusClass: ''
            };
            if(typeof prs != 'undefined') {
                if(typeof prs.Hosted_By__c != 'undefined'){
                    relatedSystem.hostedBy = prs.Hosted_By__c;
                }
                if(typeof prs.Client_System_Name__c != 'undefined'){
                    relatedSystem.clientSystemName = prs.Client_System_Name__c;
                }
                if(typeof prs.Service_Lines__c != 'undefined'){
                    relatedSystem.ServiceLines = prs.Service_Lines__c;
                }
                if(typeof prs.Additional_Info__c != 'undefined'){
                    relatedSystem.additionalInfo = prs.Additional_Info__c;
                }
                relatedSystem.projectRelatedSystem = prs.Id;
                relatedSystem.recordLink =  '/'+ prs.Id;
            }
            console.log(relatedSystem);
            newRelatedSystems.push(relatedSystem);

            //Build list of types for filters
            if(typeof newTypeOptions[psars.Type__c] == 'undefined'){
                newTypeOptions[psars.Type__c] = {label: psars.Type__c, value: psars.Type__c};
                tempSelection.push(psars.Type__c)
            }
            //Add to Any listing for filters
            newServiceLineMapping.Any.push(psars.Id);
        }

        this.serviceLineMapping = newServiceLineMapping;
        this.systemTypeOptions = Object.values(newTypeOptions);
        this.selectedSystemTypes = tempSelection;
        this.unfilteredSystems = newRelatedSystems;
        this.applyFilters();
    }
}
