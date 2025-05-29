/**
 *@Author  : Supriya Johhari
 *@Purpose : 1. Apex class CNT_TPA_AMAOffshoreTemplate Created under ER-3947 for Revised Offshore Process.     
 */
global class CNT_TPA_AMAOffshoreTemplate {    
    
    // public static List<AMA_Agreement_Detail__c> amaAgreementDetailValues{get; set;}
    // public static String amaAgreementID{get; set;}
    // public boolean isMessageShow { get; set; }
    // public boolean isTPAPermanentDown { get; set; }
    // public String title { get; set; }
    // public String Message { get; set; }
    // public boolean isRestrictedUser { get; set; }
    // //public boolean TPA_Is_Show_TPA_Down_Message {get;set;}
    // private static User CurrentUser = UTL_TPA_Multilingual.CurrentUser;
    // public static string isQaTesting {get; set;}

    // public static AMA_Agreement_Detail__c amaAgreementDetailObj {
    //     get{
    //         if(amaAgreementDetailObj == null){
    //             if(!Test.isRunningTest()) {
    //                 amaAgreementID = ApexPages.currentPage().getParameters().get('id');
    //             }
    //             if(amaAgreementID != null) {
                
    //                 amaAgreementID = UTL_TPA_AMA.getValidStringOnlyWordChar(amaAgreementID);
    //                 Set<String> fieldSet = new Set<String>{'TPA_Request__r.Agreement_Name__c', 'TPA_Request__r.Vendor_Contact_Name_f__c', 'TPA_Request__r.Vendor_Contact_Last_Name__c',
    //                                                        'TPA_Request__r.Vendor_Company_Name__c', 'TPA_Request__r.TP_Processor_Email__c', 'TPA_Request__r.Vendor_Contact_e_mail__c', 'Ex_US_Legal_Entity_Name__c',
    //                                                        'TPA_Request__r.Vendor_Contact_Email_Client__c', 'TPA_Request__r.Name'};
    //                 amaAgreementDetailValues = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{amaAgreementID}, fieldSet);
                    
    //                 if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty()) {
    //                     amaAgreementDetailObj = amaAgreementDetailValues.get(0);
    //                 }
    //             }
    //         }
    //         return amaAgreementDetailObj;
    //     }
    //     set;
    // }
    
    // public String amaAgreementDetailAsString {
    //     get{
    //         String jsonStr = JSON.serialize(amaAgreementDetailObj);
    //         jsonStr = jsonStr.replace('\\', '\\\\');
    //         return jsonStr;
    //     }
    //     set;
    // }
    // public String getPrintView() {
    
    //     return
    //     '<!--[if gte mso 9]>' +
    //         '<xml>' +
    //         '<w:WordDocument>' +
    //         '<w:View>Print</w:View>' +
    //         '<w:Zoom>125</w:Zoom>' +
    //         '<w:DoNotOptimizeForBrowser/>' +
    //         '</w:WordDocument>' +
    //         '</xml>' +
    //         '<![endif]>' + 
    //         '<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />' + 
    //         '<style>' + 
    //         'p.MsoHeader, li.MsoHeader, div.MsoHeader{margin:0in;margin-top:.0001pt;margin-left:0.8in;mso-pagination:widow-orphan;tab-stops:center 3.0in right 6.0in;}' + 
    //         'p.MsoFooter, li.MsoFooter, div.MsoFooter{margin:0in;margin-bottom:.0001pt;margin-left:-0.45in;mso-pagination:widow-orphan;tab-stops:center 3.0in right 6.0in;}' + 
    //         '@page main{mso-header:h1;mso-footer:f1;}' + 
    //         'div.main{page:main;}' + 
    //         'table#hrdftrtbl{margin:0in 0in 0in 9in;}' + 
    //         '</style>';
            
    // }
    
    // public String getWordStyle() {
    
    //     return '<style>.useDefStyle p {margin:0.0in;} .useDefStyle ol ol li p {margin:0.04in 0.0in 0.1in 0.0in;}</style>';
    // }
    
    
    public CNT_TPA_AMAOffshoreTemplate() {
        // isMessageShow = UTL_TPA.isMessageShow;
        // isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
        
        // title = Label.TPA_Custom_Landing_Page_Title;
        // Message = Label.TPA_Downtime_Message;
        
        // //TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
        
        // String restrictedUserIds = Label.TPA_Non_Restricted_Users;
        // String currentUserId = String.valueOf(CurrentUser.Id).subString( 0, 15 );
        // system.debug('restrictedUserIds:::'+restrictedUserIds.contains( currentUserId ));
        // if( restrictedUserIds.contains( currentUserId )){
        //     isRestrictedUser = false; 
        // }
        // else if(isTPAPermanentDown){
        //     isRestrictedUser = true;
        // }
        // isQaTesting = ApexPages.currentPage().getParameters().get('isQaTesting');
        // if(isTPAPermanentDown == true && isQaTesting == 'true'){
        //     isTPAPermanentDown=false;
            
        // }
        // else if (isTPAPermanentDown == true){
        //     isMessageShow = UTL_TPA.isMessageShow;
        //     isTPAPermanentDown =  UTL_TPA.isTPAPermanentDown;
            
        //     title = Label.TPA_Custom_Landing_Page_Title;
        //     Message = Label.TPA_Downtime_Message;
        //     //TPA_Is_Show_TPA_Down_Message = CurrentUser.TPA_Is_Show_TPA_Down_Message__c;
        // }
    }
    
    // public string getTechnologyToAccessAMAPPDList() {
    
    //     List<String> technologyToAccessAMAPPDList = new List<String>();
    //     Schema.DescribeFieldResult fieldResult = AMA_Agreement_Detail__c.Technologies_to_access_AMA_PPD_by_vendor__c.getDescribe();
    //     List<Schema.PicklistEntry> pleForVendorCancelationReason = fieldResult.getPicklistValues();
    //     for(Schema.PicklistEntry f : pleForVendorCancelationReason){
    //         technologyToAccessAMAPPDList.add(f.getValue());
    //     }  
    //     return JSON.serialize(technologyToAccessAMAPPDList);
    // }
    
    // @remoteAction       
    // public static Boolean tpUsReqSendQuesTOVendor(String amaAgreementObjID) {      
        
    //     AMA_Agreement_Detail__c obj = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(false, new Set<Id>{amaAgreementObjID}, new Set<String>{'Id'}).get(0);
                                
    //     obj.Status_of_Offshore_Process__c = UTL_TPA.AWAITING_VENDOR_RESPONSE_FOR_OFFSHORE_PROCESS;
    //     try {       
    //         update obj;     
                    
    //         SendNotificationWithOffshoreLink(obj);      
    //         return true;        
                        
    //     } catch (Exception e) {      
    //         system.debug(e.getMessage());
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreTemplate:::tpUsReqSendQuesTOVendor', obj.Id != null ? obj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return false;       
    //     }       
                
    // }       
    
    
    // @remoteAction
    // public static String saveOffshoreformforVendor(String amaAgreementObj) {
        
    //     amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
        
    //     Set<String> fieldSet = new Set<String>{'Status_of_Offshore_Process__c', 'Technologies_to_access_AMA_PPD_by_vendor__c', 'Date_vendor_responded_for_offshore__c'};
    //     AMA_Agreement_Detail__c obj = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{amaAgreementDetailObj.id}, fieldSet).get(0);
        
    //     try {
        
    //         if(obj.Status_of_Offshore_Process__c != UTL_TPA.AWAITING_VENDOR_RESPONSE_FOR_OFFSHORE_PROCESS) {
    //             return 'alreadySubmittedResponse';
    //         }
    //         else {
    //             Boolean isvalidOffshoreCountry = true;
    //             Boolean isOnlyUS = false;
    //             if(obj.Vendor_employee_access_data_in_country__c != null){
    //                 if(obj.Vendor_employee_access_data_in_country__c.equalsIgnoreCase('united states')){
    //                     isOnlyUS = true;
    //                 }
    //                 if(!isOnlyUS){
    //                     for(String country: obj.Vendor_employee_access_data_in_country__c.split(',')){
    //                         if(!UTL_TPA.offshoreCountries.contains(country.trim().toLowerCase())){
    //                             isvalidOffshoreCountry = false;
    //                         }
    //                     }
    //                 }
    //             }
    //             if(amaAgreementDetailObj.Technologies_to_access_AMA_PPD_by_vendor__c.containsIgnoreCase('Other') || !isvalidOffshoreCountry) {
    //                 amaAgreementDetailObj.Status_of_Offshore_Process__c = UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS;
    //             } else {
    //                 amaAgreementDetailObj.Status_of_Offshore_Process__c = UTL_TPA.VENDOR_COMPLETED_AMA_OFFSHORE_PROCESS;
    //             }
    //             amaAgreementDetailObj.Date_vendor_responded_for_offshore__c = system.Today();
    //             update amaAgreementDetailObj;
    //         }   
            
    //     } catch (Exception e) {
    //         system.debug(e.getMessage());
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreTemplate:::saveOffshoreformforVendor', obj.Id != null ? obj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return 'error';
    //     }
        
    //     if(amaAgreementDetailObj.Status_of_Offshore_Process__c == UTL_TPA.VENDOR_COMPLETED_AMA_OFFSHORE_PROCESS) {
    //         sendCompletionOffshoreNotification(amaAgreementDetailObj);
    //     } else if(amaAgreementDetailObj.Status_of_Offshore_Process__c == UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS) {
    //         sendOffshoreNotificationToDBL(amaAgreementDetailObj);
    //     }
    //     return 'success';
    // }
    
    
    // @remoteAction
    // public static String saveAMAResponseForOffshore(String amaResponse, String amaAgreementObj) {
    //     amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
    //     AMA_Agreement_Detail__c obj = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{amaAgreementDetailObj.id}, new Set<String>{'Status_of_Offshore_Process__c', 'TPA_Request__r.Agreement_Name__c'}).get(0);
    //     try {
        
    //         if(obj.Status_of_Offshore_Process__c  != UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS) {
    //             return 'alreadySubmittedResponse';
    //         }
    //         else {
    //             if(amaResponse == 'request approved') {
    //                 obj.Status_of_Offshore_Process__c  = UTL_TPA.AMA_APPROVED_OFFSHORE_PROCESS;
    //                 obj.AMA_Response__c = UTL_TPA.AMA_RESPONSE_APPROVED;
    //             }
    //             else if(amaResponse == 'Additional questions for Vendor') {
    //                 obj.Status_of_Offshore_Process__c  = UTL_TPA.AMA_ADDITIONAL_QUESTIONS_FOR_OFFSHORE_PROCESS;
    //                 obj.Questions_for_Vendor_Response__c  = amaAgreementDetailObj.Questions_for_Vendor_Response__c;
    //                 obj.AMA_Response__c = UTL_TPA.AMA_RESPONSE_ADDITIONAL_QUESTIONS;
    //             }
    //             else if(amaResponse == 'not approved') {
    //                 obj.Status_of_Offshore_Process__c  = UTL_TPA.AMA_DENIED_OFFSHORE_PROCESS;
    //                 obj.AMA_reasons_why_offshore_not_approved__c  = amaAgreementDetailObj.AMA_reasons_why_offshore_not_approved__c;
    //                 obj.AMA_Response__c = UTL_TPA.AMA_RESPONSE_NOT_APPROVED;
    //             }
    //             obj.Date_of_AMA_Response_for_Offshore__c = Date.today();                 
    //         }
    //         update obj;
                
    //     } catch (Exception e) {
    //         system.debug(e.getMessage());
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreTemplate:::saveAMAResponseForOffshore', obj.Id != null ? obj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return 'error';
    //     }

    //     sendCompletionOffshoreNotification(obj);
    //     generateDocument(obj.id, obj.TPA_Request__r.Agreement_Name__c);       
    //     return 'success';
    // }
    
    // public static void sendCompletionOffshoreNotification(AMA_Agreement_Detail__c amaAgrObj) {
    
    //     //Set list of people who should be CC'ed
    //     List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
    //     String templateId = amaSetting.get(0).Revised_Offshore_Noti_To_TPUS_TemplateID__c  ;
        
    //     TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults(); 
        
    //     //Create a master list to hold the emails we'll send
    //     List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
    //     //Create a new Email
    //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
    //     //Set email contents - you can use variables!
    //     //mail.setTargetObjectId(amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c);
    //     List<String> toAddress = new List<String>();
    //     List<String> ccTo = new List<String>();
        
    //     if(amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c != null && amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c != '') {
    //         toAddress = amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c.split(';');
    //     }

    //     if(amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c != null && amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c != '') {
    //         ccTo = amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c .split(';');
    //         mail.setCCAddresses(ccTo);
    //     }

        
        
    //     if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
    //        List<String> bccTo = new List<String>();
    //        bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
    //        mail.setBccAddresses(bccTo);
    //     }
        
    //     mail.setWhatId(amaAgrObj.id);
    //     mail.setTemplateId(templateId); 
    //     mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
    //     mail.setSaveAsActivity(true);
        
    //     mails.add(mail);
              
    //     try {
    //         if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
    //             //Messaging.sendEmail(mails);
    //             //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '');
    //         }
    //     } catch(Exception e) {
    //         System.debug('Offshore Notification sent to TP-US after completion failed: : ' + e.getMessage());
    //     } 
    // }
    
    
    // public static void sendOffshoreNotificationToDBL(AMA_Agreement_Detail__c amaAgrObj) {
          
    //     Date todayDate;
    //     todayDate = Date.today(); 
    //     //Set list of people who should be CC'ed
    //     List<TPA_AMA_Settings__c> amaSetting =  TPA_AMA_Settings__c.getall().values();
    //     TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();                
    //     String templateId = amaSetting.get(0).Offshore_Link_For_DBL_Template_ID__c;
    //     String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; //dblcontracts@ama-assn.org
        
    //     //Create a master list to hold the emails we'll send
    //     List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
    //     //Create a new Email
    //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //     List<String> toAddress = new List<String>();
    //     List<String> ccTo = new List<String>();
        
    //     if(amaSetting.get(0).Dev_Mail_ID_For_Internal_Mails__c != Null && amaSetting.get(0).Dev_Mail_ID_For_Internal_Mails__c != '') {
    //         toAddress = amaSetting.get(0).Dev_Mail_ID_For_Internal_Mails__c.split(';');
    //         mail.setToAddresses(toAddress);
    //     }
        
    //     if(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c != Null && amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c != '') {
    //         ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
    //         mail.setCCAddresses(ccTo);
    //     }
        
    //     /*if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
    //        List<String> bccTo = new List<String>();
    //        bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
    //        mail.setBccAddresses(bccTo);
    //     }*/
        
    //     //Set email contents - you can use variables!
    //     mail.setTargetObjectId(dblContractsContactId);
    //     mail.setWhatId(amaAgrObj.id);
    //     mail.setTemplateId(templateId); 
    //     mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
    //     mail.setSaveAsActivity(true);
        
    //     if(String.isNotBlank(amaAgrObj.Client__c) &&
    //         String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
    //             (amaAgrObj.Client__c.startsWithIgnoreCase('Test') || amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))) {
            
    //         mail.setTreatTargetObjectAsRecipient(false);
    //     }
        
    //     //Add email to the master list
    //     mails.add(mail);
                    
    //     try {
    //         if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
    //             //Send all emails in the master list
    //             //Messaging.sendEmail(mails);
    //             //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '');
    //             amaAgrObj.Last_AMA_offshore_reminder_mail_sent__c = todayDate;
    //             update amaAgrObj;
                
    //         }
    //     } catch(Exception e) {
    //         System.debug('Offshore Notification sent to DBL failed: ' + e.getMessage());
    //     } 
    // }
    
    // public static void sendOffshoreAMAResponseToDBL(AMA_Agreement_Detail__c amaAgrObj) { 
         
    //     Date todayDate;
    //     todayDate = Date.today(); 
    //     //Set list of people who should be CC'ed
    //     List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
    //     TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();                
    //     String templateId = amaSetting.get(0).Email_Noti_AMA_Submitted_Response_to_AMA__c;
    //     String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; //dblcontracts@ama-assn.org
        
    //     //Create a master list to hold the emails we'll send
    //     List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
    //     //Create a new Email
    //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
    //     if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c)) {
        
    //         List<String> ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
    //         mail.setCCAddresses(ccTo);
    //     }
        
    //     //Set email contents - you can use variables!
    //     mail.setTargetObjectId(dblContractsContactId);
    //     mail.setWhatId(amaAgrObj.id);
    //     //mail.setTemplateId(templateId); 

    //     Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
    //     emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, amaAgrObj.id);
    //     mail.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
    //     mail.setSubject(emailNotToSend.getSubject());
    //     mail.setCharset('UTF-8'); 
    
    //     mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
    //     mail.setSaveAsActivity(true);
        
    //     if(String.isNotBlank(amaAgrObj.Client__c) &&
    //         String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
    //             (amaAgrObj.Client__c.startsWithIgnoreCase('Test') || amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            
    //         mail.setTreatTargetObjectAsRecipient(false);
    //     }
        
        
    //     List<Attachment> attachments = [SELECT Id, Name, Body, ContentType, LastModifiedDate  FROM Attachment WHERE Parentid =:amaAgrObj.id];
        
    //     List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
    //     Messaging.EmailFileAttachment offshoreDoc = new Messaging.EmailFileAttachment();
    //     for(Attachment att : attachments) {
        
    //         Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    //         // to figure out the correct file extension
    //         if(String.isNotBlank(att.Name) && att.Name.containsIgnoreCase('AMA Offshore Consent Form')) {
                
    //             efa.setFileName(att.Name);
    //             // Take the blob data from the Attachment and put it on the email.
    //             efa.setBody(att.Body);
    //             efa.setContentType(att.ContentType);
    //             emailAttachments.add(efa);
    //         }
    //     }
        
    //     mail.setFileAttachments(emailAttachments);
    //     mails.add(mail);
                    
    //     try {
    //         if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
    //             //Send all emails in the master list
    //             Messaging.sendEmail(mails);
                
    //         }
    //     } catch(Exception e) {
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreTemplate:::sendOffshoreAMAResponseToDBL', amaAgrObj.Id != null ? amaAgrObj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         System.debug('Send AMA Response to DBL failed: ' + e.getMessage());
    //     } 
    // }
    
    
    // @Future(callout=true)
    // global static void generateDocument(String recId, string agrName)
    // {
    //     AMA_Agreement_Detail__c amaObject = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{recId}, new Set<String>{'TPA_Request__r.Agreement_Name__c', 'Ex_US_Legal_Entity_Name__c'}).get(0);
    //     try {
        
    //         PageReference pdf = new PageReference(UTL_TPA.TPA_SITEURL+'/tpa/VFP_TPA_AMA_OffshoreDocGenerator?id='+recId+'&docGenCall=true');
    //         Blob body;
    //         if(Test.IsRunningTest()) {
    //             body = Blob.valueOf('UNIT.TEST');
    //         }
    //         else {
    //             body = pdf.getContent();
    //         }
            
    //         String attchDocName = 'AMA Offshore Consent Form '+ ' ' +agrName + '.doc';
    //         List<Attachment> attachmentList = [SELECT Id, Name, Body, ContentType  FROM Attachment WHERE Parentid =: recId and Name =:attchDocName];
    //         if(!attachmentList.isEmpty()) {
    //             delete attachmentList;
    //         }
            
    //         Attachment attach = new Attachment();
    //         attach.Body = body;
    //         attach.Name = attchDocName;
    //         attach.IsPrivate = false;
    //         attach.ParentId = recId;
    //         insert attach;
            
    //         sendOffshoreAMAResponseToDBL(amaObject); 
            
    //     }
    //     catch(Exception ex) {
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMAOffshoreTemplate:::generateDocument', amaObject.Id != null ? amaObject.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         system.debug(ex.getMessage());
    //     }
        
    // }
    
    // public static void SendNotificationWithOffshoreLink(AMA_Agreement_Detail__c  amaAgrObj) {     
                  
                
    //     try {        
               
    //         List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
    //         TPA_Settings__c tpaSetting = TPA_Settings__c.getOrgDefaults();
            
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
    //         email.setTargetObjectId(amaSetting.get(0).Vendor_Contact_ID__c );
    //         email.setWhatId(amaAgrObj.Id);
    //         email.setTemplateId(amaSetting.get(0).Offshore_Vendor_Revised_Noti_Template_ID__c);
            
    //         AMA_Agreement_Detail__c amaObjWithAgrmt = SLT_AMAAgreementDetail.instance.getAMAAgreementDetailById(true, new Set<Id>{amaAgrObj.Id}, new Set<String>{'TPA_Request__r.TP_Processor_Email__c', 
    //                                                                                                                                                       'TPA_Request__r.Vendor_Contact_Email_Client__c', 
    //                                                                                                                                                       'TPA_Request__r.Vendor_Contact_e_mail__c', 
    //                                                                                                                                                       'TPA_Request__r.Vendor_e_mail__c'}).get(0); 
            
    //         List<String> toAddress = new List<String>();
    //         List<String> ccTo = new List<String>();
            
    //         if(String.isNotBlank(amaObjWithAgrmt.TPA_Request__r.Vendor_e_mail__c)) {
    //             toAddress.add(amaObjWithAgrmt.TPA_Request__r.Vendor_e_mail__c);
    //         }
          
    //         if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c)) {
            
    //             toAddress = amaSetting.get(0).Dev_Mail_ID__c.split(';'); 
    //             email.setToAddresses(toAddress); 
    //         }
            
    //         if(String.isNotBlank(amaSetting.get(0).CC_Address_For_Vendor_Offshore_Mail__c)) {
            
    //             ccTo = amaSetting.get(0).CC_Address_For_Vendor_Offshore_Mail__c.split(';');
    //             email.setCCAddresses(ccTo);
    //         }
            
    //         if(String.isNotBlank(tpaSetting.TPA_BCC_Emails__c)) {
    //            List<String> bccTo = new List<String>();
    //            bccTo.addAll(tpaSetting.TPA_BCC_Emails__c.split(';'));
    //            email.setBccAddresses(bccTo);
    //         }
            
    //         email.setOrgWideEmailAddressId(tpaSetting.TPA_From_Orgwide_Email_Id__c);
            
    //         email.setSaveAsActivity(true);
    //         email.setTreatTargetObjectAsRecipient(false);

    //         if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) { 
    //             //Messaging.sendEmail(New Messaging.SingleEmailMessage[] {email});
    //             //SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Offshore_Vendor_Revised_Noti_Template_ID__c, amaAgrObj.Id, null, '', FALSE, '');

    //         }
    //     }
    //     catch(Exception ex) {
    //         system.debug(ex.getMessage());
    //     }
    // }       
    
}