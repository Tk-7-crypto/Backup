import { LightningElement, api, track, wire } from 'lwc';
import getAgreementDetails from '@salesforce/apex/CNT_CLM_ActionPanel.getAgreementDetails';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import generateLabel from '@salesforce/label/Apttus.Generate';
import apttusResource from '@salesforce/resourceUrl/Apttus__LightningResource';
import docusignImage1 from '@salesforce/resourceUrl/CorrecteSigantureDocumentAP';
import docusignImage2 from '@salesforce/resourceUrl/RecalleSignatureRequestAP';
import docusignImage3 from '@salesforce/resourceUrl/SendeSignatureReminderAP';
import hasAccessCLMBase from '@salesforce/customPermission/Apttus_CLM_Base';
import hasO365Access from '@salesforce/customPermission/CLM_Enable_Office_365';

const NAME_FIELD = ['Apttus__APTS_Agreement__c.Name']

export default class Lwc_clm_parentActionPanel extends LightningElement {
    @api recordId;
    @api objectApiName;
    result;
    @track agreementData;
    importSupportingDocumentLogo = apttusResource + '/images/actions/importofflinedocument.svg';
    customLabel = { generateLabel };
    importSupportingDocumentLink;
    generateLink;
    generateLogo = apttusResource + '/images/actions/generate.svg';
    regenerateLink;
    regenerateLogo = apttusResource + '/images/actions/regenerate.svg';
    viewHierarchyLogo = apttusResource + '/images/actions/ViewHierarchy.svg';
    viewHierarchyLink;
    previewLogo = apttusResource + '/images/actions/preview.svg';
    previewLink;
    cancelRequestLink;
    cancelRequestLogo = apttusResource + '/images/actions/cancelrequest.svg';
    showFirstBlock;
    showSecondBlock;
    showForthBlock;
    amendLogo = apttusResource + '/images/actions/amend.svg';
    amendLink;
    inEffectViewLogo = apttusResource + '/images/actions/Ineffect.svg';
    inEffectViewLink;
    sendForReviewLink;
    office365ReviewLink;
    sendForReviewLogo = apttusResource + '/images/actions/sendforreview.svg';
    activateLogo = apttusResource + '/images/actions/activate.svg';
    activateLink;
    uploadSignedDocumentLogo = apttusResource + '/images/actions/markassigned.svg';
    uploadSignedDocumentLink;
    importOfflineDocumentLogo = apttusResource + '/images/actions/importofflinedocument.svg'
    importOfflineDocumentLink;
    submittedToClinicalLogo = apttusResource + '/images/actions/sendforreview.svg';
    submittedToClinicalLink;
    sendForESignatureLogo = apttusResource + '/images/actions/sendforesignature.svg';
    sendForESignatureLink;
    checkESignatureStatusLogo = apttusResource + '/images/actions/docusigncheckstatus.svg';
    checkESignatureStatusLink;
    correctESignatureDocumentLogo = docusignImage1;
    correctESignatureDocumentLink;
    recallESignatureRequestLogo = docusignImage2;
    recallESignatureRequestLink;   
    sendESignatureReminderLogo = docusignImage3;
    sendESignatureReminderLink;
    sendForWetSignatureLogo = apttusResource + '/images/actions/sendforesignature.svg';
    sendForWetSignatureLink;
    generateSupportingDocumentLogo = apttusResource + '/images/actions/generatesupporting.svg';
    generateSupportingDocumentLink;
    expireLogo = apttusResource + '/images/actions/expire.svg';
    isRWSAmend;
    isRWLPAmend;
    lCNReviewCheckLink;
    isVendorAmend;
    isMSAExpire;
 
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
                this.showFirstBlock = false;
                this.showForthBlock = false;
                this.showSecondBlock = false;
                this.inEffectViewLink = false;
                this.submittedToClinicalLink = false;
                this.amendLink = false;
                this.isRWSAmend = false;
                this.isRWLPAmend = false;
                this.isVendorAmend = false;
                this.lCNReviewCheckLink = false;
                this.sendForReviewLink = false;
                this.office365ReviewLink = false;
                this.importSupportingDocumentLink = false;
                this.isMSAExpire = false;
                if (this.agreementData.Apttus__VersionAware__c) {
                    this.importSupportingDocumentLink = '/lightning/cmp/Apttus__ImportOfflineContainer?Apttus__agreementId=' +
                    this.agreementData.Id + '&Apttus__action=ImportSupportingDocument';
                }
                if (this.agreementData.Generate_AP_Custom__c) {
                    this.generateLink = (String(this.agreementData.Generate_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData) {
                    this.viewHierarchyLink = String(window.location.origin).replace('.sandbox.lightning.force.com', '--apttus.sandbox.vf.force.com') + '/apex/apttus__agreementhierarchy?id=' + this.recordId;
                }
                if (this.agreementData.Regenerate_AP_Custom__c) {
                    this.regenerateLink = (String(this.agreementData.Regenerate_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData.Preview_AP_Custom__c) {
                    this.previewLink = (String(this.agreementData.Preview_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData.Cancel_Request_AP_Custom__c) {
                    this.cancelRequestLink = (String(this.agreementData.Cancel_Request_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if(this.agreementData.Amend_Custom__c) {
                    if(this.agreementData.Record_Type_Developer_Name__c == 'RWSSOW') {
                        this.isRWSAmend = this.recordId;
                    }
                    else if(this.agreementData.Record_Type_Developer_Name__c == 'RWLP' || this.agreementData.Record_Type_Developer_Name__c == 'OSA' || this.agreementData.Record_Type_Developer_Name__c == 'Preliminary_Agreement' || this.agreementData.Record_Type_Developer_Name__c == 'PSA') {
                        this.isRWLPAmend = this.recordId;
                    }
                    else if(this.agreementData.Record_Type_Developer_Name__c == 'Vendor_Agreement') {
                        this.isVendorAmend = this.recordId;
                    }
                    else {
                        this.amendLink = (String(this.agreementData.Amend_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                    }
                }
                if (this.agreementData.Activate_AP_Custom__c) {
                    this.activateLink = (String(this.agreementData.Activate_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData.UploadSignedDocument_AP_Custom__c) {
                    this.uploadSignedDocumentLink = (String(this.agreementData.UploadSignedDocument_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData.ImportOfflineDocument_AP_Custom__c) {
                    this.importOfflineDocumentLink = (String(this.agreementData.ImportOfflineDocument_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData.SendForReview_AP_Custom__c && !hasO365Access) {
                    this.sendForReviewLink = (String(this.agreementData.SendForReview_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if (this.agreementData.O365_Internal_Review_AP__c && hasO365Access) {
                    this.office365ReviewLink = (String(this.agreementData.O365_Internal_Review_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if ((this.agreementData.Apttus__Status_Category__c == 'In Effect' || this.agreementData.Apttus__Status_Category__c == 'Amended' || this.agreementData.Apttus__Status_Category__c == 'Renewed') && hasAccessCLMBase) {
                    this.inEffectViewLink = String(window.location.origin) + '/lightning/cmp/Apttus__LightningWebComponentContainer?Apttus__agreementId=' + this.recordId + '&Apttus__agreementNumber=' 
                    + parseInt(this.agreementData.Apttus__FF_Agreement_Number__c) + '&Apttus__agreementVersionNumber=' + this.agreementData.Apttus__FF_Agreement_Number__c + '&Apttus__componentName=agreementInEffectViewWebComponent';
                }
                if(this.agreementData.Record_Type_Developer_Name__c == 'RWSSOW' && this.agreementData.Apttus__Status_Category__c == 'In Authoring' &&  this.agreementData.Apttus__Agreement_Category__c == 'Full Service' 
                    && this.agreementData.Apttus__Status__c != 'Submitted to Clinical' && hasAccessCLMBase) {
                    this.submittedToClinicalLink = this.recordId;
                }
                if((this.agreementData.Record_Type_Developer_Name__c == 'Preliminary_Agreement' 
                    || this.agreementData.Record_Type_Developer_Name__c == 'RWLP' 
                    || this.agreementData.Record_Type_Developer_Name__c == 'MSA'
                    || this.agreementData.Record_Type_Developer_Name__c == 'RWSSOW'
                    || (this.agreementData.Record_Type_Developer_Name__c == 'PSA' && this.agreementData.Apttus__Subtype__c != 'SCC Amendment')
                    || this.agreementData.Record_Type_Developer_Name__c == 'OSA') 
                    && this.agreementData.Apttus__Status_Category__c == 'In Authoring' && hasAccessCLMBase) {
                    this.lCNReviewCheckLink = this.recordId;
                }
                if(this.agreementData.Record_Type_Developer_Name__c == 'MSA' && (this.agreementData.Apttus__Status_Category__c == 'In Effect' && this.agreementData.Apttus__Status__c == 'Activated')) {
                    this.isMSAExpire = this.recordId;
                }
                if (this.agreementData.Send_For_eSignature_AP__c) { 
                    this.sendForESignatureLink = (String(this.agreementData.Send_For_eSignature_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&'); 
                }
                if(this.agreementData.Check_eSignature_Status_AP__c) {
                    this.checkESignatureStatusLink = (String(this.agreementData.Check_eSignature_Status_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if(this.agreementData.Correct_E_Signature_Document_AP__c) {
                    this.correctESignatureDocumentLink = (String(this.agreementData.Correct_E_Signature_Document_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }
                if(this.agreementData.Recall_E_Signature_Request_AP__c) {
                    this.recallESignatureRequestLink = (String(this.agreementData.Recall_E_Signature_Request_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }    
                if(this.agreementData.Send_e_Signature_Reminder_AP__c) {
                    this.sendESignatureReminderLink = (String(this.agreementData.Send_e_Signature_Reminder_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }                    
                if(this.agreementData.SendForWetSignatures_AP_Custom__c) {
                    this.sendForWetSignatureLink = (String(this.agreementData.SendForWetSignatures_AP_Custom__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                }  
                if(this.agreementData.Generate_Supporting_Document_AP__c) {
                    this.generateSupportingDocumentLink = (String(this.agreementData.Generate_Supporting_Document_AP__c).match(/href="([^"]*)/)[1]).replace(/&amp;/g, '&');
                } 
                if (this.agreementData.Cancel_Request_AP_Custom__c || this.submittedToClinicalLink || this.agreementData.Activate_AP_Custom__c 
                    || this.amendLink || this.isRWSAmend || this.isRWLPAmend || this.isVendorAmend || this.isMSAExpire) {
                    this.showFirstBlock = true;
                }
                if (this.agreementData.SendForWetSignatures_AP_Custom__c || this.agreementData.Send_For_eSignature_AP__c 
                    || this.agreementData.Check_eSignature_Status_AP__c || this.agreementData.Correct_E_Signature_Document_AP__c 
                    || this.agreementData.Recall_E_Signature_Request_AP__c || this.agreementData.Send_e_Signature_Reminder_AP__c) {
                    this.showForthBlock = true;
                }
                if(this.agreementData.Generate_AP_Custom__c || this.agreementData.Preview_AP_Custom__c || this.agreementData.Regenerate_AP_Custom__c 
                    || this.agreementData.SendForReview_AP_Custom__c || this.agreementData.ImportOfflineDocument_AP_Custom__c ||  this.importSupportingDocumentLink 
                    || this.agreementData.UploadSignedDocument_AP_Custom__c || this.agreementData.Generate_Supporting_Document_AP__c) {
                    this.showSecondBlock = true; 
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