/*
*@Author  : Supriya Johari
*@Purpose : Send Reminder Mail to Vendor and AMA for cancelation request
*@Date    : 1 July 2016
*/
global class BCH_TPA_AMA_Send_Reminder_Mail implements Database.Batchable<sObject>
{
    Date todayDate;
    List<Messaging.SingleEmailMessage> mailListToBeSend;
    public Boolean includeTestDataOnly{
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}
    
    global BCH_TPA_AMA_Send_Reminder_Mail ()
    {
         //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_AMA_Send_Reminder_Mail');
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = 'Select id, Vendor_AMA_Fee_Response__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.ClientContact__c, TPA_Request__r.ClientContact__r.email, TPA_Request__r.Client_TPA_Representative_Email__c, TPA_Request__r.Request_Status__c ,TPA_Request__c, TPA_Request__r.Name, TPA_Request__r.Service_Provider_f__c,TPA_Request__r.Client_First_Name__c, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c ,Client__c, Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c ,DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c , Last_AMA_Reminder_Mail_Sent__c , Last_Vendor_Reminder_Mail_Sent__c, Last_Vendor_Offshore_Reminder_Mail_Sent__c, Status_of_Offshore_Process__c, Last_AMA_offshore_reminder_mail_sent__c FROM AMA_Agreement_Detail__c where ((Status_of_Cancelation_Request__c in ( \'Awaiting Vendor Cancelation Acknowledgement\' , \'Awaiting AMA Response to Vendor Cancelation Request\') AND TPA_Request__r.Request_Status__c != \'Cancelled\' ) OR ( (TPA_Request__r.Request_Status__c in ( \'Pending Vendor AMA Fee Acknowledgement\', \'Pending - Vendor Declined AMA Fees\'))) OR ( Status_of_Offshore_Process__c  in ( \'Awaiting Vendor Response: AMA Offshore Consent form has been sent to Vendor\', \'Awaiting AMA Response: Offshore Consent form requires AMA review/approval\')  AND TPA_Request__r.Request_Status__c not in (\'In Effect\', \'Cancelled\',\'Expired\')))'  ;    
        //query += 'and id = \'aEB0n00000006wg\' ';
        if(includeTestDataOnly){
            query += ' and (Client__c Like \'Test_'+'%\'  OR Vendor_Legal_Name__c Like \'Test_'+'%\' )'; 
        }
        if(Test.isRunningTest()){
            query += ' limit 1';
        }
        
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<sObject> objList){
        mailListToBeSend = new List<Messaging.SingleEmailMessage>();
        todayDate = Date.today(); 
        List<AMA_Agreement_Detail__c> amaAgrList = new List<AMA_Agreement_Detail__c>();
        for(sobject sobj : objList)
        {
            AMA_Agreement_Detail__c amaObj = (AMA_Agreement_Detail__c)sobj;
            TPA_Request__c tpaRequest = [Select id, Name, Owner.Type, Owner.Email, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaObj.TPA_Request__c];
            if(String.isNotBlank(amaObj.Vendor_Reasons_for_Termination__c)){
                Date vendorReminderSentDate = amaObj.Last_Vendor_Reminder_Mail_Sent__c;
                Date AMAReminderSentDate = amaObj.Last_AMA_Reminder_Mail_Sent__c;

                if(amaObj.Status_of_Cancelation_Request__c  == 'Awaiting Vendor Cancelation Acknowledgement' && amaObj.Last_Vendor_Reminder_Mail_Sent__c  != null && (Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4  || Test.isRunningTest())){
                    mailListToBeSend.add(SendNotificationWithCancelationLink(amaObj));
                         amaObj.Last_Vendor_Reminder_Mail_Sent__c = todayDate;
                         amaAgrList.add(amaObj);
                    
                }
                else if(amaObj.Last_AMA_Reminder_Mail_Sent__c  != null && AMAReminderSentDate.daysBetween(todayDate) == 3 && amaObj.Status_of_Cancelation_Request__c  == 'Awaiting AMA Response to Vendor Cancelation Request')
                {
                    mailListToBeSend.add(SendCancelationNotificationToDBL(amaObj));
                            amaObj.Last_AMA_Reminder_Mail_Sent__c = todayDate;
                            amaAgrList.add(amaObj);
                }
            }
            
            
            if(amaObj.Last_AMA_offshore_reminder_mail_sent__c  != null && String.isNotBlank(amaObj.Status_of_Offshore_Process__c)  && amaObj.Status_of_Offshore_Process__c  == UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS) {
                    Date AMAReminderSentDate = amaObj.Last_AMA_offshore_reminder_mail_sent__c;
                    Integer dayDiff = AMAReminderSentDate.daysBetween(todayDate);
                    if((amaObj.TPA_Request__r.Service_Provider_f__c != null && amaObj.TPA_Request__r.Service_Provider_f__c.containsIgnoreCase('Test_')) || (amaObj.TPA_Request__r.Client_First_Name__c != null && amaObj.TPA_Request__r.Client_First_Name__c.containsIgnoreCase('Test_'))) {
                        if(Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4 || Test.isRunningTest()) {
                            SendReminderOffshoreNotiToDBL(amaObj, tpaRequest);
                            amaObj.Last_AMA_offshore_reminder_mail_sent__c = todayDate;
                            amaAgrList.add(amaObj);
                        }
                    }
                    else{
                        if(dayDiff == 3 || math.mod(dayDiff, 3) == 0) {
                            SendReminderOffshoreNotiToDBL(amaObj, tpaRequest);
                            amaObj.Last_AMA_offshore_reminder_mail_sent__c = todayDate;
                            amaAgrList.add(amaObj);
                        }

                    }
            }
            
            // Boolean isvalidOffshoreCountry = true;
            // if(amaObj.Vendor_employee_access_data_in_country__c != null){
            //     for(String country: amaObj.Vendor_employee_access_data_in_country__c.split(',')){
            //         if(!UTL_TPA.offshoreCountries.contains(country.trim().toLowerCase())){
            //             isvalidOffshoreCountry = false;
            //             break;
            //         }
            //     }
            // }
            
            
            // else if(String.isNotBlank(amaObj.Status_of_Offshore_Questionnaire__c) && amaObj.Status_of_Offshore_Questionnaire__c == 'Awaiting Vendor Response: AMA Offshore Questionnaire has been sent to Vendor') /* added by supriya Johari under Er-2906 starts*/
            // {
            //     if(amaObj.Last_Vendor_Offshore_Reminder_Mail_Sent__c != null && (Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4  || Test.isRunningTest()) )
            //     {
            //         if(SendReminderWithOffshoreLink(amaObj) != null){
            //             mailListToBeSend.add(SendReminderWithOffshoreLink(amaObj));
            //         }
            //         amaObj.Last_Vendor_Offshore_Reminder_Mail_Sent__c = todayDate;
            //         amaAgrList.add(amaObj);
            //     }
                
            // }
            if(String.isNotBlank(amaObj.TPA_Request__r.Request_Status__c) && amaObj.TPA_Request__r.Request_Status__c == 'Pending Vendor AMA Fee Acknowledgement' && ((String.isBlank(amaObj.Vendor_AMA_Fee_Response__c) || !(amaObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('acknowledged') || amaObj.Vendor_AMA_Fee_Response__c.equalsIgnoreCase('declined'))) && (((Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4) ) || Test.isRunningTest() ) ))            {
                List<String> toAddress = new List<String>();
                if(String.isNotBlank(amaObj.TPA_Request__r.Authorized_Signer_Email__c ) && String.isNotBlank(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c) && !amaObj.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c)){
                    toAddress.add(amaObj.TPA_Request__r.Authorized_Signer_Email__c);
                    toAddress.add(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                }
                else
                {
                    if(String.isNotBlank(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c)){
                        toAddress.add(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                    }
                    else{
                        toAddress.add(amaObj.TPA_Request__r.Authorized_Signer_Email__c);
                    }
                }
                
                mailListToBeSend.add(SendReminderFeeConfirmationToVendor(amaObj, toAddress, tpaRequest));
            }
            
            if((String.isNotBlank(amaObj.TPA_Request__r.Request_Status__c) && amaObj.TPA_Request__r.Request_Status__c == 'Pending - Vendor Declined AMA Fees') && (((Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4) ) || Test.isRunningTest() ) ){
                List<String> ccAddress = new List<String>();
                if(String.isNotBlank(amaObj.TPA_Request__r.Authorized_Signer_Email__c ) && String.isNotBlank(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c) && !amaObj.TPA_Request__r.Authorized_Signer_Email__c.equalsIgnoreCase(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c) && (Math.mod(Date.newInstance(1900, 1, 1).daysBetween(Date.today()),7) <= 4  || Test.isRunningTest()))
                {
                    ccAddress.add(amaObj.TPA_Request__r.Authorized_Signer_Email__c);
                    ccAddress.add(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                }
                else
                {
                    if(String.isNotBlank(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c)){
                        ccAddress.add(amaObj.TPA_Request__r.Vendor_Contact_e_mail__c);
                    }
                    else{
                        ccAddress.add(amaObj.TPA_Request__r.Authorized_Signer_Email__c);
                    }
                }
                
                //mailListToBeSend.add(SendReminderVendorDeclinedToClient(amaObj, ccAddress));
                SendReminderVendorDeclinedToClient(amaObj, ccAddress, tpaRequest);
            }
            
        }
        
        
        try{
             if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){     
                Messaging.sendEmail(mailListToBeSend);
                update amaAgrList;
             }
        } 
       
        catch(Exception ex){
            System.debug(ex.getMessage());
        } 
    }
    
    public Messaging.SingleEmailMessage SendNotificationWithCancelationLink(AMA_Agreement_Detail__c  amaAgrObj)
    {             
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        
        List<TPA_AMA_Settings__c> amaSetting =  TPA_AMA_Settings__c.getall().values();
        
        email.setTargetObjectId(amaSetting.get(0).Vendor_Contact_ID__c);
        email.setWhatId(amaAgrObj.Id);
        //email.setTemplateId(amaSetting.get(0).Vendor_Cancelation_Reminder_Template_Id__c);
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(amaSetting.get(0).Vendor_Cancelation_Reminder_Template_Id__c, NULL, amaAgrObj.Id);
        email.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
        email.setSubject(emailNotToSend.getSubject());
        email.setCharset('UTF-8');  

        List<String> toAddress= new List<String>{amaAgrObj.TPA_Request__r.TP_Processor_Email__c, ((amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c == null || amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c.length() == 0) ? amaAgrObj.TPA_Request__r.Vendor_Contact_Email_Client__c : amaAgrObj.TPA_Request__r.Vendor_Contact_e_mail__c)}; // modified by Supriya Johari under CR-11047
        
        if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c)){   
            List<String> toAdd = amaSetting.get(0).Dev_Mail_ID__c.split(';'); 
            email.setToAddresses(toAdd); 
        }
        else{
            email.setToAddresses(toAddress);
        }
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_Vendor_Cancelation_Mail__c)){
            List<String> ccTo = amaSetting.get(0).CC_Address_For_Vendor_Cancelation_Mail__c.split(';');
            email.setCCAddresses(ccTo);
        }
        
        TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
        email.setOrgWideEmailAddressId(tpaSetting.TPA_From_Orgwide_Email_Id__c);
        email.setSaveAsActivity(true);
            
        return email;  
        
    }
    
    public Messaging.SingleEmailMessage SendCancelationNotificationToDBL(AMA_Agreement_Detail__c amaAgrObj)
    {        
        System.debug('####SendCancelationNotificationTODBL');
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
        
        TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getInstance();                
        String templateId = amaSetting.get(0).AMA_Cancelation_Reminder_Template_Id__c;
        String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<String> ccTo = amaSetting.get(0).CC_Address_For_DBL_Cancelation_Mail__c.split(';');
        mail.setCCAddresses(ccTo);
        
        
        mail.setTargetObjectId(dblContractsContactId);
        mail.setWhatId(amaAgrObj.id);
        //mail.setTemplateId(templateId); 
        Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, amaAgrObj.id);
        mail.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
        mail.setSubject(emailNotToSend.getSubject());
        mail.setCharset('UTF-8');  

        mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
        mail.setSaveAsActivity(true);
        
       
        if(String.isNotBlank(amaAgrObj.Client__c) &&
           String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
           (amaAgrObj.Client__c.startsWithIgnoreCase('Test') || amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            mail.setTreatTargetObjectAsRecipient(false);
        }
        
        
        return mail;
    }
    
    
    
    // public Messaging.SingleEmailMessage SendReminderWithOffshoreLink(AMA_Agreement_Detail__c  amaAgrObj)
    // {        
         
    //     try        
    //     {         
    //         List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values(); // modified by Supriya Johari under CR-11047
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
    //         email.setTargetObjectId(UTL_TPA.emailTargetContactId );
    //         email.setWhatId(amaAgrObj.Id);
    //         //email.setTemplateId(amaSetting.get(0).Offshore_Vendor_Reminder_Template_Id__c);
    //         Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
    //         emailNotToSend = Messaging.renderStoredEmailTemplate(amaSetting.get(0).Offshore_Vendor_Reminder_Template_Id__c, NULL, amaAgrObj.Id);
    //         email.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
    //         email.setSubject(emailNotToSend.getSubject());
    //         email.setCharset('UTF-8');  

    //         AMA_Agreement_Detail__c amaObjWithAgrmt = [Select id, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Vendor_Contact_e_mail__c from AMA_Agreement_Detail__c WHERE id =: amaAgrObj.Id];
            
    //         List<String> toAddress= new List<String>{amaObjWithAgrmt.TPA_Request__r.TP_Processor_Email__c , ((amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c == null || amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c.length() == 0) ? amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_Email_Client__c : amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c)}; // modified by Supriya Johari under CR-11047
            
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
            
    //         TPA_Settings__c tpaSetting = TPA_Settings__c.getInstance();
    //         email.setOrgWideEmailAddressId(tpaSetting.TPA_From_Orgwide_Email_Id__c);
            
    //         email.setSaveAsActivity(true);
            
    //         return email;
            
    //     }
    //     catch(Exception ex)
    //     {
    //         system.debug(ex.getMessage());
    //         return null;
    //     }
    // }
    
    
    public void SendReminderOffshoreNotiToDBL(AMA_Agreement_Detail__c amaAgrObj, TPA_Request__c tpaRequest) { 
           
        List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();

        List<String> toAddress = new List<String>();
        List<String> ccTo = new List<String>();
        
        //TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();                
        String templateId = amaSetting.get(0).Revised_Offshore_AMA_Reminder_TempId__c;
        // String dblContractsContactId = tpaCustomSettings.DBL_Contracts_Contact_Id__c; //dblcontracts@ama-assn.org
        
       
        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        if(String.isNotBlank(amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c)) {
            ccTo = amaSetting.get(0).CC_Address_For_DBL_Offshore_Mail__c.split(';');
            // mail.setCCAddresses(ccTo);
        }
        
        //Set email contents - you can use variables!
        //mail.setTargetObjectId(dblContractsContactId);
        
        //mail.setWhatId(amaAgrObj.id);
        //mail.setTemplateId(templateId); 
        //Messaging.SingleEmailMessage emailNotToSend = new Messaging.SingleEmailMessage();
        //emailNotToSend = Messaging.renderStoredEmailTemplate(templateId, NULL, amaAgrObj.id);
        //mail.setHTMLBody(SRV_TPA_TPARequest.addEmailFooter(emailNotToSend.getHTMLBody()));
        //mail.setSubject(emailNotToSend.getSubject());
        //mail.setCharset('UTF-8');  

        //mail.setOrgWideEmailAddressId(tpaCustomSettings.TPA_From_Address_For_Data_Release__c);
        //mail.setSaveAsActivity(true);
        
        //if(String.isNotBlank(amaAgrObj.Client__c) &&
          // String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
         //  (amaAgrObj.Client__c.startsWithIgnoreCase('Test') || amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))) {
        
         //   mail.setTreatTargetObjectAsRecipient(false);
       // }
        
        if(String.isNotBlank(amaAgrObj.Client__c) &&
        String.isNotBlank(amaAgrObj.Vendor_Legal_Name__c) &&
        (!amaAgrObj.Client__c.startsWithIgnoreCase('Test') && !amaAgrObj.Vendor_Legal_Name__c.startsWithIgnoreCase('Test'))){
            toAddress.add(UTL_TPA.dblContractContactEmail);
        }

        /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
        if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c){
        	SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
        }*/
                    
        try {
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
                
            }
        } 
        catch(Exception e) {
            System.debug('Offshore Notification sent to DBL failed: ' + e.getMessage());
        } 
        
        //return mail;
    }
    
    public Messaging.SingleEmailMessage SendReminderWithRevisedOffshoreLink(AMA_Agreement_Detail__c  amaAgrObj) { 
           
        try {        
            List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values(); 
            
            AMA_Agreement_Detail__c amaObjWithAgrmt = [Select id, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Vendor_Contact_e_mail__c,TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c from AMA_Agreement_Detail__c WHERE id =: amaAgrObj.Id];
            
            List<String> toAddress = new List<String>{amaObjWithAgrmt.TPA_Request__r.TP_Processor_Email__c , ((amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c == null || amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c.length() == 0) ? amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_Email_Client__c : amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c)}; // modified by Supriya Johari under CR-11047
            List<String> ccTo = new List<String>();

            if(toAddress.isEmpty() && String.isNotBlank(amaSetting.get(0).Dev_Mail_ID__c)) {
                toAddress = amaSetting.get(0).Dev_Mail_ID__c.split(';');
            }

            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_Vendor_Offshore_Mail__c)) {
                ccTo = amaSetting.get(0).CC_Address_For_Vendor_Offshore_Mail__c.split(';');
            }

            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;            
            if(amaObjWithAgrmt.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c){
            	SRV_TPA_TPARequest.assignedTPProcessorName = amaObjWithAgrmt.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
            }
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Revised_Offshore_Vendor_Reminder_TempId__c, amaAgrObj.Id, null, '', FALSE, '');
            SRV_TPA_TPARequest.addTPProcessorInitials = false;*/
            
            return null;
            
        }
        catch(Exception ex) {
            system.debug(ex.getMessage());
            return null;
        }
    }
    

    public Messaging.SingleEmailMessage SendReminderFeeConfirmationToVendor(AMA_Agreement_Detail__c  amaAgreement, List<String> toAddress, TPA_Request__c tpaRequest)
    {       
        
        try        
        {      
            TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();  
            
            List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();
            
            List<String> ccTo = new List<String>();
            
            if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c)){
                ccTo = tpaCustomSettings.TP_US_Mail_Id__c.split(',');
                
                if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)){
                    List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
                    ccTo.addAll(addCCTo);
                }
                
            }

            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;            
            if(amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c){
               SRV_TPA_TPARequest.assignedTPProcessorName = amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c; 
            }*/
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', amaSetting.get(0).Fee_Confirm_Before_Sign_Reminder_Temp__c, amaAgreement.id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            
            return null;
       
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
            //TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Custom';
            //TPAQueryHelper.setLogObject(amaAgreement.Id, 'Request: Mail not sent to vendor for AMA fee confirmation', 'Check: AMA Fee confirmation Mail not sent');
            //TPAQueryHelper.logRef().generateLog();
            return null;
        }
    }

    public Messaging.SingleEmailMessage SendReminderVendorDeclinedToClient(AMA_Agreement_Detail__c  amaAgreement, List<String> ccAddress, TPA_Request__c tpaRequest){
        
        try        
        {
            TPA_Settings__c tpaCustomSettings = TPA_Settings__c.getOrgDefaults();      
            
            List<TPA_AMA_Settings__c> amaSetting = TPA_AMA_Settings__c.getall().values();

            List<String> toAddress = new List<String>();
            toAddress.add(amaAgreement.TPA_Request__r.ClientContact__r.Email);
            
            if(amaAgreement.TPA_Request__r.Client_TPA_Representative_Email__c != null && amaAgreement.TPA_Request__r.Client_TPA_Representative_Email__c != '' ){
                toAddress.add(amaAgreement.TPA_Request__r.Client_TPA_Representative_Email__c);
            }

            if(tpaRequest.Owner.Type != null && tpaRequest.Owner.Type == 'Queue' && tpaRequest.Owner.Email != null){
                toAddress.add(tpaRequest.Owner.Email);
            }
            
            if(String.isNotBlank(tpaCustomSettings.TP_US_Mail_Id__c)){
                ccAddress.add(tpaCustomSettings.TP_US_Mail_Id__c);
            }
                
            if(String.isNotBlank(amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c)){
                List<String> addCCTo = amaSetting.get(0).CC_Address_For_All_The_AMA_Mails__c.split(';');
                ccAddress.addAll(addCCTo);
            }

            List<TPA_Contact__c> tpaContactList = SRV_TPA_TPARequest.getContactsForRequest(amaAgreement.TPA_Request__r.Id);
            if(tpaContactList != null && tpaContactList.size() > 0){
                for(TPA_Contact__c tpaContact : tpaContactList){
                    if(tpaContact.Type__c == 'Additional Client Contact'){
                        ccAddress.add(tpaContact.Email__c);
                    }
                }
            }
            
            String templateId = amaSetting.get(0).FeesInvoice_Reminder_Notify_Client__c ;

            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;            
            if(amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c){
                SRV_TPA_TPARequest.assignedTPProcessorName = amaAgreement.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
            }*/
            SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccAddress, 'SendAMAFeeDeclinedEmail', templateId, amaAgreement.Id, null, '', FALSE, '', TRUE, TRUE, tpaRequest);
            //SRV_TPA_TPARequest.addTPProcessorInitials = false;

            return null;
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
            //TODO
            //TPAQueryHelper.logRef().logToInsert().Log_Type__c = 'Custom';
            //TPAQueryHelper.setLogObject(amaAgreement.Id, 'Request: Mail not sent to Client for AMA Fee invoice declined by Vendor', 'Check: Vendor Fee declined Notification To Client not sent');
            //TPAQueryHelper.logRef().generateLog();
            return null;
        }
    }
    
    
    // finish Method
    global void finish(Database.BatchableContext bc){
    }
}
