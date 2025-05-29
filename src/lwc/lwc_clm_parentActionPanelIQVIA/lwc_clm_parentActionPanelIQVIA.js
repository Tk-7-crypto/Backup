import { LightningElement, api, track, wire } from 'lwc';
import getAgreementDetails from '@salesforce/apex/CNT_CLM_ActionPanelIQVIA.getAgreementDetails';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import apttusResource from '@salesforce/resourceUrl/LightningResource';
import docusignImage1 from '@salesforce/resourceUrl/CorrecteSigantureDocumentAP';
import docusignImage2 from '@salesforce/resourceUrl/RecalleSignatureRequestAP';
import docusignImage3 from '@salesforce/resourceUrl/SendeSignatureReminderAP';
import IQVIAResource from '@salesforce/resourceUrl/IQVIAAgreementResource';
import isTeamLead from '@salesforce/customPermission/USBU_Team_Lead';
import isContractAnalyst from '@salesforce/customPermission/USBU_Contract_Analyst';
import isIQVIALicensedUser from '@salesforce/customPermission/CLM_IQVIA_Licensed_User';
const NAME_FIELD = ['IQVIA_Agreement__c.Name']
import CURRENT_USERID from "@salesforce/user/Id";

export default class Lwc_clm_parentActionPanel extends LightningElement {
    @api recordId;
    @api objectApiName;
    result;
    @track agreementData;
    generateLink;
    generateLogo = apttusResource + '/images/actions/generate.svg';
    assignLogo = IQVIAResource + '/images/actions/IQVIAAgrAssign.svg';
    deliverLogo = IQVIAResource + '/images/actions/IQVIAAgrDeliver.svg';
    internalBusinessReviewLogo = IQVIAResource + '/images/actions/IQVIAAgrInternalBusinessReview.svg';
    reassignLogo = IQVIAResource + '/images/actions/IQVIAAgrReassign.svg';
    sendFeedbackLogo = IQVIAResource + '/images/actions/IQVIAAgrSendFeedback.svg';
    regenerateLink;
    regenerateLogo = apttusResource + '/images/actions/regenerate.svg';
    isUploadSignedDocument;
    uploadSignedDocumentLogo = apttusResource + '/images/actions/markassigned.svg';
    isAssign;
    isReassign;
    isAccept;
    isDeliver;
    isRequestReview;
    requestReviewLogo = IQVIAResource + '/images/actions/IQVIAAgrRequestReview.svg';
    importOfflineDocumentLogo = apttusResource + '/images/actions/importofflinedocument.svg';
    importOfflineDocumentLink;
    sendForReviewLogo = apttusResource + '/images/actions/sendforreview.svg';
    office365ReviewLink;
    isSOWAmend;
    isMSAAmend;
    isOAAmend;
    isMSAExpire;
    amendLogo = apttusResource + '/images/actions/amend.svg';
    previewLogo = apttusResource + '/images/actions/preview.svg';
    expireLogo = apttusResource + '/images/actions/expire.svg';
    previewLink;
    showFirstBlock;
	showSecondBlock;
    showThirdBlock;
    requestSignatureSupportLogo = IQVIAResource + '/images/actions/IQVIAAgrRequestSignatureSupport.svg';
    isRequestSignature;
    cancelRequestLink;
    cancelRequestLogo = apttusResource + '/images/actions/cancelrequest.svg';
    sendForESignatureLogo = apttusResource + '/images/actions/sendforesignature.svg';
    sendForESignatureLink;
    checkESignatureStatusLogo = apttusResource + '/images/actions/docusigncheckstatus.svg';
    checkESignatureStatusLink;
    correctESignatureRecipientLogo = docusignImage1;
    correctESignatureRecipientLink;
    recallVoidESignatureRequestLogo = docusignImage2;
    recallVoidESignatureRequestLink;   
    resendESignatureReminderLogo = docusignImage3;
    resendESignatureReminderLink;

 
    /**
    * This method is used to refresh component
    * @param result 
    */
    @wire(getRecord, { recordId: '$recordId', fields: NAME_FIELD }) testRecord(result) {
        refreshApex(this.result);
    }

