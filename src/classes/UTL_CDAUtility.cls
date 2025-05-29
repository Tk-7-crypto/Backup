public with sharing class UTL_CDAUtility {
    //  public static string serverURL = '';
    public static CDA_Settings__c settingObject = CDA_Settings__c.getOrgDefaults();
    public static Boolean isSendOutgoingEmails = settingObject.Email_Communication_Flag__c;
    public static String userNameContract = settingObject.CDAContractUserName__c;
    public static String passwordContract = settingObject.CDAContractPassword__c;
    public static String serverURLContract = settingObject.CDAContractServerURL__c;
    public static String cdaTemplateMapping = Label.CDA_Doc_Template_Mapping;
    public static string NegoMailBox = settingObject.CDA_Negotiator_central_Mailbox__c;
    public static string devEmails = settingObject.CDA_Dev_Emails__c;
    public static string legalEmails = settingObject.CDA_Legal_Emails__c;     // Added by Vikram Singh under Issue-11311
    public static Boolean isTraceCdaLogs = settingObject.Is_Trace_CDA_Logs__c;
    public static Boolean forceUpdateStatus = settingObject.forceUpdateStatus__c;
    public static String processRequestBatchClassId = settingObject.Process_Request_Batch_Class_Id__c; // Added by Vikram Singh under CR-11525
    public static Decimal processRequestBatchExecutionTime = settingObject.Process_Request_Batch_Execution_Time__c; // Added by Vikram Singh under CR-11525
    public static Boolean isCdaSystemDown = settingObject.Is_CDA_System_Down__c; // Added by Vikram Singh under CR-11526
    public static String defaultLegalEntityId = settingObject.Default_QI_Legal_Entity_Id__c;    //Added by Vikram Singh under CR-11576
    public static String defaultLegalEntityIdForComm = settingObject.Default_Legal_Entity_Id_IQVIA_Commercial__c;    //Added by C.P.Pandey under Issue-12073
    public static String defaultGoverningLawId = settingObject.Default_Governing_Law_Id__c;    //Added by Vikram Singh under CR-11576
    public static String historicalDataRecordType = settingObject.HistoricalDataRecordType__c;    //Added by Vikram Singh under CR-11691
    public static Integer remindersDaysInterval = Integer.valueOf(settingObject.CDA_Reminders_Interval__c); //Added by Vikram Singh under Issue-12008
    public static Integer remindersDaysIntervalForCustomer = Integer.valueOf(settingObject.CDA_Reminders_Interval_for_Customer__c); //Added by Vikram Singh under Issue-12008
    public static Integer languageReviewReminderPrimaryDaysInterval = Integer.valueOf(settingObject.LanguageReviewReminderPrimary__c);
    public static Integer languageReviewReminderSecondaryDaysInterval = Integer.valueOf(settingObject.LanguageReviewReminderSecondary__c);
    public static String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
    public static String serverURL = baseUrl + serverURLContract + UserInfo.getOrganizationId();
    public static string buttonType = '';
    public static Boolean isSkipCDATriggers = settingObject.Is_Skip_CDA_Triggers__c;
    public static String privilegedBusinessAreas = settingObject.Privileged_Business_Areas__c;

    //Global/Static variables
    public static final string AUDITOR = 'Auditor';
    public static final string VENDOR = 'Vendor';
    public static final string CUSTOMER = 'Customer';
    public static final string CEVA = 'CEVA';
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String NONE = '--None--';
    public static final String RECORD = 'Record';
    public static final string IQVIA = 'IQVIA';   //Modified by Vikram Singh under CR-11577
    public static final string PROJECT = 'Project';
    public static final string QUALIFICATION = 'Qualification';
    public static final string SYS_ADMIN = 'System Admin';
    public static final string REQUESTOR = 'Requestor';
    public static final string REQUESTOR_PERMISSIONSET_LABEL = 'CDA Requestor Permission';
    public static final string NEGOTIATOR = 'Negotiator';
    public static final string CONGA_PERMISSION = 'TPA Conga Permission Set';
    public static final string REQUESTOR_ADMIN = 'Requestor Admin'; //Added by Vikram Singh under CR-11764
    public static final string REQUESTOR_EXTENDED = 'Requestor Extended'; //Added by Vikram Singh under CR-12108
    public static final string LOOKUP_REPORT_USER = 'CDA Lookup Report';
    public static final string CONTRACTINGCAPACITY_COLLABORATOR = 'Collaborator';
    public static final string CONTRACTINGCAPACITY_VENDOR = 'Vendor – Project / Study Specific';
    public static final string CONTRACTINGCAPACITY_VENDOR_CORPORATE = 'Vendor – Corporate / Enterprise';
    public static final string CONTRACTINGCAPACITY_CUSTOMER = 'Customer';
    public static final string STUDYSPONSORIDENTIFIED = 'Study Sponsor identified';
    public static final string CDASOURCE_EXTERNAL = 'External';
    public static final string CDASOURCE_QUINTILESIMS = 'IQVIA';    //Modified by Vikram Singh under CR-11577
    public static final string CDA_FORMAT_PDF = 'PDF';
    public static final string CDA_FORMAT_DOC = 'DOCX';
    public static final string CDA_FORMAT_PROWORD = 'Protected Word';
    public static final string CDA_DOC_COMMENT_FOR_APTTUS = 'Insert comments and tracked changes only';
    public static final string NEGO_NOT_ASSIGN = 'Not Assigned';
    public static final string REQUEST_TYPE_NEW = 'new';
    public static final string REQUEST_TYPE_EDIT = 'edit';
    public static final string MANAGEMENT_APPROVAL_DOCUMENT = 'Management Approval Document';
    public static final string CUSTOMER_CONSENT_TO_DISCLOSE = 'Customer Consent to Disclose';
    public static final string AUDIT_SCOPE_AGENDA = 'Audit Scope Agenda';
    public static final string EXTERNAL_DOCUMENT = 'External Document';
    public static final string GENERATED_DOCUMENT = 'Generated Document';
    public static final string SPONSOR_CONSENT_TO_DISCLOSE = 'Sponsor Consent to Disclose';
    public static final string RED_LINE_DOCUMENT = 'Red Line Document';
    public static final string AWAITING_OGC_APPROVAL = 'AwaitingOGC Approval Document';
    public static final Integer MAX_RECORDLIMIT = 5000;
    public static final string STATUS_INDRAFT = 'In Draft';                                                                         //1st Level of status
    public static final string STATUS_AWAITINGREQSUB = 'Awaiting Requestor Submission';                                             //1st Level of status
    public static final string STATUS_SENTFORSIGN = 'Sent for Recipient Signature';                                                           //2nd Level of status
    public static final string STATUS_AWAITINGEXTSIGN = 'Awaiting External Signature';                                              //2nd Level of status
    public static final string STATUS_AWAITINGINTERNALSIGN = 'Awaiting Internal signatures';                                        //2nd Level of status
    public static final string STATUS_INREVIEWBYQUINTILES = 'In Review by IQVIA';                                                   //2nd Level of status //Modified by Vikram Singh under CR-11577
    public static final string STATUS_SUBMITTEDFORPROCESSING = 'Submitted for Processing';                                          //2nd Level of status //Added by Vikram Singh under CR-11525
    public static final string STATUS_AWAITING_OGC_COMPETITOR_APPROVAL = 'Awaiting GLD Competitor Approval';                        //2nd Level of status
    public static final string STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE = 'Validating Recipient Provided Document';        //3rd Level of status
    public static final string STATUS_SENTFOR_RECIPREVIEW = 'Sent for Recipient Review';                                            //4th Level of status
    public static final string STATUS_RETURNED_TO_REQUESTOR = 'Returned to Requestor';                                              //4th Level of status  //Added by Ajinkya Pande under Item #162
    // public static final string STATUS_REQUIRES_MANUAL_VALIDATION = 'Requires Manual Validation';                                 //5th Level of status  //Updated by Vikram Singh under Item #254
    public static final string STATUS_CONTRACTEXECUTED = 'Contract Executed';                                                       //5th Level of status
    public static final string STATUS_SIGNATURE_REQUEST_DENIED = 'Signature Request Denied';                                        //5th Level of status
    public static final string STATUS_CANCELEDBYREQUESTOR = 'Cancelled';                                                            //6th Level of status
    public static final string STATUS_DISCLOSUREPERIODENDED ='Disclosure Period Ended';                                             //7th Level of status
    public static final string STATUS_ACQUIRING_INTERNAL_SIGNATURE = 'Acquiring Internal IQVIA Signature'; //Added by C.P.Pandey under Issue-11144
    public static final string STATUS_LANGUAGE_REVIEW = 'Language Review';
    public static final string RECIPIENT = 'RecipientPointOfContact';
    public static final string AUTH_SIGN = 'AuthorizedSigner';
    public static final string NEGO_ASSIGNED = 'Negotiator Assigned';
    public static final string LEGAL_POC = 'LegalPOC';
    public static final string SELF_SERVICE_ONLY = 'Self Service Only';
    public static final string CENTRALMAILBOX = 'NegotiatorCentralMailbox';
    public static final string EMAIL_EXTERNAL_PAPER_REVIEW = 'Email External Paper Review';
    public static final string EMAIL_INTERNAL_SIGNATURE_REQ = 'Email Internal Signature Req';
    public static final string EMAIL_OGC_COMPETITOR_REVW_REQ = 'Email OGC Competitor Revw Req';
    public static final string EMAIL_RECIPIENT_REVIEW_REQUEST = 'Email Recipient Review Request';
    public static final string EMAIL_REQ_EXCU8_AGGR_RECVD = 'Email Req Excu8 Aggr Recvd';
    public static final string EMAIL_RESPONSE_RECEIVED = 'Email Response Received';
    public static final string EMAIL_RECIPIENT_EXC8_CONFIRM = 'Email Recipient Exc8 Confirm';
    public static final string EMAIL_CANCEL_BY_REQUESTOR = 'Email Request Canceled';
    public static final string EMAIL_NEGOTIATOR_ASSIGNED = 'Email Negotiator Assigned'; //Added by Ajinkya Pande under Item #258
    public static final string EMAIL_RESPONSE_TO_REQUESTOR = 'Email Respond To Requestor'; //Added by Ajinkya Pande under Item #162
    public static final string EMAIL_RECIPIENT_REVIEW_REMINDER = 'Email Recipient Review Reminder'; //Added by Babita Dadarwal under CR-11169
    public static final string EMAIL_RECIPIENT_REVIEW_REMINDER_Auditor = 'Email Recipient Review Reminder Auditor'; //Added by Babita Dadarwal under CR-11433
    public static final string EMAIL_LEGAL_POC_ASSIGNMENT = 'Email Legal POC Assignment';
    public static final string EMAIL_LEGAL_POC_REMINDER = 'Email Legal POC Reminder';
    public static final string CDA_TEST_CONTACT = 'Test Contact Id';
    public static final string DATE_FORMAT_STRING = '(MM/DD/YYYY)';
    public static final string EMAIL = 'Email';
    public static final string UPLOADED_AUDIT_SCOPE_AGENDA_FILE = 'Uploaded Audit Scope Agenda File';
    public static final string UPLOADED_EXTERNAL_DOCUMENT_FILE = 'Uploaded External Document File';
    public static final string UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE = 'Uploaded Customer Consent to Disclose File';
    public static final string VENDOR_MUTUAL_CDA_TEMPLATE = 'Vendor Mutual CDA Template';
    public static final string CUSTOMER_MUTUAL_CDA_TEMPLATE = 'Customer Mutual CDA Template';
    public static final string AUDITOR_CDA_TEMPLATE = 'Auditor CDA Template';
    public static final string SIGNED_ON_PAPER = 'Signed-on-Paper';
    public static final string CDA_ORG_WIDE_EMAIL_ID = 'CDA Org Wide Email Id';
    public static final String DS_DECLINED = 'Declined';
    public static final String DS_VOIDED = 'Voided';
    public final static String DS_ENVELOPE_VOID_REASON_EXPIRED = 'Envelope has expired';
    public static final String CDA_KEYWORD = 'CDA';
    public static final string EXTERNAL_KEYWORD = 'External Paper'; // Added by Ajinkya Under Item #114
    public static final String RED_LINE_KEYWORD = 'Red Line';
    public static final String RED_LINE_KEYWORD_NEW = 'REDLINED'; // Added by Ajinkya Under Item #114
    public static final string CLEANED_DOC_KEYWORD = 'Cleaned';
    public static final string CLEANED_DOC_KEYWORD_NEW = 'CLEAN'; // Added by Ajinkya Under Item #114
    public static final string COMPLETED_KEYWORD = '_Completed';
    public static final string MANAGER_APPROVAL_DOC_KEYWORD = 'Manager Approval';
    public static final string GENERATED_DOCUMENT_KEYWORD = 'CDA Template';
    public static final string BUTTON_TYPE_SUBMIT = 'submit';
    public static final string BUTTON_TYPE_REVIEW = 'review';
    public static final string BUTTON_TYPE_LANGUAGE_REVIEW = 'languageReview';
    public static final string DEFAULT_DISCLOSURE_PERIOD = '5';
    public static final string REQUEST_ID_STR = 'id';
    public static final string REQUEST_TYPE_STR = 'reqType';
    public static final string QATESTING_STR = 'qatesting'; //Added by Vikram Singh under CR-11526
    public static final string PAGE_LANDING_SCREEN = '/apex/VFP_CDA_CustomLandingPage';
    public static final string PAGE_VIEW_SCREEN = '/apex/VFP_CDA_RequestViewScreen';
    public static final string PAGE_EDIT_SCREEN = '/apex/VFP_CDA_RequestEditScreen';
    public static final string SP_CHAR_QUESTION = '?';
    public static final string SP_CHAR_AMPERSAND = '&';
    public static final string SP_CHAR_EQUAL = '=';
    public static final string SP_CHAR_SLASH = '/';
    public static final string SP_CHAR_BACKSLASH = '\'';
    public static final string SP_CHAR_PERCENTAGE = '%';
    public static final string SP_CHAR_TILDE = '~';
    public static final string SP_CHAR_COMMA = ',';
    public static final string SP_CHAR_NEWLINE = '\n';
    public static final string QRY_SELECT = 'SELECT';
    public static final string QRY_FROM = 'FROM';
    public static final string QRY_WHERE = 'WHERE';
    public static final string QRY_LIKE = 'LIKE';
    public static final string QRY_IN = 'IN';
    public static final string QRY_ORDER_BY = 'ORDER BY';
    public static final string QRY_ASC = 'ASC';
    public static final string QRY_DSC = 'DSC';
    public static final string QRY_AND = 'AND';
    public static final string QRY_OR = 'OR';
    public static final string EXTENTION_DOC = '.doc';
    public static final string EXTENTION_DOCX = '.docx';
    public static final string EXTENTION_PDF = '.pdf';
    public static final string CDA_PROCESS = 'CDA Process';
    public static final string LEGAL_ENTITY_QI = 'qiLegalEntity';
    public static final string GOVERNING_LAW = 'governingLaw';   //Added by Vikram Singh under CR-11576
    public static final string NOOVERRIDE = 'nooverride=1';   //Added by Vikram Singh under CR-11691

    // Added by Babita Dadarwal under Item #27 Start
    public final static String CDA_REQUEST_TYPE = 'CDA Type';
    public final static String CDA_REQUEST_NUMBER = 'CDA #';
    public final static String CDA_ACCOUNT_NAME = 'Account Name';
    public final static String CDA_ACCOUNT_ADDRESS = 'Account Address';
    public final static String CDA_ACCOUNT_SOURCE = 'CDA Process';
    // Added by Babita Dadarwal under Item #27 End

    //Added by Vikram Singh under CR-11146 Start
    public final static String CDA_RESPONSE_DOCTYPE_REDLINED = 'Word Redlined Only';
    public final static String CDA_RESPONSE_DOCTYPE_CLEANED = 'Word Cleaned Version Only';
    public final static String CDA_RESPONSE_DOCTYPE_REDLINED_AND_CLEANED = 'Word Redlined and Clean versions';
    //Added by Vikram Singh under CR-11146 End

    //Added by Vikram Singh under CR-11188 Start //Updated by Vikram Singh under CR-11376 Start
    public final static String CDA_BUSINESS_PART_LI = Label.CDA_Technology_Analytics_Solutions_TAS_Legacy_IMS;    //Updated by Vikram Singh under CR-12057, CR-12103
    public final static String CDA_BUSINESS_PART_LQ = Label.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles;
    public final static String CDA_BUSINESS_PART_CSMS = Label.CDA_Contract_Sales_Medical_Solutions_CSMS_Legacy_IES;
    public final static String CDA_BUSINESS_PART_QS = Label.CDA_Q_Squared;
    // public final static String CDA_BUSINESS_PART_BOTH = 'IQVIA IES (Integrated Engagement Services)';   //Commented by Vikram Singh under CR-12057
    //Added by Vikram Singh under CR-11188 End //Updated by Vikram Singh under CR-11376 End

    public final static String CDA_PARTIALLY_EXECUTED_DOC_KEYWORD = 'Partially Executed CDA Document'; // Added by Babita Dadarwal under CR-11458

    public static Boolean isBatchProcessing = false;

    public static Contact cntObj;
    public static string GUID {
        get {
            if(GuidPrvt == null) {
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                GuidPrvt = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            }
            return GuidPrvt;
        }
        set{ GuidPrvt = value; }
    }
    
    // Property to get Org Company Information
    public static Organization orgCompanyInformation {
        get{
            if(orgCompanyInformation == null) {
                orgCompanyInformation = [SELECT ID, IsSandbox FROM Organization LIMIT 1];
            }
            return orgCompanyInformation;
        }
        set;
    }
    
    // Property to check if current org is a Sandbox org or not
    public static Boolean isSandboxOrg {
        get{
            return orgCompanyInformation.IsSandbox;
        }
        set;
    }

    // private variables
    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:partner.soap.sforce.com';
    private static LogBase.ICustomLogBase logRefPrvt{get;set;}
    private static string GuidPrvt;

    // Constructor
    public UTL_CDAUtility() {}

    public static SRV_CDA_Logs logRef() {
        if(logRefPrvt == null)
            logRefPrvt = (new LogBase.LogFactory()).Instance('SRV_CDA_Logs');
        return (SRV_CDA_Logs)logRefPrvt;
    }

    public static void setLogObject(string reqId, string logDetail, string otherDetail) {
        if(logRef().logToInsert().Log_Type__c == null)
            logRef().logToInsert().Log_Type__c = 'Custom';
        logRef().logToInsert().GUID__c = GUID;
        logRef().logToInsert().Record_Id__c = reqId;
        logRef().logToInsert().Log_Detail__c = logDetail;
        logRef().logToInsert().Other_Details__c = otherDetail;
    }

    /**
     * This map is used to get all types of template i.e., email, docusign and apptus
     * Key of this map is label + language of the templates
     */
    public static map<String, CDA_Multilingual_Template_List_Settings__c> multiLingualTemplateSettingsMap {
        get {
            // When the map is called for the first time then all template is in custom setting which be stored in this map.
            if(multiLingualTemplateSettingsMap == null) {
                multiLingualTemplateSettingsMap = new map<String, CDA_Multilingual_Template_List_Settings__c>();
                //for(CDA_Multilingual_Template_List_Settings__c templateObj : [SELECT Label__c, Language__c, Template_Id__c, Template_Name__c FROM CDA_Multilingual_Template_Settings__mdt]) {
                for(CDA_Multilingual_Template_List_Settings__c templateObj : CDA_Multilingual_Template_List_Settings__c.getAll().values()) {
                   multiLingualTemplateSettingsMap.put(templateObj.Label__c + (templateObj.Language__c == null ? '' : templateObj.Language__c) , templateObj);
                }
            }
            return multiLingualTemplateSettingsMap;
        }
        private set{multiLingualTemplateSettingsMap = value;}
    }

    /**
     * Added by Vikram Singh under Item #256
     * This map is used to get all available display text wrt governing law value
     * Key of this map is value
     */
    public static map<String, CDA_Governing_Law_Name_and_PrintName__mdt> governingLawNameAndPrintNameMap {
        get {
            // When the map is called for the first time then all template is in custom setting which be stored in this map.
            if(governingLawNameAndPrintNameMap == null) {
                governingLawNameAndPrintNameMap = new map<String, CDA_Governing_Law_Name_and_PrintName__mdt>();
                for(CDA_Governing_Law_Name_and_PrintName__mdt templateObj : [SELECT MasterLabel, Value__c, Display_Text__c FROM CDA_Governing_Law_Name_and_PrintName__mdt]) {
                   governingLawNameAndPrintNameMap.put(templateObj.Value__c, templateObj);
                }
            }
            return governingLawNameAndPrintNameMap;
        }
        private set{governingLawNameAndPrintNameMap = value;}
    }

    /**
     * Added by Vikram Singh under CR-11525
     * This is set of User Ids those are having Apttus license assigned.
     * @type {[type]}
     */
    public static Set<String> setOfUserIdsHavingApttusLicense {
        get {
            if(setOfUserIdsHavingApttusLicense == null) {
                setOfUserIdsHavingApttusLicense = new Set<String>();
                for(UserPackageLicense upl : [SELECT UserId FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix = 'Apttus']) {
                    if(upl != null) {
                        setOfUserIdsHavingApttusLicense.add(upl.UserId);
                    }
                }
            }
            return setOfUserIdsHavingApttusLicense;
        }
        private set {setOfUserIdsHavingApttusLicense = value;}
    }

    /**
     * This method will fetch templateId from the map as templateName+language as key.
     */
    public static Id getTemplateId(string templateName, string language) {
        system.debug('####UTL_CDAUtility.getTemplateId multiLingualTemplateSettingsMap: '+multiLingualTemplateSettingsMap);
        system.debug('####UTL_CDAUtility.getTemplateId templateName: '+templateName+', language: '+language);
        Id templateId;
        String tempLanguage = language == 'English' ? language : 'NonEnglish';
        if(templateName != null && language != null) {
            if(multiLingualTemplateSettingsMap.get(templateName+tempLanguage) != null) {
                templateId = multiLingualTemplateSettingsMap.get(templateName+tempLanguage).Template_Id__c; 
            } else if(multiLingualTemplateSettingsMap.get(templateName+'English') != null) {
                templateId = multiLingualTemplateSettingsMap.get(templateName+'English').Template_Id__c;
            }
        }
        return templateId;
    }


    public static void sendNotificationEmail(List<Messaging.SingleEmailMessage> emailsToSend) {
        system.debug('####UTL_CDAUtility.sendNotificationEmail emailsToSend: '+emailsToSend);
        system.debug('####UTL_CDAUtility.sendNotificationEmail emailsToSend size: '+emailsToSend.size());
        List<String> workflowEmail = new List<String>{'Email OGC Competitor Revw Req', 'Email External Paper Review', 'Email Respond To Requestor', 'Email Negotiator Assigned', 'Email Response Received', 'Email Request Canceled', 'Email Internal Signature Req'};
        Set<Id> workflowEmailIdSet = new Set<Id>();
        for(String s: workflowEmail){
            workflowEmailIdSet.add(getTemplateId(s, 'English'));
        }
        
        List<Messaging.SingleEmailMessage> emailWithoutWorkflow = new List<Messaging.SingleEmailMessage>();
        
        try {
            if(emailsToSend != null && emailsToSend.size() > 0) {
                for(Messaging.SingleEmailMessage email: emailsToSend){
                    if(workflowEmailIdSet.contains(email.getTemplateId())){
                        sendEmailThroughWorkflow(email);
                    }else{
                        emailWithoutWorkflow.add(email);
                    }
                }
                if(!emailWithoutWorkflow.isEmpty() && !Test.isRunningTest()){
                    Messaging.sendEmail(emailWithoutWorkflow);
                }
            }
        } catch(Exception ex) {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject('', 'Exception Occurred in UTL_CDAUtility : '+ ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
        }
    }

    /**
     *  Method will return the logged in user details.
     */
    public static User getUserDetails() {
        User presentUser = new User();
        if(presentUser != Null ) {
            presentUser = [select Id,
                                  Name,
                                  Email,
                                  Profile.Name,
                                  (SELECT AssigneeId, PermissionSet.Label
                                   FROM PermissionSetAssignments
                                   WHERE PermissionSet.IsOwnedByProfile = false)
                           from User
                           where Id =: UserInfo.getUserId()] ;
        }
        return presentUser;
    }

    /**
     *   accepts username and password and returns the session
     */
    public static String login(String user, String password)
    {
        try
        {
           HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setTimeout(60000);
            req.setEndpoint(serverURL);
            req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            req.setHeader('SOAPAction', '""');
            req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +user+ '</username><password>' + password + '</password></login></Body></Envelope>');
            HttpResponse res =  new Http().send(req);
            if(res.getStatusCode() != 200)
            {
                Dom.Document responseDocument = res.getBodyDocument();
                Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
                Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body
                Dom.Xmlnode faultElm = bodyElm.getChildElement('Fault', NS_SOAP); // soapenv:Fault
                Dom.Xmlnode faultStringElm = faultElm.getChildElement('faultstring', null); // faultstring
            //    throw new LoginException(faultStringElm.getText());
            }
            Dom.Document responseDocument = res.getBodyDocument();
            Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
            Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body
            Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF); // loginResponse
            Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF); // result
            Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF); // sessionId
            Dom.Xmlnode serverUrlElm = resultElm.getChildElement('serverUrl', NS_SF); // serverUrl
            // UTL_CDAUtility.serverUrl = serverUrlElm.getText();
            return sessionIdElm.getText();
        }
        catch(Exception ex)
        {
            UTL_CDAUtility.logRef().logToInsert().Log_Type__c = 'Exception';
            UTL_CDAUtility.setLogObject('', 'Exception Occurred in UTL_CDAUtility : '+ ex.getMessage(), 'Line :' + ex.getLineNumber() + ' Cause :' + ex.getCause());
            UTL_CDAUtility.logRef().generateLog();
            return null;
        }
    }

    /**
     *   accepts indivsidual object name and its reference field name in objectName and returns soql friendly string for relationship fields e.g. QI_Legal_Entity_Name__r.Name
     *   e.g. individual object name:'QI_Legal_Entity__c',
     *        reference field name in CDA_Request__c: 'QI_Legal_Entity_Name__c'
     */
    public static String getRelationObjectFieldStr(String objectName, String referenceFieldName){
        String relationObj = referenceFieldName.replace('__c', '__r');
        List<String> relationFieldList = new List<String>();
        for(String f : getObjectFields(objectName)){
            relationFieldList.add(relationObj+'.'+f);
        }
        return String.join(relationFieldList, ',');
    }

    /**
     *   it converts list of all fields of given objectName into a soql friendly string
     */
    public static String getObjectFieldStr(String objectName){
        return String.join(getObjectFields(objectName), ',');
    }

    /**
     *   it returns list of all fields of given objectName
     */
    public static List<String> getObjectFields(String objectName){
        //Map<String, Schema.SObjectField> fieldToApiMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{objectName});        
        Map<String, Schema.SObjectField> fieldToApiMap = descResult[0].fields.getMap();
        return new List<String>(fieldToApiMap.keySet());
    }

    //Added By Ajinkya Pande under Item #114 Start
    /**
     *   It return the dynamic naming conventions for attachment attach to cda request.
     */
    public static string getDocumentName(CDA_Request__c cdaRequest, String docType) {
        String nameOfDoc;
        if(cdaRequest != null) {
            // Modified by C.P.Pandey under CR-11153 start
            string recipientAccountName = '';
            if(cdaRequest.Recipient_Account_Name_Formula__c != null && cdaRequest.Recipient_Account_Name_Formula__c.length() > 0) {
                recipientAccountName = cdaRequest.Recipient_Account_Name_Formula__c.replaceAll('[^ &@+\\-_/()a-zA-Z0-9]+','');
                if(recipientAccountName.length() > 80){
                    recipientAccountName = recipientAccountName.substring(0, 80);
                }
            }
            nameOfDoc = cdaRequest.CDA_Type__c + '_' + cdaRequest.get('CDA_Id__c') + '_' + recipientAccountName;
            // Modified by C.P.Pandey under CR-11153 end
            if(docType == UTL_CDAUtility.CDASOURCE_EXTERNAL) {
                nameOfDoc += '_' + UTL_CDAUtility.EXTERNAL_KEYWORD;
            }
            if(docType == UTL_CDAUtility.CDASOURCE_QUINTILESIMS || docType == UTL_CDAUtility.CDA_PARTIALLY_EXECUTED_DOC_KEYWORD) { // Updated By Babita Dadarwal under CR-11458
                nameOfDoc += '_' + UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD;
            }
            if(cdaRequest.CDA_Format__c != null) {
                nameOfDoc += '_' + cdaRequest.CDA_Format__c;
            }
            if(docType == UTL_CDAUtility.COMPLETED_KEYWORD) {
                nameOfDoc += UTL_CDAUtility.COMPLETED_KEYWORD + UTL_CDAUtility.EXTENTION_PDF;
            } else if(docType == UTL_CDAUtility.CLEANED_DOC_KEYWORD) {
                nameOfDoc += '_' + UTL_CDAUtility.CLEANED_DOC_KEYWORD_NEW;
            } else if(docType == UTL_CDAUtility.RED_LINE_KEYWORD) {
                nameOfDoc += '_' + UTL_CDAUtility.RED_LINE_KEYWORD_NEW;
            }else if(docType == UTL_CDAUtility.MANAGER_APPROVAL_DOC_KEYWORD){
                nameOfDoc += '_' + UTL_CDAUtility.MANAGER_APPROVAL_DOC_KEYWORD;
            }
            if(EXT_CDA_RequestViewController.isGenerateDocAgreementBtnHit){
                nameOfDoc += UTL_CDAUtility.EXTENTION_DOCX;
            }else if((cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_DOC || cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PROWORD) && docType == UTL_CDAUtility.CDASOURCE_QUINTILESIMS ) {
                nameOfDoc += UTL_CDAUtility.EXTENTION_DOCX;
            } else if(cdaRequest.CDA_Format__c == UTL_CDAUtility.CDA_FORMAT_PDF && docType == UTL_CDAUtility.CDASOURCE_QUINTILESIMS) {
                nameOfDoc += UTL_CDAUtility.EXTENTION_PDF;
            }
        }
        return nameOfDoc;
    }
    //Added By Ajinkya Pande under Item #114 End

    /**
     * It returns the available additional contacts under any CDA based on it's Id.
     */
    public static List<cdaAdditionalContactWrapper> getAdditionalContactsDetails (Id cdaRequestId) {
        List<cdaAdditionalContactWrapper> contactDetailsList = new List<cdaAdditionalContactWrapper>();
        CDA_Request__c cdaRequest = SRV_CDA_CDARequest.getCDARequest(cdaRequestId);
        if (cdaRequest != null && cdaRequest.Additional_Contact_Flag__c == 'Yes' && cdaRequest.Additional_Contact_Details__c != null) {
            List<String> contactRecords = cdaRequest.Additional_Contact_Details__c.split(';');
            for(String cr : contactRecords) {
                system.debug('#### contactRecord cr: '+cr);
                cdaAdditionalContactWrapper contactDetailWrapper = new cdaAdditionalContactWrapper();
                List<String> splittedStr = cr.split(',');
                contactDetailWrapper.acFirstName = splittedStr.get(0);
                contactDetailWrapper.acLastName = splittedStr.get(1);
                contactDetailWrapper.acEmail = splittedStr.get(2);
                contactDetailsList.add(contactDetailWrapper);
            }
        } 
        system.debug('####EXT_CDA_RequestViewController contactDetailsList: '+contactDetailsList);
        return contactDetailsList;
    }

     /**
     * Name : cdaAdditionalContactWrapper
     * This wrapper class is used to store all newly inserted Additional IQVIA contacts with CDA request information.
     */
    public class cdaAdditionalContactWrapper {
        @AuraEnabled
        public string acFirstName {get; set;}
        @AuraEnabled
        public string acLastName {get; set;}
        @AuraEnabled
        public string acEmail {get; set;}
    }
    
    public static void sendEmailThroughWorkflow(Messaging.SingleEmailMessage email) {
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = email;
        
        Workflow_Email_Record__c objWorkFlowEmail = new Workflow_Email_Record__c();
        
        Savepoint sp = Database.setSavepoint();
        try {
            if(UTL_CDAUtility.isSendOutgoingEmails) {
                Messaging.SendEmail(New Messaging.SingleEmailMessage[] {emailNotToSend});
            }
        } catch(Exception exp) {
            System.debug(' Email Failed: ' + exp.getMessage());
        }
        Database.rollback(sp);
        objWorkFlowEmail.content_1__c = emailNotToSend.getHTMLBody();
        objWorkFlowEmail.Email_Subject__c = emailNotToSend.getSubject();
        
        objWorkFlowEmail.isAttachmentRequired__c = false;
        string strWhatId = email.getWhatId();
        if(strWhatId != null && strWhatId != '') {
            objWorkFlowEmail.Related_To_Object_Id__c = strWhatId;
            Id objId = strWhatId;
            objWorkFlowEmail.Related_To_Object_Api__c = objId.getSObjectType().getDescribe().getName();
        }
        objWorkFlowEmail.Module_Name__c = 'CDA';
        objWorkFlowEmail.Email_Action__c = 'CDA_01_SendEmail';
        Integer toEmailCounter = 1;
        if(email.getToAddresses() != null && email.getToAddresses().size() > 0) {
            for(string strToEmail: email.getToAddresses()) {
                objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', strToEmail);
                toEmailCounter++;
            }
        }
        if(email.getCcAddresses() != null && email.getCcAddresses().size() > 0) {
            for(string strCcEmail: email.getCcAddresses()) {
                objWorkFlowEmail.put('To_Email_'+toEmailCounter+'__c', strCcEmail);
                toEmailCounter++;
            }
        }
        if(Test.isRunningTest()) {
            objWorkFlowEmail.content_1__c = 'TEST Content';
            objWorkFlowEmail.Email_Subject__c = 'TEST Subject';
        }
        system.debug('objWorkFlowEmail:::'+objWorkFlowEmail);
        if(UTL_CDAUtility.isSendOutgoingEmails) {
            try{
                insert objWorkFlowEmail;
            }
            catch(Exception ex) {
                //UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'CDA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::SRV_TPA_TPARequest:::sendEmailThroughWorkflow:::objWorkFlowEmail Insert Exception', email.getWhatId()));
                //UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                system.debug('workFlowException:::'+ex.getMessage());
            }
        }
    }
}
