import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PROJECT_TASK_OBJECT from '@salesforce/schema/pse__Project_Task__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, generateRecordInputForCreate, createRecord } from 'lightning/uiRecordApi';
import getFieldSet from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getFieldSet';
import getValidMetricsForService from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getValidMetricsForService';
import createMisses from '@salesforce/apex/CNT_PSA_filteredDetailsTab.createMisses';
import getExistingMisses from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getExistingMisses';
import getDrugDependentOptions from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getDrugDependentOptions'
import getProjectDependentOptions from '@salesforce/apex/CNT_PSA_filteredDetailsTab.getProjectDependentOptions'
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { buildErrorMessage, ShowToast } from 'c/utils'
import apexSearch from '@salesforce/apex/CNT_PSA_filteredDetailsTab.searchDrug';

const PROJECT_TASK_FIELDS = [
    'pse__Project_Task__c.Name',
    'pse__Project_Task__c.RecordTypeId',
    'pse__Project_Task__c.RecordType.Name',
    'pse__Project_Task__c.Program__c',
    'pse__Project_Task__c.Parent_Project__c',
    'pse__Project_Task__c.pse__Project__c',
    'pse__Project_Task__c.pse__Project__r.pse__Parent_Project__c',
    'pse__Project_Task__c.pse__Milestone__r.Service_Line__c',
    'pse__Project_Task__c.pse__Milestone__r.Service__c',
    //'pse__Project_Task__c.pse__Milestone__r.Unit_Price__c',
    'pse__Project_Task__c.pse__Milestone__c',
    'pse__Project_Task__c.pse__Milestone__r.Budget_Hours__c',
    'pse__Project_Task__c.pse__Milestone__r.Start_Date__c',
    'pse__Project_Task__c.pse__Milestone__r.End_Date__c',
    'pse__Project_Task__c.Service__c',
    'pse__Project_Task__c.Service_Line__r.Name',
    'pse__Project_Task__c.Service_Code__c',
    'pse__Project_Task__c.Service_Line_Code__c'
];

const MILESTONE_FIELDS = [
    'pse__Milestone__c.Id',
    'pse__Milestone__c.Name',
    'pse__Milestone__c.pse__Project__c',
    'pse__Milestone__c.pse__Project__r.Program__c',
    'pse__Milestone__c.pse__Project__r.pse__Parent_Project__c',
    'pse__Milestone__c.Service_Line__c',
    'pse__Milestone__c.Service_Line__r.Name',
    'pse__Milestone__c.Service__c',
    'pse__Milestone__c.Service_Code__c',
    'pse__Milestone__c.Service_Line__r.Service_Line_Code__c',
    //'pse__Milestone__c.Unit_Price__c',
    'pse__Milestone__c.Budget_Hours__c',
    'pse__Milestone__c.Start_Date__c',
    'pse__Milestone__c.End_Date__c'
];

const hiddenFields = [
    'Activity_Controlling_Picklist__c'
];

const readOnlyFields = [
    'RecordTypeId',
    'RecordType',
    'pse__Task_Key_Chain__c',
    'Unit_Price__c',
    'Billable__c',
    'Billing_Milestone__c',
    'Billing_Hold__c',
    'Exclude_from_Billing__c',
];

// to provide  edit functionality to user having permission set : RDS Project Manager and Functional Lead and RDS Admin.
const fieldWithEditPermission = [
    'Edit_Billing_Hold__c',
    'Edit_Exclude_from_Billing__c',
];

const customLookupFields = [
    'Drug__c'
]

const DELIVERABLE_TYPE = 'RDS Deliverable';
const TASK_TYPE = 'RDS Deliverable Task';

export default class Lwc_psa_filteredDetailsTab extends NavigationMixin(LightningElement) {
    static delegatesFocus = true;
    connectedCallback() {
        if( this.openInModal == 'true'){

            if(this.objectApiName == 'pse__Milestone__c') {
                this.status.visible.recordAddForm = true;
            } else if (this.cloneMode == 'true'){
                this.status.visible.recordCloneForm = true;
            } else {
                this.status.visible.recordEditForm = true;
            }

            this.status.modal.busy = true;
        }
        else {
            this.status.visible.recordAddForm = false;
            this.status.visible.recordCloneForm = false;
        }
    }

