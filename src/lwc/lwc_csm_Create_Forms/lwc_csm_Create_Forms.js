import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import RECORD_TYPE_NAME from '@salesforce/schema/Case.RecordTypeName__c';
import Account_NAME from '@salesforce/schema/Case.Account_Name_Article__c';
import CASE_TYPE from '@salesforce/schema/Case.Case_Type__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import PRODUCT_NAME from '@salesforce/schema/Case.ProductName__c';
import ASSET_ID from '@salesforce/schema/Case.AssetId';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import INFORMATION_OFFERING_ID_FIELD from '@salesforce/schema/CSM_Create_Forms__c.Id';
import getCreate from '@salesforce/apex/CNT_CSM_CreateInformationOffering.getCreate';
export default class Lwc_csm_create_information_offering extends NavigationMixin (LightningElement) {
    showSpinner = true;
    offeringUnavailable = true;
    @track offeringCheckSize = true;
    isReportMaintenance = false;
    displayInfo = 'Click the New button to create Product or Market Information record';
    @track offeringWrapper;
    @track caserecord;
    @api recordId;
    @track error;
    tabsInfo = '';
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CASE_NUMBER,Account_NAME,CASE_TYPE,CASE_STATUS,RECORD_TYPE_NAME,PRODUCT_NAME,ASSET_ID]
    }) wirecase({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
           this.showErrorToast();
           this.showSpinner = false;
           
        } else if (data) {
            this.showSpinner = true;
            var caseRecord = {Id: '', CaseNumber: '',Status:'', Account_Name_Article__c: '', RecordTypeName__c: '',ProductName__c: '', Case_Type__c: '',AssetId:''};
            caseRecord.Id = this.recordId;
            caseRecord.CaseNumber = data.fields.CaseNumber.value;
            caseRecord.Account_Name_Article__c = data.fields.Account_Name_Article__c.value;
            caseRecord.RecordTypeName__c = data.fields.RecordTypeName__c.value;
            caseRecord.ProductName__c = data.fields.ProductName__c.value;
            caseRecord.Case_Type__c = data.fields.Case_Type__c.value;
            caseRecord.AssetId = data.fields.AssetId.value;
            caseRecord.Status = data.fields.Status.value;
            if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Case_Type__c == 'Report Maintenance'){
                this.isReportMaintenance = true;
            }else{
                this.isReportMaintenance = false;
            }
            if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.AssetId == undefined){
                this.displayInfo = 'Please fill the Categorization section.';
                this.offeringCheckSize = false;
            }else if(caseRecord.RecordTypeName__c == 'DATACreateService' && (caseRecord.Status == 'Verification' || caseRecord.Status == 'Coding')){
                this.displayInfo = '';
                this.offeringCheckSize = false;
            }else{
                this.displayInfo = 'Click the New button to create Product or Market Information record';
                this.offeringCheckSize = true;
            }
            this.caseRecord = caseRecord;
            this.init();            
        }
    }

    init() {
        getCreate({caseId: this.recordId})
        .then(result => {
            this.offeringWrapper = result;
            this.offeringUnavailable = !result.isOfferingAvailable;
            /*if(result.offering.length < 3){
                this.offeringCheckSize = true;
            }else{
                this.offeringCheckSize = false;
            }*/
            this.showSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.showErrorToast();
            this.showSpinner = false;
        });
    }

    openInformationOfferingForm(event) {
        var createRecord = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'CSM_Create_Forms__c',
                actionName: 'new'                
            },
            state : {
                nooverride: '1',
                count: '1',
                defaultFieldValues:"Case__c="+this.recordId
            },
            
        };
        this[NavigationMixin.Navigate](createRecord);
    
    }

    openOffering(event) {
        var viewRecord = {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'CSM_CREATE_FORMS__r',
                recordId: event.currentTarget.dataset.recordId,
                actionName: 'view'             
            }
        };
        this[NavigationMixin.Navigate](viewRecord);
    }

    navigateToOfferingRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'CSM_CREATE_FORMS__c',
                relationshipApiName: 'CSM_CREATE_FORMS__r',
                actionName: 'view'
            },
        });
    }

    showErrorToast() {
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

    async openNewSubTabHandler() {
        let compDefination = {
            componentDef: "c:lwc_csm_dataReportMaintenance",
            attributes: {
                reportType:this.caseRecord.Case_Type__c,
                recordTypeName:this.caseRecord.RecordTypeName__c,
                productName: this.caseRecord.ProductName__c,
                recordId:this.recordId
            }
        }
        let compBase64 = btoa(JSON.stringify(compDefination));
        let foucedTabInfo = await this.invokeWorkspaceAPI('getFocusedTabInfo');
        if(foucedTabInfo.isSubtab){
            await this.invokeWorkspaceAPI('openSubtab', {
                parentTabId: foucedTabInfo.parentTabId,
                url: `#${compBase64}`,
                focus: true,
                icon:'standard:form',
                label: 'Forms'
            })
        }else{
            await this.invokeWorkspaceAPI('openSubtab', {
                parentTabId: foucedTabInfo.tabId,
                url: `#${compBase64}`,
                focus: true,
                icon:'standard:form',
                label: 'Forms'
            })
        }
    }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    category: "workspaceAPI",
                    methodName: methodName,
                    methodArgs: methodArgs,
                    callback: (err, response) => {
                        if (err) {
                            return reject(err);
                        } else {
                            return resolve(response);
                        }
                    }
                }
            });

            this.dispatchEvent(apiEvent);
        });
    }
}
