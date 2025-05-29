global class CNT_TPA_AMAOffshoreDocGenerator {
    
    // public static List<AMA_Agreement_Detail__c> amaAgreementDetailValues{get; set;}
    // public static String amaAgreementID{get; set;}
    // public static AMA_Agreement_Detail__c amaAgreementDetailObj {
    //     get{
    //         if(amaAgreementDetailObj == null){
    //             if(!Test.isRunningTest())
    //             {
    //                 amaAgreementID = ApexPages.currentPage().getParameters().get('id');
    //             }
    //             if(amaAgreementID != null)
    //             {
    //                 amaAgreementDetailValues = [Select id,Name,  TPA_Request__r.Employee_Accessing_Data_Location__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
    //                                             TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Request_Status__c,  Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c, Client_Company_Name__c,
    //                                             Status_of_Offshore_Questionnaire__c, Where_will_the_data_reside__c, pharmaceutical_client_accessed_overseas__c, service_provider_accessed_overseas__c, With_the_overseas_entity__c, Tell_us_about_the_project__c, Volume_of_records__c,              
    //                                             Specific_variables_requested__c, offshore_entity_interacting_with_data__c, How_will_the_data_be_accessed__c, HTTPS_VPN_Other__c, app_software_used_at_offshore__c, Data_security_procedures_used__c , Encryption__c,Can_data_be_downloaded_or_printed__c, Firewall_port_filtering_technologies__c,
    //                                             Other__c, physical_security_procedures__c, Portable_storage_devices_allowed__c, Employees_have_wireless_connectivity__c, Is_area_secure__c, Number_of_computers_used__c, Additional_technologies_used__c
    //                                             FROM AMA_Agreement_Detail__c Where id = :amaAgreementID limit 1];
    //                 if(amaAgreementDetailValues!= null && !amaAgreementDetailValues.isEmpty())
    //                     amaAgreementDetailObj = amaAgreementDetailValues.get(0);
    //             }
    //         }
    //         return amaAgreementDetailObj;
    //     }
    //     set;
    // }
    
    
    
    // public String amaAgreementDetailAsString {
    //     get{
    //         return JSON.serialize(amaAgreementDetailObj);
    //     }
    //     set;
    // }
    // public String getPrintView()
    // {
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
    
    // public String getWordStyle()
    // {
    //     return '<style>.useDefStyle p {margin:0.0in;} .useDefStyle ol ol li p {margin:0.04in 0.0in 0.1in 0.0in;}</style>';
    // }
    
    
    public CNT_TPA_AMAOffshoreDocGenerator() {
    }
    
    // @remoteAction       
    // public static Boolean tpUsReqSendQuesTOVendor(String amaAgreementObjID ) {      
                
    //     AMA_Agreement_Detail__c obj = [Select id,  TPA_Request__r.Name, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,      
    //                                         TPA_Request__c,  Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,       
    //                                         Status_of_Offshore_Questionnaire__c                         
    //                                         FROM AMA_Agreement_Detail__c  Where id =:amaAgreementObjID limit 1];        
                                
    //     obj.Status_of_Offshore_Questionnaire__c = 'Awaiting Vendor Response: AMA Offshore Questionnaire has been sent to Vendor';
    //     obj.Last_Vendor_Offshore_Reminder_Mail_Sent__c = Date.today();      
    //     try {       
    //         update obj;     
                    
    //         SendNotificationWithOffshoreLink(obj);      
    //         return true;        
                        
    //     } catch (DmlException e) {            
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreDocGenerator:::tpUsReqSendQuesTOVendor', obj.Id != null ? obj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return false;       
    //     }       
                
    // }       
    
    // @remoteAction
    // public static String saveOffshoreQuestionnaire(String amaAgreementObj) {
        
    //     amaAgreementDetailObj = (AMA_Agreement_Detail__c)JSON.deserialize(amaAgreementObj, AMA_Agreement_Detail__c.class);
        
    //     AMA_Agreement_Detail__c obj = [Select id, Name,  TPA_Request__r.Name, TPA_Request__r.Employee_Accessing_Data_Location__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
    //                                         TPA_Request__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c, 
    //                                         Status_of_Offshore_Questionnaire__c                 
    //                                         FROM AMA_Agreement_Detail__c  Where id =:amaAgreementDetailObj.id limit 1];
        
    //     List<Attachment> attachments = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Parentid =:amaAgreementDetailObj.id];
        
    //     try {
        
    //         if(obj.Status_of_Offshore_Questionnaire__c != 'Awaiting Vendor Response: AMA Offshore Questionnaire has been sent to Vendor')
    //         {
    //             return 'alreadySubmittedResponse';
    //         }
    //         else
    //         {
    //             Attachment a;
    //             for(Attachment att : attachments) {
    //                 if(String.isNotBlank(att.Name) && att.Name.startsWithIgnoreCase('Temp') 
    //                    && att.Name.containsIgnoreCase('Connection Diagram') )
    //                 {
    //                     a = att;
    //                     att.Name = att.Name.replace('Temp', '');
    //                     a.Name = att.Name.trim();
    //                     break;
    //                 }
    //             }
    //             if(a != null)
    //                 update a;
    //             update amaAgreementDetailObj;
    //         }   
            
    //     } catch (DmlException e) {
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreDocGenerator:::saveOffshoreQuestionnaire', obj.Id != null ? obj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return 'error';
    //     } catch (Exception e) {
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreDocGenerator:::saveOffshoreQuestionnaire', obj.Id != null ? obj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return 'error';
    //     }
    //     return 'Success';
    // }
    
    // public static void SendCompletionOffshoreNotification(AMA_Agreement_Detail__c amaAgrObj)
    // {
    //     //Set list of people who should be CC'ed
    //     List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
 
    //     String templateId = amaSetting.get(0).Offshore_Noti_To_TPUS_Template_ID__c  ;
        
    //     TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance(); 
        
    //     //Create a master list to hold the emails we'll send
    //     List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
    //     //Create a new Email
    //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
    //     //Set email contents - you can use variables!
        
    //     mail.setTargetObjectId(UTL_TPA.emailTargetContactId);

    //     List<String> toAddress = new List<String>();
        
    //     if(String.isNotBlank(amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c )) {
    //         toAddress = amaSetting.get(0).To_Address_For_TP_US_Cancelation_Mail__c.split(';');
    //     }
        
    //     if(String.isNotBlank(amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c ))
    //     {
    //         List<String> ccTo = amaSetting.get(0).CC_Address_For_TPUS_Offshore_Mail__c .split(';');
    //         mail.setCCAddresses(ccTo);
    //     }
        
    //     if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
    //        List<String> bccTo = new List<String>();
    //        bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
    //        mail.setBccAddresses(bccTo);
    //     }
        
    //     mail.setToAddresses(toAddress);
    //     mail.setWhatId(amaAgrObj.id);
    //     //mail.setTemplateId(templateId); 

    //     Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
    //     emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, amaAgrObj.id);
    //     mail.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
    //     mail.setSubject(emailNotToSend.getSubject());
    //     mail.setCharset('UTF-8');
        
    //     mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
    //     mail.setSaveAsActivity(true);
        
    //     List<Attachment> attachments = [SELECT Id, Name, Body, ContentType, LastModifiedDate  FROM Attachment WHERE Parentid =:amaAgrObj.id];
        
    //     List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
    //     Messaging.EmailFileAttachment offshoreDoc = new Messaging.EmailFileAttachment();
    //     for(Attachment att : attachments) {
        
    //         Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
    //         // to figure out the correct file extension
    //         if(String.isNotBlank(att.Name) && !att.Name.startsWithIgnoreCase('Temp') 
    //            && (att.Name.containsIgnoreCase('Connection Diagram') 
    //                || (att.Name.containsIgnoreCase('AMA Offshore Questionnaire'))))
    //         {
    //             efa.setFileName(att.Name);
    //             // Take the blob data from the Attachment and put it on the email.
    //             efa.setBody(att.Body);
    //             efa.setContentType(att.ContentType);
    //             emailAttachments.add(efa);
    //         }
    //     }
        
    //     mail.setFileAttachments(emailAttachments);
        
    //     //Add email to the master list
    //     mails.add(mail);
              
    //     try {
    //         if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
    //             Messaging.sendEmail(mails);
    //         }
    //     } catch(Exception e) {
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreDocGenerator:::SendCompletionOffshoreNotification', amaAgrObj.Id != null ? amaAgrObj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //     } 
    // }
    
    // @remoteAction
    // global static string generateDocument(String recId, string agrName)
    // {
    //     AMA_Agreement_Detail__c amaObject = [Select id, Name, TPA_Request__r.Employee_Accessing_Data_Location__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c,
    //                                         TPA_Request__c, TPA_Request__r.Name, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c , Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c, 
    //                                         Status_of_Offshore_Questionnaire__c                 
    //                                         FROM AMA_Agreement_Detail__c  Where id =:recId limit 1];
    //     try
    //     {
    //         PageReference pdf = Page.VFP_TPA_AMAOffshoreDocGenerator;
    //         pdf.getParameters().put('id',recId);
    //         pdf.getParameters().put('docGenCall','true');
    //         Blob body;
    //         if (Test.IsRunningTest())
    //         {
    //             body = Blob.valueOf('UNIT.TEST');
    //         }
    //         else
    //         {
    //             body = pdf.getContent();
    //         }
    //         String attchDocName = 'AMA Offshore Questionnaire'+ ' ' +agrName + '.doc';
    //         List<Attachment> attachmentList = [SELECT Id, Name, Body, ContentType  FROM Attachment WHERE Parentid =: recId and Name =:attchDocName];
    //         delete attachmentList;
            
    //         Attachment attach = new Attachment();
    //         attach.Body = body;
    //         attach.Name = attchDocName;
    //         attach.IsPrivate = false;
    //         attach.ParentId = recId;
    //         insert attach;
            
    //         SendCompletionOffshoreNotification(amaObject);
    //     }
    //     catch(Exception ex)
    //     {
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMAOffshoreDocGenerator:::generateDocument', amaObject.Id != null ? amaObject.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
    //         return 'exception: ' + ex.getMessage();
    //     }
    //     return 'Success';
    // }
    
    // public static void SendNotificationWithOffshoreLink(AMA_Agreement_Detail__c  amaAgrObj)     
    // {               
                
    //     try             
    //     {               
    //         //Date todayDate;     
    //         //todayDate = Date.today();       
    //         List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();       
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
                    
    //         email.setTargetObjectId(amaSetting.get(0).Vendor_Contact_ID__c );       
    //         email.setWhatId(amaAgrObj.Id);      
    //         //email.setTemplateId(amaSetting.get(0).Offshore_Vendor_Notification_Template_ID__c);     
                    
    //         Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
    //         emailNotToSend = Messaging.renderStoredEmailTemplate(amaSetting.get(0).Offshore_Vendor_Notification_Template_ID__c, NULL, amaAgrObj.Id);
    //         email.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
    //         email.setSubject(emailNotToSend.getSubject());
    //         email.setCharset('UTF-8'); 
    
    //         AMA_Agreement_Detail__c amaObjWithAgrmt = [Select id, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Vendor_Contact_e_mail__c from AMA_Agreement_Detail__c WHERE id =: amaAgrObj.Id];        
    //         system.debug('amaAgrObj.TPA_Request__r.TP_Processor_Email__c'+amaObjWithAgrmt.TPA_Request__r.TP_Processor_Email__c +'amaAgrObj.TPA_Request__r.Vendor_Contact_Email_Client__c'+amaAgrObj.TPA_Request__r.Vendor_Contact_Email_Client__c +'amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c'+amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c );     
    //         List<String> toAddress= new List<String>{amaObjWithAgrmt.TPA_Request__r.TP_Processor_Email__c , ((amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c == null || amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c.length() == 0) ? amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_Email_Client__c : amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c)};
    //         if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c)){
            
    //             List<String> toAdd = amaSetting.get(0).Dev_Mail_ID__c.split(';'); 
    //             email.setToAddresses(toAdd); 
    //         }
    //         else{
    //             email.setToAddresses(toAddress);
    //         }
    //         if(String.isNotBlank(amaSetting.get(0).CC_Address_For_Vendor_Offshore_Mail__c))     
    //         {       
    //             List<String> ccTo = amaSetting.get(0).CC_Address_For_Vendor_Offshore_Mail__c.split(';');        
    //             email.setCCAddresses(ccTo);     
    //         }       
    //         TPA_Settings__c tpaSetting = TPA_Settings__c.getOrgDefaults();
    //         if(String.isNotBlank(tpaSetting.TPA_BCC_Emails__c)) {
    //            List<String> bccTo = new List<String>();
    //            bccTo.addAll(tpaSetting.TPA_BCC_Emails__c.split(';'));
    //            email.setBccAddresses(bccTo);
    //         }
            
    //         tpaSetting = TPA_Settings__c.getInstance();     
    //         email.setOrgWideEmailAddressId(tpaSetting.TPA_From_Orgwide_Email_Id__c);        
                    
    //         email.setSaveAsActivity(true);      
    //         try     
    //         {       
    //             if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {        
    //                 Messaging.sendEmail(New Messaging.SingleEmailMessage[] {email});        
    //                 system.debug('abchfnrg4');      
    //             }       
    //         }       
    //         catch(Exception e)      
    //         {       
    //             UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::CNT_TPA_AMAOffshoreDocGenerator:::SendNotificationWithOffshoreLink', amaAgrObj.Id != null ? amaAgrObj.Id : ''));
    //             UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);        
    //         }       
    //     }       
    //     catch(Exception ex)     
    //     {       
    //         UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, ex.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + ex.getLineNumber() + ':::CNT_TPA_AMAOffshoreDocGenerator:::SendNotificationWithOffshoreLink', amaAgrObj.Id != null ? amaAgrObj.Id : ''));
    //         UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);  
    //     }
    // }       
}