/*
*   @author    : Ajinkya
*   This class serves as a extension for VFP_CDA_RequestEditScreen page. (created under ER-3556 on 27/03/2017)
*/
public with sharing class EXT_CDA_RequestEditController {

    //Public variables
    public CDA_Request__c cdaRecord {get;set;}
    public QI_Legal_Entity__c qiLegalEntityRecord {get;set;}
    public CDA_Approved_Governing_Law_Location__c governingLawRecord {get;set;} //Added by Vikram Singh under CR-11576
    public String governingLaw {get;set;} //Added by Vikram Singh under CR-11576
    public Boolean isCdaTypeAuditor {get;set;}
    public Boolean isCdaTypeVendor {get;set;}
    public Boolean isCdaTypeCustomer {get;set;}
    public Boolean isCdaTypeCEVA {get;set;}
    public Boolean isCustomerLegalEntityOther {get;set;}
    public Boolean isRecipientAccountNameOther {get;set;}
    public Boolean isSponsorLegalEntityNameOther {get;set;}
    public string confirmEmailAddress {get;set;}
    public string confirmRecipientAuthorizedSignerEmailAddress {get;set;}
    public string recipientAccountName{get;set;}
    public string recipientAccountAddress {get;set;}
    public string sponsorLegalEntityAddress {get;set;}
    public string sponsorLegalEntityStreet {get;set;}
    public string sponsorLegalEntityCity {get;set;}
    //public string sponsorLegalEntityState {get;set;} // Commented by Babita Dadarwal under Item #200
    //public string sponsorLegalEntityCountry {get;set;} // Commented by Babita Dadarwal under Item #200
    public string sponsorLegalEntityZipCode {get;set;}
    public string customerLegalEntityAddress {get;set;}
    public string customerLegalEntityStreet {get;set;}
    public string customerLegalEntityCity {get;set;}
    public string customerLegalEntityState {get;set;}
    public string customerLegalEntitycountry {get;set;}
    public string customerLegalEntityZipCode {get;set;}
    public string recipientAccountStreet {get;set;}
    public string recipientAccountCity {get;set;}
    public string recipientAccountState {get;set;}
    public string recipientAccountCountry {get;set;}
    public string recipientAccountZipCode {get;set;}
    public String isAuthorizedSigner {get;set;}
    public string sponsorLegalEntityName{get;set;}
    public string customerLegalEntity{get;set;}
    public string qiLegalEntity{get;set;}
    public string cdaRequestType {get;set;}
    public CDA_Settings__c cdaSettings;
    //Added by Vikram Singh under CR-11188 Start
    public Boolean isDataAndServices {get; set;}
    public Boolean isClinicalResearch {get; set;}
    // public Boolean isCombinedOfferings {get; set;}   //Commented by Vikram Singh under CR-12057
    //Added by Vikram Singh under CR-11188 End
    public Boolean isQaTesting {get;set;}   //Added by Vikram Singh under CR-11526
    public string originatingRequestorConfirmEmailAddress {get;set;}    //Added by Vikram Singh under CR-11764
    public string projectDescriptionValue {get;set;}    //Added by Vikram Singh under CR-11683

    public String dateFormatString {
        get {
            return UTL_CDAUtility.DATE_FORMAT_STRING;
        }
        set;
    }

    public Boolean isCompetitor {
        get {
            return (cdaRecord.Competitor_Flag__c == UTL_CDAUtility.YES && cdaRecord.Competitor_Flag__c != null);
        }
        set;
    }

    public Boolean isNegotiator {
        get {
            return (SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.NEGOTIATOR || SRV_CDA_CDARequest.getUserPermission() == UTL_CDAUtility.SYS_ADMIN);
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

    public Boolean isProtocolNumberKnown {
        get {
            return (cdaRecord.Is_Protocol_Number_Known__c == UTL_CDAUtility.YES && cdaRecord.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isProtocolNumberNotKnown {
        get {
            return (cdaRecord.Is_Protocol_Number_Known__c == UTL_CDAUtility.NO && cdaRecord.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isProtocolTitleKnown {
        get {
            return (cdaRecord.Is_Protocol_Title_Known__c == UTL_CDAUtility.YES && cdaRecord.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isProtocolTitleNotKnown {
        get {
            return (cdaRecord.Is_Protocol_Title_Known__c == UTL_CDAUtility.NO && cdaRecord.Is_Protocol_Number_Known__c != null);
        }
        set;
    }

    public Boolean isProtocolHasToRender {
        get {
            return ((cdaRecord.Competitor_Contracting_Capacity__c != UTL_CDAUtility.CONTRACTINGCAPACITY_COLLABORATOR && cdaRecord.Competitor_Contracting_Capacity__c != null) || (cdaRecord.Project_Specific_Indicator__c == UTL_CDAUtility.YES && cdaRecord.Competitor_Contracting_Capacity__c == null));
        }
        set;
    }

    public Boolean isCompetitorContractingCapacityCollaborator {
        get {
            return (cdaRecord.Competitor_Contracting_Capacity__c == UTL_CDAUtility.CONTRACTINGCAPACITY_COLLABORATOR && cdaRecord.Competitor_Contracting_Capacity__c != null);
        }
        set;
    }

    public Boolean isCompetitorContractingCapacityVendor {
        get {
            return (cdaRecord.Competitor_Contracting_Capacity__c == UTL_CDAUtility.CONTRACTINGCAPACITY_VENDOR && cdaRecord.Competitor_Contracting_Capacity__c != null);
        }
        set;
    }

    public Boolean isCompetitorContractingCapacityCustomer {
        get {
            return (cdaRecord.Competitor_Contracting_Capacity__c == UTL_CDAUtility.CONTRACTINGCAPACITY_CUSTOMER && cdaRecord.Competitor_Contracting_Capacity__c != null);
        }
        set;
    }

    public Boolean whatIsTheStudySponsorSituationStudySponsorIdentified {
        get {
            return (cdaRecord.What_is_the_Study_Sponsor_situation__c == UTL_CDAUtility.STUDYSPONSORIDENTIFIED && cdaRecord.What_is_the_Study_Sponsor_situation__c != null);
        }
        set;
    }

    public Boolean showCdaFormat {
        get {
            return ((!isCdaTypeCEVA && cdaRecord.CDA_Source__c == UTL_CDAUtility.IQVIA) || (isCdaTypeCEVA && cdaRecord.Customer_Specified_Vendor_Template__c == UTL_CDAUtility.NO)); //Modified by Vikram Singh under CR-11577
        }
        set;
    }

    //Added by Babita Dadarwal under CR-11270 Start
    public Boolean showExecutedRequestPopup {
        get {
            return (cdaRecord.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED);
        }
        set;
    }
    //Added by Babita Dadarwal under CR-11270 End

    //Private variables
    private Id cdaRequestId;


    //Constructor
    public EXT_CDA_RequestEditController(ApexPages.StandardController controller) {
        cdaRequestId = controller.getId();
        cdaSettings = CDA_Settings__c.getOrgDefaults();
        cdaRequestType = ApexPages.currentPage().getparameters().get(UTL_CDAUtility.REQUEST_TYPE_STR);
        isQaTesting = ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR) == null ? false : Boolean.valueOf(ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR));    //Added by Vikrm Singh under CR-11526
        cdaRecord = SRV_CDA_CDARequest.getCDARequest(cdaRequestId);
        setDefaults();
    }


    //Public methods
    public void setDefaults() {
        if (cdaRequestType == UTL_CDAUtility.REQUEST_TYPE_NEW || (cdaRecord.QI_Legal_Entity_Name__c == null && cdaRecord.Location_of_Governing_Law__c == null)) {   //Updated by Vikram Singh under CR-11576
            setNewRequestDefaults();
        }
        qiLegalEntityRecord = SRV_CDA_CDARequest.getQILegalEntity(cdaRecord.QI_Legal_Entity_Name__c);
        qiLegalEntity = qiLegalEntityRecord.Name;
        governingLawRecord = SRV_CDA_CDARequest.getGoverningLaw(cdaRecord.Location_of_Governing_Law__c);    //Added by Vikram Singh under CR-11576
        governingLaw = governingLawRecord.Name; //Added by Vikram Singh under CR-11576
        isAuthorizedSigner = UTL_CDAUtility.YES;
        if (cdaRequestType == UTL_CDAUtility.REQUEST_TYPE_EDIT) {
            setEditRequestDefaults();
        }
        if(cdaRecord.Disclosure_Period__c == null) {
            cdaRecord.Disclosure_Period__c = UTL_CDAUtility.DEFAULT_DISCLOSURE_PERIOD;
        }
        customerLegalEntityAddress = cdaRecord.Cust_Legal_Entity_Address__c;
        recipientAccountAddress = cdaRecord.Recipient_Account_Address__c;
        sponsorLegalEntityAddress = cdaRecord.Sponsor_Legal_Entity_Address__c;
        setQIBusinessPart();    //Added by Vikram Singh under CR-11188
        setCdaTypeMethod();
    }

    //Updated by Vikram Singh under CR-11576 Start
    public void setNewRequestDefaults() {
        cdaRecord.QI_Legal_Entity_Name__c = UTL_CDAUtility.defaultLegalEntityId != null ? UTL_CDAUtility.defaultLegalEntityId : ''; //Id of 'IQVIA Inc.' (Default value)    //Updated by Vikram Singh under CR-11385, CR-11576
        cdaRecord.Location_of_Governing_Law__c = UTL_CDAUtility.defaultGoverningLawId != null ? UTL_CDAUtility.defaultGoverningLawId : ''; //Id of 'United States, State of Delaware.' (Default value)    //Added by Vikram Singh under CR-11576
        cdaRecord.QuintilesIMS_Affiliates_Value__c = UTL_CDAUtility.YES;
        //Commented by Vikram Singh under CR-11576 Start
        // Added by Vikram Singh under Item #256 Start
        // String defaultVal;
        // List <Schema.PicklistEntry> govLawPickVals = CDA_Request__c.Governing_Law__c.getDescribe().getPicklistValues();
        // for (Schema.PicklistEntry pv: govLawPickVals) {
        //     if (pv.isDefaultValue()) {
        //         defaultVal = pv.getValue();
        //     }
        // }
        // cdaRecord.Governing_Law__c = defaultVal;
        // Added by Vikram Singh under Item #256 End
        //Commented by Vikram Singh under CR-11576 End
    }

    public void setEditRequestDefaults() {
        //Added by Vikram Singh under CR-11576 Start
        if(cdaRecord.QI_Legal_Entity_Name__c != null){
            qiLegalEntityRecord.Name = cdaRecord.QI_Legal_Entity_Name__c;
        }
        //Added by Vikram Singh under CR-11576 End
        if(cdaRecord.Location_of_Governing_Law__c != null){
            governingLawRecord.Name = cdaRecord.Location_of_Governing_Law__c;  //Updated by Vikram Singh under CR-11576
        }
        if (cdaRecord.Recipient_Authorized_Signer_First_Name__c != null) {
            isAuthorizedSigner = UTL_CDAUtility.NO;
        }
        if(cdaRecord.Customer_Legal_Entity_Name_Other__c != null) {
            isCustomerLegalEntityOther = true;
        } else if(cdaRecord.Cust_Legal_Entity_Name__c != null) {
            customerLegalEntity = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Cust_Legal_Entity_Name__c).Name;
        }
        if(cdaRecord.Recipient_Account_Name_Other__c != null) {
            isRecipientAccountNameOther = true;
        } else if(cdaRecord.Recipient_Account__c != null) {
            recipientAccountName = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Recipient_Account__c).Name;
        }
        if(cdaRecord.Sponsor_Legal_Entity_Name_Other__c != null) {
            isSponsorLegalEntityNameOther = true;
        } else if(cdaRecord.Sponsor_Legal_Entity__c != null) {
            sponsorLegalEntityName = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Sponsor_Legal_Entity__c).Name;
        }
        confirmEmailAddress = cdaRecord.Recipient_Point_of_Contact_Email_Address__c;

        if(isAuthorizedSigner == UTL_CDAUtility.YES){
            confirmRecipientAuthorizedSignerEmailAddress = cdaRecord.Recipient_Authorized_Signer_Email_Addres__c;
        }

        //Added by Vikram Singh under CR-11764 Start
        if(cdaRecord.Originating_Requestor_Flag__c == UTL_CDAUtility.YES) {
            if(cdaRecord.Originating_Requestor_IQVIA_Email__c != null) {
                originatingRequestorConfirmEmailAddress = cdaRecord.Originating_Requestor_IQVIA_Email__c;
            }
        }
        //Added by Vikram Singh under CR-11764 End
        //Added by Vikram Singh under CR-11683 Start
        if(cdaRecord.Project_Description_Textarea__c != null) {
            projectDescriptionValue = cdaRecord.Project_Description_Textarea__c;
        }
        //Added by Vikram Singh under CR-11683 End
    }
    //Updated by Vikram Singh under CR-11576 End

    public void resetDefaults() {
        cdaRecord.Audit_Type__c = null;
        // cdaRecord.QuintilesIMS_Business__c = null;   //Commented by Vikram Singh under CR-11188
        cdaRecord.Customer_Consent_to_Disclose__c = null;
        isCustomerLegalEntityOther = false;
        resetDefaultQILegalEntity(); //Added by C.P.Pandey under Issue-12073
        setCustomerLegalEntityOther();
        cdaRecord.CDA_Source__c = null;
        cdaRecord.CDA_Format__c = null;
        cdaRecord.Competitor_Flag__c = null;
        setSpecificIndicatorMethod();
        resetOriginatingRequestorFlag();  //Added by Vikram Singh under CR-11764
        recipientAccountNameOtherChanged();
        sponsorConsentToDiscloseChanged();
        recipientPointOfContactChanged();
        recipientAuthorizedSignerChanged();
    }

    //Added by Vikram Singh under Issue-12073 Start
    public void resetDefaultQILegalEntity() {
        if(cdaRecord.QuintilesIMS_Business__c == UTL_CDAUtility.CDA_BUSINESS_PART_LI) {
            cdaRecord.QI_Legal_Entity_Name__c = UTL_CDAUtility.defaultLegalEntityId != null ? UTL_CDAUtility.defaultLegalEntityId : '';
        }
        else {
            cdaRecord.QI_Legal_Entity_Name__c = UTL_CDAUtility.defaultLegalEntityIdForComm != null ? UTL_CDAUtility.defaultLegalEntityIdForComm : '';
        }
        cdaRecord.Location_of_Governing_Law__c = UTL_CDAUtility.defaultGoverningLawId != null ? UTL_CDAUtility.defaultGoverningLawId : '';
        qiLegalEntityRecord = SRV_CDA_CDARequest.getQILegalEntity(cdaRecord.QI_Legal_Entity_Name__c);
        qiLegalEntity = qiLegalEntityRecord.Name;
        governingLawRecord = SRV_CDA_CDARequest.getGoverningLaw(cdaRecord.Location_of_Governing_Law__c);
        governingLaw = governingLawRecord.Name;
    }
    //Added by Vikram Singh under Issue-12073 End

    //Added by Vikram Singh under CR-11764 Start
    public void resetOriginatingRequestorSection() {
        cdaRecord.Originating_Requestor_First_Name__c = null;
        cdaRecord.Originating_Requestor_Last_Name__c = null;
        cdaRecord.Originating_Requestor_IQVIA_Email__c = null;
        originatingRequestorConfirmEmailAddress = null;
        cdaRecord.Requestor_Admin_Email_Flag__c = UTL_CDAUtility.NO;
    }

    public void resetOriginatingRequestorFlag() {
        cdaRecord.Originating_Requestor_Flag__c = null;
        resetOriginatingRequestorSection();
    }
    //Added by Vikram Singh under CR-11764 End

    //Added by Vikram Singh under CR-11188 Start
    public void setQIBusinessPart() {
        isDataAndServices = SRV_CDA_CDARequest.isDataAndServices(cdaRecord.QuintilesIMS_Business__c);
        isClinicalResearch = SRV_CDA_CDARequest.isClinicalResearch(cdaRecord.QuintilesIMS_Business__c);
        // isCombinedOfferings = false;//SRV_CDA_CDARequest.isCombinedOfferings(cdaRecord.QuintilesIMS_Business__c);    //Commented by Vikram Singh under CR-12057
    }

    public void qiBusinessPartChanged() {
        cdaRecord.CDA_Type__c = null;
        // resetDefaults();
        setQIBusinessPart();
    }
    //Added by Vikram Singh under CR-11188 End

    /**
     *  This method set the rendering flags of vfPage
     */
    public void setCdaTypeMethod() {
        isCdaTypeAuditor = SRV_CDA_CDARequest.isCdaTypeAuditor(cdaRecord.CDA_Type__c);
        isCdaTypeVendor = SRV_CDA_CDARequest.isCdaTypeVendor(cdaRecord.CDA_Type__c);
        isCdaTypeCustomer = SRV_CDA_CDARequest.isCdaTypeCustomer(cdaRecord.CDA_Type__c);
        isCdaTypeCEVA = SRV_CDA_CDARequest.isCdaTypeCEVA(cdaRecord.CDA_Type__c);
    }

    public void setSpecificIndicatorMethod() {
        if (cdaRecord.CDA_Type__c == UTL_CDAUtility.AUDITOR) {
            if (cdaRecord.Audit_Type__c == UTL_CDAUtility.PROJECT) {
                cdaRecord.Project_Specific_Indicator__c = UTL_CDAUtility.YES;
            } else if (cdaRecord.Audit_Type__c == UTL_CDAUtility.QUALIFICATION) {
                cdaRecord.Project_Specific_Indicator__c = UTL_CDAUtility.NO;
            } else {
                cdaRecord.Project_Specific_Indicator__c = null;
            }
        } else if (cdaRecord.Competitor_Flag__c == UTL_CDAUtility.YES) {
            cdaRecord.Project_Specific_Indicator__c = UTL_CDAUtility.YES;
        } else if (cdaRecord.Competitor_Flag__c == UTL_CDAUtility.NO) {
            cdaRecord.Project_Specific_Indicator__c = null;
        }
        competitorFlagChanged();
    }

    public void competitorFlagChanged() {
        cdaRecord.Competitor_Contracting_Capacity__c = null;
        cdaRecord.Competitor_Originating_from_Sponsor__c = null;
        if(cdaRecord.Competitor_Flag__c != UTL_CDAUtility.YES) {
            recipientAccountNameOtherChanged();
        }
        competitorContractingCapacityChanged();
    }

    public void competitorContractingCapacityChanged() {
        if(!isCdaTypeAuditor && cdaRecord.Project_Specific_Indicator__c != UTL_CDAUtility.YES) {   //Updated by Vikram Singh under CR-11683
            isProtocolNumberKnownChanged();
        }
        whatIsTheStudySponsorSituationChanged();
        if (cdaRecord.Competitor_System_Access__c != null) {
            cdaRecord.Competitor_System_Access__c = null;
        }
        competitorSystemAccessChanged();
    }

    public void isProtocolNumberKnownChanged() {
        cdaRecord.Is_Protocol_Number_Known__c = null;
        isProtocolTitleKnownChanged();
    }

    public void isProtocolTitleKnownChanged() {
        cdaRecord.Protocol_Number__c = null;
        cdaRecord.Is_Protocol_Title_Known__c = null;
        isProtocolTitleDiscriptionChanged();
    }

    public void isProtocolTitleDiscriptionChanged() {
        cdaRecord.Protocol_Title__c = null;
        cdaRecord.Project_Description_Textarea__c = null;    //Updated by Vikram Singh under CR-11529
    }

    //Added by Vikram Singh under CR-11683 Start
    public void setProjectDescription() {
        cdaRecord.Project_Description_Textarea__c = projectDescriptionValue;
    }
    //Added by Vikram Singh under CR-11683 End

    public void whatIsTheStudySponsorSituationChanged() {
        cdaRecord.What_is_the_Study_Sponsor_situation__c = null;
        sponsorConsentToDiscloseChanged();
    }

    public void sponsorConsentToDiscloseChanged() {
        if (cdaRecord.Sponsor_Consent_to_Disclose__c != null && (!whatIsTheStudySponsorSituationStudySponsorIdentified || cdaRecord.What_is_the_Study_Sponsor_situation__c == null)) {
            cdaRecord.Sponsor_Consent_to_Disclose__c = null;
        }
        sponsorLegalEntityNameOtherChanged();
    }

    public void sponsorLegalEntityNameOtherChanged() {
        cdaRecord.Sponsor_Legal_Entity__c = null;
        sponsorLegalEntityName = null;
        sponsorLegalEntityAddress = null;
        cdaRecord.Sponsor_Legal_Entity_Name_Other__c = null;
    }

    public void competitorSystemAccessChanged() {
        cdaRecord.Systems_To_Be_Accessed__c = null;
        cdaRecord.Purpose_for_Working_for_a_Competitor__c = null;
        cdaRecord.Description_of_work_provided_to_Customer__c = null;
        cdaRecord.Desc_of_Work_provided_to_Cust_By_Comp__c = null;
        cdaRecord.QI_information_disclosed_to_competitor__c = null;
        cdaRecord.Competitor_information_disclosed_to_QI__c = null;
    }

    public void cdaTypeChanged() {
        resetDefaults();
        setCdaTypeMethod();
        if (isCdaTypeCEVA) {
            if (cdaRecord.Customer_Specified_Vendor_Template__c == UTL_CDAUtility.YES) {
                cdaRecord.CDA_Source__c = UTL_CDAUtility.CDASOURCE_EXTERNAL;
            } else {
                cdaRecord.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
            }
            cdaRecord.Project_Specific_Indicator__c = UTL_CDAUtility.YES;
            cdaRecord.Competitor_Flag__c = UTL_CDAUtility.NO;
        }
        if (isCdaTypeAuditor) {
            cdaRecord.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        }
    }

    public void cdaSourceChanged() {
        cdaRecord.CDA_Format__c = null;
        if (cdaRecord.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS) {
            cdaRecord.QuintilesIMS_Affiliates_Value__c = UTL_CDAUtility.YES;
        }
        if(cdaRecord.CDA_Source__c == UTL_CDAUtility.CDASOURCE_EXTERNAL) {
            cdaRecord.QuintilesIMS_Affiliates_Value__c = null;
        }
        if((isCdaTypeCustomer || isCdaTypeCEVA || isCdaTypeVendor) && cdaRecord.CDA_Source__c == UTL_CDAUtility.CDASOURCE_QUINTILESIMS) {
            cdaRecord.Recipient_Affiliates__c = UTL_CDAUtility.YES;
        }
    }

    public void customerSpecifiedVendorTemplateChanged() {
        if (cdaRecord.Customer_Specified_Vendor_Template__c == UTL_CDAUtility.YES) {
            cdaRecord.CDA_Source__c = UTL_CDAUtility.CDASOURCE_EXTERNAL;
        } else {
            cdaRecord.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        }
    }

    public void setCustomerLegalEntityOther() {
        cdaRecord.Cust_Legal_Entity_Name__c = null;
        customerLegalEntity = null;
        customerLegalEntityAddress = null;
        cdaRecord.Customer_Legal_Entity_Name_Other__c = null;
        cdaRecord.Customer_Legal_Entity_Address_Other__c = null;
        cdaRecord.Customer_Legal_Entity_Street_Other__c = null;
        cdaRecord.Customer_Legal_Entity_City_Other__c = null;
        cdaRecord.Customer_Legal_Entity_State_Other_PL__c = null; // Updated by Babita Dadarwal under Item #200
        cdaRecord.Customer_Legal_Entity_Country_Other_PL__c = null; // Updated by Babita Dadarwal under Item #200
        cdaRecord.Customer_Legal_Entity_ZipCode_Other__c = null;
    }

    public void recipientAccountNameOtherChanged() {
        cdaRecord.Recipient_Account__c = null;
        recipientAccountAddress = null;
        recipientAccountName = null;
        cdaRecord.Recipient_Account_Name_Other__c = null;
        cdaRecord.Recipient_Account_Street_Other__c = null;
        cdaRecord.Recipient_Account_City_Other__c = null;
        cdaRecord.Recipient_Account_State_Other_PL__c = null; // Updated by Babita Dadarwal under Item #200
        cdaRecord.Recipient_Account_Country_Other_PL__c = null; // Updated by Babita Dadarwal under Item #200
        cdaRecord.Recipient_Account_ZipCode_Other__c = null;
    }

    public void recipientPointOfContactChanged() {
        cdaRecord.Recipient_Point_of_Contact_Prefix__c = null;
        cdaRecord.Recipient_Point_of_Contact_First_Name__c = null;
        cdaRecord.Recipient_Point_of_Contact_Last_Name__c = null;
        cdaRecord.Recipient_Point_of_Contact_Title__c = null;
        cdaRecord.Recipient_Point_of_Contact_Telephone_Num__c = null;
        cdaRecord.Recipient_Point_of_Contact_Email_Address__c = null;
        cdaRecord.Recipient_Point_of_Contact_Preferred_Met__c = UTL_CDAUtility.EMAIL;
        confirmEmailAddress = null;
        isAuthorizedSigner = UTL_CDAUtility.YES;
    }

    public void recipientAuthorizedSignerChanged() {
        cdaRecord.Recipient_Authorized_Signer_Title__c = null;
        cdaRecord.Recipient_Authorized_Signer_First_Name__c = null;
        cdaRecord.Recipient_Authorized_Signer_Last_Name__c = null;
        cdaRecord.Recipient_Authorized_Signer_Email_Addres__c = null;
        confirmRecipientAuthorizedSignerEmailAddress = null;
    }

    public void qiLegalEntityNameChanged() {
        if (cdaRecord.QI_Legal_Entity_Name__c != null) {
            qiLegalEntityRecord = SRV_CDA_CDARequest.getQILegalEntity(cdaRecord.QI_Legal_Entity_Name__c);
        }
    }

    public void customerLegalEntityNameChanged() {
        if (cdaRecord.Cust_Legal_Entity_Name__c != null) {
            CDA_Account__c cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Cust_Legal_Entity_Name__c);
            if(cdaAccountC != null) {
                customerLegalEntityAddress = cdaAccountC.Complete_Address__c;
            }
        }
    }

    public void sponsorLegalEntityNamechanged() {
        if (cdaRecord.Sponsor_Legal_Entity__c != null) {
            CDA_Account__c cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Sponsor_Legal_Entity__c);
            if(cdaAccountC != null) {
                sponsorLegalEntityAddress = cdaAccountC.Complete_Address__c;
            }
        }
    }

    public void recipientAccountNameChanged() {
        if (cdaRecord.Recipient_Account__c != null) {
            CDA_Account__c cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Recipient_Account__c);
            if(cdaAccountC != null) {
                recipientAccountAddress = cdaAccountC.Complete_Address__c;
            }
        }
    }

    public void saveForLaterRecord() {
        try {
            if(cdaRequestType == UTL_CDAUtility.REQUEST_TYPE_NEW || cdaRecord.Status__c == UTL_CDAUtility.STATUS_INDRAFT) {
                if(isCdaTypeAuditor) {
                    if(cdaRecord.Competitor_Flag__c == UTL_CDAUtility.YES){
                        cdaRecord.Competitor_Flag__c = null;
                    }
                    competitorFlagChanged();
                }
                cdaRecord.Status__c = UTL_CDAUtility.STATUS_INDRAFT;   //Added by Vikram Singh under Item #38(Day-2)
                upsert cdaRecord;
            }
        } catch (Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRecord.Id , 'Exception Occurred in EditController : '+ ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
        }
    }

    public PageReference saveRecord() {
        try {
            Map<Id,CDA_Account__c> toBeUpdated =  new Map<Id,CDA_Account__c>();
            if (cdaRecord != null && cdaRecord.Cust_Legal_Entity_Name__c != null && isCdaTypeAuditor) {
                CDA_Account__c cdaAccountC;
                if(toBeUpdated != null && toBeUpdated.size() > 0 && toBeUpdated.containsKey(cdaRecord.Cust_Legal_Entity_Name__c)) {
                    cdaAccountC = toBeUpdated.get(cdaRecord.Cust_Legal_Entity_Name__c);
                }
                else {
                    cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Cust_Legal_Entity_Name__c);
                }
                if(cdaRecord.Cust_Legal_Entity_Address__c == null) {
                   if (cdaAccountC != null && customerLegalEntityStreet != null && customerLegalEntitycountry != null) {
                        cdaAccountC.Street__c = customerLegalEntityStreet;
                        cdaAccountC.City__c = customerLegalEntityCity;
                        cdaAccountC.State__c = customerLegalEntityState;
                        cdaAccountC.Country__c = customerLegalEntitycountry;
                        cdaAccountC.Zip_Postal_Code__c = customerLegalEntityZipCode;
                    }
                }
                if(cdaAccountC.Id != null) {
                    toBeUpdated.put(cdaAccountC.Id , cdaAccountC);
                }
            }
            if (cdaRecord != null && cdaRecord.Sponsor_Legal_Entity__c != null) {
                CDA_Account__c cdaAccountC;
                if(toBeUpdated != null && toBeUpdated.size() > 0 && toBeUpdated.containsKey(cdaRecord.Sponsor_Legal_Entity__c)) {
                    cdaAccountC = toBeUpdated.get(cdaRecord.Sponsor_Legal_Entity__c);
                } else {
                    cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Sponsor_Legal_Entity__c);
                }
                if (cdaRecord.What_is_the_Study_Sponsor_situation__c != null && cdaRecord.What_is_the_Study_Sponsor_situation__c == UTL_CDAUtility.STUDYSPONSORIDENTIFIED) {
                        cdaAccountC.CDA_Sponsor_Indicator__c = true;
                }
                // Updated by Babita Dadarwal under Item #200 Start
                // if(cdaRecord.Sponsor_Legal_Entity_Address__c == null && cdaAccountC != null && sponsorLegalEntityStreet != null && sponsorLegalEntitycountry != null) {
                if(cdaRecord.Sponsor_Legal_Entity_Address__c == null && cdaAccountC != null && sponsorLegalEntityStreet != null && cdaRecord.Sponsor_Legal_Entity_Country_Other_PL__c != null) {
                    cdaAccountC.Street__c = sponsorLegalEntityStreet;
                    cdaAccountC.City__c = sponsorLegalEntityCity;
                    // cdaAccountC.State__c = sponsorLegalEntityState;
                    // cdaAccountC.Country__c = sponsorLegalEntitycountry;
                    cdaAccountC.State__c = cdaRecord.Sponsor_Legal_Entity_State_Other_PL__c;
                    cdaAccountC.Country__c = cdaRecord.Sponsor_Legal_Entity_Country_Other_PL__c;
                    cdaAccountC.Zip_Postal_Code__c = sponsorLegalEntityZipCode;
                }
                // Updated by Babita Dadarwal under Item #200 End
                if(cdaAccountC != null && cdaAccountC.Id != null ){
                    toBeUpdated.put(cdaAccountC.Id , cdaAccountC);
                }
            }
            if (cdaRecord != null && cdaRecord.Recipient_Account__c != null) {
                CDA_Account__c cdaAccountC;
                if(toBeUpdated != null && toBeUpdated.size() > 0 && toBeUpdated.containsKey(cdaRecord.Recipient_Account__c)) {
                    cdaAccountC = toBeUpdated.get(cdaRecord.Recipient_Account__c);
                }
                else{
                    cdaAccountC = SRV_CDA_CDARequest.getCDAAccount(cdaRecord.Recipient_Account__c);
                }
                if(cdaRecord.Recipient_Account_Address__c == null && cdaAccountC != null && recipientAccountStreet != null && recipientAccountCountry != null && recipientAccountZipCode != null) {
                    cdaAccountC.Street__c = recipientAccountStreet;
                    cdaAccountC.City__c = recipientAccountCity;
                    cdaAccountC.State__c = recipientAccountState;
                    cdaAccountC.Country__c = recipientAccountCountry;
                    cdaAccountC.Zip_Postal_Code__c = recipientAccountZipCode;
                }
                if (cdaAccountC != null && cdaRecord.Competitor_Flag__c != null && cdaRecord.Competitor_Flag__c == UTL_CDAUtility.YES) {
                        cdaAccountC.Competitor_flag__c = true;
                }
                if (cdaAccountC != null && cdaRecord.CDA_Type__c != null && isCdaTypeAuditor) {
                    cdaAccountC.CDA_Auditor_Indicator__c = true;
                } else if (cdaAccountC != null && cdaRecord.CDA_Type__c != null && isCdaTypeCustomer) {
                    cdaAccountC.CDA_Customer_Indicator__c = true;
                } else if (cdaAccountC != null && cdaRecord.CDA_Type__c != null && isCdaTypeVendor) {
                    cdaAccountC.CDA_Vendor_Indicator__c = true;
                } else if(cdaAccountC != null && cdaRecord.CDA_Type__c != null && isCdaTypeCEVA) {
                    cdaAccountC.CEVA_Committee_Member__c = true;
                }
                if(cdaAccountC != null && cdaAccountC.Id != null ){
                    toBeUpdated.put(cdaAccountC.Id , cdaAccountC);
                }
            }
            cdaRecord.Status__c = UTL_CDAUtility.STATUS_AWAITINGREQSUB;
            //Added by Vikram Singh under Issue-12109 Start
            if(isDataAndServices || isProtocolTitleNotKnown){
                cdaRecord.Project_Description_Textarea__c = projectDescriptionValue;
            }
            //Added by Vikram Singh under Issue-12109 End
            //cdaRecord.QI_Legal_Entity_Governing_Law__c = qiLegalEntityRecord.Governing_Law__c;
            //Added by Vikram Singh under Item #256 Start
            if(cdaRecord.Location_of_Governing_Law__c != null) {    //Updated by Vikram Singh under CR-11576
                String glStr = governingLaw; //cdaRecord.Governing_Law__c; //Updated by Vikram Singh under CR-11576
                if(UTL_CDAUtility.governingLawNameAndPrintNameMap.containsKey(glStr)) {
                    String glDisplayStr = UTL_CDAUtility.governingLawNameAndPrintNameMap.get(glStr).Display_Text__c != null ? UTL_CDAUtility.governingLawNameAndPrintNameMap.get(glStr).Display_Text__c : glStr;
                    cdaRecord.Governing_Law_Display_Text__c = glDisplayStr;
                } else {
                    cdaRecord.Governing_Law_Display_Text__c = glStr;
                }
            }
            //Added by Vikram Singh under Item #256 End
            cdaRecord.Awaiting_Requestor_Submission_Date__c = System.now();

            // Added by C.P.Pandey under Item #43 (Day-2) Start
            if(cdaRecord.Negotiator_Assigned_List__c == UTL_CDAUtility.SELF_SERVICE_ONLY) {
                cdaRecord.Negotiator_Assigned_List__c = UTL_CDAUtility.NEGO_NOT_ASSIGN;
            }
            // Added by C.P.Pandey under Item #43 (Day-2) End

            //Added by Vikram Singh under CR-11764 Start
            if(isRequestorAdmin && cdaRecord.Originating_Requestor_Flag__c == UTL_CDAUtility.YES){
                cdaRecord.On_Behalf_of_User_Full_Name__c = cdaRecord.Originating_Requestor_Full_Name__c != null ? cdaRecord.Originating_Requestor_Full_Name__c : cdaRecord.Originating_Requestor_First_Name__c +' '+cdaRecord.Originating_Requestor_Last_Name__c;
            }else {
                cdaRecord.On_Behalf_of_User_Full_Name__c = cdaRecord.Owner.Name != null ? cdaRecord.Owner.Name : UTL_CDAUtility.getUserDetails().Name;  //Updated by Vikram Singh under Issue-11855
            }
            //Added by Vikram Singh under CR-11764 End

            upsert cdaRecord;
            system.debug('####OnBehalfOfUser in EditController: '+cdaRecord.On_Behalf_of_User_Full_Name__c);
            // Added by C.P.Pandey under Issue-11535 start
            if(cdaRecord.CDA_Format__c != UTL_CDAUtility.CDA_FORMAT_PDF && cdaRecord.get('CDA_Id__c') != null && cdaRequestType == UTL_CDAUtility.REQUEST_TYPE_EDIT) { // Modified by C.P.Pandey under Issue-11579
                Set<string> cdaIds = new Set<string>();
                cdaIds.add((String)cdaRecord.get('CDA_Id__c'));
                SRV_CDA_DocusignStatus.setVoidToDocusignEnvelope(cdaIds);
            }
            // Added by C.P.Pandey under Issue-11535 end
            if(toBeUpdated != null && toBeUpdated.size() > 0) {
                update toBeUpdated.values();
            }
            PageReference page;
            // page = new PageReference('/apex/VFP_CDA_RequestViewScreen?id=' + cdaRecord.id+'&reqType='+cdaRequestType);
            page = new PageReference(UTL_CDAUtility.PAGE_VIEW_SCREEN + UTL_CDAUtility.SP_CHAR_QUESTION + UTL_CDAUtility.REQUEST_ID_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRecord.id + UTL_CDAUtility.SP_CHAR_AMPERSAND + UTL_CDAUtility.REQUEST_TYPE_STR + UTL_CDAUtility.SP_CHAR_EQUAL + cdaRequestType);
            return page;
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRecord.Id , 'Exception Occurred in EditController : '+ ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            return null;
        }
    }

    public List <SelectOption> getIsAuditorIsEmp() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        options.add(new SelectOption(UTL_CDAUtility.YES, 'Yes'));
        options.add(new SelectOption(UTL_CDAUtility.NO, 'No'));
        return options;
    }

    //Updated by Vikram Singh under Item #38(Day-2)
    public PageReference cancel() {
        // try {
        //     if(cdaRequestType == UTL_CDAUtility.REQUEST_TYPE_NEW) {
        //         delete cdaRecord;
        //     }
            PageReference page = new PageReference(UTL_CDAUtility.PAGE_LANDING_SCREEN);
            return page;
        // } catch(Exception ex) {
        //     UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
        //     UTL_CDAUtility.setLogObject(cdaRecord.Id , 'Exception Occurred in EditController : '+ ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
        //     UTL_CDAUtility.logRef().generateLog();
        //     Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
        //     return null;
        // }
    }

    // Modified by C.P.Pandey under Item#32(Day-2) start
    public PageReference cdaRequestDeleteAndReturnToLanding() {
        try {
            if(cdaRecord != null && cdaRecord.Id != null && cdaRecord.Status__c != UTL_CDAUtility.STATUS_SENTFORSIGN) {
                delete cdaRecord;
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject(cdaRecord.Id , 'Exception Occurred in EditController : '+ ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, ex.getMessage()));
            return null;
        }
        PageReference page = new PageReference(UTL_CDAUtility.PAGE_LANDING_SCREEN);
        return page;
    }
    // Modified by C.P.Pandey under Item#32(Day-2) end

    //Added by Vikram Singh under CR-11691 Start
    public PageReference redirectHistoricalDataLayout() {
        return new SRV_CDA_CDARequest().redirectHistoricalDataLayout(cdaRecord, 'e');   //'e' stands for view page rendering
    }
    //Added by Vikram Singh under CR-11691 End
}