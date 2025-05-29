/*
*   Author    : Sweta Sharma
*   This class serves as a extension for VFP_CDA_RequestViewScreen page. (created under ER-3556 on 27/03/2017)
*/
public with sharing class EXT_CDA_RequestViewController {

    //public Variables
    public CDA_Request__c cdaRequest {get; set;}
    public CDA_Request__c cdaRequestIntNotesEdit {get; set;}    //Added by Vikram Singh under Item #190
    public CDA_Request__c cdaRequestStatusEdit {get; set;}
    public CDA_Request__c cdaRequestAuthSignEdit {get; set;}
    public CDA_Request__c cdaRequestNegoAssignEdit {get;set;}   //Added by Ajinkya Pande under Item #258
    public CDA_Request__c cdaRequestResponseDocTypeEdit {get; set;}    //Added by Vikram Singh under CR-11146
    public String selectedQILegalEntityAddress{get;set;}
    public Boolean isManagementApprovalDocumentAttached{get;set;}
    public Boolean isCustomerConsenttoDiscloseAttached{get;set;}
    public Boolean isGeneratedDocumentAttached{get;set;}
    public Boolean isAuditScopeAgendaAttached{get;set;}
    public Boolean isExternalDocumentAttached{get;set;}
    public Boolean isSponsorConsenttoDiscloseAttached{get;set;}
    public Boolean isPartiallyExecutedCdaDocumentAttached {get;set;} //Added by Babita Dadarwal under CR-11458
    public Boolean isSubmitEnabeled{get;set;}
    public Boolean isAllRequiredDocAttached{get;set;}
    public Boolean isRedLineDocumentAttached{get;set;}
    public Boolean isAwaitingOCGDocumentAttached{get;set;} //Added by Ajinkya Pande Under Item #243b
    public string cdaRequestType{get;set;}
    public Boolean showNegotiatorEditable {get;set;}
    public Boolean showStatusEditable {get;set;}
    public Boolean isStatusEditable {get;set;}
    public Boolean isSendCompletionEmailEnable {get;set;}
    public String isAuthorizedSigner {get;set;}
    public string confirmRecipientAuthorizedSignerEmailAddress {get;set;}
    public Boolean isAuthSignEditable {get;set;}
    public Boolean isInternalNotesEditable {get;set;}    //Added by Vikram Singh under Item #190
    //Added by Vikram Singh under CR-11146 Start
    public String responseDocumentType {get;set;}
    public Boolean isCdaRequestResponseDocTypeEditable {get;set;}
    public Boolean isResponseDocTypeRedlined {get;set;}
    public Boolean isResponseDocTypeCleaned {get;set;}
    public Boolean isResponseDocTypeRedlinedAndCleaned {get;set;}
    public Boolean isCleanDocumentAttached {get;set;}
    //Added by Vikram Singh under CR-11146 End
    public Boolean showExecutedRequestPopup {get;set;} // Added by Babita Dadarwal under CR-11270
    public Boolean isQaTesting {get;set;}   //Added by Vikram Singh under CR-11526
    public Boolean isPrivilegedBusinessAreaSelected {get;set;}
    public Boolean isManagerApprovalDocUplaoded {get;set;}
    public CDA_Legal_POC_Cross_Walk__c cdaLegalPOC {get; set;}
    public String btnType {get; set;}
    public List<UTL_CDAUtility.cdaAdditionalContactWrapper> cdaAdditionalContactWrapperList {get; set;}
    public String negotiatorAssigned{get; set;}
    public static boolean isGenerateDocAgreementBtnHit {
        get{
            if(isGenerateDocAgreementBtnHit == null){
                isGenerateDocAgreementBtnHit = false;
            }
            return isGenerateDocAgreementBtnHit;
        }
        set;
    }

    public Boolean isPDFTypeCDARequest {
        get {
            return cdaRequest.CDA_Format__c == 'PDF';
        }
        set;
    }

    //Added by Vikram Singh under CR-11525 Start
    public Boolean isUserHavingApttusLicense {
        get {
            return SRV_CDA_CDARequest.isUserHavingApttusLicense();
        }
        set;
    }
    //Added by Vikram Singh under CR-11525 End
    public Boolean isUserHavingCongaPermissionSet {
        get {
            return SRV_CDA_CDARequest.isUserHavingCongaPermissionSet();
        }
        set;
    }
    public String dateFormatString {
        get {
            return UTL_CDAUtility.DATE_FORMAT_STRING;
        }
        set;
    }

    public Boolean isNegotiator {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }

    public Boolean isRequestor {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.REQUESTOR ||SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }

    //Added by Vikram Singh under CR-11764 Start
    public Boolean isRequestorAdmin {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.REQUESTOR_ADMIN ||SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }
    //Added by Vikram Singh under CR-11764 End

    //Added by Vikram Singh under CR-12108 Start
    public Boolean isRequestorExtended {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.REQUESTOR_EXTENDED || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
        }
        set;
    }
    //Added by Vikram Singh under CR-12108 End

    public Boolean isLookupReportUser {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.LOOKUP_REPORT_USER);
        }
        set;
    }

    public Boolean isCurrentUserARequestOwner {
        get {
            return SRV_CDA_CDARequest.isCurrentUserARequestOwner(cdaRequest);
        }
        set;
    }

    public Boolean isProtocolHasToRender {
        get {
            return ((cdaRequest.Competitor_Contracting_Capacity__c != UTL_CDAUtility.CONTRACTINGCAPACITY_COLLABORATOR && cdaRequest.Competitor_Contracting_Capacity__c != null) || (cdaRequest.Project_Specific_Indicator__c == UTL_CDAUtility.YES && cdaRequest.Competitor_Contracting_Capacity__c == null));
        }
        set;
    }

    public Boolean isProtocolNumberKnown {
        get {
            return (cdaRequest.Is_Protocol_Number_Known__c == UTL_CDAUtility.YES && cdaRequest.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isProtocolNumberNotKnown {
        get {
            return (cdaRequest.Is_Protocol_Number_Known__c == UTL_CDAUtility.NO && cdaRequest.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isProtocolTitleKnown {
        get {
            return (cdaRequest.Is_Protocol_Title_Known__c == UTL_CDAUtility.YES && cdaRequest.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isProtocolTitleNotKnown {
        get {
            return (cdaRequest.Is_Protocol_Title_Known__c == UTL_CDAUtility.NO && cdaRequest.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isSubmitHasToRender {
        get {
            return cdaRequest.Status__c == UTL_CDAUtility.STATUS_AWAITINGREQSUB;
        }
        set;
    }

    public Boolean isRedlineUploadHasToRender {
        get {
            return isNegotiator && (cdaRequest.Status__c == UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES || cdaRequest.Status__c == UTL_CDAUtility.STATUS_SENTFORSIGN || cdaRequest.Status__c == UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW || cdaRequest.Status__c == UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE || isStatusAwaitingOGC || cdaRequest.Status__c == UTL_CDAUtility.STATUS_LANGUAGE_REVIEW);
        }
        set;
    }

    //Updated by Vikram Singh under Issue-11192 Start
    public Boolean isEnvelopeActive {
        get {
            List<dsfs__DocuSign_Status__c> activeDocusignEnvelopeList = [SELECT  CDA_Request__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE dsfs__Envelope_Status__c not in ('Voided', 'Completed', 'Declined', 'Expired') and CDA_Request__r.Id =: cdaRequest.Id];
            if(activeDocusignEnvelopeList != null && activeDocusignEnvelopeList.size() > 0) {
                return true;
            }
            return false;
        }
        set;
    }
    //Updated by Vikram Singh under Issue-11192 End

    public Boolean isStartStatus {
        get {
            return (cdaRequest.Status__c == UTL_CDAUtility.STATUS_INDRAFT || cdaRequest.Status__c == UTL_CDAUtility.STATUS_AWAITINGREQSUB);
        }
        set;
    }

    public Boolean isMiddleStatus {
        get {
            return (cdaRequest.Status__c == UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES || cdaRequest.Status__c == UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE || cdaRequest.Status__c == UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW || isStatusAwaitingOGC || cdaRequest.Status__c == UTL_CDAUtility.STATUS_ACQUIRING_INTERNAL_SIGNATURE || cdaRequest.Status__c == UTL_CDAUtility.STATUS_LANGUAGE_REVIEW); //Modified by C.P.Pandey under Issue-11144
        }
        set;
    }

    public Boolean isEndStatus {
        get {
            return (cdaRequest.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED || cdaRequest.Status__c == UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR || cdaRequest.Status__c == UTL_CDAUtility.STATUS_DISCLOSUREPERIODENDED || cdaRequest.Status__c == UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING); //Updated by Vikram Singh under Item #254  //Updated by Vikram Singh under CR-11525
        }
        set;
    }

    public Boolean isStatusAwaitingOGC {
        get {
            return cdaRequest.Status__c == UTL_CDAUtility.STATUS_AWAITING_OGC_COMPETITOR_APPROVAL;
        }
        set;
    }

    public Boolean isStatusSendForSign {
        get {
            return cdaRequest.Status__c == UTL_CDAUtility.STATUS_SENTFORSIGN;
        }
        set;
    }

    public Boolean isStatusSignRequestDenied {
        get {
            return cdaRequest.Status__c == UTL_CDAUtility.STATUS_SIGNATURE_REQUEST_DENIED;
        }
        set;
    }

    public Boolean isCdaTypeAuditor {
        get {
            return SRV_CDA_CDARequest.iscdaTypeAuditor(cdaRequest.CDA_Type__c);
        }
        set;
    }

    public Boolean isCdaTypeVendor {
        get {
            return SRV_CDA_CDARequest.isCdaTypeVendor(cdaRequest.CDA_Type__c);
        }
        set;
    }

    public Boolean isCdaTypeCustomer {
        get {
            return SRV_CDA_CDARequest.isCdaTypeCustomer(cdaRequest.CDA_Type__c);
        }
        set;
    }

    public Boolean isCdaTypeCEVA {
        get {
            return SRV_CDA_CDARequest.isCdaTypeCEVA(cdaRequest.CDA_Type__c);
        }
        set;
    }

    public Boolean isCustomerLegalEntityToRender {
        get {
            return cdaRequest.Cust_Legal_Entity_Name__c != null;
        }
        set;
    }

    public Boolean isRecipientAccountToRender {
        get {
            return cdaRequest.Recipient_Account__c != null;
        }
        set;
    }

    public Boolean isRecipientAccountOtherToRender {
        get {
            return cdaRequest.Recipient_Account_Name_Other__c != null;
        }
        set;
    }

    public Boolean isCompetitor {
        get {
            return cdaRequest.Competitor_Flag__c == UTL_CDAUtility.YES;
        }
        set;
    }

    public Boolean isCompetitorContractingCapacityCollaborator {
        get {
            return cdaRequest.Competitor_Contracting_Capacity__c == UTL_CDAUtility.CONTRACTINGCAPACITY_COLLABORATOR;
        }
    }

    public Boolean isCompetitorContractingCapacityCustomer {
        get {
            return cdaRequest.Competitor_Contracting_Capacity__c == UTL_CDAUtility.CONTRACTINGCAPACITY_CUSTOMER;
        }
        set;
    }

    public Boolean whatIsTheStudySponsorSituationStudySponsorIdentified {
        get {
            return(cdaRequest.What_is_the_Study_Sponsor_situation__c == UTL_CDAUtility.STUDYSPONSORIDENTIFIED && cdaRequest.What_is_the_Study_Sponsor_situation__c != null);
        }
        set;
    }

    public Boolean isAThreeWayAgreementRequired {
        get {
            return(isCdaTypeCustomer && isCompetitor && isCompetitorContractingCapacityCustomer && whatIsTheStudySponsorSituationStudySponsorIdentified);
        }
        set;
    }

    public Boolean isSponsorLegalEntityToRender {
        get {
            return cdaRequest.Sponsor_Legal_Entity__c != null && cdaRequest.What_is_the_Study_Sponsor_situation__c == UTL_CDAUtility.STUDYSPONSORIDENTIFIED;
        }
        set;
    }

    public Boolean isSponsorLegalEntityOtherToRender {
        get {
            return cdaRequest.Sponsor_Legal_Entity_Name_Other__c != null && cdaRequest.What_is_the_Study_Sponsor_situation__c == UTL_CDAUtility.STUDYSPONSORIDENTIFIED;
        }
        set;
    }

    public Boolean isCompetitorSystemAccessRequired {
        get {
            return cdaRequest.Competitor_System_Access__c == UTL_CDAUtility.YES;
        }
        set;
    }

    public Boolean isActionSectionToRender {
        get {
            return cdaRequest.Status__c != UTL_CDAUtility.STATUS_INDRAFT && !isEndStatus;
        }
        set;
    }

    public Boolean isCustomerConsenttoDiscloseRender {
        get {
            return cdaRequest.Customer_Consent_to_Disclose__c == UTL_CDAUtility.YES;
        }
        set;
    }

    public Boolean isSponsorConsenttoDiscloseRender {
        get {
            return cdaRequest.Sponsor_Consent_to_Disclose__c == UTL_CDAUtility.YES;
        }
        set;
    }

    public Boolean isCDASourceQuintilesIMS {
        get {
            return cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        }
        set;
    }

    public Boolean isCDASourceExternal {
        get {
            return cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL;
        }
        set;
    }

    public Boolean isCDAExecutive {
        get {
            return FeatureManagement.checkPermission('CDA_Executive');
        }
        set;
    }
    
    public Boolean isBusinessAreaRDS{
        get{
            return cdaRequest.QuintilesIMS_Business__c == Label.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles;
        }
        set;
    }
    
    public Boolean isBroadCDA {
        get {
            return (cdaRequest.QuintilesIMS_Business__c == Label.CDA_Q_Squared || isBusinessAreaRDS) && isProjSpeciIndiYes;
        }
        set;
    }
    
    public Boolean isProjSpeciIndiYes{
        get{
            return cdaRequest.Project_Specific_Indicator__c == 'Yes';
        }
        set;
    }

    //Added by Babita Dadarwal under CR-11458 Start
    public Boolean showUploadPartiallyExecutedCdaButton {
        get {
            return (    isNegotiator
                    &&  cdaRequest.Status__c == UTL_CDAUtility.STATUS_ACQUIRING_INTERNAL_SIGNATURE
                    &&  !isPartiallyExecutedCdaDocumentAttached
                    &&  (isProtectedWordFormat || isCDASourceExternal) );
        }
        set;
    }
    //Added by Babita Dadarwal under CR-11458 End

    public Boolean isProtectedWordFormat { //Modified by Vikram Singh under Item #183
        get {
            return cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PROWORD;
        }
        set;
    }

    public Boolean isSendForSignature { //Modified by Vikram Singh under Item #183
        get {
            if(cdaRequest != null && cdaRequest.Attachments != null && cdaRequest.Attachments.size() > 0) {
                for(Attachment attach : cdaRequest.Attachments) {
                    if(cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PDF && attach.Name.Contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD) && attach.Name.contains(UTL_CDAUtility.EXTENTION_PDF) && attach.Name.contains(cdaRequest.CDA_Type__c) && attach.CreatedDate > cdaRequest.Awaiting_Requestor_Submission_Date__c) {   //Updated by Vikram Singh under Issue-11192
                        return true;
                    }
                }
            }
            return false;
        }
        set;
    }

    public Boolean isRedLineDocumentRequired {
        get {
            if(cdaRequest != null && cdaRequest.Attachments != null && cdaRequest.Attachments.size() > 0) {
                for(Attachment attach : cdaRequest.Attachments) {
                    if((((cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PROWORD && attach.Name.Contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD) && attach.Name.contains(cdaRequest.CDA_Type__c)) && attach.CreatedDate > cdaRequest.Awaiting_Requestor_Submission_Date__c) || (cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL && attach.Name.contains(UTL_CDAUtility.CDASOURCE_EXTERNAL))) && (attach.Name.contains(UTL_CDAUtility.EXTENTION_DOC) || attach.Name.contains(UTL_CDAUtility.EXTENTION_DOCX))) { // Updated by Ajinkya Pande Under Item #114  //Updated by Vikram Singh under Issue-11192
                        return true;
                    }
                }
            }
            return false;
        }
        set;
    }

    public Boolean isRegenrateTextRequired {
        get {
            if(generatedAttachment != null) {
                return cdaRequest.Awaiting_Requestor_Submission_Date__c > generatedAttachment.CreatedDate;
            }
            return false;
        }
        set;
    }

    public Boolean isCompletedDocAttached {
        get {
            if(cdaRequest != null && cdaRequest.Attachments != null && cdaRequest.Attachments.size() > 0) {
                for(Attachment attach : cdaRequest.Attachments) {
                    if(attach.Name.contains((String)cdaRequest.get('CDA_Id__c')) && attach.Name.containsIgnoreCase(UTL_CDAUtility.COMPLETED_KEYWORD) && (attach.Name.containsIgnoreCase(UTL_CDAUtility.EXTENTION_PDF) || attach.Name.containsIgnoreCase(UTL_CDAUtility.EXTENTION_DOC) || attach.Name.containsIgnoreCase(UTL_CDAUtility.EXTENTION_DOCX))) { //Modified by C.P.Pandey under Issue-11121
                        return true;
                    }
                }
            }
            return false;
        }
        set;
    }

    //Updated by Ajinkya Pande under Item #1003 Start
    public Boolean isRegenrateDoc {
        get {
            if(cdaRequest != null && cdaRequest.Attachments != null && cdaRequest.Attachments.size() > 0 && generatedAttachment != null) {
                for(Attachment attach: cdaRequest.Attachments) {
                    if(attach.Name.contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD) && cdaRequest.Awaiting_Requestor_Submission_Date__c > attach.CreatedDate && cdaRequest.Awaiting_Requestor_Submission_Date__c < generatedAttachment.CreatedDate) {
                        return true;
                    }
                }
            }
            return false;
        }
        set;
    }

    public Boolean isRegenrateDocByNegotiator {
        get {
            return isNegotiator && isRegenrateDoc && cdaRequest != null && cdaRequest.Status__c == UTL_CDAUtility.STATUS_AWAITINGREQSUB;
        }
        set;
    }
    //Updated by Ajinkya Pande under Item #1003 End

    //Added by Ajinkya Pande under Item #162 Start
    public Boolean isStatusReturnedToRequestor {
        get {
            if(cdaRequest != null) {
                return cdaRequest.Status__c == UTL_CDAUtility.STATUS_RETURNED_TO_REQUESTOR;
            }
            return false;
        }
        set;
    }
    //Added by Ajinkya Pande under Item #162 End

    // Added by Vikram Singh under CR-11188 Start
    public Boolean isDataAndServices {
        get {
            if(cdaRequest != null) {
                return SRV_CDA_CDARequest.isDataAndServices(cdaRequest.QuintilesIMS_Business__c);
            }
            return false;
        }
        set;
    }

    public Boolean isClinicalResearch {
        get {
            if(cdaRequest != null) {
                return SRV_CDA_CDARequest.isClinicalResearch(cdaRequest.QuintilesIMS_Business__c);
            }
            return false;
        }
        set;
    }

    public Boolean IsRDSandQ2BusinessArea{
        get{
            return (cdaRequest.QuintilesIMS_Business__c == Label.CDA_Q_Squared || cdaRequest.QuintilesIMS_Business__c == Label.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles);
        }
        set;
    }
    // Added by Vikram Singh under CR-11188 End

    //private variables
    private CDA_Request__c request;
    private Attachment generatedAttachment;
    private static Boolean isCancelClicked = false;


    //Constructor
    public EXT_CDA_RequestViewController(ApexPages.StandardController controller) {
        request = (CDA_Request__c) controller.getRecord();
        if(!System.isBatch() && !System.isQueueable() && !System.isScheduled()) {    //Added by Vikram Singh under CR-11525
            cdaRequestType = ApexPages.currentPage().getparameters().get(UTL_CDAUtility.REQUEST_TYPE_STR);
            isQaTesting = ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR) == null ? false : Boolean.valueOf(ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR));    //Added by Vikrm Singh under CR-11526
        }
        cdaRequest = new CDA_Request__c();
        if(request != null && request.id != null) {
            cdaRequest = SRV_CDA_CDARequest.getCDARequest(request.Id);
            cdaRequestNegoAssignEdit = cdaRequest.clone(true, true, true, true); //Added by Ajinkya Pande under Item #258
            cdaRequestStatusEdit = cdaRequest.clone(true, true, true, true);
            cdaRequestAuthSignEdit = cdaRequest.clone(true, true, true, true);
            cdaRequestIntNotesEdit = cdaRequest.clone(true, true, true, true);  //Added by Vikram Singh under Item #190
            cdaRequestResponseDocTypeEdit = cdaRequest.clone(true, true, true, true);   //Added by Vikram Singh under CR-11146
        }
        negotiatorAssigned = cdaRequest.Negotiator_Assigned_List__c;
        isPartiallyExecutedCdaDocumentAttached = false; //Added by Babita Dadarwal under CR-11458
        isManagementApprovalDocumentAttached = false;
        isCustomerConsenttoDiscloseAttached = false;
        isGeneratedDocumentAttached = false;
        isAuditScopeAgendaAttached = false;
        isExternalDocumentAttached = false;
        isSponsorConsenttoDiscloseAttached = false;
        isSubmitEnabeled = false;
        isRedLineDocumentAttached = false;
        isAllRequiredDocAttached = true;
        isStatusEditable = false;
        isSendCompletionEmailEnable = false;
        isAuthorizedSigner = UTL_CDAUtility.YES;
        isAuthSignEditable = false;
        isAwaitingOCGDocumentAttached = false; //Added by Ajinkya Pande Under Item #243b
        isInternalNotesEditable = true; //Added by Vikram Singh under Item #190
        isCdaRequestResponseDocTypeEditable = false;    //Added by Vikram Singh under CR-11146
        isCleanDocumentAttached = false; //Added by Vikram Singh under CR-11146
        showExecutedRequestPopup = false; // Added by Babita Dadarwal under CR-11270
        isPrivilegedBusinessAreaSelected = false;
        isManagerApprovalDocUplaoded = false;
        if(cdaRequest != null) {
            if(cdaRequest.QI_Legal_Entity_Name__c != null && cdaRequest.QI_Legal_Entity_Name__r.QI_Legal_Entity_Address__c != null) {
                selectedQILegalEntityAddress = cdaRequest.QI_Legal_Entity_Name__r.QI_Legal_Entity_Address__c;
            }
            showNegotiatorEditable = false;
            showStatusEditable = false;
            
            if(UTL_CDAUtility.privilegedBusinessAreas != null && cdaRequest.QuintilesIMS_Business__c != null && UTL_CDAUtility.privilegedBusinessAreas.toLowerCase().contains(cdaRequest.QuintilesIMS_Business__c.toLowerCase())) {
                isPrivilegedBusinessAreaSelected = true;
            }

            if(cdaRequest.CDA_Language__c != null && cdaRequest.CDA_Language__c != 'English') {
                cdaLegalPOC = SRV_CDA_CDARequest.getCDALegalPOC(cdaRequest.CDA_Language__c);
            }

            //loading Additional IQVIA contact details
            cdaAdditionalContactWrapperList = UTL_CDAUtility.getAdditionalContactsDetails(cdaRequest.Id);    
        }
        
        if((cdaRequest.Competitor_Flag__c == UTL_CDAUtility.YES && !isManagementApprovalDocumentAttached && isCDAExecutive) && cdaRequest.Customer_Consent_to_Disclose__c != UTL_CDAUtility.YES && cdaRequest.CDA_Type__c != 'Auditor' && cdaRequest.Sponsor_Consent_to_Disclose__c != UTL_CDAUtility.YES && (!(isCdaTypeVendor && isCDASourceExternal) || isCDAExecutive) && cdaRequest.CDA_Source__c != UTL_CDAUtility.CDASOURCE_EXTERNAL) {
            isSubmitEnabeled = true;
        }

        if(cdaRequest.Attachments != null && cdaRequest.Attachments.size() > 0) {
            for(Attachment att: cdaRequest.Attachments) {
                if(att.Name.contains(UTL_CDAUtility.MANAGEMENT_APPROVAL_DOCUMENT) && cdaRequest.Competitor_Flag__c == UTL_CDAUtility.YES) {
                    isManagementApprovalDocumentAttached = true;
                } else if(att.Name.contains(UTL_CDAUtility.CUSTOMER_CONSENT_TO_DISCLOSE) && cdaRequest.Customer_Consent_to_Disclose__c == UTL_CDAUtility.YES) {
                    isCustomerConsenttoDiscloseAttached = true;
                } else if(att.Name.contains(UTL_CDAUtility.AUDIT_SCOPE_AGENDA) && cdaRequest.CDA_Type__c == UTL_CDAUtility.AUDITOR) {
                    isAuditScopeAgendaAttached = true;
                } else if(att.Name.contains(UTL_CDAUtility.CDASOURCE_EXTERNAL) && cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL) { // Updated by Ajinkya under Item #114
                    isExternalDocumentAttached = true;
                } else if(att.Name.contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD) && cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS) {
                    isGeneratedDocumentAttached = true;
                    if(generatedAttachment == null) {
                        generatedAttachment = att;
                    }
                } else if(att.Name.contains(UTL_CDAUtility.SPONSOR_CONSENT_TO_DISCLOSE) && cdaRequest.Sponsor_Consent_to_Disclose__c == UTL_CDAUtility.YES) {
                    isSponsorConsenttoDiscloseAttached = true;
                } else if((att.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || att.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW)) || (att.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || att.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW))) { //Updated by Ajinkya under Item #114  //Updated by Vikram Singh under CR-11146 Start
                    // isRedLineDocumentAttached = true;
                    isExternalDocumentAttached = true;
                    //Added by Vikram Singh under CR-11146 Start
                    // Updated by Babita Dadarwal under Issue-11711 Start
                    if(cdaRequest.What_documents_would_you_like_to_provide__c == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED
                    && (att.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || att.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW))
                    && (cdaRequest.Awaiting_Requestor_Submission_Date__c < att.CreatedDate)) {
                        isRedLineDocumentAttached = true;
                    }
                    else if(cdaRequest.What_documents_would_you_like_to_provide__c == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_CLEANED
                        && (att.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || att.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW))
                        && (cdaRequest.Awaiting_Requestor_Submission_Date__c < att.CreatedDate)) {
                            isCleanDocumentAttached = true;
                    }
                    else if(cdaRequest.What_documents_would_you_like_to_provide__c == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED_AND_CLEANED) {
                        for(Attachment att1: cdaRequest.Attachments) {
                            if(att1.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD) || att1.Name.contains(UTL_CDAUtility.RED_LINE_KEYWORD_NEW)
                            && (cdaRequest.Awaiting_Requestor_Submission_Date__c < att1.CreatedDate)) {
                                isRedLineDocumentAttached = true;
                                for(Attachment att2: cdaRequest.Attachments) {
                                    if(att2.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD) || att2.Name.contains(UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW)
                                    && att2.CreatedDate > att1.CreatedDate
                                    && (cdaRequest.Awaiting_Requestor_Submission_Date__c < att2.CreatedDate)) {
                                        isCleanDocumentAttached = true;
                                        break;
                                    }
                                }
                                break;
                            }
                        }
                    }   //Added by Vikram Singh under CR-11146 End  //Updated by Vikram Singh under CR-11146 End
                    // Updated by Babita Dadarwal under Issue-11711 End
                } else if(att.Name.contains(UTL_CDAUtility.AWAITING_OGC_APPROVAL)) { //Added by Ajinkya Pande Under Item #243b
                    isAwaitingOCGDocumentAttached = true; //Added by Ajinkya Pande Under Item #243b
                } else if(att.Name.contains(UTL_CDAUtility.MANAGER_APPROVAL_DOC_KEYWORD)){
                    isManagerApprovalDocUplaoded = true;
                }
                // Added by Babita Dadarwal under CR-11458 Start
                if((att.Name.containsIgnoreCase(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_' + UTL_CDAUtility.CDA_FORMAT_PROWORD + '.' + UTL_CDAUtility.CDA_FORMAT_PDF))
                && !isPartiallyExecutedCdaDocumentAttached
                && (cdaRequest.Awaiting_Requestor_Submission_Date__c < att.CreatedDate)) {
                    isPartiallyExecutedCdaDocumentAttached = true;
                }
                if(isCDASourceExternal && !isPartiallyExecutedCdaDocumentAttached
                && (cdaRequest.Awaiting_Requestor_Submission_Date__c < att.CreatedDate)
                && (att.Name.containsIgnoreCase(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '.' + UTL_CDAUtility.CDA_FORMAT_PDF))){
                    isPartiallyExecutedCdaDocumentAttached = true;
                }
                // Added by Babita Dadarwal under CR-11458 End
            }
            if(generatedAttachment != null && cdaRequest.Awaiting_Requestor_Submission_Date__c > generatedAttachment.CreatedDate) {
                isGeneratedDocumentAttached = false;
            }

            if((cdaRequest.Competitor_Flag__c != UTL_CDAUtility.YES || isManagementApprovalDocumentAttached || isCDAExecutive) && (cdaRequest.Customer_Consent_to_Disclose__c != UTL_CDAUtility.YES || isCustomerConsenttoDiscloseAttached) && (cdaRequest.CDA_Type__c != 'Auditor' || isAuditScopeAgendaAttached) && (isExternalDocumentAttached || isGeneratedDocumentAttached || ((!isUserHavingApttusLicense || (isUserHavingApttusLicense && !isNegotiator)) && cdaRequest.CDA_Source__c != UTL_CDAUtility.CDASOURCE_EXTERNAL && !isGeneratedDocumentAttached)) && (cdaRequest.Sponsor_Consent_to_Disclose__c != UTL_CDAUtility.YES || isSponsorConsenttoDiscloseAttached) && ((!isUserHavingApttusLicense || (isUserHavingApttusLicense && !isNegotiator)) || (generatedAttachment != null && generatedAttachment.CreatedDate != null && (cdaRequest.Awaiting_Requestor_Submission_Date__c < generatedAttachment.CreatedDate)) || cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL) && (((isManagerApprovalDocUplaoded || !(isCdaTypeVendor && isCDASourceExternal) || isCDAExecutive) || !isBroadCDA))) {    //Updated by Vikram Singh under CR-11525
                isSubmitEnabeled = true;
            }
            if(isBroadCDA && !isManagerApprovalDocUplaoded){
                isSubmitEnabeled = false;
            }
            if(isBroadCDA && isManagerApprovalDocUplaoded && isGeneratedDocumentAttached){
                isSubmitEnabeled = true;
            }
            if(isCdaTypeAuditor && isProjSpeciIndiYes && isBusinessAreaRDS && !isManagerApprovalDocUplaoded){
                if(!isNegotiator && isAuditScopeAgendaAttached && ((cdaRequest.Customer_Consent_to_Disclose__c != UTL_CDAUtility.YES || isCustomerConsenttoDiscloseAttached))){
                    isSubmitEnabeled = true;
                }else{
                    if(isGeneratedDocumentAttached){
                        isSubmitEnabeled = true;
                    }
                }
            }
        } else { //Added by Vikram Singh under Issue-11631
            if((!isUserHavingApttusLicense || (isUserHavingApttusLicense && !isNegotiator)) && cdaRequest.CDA_Source__c != UTL_CDAUtility.CDASOURCE_EXTERNAL && cdaRequest.CDA_Type__c != 'Auditor' && cdaRequest.Competitor_Flag__c != UTL_CDAUtility.YES) {
                isSubmitEnabeled = true;
            }
            if(isBroadCDA && !isManagerApprovalDocUplaoded){
                isSubmitEnabeled = false;
            }
        }

        if(cdaRequest.Competitor_Flag__c == UTL_CDAUtility.YES && !isManagementApprovalDocumentAttached) {
            isAllRequiredDocAttached = false;
        }
        if(cdaRequest.Customer_Consent_to_Disclose__c == UTL_CDAUtility.YES && !isCustomerConsenttoDiscloseAttached) {
            isAllRequiredDocAttached = false;
        }
        if(cdaRequest.CDA_Type__c == UTL_CDAUtility.AUDITOR && !isAuditScopeAgendaAttached) {
            isAllRequiredDocAttached = false;
        }
        if(cdaRequest.Sponsor_Consent_to_Disclose__c == UTL_CDAUtility.YES && !isSponsorConsenttoDiscloseAttached) {
            isAllRequiredDocAttached = false;
        }
        if(cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_SENTFORSIGN || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_SIGNATURE_REQUEST_DENIED || isMiddleStatus || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_RETURNED_TO_REQUESTOR) { //Updated by Vikram Singh under Item #254 and C.P.Pandey under Item #29
            isStatusEditable = true;
        }
        if(cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED) {
            isSendCompletionEmailEnable = true;
        }
        if(cdaRequestAuthSignEdit.Recipient_Authorized_Signer_First_Name__c != null) {
            isAuthorizedSigner = UTL_CDAUtility.NO;
        }
        if(isAuthorizedSigner == UTL_CDAUtility.NO) {
            confirmRecipientAuthorizedSignerEmailAddress = cdaRequestAuthSignEdit.Recipient_Authorized_Signer_Email_Addres__c;
        }
        //Added by Vikram Singh under Item #190 Start
        if(cdaRequestIntNotesEdit.Internal_Processing_Notes__c != null) {
            isInternalNotesEditable = false;
        }
        //Added by Vikram Singh under Item #190 End

        setResponseDocumentType(cdaRequestResponseDocTypeEdit); //Added by Vikram Singh under CR-11146
    }

    public PageReference generateCDADoc() {
        if(cdaRequest != null) {
            SRV_CDA_CDARequest.generateCDADocument(cdaRequest);
        }
        PageReference pageRef = new PageReference(UTL_CDAUtility.SP_CHAR_SLASH + cdaRequest.Id);
        return pageRef;
    }

    public pageReference editRequest() {
        PageReference pageRef = new PageReference(UTL_CDAUtility.PAGE_EDIT_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRequest.id + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + UTL_CDAUtility.REQUEST_TYPE_EDIT);
        return pageRef;
    }

    public pageReference cancelRequest() {
        try {
            if(cdaRequestType == UTL_CDAUtility.REQUEST_TYPE_NEW) {
                delete cdaRequest;
            }
            PageReference pageRef = new PageReference(UTL_CDAUtility.PAGE_LANDING_SCREEN);
            return pageRef;
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
            return null;
        }
    }

    public void cancelbyRequestor() {
        try {
            Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
            cdaIdToCdaRequestMap.put(cdaRequest.Id, cdaRequest);
            string devEmails = UTL_CDAUtility.devEmails;
            List <string> ccAddress;
            if(devEmails != null) {
                ccAddress = devEmails.split(';');
            }
            string templateName = UTL_CDAUtility.EMAIL_CANCEL_BY_REQUESTOR;
            string toWhom = UTL_CDAUtility.NEGO_ASSIGNED;
            cdaRequest.Status__c = UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR;
            isCancelClicked = true;
            voidDocusignEnvpAndResubmit();
            update cdaRequest;
            if(!isNegotiator) {
                SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, toWhom, ccAddress, templateName);
            }
        } catch (Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }

    public void editNegotiatorDetails() {
        showNegotiatorEditable = true;
    }

    public pageReference updateNegotiatorDetails() {
        try {
            if(cdaRequest.Negotiator_Assigned_List__c != null || cdaRequest.Negotiating_Office__c != null || cdaRequest.Recipient_Affiliates__c != null || cdaRequest.QuintilesIMS_Affiliates_Value__c != null) {
                //cdaRequest.Status__c = UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE;
                cdaRequest.Negotiator_Assigned_List__c = negotiatorAssigned;
                update cdaRequest;
                //Added by Ajinkya Pande under Item #258 Start
                User loggedInUser = UTL_CDAUtility.getUserDetails();
                if(cdaRequest.Negotiator_Assigned_List__c != UTL_CDAUtility.NEGO_NOT_ASSIGN && cdaRequest.Negotiator_Assigned_List__c != UTL_CDAUtility.SELF_SERVICE_ONLY && cdaRequest.Negotiator_Assigned_List__c != cdaRequestNegoAssignEdit.Negotiator_Assigned_List__c && loggedInUser.Email != cdaRequest.Negotiator_Assigned_List__c) {
                    Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
                    cdaIdToCdaRequestMap.put(cdaRequest.Id, cdaRequest);
                    string devEmails = UTL_CDAUtility.devEmails;
                    List <string> ccAddress;
                    if(devEmails != null) {
                        ccAddress = devEmails.split(';');
                    }
                    SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.NEGO_ASSIGNED, ccAddress, UTL_CDAUtility.EMAIL_NEGOTIATOR_ASSIGNED);
                }
                //Added by Ajinkya Pande under Item #258 End
            }
            showNegotiatorEditable = false;
            PageReference pageRef = new PageReference(UTL_CDAUtility.SP_CHAR_SLASH + cdaRequest.Id);
            return pageRef;
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
            return null;
        }
    }

    // Updated by Babita Dadarwal under CR-11270 Start
    public void editCdaStatus() {
        cdaRequestStatusEdit = SRV_CDA_CDARequest.getCDARequest(cdaRequestStatusEdit.Id);
        if(cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED) {
            showStatusEditable = false;
            isStatusEditable = false;
            showExecutedRequestPopup = true;
        }
        else {
            showStatusEditable = true;
        }    
    }
    // Updated by Babita Dadarwal under CR-11270 End

    public PageReference updateCdaStatus() {
        try {
            showStatusEditable = false;
            // Updated by Babita Dadarwal under Item #29 Start
            if(cdaRequestStatusEdit.Status__c != null) { // && (cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES)) {
                if(cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED) {
                    cdaRequestStatusEdit.Status_Completion_Date__c = System.Now();
                }
                if(cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR) {
                    voidDocusignEnvpAndCancel();
                }
                // Added by C.P.Pandey under Item #43 (Day-2) Start
                try {
                    if(cdaRequestStatusEdit != null && (cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_AWAITING_OGC_COMPETITOR_APPROVAL || cdaRequestStatusEdit.Status__c == UTL_CDAUtility.STATUS_AWAITINGREQSUB || cdaRequest.Status__c == UTL_CDAUtility.STATUS_LANGUAGE_REVIEW)) {
                        if(cdaRequestStatusEdit.Negotiator_Assigned_List__c == UTL_CDAUtility.SELF_SERVICE_ONLY) {
                            cdaRequestStatusEdit.Negotiator_Assigned_List__c = UTL_CDAUtility.NEGO_NOT_ASSIGN;
                        }
                        Set<string> cdaIds = new Set<string>();
                        cdaIds.add((String)cdaRequestStatusEdit.get('CDA_Id__c'));
                        SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaIds);
                    }
                } catch(Exception ex) {
                    UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
                    UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
                    UTL_CDAUtility.logRef().generateLog();
                    if(ApexPages.currentPage() != null) {
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
                    }
                }
                // Added by C.P.Pandey under Item #43 (Day-2) End
                update cdaRequestStatusEdit;
            }
            // Updated by Babita Dadarwal under Item #29 End
            return new PageReference(UTL_CDAUtility.SP_CHAR_SLASH + cdaRequestStatusEdit.Id);
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
            return null;
        }
    }

    //Added by Vikram Singh under Item #190 Start
    public void updateInternalNotes() {
        if(!String.isBlank(cdaRequestIntNotesEdit.Internal_Processing_Notes__c)) {
            isInternalNotesEditable = isInternalNotesEditable == true ? false : true;
        }
        try {
            if(!isInternalNotesEditable && !String.isBlank(cdaRequestIntNotesEdit.Internal_Processing_Notes__c)) {
                update cdaRequestIntNotesEdit;
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }
    //Added by Vikram Singh under Item #190 End

    public void editAuthSignerDetails() {
        isAuthSignEditable = true;
    }

    public pageReference updateAuthSignerDetails() {
        try {
            isAuthSignEditable = false;
            if(isAuthorizedSigner == UTL_CDAUtility.YES) {
                cdaRequestAuthSignEdit.Recipient_Authorized_Signer_First_Name__c = null;
                cdaRequestAuthSignEdit.Recipient_Authorized_Signer_Last_Name__c = null;
                cdaRequestAuthSignEdit.Recipient_Authorized_Signer_Email_Addres__c = null;
                cdaRequestAuthSignEdit.Recipient_Authorized_Signer_Title__c = null;
            }
            update cdaRequestAuthSignEdit;

            return new PageReference(UTL_CDAUtility.SP_CHAR_SLASH + cdaRequestAuthSignEdit.Id);
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
            return null;
        }
    }

    //Updated by Vikram Singh under CR-11525 Start
    public void submitRequest() {
        try {
            if(cdaRequest.CDA_Source__c != UTL_CDAUtility.CDASOURCE_EXTERNAL && (!isUserHavingApttusLicense || (isUserHavingApttusLicense && !isNegotiator)) && cdaRequest.Status__c != UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING) {
                cdaRequest.Status__c = UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING;
                cdaRequest.Status_Start_Date__c = System.now();
                update cdaRequest;
            } else {  //Added by Vikram Singh under CR-11525
                Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
                cdaIdToCdaRequestMap.put(cdaRequest.Id, cdaRequest);
                string devEmails = UTL_CDAUtility.devEmails;
                List <string> ccAddress;
                if(devEmails != null) {
                    ccAddress = devEmails.split(';');
                }
                List<string> templateName = new List<String>();
                List<string> toWhom = new List<String>();
				cdaRequest.Customer_Signed_Date__c = null;
                cdaRequest.Date_executed_signed_contract_received__c = null;
                cdaRequest.Date_Sent_for_Review__c = null;
                cdaRequest.Status_Completion_Date__c = null;
                
                if((isUserHavingApttusLicense && isNegotiator) || cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL) { //Added by Vikram Singh under CR-11525 //Updated by Vikram Singh under Issue-11710
                    cdaRequest.Status_Start_Date__c = System.now();
                }
                if(cdaRequest.Competitor_System_Access__c != null && cdaRequest.Competitor_System_Access__c == UTL_CDAUtility.YES) {
                    templateName.add(UTL_CDAUtility.EMAIL_OGC_COMPETITOR_REVW_REQ);
                    toWhom.add(UTL_CDAUtility.CENTRALMAILBOX);
                    cdaRequest.Status__c = UTL_CDAUtility.STATUS_AWAITING_OGC_COMPETITOR_APPROVAL;
                } else if(cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS && cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PDF) {
                    SRV_CDA_DocusignStatus.createAndSendEnvelope(cdaRequest.ID);
                } else {
                    if(cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS && cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PROWORD) {
                        if(cdaRequest.CDA_Language__c == 'English')  {
                            ccAddress.add(UTL_CDAUtility.NegoMailBox);
                            UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;
                            templateName.add(UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST);
                            toWhom.add(isAuthorizedSigner == UTL_CDAUtility.YES ? UTL_CDAUtility.RECIPIENT : UTL_CDAUtility.AUTH_SIGN);   //Updated by Vikram Singh under CR-11146
                            cdaRequest.Status__c = UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW;
                            cdaRequest.Date_Sent_for_Review__c = System.now();
                        } else {
                            this.btnType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;
                            sendForLanguageReview();
                        }
                    }
                    if(cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL) {
                        if(cdaRequest.CDA_Language__c == 'English') {
                            toWhom.add(UTL_CDAUtility.CENTRALMAILBOX);
                            templateName.add(UTL_CDAUtility.EMAIL_EXTERNAL_PAPER_REVIEW);
                            cdaRequest.Status__c = UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES;
                        } else {
                            this.btnType = '';
                            sendForLanguageReview();
                        }
                    }
                }
                update cdaRequest;
                if(cdaIdToCdaRequestMap != null && cdaIdToCdaRequestMap.size() > 0 && toWhom != null && templateName != null && templateName.size() > 0) {
                    for(Integer i = 0; i < templateName.size(); i++) {
                        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, toWhom[i], ccAddress, templateName[i]);
                    }
                }
            }   
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }
    //Updated by Vikram Singh under CR-11525 End

    public void sendForReview() {
        try {
            Map<Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
            cdaIdToCdaRequestMap.put(cdaRequest.Id, cdaRequest);
            string devEmails = UTL_CDAUtility.devEmails;
            List<string> ccAddress;
            if(devEmails != null) {
                ccAddress = devEmails.split(';');
            }
            if(UTL_CDAUtility.NegoMailBox != null){
                ccAddress.add(UTL_CDAUtility.NegoMailBox);
            }
            string templateName = UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST;
            string toWhom = isAuthorizedSigner == UTL_CDAUtility.YES ? UTL_CDAUtility.RECIPIENT : UTL_CDAUtility.AUTH_SIGN;   //Updated by Vikram Singh under CR-11146
            cdaRequest.Status__c = UTL_CDAUtility.STATUS_SENTFOR_RECIPREVIEW;
            cdaRequest.Date_Sent_for_Review__c = System.now();
            UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_REVIEW;
            update cdaRequest;
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, toWhom, ccAddress, templateName);
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }

    /**
    * This method assigns CDA Request for Language Review to one of the Legal POC attorney based on the language followed by an email notification to this attorney 
    */
    public void sendForLanguageReview() {
        try {
            Map<Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
            cdaIdToCdaRequestMap.put(cdaRequest.Id, cdaRequest);
            string devEmails = UTL_CDAUtility.devEmails;
            List<string> bccAddress;
            if(devEmails != null) {
                bccAddress = devEmails.split(';');
            }
            string templateName = UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT;
            string toWhom = UTL_CDAUtility.LEGAL_POC;
            cdaRequest.Status__c = UTL_CDAUtility.STATUS_LANGUAGE_REVIEW;
            cdaRequest.Date_Sent_For_Language_Review__c = System.now();
            if(this.btnType == null) {
                this.btnType = UTL_CDAUtility.BUTTON_TYPE_LANGUAGE_REVIEW;
            }
            UTL_CDAUtility.buttonType = btnType;
            update cdaRequest;
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, toWhom, bccAddress, templateName);
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }

    public PageReference sendForSignature() {
        if(cdaRequest.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS && cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PDF) {
            SRV_CDA_DocusignStatus.createAndSendEnvelope(cdaRequest.ID);
        }
        return new PageReference(UTL_CDAUtility.PAGE_LANDING_SCREEN);
    }

    public void voidDocusignEnvpAndCancel() {
        try {
            if(cdaRequest != null) {
                Set<string> cdaIds = new Set<string>();
                cdaIds.add((String)cdaRequest.get('CDA_Id__c'));
                SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaIds);
                cdaRequest.Status__c = UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR;
                update cdaRequest;
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }

    public void voidDocusignEnvpAndResubmit() {
        try {
            if(cdaRequest != null) {
                Set<string> cdaIds = new Set<string>();
                cdaIds.add((String)cdaRequest.get('CDA_Id__c'));
                SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaIds);
                if(!isCancelClicked) {
                    cdaRequest.Status__c = UTL_CDAUtility.STATUS_AWAITINGREQSUB;
                    update cdaRequest;
                }
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }

    public void sendRecipientEmail() {
        if(cdaRequest.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED) {
            Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
            cdaIdToCdaRequestMap.put(cdaRequest.Id, cdaRequest);
            string devEmails = UTL_CDAUtility.devEmails;
            List<string> ccAddress;
            if(devEmails != null) {
                ccAddress = devEmails.split(';');
            }
            string templateName = UTL_CDAUtility.EMAIL_RECIPIENT_EXC8_CONFIRM;
            string toWhom = UTL_CDAUtility.RECIPIENT;
            string templateNameforRequestor = UTL_CDAUtility.EMAIL_REQ_EXCU8_AGGR_RECVD;
            string toWhomReq = UTL_CDAUtility.REQUESTOR;
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, toWhom, ccAddress, templateName);
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, toWhomReq, ccAddress, templateNameforRequestor);
        }
    }

    //Added by Ajinkya Pande under Item #162 Start
    public void respondToRequestorEmail() {
        if(cdaRequest != null) {
            cdaRequest.Status__c = UTL_CDAUtility.STATUS_RETURNED_TO_REQUESTOR;
            update cdaRequest;
            Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
            cdaIdToCdaRequestMap.put(cdaRequest.Id, cdaRequest);
            string devEmails = UTL_CDAUtility.devEmails;
            List <string> ccAddress;
            if(devEmails != null) {
                ccAddress = devEmails.split(';');
            }
            SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.REQUESTOR, ccAddress, UTL_CDAUtility.EMAIL_RESPONSE_TO_REQUESTOR);
        }
    }
    //Added by Ajinkya Pande under Item #162 End

    //Added by Vikram Singh under CR-11146 Start
    public void editCdaRequestResponseDocType() {
        isCdaRequestResponseDocTypeEditable = true;
    }

    /**
     * function determines and updates the response doc type that needs to be attached by negotiator.
     */
    public void setAndUpdateResponseDocumentType() {
        // system.assert(false,'1**'+responseDocumentType+'--'+cdaRequestResponseDocTypeEdit.What_documents_would_you_like_to_provide__c);
        try{
            if(isCdaRequestResponseDocTypeEditable && cdaRequestResponseDocTypeEdit.What_documents_would_you_like_to_provide__c != null) {
                setResponseDocumentType(cdaRequestResponseDocTypeEdit);
                update cdaRequestResponseDocTypeEdit;
                isCdaRequestResponseDocTypeEditable = false;
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRequest.Id, 'Exception Occurred in ViewController : ' + ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            if(ApexPages.currentPage() != null) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            }
        }
    }

    private void setResponseDocumentType(CDA_Request__c cdaRequestResponseDocTypeEdit) {
        if(cdaRequestResponseDocTypeEdit.What_documents_would_you_like_to_provide__c != null) {
            isResponseDocTypeRedlined = false;
            isResponseDocTypeCleaned = false;
            isResponseDocTypeRedlinedAndCleaned = false;
            responseDocumentType = cdaRequestResponseDocTypeEdit.What_documents_would_you_like_to_provide__c;
            // system.assert(false,responseDocumentType+'--'+cdaRequestResponseDocTypeEdit.What_documents_would_you_like_to_provide__c);

            if(responseDocumentType.toLowerCase() == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED.toLowerCase()) {
                isResponseDocTypeRedlined = true;
            } else if(responseDocumentType.toLowerCase() == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_CLEANED.toLowerCase()) {
                isResponseDocTypeCleaned = true;
            } else if(responseDocumentType.toLowerCase() == UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED_AND_CLEANED.toLowerCase()) {
                isResponseDocTypeRedlinedAndCleaned = true;
            }
        }
    }
    //Added by Vikram Singh under CR-11146 End

    //Added by Vikram Singh under CR-11691 Start
    public PageReference redirectHistoricalDataLayout() {
        return new SRV_CDA_CDARequest().redirectHistoricalDataLayout(request, 'v');   //'v' stands for view page rendering
    }
    //Added by Vikram Singh under CR-11691 End
    
    public List<SelectOption> getnegotiatorList(){
        List<SelectOption> options = new List<SelectOption>();
        for(CDA_Negotiator__c negotiator: [Select Name from CDA_Negotiator__c order by Name]){
            options.add(new SelectOption(negotiator.Name, negotiator.Name));
        }
        return options;
    }
    
    public String setnegotiatorAssigned(){
        return negotiatorAssigned;
    }
    
    public void getnegotiatorAssigned(String negotiatorAssigned){
        this.negotiatorAssigned = negotiatorAssigned;
    }
}