global class BCH_TPA_Vendor_Off_Return_Ack implements Database.Batchable<sObject>,Database.Stateful {
    Date todayDate;
    List<TPA_AMA_Settings__c> amaSetting;
    public Map<ID,TPA_Master_Extension_Information__c> mapAddressIdWithAddressExtension = new Map<ID,TPA_Master_Extension_Information__c>();
    public Map<ID,List<TPA_Request__c>> mapAddressIdWithRequestLst = new Map<ID,List<TPA_Request__c>>();
    public List<Watch_List_History__c> watchHistories = new List<Watch_List_History__c>();
    public Map<ID,List<TPA_Request__c>> mapVendorIdWithRequestLst = new Map<ID,List<TPA_Request__c>>();
    public Map<ID,ID> mapRequestwithVendor = new Map<ID,ID>();
    public Map<ID,String> mapRequestwitheNewStatus = new Map<ID,String>();
    
    public Boolean includeTestDataOnly {
        get {
            if(includeTestDataOnly == null) {
                includeTestDataOnly = false;
            }
            return includeTestDataOnly;
        }
        set;
    }
    
    global BCH_TPA_Vendor_Off_Return_Ack() {
         todayDate = Date.today();
         amaSetting = TPA_AMA_Settings__c.getall().values();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String amaCancelationStatus = amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c;
        
        String query = 'Select id from TPA_Request__c where ( Request_Status__c IN ( \'Expired\', \'AMA Discontinued\', \'AMA Discontinued\', \'AMA Cancelled\', \'Client Discontinued\', ' + '\'' +amaCancelationStatus + '\''+ ') ) and Is_Submitted__c = true and (Is_Renewed__c = false OR (Is_Renewed__c =true AND Renewed_As__r.Request_Status__c =  ' + '\'cancelled\'' + ') OR (Is_Renewed__c =true AND Renewed_As__r.Is_Partially_Renewed__c = true)) and In_Effect_Date__c != null  and CreatedDate = LAST_N_DAYS:1095 and id not in (select TPA_Request__c from Vendor_Offering_Return_Acknowledgment__c)';
        
        if(includeTestDataOnly) {
            query += ' and (Client_Address__r.Name Like \'Test_'+'%\'  OR Service_Provider_f__c Like \'Test_'+'%\' )';
        }

        if(Test.isRunningTest()) {
            query += ' limit 10';
        }

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> objList) {
        List<string> toRecipients = new List<String>();
        List<string> ccRecipients = new List<String>();
        List<TPA_Request__c> requestToBeUpdated = new List<TPA_Request__c>();
        map<Id, Integer> requestDayDiffMap = new map<Id, Integer>();
        List<TPA_Request__c> requestsOnHold = new List<TPA_Request__c>();

        String preferredLanguage = 'English';
        String emailTemplateId = '';
        String excludedOfferings = '';

        Set<Id> setRequestID = new Set<Id>();

        for(sobject sobj : objList) {
            TPA_Request__c objRequest = (TPA_Request__c)sobj ;
            setRequestID.add(objRequest.id);
        }

        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>();
        List<Id> renewedTpaRequestList = new List<Id>();
        
        String query = 'Select id, Service_Provider_Address__c, Service_Provider_Address__r.Parent_Vendor_Name__c, Service_Provider_Address__r.Primary_Vendor_Address__c, Renewed_As__c, Renewed_As__r.Is_Partially_Renewed__c,Renewed_As__r.Partially_Renewed_Date__c, Service_Provider_Contact_f__c, Vendor_Contact_e_mail__c, Vendor_Compliance_Email__c, Is_TPA_Send_DDN_Button_Enabled__c, Early_Contract_Expiry_Date__c, Is_DDN_Pending_Request__c, Client_Address__c, Client_Address__r.Name, Service_Provider_f__c,  Renewed_As__r.Cancelled__c,  Service_Provider_Address__r.id, Service_Provider_Address__r.Parent_Vendor_Name__r.id, Renewed_As__r.Request_Status__c, Client_First_Name__c,Expired_Date__c,vendor_language__c, name, request_termination_time__c,Request_Status__c, Vendor_e_mail__c, Authorized_Signer_Email__c, TP_Processor_Email__c, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, ClientContact__r.Email, Owner.Type, Owner.Email, Client_TPA_Representative_Email__c, (select id, Email__c,type__c from TPA_Request_Contacts__r),  (select id, Name, Early_Contract_Expiry_Date__c from TPA_Agreement_Additional_Fields__r), data_access_end_date__c from TPA_Request__c where Id IN :setRequestID'; 
        
        if(Test.isRunningTest()) {
            query += ' limit 10';
        }

        tpaRequestList = (List<TPA_Request__c>) Database.query(query);        

        for(TPA_Request__c reqObj : tpaRequestList) {
            if(reqObj.Renewed_As__c != null && reqObj.Renewed_As__r.Is_Partially_Renewed__c) {
                renewedTpaRequestList.add(reqObj.Renewed_As__c);
            }
        }

        Map<Id, TPA_Agreement_Additional_Field__c> tpaRequestWithAggAdditionalFirldsmap = new Map<Id, TPA_Agreement_Additional_Field__c>();
        if(renewedTpaRequestList.size() > 0) {
            for(TPA_Agreement_Additional_Field__c tpaAggAddiField : [Select id, Excluded_Offerings_In_Renewal__c, Related_TPA_Request__c FROM TPA_Agreement_Additional_Field__c Where Related_TPA_Request__c In : renewedTpaRequestList]) {
                tpaRequestWithAggAdditionalFirldsmap.put(tpaAggAddiField.Related_TPA_Request__c, tpaAggAddiField);
            }
        }
		
        for(TPA_Request__c requestObj : tpaRequestList) {	
            excludedOfferings = '';
            if(requestObj.Renewed_As__c != null && requestObj.Renewed_As__r.Is_Partially_Renewed__c) {
                TPA_Agreement_Additional_Field__c tpaRenewedReqAgrAddFieldsRec = tpaRequestWithAggAdditionalFirldsmap.get(requestObj.Renewed_As__c);
            
                if(tpaRenewedReqAgrAddFieldsRec != null && !UTL_Validate.isEmptyOrNull(tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c)) {
                    excludedOfferings = tpaRenewedReqAgrAddFieldsRec.Excluded_Offerings_In_Renewal__c;
                }
            }
            
            preferredLanguage = requestObj.vendor_language__c != null ? requestObj.vendor_language__c : 'English';
            
            toRecipients = new List<String>();
            ccRecipients = new List<String>();
            
            toRecipients.add(requestObj.Vendor_e_mail__c);
            if(requestObj.Vendor_e_mail__c != requestObj.Authorized_Signer_Email__c) {
                toRecipients.add(requestObj.Authorized_Signer_Email__c);
            }
       
            Integer dayDiff = 0;
            Date statusExpiryDate;
            Boolean isEarlyExpired = false;
            Boolean isRenewedReqCancelled = false;
            DateTime DateBefore90DayofDDNReqDeployemnt = UTL_TPA.NewDDNReqDeploymentDate != null ? UTL_TPA.NewDDNReqDeploymentDate.addDays(-90) : null;
            if(requestObj.Expired_Date__c != null) {
                DateTime earlyExpireDateTime;
                if(requestObj.Early_Contract_Expiry_Date__c != null) {
                    earlyExpireDateTime = requestObj.Early_Contract_Expiry_Date__c;
                }
                if(earlyExpireDateTime != null) {
                    if(requestObj.Renewed_As__c != null 
                       && requestObj.Renewed_As__r.Request_Status__c == 'cancelled' 
                       && requestObj.Renewed_As__r.Cancelled__c >= earlyExpireDateTime) {
                           isRenewedReqCancelled = true;
                           DateTime cancelledDate = requestObj.Renewed_As__r.Cancelled__c;
                           statusExpiryDate = date.newinstance(cancelledDate.year(), cancelledDate.month(), cancelledDate.day());
                       } else if(requestObj.Renewed_As__c != null 
                                 && requestObj.Renewed_As__r.Request_Status__c != 'cancelled'
                                 && requestObj.Renewed_As__r.Is_Partially_Renewed__c
                                 && requestObj.Renewed_As__r.Partially_Renewed_Date__c != null
                                 && requestObj.Renewed_As__r.Partially_Renewed_Date__c >= earlyExpireDateTime) {
                                     DateTime partiallyRenewedDate = requestObj.Renewed_As__r.Partially_Renewed_Date__c;
                                     statusExpiryDate = date.newinstance(partiallyRenewedDate.year(), partiallyRenewedDate.month(), partiallyRenewedDate.day());  
                                 } else {
                                     statusExpiryDate = date.newinstance(earlyExpireDateTime.year(), earlyExpireDateTime.month(), earlyExpireDateTime.day());
                                 }
                    statusExpiryDate = statusExpiryDate.addDays(-11);
                    dayDiff = statusExpiryDate.daysBetween(todayDate);
                    if(requestObj.Request_Status__c.equalsIgnoreCase(UTL_TPA.EXPIRED)) {
                        isEarlyExpired = true;
                    }
                }
                else {
                    if(requestObj.Renewed_As__c != null 
                       && requestObj.Renewed_As__r.Request_Status__c == 'cancelled'
                       && requestObj.Renewed_As__r.Cancelled__c >= requestObj.Expired_Date__c) {
                           isRenewedReqCancelled = true;
                           DateTime cancelledDate = requestObj.Renewed_As__r.Cancelled__c;
                           statusExpiryDate = date.newinstance(cancelledDate.year(), cancelledDate.month(), cancelledDate.day());
                       } else if(requestObj.Renewed_As__c != null 
                                 && requestObj.Renewed_As__r.Request_Status__c != 'cancelled'
                                 && requestObj.Renewed_As__r.Is_Partially_Renewed__c
                                 && requestObj.Renewed_As__r.Partially_Renewed_Date__c != null
                                 && requestObj.Renewed_As__r.Partially_Renewed_Date__c >= requestObj.Expired_Date__c) {
                                     DateTime partiallyRenewedDate = requestObj.Renewed_As__r.Partially_Renewed_Date__c;
                                     statusExpiryDate = date.newinstance(partiallyRenewedDate.year(), partiallyRenewedDate.month(), partiallyRenewedDate.day());  
                                 } else {
                                     DateTime statusExpiredDateTime = requestObj.Expired_Date__c;
                                     statusExpiryDate = date.newinstance(statusExpiredDateTime.year(), statusExpiredDateTime.month(), statusExpiredDateTime.day());
                                 }
                    dayDiff = statusExpiryDate.daysBetween(todayDate);
                }
            }
            
            Integer terminationDayDiff = 0;
            Date statusTerminationDate;
            if(requestObj.request_termination_time__c != null) {                
                if(requestObj.Renewed_As__c != null 
                   && requestObj.Renewed_As__r.Request_Status__c == 'cancelled'
                   && requestObj.Renewed_As__r.Cancelled__c >= requestObj.request_termination_time__c) {
                       isRenewedReqCancelled = true;
                       DateTime cancelledDate = requestObj.Renewed_As__r.Cancelled__c;
                       statusTerminationDate = date.newinstance(cancelledDate.year(), cancelledDate.month(), cancelledDate.day());
                   } else if(requestObj.Renewed_As__c != null 
                             && requestObj.Renewed_As__r.Request_Status__c != 'cancelled'
                             && requestObj.Renewed_As__r.Is_Partially_Renewed__c
                             && requestObj.Renewed_As__r.Partially_Renewed_Date__c != null
                             && requestObj.Renewed_As__r.Partially_Renewed_Date__c >= requestObj.request_termination_time__c) {
                                 DateTime partiallyRenewedDate = requestObj.Renewed_As__r.Partially_Renewed_Date__c;
                                 statusTerminationDate = date.newinstance(partiallyRenewedDate.year(), partiallyRenewedDate.month(), partiallyRenewedDate.day());  
                             } else {
                                 DateTime statusTerminationDateTime = requestObj.request_termination_time__c;
                                 statusTerminationDate = date.newinstance(statusTerminationDateTime.year(), statusTerminationDateTime.month(), statusTerminationDateTime.day());
                             }
                terminationDayDiff = statusTerminationDate.daysBetween(todayDate);
            }
            
            Integer dayDiffToDisplayInActivity = (requestObj.request_status__c == 'Expired'?dayDiff:terminationDayDiff);
            Boolean isExpired = requestObj.Request_Status__c == 'Expired';
            Boolean isCancelledOrDiscontinued = (requestObj.Request_Status__c == 'AMA Cancelled' || requestObj.Request_Status__c == 'AMA Discontinued' || requestObj.Request_Status__c == 'Client Discontinued' || requestObj.Request_Status__c == amaSetting.get(0).Vendor_Renewal_Cancelation_Status__c);
            
            if((requestObj.Service_Provider_f__c != null && requestObj.Service_Provider_f__c.containsIgnoreCase('Test_')) || (requestObj.Client_Address__c !=null && requestObj.Client_Address__r.Name.containsIgnoreCase('Test_'))) {
                if(isEarlyExpired) {
                    dayDiffToDisplayInActivity = dayDiffToDisplayInActivity-10; 
                }
                
                if((dayDiff == 1 && isExpired) || (terminationDayDiff == 1 && isCancelledOrDiscontinued)) {
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(requestObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = requestObj.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    
                    if((requestObj.Renewed_As__c != null && requestObj.Renewed_As__r.Is_Partially_Renewed__c && requestObj.Renewed_As__r.Request_Status__c != 'Cancelled')){
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA DDN Partial Modify Email'+preferredLanguage).Translated_Template_Id__c;
                    }else{
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Ack of DD'+preferredLanguage).Translated_Template_Id__c;
                        if(requestObj.Vendor_Compliance_Email__c != null){
                            ccRecipients.add(requestObj.Vendor_Compliance_Email__c);
                        }
                    }
                    sendMail(requestObj, toRecipients, ccRecipients, emailTemplateId, dayDiffToDisplayInActivity, isRenewedReqCancelled, excludedOfferings); 
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;

                }
                else if((dayDiff >= 2 && dayDiff<= 5  && isExpired) || (dayDiff >= 12 && dayDiff<= 15  && isEarlyExpired) ||(terminationDayDiff >= 2 && terminationDayDiff<=5 && isCancelledOrDiscontinued)) {
                    ccRecipients.add(requestObj.ClientContact__r.Email);
                    if(requestObj.Client_TPA_Representative_Email__c != null && requestObj.Client_TPA_Representative_Email__c != ''){
                        ccRecipients.add(requestObj.Client_TPA_Representative_Email__c);
                    }
                    if(requestObj.Owner.Type != null && requestObj.Owner.Type == 'Queue' && requestObj.Owner.Email != null){
                        ccRecipients.add(requestObj.Owner.Email);
                    }
                    if(requestObj.TPA_Request_Contacts__r.size() > 0) {
                        for(TPA_Contact__c tpaCon : requestObj.TPA_Request_Contacts__r) {
                            ccRecipients.add(tpaCon.Email__c);
                        }
                    }
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(requestObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = requestObj.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    if((requestObj.Renewed_As__c != null && requestObj.Renewed_As__r.Is_Partially_Renewed__c && requestObj.Renewed_As__r.Request_Status__c != 'Cancelled')){
                        emailTemplateId =  UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA DDN Partial Modify Email'+preferredLanguage).Translated_Template_Id__c;
                    }else{
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email FollowUp of Ack DD'+preferredLanguage).Translated_Template_Id__c;
                        if(requestObj.Vendor_Compliance_Email__c != null){
                            ccRecipients.add(requestObj.Vendor_Compliance_Email__c);
                        }
                    }
                    sendMail(requestObj, toRecipients, ccRecipients, emailTemplateId, dayDiffToDisplayInActivity, isRenewedReqCancelled, excludedOfferings); 
                }
                else if((dayDiff == 6 && isExpired) || (dayDiff == 16  && isEarlyExpired )  || (terminationDayDiff == 6 && isCancelledOrDiscontinued)) { 
                    ccRecipients.add(requestObj.ClientContact__r.Email);
                    if(requestObj.Client_TPA_Representative_Email__c != null && requestObj.Client_TPA_Representative_Email__c != ''){
                        ccRecipients.add(requestObj.Client_TPA_Representative_Email__c);
                    }
                    if(requestObj.Owner.Type != null && requestObj.Owner.Type == 'Queue' && requestObj.Owner.Email != null){
                        ccRecipients.add(requestObj.Owner.Email);
                    }
                    if(requestObj.TPA_Request_Contacts__r.size() > 0) {
                        for(TPA_Contact__c tpaCon : requestObj.TPA_Request_Contacts__r) {
                            ccRecipients.add(tpaCon.Email__c);
                        }
                    }
                    ccRecipients.add(requestObj.TP_Processor_Email__c);
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(requestObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = requestObj.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    if((requestObj.Renewed_As__c != null && requestObj.Renewed_As__r.Is_Partially_Renewed__c && requestObj.Renewed_As__r.Request_Status__c != 'Cancelled')){
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA DDN Partial Modify Email'+preferredLanguage).Translated_Template_Id__c;
                    }else{
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email 3Day Notice of Ack DD'+preferredLanguage).Translated_Template_Id__c;
                        if(requestObj.Vendor_Compliance_Email__c != null){
                            ccRecipients.add(requestObj.Vendor_Compliance_Email__c);
                        }
                    }
                    sendMail(requestObj, toRecipients, ccRecipients, emailTemplateId, dayDiffToDisplayInActivity, isRenewedReqCancelled, excludedOfferings); 

                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                }
                else if(DateBefore90DayofDDNReqDeployemnt != null && ((statusExpiryDate != null && statusExpiryDate > DateBefore90DayofDDNReqDeployemnt)
                || (statusTerminationDate != null &&  statusTerminationDate > DateBefore90DayofDDNReqDeployemnt))) {
                    if((dayDiff > 7 && isExpired && !isEarlyExpired) 
                    || (dayDiff > 17  && isEarlyExpired ) 
                    || (terminationDayDiff > 7 && isCancelledOrDiscontinued)){
                        if(dayDiff > 7 && isEarlyExpired){
                            system.debug('In 7');
                            //addAddressExtensionRecord(requestObj, dayDiff-17);
                            requestDayDiffMap.put(requestObj.Id, dayDiff-17);
                        }
                        else if(dayDiff > 7 && isExpired && !isEarlyExpired){
                            system.debug('In 17');
                            //addAddressExtensionRecord(requestObj, dayDiff-7);
                            requestDayDiffMap.put(requestObj.Id, dayDiff-7);
                        }
                        else{
                            system.debug('In else');
                            //addAddressExtensionRecord(requestObj, terminationDayDiff-7);
                            requestDayDiffMap.put(requestObj.Id, terminationDayDiff-7);
                        }
                        requestsOnHold.add(requestObj);                        
                    }
                    if((dayDiff > 6 && isExpired) || (dayDiff > 16  && isEarlyExpired ) || (terminationDayDiff > 6 && isCancelledOrDiscontinued)){
                        if(!requestObj.Is_TPA_Send_DDN_Button_Enabled__c) {
                            requestObj.Is_TPA_Send_DDN_Button_Enabled__c = true;
                            requestToBeUpdated.add(requestObj);
                        }
                    }
                }
            }
            else {
                if((dayDiff == 10 && isExpired) || (terminationDayDiff == 10 && isCancelledOrDiscontinued)) {
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(requestObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = requestObj.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/

                    if((requestObj.Renewed_As__c != null && requestObj.Renewed_As__r.Is_Partially_Renewed__c && requestObj.Renewed_As__r.Request_Status__c != 'Cancelled')){
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA DDN Partial Modify Email'+preferredLanguage).Translated_Template_Id__c;
                    }else{
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email Ack of DD'+preferredLanguage).Translated_Template_Id__c;
                        if(requestObj.Vendor_Compliance_Email__c != null){
                            ccRecipients.add(requestObj.Vendor_Compliance_Email__c);
                        }
                    }
                    sendMail(requestObj, toRecipients, ccRecipients, emailTemplateId, dayDiffToDisplayInActivity, isRenewedReqCancelled, excludedOfferings);    
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                }
                else if((dayDiff >= 20 && dayDiff <= 30 && isExpired) || (terminationDayDiff >= 20 && terminationDayDiff <= 30 && isCancelledOrDiscontinued)) {
                    system.debug('20th -30th day');

                    if((dayDiff == 20 && isExpired) || (terminationDayDiff == 20 && isCancelledOrDiscontinued)) {
                        system.debug('20th  day');

                        ccRecipients.add(requestObj.ClientContact__r.Email);
                        if(requestObj.Client_TPA_Representative_Email__c != null && requestObj.Client_TPA_Representative_Email__c != ''){
                            ccRecipients.add(requestObj.Client_TPA_Representative_Email__c);
                        }
                        if(requestObj.Owner.Type != null && requestObj.Owner.Type == 'Queue' && requestObj.Owner.Email != null){
                            ccRecipients.add(requestObj.Owner.Email);
                        }
                        if(requestObj.TPA_Request_Contacts__r.size() > 0) {
                            for(TPA_Contact__c tpaCon : requestObj.TPA_Request_Contacts__r) {
                                ccRecipients.add(tpaCon.Email__c);
                            }
                        }
                    }

                    Integer noOfDays = math.mod((dayDiff), 3); 
                    Integer noOfDaysTermination = math.mod((terminationDayDiff), 3);
                    if((noOfDays == 2 && isExpired) || (noOfDaysTermination == 2 && isCancelledOrDiscontinued)) {
                        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                        if(requestObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                            SRV_TPA_TPARequest.assignedTPProcessorName = requestObj.TPA_Assigned_TP_Processor__r.Initials__c; 
                        }*/
                        if((requestObj.Renewed_As__c != null && requestObj.Renewed_As__r.Is_Partially_Renewed__c && requestObj.Renewed_As__r.Request_Status__c != 'Cancelled')){
                            emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA DDN Partial Modify Email'+preferredLanguage).Translated_Template_Id__c;
                        }else{
                            emailTemplateId =  UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email FollowUp of Ack DD'+preferredLanguage).Translated_Template_Id__c;
                            if(requestObj.Vendor_Compliance_Email__c != null){
                                ccRecipients.add(requestObj.Vendor_Compliance_Email__c);
                            }
                        } 
                        sendMail(requestObj, toRecipients, ccRecipients, emailTemplateId, dayDiffToDisplayInActivity, isRenewedReqCancelled, excludedOfferings);
                    }
                }
                else if((dayDiff == 31 && isExpired) || (terminationDayDiff == 31 && isCancelledOrDiscontinued)) {
                    system.debug('31st day');
                    ccRecipients.add(requestObj.ClientContact__r.Email);
                    if(requestObj.Client_TPA_Representative_Email__c != null && requestObj.Client_TPA_Representative_Email__c != ''){
                        ccRecipients.add(requestObj.Client_TPA_Representative_Email__c);
                    }
                    if(requestObj.Owner.Type != null && requestObj.Owner.Type == 'Queue' && requestObj.Owner.Email != null){
                        ccRecipients.add(requestObj.Owner.Email);
                    }
                    if(requestObj.TPA_Request_Contacts__r.size() > 0) {
                        for(TPA_Contact__c tpaCon : requestObj.TPA_Request_Contacts__r) {
                            ccRecipients.add(tpaCon.Email__c);
                        }
                    }
                    ccRecipients.add(requestObj.TP_Processor_Email__c);
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(requestObj.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.assignedTPProcessorName = requestObj.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    if((requestObj.Renewed_As__c != null && requestObj.Renewed_As__r.Is_Partially_Renewed__c && requestObj.Renewed_As__r.Request_Status__c != 'Cancelled')){
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('TPA DDN Partial Modify Email'+preferredLanguage).Translated_Template_Id__c;
                    }else{
                        emailTemplateId = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Email 3Day Notice of Ack DD'+preferredLanguage).Translated_Template_Id__c;
                        if(requestObj.Vendor_Compliance_Email__c != null){
                            ccRecipients.add(requestObj.Vendor_Compliance_Email__c);
                        }
                    }
                    sendMail(requestObj, toRecipients, ccRecipients, emailTemplateId, dayDiffToDisplayInActivity, isRenewedReqCancelled, excludedOfferings);

                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                }
                else if(DateBefore90DayofDDNReqDeployemnt != null && ((statusExpiryDate != null && statusExpiryDate > DateBefore90DayofDDNReqDeployemnt)
                || (statusTerminationDate != null &&  statusTerminationDate > DateBefore90DayofDDNReqDeployemnt))) {
                    if((dayDiff >= 90 && isExpired) || (terminationDayDiff >= 90 && isCancelledOrDiscontinued)) {
                        system.debug('After 90 days Condition');
                        if(dayDiff >= 90 && isExpired){
                            //addAddressExtensionRecord(requestObj, dayDiff-90);
                            requestDayDiffMap.put(requestObj.Id, dayDiff-90);
                        }
                        else{
                            //addAddressExtensionRecord(requestObj, terminationDayDiff-90);
                            requestDayDiffMap.put(requestObj.Id, terminationDayDiff-90);
                        }   
                        requestsOnHold.add(requestObj);                     
                    }
                    if((dayDiff > 31 && isExpired) || (terminationDayDiff > 31 && isCancelledOrDiscontinued)){
                        
                        if(!requestObj.Is_TPA_Send_DDN_Button_Enabled__c) {
                            requestObj.Is_TPA_Send_DDN_Button_Enabled__c = true;
                            requestToBeUpdated.add(requestObj);
                        }
                    }
                }
            }
            if(requestsOnHold.size() > 0 && requestDayDiffMap.size() > 0) {
                addAddressExtensionRecord(requestsOnHold, requestDayDiffMap);
            }
        }
        if(requestToBeUpdated != null && requestToBeUpdated.size() > 0){
            try
            {
                update requestToBeUpdated;
                system.debug('request updated successfully');
            }
            catch(Exception e)
            {
                System.debug('Request updated Failed: ' + e.getMessage());
            }
        }
    }
	public static void updateRequest(TPA_Request__c reqObj) {
        reqObj = SRV_TPA_TPARequest.getRequestInfo(reqObj.id);
        reqObj = SRV_TPA_TPARequest.manualApproval(reqObj);
        if(reqObj.Request_Status__c == 'In Auto Approval Process'){
            reqObj.TLLA_Batch_Call_Sent_On__c = null;
            reqObj.isbatchProcessing__c = false;
        }
        if(reqObj.Request_Status__c == 'Hold for TPA non-compliance') {
            reqObj.Request_Status__c = 'In Review By IQVIA';
        }

        update reqObj;
        List<dsfs__DocuSign_Status__c> docuSign = new List<dsfs__DocuSign_Status__c>();
        if(reqObj != null  ){
            docuSign = [select id,name,dsfs__Completed_Date_Time__c, dsfs__Envelope_Status__c,dsfs__Voided_Reason__c,dsfs__Voided_Date_Time__c from dsfs__DocuSign_Status__c  where TPA_Request__c =: reqObj.Id order by createddate desc limit 1] ;
        }
        if(docuSign != null && docuSign.size() >0){
            if( reqObj.Request_Status__c == 'In Review By IQVIA' && docuSign[0].dsfs__Envelope_Status__c== 'voided' && docuSign[0].dsfs__Voided_Reason__c == 'TPA Request on Hold for TPA Non-Compliance' && (docuSign[0].dsfs__Voided_Date_Time__c > reqObj.Client_Request_Submission__c || docuSign[0].dsfs__Voided_Date_Time__c >reqObj.Vendor_App_Submitted__c)){
                SRV_TPA_TPARequest.sendMailtoTPProcessorAbtStatusUpdateFromComplianceHold(reqObj);
            }  
        }        
    }

    public void addAddressExtensionRecord(List<TPA_Request__c> requestsOnHold, map<Id, Integer> requestDayDiffMap) {
        Set<Id> setVendorID = new Set<Id>(); 
        Map<Id,Address__c> mapAddressIdWithRecord = new Map<Id,Address__c>();
        Map<ID,Watch_List_History__c> mapRequestIdWithwatchHistories = new Map<ID,Watch_List_History__c>();	
     
        for(TPA_Request__c reqObj : requestsOnHold) {
            if(reqObj.Service_Provider_Address__c != Null ) {
                if(reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c) {
                    setVendorID.add(reqObj.Service_Provider_Address__c);
                }
                else if(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null){
                    setVendorID.add(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c);
                }                
            }
        } 

        for(TPA_Request__c reqObj : [Select id, Service_Provider_Address__c, Service_Provider_Address__r.Parent_Vendor_Name__c, Service_Provider_Address__r.Primary_Vendor_Address__c,Request_Status__c,Vendor_Language__c, TP_Processor_Email__c,TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, Vendor_Contact_Email_Client__c from TPA_Request__c where (Service_Provider_Address__c in: setVendorID OR Service_Provider_Address__r.Parent_Vendor_Name__c in: setVendorID) AND Request_Status__c in ('In Review By IQVIA','Pending IQVIA Review of Voided Envelope', 'Awaiting Vendor Signature', 'TPA Approved Awaiting AMA Approval')]) {
            Id vendorId;
            if(reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c) {
                vendorId = reqObj.Service_Provider_Address__c;
            } else if(reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null){
                vendorId = reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c;
            }
            if(!mapVendorIdWithRequestLst.containsKey(vendorId)) {
                mapVendorIdWithRequestLst.put(vendorId, new list<TPA_Request__c>{reqObj});
            } else {
                mapVendorIdWithRequestLst.get(vendorId).add(reqObj);
            }
        }  
        
        for(Address__c addObj : [Select id, (select id, DDN_Ack_Pending_Requests__c from  TPA_Master_Extension_Informations__r) from Address__c where id IN: setVendorID]) { 
            mapAddressIdWithRecord.put(addObj.id, addObj);
        }

        for(Watch_List_History__c watchObj : [Select id, Pending_TPA_Request__c, Pending_TPA_Request__r.id, Request_added_on_Date__c from Watch_List_History__c where Pending_TPA_Request__c != null and Pending_TPA_Request__r.id in: requestsOnHold]) { 
            mapRequestIdWithwatchHistories.put(watchObj.Pending_TPA_Request__r.id, watchObj);
        }

        for(TPA_Request__c reqObj : requestsOnHold) {
            Integer dayDiff = requestDayDiffMap.get(reqObj.Id);
            System.debug('in addAddressExtensionRecord:: '+ dayDiff);
            Id vendorAddId = null;
            if(reqObj.Service_Provider_Address__c != null && reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c){
                vendorAddId = reqObj.Service_Provider_Address__c;
            } else if(reqObj.Service_Provider_Address__c != null && reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null){
                vendorAddId = reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c;
            }
            TPA_Master_Extension_Information__c objTPAMasExt;
            if(reqObj.Service_Provider_Address__c != null && (reqObj.Service_Provider_Address__r.Parent_Vendor_Name__c != null || reqObj.Service_Provider_Address__r.Primary_Vendor_Address__c)){
                Address__c addObj = mapAddressIdWithRecord.get(vendorAddId);
                if(mapAddressIdWithAddressExtension.containsKey(vendorAddId)) {
                    objTPAMasExt = mapAddressIdWithAddressExtension.get(vendorAddId);
                } else if(addObj.TPA_Master_Extension_Informations__r != null && addObj.TPA_Master_Extension_Informations__r.size() > 0) {
                    objTPAMasExt = addObj.TPA_Master_Extension_Informations__r[0];
                    if(objTPAMasExt.DDN_Ack_Pending_Requests__c != null && objTPAMasExt.DDN_Ack_Pending_Requests__c != ''){
                        objTPAMasExt.DDN_Ack_Pending_Requests__c += ', ';
                    }
                } else{
                    objTPAMasExt = new TPA_Master_Extension_Information__c(Return_Destruction_Ack_Outstanding__c = false, DDN_Ack_Pending_Requests__c = '');
                }
        
                if(!mapRequestIdWithwatchHistories.containsKey(reqObj.Id)) {
                    watchHistories.add(new Watch_List_History__c( Pending_TPA_Request__c = reqObj.Id, Vendor_on_Hold__c = vendorAddId, Request_added_on_Date__c = todayDate.addDays(-dayDiff) ));
                }
        
                if(!mapAddressIdWithRequestLst.containsKey(vendorAddId)) {
                    mapAddressIdWithRequestLst.put(vendorAddId, new list<TPA_Request__c>{reqObj});
                } else {
                    mapAddressIdWithRequestLst.get(vendorAddId).add(reqObj);
                }
                
                if(objTPAMasExt.DDN_Ack_Pending_Requests__c == null || !objTPAMasExt.DDN_Ack_Pending_Requests__c.contains(reqObj.name)) {
                    objTPAMasExt.DDN_Ack_Pending_Requests__c = objTPAMasExt.DDN_Ack_Pending_Requests__c != null ? objTPAMasExt.DDN_Ack_Pending_Requests__c += reqObj.name : reqObj.name ; 
                    objTPAMasExt.DDN_Ack_Pending_Requests__c +=  ', ';
                    objTPAMasExt.Return_Destruction_Ack_Outstanding__c = true;
                    if(vendorAddId != null){
                        objTPAMasExt.TPA_Accounts_Address__c = vendorAddId;
                        mapAddressIdWithAddressExtension.put(vendorAddId, objTPAMasExt);       
                    }  
                    if(Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4  || Test.isRunningTest()){
                    sendMailToVendor(reqObj);
                } 

                }    
            }        
            system.debug('mapAddressIdWithAddressExtension: '+ mapAddressIdWithAddressExtension); 
            if(!reqObj.Is_DDN_Pending_Request__c) {
                reqObj.Is_DDN_Pending_Request__c = true;
            }
            reqObj.Request_added_on_DDN_Hold__c = Date.today();
            try {
                upsert reqObj; 
                System.debug('reuest updated successfully');
            } catch(Exception e) {
                System.debug('Following Exception Occue In IF---------> ' + e);
            }
        }
    }
    
    public void sendMail(TPA_Request__c reqRec, List<string> toRecipients, List<string> ccRecipients, Id templateID, Integer dayDiff, Boolean isRenewedReqCancelled, String excludedOfferings) {
        try {
            System.debug('INN!234');
            Id reqId = reqRec.Id;
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
            try {
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, reqId);
            } catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }

            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setCharset('UTF-8');
            emailToSend.setToAddresses(toRecipients);
            String emailBody = '';
            String emailSubject = '';
            if(reqRec.Renewed_As__c != null && reqRec.Renewed_As__r.Is_Partially_Renewed__c && reqRec.Renewed_As__r.Request_Status__c != 'Cancelled' && !UTL_Validate.isEmptyOrNull(excludedOfferings)) {
                String offBulletList = UTL_TPA.getOfferingDetailsToHtmlList(excludedOfferings);
                system.debug('0001:::'+offBulletList);
                emailBody = emailNotToSend.getPlainTextBody();
                emailBody = emailBody.replace('EXCLUDEDOFFERINGS','<div style="font-size:13px;font-family:arial;">' + offBulletList + '</div>');
                emailToSend.setPlainTextBody(emailBody);
                emailBody = emailNotToSend.getHTMLBody();
                emailBody = emailBody.replace('EXCLUDEDOFFERINGS','<div style="font-size:13px;font-family:arial;">' +  offBulletList + '</div>');
                system.debug('0002:::'+emailBody.indexOf('EXCLUDEDOFFERINGS')+'::::'+emailBody);
                emailBody = SRV_TPA_TPARequest.addEmailFooter(emailBody);
                emailToSend.setHTMLBody(emailBody);
                emailSubject = emailNotToSend.getSubject();
                system.debug('0003:::'+emailBody);
            } else {
                emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
                emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
            }
            
            emailToSend.setSubject(emailNotToSend.getSubject());
            emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            emailToSend.setWhatId(reqId);
            emailToSend.setSaveAsActivity(true);

            if(String.isNotBlank(TPA_Settings__c.getOrgDefaults().TPA_RequestSubmitted_Email__c) && ccRecipients != null ) {
                ccRecipients.addAll(TPA_Settings__c.getOrgDefaults().TPA_RequestSubmitted_Email__c.split(','));
            }
            if(ccRecipients != null && ccRecipients.size() > 0) {
                emailToSend.setCcAddresses(ccRecipients);
            }
            
            msgListToBeSend.add(emailToSend);
            try {
                if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    SRV_TPA_TPARequest.sendEmailThroughWorkflow(toRecipients, ccRecipients, 'SendEmail', templateId, reqId, null, emailSubject, FALSE, emailBody, FALSE, FALSE, null);
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                }
            } catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }
            TPA_Acknowledgment_Log__c tpaAckLog = new TPA_Acknowledgment_Log__c();
            for(String recipient : toRecipients) {
                if(tpaAckLog.Email_Sent_To__c == null || tpaAckLog.Email_Sent_To__c == '') {
                    tpaAckLog.Email_Sent_To__c = recipient;
                }
                else {
                    tpaAckLog.Email_Sent_To__c = tpaAckLog.Email_Sent_To__c +  ', ' + recipient;
                }
            }
            tpaAckLog.TPA_Request__c = reqId;
            
            if(isRenewedReqCancelled) {
                tpaAckLog.Description__c = dayDiff+'-day Data Destroy Notificiation sent after renewed request cancelled';
            } else {
                tpaAckLog.Description__c = dayDiff+'-day Data Destroy Notificiation sent';
            }
            insert tpaAckLog;
        } catch(System.EmailException emlEx) {
            System.debug('Email Failed: ' + emlEx);
        } catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }
    
    public void sendMailToVendor(TPA_Request__c request) {
        String preferredLanguage = 'English';
        preferredLanguage = request.vendor_language__c != null ? request.vendor_language__c : 'English';
        system.debug('####TPA_Batch_Vendor_Offering_Return_Ack.sendMailToVendor preferredLanguage: '+preferredLanguage);
        Id templateID;
        List<String> toAddressesList = new List<String>();
        toAddressesList.add(request.Vendor_e_mail__c);
        if(request.Vendor_e_mail__c != request.Authorized_Signer_Email__c) {
            toAddressesList.add(request.Authorized_Signer_Email__c);
        }
        
        List<String> ccAddressesList = new List<String>();
        ccAddressesList.add(request.ClientContact__r.Email);
        if(request.Client_TPA_Representative_Email__c != null && request.Client_TPA_Representative_Email__c != ''){
            ccAddressesList.add(request.Client_TPA_Representative_Email__c);
        }
        if(request.Owner.Type != null && request.Owner.Type == 'Queue' && request.Owner.Email != null){
            ccAddressesList.add(request.Owner.Email);
        }
        ccAddressesList.add(request.Vendor_Compliance_Email__c);
        ccAddressesList.add(request.TP_Processor_Email__c);
        try {
            System.debug('INN!234');
            List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();

            Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();

            try {
                templateID = UTL_TPA_Multilingual.multiLingualTemplateSettingsMap.get('Accnt on Hold Due To Fail DD'+preferredLanguage).Translated_Template_Id__c;
                emailNotToSend = Messaging.renderStoredEmailTemplate(templateID, NULL, request.Id);
            }
            catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }


            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setCharset('UTF-8');
            emailToSend.setToAddresses(toAddressesList);
            emailToSend.setPlainTextBody(emailNotToSend.getPlainTextBody());
            emailToSend.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
            emailToSend.setSubject(emailNotToSend.getSubject());
            emailToSend.setOrgWideEmailAddressId(TPA_Settings__c.getInstance().TPA_From_Orgwide_Email_Id__c);
            emailToSend.setWhatId(request.Id);
            emailToSend.setSaveAsActivity(true);

            if(String.isNotBlank(TPA_Settings__c.getOrgDefaults().TPA_RequestSubmitted_Email__c) && ccAddressesList != null ) {
                ccAddressesList.addAll(TPA_Settings__c.getOrgDefaults().TPA_RequestSubmitted_Email__c.split(','));
            }
            if(ccAddressesList != null && ccAddressesList.size() > 0) {
                emailToSend.setCcAddresses(ccAddressesList);
            }
            
            msgListToBeSend.add(emailToSend);
            try {
                if(msgListToBeSend != null && msgListToBeSend.size() > 0 && UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                    /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                    if(request.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                        SRV_TPA_TPARequest.addTPProcessorInitials = true;
                        SRV_TPA_TPARequest.assignedTPProcessorName = request.TPA_Assigned_TP_Processor__r.Initials__c;
                    }*/
                    SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddressesList, ccAddressesList, 'SendEmail', templateId, request.Id, null, '', FALSE, '', TRUE, TRUE, request);
                    //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                }
            }
            catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }
            

        }
        catch(System.EmailException emlEx) {
            System.debug('Email Failed: ' + emlEx);
        }
        catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('In Finish method: ');
        System.debug('mapAddressIdWithAddressExtension: ' + mapAddressIdWithAddressExtension);
        if(mapAddressIdWithAddressExtension != null && mapAddressIdWithAddressExtension.size() > 0){
            for(TPA_Master_Extension_Information__c addExtRecord : mapAddressIdWithAddressExtension.values()) {
                addExtRecord.DDN_Ack_Pending_Requests__c = addExtRecord.DDN_Ack_Pending_Requests__c.removeEnd(', ');
            }
            try {
                upsert mapAddressIdWithAddressExtension.values(); 
                System.debug('address updated successfully');
            } catch(Exception e) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::BCH_TPA_Vendor_Off_Return_Ack:::updateAccount', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('Following Exception Occue In IF---------> ' + e);
            }
        }

        List<TPA_Request__c> reqListTobeUpdate = new List<TPA_Request__c>();
        Set<id> requestIds = new Set<id>();
        Set<id> requestIdsSet = new Set<id>();
        for(Id vendorId:mapAddressIdWithAddressExtension.keySet()){
            if(mapVendorIdWithRequestLst != null && mapVendorIdWithRequestLst.size() > 0 
               && vendorId != null && mapVendorIdWithRequestLst.get(vendorId) != null 
               && mapVendorIdWithRequestLst.get(vendorId).size() > 0){
                   for(TPA_Request__c reqObj : mapVendorIdWithRequestLst.get(vendorId)){
                       if(!requestIdsSet.contains(reqObj.id)){
                           requestIdsSet.add(reqObj.id);                    
                           if(reqObj.Request_Status__c == 'Awaiting Vendor Signature'){
                               requestIds.add(reqObj.id);
                               if(!mapRequestwitheNewStatus.containsKey(reqObj.id)){
                                   mapRequestwitheNewStatus.put(reqObj.id, 'Awaiting Vendor Signature');
                               }
                           }
                           else {
                               if(!mapRequestwitheNewStatus.containsKey(reqObj.id)){
                                   mapRequestwitheNewStatus.put(reqObj.id, reqObj.Request_Status__c);
                               }
                           }
                           reqObj.Request_Status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs';
                           SRV_TPA_TPARequest.DDNAckPendingRecords = mapAddressIdWithRequestLst.get(vendorId);
                           reqListTobeUpdate.add(reqObj);
                           if(!mapRequestwithVendor.containsKey(reqObj.id)){
                               mapRequestwithVendor.put(reqObj.id, vendorId);
                           }
                           
                       }
                   }
               }            
        }
        if(requestIds != null && requestIds.size() > 0) {
            QBL_TPA_AsyncVoidEnvelope asyncVoidEnvelopeCall= new QBL_TPA_AsyncVoidEnvelope();
            asyncVoidEnvelopeCall.requestIds = requestIds ;
            asyncVoidEnvelopeCall.voidReason = 'DDNVoidReason';
            if(!Test.isRunningTest()) {
                System.enqueueJob(asyncVoidEnvelopeCall);
            }
        }        

        if(reqListTobeUpdate != null && reqListTobeUpdate.size() > 0) {
            try {
                SRV_TPA_TPARequest.sendMailtoTPProcessorAbtSignaturetoHoldForBulk(reqListTobeUpdate, mapRequestwitheNewStatus);           
                SRV_TPA_TPARequest.sendDataDestructionAckOutstandingMailforBulkRequest(reqListTobeUpdate, mapAddressIdWithRequestLst, mapVendorIdWithRequestLst,mapRequestwithVendor);  
                
                upsert reqListTobeUpdate; 
                System.debug('reuest updated successfully');
            } catch(Exception e) {
                UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::BCH_TPA_Vendor_Off_Return_Ack:::updateRequest', ''));
                UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);
                System.debug('Following Exception Occue In IF---------> ' + e);
            }
        }
        
        if(watchHistories != null && watchHistories.size() > 0) {
            try {
                insert watchHistories; 
                System.debug('reuest updated successfully');
            } catch(Exception e) {
                System.debug('Following Exception Occue In IF---------> ' + e);
            }
        }
    }
}
