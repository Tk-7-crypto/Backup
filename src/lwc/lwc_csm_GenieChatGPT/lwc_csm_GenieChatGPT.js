import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
//import { IsConsoleNavigation, EnclosingTabId, getTabInfo, getFocusedTabInfo, setTabLabel ,setTabHighlighted } from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import CASE_OBJECT from '@salesforce/schema/Case';
import RECORD_TYPE_NAME from '@salesforce/schema/Case.RecordTypeName__c';
import PRODUCT_NAME from '@salesforce/schema/Case.ProductName__c';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import Account_NAME from '@salesforce/schema/Case.Account_Name_Article__c';
import getGenieResolution from '@salesforce/apex/CNT_CSM_GenieChatGPT.getGenieResolution';
import saveFeedBackdata from '@salesforce/apex/CNT_CSM_GenieChatGPT.saveFeedBackdata';
import getTicketGeniedata from '@salesforce/apex/CNT_CSM_GenieChatGPT.getTicketGeniedata';
import hasTicketGeniePermission from "@salesforce/customPermission/CSM_Ticket_Genie_Access";

export default class Lwc_csm_GenieChatGPT extends LightningElement {
    genieType = false;
    genieLanguage  = false;
    showSpinner = true;
    trckrec = true;
    @track radioValue;
    isFeedBackProvided = false;
    isOcePersonal = true;
    showSaveBtn = false;
    isCustomButtonGenie = false;
    @api recordId;
    @track caseRecord;
    @track error;
    @track respRecords;
    @track ticketGenie;
    @track resolutionData;

    get options() {
        return [{ label: '1', value: '1' },{ label: '2', value: '2' },{ label: '3', value: '3' },{ label: '4', value: '4' },{ label: '5', value: '5' }];
    }

    get isTicketGenieEnabled() {
        console.log(' hasTicketGeniePermission : '+hasTicketGeniePermission);
        return hasTicketGeniePermission;
    }
    //@wire(EnclosingTabId) tabId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('getStateParameters');
     if (currentPageReference) {
       const urlValue = currentPageReference.state.c__caseId;
       if (urlValue) {
         this.recordId = urlValue;
         this.isCustomButtonGenie = true;
         //setTabLabel(this.tabId, "Ask Genie");
       }else{
           this.isCustomButtonGenie = false;
       }
     }
    }
    
    onCheckboxChange(event) {
        var checkBoxName = event.target.name;
        if(checkBoxName === 'genieType') {
            this.genieType = event.target.checked;
        }else if(checkBoxName === 'genieLanguage') {
            this.genieLanguage = event.target.checked;
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [RECORD_TYPE_NAME, CASE_NUMBER, Account_NAME, PRODUCT_NAME]
    }) wiredCase({
        error,
        data
    }) {
        this.showSpinner = false;
        console.log('getRecord');
        console.log('getRecord'+this.recordId);
        if (error) {
           this.error = error ;
           console.log('getRecord error : '+ error); 
           this.showToast();
        } else if (data) {
            var caseRecord = {Id: '', CaseNumber: '', Account_Name_Article__c: '', RecordTypeName__c: '',ProductName__c: ''};
            caseRecord.Id = this.recordId;
            caseRecord.CaseNumber = data.fields.CaseNumber.value;
            caseRecord.Account_Name_Article__c = data.fields.Account_Name_Article__c.value;
            caseRecord.RecordTypeName__c = data.fields.RecordTypeName__c.value;
            caseRecord.ProductName__c = data.fields.ProductName__c.value;
            this.caseRecord = caseRecord;
            if(caseRecord && this.isCustomButtonGenie){
                this.askGenie();
            }
            this.isOcePersonal = true;
            
            console.log('getRecord caseRecord : '+ caseRecord); 
        }
    }

    connectedCallback(){
        getTicketGeniedata({recordId: this.recordId}).then(result => {
            var respdata = JSON.parse(result.SuggestedResolution__c);
            var resolutionText = '';
            this.ticketGenie = result;
            for (let i = 0; i < respdata.Resolution.length; i++) {
                resolutionText += respdata.Resolution[i] + '<br>';
              }
              this.resolutionData = resolutionText;
            //var respRecords = {Summary: '', Resolution: [], References: []};
            if(result.FeedBackScore__c > 3 &&  result.FeedBackScore__c != undefined){
                this.showSaveBtn = true;
            }else{
                this.showSaveBtn = false;
            }
            this.radioValue = result.FeedBackScore__c+'';
            this.respRecords = respdata;
            console.log('this.respRecords : '+this.respRecords);
            this.showSpinner = false;
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
    askGenie(){
        if(this.caseRecord.ProductName__c == undefined){
            var toastEvent = new ShowToastEvent({
                title: 'Error',
                message: 'Product Name is Mandatory for '+this.caseRecord.CaseNumber,
                variant: 'Error'
            });
            this.dispatchEvent(toastEvent);
            return;
        }
        if(this.caseRecord.ProductName__c != undefined){
        this.showSpinner = true;
        var caseRecord = this.caseRecord;
        getGenieResolution({caseRecord : caseRecord, genieType : this.genieType, genieLanguage : this.genieLanguage})
            .then(result => {
                var respdata = JSON.parse(result.SuggestedResolution__c);
                this.ticketGenie = result;
                //var respRecords = {Summary: '', Resolution: [], References: []};
                this.radioValue = result.FeedBackScore__c+'';
                if(result.FeedBackScore__c > 3 &&  result.FeedBackScore__c != undefined){
                    this.showSaveBtn = true;
                }else{
                    this.showSaveBtn = false;
                }
                this.respRecords = respdata;
                this.showSpinner = false;
                
            })
            .catch(error => {
                this.error = error;
                this.showToast();
                this.showSpinner = false;
            });
        }
    }

    saveFeedBack(event) {
        saveFeedBackdata({ticketGenie : this.ticketGenie})
            .then(result => {
                var respdata = JSON.parse(result.SuggestedResolution__c);
                this.ticketGenie = result;
                //var respRecords = {Summary: '', Resolution: [], References: []};
                this.radioValue = result.FeedBackScore__c+'';
                if(result.FeedBackScore__c > 3 &&  result.FeedBackScore__c != undefined){
                    this.showSaveBtn = true;
                }else{
                    this.showSaveBtn = false;
                }
                this.respRecords = respdata;
                this.showSpinner = false;
                var toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Feedback added successfully',
                    variant: 'success'
                });
                this.dispatchEvent(toastEvent);
                
            })
            .catch(error => {
                this.error = error;
                this.showToast();
                this.showSpinner = false;
            });

    }

    handleChangeFeedbackComment( event ) {

        console.log( 'Updated Value is ' + event.detail.value );
        this.ticketGenie.Comments__c = event.detail.value;

    }

    handleChangeFeedScore(event) {
        console.log('Option selected with value: ' + event.detail.value);
        this.ticketGenie.FeedBackScore__c = event.detail.value;
    }



}
