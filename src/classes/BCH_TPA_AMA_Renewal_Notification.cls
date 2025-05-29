/*
*@Author  : Supriya Johari
*@Purpose : Get List of all the AMA agreement and send notification to vendor prior 90 days and 75 days for renewal 
*@Date    : 19 sept. 2016
*/
global class BCH_TPA_AMA_Renewal_Notification implements Database.Batchable<sObject> {
    
    private AMA_Agreement_Detail__c AMAagg;
    private List<Messaging.SingleEmailMessage> mailListToBeSend;
    private List<TPA_AMA_Settings__c> amaSetting;
    private List<AMA_Agreement_Detail__c> amaAgrList;
    private String currentYear;
	public Boolean includeTestDataOnly{
		get{
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}
    
    
    global BCH_TPA_AMA_Renewal_Notification() {
        amaSetting = [Select id, Send_Renewal_Notification__c , Dev_Mail_ID__c  , Vendor_Renewal_Notification_Template_Id__c , To_address_Vendor_Renewal_Notification__c , CC_address_Vendor_Renewal_Notification__c,Reminder_Start_Date__c, Vendor_Renewal_Noti_for_old_Template_Id__c from TPA_AMA_Settings__c Limit 1]; // added by supriya Johari under Er-3196 // // Modified By Neha Bansal under CR-12117
        currentYear = String.valueOf(System.Today().year()+1);
        //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_AMA_Renewal_Notification');
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'Select Id, Name, TPA_Request__r.Name, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Client_Company_Name_Address__r.Name,TPA_Request__r.Service_Provider_Address__r.AMA_Database_Licensee__c, Current_Year_Fees__c,Next_Year__c, Next_Year_Fees__c, Date_Agreement_Activated__c,Contract_Type__c from AMA_Agreement_Detail__c where TPA_Request__r.Request_Status__c = \'In Effect\' and Date_Agreement_Activated__c != null ';
        query += ' and Next_Year_Fees__c > 0 ';
        query += ' and Next_Year__c = :currentYear';
        query += ' and (DBL__c like \'%IQVIA%\' OR DBL__c like \'%IMS%\' OR DBL__c like \'%DMD%\') ';
        query += ' and TPA_Request__r.Service_Provider_Address__r.AMA_Database_Licensee__c = False';
        query += ' and (Status_of_Cancelation_Request__c  = null OR Status_of_Cancelation_Request__c = \'\') and Status_of_Renewal_Process__c not in (\'Vendor Responded Cancel\', \'AMA Acknowledged\',\'Vendor Confirmed Renewal\')'; // modified by supriya johari under Issue-09686 // Modified By Neha Bansal under CR-12274
        
        //if(!amaSetting.isEmpty() && amaSetting.get(0).Send_Renewal_Notification__c)
        if(includeTestDataOnly){
            query += ' and (Client__c Like \'Test_'+'%\'  OR Vendor_Legal_Name__c Like \'Test_'+'%\' )';
        }
        
        query += ' order by Date_Agreement_Activated__c DESC';
        if(Test.isRunningTest()){
            query += ' limit 1' ;
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Sobject> objList){
        mailListToBeSend = new List<Messaging.SingleEmailMessage>();
        amaAgrList = new List<AMA_Agreement_Detail__c>();
        for(SObject obj : objList){
            AMAagg = (AMA_Agreement_Detail__c)obj;
            
            string query = 'Select Id, Name, TPA_Request__r.Name, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Client_Company_Name_Address__r.Name, Current_Year_Fees__c,Next_Year__c, Next_Year_Fees__c, Date_Agreement_Activated__c,Contract_Type__c from AMA_Agreement_Detail__c where TPA_Request__r.Request_Status__c = \'In Effect\' and Date_Agreement_Activated__c != null ';
            query += ' and Next_Year_Fees__c > 0 ';
            query += ' and Next_Year__c = :currentYear';
            query += ' and (Status_of_Cancelation_Request__c  = null OR Status_of_Cancelation_Request__c = \'\') and Status_of_Renewal_Process__c not in (\'Vendor Responded Cancel\', \'AMA Acknowledged\',\'Vendor Confirmed Renewal\') and Id = \'' + AMAagg.Id + '\''; 
            
            if(!amaSetting.isEmpty() && amaSetting.get(0).Send_Renewal_Notification__c)
                query += ' and (Client__c Like \'Test_'+'%\'  OR Vendor_Legal_Name__c Like \'Test_'+'%\' )';
            
            query += ' order by Date_Agreement_Activated__c DESC';
            if(Test.isRunningTest()){
                query += ' limit 1' ;
            }
            List<sObject> sobjList = Database.query(query);
            if(sobjList == null || sobjList.size() == 0) {
                continue;
            }
            else {
                AMAagg = (AMA_Agreement_Detail__c)sobjList[0];
            }
            
            sendRenewalNotificationToVendor(AMAagg);
        }
        
        
        try{
            //if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()){
                //Messaging.sendEmail(mailListToBeSend);
                try{
                    update amaAgrList;
                }
                catch(Dmlexception ex){
                    System.debug(ex.getMessage());
                } 
           // }
        } catch(System.EmailException ex){
            System.debug(ex.getMessage());
        } 
        catch(Exception ex){
            System.debug(ex.getMessage());
        }
        
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    
    private void sendRenewalNotificationToVendor(AMA_Agreement_Detail__c  amaAgrObj){     
        try {  
            Date todayDate = Date.today();        
            String emailType = '';
            if(todayDate >= amaSetting.get(0).Reminder_Start_Date__c){
                emailType = 'Email Vendor Renewal Noti Old';
            }else{
                emailType = 'Email Vendor Renewal Notification';
            }
            
            AMA_Agreement_Detail__c amaObjWithAgrmt = [Select id,Status_of_Renewal_Process__c, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Vendor_Contact_e_mail__c, Invoice_Contact_Email__c, TPA_Request__r.Authorized_Signer_Email__c,TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c  from AMA_Agreement_Detail__c WHERE id =: amaAgrObj.Id]; // Modified by Neha Bansal under CR-12117
            TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];
            
            List<String> toAddress= new List<String>{((amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c == null || amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c.length() == 0) ? amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_Email_Client__c : amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c)};
                if(toAddress.isEmpty()){
                    toAddress.add(amaSetting.get(0).Dev_Mail_ID__c);
                }
            
            if(amaObjWithAgrmt.TPA_Request__r.Authorized_Signer_Email__c != null && amaObjWithAgrmt.TPA_Request__r.Authorized_Signer_Email__c.length() > 0)
            {
                toAddress.Add(amaObjWithAgrmt.TPA_Request__r.Authorized_Signer_Email__c);
            }
            
            if(String.isNotBlank(amaObjWithAgrmt.Invoice_Contact_Email__c)) {
                toAddress.add(amaObjWithAgrmt.Invoice_Contact_Email__c);
            }
            
            List<String> ccTo = new List<String>();
            
            if(amaObjWithAgrmt.TPA_Request__r.TP_Processor_Email__c != null)
                ccTo.add(amaObjWithAgrmt.TPA_Request__r.TP_Processor_Email__c);
            
            if(UTL_TPA.TPUSEMailAddress != null) {
                for(String emailToCc: UTL_TPA.TPUSEMailAddress.split(',')) {
                    ccTo.add(emailToCc);
                }
            }    
            
            if(String.isNotBlank(amaSetting.get(0).CC_address_Vendor_Renewal_Notification__c))
            {
                List<String> addCCTo = amaSetting.get(0).CC_address_Vendor_Renewal_Notification__c.split(';');
                ccTo.addAll(addCCTo);
            }
            
            List<Attachment> lstAttachment = new List<Attachment>();
            lstAttachment = [select Id, Name,Body from Attachment where ParentId =: amaObjWithAgrmt.TPA_Request__r.id and (Name like 'AMA_%TPA%.pdf_Completed') order by LastModifiedDate Desc limit 1];
                
            
            amaObjWithAgrmt.Status_of_Renewal_Process__c = 'Awaiting Vendor Response for renewal';
            amaObjWithAgrmt.Renewal_Cancellation_Vendor_Link_Date__c = Date.today();
            amaAgrList.add(amaObjWithAgrmt);
            /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
            if(amaObjWithAgrmt.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
            	SRV_TPA_TPARequest.assignedTPProcessorName = amaObjWithAgrmt.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
            }*/
            SRV_TPA_TPARequest.sendTPANotifications(toAddress, ccTo, emailType, 'English', amaAgrObj.id, true, lstAttachment, null, FALSE, FALSE, tpaRequest);
            //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            return ;
            
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
            return ;
        }
    }
    
}