    @api recordId;
    @api objectApiName;
    @api openInModal;
    @api addRelatedMode;
    @api cloneMode;
    newDeliverableTaskRecordTypeId;
    recordTypeId;
    recordTypeName;
    mappingType;
    name;
    serviceLineProjectId;
    parentProjectId;
    milestoneId;
    serviceLineId;
    serviceId;
    programId;
    serviceLineName;
    serviceCode;
    serviceLineCode;
    detailsFields = [];
    serviceLineFields = [];
    billingFields = [];
    systemFields = [];
    failedMetrics = [];
    existingMisses = [];
    showRecordEditForm = false;
    showMetricsModal = false;
    clickedField;
    drugErrors = [];
    formulaFields = [];
    @track status = {
        loading: {
            details: true,
            serviceLine: true,
            system: true,
            billing: true
        },
        visible: {
            recordEditForm: false,
            recordAddForm: false
        },
        modal: {
            busy: false,
            saving: false
        }
    };

    @wire(CurrentPageReference) pageRef;

    @wire(getObjectInfo, { objectApiName: PROJECT_TASK_OBJECT })
    projectTaskObjectInfo(value){
        let {error, data} = value;
        if(typeof data != 'undefined'){
            this.deliverableObjectInfo = data;
            for(let field in data.fields) {
                if (data.fields[field].updateable == false){
                    this.formulaFields.push(field);
                }
            }
            const rtis = data.recordTypeInfos;
            this.newDeliverableTaskRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'RDS Deliverable');
            if(this.mappingType == 'Deliverable') {
                this.recordTypeName = 'RDS Deliverable';
                this.recordTypeId = this.newDeliverableTaskRecordTypeId;
            }
        }
    };

    @wire(getRecord, {recordId: '$recordId', fields: '$recordFields' })
    wiredTaskData(value){
        this.wiredTaskDataValue = value;
        let { error, data } = value;
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {

            if(this.objectApiName == 'pse__Project_Task__c'){
                this.name = data.fields.Name.value;
                this.programId = data.fields.Program__c.value;
                this.serviceLineProjectId = data.fields.pse__Project__c.value;
                this.parentProjectId = data.fields.pse__Project__r.value.fields.pse__Parent_Project__c.value;
                this.serviceLineId = data.fields.pse__Milestone__r.value.fields.Service_Line__c.value;
                this.serviceId = data.fields.Service__c.value;
                this.milestoneId = data.fields.pse__Milestone__c.value;
                this.serviceLineName = data.fields.Service_Line__r.value.fields.Name.value;
                this.serviceCode = data.fields.Service_Code__c.value;
                this.serviceLineCode = data.fields.Service_Line_Code__c.value;
                this.recordTypeId = data.fields.RecordTypeId.value;
                this.recordTypeName = data.fields.RecordType.value.fields.Name.value;

                if (this.recordTypeName == DELIVERABLE_TYPE){
                    this.mappingType = 'Deliverable';
                }
                if (this.recordTypeName == TASK_TYPE){
                    this.mappingType = 'Task';
                }
            }

            if(this.objectApiName == 'pse__Milestone__c'){
                this.name = data.fields.Name.value;
                this.programId = data.fields.pse__Project__r.value.fields.Program__c.value;
                this.serviceLineProjectId = data.fields.pse__Project__c.value;
                this.selected_pse__Project__c = data.fields.pse__Project__c.value;
                this.parentProjectId = data.fields.pse__Project__r.value.fields.pse__Parent_Project__c.value;
                this.serviceLineId = data.fields.Service_Line__c.value;
                this.serviceId = data.fields.Service__c.value;
                this.milestoneId = this.recordId;
                this.serviceLineName = data.fields.Service_Line__r.value.fields.Name.value;
                this.serviceCode = data.fields.Service_Code__c.value;
                this.serviceLineCode = data.fields.Service_Line__r.value.fields.Service_Line_Code__c.value;
                this.mappingType = 'Deliverable';

                if(typeof this.newDeliverableTaskRecordTypeId != 'undefined'){
                    this.recordTypeName = 'RDS Deliverable';
                    this.recordTypeId = this.newDeliverableTaskRecordTypeId;
                }
            }
        }
    }

    @wire(getFieldSet, {type: '$mappingType', formSection: 'Details', serviceCode: '$serviceCode', serviceLineCode: '$serviceLineCode'})
    wiredGetDetailsFields(value) {
        this.wiredDetailsFields = value;
       let {error, data } = value;
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {
            this.detailsFields = this.buildFieldsList(data);
            this.status.loading.details = false;
        }
    }

    @wire(getFieldSet, {type: '$mappingType', formSection: 'Service Line', serviceCode: '$serviceCode', serviceLineCode: '$serviceLineCode'})
    wiredGetServiceLineFields(value) {
        this.wiredServiceLineFields = value;
       let {error, data } = value;
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {
            this.serviceLineFields = this.buildFieldsList(data);
            this.status.loading.serviceLine = false;
        }
    }

    @wire(getFieldSet, {type: '$mappingType', formSection: 'Billing'})
    wiredGetBillingFields(value) {
        this.wiredBillingFields = value;
        let {error, data } = value;
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {
            this.billingFields = this.buildFieldsList(data);
            this.status.loading.billing = false;
        }
    }

    @wire(getFieldSet, {type: '$mappingType', formSection: 'System'})
    wiredGetSystemFields(value) {
        this.wiredSystemFields = value;
       let {error, data } = value;
        if (typeof error != 'undefined') {
            ShowToast.error(this, buildErrorMessage(error))
        } else if (typeof data != 'undefined') {
            this.systemFields = this.buildFieldsList(data);
            this.status.loading.system = false;
        }
    }

    @wire(getExistingMisses, {deliverableId: '$recordId'})
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

    get hasServiceLineSection(){
        return (this.serviceLineFields.length > 0);
    }

    get hasBillingSection(){
        return (this.billingFields.length > 0);
    }

    get serviceLineTitle(){
        if(typeof this.serviceLineCode != undefined && this.serviceLineCode != null){
            return this.serviceLineCode + ' Information';
        }
        return 'Service Line Information';
    }

    get recordViewForm(){
        return !this.addRelatedMode && !this.cloneMode && this.status.visible.recordAddForm == false && this.status.visible.recordEditForm == false;
    }

    get addRelatedButton(){
        return this.addRelatedMode && !this.status.visible.recordAddForm;
    }

    get objectName(){
        if( this.objectApiName == 'pse__Milestone__c'){
            return 'pse__Project_Task__c';
        }
        return this.objectApiName;
    }
    
    get recordFields(){
        if( this.objectApiName == 'pse__Milestone__c'){
            return MILESTONE_FIELDS;
        }
        return PROJECT_TASK_FIELDS;
    }

    buildFieldsList( data ){
        let newFields = [];
        for(let fieldName of data){
            if (fieldWithEditPermission.includes(fieldName)) {
                 continue; 
            }
            let field = {fieldName: fieldName};
            if(hiddenFields.includes(fieldName)){
                field.hidden = true;
            }
            if(readOnlyFields.includes(fieldName) || this.formulaFields.includes(fieldName)){
                if(data.includes('Edit_' +fieldName)){
                    field.readOnly = false;
                }
                else{
                    field.readOnly = true;
                }
            }
            else {
                field.readOnly = false;
                if(fieldName === 'Name'){
                    field.required = true;
                }
                else{
                    field.editableAndNotRequired = true;
                }
                
            }
            if(customLookupFields.includes(fieldName)){
                field.isCustomLookup = true;
                field.hiddenFieldName = 'hidden'+fieldName;
            }
            this.applyFieldDefaults(field);
            newFields.push(field);
        }
        this.buildFieldsDependentLookupWorkaround(newFields) // !
        return newFields;
    }

    expandSection(event){
        let sections = this.template.querySelectorAll('.'+event.target.name);
        for(let section of sections){
            section.classList.toggle('slds-is-open');
        }
    }

    editRecord(event){
        console.log('Editing...');
        this.status.visible.recordEditForm = true;
        this.status.modal.busy = true;
    }
    editRecordLoaded(event){
        if(this.status.modal.saving == false) {
            this.status.modal.busy = false;
        }

        this.recordLoadedDependentLookupWorkaround(event) // !
    }
    addRecordLoaded(event){
        //
    }

    saveClicked(){
        console.log("Save clicked.");
        const submitDummy = this.template.querySelector('.submit-dummy');
        if( submitDummy ){
            submitDummy.click();
        }
    }

    interruptSubmit(event){
        this.status.modal.busy = true;
        event.preventDefault();
        console.log('Submit interrupted!');
        this.commitFields = event.detail.fields;

        getValidMetricsForService({projectId: this.parentProjectId, serviceLineId: this.serviceLineId, serviceId: this.serviceId})
        .then(result => {
            if (typeof result != 'undefined') {
                console.log('Metrics:',result);
                let filteredMetrics = [];
                for(let metric of result){
                    filteredMetrics.push(metric);
                }
                if(filteredMetrics.length > 0 && this.hasMiss(this.commitFields, filteredMetrics)){
                    this.status.modal.busy = false;
                    this.showMetricsModal = true;
                } else {
                    this.status.modal.saving = true;

                    if(this.cloneMode){
                        //Submit in Clone Mode
                        this.commitFields.RecordTypeId = this.recordTypeId;
                        const recordInput = { apiName: 'pse__Project_Task__c', fields: this.commitFields };
                        console.log(JSON.parse(JSON.stringify(this.commitFields)));
                        //let fields = {apiName: 'pse__Project_Task__c', fields: this.commitFields};
                        //const recordInput = generateRecordInputForCreate(fields, this.deliverableObjectInfo);
                        createRecord(recordInput)
                        .then(newTask => {
                            this.dispatchEvent(new CustomEvent("recordsaved"), {detail: 'Record saved.'});
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: newTask.id,
                                    actionName: 'view'
                                }
                            });
                        })
                        .catch(error => {
                            this.saveError(error.body);
                        });
                    } else {
                        //Submit in Add or Edit Mode
                        let editForm = this.template.querySelector('lightning-record-edit-form.record-edit-form');
                        if(editForm === null) {
                            editForm = this.template.querySelector('lightning-record-edit-form.record-add-form');
                        }
                        if(editForm != null) {
                            editForm.submit(this.commitFields);
                        }
                    }
                }
            }
        })
        .catch(error => {
            ShowToast.error(this, buildErrorMessage(error))
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Error validating project metrics',
            //         message: error.message,
            //         variant: 'error'
            //     })
            // );
        })
    }

    @api
    saveRecord(event){
        console.log("Save clicked (modal).");
        this.template.querySelector('.CLICK-ME').click();
    }
    cancelSave(){
        this.showMetricsModal = false;
    }
    confirmSave(){
        //First Save the record
        this.status.modal.busy = true;
        this.status.modal.saving = true;
        this.template.querySelector('lightning-record-edit-form.record-edit-form').submit(this.commitFields);
    }
    saveSuccess(event){
        if(this.openInModal == 'true'){
            this.dispatchEvent(new CustomEvent("recordsaved"), {detail: 'Record saved.'});
        } else {
            this.status.visible.recordEditForm = false;
            this.status.visible.recordAddForm = false;
            this.status.modal.busy = false;
        }
        if(this.showMetricsModal == true){
            createMisses({metrics: this.failedMetrics, deliverableId: this.recordId, serviceLine: this.serviceLineName, actualDates: this.missActualDates})
            .then(result => {
                console.log(result);
                ShowToast.success(this, 'Your issues have been created and attached to this deliverable.')
                // new ShowToastEvent({
                //     title: 'Success',
                //     message: 'Your issues have been created and attached to this deliverable.',
                //     variant: 'success'
                // });
                this.showMetricsModal = false;
                this.status.modal.saving = false;
            })
            .catch(error => {
                this.status.modal.saving = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Metric Issues',
                        message: error.message,
                        variant: 'error'
                    })
                );
            })
        } else {
            this.status.modal.saving = false;
            if(this.addRelatedMode == true){
                this.navigateToMilestoneRelatedList();
            }
        }
    }
    saveError(event){
        this.status.modal.saving = false;
        this.status.modal.busy = false;
        let output = event.output;
        if( typeof output != 'undefined'){
            let errors = output.errors;
            let fieldErrors = output.fieldErrors;
            if(errors && errors.length > 0){
                for(let error of errors){
                    console.log('page error: ',error);
                    ShowToast.error(this, buildErrorMessage(error))
                }
            }
            if(fieldErrors && Object.keys(fieldErrors).length > 0){
                for(let field of Object.keys(fieldErrors)){
                    for(let error of fieldErrors[field]){
                        console.log('field error: ',error);
                        ShowToast.error(this, buildErrorMessage(error))
                    }
                }
            }
        }
    }
    cancelEdit(event){
        this.status.visible.recordEditForm = false;
    }
    cancelAdd(event){
        this.status.visible.recordAddForm = false;
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
    showAddRelatedForm(){
        this.status.modal.busy = true;
        this.status.visible.recordAddForm = true;
    }
    handleCustomEditButton(event){
        console.log('Custom edit button received.');
        this.status.visible.recordEditForm = true;
    }
    handlePencilClick(event){
        this.clickedField = event.target.getAttribute('data-id-targetfield');
        this.status.visible.recordEditForm = true;
    }
    handleFormReady(event){
        console.log('Form ready', event);
    }
    fieldChanged(event){
        // console.log('Field changed :' + event.target.name);
        this.fieldChangedDependentLookupWorkaround(event) // !
    }
    handleLookupChange(event){
        const fieldName = event.currentTarget.dataset.idFieldname // data-id-fieldname
        event.detail.value = (event.detail.length > 0) ? event.detail : [null];
        this.writeHiddenLookupField(fieldName, event.detail.value[0]);
        this.fieldChanged(event);
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

    applyFieldDefaults(field){
        if(field.fieldName == 'Activity_Controlling_Picklist__c'){
            field.fieldValue = this.serviceCode;
        }

        //When adding a new record, set some defaults
        if(this.status.visible.recordAddForm || this.addRelatedMode){
            if(field.fieldName == 'Name'){
                field.fieldValue = this.name;
            }
            if(field.fieldName == 'pse__Milestone__c'){
                field.fieldValue = this.milestoneId;
            }
            if(field.fieldName == 'Parent_Project__c'){
                field.fieldValue = this.parentProjectId;
            }
            if(field.fieldName == 'pse__Project__c'){
                field.fieldValue = this.serviceLineProjectId;
            }
            if(field.fieldName == 'Program__c'){
                field.fieldValue = this.programId;
            }
            if(field.fieldName == 'Service_Line__c'){
                field.fieldValue = this.serviceLineId;
            }
            if(field.fieldName == 'Service__c'){
                field.fieldValue = this.serviceId;
            }
            if(field.fieldName == 'Type__c'){
                field.fieldValue = 'Deliverable';
            }
        }

        //When Cloning a record, copy over values
    }

    navigateToMilestoneRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.milestoneId,
                objectApiName: 'pse__Milestone__c',
                relationshipApiName: 'pse__Project_Tasks__r',
                actionName: 'view'
            }
        });
    }

    navigateToMilestonePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.milestoneId,
                actionName: 'view'
            }
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
    get dependsOnFields () {
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
        console.log('wiredGetDrugDependentOptions?', 'selected_Drug__c', this.selected_Drug__c)
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
        const fieldsWithDependencies = this.dependsOnFields
        fieldsWithDependencies.forEach(fldDep => {
            const hasDependsOnField = fields.some(e => e.fieldName === fldDep)
            if (hasDependsOnField) {
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
     * When the controlling lookup field is changed then load/refresh the dependent options
     * @param {*} event
     */
    fieldChangedDependentLookupWorkaround (event) {
        const fieldName = event.currentTarget.dataset.idFieldname // data-id-fieldname
        const fieldsWithDependencies = this.dependsOnFields
        if (fieldsWithDependencies.indexOf(fieldName) > -1) {
            const changedValue = event.detail.value[0] || null
            if (changedValue === null || changedValue === '') {
                // when field is cleared then clear dependent options, selections, and hidden values
                Object.keys(this.dependentLookupItems).forEach(key => {
                    if (this.dependentLookupItems[key].depends_on_field === fieldName) {
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
    recordLoadedDependentLookupWorkaround (event) {
        const record = event.detail.records
        if(typeof record === 'undefined'){
            return
        }
        const fields = record[this.recordId].fields
        if (typeof fields === 'undefined') {
            return
        }
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
    writeHiddenLookupField (fieldName, value) {
        const hiddenLookupField = this.template.querySelector(`lightning-input-field.${fieldName}`)
        if (typeof hiddenLookupField !== 'undefined' && hiddenLookupField !== null) {
            hiddenLookupField.value = value
        }
    }
    // ------------------------------------------------------------------------
}