/*****************************************************
Author:  Rajendra Prakash Gupta
Purpose: Batch to send AMA renewal mail Annualy
ER No.:  Issue-12287
*****************************************************/
global class BCH_TPA_Send_AMA_Renewal_Mail_Annua implements Database.Batchable<sObject> {
    
    private List<Messaging.SingleEmailMessage> mailListToBeSend;
    private List<TPA_AMA_Settings__c> amaSetting;
    public Boolean includeTestDataOnly {
		get {
			if(includeTestDataOnly == null) {
				includeTestDataOnly = false;
			}
			return includeTestDataOnly;
		}
		set;
	}
    
    global BCH_TPA_Send_AMA_Renewal_Mail_Annua(){
        amaSetting = TPA_AMA_Settings__c.getAll().values();
        //includeTestDataOnly = UTL_TPA.runBatchForTestRecords('BCH_TPA_Send_AMA_Renewal_Mail_Annua');
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        string query = 'Select Id, TPA_Request__r.Owner.Type, TPA_Request__r.Owner.Email, TPA_Request__r.Client_TPA_Representative_Email__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.ClientContact__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__c, TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Is_Active__c,  TPA_Request__r.Co_Assigned_Global_TP_Processor__r.Initials__c, TPA_Request__r.Service_Provider_Address__r.AMA_Database_Licensee__c from AMA_Agreement_Detail__c '+
                        'where TPA_Request__r.Request_Status__c = \'In Effect\' AND (DBL__c like \'%IQVIA%\' OR DBL__c like \'%IMS%\' OR DBL__c like \'%DMD%\')';
        query += ' and TPA_Request__r.Service_Provider_Address__r.AMA_Database_Licensee__c = False';  
        query += ' and (Status_of_Cancelation_Request__c  = null OR Status_of_Cancelation_Request__c = \'\') ';             
        query += ' and Next_Year_Fees__c > 0 AND Status_of_Renewal_Process__c != \'Vendor Responded Cancel\' AND Agreement_End_Date__c > ';
        query += String.valueOf(Date.newInstance(Date.today().year(), Integer.valueOf(amaSetting.get(0).Last_Day_Of_Year__c.split('-').get(0)), Integer.valueOf(amaSetting.get(0).Last_Day_Of_Year__c.split('-').get(1)))).split(' ').get(0);
        
        //if(!amaSetting.isEmpty() && amaSetting.get(0).Send_Renewal_Notification__c)
        if(includeTestDataOnly){
            query += ' and (Client__c Like \'Test_'+'%\'  OR Vendor_Legal_Name__c Like \'Test_'+'%\' )';
        }
        
        if(Test.isRunningTest())
        {
            query += ' limit 1' ;
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Sobject> objList)
    {
        for(SObject obj : objList)
        {
            createRenewalNotificationToVendor((AMA_Agreement_Detail__c)obj);
        }
    }

    global void finish(Database.BatchableContext bc)
    {

    }


    private void createRenewalNotificationToVendor(AMA_Agreement_Detail__c amaAgrObj)
    {
        try
        {
            String templateId = amaSetting.get(0).VendorRenewalNotifiAnnuallyTemplateId__c;
            AMA_Agreement_Detail__c amaObjWithAgrmt = [Select id, TPA_Request__c, TPA_Request__r.ClientContact__r.Email, TPA_Request__r.Owner.Type , TPA_Request__r.Owner.Email, Invoice_Contact_Email__c, TPA_Request__r.Client_TPA_Representative_Email__c, TPA_Request__r.Authorized_Signer_Email__c, Status_of_Renewal_Process__c, TPA_Request__r.ClientContact__c, TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c, TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Vendor_Contact_e_mail__c from AMA_Agreement_Detail__c WHERE id =: amaAgrObj.Id];
            TPA_Request__c tpaRequest = [Select id, Name, TPA_Assigned_TP_Processor__c, TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c from TPA_Request__c where Id =: amaAgrObj.TPA_Request__c];
            List<String> toAddress= new List<String>();
            if(amaObjWithAgrmt.TPA_Request__r != null && amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c != null) {
                toAddress.add(amaObjWithAgrmt.TPA_Request__r.Vendor_Contact_e_mail__c);
            }
            if(amaObjWithAgrmt.TPA_Request__r != null && amaObjWithAgrmt.TPA_Request__r.Authorized_Signer_Email__c != null) {
                toAddress.add(amaObjWithAgrmt.TPA_Request__r.Authorized_Signer_Email__c);
            }
            if(amaObjWithAgrmt != null && amaObjWithAgrmt.Invoice_Contact_Email__c != null) {
                toAddress.add(amaObjWithAgrmt.Invoice_Contact_Email__c);
            }
            
            List<String> ccTo = new List<String>{amaObjWithAgrmt.TPA_Request__r.ClientContact__r.Email};

            if(amaObjWithAgrmt.TPA_Request__r.Client_TPA_Representative_Email__c != null && amaObjWithAgrmt.TPA_Request__r.Client_TPA_Representative_Email__c != ''){
                ccTo.add(amaObjWithAgrmt.TPA_Request__r.Client_TPA_Representative_Email__c);
            }

            if(amaObjWithAgrmt.TPA_Request__r.Owner.Type != null && amaObjWithAgrmt.TPA_Request__r.Owner.Type == 'Queue' && amaObjWithAgrmt.TPA_Request__r.Owner.Email != null){
                ccTo.add(amaObjWithAgrmt.TPA_Request__r.Owner.Email);
            }
            
            ccTo.addAll(amaSetting.get(0).TP_US_Email_Id__c.split(';'));
            if(UTL_TPA.isSendOutgoingEmails && !Test.isRunningTest()) {
                /*SRV_TPA_TPARequest.addTPProcessorInitials = true;
                if(amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Is_Active__c) {
                    SRV_TPA_TPARequest.assignedTPProcessorName = amaAgrObj.TPA_Request__r.TPA_Assigned_TP_Processor__r.Initials__c;
                }*/
                SRV_TPA_TPARequest.sendEmailThroughWorkflow(toAddress, ccTo, 'SendEmail', templateId, amaAgrObj.Id, null, '', FALSE, '', FALSE, FALSE, tpaRequest);
                //SRV_TPA_TPARequest.addTPProcessorInitials = false;
            }
            return;

        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            UTL_LogFactory.getLogLst().Add(UTL_LogFactory.generateAndCommitLog(FALSE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::BCH_TPA_Send_AMA_Renewal_Mail_Annua:::createRenewalNotificationToVendor', amaAgrObj != null ? amaAgrObj.Id : ''));
            UTL_LogFactory.saveLogs(UTL_LogFactory.getLogLst(), TRUE);       
            System.debug('Send Renewal notification Annually failed: ' + e.getMessage());
            return ;
        }
    }
}
