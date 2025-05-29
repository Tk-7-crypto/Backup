import { LightningElement,api,wire,track } from 'lwc';
import getReportDrugs from '@salesforce/apex/CNT_PSA_CreateDrugReport.getReportDrugs';
import getRecordDetils from '@salesforce/apex/CNT_PSA_CreateDrugReport.getRecordDetils';
import saveReportDrugs from '@salesforce/apex/CNT_PSA_CreateDrugReport.saveReportDrugs';
import NAME_FIELD from '@salesforce/schema/Aggregate_Report__c.Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";

import { CurrentPageReference } from 'lightning/navigation';

export default class Lwc_psa_newCreateReportDrug extends NavigationMixin(LightningElement) {
    @track isShowModal = false;
    isDropdownOpen = true;
    @track options = [];
    @track filteredOptions =[];
    @track selectedValues = [];
    @track OptionMap = new Map();
    programId = '';
    aggregateReportId ='';
    error;
    @track reportDrugResult = [];
    @track error;
    objectApiName = 'Aggregate_Report__c';
    nameField = NAME_FIELD;
    isLoading =  true;
    recordId;
    isShowModalForDrug = false;
    drugName = '';
    relatedListSize = 0;
    serviceLineName ='';
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference && currentPageReference.attributes) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    connectedCallback(){
        this.isLoading =  true;
        this.getRecords();
        this.isLoading =  false; 
    }
    getRecords(){
        getRecordDetils({recordId: this.recordId}).then((result) => {
            if(result){
                if(result.options){
                    this.options = result.options;
                    this.filteredOptions = result.options;
                    this.selectedValues = result.options.filter(option => option.checked).map(option => option.label);
                }
                if(result.programId){
                    this.programId = result.programId;
                }
                if(result.aggregateReportId){
                    this.aggregateReportId = result.aggregateReportId;
                }
                if(result.serviceLineName){
                    this.serviceLineName = result.serviceLineName;
                }
            }
        })
        .catch(error => {
            console.log('Err occurred'+error);
        });
    }
    
    refreshDrugReport;
    @wire(getReportDrugs, { recordId: '$recordId'})
    wiredGetReportDrugs(value) {
        this.refreshDrugReport = value;
        const { data, error } = value; 
        if (data) {
            this.reportDrugResult = data;
            this.error = undefined;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    
    get listSize() {
        let returnString = 'Report Drugs'
        if(this.reportDrugResult.reportDrugs){
            return returnString+'('+this.reportDrugResult.reportDrugs.length+')';
        }
        return returnString;
    }

    showModalBox() {  
        this.isShowModal = true;
        this.getRecords();
    }

    hideModalBox() {  
        this.isShowModal = false;
        this.isShowModalForDrug = false;
    }
    submitDetails(){
        if(this.selectedValues.length > 0){
            this.isLoading =  true;
            const selectedOption= this.filteredOptions.filter(option => option.isOperation);
            
            saveReportDrugs({ records: selectedOption, aggregateReportId : this.aggregateReportId, programId : this.programId}).then((result) => {
                if(result == 'Success'){
                    const event = new ShowToastEvent({ title: 'Success', message: 'Operation successfully!', variant: 'success' }); this.dispatchEvent(event);
                    this.isShowModal = false; 
                    refreshApex(this.refreshDrugReport);
                    this.isLoading =  false;
                }else{
                    
                    const event = new ShowToastEvent({ title: 'Error', message: result, variant: 'error' }); this.dispatchEvent(event);
                    this.isLoading =  false;
                }
            })
            .catch(error => {
            
                const event = new ShowToastEvent({ title: 'Error', message: this.handleError(error), variant: 'error' }); this.dispatchEvent(event);
                this.isLoading =  false;
            });
        }
        else{
            const event = new ShowToastEvent({ title: 'Error', message: 'Please select atleast one Drug', variant: 'error' }); this.dispatchEvent(event);
        }
    }

    handleError(error) {

        let message = 'Something went wrong!';
        // Check if the error has a body
        if (error.body) {
            if (Array.isArray(error.body)) {
            // If body is an array, extract messages
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
        } else if (typeof error.message === 'string') {
            message = error.message;
        }
        console.error('Error: ', message);
        return message;
    }


    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        this.filteredOptions = this.options.filter(option =>
        option.label.toLowerCase().includes(searchTerm)
    );
    }
    
    handleCheck(event) {
        
        this.showPageSpinner = true;
        const value = event.target.dataset.id;
        const updatedOptions = this.filteredOptions.map(option => {
        if (option.value === value) {
            option.checked = !option.checked;
            option.isOperation = true;
            }
        return option;
        });
        this.options = updatedOptions;
        this.filteredOptions = updatedOptions;
        this.selectedValues = updatedOptions.filter(option => option.checked).map(option => option.label);
        this.showPageSpinner = false;
    } 

    get selectedLabels() {
        let selectedValues = this.filteredOptions.filter(option => option.checked).map(option => option.label)
        return this.selectedValues.length ? selectedValues.join(', '): ' Select Drugs';
    }
    newDrug() {
        this.isShowModalForDrug = true;
    }
    hideDrugModalBox(){
        this.isShowModalForDrug = false;
    }
    handleChange(event){
        this.drugName = event.detail.value;
    }
    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        let service_Lines = this.template.querySelector('[data-id="Service_Lines"]');
        let serviceLines = service_Lines.value.split(';');
        if (service_Lines.value && !service_Lines.value.includes(this.serviceLineName)) {
            serviceLines = [...serviceLines,this.serviceLineName];
        }else{
            serviceLines = [...serviceLines];
        } 
        fields.Service_Lines__c = serviceLines.map(e => e).join(';');
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
     }
     handleSuccess(event){

        const creatededRecordId = event.detail.id;
        const newItem = {
            label: this.drugName,
            value: creatededRecordId,
            checked: true,
            isOperation : true,
            reportDrugId : ''
        };
        this.filteredOptions = [...this.options, newItem];
        this.selectedValues = [...this.selectedValues, this.drugName];
        const event1 = new ShowToastEvent({ title: 'Success', message: 'Record created successfully!', variant: 'success' }); this.dispatchEvent(event1);
        this.isShowModalForDrug = false;
     }
     
}
