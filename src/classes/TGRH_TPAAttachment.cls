public without sharing class TGRH_TPAAttachment {
    public string templateName = 'TPA Limited License Agreement';
    public Static string InEffectSteps = ' ';
    public List<Messaging.SingleEmailMessage> mails;
    public static List<Apttus__APTS_Template__c> listTemplates;
    public void OnBeforeInsert(Attachment[] newAttachments, List<dsfs__DocuSign_Status__c> dsRecords) {
        
        List<id> parentOfAtt = new List<id>();
        for(Attachment att:newAttachments){
            if(att.Name.toLowerCase().indexOf(('STANDARD TERMS AND CONDITIONS').toLowerCase()) != -1 || att.Name.toLowerCase().indexOf(('Compliance Program').toLowerCase()) != -1 ){
                continue;
            }
            else{
                parentOfAtt.add(att.ParentId);
            }
        }
        for(dsfs__DocuSign_Status__c objDocusignStatus: dsRecords)
        {
            for(Attachment att:newAttachments){
                att.Name = att.Name +'_Completed';
                if(!Test.isRunningTest()){
                    att.ParentId = objDocusignStatus.TPA_Request__c;
                }
                if(att.Name.indexOf('Signed-on') != -1){
                    att.Name = 'Signed on Paper_'+Label.TPA_TLLA+'_'+objDocusignStatus.TPA_Request__r.name+'_Completed';
                }
            }
            
        }
        
        Map<id,AMA_Agreement_Detail__c> amaAgreementsMap= new Map<id,AMA_Agreement_Detail__c>();
        if(!parentOfAtt.isEmpty()) {
            for(TPA_Request__c agg : [Select id,name,(Select id, Current_Year_Invoice__c, Next_Year_Invoice__c, Contract_Type__c,Ex_Contract_Type__c,Current_Year__c,Is_AMA_License_Required__c,Is_Offshore_Access_Amendment_to_FL_Req__c,Is_Offshore_Access_Amendment_Required__c,Is_Foreign_License_Required__c,Is_Off_Access_Amendment_Req_WithNALoc__c,AMA_Foreign_Storage_Contract_Type__c from AMA_Agreement_Details__r ) 
                                      from TPA_Request__c
                                      where id in: parentOfAtt]) {
                                          if(agg.AMA_Agreement_Details__r.size() > 0) {
                                              amaAgreementsMap.put(agg.id, agg.AMA_Agreement_Details__r[0]);
                                          }
                                          
                                      }
            
            for(TPA_Request__c agg : [select id,Pending_Acknowledgements__c,Requires_Manual_Review__c,Secondary_Client_Contact_Territory__c,Is_Contract_Generated__c,Data_Access_Start_Date__c
                                      , Service_Provider_Name__c,Client_Address__r.Name,Client_Address__r.Region_Territory__c
                                      , Check_Use_Definition_Extension__c, Client_Off_Notification_Ack_Date__c
                                      , Vendor_Off_Notification_Ack_Date__c, is_Addendum_Attachment_Required__c
                                      ,Vendor_Billing_Mailing_Country__c, Agreement_Name__c 
                                      ,Name,Client_Contact_Territory__c from TPA_Request__c where id IN : parentOfAtt]) 
            {
                for(Attachment att:newAttachments)
                {
                    String tpsaClient = 'Regenerated_'+Label.TPSA_Client_Template_Name;
                    String tpsaVendor = 'Regenerated_'+Label.TPSA_Vendor_Template_Name;
                    string serviceProvider ='';
                    string client ='';
                    string region ='';
                    string tpaRequestName ='';
                    string currentYear = '';
                    Boolean isTechLicSelected = false;
                    if(listTemplates == null) {
                        listTemplates = [Select Id, Name, Apttus__Keywords__c FROM Apttus__APTS_Template__c WHERE Apttus__Keywords__c IN ('AMA Agreement', 'TPA Agreement', 'TPSA', 'Use Defination') AND Apttus__IsActive__c = TRUE];
                    }
                    if(listTemplates != null) {
                        for(Apttus__APTS_Template__c objApttusTemplate: listTemplates) {
                            if(att.Name.indexOf(agg.Name + '_' + objApttusTemplate.Name) != -1) {
                                att.Name = att.Name.replace(agg.Name, agg.Agreement_Name__c);
                                break;
                            }
                        }
                    }
                    if(att.Name.indexOf('Merged') > -1 && att.Name.indexOf('MergedAdHocDocs') < 0){
                        att.Description = 'Merged with AddHoc Exhibit Pages';
                        att.Name = att.Name.replace('Merged','');
                    }
                    if(att.Name.indexOf(Label.TPSA_Client_Template_Name) > -1 || att.Name.indexOf(Label.TPSA_Vendor_Template_Name) > -1 || att.Name.indexOf('TP Tech Lic Agreement') > -1 || att.Name.indexOf('TP Tech License Agreement (hosted by Client or IQVIA – NO TPA ASSOCIATED)') > -1 || att.Name.indexOf('IQVIA Third Party Access Program - Tech Amendment') > -1) { 
                        att.Name = att.Name.replace('_TLLA','');
                    }
                    if (agg.Service_Provider_Name__c != null) {
                        if(agg.Service_Provider_Name__c.length()>15) {
                            serviceProvider = agg.Service_Provider_Name__c.substring(0,14);
                        } else {
                            serviceProvider = agg.Service_Provider_Name__c;
                        }
                    }
                    
                    if (agg.Client_Address__r != null && agg.Client_Address__r.Name != null ) {
                        if(agg.Client_Address__r.Name.length()>10) {
                            client = agg.Client_Address__r.Name.substring(0,10);
                        } else {
                            client = agg.Client_Address__r.Name;
                        }
                    }
                    
                    if (agg.Secondary_Client_Contact_Territory__c != null ) {
                        region = agg.Secondary_Client_Contact_Territory__c;
                    }
                    
                    if (agg.Name != null ) {
                        tpaRequestName = agg.Name;
                    }
                    currentYear = string.valueOf(Date.Today().Year());                    
                    if(att.ParentId == agg.id && att.name.indexOf(Label.TPA_TLLA)!= -1
                       && att.name.indexOf(templateName)!= -1) 
                    {
                        if(agg.Pending_Acknowledgements__c != null && agg.Pending_Acknowledgements__c.indexOf('TLLA Generation Pending after Ad-Hoc Terms update') != -1){
                            string strPickListValue = agg.Pending_Acknowledgements__c;
                            if(strPickListValue != null) {
                                List<string> lstPicklistValues = strPickListValue.split(';');
                                string strValueToRemove ='TLLA Generation Pending after Ad-Hoc Terms update';
                                if(lstPicklistValues.contains(strValueToRemove)){
                                    lstPicklistValues.remove(lstPicklistValues.indexOf(strValueToRemove));
                                }
                                agg.Pending_Acknowledgements__c = String.join(lstPicklistValues,';');
                            }
                        }
                        if(att.name.indexOf('Regenerated')!= -1)
                        {
                            if(att.Name.endsWith('.doc') || att.Name.endsWith('.docx') || att.Name.endsWith('.rtf')) {
                                agg.Check_Use_Definition_Extension__c = true;
                            }
                        }
                        
                        att.Name = att.Name.endsWith('.docx')? att.Name.substring(att.Name.length()-5): att.Name.substring(att.Name.length()-4);
                        att.Name = tpaRequestName+'_'+serviceProvider + '_' + Label.TPA_TLLA + '_' + client+'_'+region+'_'+ currentYear +att.Name ;
			if(att.Name.contains('"')){
                        
                        	att.Name = att.Name.replace('"','');     
                    	}
                        agg.List_of_tllas__c = att.Name;
                        
                        if(att.Name.indexOf('Use Defination Template') == -1){ 
                            
                            agg.Agreement_Effective_Date__c = agg.Data_Access_Start_Date__c.daysBetween(date.today()) > 0 ? date.today() : agg.Data_Access_Start_Date__c;
                        }
                        
                        if(agg.Client_Off_Notification_Ack_Date__c == null || agg.Vendor_Off_Notification_Ack_Date__c == null){
                            agg.Offering_Notification_Document_Id__c  = null;
                        }
                        update agg;
                        // if(agg.is_Addendum_Attachment_Required__c == true ) {
                        //     SRV_TPA_TPARequest.generateAddendumNotificationDoc(agg.Id, 'pdf', UTL_LogFactory.GUID); 
                        // }
                        
                    }
                    else if(att.ParentId == agg.id && att.name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1 ) 
                    {
                        Boolean isCompleted = att.Name.indexOfIgnoreCase('completed') != -1 ? true : false;
                        att.Name = isCompleted ? att.Name.substring(0,att.Name.length() - 10) : att.Name;
                        att.Name = att.Name.endsWith('.docx')? att.Name.substring(att.Name.length()-5): att.Name.substring(att.Name.length()-4);
                        att.Name = tpaRequestName+'_'+UTL_TPA.helpfulHintsDocLabel +'_'+ currentYear +att.Name ;
                        att.Name += isCompleted ? '_Completed' : '';
                    }
                    else if(att.ParentId == agg.id && att.name.indexOf('IQVIA Third Party Access Program - Tech Amendment') != -1 ) 
                    {
                        att.Name = att.Name.endsWith('.docx')? att.Name.substring(att.Name.length()-15): att.Name.substring(att.Name.length()-14);
                        att.Name = agg.Agreement_Name__c + '_IQVIA Third Party Tech Amendment_' + att.Name ;
                        isTechLicSelected = true;
                    }
                    else if(att.ParentId == agg.id && att.name.indexOf('IQVIA Third Party Tech Amendment') != -1 ) 
                    {
                        isTechLicSelected = true;
                    }
                    else if(att.ParentId == agg.id && att.name.indexOf('TP Tech License Agreement (hosted by Client or IQVIA – NO TPA ASSOCIATED)') != -1) 
                    {
                        att.Name = att.Name.endsWith('.docx')? att.Name.substring(att.Name.length()-15): att.Name.substring(att.Name.length()-14);
                        att.Name = agg.Agreement_Name__c + '_IQVIA Third Party Tech License Agreement_' + att.Name ;
                        isTechLicSelected = true;
                        
                    }
                    else if(att.ParentId == agg.id && att.name.indexOf('Tech License Agreement') != -1 ) 
                    {
                        isTechLicSelected = true;
                    }
                    else if(att.name.indexOf('Regenerated_Use Definition')!= -1 || att.name.indexOf(tpsaClient)!= -1 || att.name.indexOf(tpsaVendor)!= -1)
                    {
                        att.Name = att.Name.replace('Regenerated_','');
                    }
                    else if(att.ParentId == agg.id && att.name.indexOf('NOTICE OF CANCELLATION AND DESTRUCTION - TPSU') != -1 ) 
                    {
                        att.Name = att.Name.endsWith('.docx')? att.Name.substring(att.Name.length()-5): att.Name.substring(att.Name.length()-4);
                        att.Name = 'Notice of Cancellation and Destruction ' + serviceProvider + '_' + client + ' ' + DateTime.now().format('MM.dd.yyyy') + att.Name ;
                    }
                    else if(att.ParentId == agg.id && att.name.indexOf('CREDIT MEMO INVOICE') != -1 ) 
                    {
                        AMA_Agreement_Detail__c amaAgreement = amaAgreementsMap.get(att.parentId);
                        String invoiceNumber = '';
                        if(amaAgreement?.Next_Year_Invoice__c != null){
                            invoiceNumber = '' + amaAgreement.Next_Year_Invoice__c;  
                        }
                        else if(amaAgreement?.Current_Year_Invoice__c != null){
                            invoiceNumber = '' + amaAgreement.Current_Year_Invoice__c;
                        }
                        att.Name = att.Name.endsWith('.docx')? att.Name.substring(att.Name.length()-5): att.Name.substring(att.Name.length()-4);
                        att.Name = 'Credit Memo Invoice ' + invoiceNumber + '_' + (amaAgreement?.Contract_Type__c == null ? '' : amaAgreement?.Contract_Type__c) + '_' +  serviceProvider + '_' + client + ' ' + DateTime.now().format('MM.dd.yyyy') + att.Name;
                    }
                    if(att.Name.indexOf('Original_Use Defination Template') > -1 || att.Name.indexOf('Use Defination Template') > -1) { 
                        att.Name = att.Name.replace('_TLLA','');
                        att.Name = att.Name.replace('_Original','');
                        att.Name = att.Name.replace(' Template','');
                        att.Name = att.Name.replace('Defination','Definition');
                    }
                    
                    Boolean isAMAAttachment = att.Name.indexOf('TPA-') != -1 && att.Name.indexOf('TLLA') != -1 && att.Name.indexOf('TLLA') < att.Name.indexOf('TPA-');
                    
                    if(att.ParentId == agg.id && isAMAAttachment && !isTechLicSelected) {
                        AMA_Agreement_Detail__c amaAgreement = amaAgreementsMap.get(att.parentId);
                        if(amaAgreement != null) {
                            String amaContractType = amaAgreement.Contract_Type__c;
                            if(amaAgreement.Is_Foreign_License_Required__c && amaAgreement.AMA_Foreign_Storage_Contract_Type__c != null && att.name.indexOf('Foreign License') != -1 && att.name.indexOf('ExUS Entity') == -1){ 
                                amaContractType = amaAgreement.AMA_Foreign_Storage_Contract_Type__c;
                            }
                            if((amaAgreement.Is_Offshore_Access_Amendment_Required__c || amaAgreement.Is_Off_Access_Amendment_Req_WithNALoc__c) && amaAgreement.Ex_Contract_Type__c != null && att.name.indexOf('Offshore Access Amendment') != -1){ 
                                amaContractType = 'Offshore Access Amendment ' + amaAgreement.Ex_Contract_Type__c;
                            }
                            att.Name = att.Name.endsWith('.docx')? att.Name.substring(att.Name.length()-5): att.Name.substring(att.Name.length()-4);
                            att.Name = 'AMA_'+amaContractType+'_'+tpaRequestName+'_'+serviceProvider+'_'+client+'_'+amaAgreement.Current_Year__c+att.Name; 
                        }
                    }
                    InEffectSteps += 'In Before Insert: ' + att.Name;
                }
            }
        }
    }
    
    public void OnAfterInsert(Attachment[] newAttachments){
        InEffectSteps += 'In Aftre Insert: ';
        List<id> parentOfatt = new List<id>();
        
        Map<Id, TPA_Request__c> tpaMapToUpdate = new Map<Id, TPA_Request__c>();
        TPA_Request__c objTpaRequest;
        TPA_Agreement_Additional_Field__c tpaAgreementAdditionalFieldData; 
        Map<string, string> mapTpaAttachAgreement = new Map<string, string>();
        Map<Id,Attachment> mapAgreeIdWithAttachmentObj = new Map<Id,Attachment>();
        List<Attachment> lstAttachmentDeleted =  new List<Attachment>();
        Set<Id> stAttIds = new Set<Id>();
        pattern AMAPattern = pattern.compile('AMA_.*TPA.*.[pP][dD][fF]_[cC][oO][mM][pP][lL][eE][tT][eE][dD]'); 
        pattern AMAPatternBeforeSign = pattern.compile('AMA_.*TPA.*.pdf'); 
        mails = new List<Messaging.SingleEmailMessage>(); 
        Boolean sendAfterInvoiceForAMA = false; 
        Boolean isCurrentAttTLLA = false; 
        Boolean isCurrentAttMergedTLLA = false; 
        Boolean isCurrentMergedAddHoc = false;
        Boolean isCurrentAttHelpfulHint = false; 
        Boolean isCurrentAttAMA = false; 
        Boolean isCurrentAttTPATechLicense = false;
        
        List<Task> lstTaskInsert = new List<Task>();
        List<User> lstUser = [select id,TimeZoneSidKey from User where id =: userInfo.getUserId()];
        for(Attachment att:newAttachments){
            if(att.Name.toLowerCase().indexOf(('STANDARD TERMS AND CONDITIONS').toLowerCase()) != -1 || att.Name.toLowerCase().indexOf(('Compliance Program').toLowerCase()) != -1 ){
                String userTimeZone = null;
                if(lstUser != null && lstUser.size() != 0){
                    userTimeZone = lstUser[0].TimeZoneSidKey;
                }
                String strConvertedDate = System.now().format('MM/dd/yyyy hh:mm a',userTimeZone);
                Task tk = new Task( WhatId = att.ParentId, ActivityDate = system.today(), Status = 'Completed',
                                               Subject = att.Name+' attached by '+userInfo.getName()+' on '+ strConvertedDate );
                lstTaskInsert.add(tk);
            }
            else{
                parentOfatt.add(att.ParentId);
                mapAgreeIdWithAttachmentObj.put(att.ParentId, att);
                if(att.name.indexOf(Label.TPA_TLLA)!= -1 && (att.Description == null || att.Description == '' || att.Description.indexOf('Merged') < 0)){
                    if(mapTpaAttachAgreement.get(att.ParentId) == null){
                        mapTpaAttachAgreement.put(att.ParentId, att.Id + '~' + att.Name);
                    }
                    isCurrentAttTLLA = true; 
                }
                if(att.name.indexOf(Label.TPA_TLLA)!= -1 && (att.Description != null && att.Description != '' && att.Description.indexOf('Merged') > -1)){
                    isCurrentAttMergedTLLA = true; 
                }
                if(att.name.indexOf('MergedAdHocDocs')!= -1){
                    isCurrentMergedAddHoc = true; 
                }
                if(att.name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1 && !(att.name.containsIgnoreCase('Completed'))){
                    isCurrentAttHelpfulHint = true;
                }
                if(att.name.indexOf('AMA_') != -1 && !(att.name.containsIgnoreCase('Completed'))){
                    isCurrentAttAMA = true;
                }
                if((att.name.indexOf('Tech License Agreement') != -1 || att.name.indexOf('Third Party Tech Amendment') != -1 ) && !(att.name.containsIgnoreCase('Completed'))){
                    isCurrentAttTPATechLicense = true;
                }
                if(AMAPattern.matcher(att.Name).matches()){
                    sendAfterInvoiceForAMA = true;
                }
                InEffectSteps += '-att.name:' + att.name;
            }
        }
        
        Map<id,List<AMA_Agreement_Detail__c>> childDetailMap = new Map<id,List<AMA_Agreement_Detail__c>>();
        
        if(!parentOfatt.isEmpty()) {
            List<AMA_Agreement_Detail__c> amaAgrDetailList = [SELECT id, Vendor_Legal_Name__c, Client__c, TPA_Request__c, TPA_Request__r.name,
                                                              (SELECT ActivityDate, Subject, Description from ActivityHistories ORDER BY ActivityDate DESC , LastModifiedDate DESC LIMIT 500) FROM AMA_Agreement_Detail__c where TPA_Request__c IN :parentOfatt];
            for(AMA_Agreement_Detail__c amaObj: amaAgrDetailList) {
                List<AMA_Agreement_Detail__c> childList;
                if(childDetailMap.containsKey(amaObj.TPA_Request__c)) {
                    childList = childDetailMap.get(amaObj.TPA_Request__c);
                }
                else {
                    childList =  new List<AMA_Agreement_Detail__c>();
                }
                childList.add(amaObj);
                childDetailMap.put(amaObj.TPA_Request__c, childList);
            }
        }

        if(!parentOfatt.isEmpty()) {
            for(TPA_Request__c agg : [select id ,Pending_Acknowledgements__c, Exhibit_Page_Required__c, TLLA_Language_Chosen__c, Vendor_Language__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Is_VSN_Acknowlege_By_Client__c, isClientOnComplianceHold__c, isVendorOnComplianceHold__c, Is_Potential_Vendor_Case__c, isLegalEntityPresent__c, is_Bulk_TPA_Request__c, Is_Contract_Generated__c, is_Addendum_Attachment_Required__c, Requires_Manual_Review__c,Vendor_Off_Notification_Ack_Date__c,Owner.Type, Owner.Email, Request_Status__c,Client_Off_Notification_Ack_Date__c, Vendor_App_Submitted__c,(Select Id,Status__c,Manual_Review_Reason__c from TPA_Commercial_Reviews__r), (select id , Description,name, createdDate from attachments order by CreatedDate DESC), (Select id, Client__c ,Vendor_Legal_Name__c , Contract_Type__c, Current_Year__c, Current_Year_Fees__c, Next_Year_Fees__c, Is_AMA_License_Required__c, AMA_Manual_Review__c, Invoice_Contact_Email__c,TPA_Request__c,TPA_Request__r.ClientContact__r.email, TPA_Request__r.Client_TPA_Representative_Email__c, TPA_Request__r.Assigned_TP_Processor__c,TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c,TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, Is_Offshore_Access_Amendment_Required__c,Is_Foreign_License_Required__c,Vendor_AMA_Fee_Response__c, Billed_in_Advance__c from AMA_Agreement_Details__r), Is_Document_Generated__c,Upload_Client_Document_Check__c, name, isbatchprocessing__c, Service_Provider_Name__c,  Authorized_Signer_Email__c, Vendor_Contact_e_mail__c , Client_Address__r.TPAOtherEmailIds__c from TPA_Request__c where id IN : parentOfatt])
            {
                Boolean invoiceMailSent = false; 
                Boolean isAddendumAttReq = agg.is_Addendum_Attachment_Required__c;
                AMA_Agreement_Detail__c amaAgreement;
                if(agg.AMA_Agreement_Details__r != null && agg.AMA_Agreement_Details__r.size() > 0){
                    amaAgreement = agg.AMA_Agreement_Details__r[0];
                }
                if(amaAgreement != null && amaAgreement.Vendor_Legal_Name__c != null) { 
                    List<AMA_Agreement_Detail__c> amaAgrList = childDetailMap.get(agg.id);
                    List<ActivityHistory> activityHistories = new List<ActivityHistory>();
                    if(amaAgrList != null) {
                        for(AMA_Agreement_Detail__c  es: amaAgrList) {
                            activityHistories = es.ActivityHistories;
                            string invoiceMailSubject = UTL_TPA.INVOICE_MAIL_SUBJECT.replace('vendorLegalName', es.Vendor_Legal_Name__c);
                            for(ActivityHistory ah:  activityHistories) {
                                if(ah.Subject.equalsIgnoreCase(invoiceMailSubject)) {
                                    invoiceMailSent= true;
                                }
                            }
                        }
                    }
                }
                Attachment att = mapAgreeIdWithAttachmentObj.get(agg.id);
                if(att.name == 'Name_Completed'){
                    stAttIds.add(att.id);
                }
                String userTimeZone = null;
                if(lstUser != null && lstUser.size() != 0){
                    userTimeZone = lstUser[0].TimeZoneSidKey;
                }
                String strConvertedDate = System.now().format('MM/dd/yyyy hh:mm a',userTimeZone);
                Attachment objAttach = mapAgreeIdWithAttachmentObj.get(agg.id);
                if(objAttach.Name != null && !objAttach.Name.toLowerCase().contains('_completed')){
                    SRV_TPA_TPARequest.updateActivityHistory(agg.Id, objAttach.Name+' attached by '+userInfo.getName()+' on '+ strConvertedDate, true);
                }
                if(tpaMapToUpdate.get(agg.Id) == null)
                {
                    objTpaRequest = [select id,is_VSN_Selected__c, (SELECT id,Vendor_Specific_Notification_Response__c FROM TPA_Agreement_Additional_Fields__r) from TPA_Request__c where id = :agg.Id]; //added by neha under ER-3031
                    if(objTpaRequest.TPA_Agreement_Additional_Fields__r != null && objTpaRequest.TPA_Agreement_Additional_Fields__r.size() > 0) {
                        tpaAgreementAdditionalFieldData = objTpaRequest.TPA_Agreement_Additional_Fields__r[0];
                    }
                    if(mapTpaAttachAgreement.get(agg.Id) != null && (mapTpaAttachAgreement.get(agg.Id)).split('~')[1].indexOf(agg.Name + '_' + (agg.Service_Provider_Name__c.length() > 15 ? agg.Service_Provider_Name__c.substring(0,14) : agg.Service_Provider_Name__c) + '_' + Label.TPA_TLLA) != -1 && TPA_Settings__c.getInstance() != null
                       && !(mapTpaAttachAgreement.get(att.ParentId)).split('~')[1].containsIgnoreCase('Completed')){
                           objTpaRequest.TPA_Doc_Link__c = TPA_Settings__c.getInstance().Base_Url__c + '/servlet/servlet.FileDownload?file=' + (mapTpaAttachAgreement.get(agg.Id)).split('~')[0];
                       }
                    if(isCurrentAttHelpfulHint){
                        if(agg.is_Addendum_Attachment_Required__c == true ) {
                            SRV_TPA_TPARequest.generateAddendumNotificationDoc(agg.Id, 'pdf', UTL_LogFactory.GUID); 
                        }
                        SRV_TPA_DocusignEnvelope.generateAmaDocForSign(agg.Id, UTL_LogFactory.GUID); 
                        
                    }
                    
                    String vendorLanguage = agg.TLLA_Language_Chosen__c != null ? agg.TLLA_Language_Chosen__c : (agg.Vendor_Language__c != null ? agg.Vendor_Language__c : 'English');
                        
                        if(isCurrentAttTLLA && mapTpaAttachAgreement.get(agg.Id) != null && (mapTpaAttachAgreement.get(agg.Id)).split('~')[1].indexOf(agg.Name + '_' + (agg.Service_Provider_Name__c.length() > 15 ? agg.Service_Provider_Name__c.substring(0,14) : agg.Service_Provider_Name__c) + '_' + Label.TPA_TLLA) != -1
                           && !(mapTpaAttachAgreement.get(agg.Id)).split('~')[1].containsIgnoreCase('Completed')){
                               
                               if(agg.Exhibit_Page_Required__c && UserInfo.getName() == 'API Integration User'){
                                   QBL_TPA_MergeAdHocDocs mergeDocQBL = new QBL_TPA_MergeAdHocDocs();
                                   mergeDocQBL.requestId = agg.Id;
                                   System.enqueueJob(mergeDocQBL);
                               }
                               else{
                                   if(vendorLanguage == 'Japanese'){
                                       SRV_TPA_TPARequest.generateHelpfulHintsAddendumDoc(agg.Id);   
                                   }
                                   else{
                                       QBL_TPA_HelpfulHintsAddendum qblHelpfulHints = new QBL_TPA_HelpfulHintsAddendum();
                                       qblHelpfulHints.requestId = agg.Id;
                                       qblHelpfulHints.GUID = UTL_LogFactory.GUID;
                                       System.enqueueJob(qblHelpfulHints);
                                   }
                               }
                           }
                    if(isCurrentAttMergedTLLA && agg.Exhibit_Page_Required__c){
                        if(vendorLanguage == 'Japanese'){
                            SRV_TPA_TPARequest.generateHelpfulHintsAddendumDoc(agg.Id);   
                        }
                        else{
                            QBL_TPA_HelpfulHintsAddendum qblHelpfulHints = new QBL_TPA_HelpfulHintsAddendum();
                            qblHelpfulHints.requestId = agg.Id;
                            qblHelpfulHints.GUID = UTL_LogFactory.GUID;
                            System.enqueueJob(qblHelpfulHints);
                        }
                    }
                    if(isCurrentMergedAddHoc && agg.Exhibit_Page_Required__c){
                        QBL_TPA_Merge_Doc mergeDocs = new QBL_TPA_Merge_Doc();
                        mergeDocs.requestId = agg.Id;
                        if(!Test.isRunningTest()){
                            System.enqueueJob(mergeDocs);   
                        }
                    }
                    
                    if(tpaMapToUpdate.get(agg.Id) == null && agg.Request_Status__c != 'In Effect'){
                        InEffectSteps += '-in first update';
                        tpaMapToUpdate.put(agg.Id, objTpaRequest); 
                    }
                    if(tpaMapToUpdate.get(agg.Id) == null && agg.Request_Status__c == 'In Effect' && (isCurrentAttAMA || isCurrentAttTPATechLicense)){
                        InEffectSteps += '-in second update';
                        UTL_TPA.modifyRequestForcefully = true;
                        tpaMapToUpdate.put(agg.Id, new TPA_Request__c(id = agg.Id,After_in_Effect_Changes__c = true)); 
                    }
                }
                Boolean allCompleted = true,recordsPresent = false;
                Boolean isOtherUseorOffshoreSelected = false;
                if(!agg.is_Bulk_TPA_Request__c || (agg.is_Bulk_TPA_Request__c && UTL_TPA.tpaSetting.Enable_Comm_Auto_for_Bulk_Requests__c)){
                    for(TPA_Commercial_Review__c comRev : agg.TPA_Commercial_Reviews__r){
                        if(comRev.Status__c == null || (comRev.Status__c != null && !comRev.Status__c.contains('Combination Approved') && !comRev.Status__c.contains('Combination Approved and Future Approved') && comRev.Status__c != 'Complete' )){
                            allCompleted = false;
                        }
                        if(comRev.Manual_Review_Reason__c != null && (comRev.Manual_Review_Reason__c.contains('offshore') || comRev.Manual_Review_Reason__c.contains('Other Use Selected'))){
                            isOtherUseorOffshoreSelected = true;
                        }
                        recordsPresent = true;
                    }
                }
                /*else{
                allCompleted = false;
                }*/
                try
                {
                    if(agg.attachments.size() > 0 )
                    {
                        Boolean isTLLAAttached = false;
                        Boolean isMergedTLLAAttached = false;
                        Boolean isAMAAttached = false; 
                        Boolean isAMAAttachment = false; 
                        Boolean isAddendumAttached = false;
                        Boolean isHelpfulHintAttached = false;
                        Boolean holdForAMAFeeConfirmation = false; 
                        Boolean isVSNAckAlready = tpaAgreementAdditionalFieldData!= null && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c != Null && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c != '' && tpaAgreementAdditionalFieldData.Vendor_Specific_Notification_Response__c.contains('Acknowledge');
                        
                        
                        for(Attachment a : agg.attachments)
                        {
                            if(a.Createddate >= agg.Vendor_App_Submitted__c)
                            {
                                isAMAAttachment = a.Name.indexOf('AMA_') == 0 && a.Name.indexOf('TPA-') != -1 && a.name.indexOf('Foreign License') == -1;
                                
                                if(isAddendumAttached && a.Name.indexOf('Addendum') != -1 && a.Name.indexOf('TPA-') != -1 && a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) == -1) {
                                    continue;
                                }
                                if(isTLLAAttached && a.Name.indexOf('TLLA') != -1 &&  (a.Description == null || a.Description.indexOf('Merged') < 0)) {
                                    continue;
                                }
                                if(isMergedTLLAAttached && a.Name.indexOf('TLLA') != -1 && a.Description != null && a.Description.indexOf('Merged') > -1){
                                    continue;
                                }
                                if(isHelpfulHintAttached && a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1) {
                                    continue;
                                }
                                if(sendAfterInvoiceForAMA && !invoiceMailSent && amaAgreement!= null && amaAgreement.Is_AMA_License_Required__c && amaAgreement.Current_Year_Fees__c >0 && (amaAgreement.Contract_Type__c == 'Service Bureau II' || amaAgreement.Contract_Type__c == 'Contract Sales Force') && !amaAgreement.Billed_in_Advance__c)
                                {
                                    List<String> toAddress = new List<String>();
                                    sendAfterInvoiceForAMA = false;
                                    if(String.isNotBlank(agg.Authorized_Signer_Email__c) && String.isNotBlank(agg.Vendor_Contact_e_mail__c) && !agg.Authorized_Signer_Email__c.equalsIgnoreCase(agg.Vendor_Contact_e_mail__c))
                                    {
                                        toAddress.add(agg.Authorized_Signer_Email__c);
                                        toAddress.add(agg.Vendor_Contact_e_mail__c);
                                    }
                                    else {
                                        if(String.isNotBlank(agg.Vendor_Contact_e_mail__c)){
                                            toAddress.add(agg.Vendor_Contact_e_mail__c);
                                        }
                                        else{
                                            toAddress.add(agg.Authorized_Signer_Email__c);
                                        }
                                    }
                                    addAMAFeeInvoicedConfirmationMail(amaAgreement, toAddress, agg);
                                }
                                
                                if(AMAPatternBeforeSign.matcher(a.Name).matches() && a.name.indexOf('Foreign License') == -1 && amaAgreement!= null && amaAgreement.Is_AMA_License_Required__c && (String.isBlank(amaAgreement.Vendor_AMA_Fee_Response__c)) && (amaAgreement.Current_Year_Fees__c > 0 || amaAgreement.Next_Year_Fees__c > 0 ) && (amaAgreement.Contract_Type__c == 'Service Bureau II' || amaAgreement.Contract_Type__c == 'Contract Sales Force') ) {                                
                                    holdForAMAFeeConfirmation = true;
                                }
                                if(isAMAAttached && isAMAAttachment  && amaAgreement!= null && !amaAgreement.AMA_Manual_Review__c && amaAgreement.Is_AMA_License_Required__c)
                                {
                                    continue;
                                }
                                if(a.Name.indexOf('Use Definition') != -1) {
                                    continue;
                                }
                                
                                if(a.Name.indexOf('TLLA') != -1){
                                    isTLLAAttached = true;
                                }
                                if(a.Name.indexOf('TLLA') != -1 && a.Description != null && a.Description.indexOf('Merged') > -1){
                                    isMergedTLLAAttached = true;
                                }
                                if(a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) != -1){
                                    isHelpfulHintAttached = true;
                                }
                                if(a.Name.indexOf('Addendum') != -1 && a.Name.indexOf('TPA-') != -1 && a.Name.indexOf(UTL_TPA.helpfulHintsDocLabel) == -1){
                                    isAddendumAttached = true;
                                }
                                if(isAMAAttachment  && amaAgreement!= null && !amaAgreement.AMA_Manual_Review__c && (amaAgreement.Is_AMA_License_Required__c || amaAgreement.Is_Offshore_Access_Amendment_Required__c))
                                {
                                    isAMAAttached = true;
                                }
                            }
                        }
                        TPA_Request__c objRequestStatus = tpaMapToUpdate.get(agg.id);
                        
                        if( isTLLAAttached && isCurrentAttAMA
                           && ( agg.Request_Status__c == 'In Auto Approval Process'
                               || agg.Request_Status__c ==  Label.TPA_In_Review_By_IMS_Status
                               || agg.Request_Status__c ==  Label.TPA_In_Review_By_IQVIA_Status
                               || agg.Request_Status__c ==  'TPA Approved Awaiting AMA Approval') 
                           &&  holdForAMAFeeConfirmation)
                        {
                            InEffectSteps += '-in First If';
                            agg.Is_Contract_Generated__c = false;
                            objRequestStatus.TPA_Request_Temporary_Status__c = agg.Request_Status__c;
                            agg.Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
                            if(agg.Pending_Acknowledgements__c == null || agg.Pending_Acknowledgements__c == ''){
                                agg.Pending_Acknowledgements__c =  'AMA Fee Acknowledgement' ;
                            }
                            else if(agg.Pending_Acknowledgements__c.indexOf('AMA Fee Acknowledgement') == -1){
                                agg.Pending_Acknowledgements__c = agg.Pending_Acknowledgements__c + ';AMA Fee Acknowledgement' ;
                            }
                            update agg;
                            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                               FALSE, 
                                                                                               UTL_LogFactory.GUID, 
                                                                                               'Check: Hold For AMA Fee Confirmation', 
                                                                                               'TPA', 
                                                                                               'Custom', 
                                                                                               'INFO', 
                                                                                               ':::TGRH_TPAAttachment:::OnAfterInsert: Contact Generated not true check', 
                                                                                               (agg.Id != null) ? agg.Id : ''));
                            
                            List<String> toAddress = new List<String>();
                            if(String.isNotBlank(agg.Authorized_Signer_Email__c) && String.isNotBlank(agg.Vendor_Contact_e_mail__c) && !agg.Authorized_Signer_Email__c.equalsIgnoreCase(agg.Vendor_Contact_e_mail__c))
                            {
                                toAddress.add(agg.Authorized_Signer_Email__c);
                                toAddress.add(agg.Vendor_Contact_e_mail__c);
                            }
                            else{
                                if(String.isNotBlank(agg.Vendor_Contact_e_mail__c)){
                                    toAddress.add(agg.Vendor_Contact_e_mail__c);
                                }
                                else{
                                    toAddress.add(agg.Authorized_Signer_Email__c);
                                }
                            }
                            addAMAFeeInvoicedBeforeSignConfirmationMail(amaAgreement, toAddress, agg);
                        }
                        else if(((!agg.Requires_Manual_Review__c && agg.Request_Status__c == 'In Auto Approval Process')
                                 || (allCompleted && recordsPresent && !isOtherUseorOffshoreSelected && agg.Request_Status__c == 'In Review by IQVIA' && SRV_TPA_TPARequest.isReqReadyForSignatures(agg)))
                                &&   !isCurrentAttTLLA && (!agg.Exhibit_Page_Required__c || isMergedTLLAAttached )  && !isCurrentAttMergedTLLA && !isCurrentMergedAddHoc && isTLLAAttached && isHelpfulHintAttached && (!isAddendumAttReq || (isAddendumAttReq && isAddendumAttached))
                                &&   (   amaAgreement == null
                                      ||     (   !isAMAAttached
                                              &&     amaAgreement != null
                                              &&     (   !amaAgreement.Is_AMA_License_Required__c && !amaAgreement.Is_Offshore_Access_Amendment_Required__c && !amaAgreement.AMA_Manual_Review__c
                                                     )
                                             )
                                      ||     (   amaAgreement!= null
                                              &&     (!amaAgreement.AMA_Manual_Review__c || (allCompleted && recordsPresent && !isOtherUseorOffshoreSelected))
                                              && (amaAgreement.Is_AMA_License_Required__c || amaAgreement.Is_Offshore_Access_Amendment_Required__c)
                                              &&     isAMAAttached && !isCurrentAttHelpfulHint 
                                             )
                                     )
                               ) 
                        {
                            InEffectSteps += '-in Second If';
                            agg.Is_Contract_Generated__c = true;
                            objRequestStatus.TPA_Request_Temporary_Status__c = 'In Docusign Auto Process';
                            Task t1 = new Task( WhatId = objRequestStatus.id, ActivityDate = system.today(), Status = 'Completed',
                                               Subject = 'Status Changes to In Docusign Auto Process', CallObject = 'Status Changes to In Batch Process' );
                            lstTaskInsert.add(t1);
                            update agg;
                            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                               FALSE, 
                                                                                               UTL_LogFactory.GUID, 
                                                                                               'Check: After Vendor Submit', 
                                                                                               'TPA', 
                                                                                               'Custom', 
                                                                                               'INFO', 
                                                                                               ':::TGRH_TPAAttachment:::OnAfterInsert: Request: Contact Generated true check', 
                                                                                               (agg.Id != null) ? agg.Id : ''));
                            
                        }
                        else {
                            InEffectSteps += '-in Else If';
                            if(!agg.Request_Status__c.equalsIgnoreCase('Pending Vendor AMA Fee Acknowledgement') && !agg.Request_Status__c.equalsIgnoreCase('Pending - Vendor Declined AMA Fees') && objRequestStatus != null){
                                objRequestStatus.TPA_Request_Temporary_Status__c = agg.Request_Status__c;
                            }
                            if(isCurrentAttTLLA  
                               && agg.Request_Status__c ==  Label.TPA_In_Review_By_IQVIA_Status 
                               && objTpaRequest.is_VSN_Selected__c
                               && !holdForAMAFeeConfirmation
                               && !isVSNAckAlready) 
                            {
                                objTpaRequest.Is_VSN_Acknowlege_By_Client__c = true;
                                InEffectSteps += '-in VSN Condition';
                                tpaMapToUpdate.put(agg.Id, objTpaRequest);
                            }
                            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                               FALSE, 
                                                                                               UTL_LogFactory.GUID, 
                                                                                               'Check: After Vendor part Submit', 
                                                                                               'TPA', 
                                                                                               'Custom', 
                                                                                               'INFO', 
                                                                                               ':::TGRH_TPAAttachment:::OnAfterInsert: Request: Contact Generated not true check', 
                                                                                               (agg.Id != null) ? agg.Id : ''));
                        }
                        UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);
                    }
                }
                catch( Exception ex)
                {
                    UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                       FALSE, 
                                                                                       UTL_LogFactory.GUID, 
                                                                                       'Check Exception: Contact Generated True Exception. Line# - ' + ex.getLineNumber(), 
                                                                                       'TPA', 
                                                                                       'Exception', 
                                                                                       'ERROR', 
                                                                                       ':::TGRH_TPAAttachment:::OnAfterInsert: ' + ex.getMessage(), 
                                                                                       (agg.Id != null) ? agg.Id : ''));
                    UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);    
                }
            }
        }
        
        if(tpaMapToUpdate.size() > 0) {
            try {
                update tpaMapToUpdate.values();
                UTL_TPA.modifyRequestForcefully = false;
            }
            catch(Exception ex) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                    FALSE, 
                                                                                    UTL_LogFactory.GUID, 
                                                                                    'Check Exception: Line# - ' + ex.getLineNumber(), 
                                                                                    'TPA', 
                                                                                    'Exception', 
                                                                                    'ERROR', 
                                                                                    ':::TGRH_TPAAttachment:::OnAfterInsert: ' + ex.getMessage() + InEffectSteps, 
                                                                                    tpaMapToUpdate.values()[0].Id));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);    
            }
        }
        if(lstTaskInsert.size()  > 0){
            upsert lstTaskInsert;
        }
        lstAttachmentDeleted = [select id,name from Attachment where id in:  stAttIds];
        if(lstAttachmentDeleted !=null && lstAttachmentDeleted.size() > 0){
            delete lstAttachmentDeleted;
        }
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            }
        } catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, FALSE, UTL_LogFactory.GUID, 'Check Exception: Contact Generated True Exception. Line# - ' + ex.getLineNumber(), 'TPA', 'Exception', 'ERROR', ':::TGRH_TPAAttachment:::OnAfterInsert:::AMA Confirmation mail not sent ' + ex.getMessage(), null));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);
        }
        List<Attachment> attchsToDelete = new List<Attachment>();
        for(Attachment att:newAttachments) {
            if(att.name.indexOf(', Signature Request for')!= -1 || att.name.indexOf('への署名の依頼')!= -1) {
                attchsToDelete.add(new Attachment(Id = att.Id));
            }
        }
        try{
            delete attchsToDelete;
        }
        catch(Exception ex) {
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog( FALSE, 
                                                                                FALSE, 
                                                                                UTL_LogFactory.GUID, 
                                                                                'Check Exception: Line# - ' + ex.getLineNumber(), 
                                                                                'TPA', 
                                                                                'Exception', 
                                                                                'ERROR', 
                                                                                ':::TGRH_TPAAttachment:::OnAfterInsert: ' + ex.getMessage(), 
                                                                                null));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), FALSE);    
        }
    }
    
    
    public void addAMAFeeInvoicedConfirmationMail(AMA_Agreement_Detail__c  amaAgreement, List<String> toAddress, TPA_Request__c tpaRequest)
    { 
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();

        List<String> ccTo = new List<String>();

        if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c))
        {
            ccTo = tpaCustomSettings.TP_US_Mail_Id__c.split(',');
            
            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)){
                List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
                ccTo.addAll(addCCTo);
            }
            
            if(String.isNotBlank(amaAgreement.Invoice_Contact_Email__c)) {
                ccTo.add(amaAgreement.Invoice_Contact_Email__c);
            }
            
            if(amaAgreement.TPA_Request__r.ClientContact__r.email != null){
                ccTo.add(amaAgreement.TPA_Request__r.ClientContact__r.email);
            }
            if(amaAgreement.TPA_Request__r.Client_TPA_Representative_Email__c != null && amaAgreement.TPA_Request__r.Client_TPA_Representative_Email__c != ''){
                ccTo.add(amaAgreement.TPA_Request__r.Client_TPA_Representative_Email__c);
            }
            if(tpaRequest.Owner.Type != null && tpaRequest.Owner.Type == 'Queue' && tpaRequest.Owner.Email != null){
                ccTo.add(tpaRequest.Owner.Email);
            }
            
            List<TPA_Contact__c> tpaContactsList = SRV_TPA_TPARequest.getContactsForRequest(amaAgreement.TPA_Request__c);
            if(tpaContactsList!= null && tpaContactsList.size() > 0){
                for(TPA_Contact__c tpaContact : tpaContactsList){
                    if(tpaContact.Type__c == 'Additional Client Contact' || tpaContact.Type__c == 'Additional Contact' ){
                        ccTo.add(tpaContact.Email__c);
                    }
                }
            }

            if (tpaRequest.Client_Address__r.TPAOtherEmailIds__c != null) {
                UTL_TPA_Multilingual.ccList(tpaRequest.Client_Address__r.TPAOtherEmailIds__c, ccTo);
            }
        }
        
        if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
	       List<String> bccTo = new List<String>();
	       bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
	    }
        
        String templateId = amaSetting.get(0).Fees_Invoice_Confirm_after_sign_template__c;

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
        	SRV_TPA_TPARequest.assignedTPProcessorName = amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/

        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgreement.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
        
        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
        
    }
    
    public void OnBeforeUpdate(Attachment[] oldAttachments, Attachment[] updatedAttachments, Map<ID, Attachment> attachmentMap, Map<Id, Attachment> oldAttachmentMap){
        List<id> parentOfAtt = new List<id>();
        for(Attachment att:updatedAttachments){
            parentOfAtt.add(att.ParentId);
        }
        
        for(TPA_Request__c agg : [select id,Requires_Manual_Review__c,Secondary_Client_Contact_Territory__c,Is_Contract_Generated__c,Data_Access_Start_Date__c
                                  , Service_Provider_Name__c,Client_Address__r.Name,Client_Address__r.Region_Territory__c
                                  , Check_Use_Definition_Extension__c, Client_Off_Notification_Ack_Date__c
                                  , Vendor_Off_Notification_Ack_Date__c, is_Addendum_Attachment_Required__c
                                  ,Vendor_Billing_Mailing_Country__c, Agreement_Name__c 
                                  ,Name,Client_Contact_Territory__c from TPA_Request__c where id IN : parentOfAtt]) 
        {
        
            for(Attachment att: updatedAttachments){
                if(listTemplates == null) {
                    listTemplates = [Select Id, Name, Apttus__Keywords__c FROM Apttus__APTS_Template__c WHERE Apttus__Keywords__c IN ('AMA Agreement', 'TPA Agreement', 'TPSA', 'Use Defination') AND Apttus__IsActive__c = TRUE];
                }
                if(listTemplates != null) {
                    for(Apttus__APTS_Template__c objApttusTemplate: listTemplates) {
                        if(att.Name.indexOf(agg.Name + '_' + objApttusTemplate.Name) != -1 && oldAttachmentMap.get(att.Id) != null && oldAttachmentMap.get(att.Id).Name != att.Name) {
                            att.Name = oldAttachmentMap.get(att.Id).Name;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    public void OnAfterUpdate(Attachment[] oldAttachments, Attachment[] updatedAttachments, Map<ID, Attachment> oldMap,Map<ID, Attachment> newMap){
        List<id> parentOfatt = new List<id>();
        Map<Id,Attachment> mapAgreeIdWithAttachmentObj = new Map<Id,Attachment>();
        for(Attachment att:updatedAttachments) {
            if(oldMap.get(att.id).name != newMap.get(att.id).name) {
                parentOfatt.add(att.ParentId);
                mapAgreeIdWithAttachmentObj.put(att.ParentId, att);
            }
            
        }
        for(TPA_Request__c agg : [select id, Is_Contract_Generated__c, Requires_Manual_Review__c,Vendor_Off_Notification_Ack_Date__c, Client_Off_Notification_Ack_Date__c, Vendor_App_Submitted__c, (select id , name, createdDate from attachments), (Select id, Contract_Type__c, Is_AMA_License_Required__c, AMA_Manual_Review__c from AMA_Agreement_Details__r), Is_Document_Generated__c,Upload_Client_Document_Check__c, name, Service_Provider_Name__c from TPA_Request__c where id IN : parentOfatt])
        {
            
            String userTimeZone = null;
            User currentUser = UTL_TPA.getCurrentUserDetails();
            if(currentUser != null ){
                userTimeZone = currentUser.TimeZoneSidKey;
            }
            String strConvertedDate = System.now().format('MM/dd/yyyy hh:mm a',userTimeZone);
            Attachment objAttach = mapAgreeIdWithAttachmentObj.get(agg.id);
            if(objAttach != null){
               SRV_TPA_TPARequest.updateActivityHistory(agg.Id, objAttach.Name+' updated by '+userInfo.getName()+' on '+strConvertedDate, true);
            }
        }
    }

    public void OnAfterDelete(Attachment[] deletedAttachments, Map<ID, Attachment> attachmentMap){
        List<Id> aggList=new List<Id>();
        for(Attachment att:deletedAttachments) {
            aggList.add(att.ParentId);
        }
        Map<Id,TPA_Request__c> parentMap=new Map<Id,TPA_Request__c>();
        List<Attachment> attList=new List<Attachment>();
        if(parentMap!=Null) {
            for(Attachment att:[Select id,parentId from Attachment where parentId IN:parentMap.keySet()]) {
                if(parentMap.get(att.parentId).MasterAttachmentsIDs__c!=Null) {
                    if(parentMap.get(att.parentId).MasterAttachmentsIDs__c.contains(att.Id)) {
                        attList.add(att);
                    }
                }
            }
        }
        
        if(attList.size()>0) {
            delete attList;
        }
    }
    
    public void addAMAFeeInvoicedBeforeSignConfirmationMail(AMA_Agreement_Detail__c  amaAgreement, List<String> toAddress, TPA_Request__c tpaRequest)
    {
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        List<String> ccTo = new List<String>();
        
        if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c)) {
            ccTo = tpaCustomSettings.TP_US_Mail_Id__c.split(',');
            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)) {
                List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
                ccTo.addAll(addCCTo);
            }
        }
        
        if(String.isNotBlank(tpaCustomSettings.TPA_BCC_Emails__c)) {
           List<String> bccTo = new List<String>();
           bccTo.addAll(tpaCustomSettings.TPA_BCC_Emails__c.split(';'));
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
           SRV_TPA_TPARequest.assignedTPProcessorName = amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
        }*/
         
        SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Fees_Invoice_Confirm_BeforeSign_Template__c, amaAgreement.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);

        //SRV_TPA_TPARequest.addTPProcessorInitials = false;
    }
}