    /**
    * This method gets agreement action panel fields
    * @param result 
    */
    @wire(getAgreementDetails, { agreementId: '$recordId' }) agreement(result) {
        this.result = result;
        if (result.data) {
            try {    
                this.agreementData = result.data;
                this.generateLink = false;
                this.regenerateLink = false;
                this.isUploadSignedDocument = false;
                this.isAssign = false;
                this.isReassign = false;
                this.isAccept = false;
                this.isDeliver = false;
                this.isRequestReview = false;
                this.office365ReviewLink = false;
                this.isInternalBusinessReview = false;
                this.isSendFeedback = false;
                this.isSOWAmend = false;
                this.isOAAmend = false;
                this.showFirstBlock = false;
                this.showSecondBlock = false;
                this.cancelRequestLink = false;
                this.isMSAAmend = false;
                this.previewLink = false;
                this.isMSAExpire = false;
                this.showThirdBlock = false;
                this.isRequestSignature = false;
                this.importOfflineDocumentLink = false;
                this.sendForESignatureLink = false;
                this.checkESignatureStatusLink = false;
                this.correctESignatureRecipientLink = false;
                this.recallVoidESignatureRequestLink = false;
                this.resendESignatureReminderLink = false;

                if (this.agreementData.Has_Conga__c && this.agreementData.Generate_AP_Custom__c && CURRENT_USERID === this.agreementData.OwnerId 
                    && isContractAnalyst && (this.agreementData.Helper__c == null || (this.agreementData.Helper__c != null && (!(this.agreementData.Is_Other_Agreement__c && this.agreementData.Version_Number__c == 0) && !(this.agreementData.Helper__c.includes('Self-Service SOW')))))) {
                    this.generateLink = (String(this.agreementData.Generate_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData.Has_Conga__c && this.agreementData.Regenerate_AP_Custom__c && CURRENT_USERID === this.agreementData.OwnerId 
                    && ((isContractAnalyst && this.agreementData.Status__c != 'Other Party Review')
                    || (this.agreementData.Status__c == 'Other Party Review') && (!isContractAnalyst && isIQVIALicensedUser))) {
                    this.regenerateLink = (String(this.agreementData.Regenerate_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if((isContractAnalyst && CURRENT_USERID == this.agreementData.OwnerId && (this.agreementData.Status_Category__c == 'In Authoring' || (this.agreementData.Status_Category__c == 'In Signatures' && (this.agreementData.Status__c == 'Ready for Signatures' || this.agreementData.Status__c == 'Sent for Signatures'))))
                    || (this.agreementData.Status__c == 'Other Party Review' && !isContractAnalyst)) {
                    this.isUploadSignedDocument = true;
                }
                if(isContractAnalyst && ((this.agreementData.Status_Category__c == 'Request' && this.agreementData.Status__c == 'Request')
                    || (this.agreementData.Helper__c != null && !this.agreementData.Helper__c.includes('Assigned') 
                    && this.agreementData.Helper__c.includes('Self-Service SOW') && this.agreementData.Status__c == 'Internal Review'))) {
                    this.isAssign = this.recordId;
                }
                if(isContractAnalyst && this.agreementData.Helper__c != null && this.agreementData.Helper__c.includes('Assigned') &&
                    (this.agreementData.Status__c == 'Author Contract' || 
                    this.agreementData.Status__c == 'Internal Review' || this.agreementData.Status__c == 'Assigned' || this.agreementData.Status__c == 'Ready for Signatures')) {
                    this.isReassign = this.recordId;
                }
                if((this.agreementData.Status_Category__c == 'Request' || this.agreementData.Status_Category__c == 'In Authoring' 
                    || this.agreementData.Status_Category__c == 'In Signatures') 
                    && this.agreementData.Status__c != 'Cancelled Request' 
                    && CURRENT_USERID === this.agreementData.OwnerId) {
                    this.cancelRequestLink = this.recordId;
                }
              /*if(this.agreementData.Status_Category__c == 'Request' && ((isTeamLead && (this.agreementData.Status__c == 'Request' || this.agreementData.Status__c == 'Assigned'))|| (!(isTeamLead) && this.agreementData.Status__c == 'Assigned'))) {
                    this.isAccept = this.recordId;
                }*/
                if(isContractAnalyst && CURRENT_USERID == this.agreementData.OwnerId && this.agreementData.Status_Category__c == 'In Authoring' 
                    && (this.agreementData.Status__c == 'Author Contract' || this.agreementData.Status__c == 'Internal Review')) {
                    this.isDeliver = this.recordId;
                }
                if(this.agreementData.Has_Conga__c && CURRENT_USERID == this.agreementData.OwnerId 
                    && this.agreementData.O365_Internal_Review_AP__c && isContractAnalyst) {
                    this.office365ReviewLink = (String(this.agreementData.O365_Internal_Review_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if(this.agreementData.Status__c == 'Other Party Review' && !isContractAnalyst) {
                    this.isRequestReview = true;
                }
                if (this.agreementData.Has_Conga__c && CURRENT_USERID == this.agreementData.OwnerId 
                    && this.agreementData.ImportOfflineDocument_AP_Custom__c && isContractAnalyst) { 
                    this.importOfflineDocumentLink = (String(this.agreementData.ImportOfflineDocument_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if(isContractAnalyst && CURRENT_USERID == this.agreementData.OwnerId && (this.agreementData.Status_Category__c == 'Request' 
                    || this.agreementData.Status_Category__c == 'In Authoring'
                    || this.agreementData.Status_Category__c == 'In Signatures')
                    && (this.agreementData.Status__c != 'Other Party Review' 
                    && this.agreementData.Status__c != 'Feedback Awaited' && this.agreementData.Status__c != 'Other Party Signatures' 
                    && this.agreementData.Status__c != 'Fully Signed')) {
                    this.isInternalBusinessReview = this.recordId;
                }
                if(!isContractAnalyst && this.agreementData.Status__c == 'Feedback Awaited') {
                    this.isSendFeedback = this.recordId;
                }
                if(this.agreementData.Record_Type_Developer_Name__c == 'USBU' && !this.agreementData.Is_Other_Agreement__c
                    && this.agreementData.Status_Category__c == 'In Effect') {
                    this.isSOWAmend = this.recordId;
                }    
                if(this.agreementData.Record_Type_Developer_Name__c == 'MSA' && this.agreementData.Status_Category__c == 'In Effect') {
                    this.isMSAAmend = this.recordId;
                }
                if(this.agreementData.Record_Type_Developer_Name__c == 'USBU' && this.agreementData.Is_Other_Agreement__c
                    && this.agreementData.Status_Category__c == 'In Effect') {
                    this.isOAAmend = this.recordId;
                }
                if(isContractAnalyst && this.agreementData.Record_Type_Developer_Name__c == 'MSA' && (this.agreementData.Status_Category__c == 'In Effect'
                    && this.agreementData.Status__c == 'Activated')) {
                    this.isMSAExpire = this.recordId;
                }
                if (this.agreementData.Has_Conga__c && this.agreementData.Preview_AP__c && isIQVIALicensedUser) {
                    this.previewLink = (String(this.agreementData.Preview_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }  
                if(!isContractAnalyst && this.agreementData.Status_Category__c == 'In Authoring' && this.agreementData.Status__c == 'Other Party Review') {
                    this.isRequestSignature = this.recordId;
                }
                if (this.agreementData.Send_For_eSignature__c) { 
                    this.sendForESignatureLink = (String(this.agreementData.Send_For_eSignature__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&'); 
                }
                if(this.agreementData.Check_eSignature_Status__c) {
                    this.checkESignatureStatusLink = (String(this.agreementData.Check_eSignature_Status__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if(this.agreementData.Correct_E_Signature_Recipients__c) {
                    this.correctESignatureRecipientLink = (String(this.agreementData.Correct_E_Signature_Recipients__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if(this.agreementData.Recall_Void_E_Signature_Request__c) {
                    this.recallVoidESignatureRequestLink = (String(this.agreementData.Recall_Void_E_Signature_Request__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }    
                if(this.agreementData.Re_Send_e_Signatures_Reminder__c) {
                    this.resendESignatureReminderLink = (String(this.agreementData.Re_Send_e_Signatures_Reminder__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }  
                if(this.isAssign || this.isReassign || this.isDeliver || this.isRequestReview 
                    || this.office365ReviewLink || this.isInternalBusinessReview || this.isSendFeedback
                    || this.isSOWAmend || this.cancelRequestLink || this.isMSAAmend || this.isOAAmend || this.isMSAExpire) {
                    this.showFirstBlock = true;
                }
                if(this.generateLink || this.regenerateLink || this.isUploadSignedDocument || this.importOfflineDocumentLink) {
                    this.showSecondBlock = true;
                }
                if(this.isRequestSignature || this.sendForESignatureLink || this.checkESignatureStatusLink || this.correctESignatureRecipientLink 
                    || this.recallVoidESignatureRequestLink || this.resendESignatureReminderLink) {
                    this.showThirdBlock = true;
                }
            }
            catch (ex) {
                console.log('Error is '+ex);
            }        
        }
        else if (result.error) {
            this.error = result.error;
            console.log(this.error);
        }
    }
}