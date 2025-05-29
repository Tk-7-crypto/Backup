import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAgreementFieldsForValidation from '@salesforce/apex/CNT_CLM_ActionPanel.getAgreementFieldsForValidation';
import getSectionData from '@salesforce/apex/CNT_CLM_ActionPanel.getSectionData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
const FIELD_ERROR = 'Complete this field.';
const DATE_ERROR = 'Perpetual checkbox OR Agreement End Date';
const BCP_ERROR = 'Estimate % of budget related to BCP is mandatory for BCP service.';
const LOG_PERMISSION_ERROR = 'Sorry, you don\'t have permissions TO ACTIVATE the Agreement, Please Contact your REGIONAL SIGNATURE MAILBOX.';
const QUOTE_ERROR = 'Agreement can\'t be Activated because related Quote validation exists';
const MSA_FIELD = 'Related_Master_Agreement__c';

export default class Lwc_clm_childActionPanel extends NavigationMixin(LightningElement) {
    @api logo;
    @api link;
    @api label;
    @api flowApiName;
    isOpen = false;
    @api action;
    isModalOpen;
    fields = [];
    @track dateSection = [];
    isLoading;
    @track sectionData;
    @api recordId;
    formVal;
    hasError = false;
    logError;
    quoteError;
    hasField;
    isValid;
    richText;

    handleOnClick(event) {
        if(this.action) {
            this.hasError = false;
            this.isModalOpen = true;
            getAgreementFieldsForValidation({
                recordId: this.recordId,
                action: this.action
            })
            .then((result) => {
                this.fields = result;
                let tNo;
                this.fields.forEach(e => {
                    if(e.includes(LOG_PERMISSION_ERROR)) {
                        this.logError = e;
                    }
                    if(e.includes(QUOTE_ERROR)) {
                        this.quoteError = e;
                    }
                    if(e.includes('__c')) {
                        this.hasField = true;
                    }
                });
                if((this.logError || this.quoteError) && this.hasField) {
                    this.isValid = false;
                    this.hasError = true;
                }
                else if(this.hasField) {
                    this.isValid = false;
                }
                else {
                    this.isValid = true;
                }
                this.richText = (this.logError ? this.logError : '') + '<br/><br/>' + (this.quoteError ? this.quoteError : '');
                if(this.fields[0] == '') {
                    this.isModalOpen = false;
                    this.navigateToPage();
                }
                else {
                    this.sectionData.forEach((elem, i) => {
                        elem.toggleClass = 'slds-section slds-is-open';
                        elem.key = (elem.key.replace('_Tab__c', '')).replaceAll('_', ' ');
                        elem.value = elem.value.filter((e) => this.fields.includes(e));
                        if(elem.key == 'Term And Renewal') {
                            tNo = i;
                        }
                        if(elem.key == 'Information' && elem.value && elem.value.includes('Related_Master_Agreement__c')) {
                            const item = this.template.querySelector(`[data-role="${MSA_FIELD}"]`);
                            if(item) {
                                item.style = 'display:none';
                            }
                            elem.hasMSA = true;
                        }
                    });
                    if(tNo) {
                        let dateVal = this.sectionData[tNo];
                        this.dateSection = [...this.dateSection, dateVal];
                        this.sectionData.splice(tNo, 1);
                    }
                    else {
                        this.dateSection = [];
                    }
                    this.isLoading = true;
                }
            })
            .catch((error) => {
                console.log(error);
                this.richText = '<b>An unexpected error has occurred. Please contact the support team for help.</b><br/><b>Error Details : </b>'+error.body?.message;
                this.isValid = true;
                this.isLoading = true;
            });
        }
        else if(this.flowApiName) {
            this.isOpen = true;
        }
        else {
            this.navigateToPage();
        }
    }

    get inputVariables() {
        return [{
            name: "recordId",
            type: "String",
            value: this.link
        }];
    }

    closeFlowModal(event) {
        this.isOpen = false;
        window.location = '/lightning/r/Apttus__APTS_Agreement__c/' + this.link + '/view';
    }

    closeModal() {
        this.isModalOpen = false;
        window.location = '/lightning/r/Apttus__APTS_Agreement__c/' + this.recordId + '/view';
    }

