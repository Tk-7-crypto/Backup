import { LightningElement, track,api,wire } from 'lwc';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import {IsConsoleNavigation,getFocusedTabInfo,closeTab} from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import RECORD_TYPE_NAME from '@salesforce/schema/Case.RecordTypeName__c';
import Account_NAME from '@salesforce/schema/Case.Account_Name_Article__c';
import CASE_TYPE from '@salesforce/schema/Case.Case_Type__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import PRODUCT_NAME from '@salesforce/schema/Case.ProductName__c';
import SUBTYPE_2 from '@salesforce/schema/Case.SubType2__c';
import REPORT_VER_COMP from '@salesforce/schema/Case.Report_Verification_Complexity__c';
import REASON_LEAD_CONS from '@salesforce/schema/Case.Reason_for_Lead_Consultation__c';
import MAINTEN_TYPE from '@salesforce/schema/Case.Maintenance_Type__c';
import ASSET_ID from '@salesforce/schema/Case.AssetId';
import getCreatHistoryPreview from '@salesforce/apex/CNT_CSM_CreateInformationOffering.getCreatHistoryPreview';
export default class Lwc_csm_dataCreatePreview extends LightningElement {
    @api recordId;
    activeSections = ['Categorization','CaseInformation', 'RMSpecialNotRerun','RMSpecialRerun','RMSpecialNotDDD','DataProvisioning','CaseDetails'];
    isSpecialNotRerun = false;
    isSpecialRerun = false;
    isSpecialRerunNotDDD = false;
    isDataProvisioning = false;
    isCTNotLeadQueue = false;
    isExpectedOutcome = false;
    isReportM = false;
    isReportMTRerun = false;
    isAssetFIA = false;
    isVerification = false;
    isMarketDefinition = false;
    @api prop1;
    @wire(CurrentPageReference)
    currentPageReference;
    @track caserecord;
    @track error;
    @track offeringWrapper;
    @wire(IsConsoleNavigation) isConsoleNavigation;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [Account_NAME,ASSET_ID,CASE_STATUS,CASE_TYPE,RECORD_TYPE_NAME,PRODUCT_NAME,SUBTYPE_2,REPORT_VER_COMP,REASON_LEAD_CONS,MAINTEN_TYPE]
    }) wirecase({
        error,
        data
    }) {
        if (error) {
           this.error = error ;  
        } else if (data) {
            var caseRecord = {Id: '', Status:'', Account_Name_Article__c: '', RecordTypeName__c: '',ProductName__c: '', AssetId: '',
            Case_Type__c: '', SubType2__c:'',Report_Verification_Complexity__c: '', Reason_for_Lead_Consultation__c: '',Maintenance_Type__c:''};
            caseRecord.Id = this.recordId;
            caseRecord.Account_Name_Article__c = data.fields.Account_Name_Article__c.value;
            caseRecord.RecordTypeName__c = data.fields.RecordTypeName__c.value;
            caseRecord.ProductName__c = data.fields.ProductName__c.value;
            caseRecord.Case_Type__c = data.fields.Case_Type__c.value;
            caseRecord.Status = data.fields.Status.value;
            caseRecord.SubType2__c = data.fields.SubType2__c.value;
            caseRecord.Report_Verification_Complexity__c = data.fields.Report_Verification_Complexity__c.value;
            caseRecord.Reason_for_Lead_Consultation__c = data.fields.Reason_for_Lead_Consultation__c.value;
            caseRecord.Maintenance_Type__c = data.fields.Maintenance_Type__c.value;
            caseRecord.AssetId = data.fields.AssetId.value;
            if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Case_Type__c == 'Market Definition'){
                this.isMarketDefinition = true;
            }
            if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Case_Type__c == 'Report Maintenance'){
                this.isReportM = true;
                if(caseRecord.Maintenance_Type__c == 'Rerun'){
                    this.isReportMTRerun = true;
                }
            if(caseRecord.SubType2__c == 'Special' && (caseRecord.ProductName__c == 'DDD' || caseRecord.ProductName__c == 'DDD MD' || caseRecord.ProductName__c == 'XPONENT')){
                if(caseRecord.Maintenance_Type__c != 'Rerun'){
                    this.isSpecialNotRerun = true;
                }else if(caseRecord.Maintenance_Type__c == 'Rerun'){
                    this.isSpecialRerun = true;
                }
                
            }else if(caseRecord.SubType2__c == 'Special' && !(caseRecord.ProductName__c == 'DDD' || caseRecord.ProductName__c == 'DDD MD' || caseRecord.ProductName__c == 'XPONENT')){
                this.isSpecialRerunNotDDD = true;
            }
        
        }else if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Case_Type__c == 'Data Provisioning'){
            this.isDataProvisioning = true;
        }
		if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Case_Type__c != 'Lead Queue' ){
            this.isCTNotLeadQueue = true;
        }
        if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.ProductName__c != null && (caseRecord.ProductName__c.toLowerCase().startsWith("fia") || caseRecord.ProductName__c.toLowerCase().startsWith("laad"))){
            this.isAssetFIA = true;
        }

        if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Report_Verification_Complexity__c != 'NO' ){
            this.isExpectedOutcome = true;
        }
        
        if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Status == 'Verification'){
            this.isVerification = true;
        }
        if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.Case_Type__c == 'Report Maintenance'){
            this.isReportMaintenance = true;
        }else{
            this.isReportMaintenance = false;
        }

        if(caseRecord.RecordTypeName__c == 'DATACreateService' && caseRecord.AssetId == undefined){
            this.displayInfo = 'Please fill the Categorization section.';
            this.offeringCheckSize = false;
        }
            this.caseRecord = caseRecord;
            this.init();
        }
    }

    init() {
        getCreatHistoryPreview({caseId: this.recordId})
        .then(result => {
            this.offeringWrapper = result;
            this.offeringUnavailable = !result.isOfferingAvailable;
        })
        .catch(error => {
            this.error = error;
        });
    }

    handlePrintClick () {
        window.print();
    }
}
