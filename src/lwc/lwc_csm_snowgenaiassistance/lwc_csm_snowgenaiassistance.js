import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from 'lightning/navigation';
//import { IsConsoleNavigation, EnclosingTabId, getTabInfo, getFocusedTabInfo, setTabLabel ,setTabHighlighted } from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecord } from 'lightning/uiRecordApi';
import RECORD_TYPE_NAME from '@salesforce/schema/Case.RecordTypeName__c';
import PRODUCT_NAME from '@salesforce/schema/Case.ProductName__c';
import LOS from '@salesforce/schema/Case.LOS__c';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import Account_NAME from '@salesforce/schema/Case.Account_Name_Article__c';
import getSummaryDetails from '@salesforce/apex/CNT_CSM_SNOWChatGPT.getSummaryDetails';
import askCaseAssistance from '@salesforce/apex/CNT_CSM_SNOWChatGPT.askCaseAssistance';
import getCaseAssistance from '@salesforce/apex/CNT_CSM_SNOWChatGPT.getCaseAssistance';
import getCopilotCustomSettings from '@salesforce/apex/CNT_CSM_SNOWChatGPT.getCopilotCustomSettings';
import saveEmailasDraft from '@salesforce/apex/CNT_CSM_SNOWChatGPT.saveEmailasDraft';
import saveKBDraft from '@salesforce/apex/CNT_CSM_SNOWChatGPT.saveKBDraft';
import saveCaseResolution from '@salesforce/apex/CNT_CSM_SNOWChatGPT.saveCaseResolution';
export default class Lwc_csm_snowgenaiassistance extends NavigationMixin (LightningElement) {
    coPilotType;
    showSpinner = true;
    askType;
    @track radioValue;
    isFeedBackProvided = false;
    showSaveBtn = false;
    @api recordId;
    @track options = [];
    @track langValue ='English';
    @track langCode ='en_US';
    value;
    @track caseRecord;
    @track error;
    @track respRecords;
    @track resolutionData;
    event1;
    timeSpan = 10000;
    isDraftEmail = false;
    isDraftKB = false;
    kbvId;
    isKBView = false;
    isCaseResolution = false;
    @track languages = [];
    handleChange(event) {
        this.askType = event.detail.value;
        if(this.askType == 'Draft Article Question-Answer' || this.askType == 'Draft Article Information'){
            this.langValue ='English';
            this.langCode ='en_US';
            this.languages = [
                { label: 'Czech', value: 'cs' },
                { label: 'Dutch', value: 'nl_NL' },
                { label: 'English', value: 'en_US' },
                { label: 'French', value: 'fr' },
                { label: 'German', value: 'de' },
                { label: 'Hungarian', value: 'hu' },
                { label: 'Italian', value: 'it' },
                { label: 'Polish', value: 'pl' },
                { label: 'Russian', value: 'ru' },
                { label: 'Spanish', value: 'es' }];
        }else {
          this.languages =
          [
             { label: 'Bulgarian', value: 'bg' },
             { label: 'Czech', value: 'cs' },
             { label: 'Danish', value: 'da' },
             { label: 'Dutch', value: 'nl_NL' },
             { label: 'English', value: 'en_US' },
             { label: 'Finnish', value: 'fi' },
             { label: 'French', value: 'fr' },
             { label: 'German', value: 'de' },
             { label: 'Greek', value: 'el' },
             { label: 'Hindi', value: 'hi' },
             { label: 'Hungarian', value: 'hu' },
             { label: 'Italian', value: 'it' },
             { label: 'Norwegian', value: 'no' },
             { label: 'Polish', value: 'pl' },
             { label: 'Romanian', value: 'ro' },
             { label: 'Russian', value: 'ru' },
             { label: 'Slovak', value: 'sk' },
             { label: 'Spanish', value: 'es' },
             { label: 'Swedish', value: 'sv' },
             { label: 'Turkish', value: 'tr' }
         ];  
        }
    }
    handleLanguageChange(event) {
        this.langCode = event.detail.value;
        for (let i = 0; i < this.languages.length; i++) {
            if(this.langCode == this.languages[i].value){
                this.langValue = this.languages[i].label;
                break;
            }
        
        }
    }
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [RECORD_TYPE_NAME, CASE_NUMBER, Account_NAME, PRODUCT_NAME,LOS]
    }) wiredCase({
        error,
        data
    }) {
        this.showSpinner = false;
        if (error) {
           this.error = error ;
           console.log('getRecord error : '+ error);
           this.showToast();
        } else if (data) {
            var caseRecord = {Id: '', CaseNumber: '', Account_Name_Article__c: '', RecordTypeName__c: '',ProductName__c: '',los__c:''};
            caseRecord.Id = this.recordId;
            caseRecord.CaseNumber = data.fields.CaseNumber.value;
            caseRecord.Account_Name_Article__c = data.fields.Account_Name_Article__c.value;
            caseRecord.RecordTypeName__c = data.fields.RecordTypeName__c.value;
            if((caseRecord.RecordTypeName__c == 'DATACase' || caseRecord.RecordTypeName__c == 'DATACreateService' || caseRecord.RecordTypeName__c == 'TechnologyCase') && data.fields.ProductName__c != undefined){
                caseRecord.ProductName__c = data.fields.ProductName__c.value;
            }else if((caseRecord.RecordTypeName__c == 'ActivityPlan' || caseRecord.RecordTypeName__c == 'RandDCase' || caseRecord.RecordTypeName__c == 'ClinicalTrialPayment' || caseRecord.RecordTypeName__c == 'ConnectedDevicePatient' || caseRecord.RecordTypeName__c == 'VirtualTrialsCase') && data.fields.LOS__c != undefined){
                caseRecord.los__c = data.fields.LOS__c.value;
            }
            this.caseRecord = caseRecord;
        }
    }

    @wire(getCopilotCustomSettings,{
        recordId: '$recordId'
    })
    copilotCustomSettings({
        error,
        data
    }) {
        this.showSpinner = false;
        if (error) {
           this.error = error ;
           this.showToast();
        } else if (data) {
            for (let i = 0; i < data.length; i++) {
                this.options.push({ label: data[i], value: data[i] });
            }
            
        }
    }

    connectedCallback(){
        this.languages =
         [
            { label: 'Bulgarian', value: 'bg' },
            { label: 'Czech', value: 'cs' },
            { label: 'Danish', value: 'da' },
            { label: 'Dutch', value: 'nl_NL' },
            { label: 'English', value: 'en_US' },
            { label: 'Finnish', value: 'fi' },
            { label: 'French', value: 'fr' },
            { label: 'German', value: 'de' },
            { label: 'Greek', value: 'el' },
            { label: 'Hindi', value: 'hi' },
            { label: 'Hungarian', value: 'hu' },
            { label: 'Italian', value: 'it' },
            { label: 'Norwegian', value: 'no' },
            { label: 'Polish', value: 'pl' },
            { label: 'Romanian', value: 'ro' },
            { label: 'Russian', value: 'ru' },
            { label: 'Slovak', value: 'sk' },
            { label: 'Spanish', value: 'es' },
            { label: 'Swedish', value: 'sv' },
            { label: 'Turkish', value: 'tr' }
        ];
    
        getSummaryDetails({recordId: this.recordId}).then(result => {
            this.respRecords = result;
            this.showSpinner = false;
            for (let i = 0; i < this.respRecords.length; i++) {
                
                if(this.respRecords[i].Type__c == 'Draft Close Resolution'){
                    this.isCaseResolution = true;
                }else{
                    this.isCaseResolution = false;
                }
                if(this.respRecords[i].Type__c == 'Draft Email'){
                    this.isDraftEmail = true;
                }else{
                    this.isDraftEmail = false;
                }
                if(this.respRecords[i].Type__c == 'Draft Article Question-Answer' || this.respRecords[i].Type__c == 'Draft Article Information'){
                    if(this.respRecords[i].Knowledge__c != undefined){
                        this.isKBView = true;
                        this.kbvId = this.respRecords[i].Knowledge__c;
                        this.isDraftKB = false;
                    }else{
                        this.isKBView = false;
                        this.isDraftKB = true;
                    }
                }else{
                    this.isDraftKB = false;
                }
            }
        }).catch(error => {
            this.error = error;
            this.showToast();
            this.showSpinner = false;
        });
   }

    showToast() {
        var error = this.error;
        if(error != undefined && error != null && error != '' && error.body != undefined && error.body != null && error.body != '') {
            var errorMessage = error.body.message;
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
        }
    }
    askAssistance(){
        if(this.askType == undefined || this.langValue == undefined){
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message:  'Co-Pilot Type is Mandatory',
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        if((this.caseRecord.RecordTypeName__c == 'DATACase' || this.caseRecord.RecordTypeName__c == 'DATACreateService' || this.caseRecord.RecordTypeName__c == 'TechnologyCase') && this.caseRecord.ProductName__c == undefined){
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: this.caseRecord.RecordTypeName__c == 'DATACreateService' ? 'Asset is Mandatory for '+this.caseRecord.CaseNumber : 'Product Name is Mandatory for '+this.caseRecord.CaseNumber,
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }else if((this.caseRecord.RecordTypeName__c == 'ActivityPlan' || this.caseRecord.RecordTypeName__c == 'RandDCase' || this.caseRecord.RecordTypeName__c == 'ClinicalTrialPayment' || this.caseRecord.RecordTypeName__c == 'ConnectedDevicePatient' || this.caseRecord.RecordTypeName__c == 'VirtualTrialsCase') && this.caseRecord.los__c == undefined){
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Los is Mandatory for '+this.caseRecord.CaseNumber,
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        if(this.caseRecord.ProductName__c != undefined || this.caseRecord.Los__c != undefined){
        this.showSpinner = true;
        var caseRecord = this.caseRecord;
        askCaseAssistance({caseId : this.caseRecord.Id, askType : this.askType, language : this.langValue, langCode: this.langCode})
            .then(result => {
                if(result && result[0].sys_Id__c == 'Failed'){
                    this.showSpinner = false;
                    var toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'We are unable to connect to the service, please try again later.',
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                    return;
                }else{
                this.event1 = setInterval(() => {
                 if(result){
                   getCaseAssistance({caseId : this.caseRecord.Id, sys_id : result[0].sys_Id__c, askType : this.askType})
                        .then(getresult => {
                         if (getresult.length > 0){
                            clearInterval(this.event1);
                            this.respRecords = getresult;
                            this.showSpinner = false;
                            
                            if(this.askType == 'Draft Close Resolution'){
                                this.isCaseResolution = true;
                            }else{
                                this.isCaseResolution = false;
                            }
                            if(this.askType == 'Draft Email'){
                                this.isDraftEmail = true;
                            }else{
                                this.isDraftEmail = false;
                            }
                            if(this.askType == 'Draft Article Question-Answer' || this.askType == 'Draft Article Information'){
                                this.isDraftKB = true;
                                this.isKBView = false;
                            }else{
                                this.isDraftKB = false;
                                this.isKBView = false;
                            }
                        }
                    })
                    .catch(error => {
                      clearInterval(this.event1);
                      this.error = error;
                      this.showToast();
                      this.showSpinner = false;
                    });
                }
                }, this.timeSpan);
            }
            })
            .catch(error => {
                this.error = error;
                this.showToast();
                this.showSpinner = false;
            });
        }
    }

    handleSaveEmailDraft(event) {

        saveEmailasDraft({caseId: this.recordId, contentId:event.currentTarget.dataset.id}).then(result => {
            var toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'The Draft email has been created. Please review its content before sending as it was generated by AI',
                variant: 'Success'
            });
            this.dispatchEvent(toastEvent);
        }).catch(error => {
            this.error = error;
            this.handleError(error, 'handleSaveEmailDraft');
            this.showSpinner = false;
        });

    }

    handleSaveKBDraft(event) {

        saveKBDraft({caseId: this.recordId, contentId:event.currentTarget.dataset.id,langCode: this.langCode}).then(result => {
            
            for (let i = 0; i < result.length; i++) {
                console.log('result[i].message : '+result[i].Message__c);
                console.log('result[i].Knowledge : '+result[i].Knowledge__c);
                if(result != null && result[i].Knowledge__c != undefined ){
                    var toastEvent = new ShowToastEvent({
                       title: 'Success',
                       message: 'The Draft Knowledge article has been created. Please review its content before publish as it was generated by AI',
                       variant: 'Success'
                    });
                    this.dispatchEvent(toastEvent);
                    if((result[i].Type__c == 'Draft Article Question-Answer' || result[i].Type__c == 'Draft Article Information') ){
                        if(result[i].Knowledge__c != undefined){
                            this.isKBView = true;
                            this.isDraftKB = false;
                            this.kbvId = result[i].Knowledge__c;
                        }else{
                            this.isKBView = false;
                            this.isDraftKB = true;
                        }
                        
                    }
                }else if(result[i].Message__c != undefined){
                    var toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: result[i].Message__c,
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
        }).catch(error => {
            this.error = error;
            this.handleError(error, 'handleSaveKBDraft');
            this.showSpinner = false;
        });

    }

    handleViewKBDraft(event) {
        var viewRecord = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Knowledge__kav',
                recordId: this.kbvId,
                actionName: 'view'
            }
        };
        this[NavigationMixin.Navigate](viewRecord);
    }

    handleSaveCaseResolution(event) {
        this.showSpinner = true;
        saveCaseResolution({caseId: this.recordId, contentId:event.currentTarget.dataset.id}).then(result => {
            for (let i = 0; i < result.length; i++) {
                if(result != null && result[i].Message__c == undefined ){
                    var toastEvent = new ShowToastEvent({
                       title: 'Success',
                       message: 'The Close Rsolution has been updated. Please review its content before publish as it was generated by AI',
                       variant: 'Success'
                    });
                    this.dispatchEvent(toastEvent);
                    this.isKBView = false;
                    this.isDraftKB = false;
                    this.isDraftEmail = false;
                    if(result[i].Type__c == 'Draft Close Resolution'){
                        this.isCaseResolution = true;
                    }else{
                         this.isCaseResolution = false;
                    }
                }else if(result[i].Message__c != undefined){
                    var toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: result[i].Message__c,
                        variant: 'Error'
                    });
                    this.dispatchEvent(toastEvent);
                }
            }
            this.showSpinner = false;
        }).catch(error => {
            this.error = error;
            this.handleError(error, 'handleSaveCaseResolution');
            this.showSpinner = false;
        });

    }

    handleError(error, methodName) {
        console.log(methodName + ' : ' + JSON.stringify(error));
        this.error = new Set();
        if (Array.isArray(error)) {
            error.forEach(currentError => {
                this.error.add(currentError);
            });
        } else {
            var err = error.body ? (error.body.message ? JSON.stringify(error.body.message) : JSON.stringify(error.body)) : JSON.stringify(error);
            if (JSON.parse(err).fieldErrors) {
                let fieldError = JSON.parse(err).fieldErrors;
                for (let [key, value] of Object.entries(fieldError)) {
                    this.error.add(key + ': ' + value[0].message);
                }
            } else {
                this.error.add(err == "{}" ? 'Unexpected error !!!' : err);
            }
        }
        var toastEvent = new ShowToastEvent({
            title: 'Error',
            message: error,
            variant: 'Error'
        });
        this.dispatchEvent(toastEvent);
    }
    

}