    @wire(getSectionData)
    wiredSection({ error, data }) {
        if(data) {
            this.sectionData = Object.entries(data).map(([key, value]) => ({
                key,
                value: data[key]
            }));
        }
        if(error) {
            console.log(error);
        }
    }

    handleToggleClick(event) {
        var j = event.target.getAttribute('data-index');
        let k = event.currentTarget.getAttribute('data-index');
        this.sectionData[k].toggleClass = (this.sectionData[k].toggleClass == 'slds-section slds-is-open') ? 'slds-section' : 'slds-section slds-is-open';
    }

    handleToggleClickDate(event) {
        var j = event.target.getAttribute('data-index');
        let k = event.currentTarget.getAttribute('data-index');
        this.dateSection[k].toggleClass = (this.dateSection[k].toggleClass == 'slds-section slds-is-open') ? 'slds-section' : 'slds-section slds-is-open';
    }

    handleOnSubmit(event) {
        let hasError = false;
        event.stopPropagation();
        event.preventDefault();
        const fields = event.detail.fields;
        this.formVal = fields;
        let fieldArr = Object.keys(fields);
        fieldArr.forEach(f => {
            if((f == 'Apttus__Contract_End_Date__c' || f == 'Apttus__Perpetual__c')
                && (fields.Apttus__Contract_End_Date__c == null && fields.Apttus__Perpetual__c == false)) {
                hasError = true;
                let f2 = this.template.querySelector(`[data-id="${'Apttus__Contract_End_Date__c'}"]`);
                f2.setErrors({ 'body': { 'output': { 'fieldErrors': { 'Apttus__Contract_End_Date__c': [{ 'message': '' + DATE_ERROR + '' }] } } } });
                let f3 = this.template.querySelector(`[data-id="${'Apttus__Perpetual__c'}"]`);
                f3.setErrors({ 'body': { 'output': { 'fieldErrors': { 'Apttus__Perpetual__c': [{ 'message': '' + DATE_ERROR + '' }] } } } });
            }
            else if(fields[f] == null && (f != 'Apttus__Contract_End_Date__c' && f != 'Apttus__Perpetual__c' && f != MSA_FIELD)) {
                hasError = true;
                let f1 = this.template.querySelector(`[data-id="${f}"]`);
                f1.setErrors({ 'body': { 'output': { 'fieldErrors': { [f]: [{ 'message': '' + FIELD_ERROR + '' }] } } } });
            }
        });
        let lookup = this.template.querySelector('c-lwc_clm_custom-lookup');
        if(lookup) {
            if(lookup.selectedRecord) {
                this.formVal.Related_Master_Agreement__c = lookup.selectedRecord.Id;
            }
            else {
                lookup.hasError = true;
                lookup.inputClass = 'slds-combobox__form-element slds-has-error';
                hasError = true;
            }
        }
        if(!hasError) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.isLoading = false;
        }
    }

    handleOnError(event) {
        let errorMessage = event.detail.detail;
        const evt = new ShowToastEvent({
            title: 'Error Occurred !!',
            message: errorMessage,
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
        if(errorMessage && errorMessage.includes(BCP_ERROR)) {
            this.formVal.Services__c = null;
            this.hasError = true;
            this.template.querySelector('lightning-record-edit-form').submit(this.formVal);
        }
        this.isModalOpen = false;
    }

    handleOnSuccess(event) {
        this.isLoading = true;
        event.preventDefault();
        this.isModalOpen = false;
        if(!this.hasError) {
            this.navigateToPage();
        }
        else {
            this.dispatchEvent(new RefreshEvent());
        }
        if(!this.isValid && (this.action == 'activate')) {
            this.isValid = true;
            if(this.hasError) {
                this.isModalOpen = true;
            }
        }
    }

    handleFieldClick(event) {
        let fieldClicked = event.target.dataset.id;
        let f4 = this.template.querySelector(`[data-id="${'Apttus__Contract_End_Date__c'}"]`);
        let f5 = this.template.querySelector(`[data-id="${'Apttus__Perpetual__c'}"]`);
        if(fieldClicked == 'Apttus__Perpetual__c') {
            f4.reset();
        }
        else if(fieldClicked == 'Apttus__Contract_End_Date__c') {
            f5.reset();
        }
    }

    navigateToPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.link
            }
        }).then(generatedUrl => {
            window.open(generatedUrl, "_self");
        });
    }

    spanClick(event) {
        event.preventDefault();
    }
}