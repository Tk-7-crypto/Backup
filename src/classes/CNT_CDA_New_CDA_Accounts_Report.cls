/**
 * @Author  : Babita Dadarwal
 * @Name    : CNT_CDA_New_CDA_Accounts_Report
 * @Purpose : Controller of the VFP_CDA_New_CDA_Accounts_Report Page.
 */
public with sharing class CNT_CDA_New_CDA_Accounts_Report {
    private final static Integer REPORT_INTERVAL = 7;
    private final static String EMAIL_ATTACHMENT_NAME = 'New_CDA_Accounts_Report.xls';

    public transient List<cdaAccountWrapper> cdaAccountWrapperList {get; set;}

    // Constructor
    public CNT_CDA_New_CDA_Accounts_Report() {
        loadData();
    }

    /**
     * Name : loadData
     * This Method is used to load all CDA Account that were created in last 7 days.
     */
    public void loadData() {
        cdaAccountWrapperList = new List<cdaAccountWrapper>();
        String query = '';
        query += 'SELECT Id, Name, CDA_Type__c, Date_executed_signed_contract_received__c';
        query += ', Cust_Legal_Entity_Name__c, Cust_Legal_Entity_Name__r.Name, Cust_Legal_Entity_Name__r.Complete_Address__c, Cust_Legal_Entity_Name__r.CreatedDate';
        query += ', Recipient_Account__c, Recipient_Account__r.Name, Recipient_Account__r.Complete_Address__c, Recipient_Account__r.CreatedDate';
        query += ', Sponsor_Legal_Entity__c, RecordTypeId'; //Updated by Vikram Singh under CR-11691
        query += ' FROM CDA_Request__c';
        query += ' WHERE ((Cust_Legal_Entity_Name__r.CreatedDate = LAST_N_DAYS : ' + REPORT_INTERVAL + ' AND Cust_Legal_Entity_Name__r.Account_Source__c = \'' + UTL_CDAUtility.CDA_ACCOUNT_SOURCE + '\')';
        query += ' OR (Recipient_Account__r.CreatedDate = LAST_N_DAYS : ' + REPORT_INTERVAL + ' AND Recipient_Account__r.Account_Source__c = \'' + UTL_CDAUtility.CDA_ACCOUNT_SOURCE + '\'))';
        query += ' AND RecordType.Name != \''+UTL_CDAUtility.historicalDataRecordType+'\''; //Added by Vikram Singh under CR-11691
        //query += ' OR (Sponsor_Legal_Entity__r.CreatedDate = LAST_N_DAYS : ' + REPORT_INTERVAL + ' AND Sponsor_Legal_Entity__r.Account_Source__c = \'' + UTL_CDAUtility.CDA_ACCOUNT_SOURCE + '\'))';
        query += ' ORDER BY Date_executed_signed_contract_received__c asc';

        list<CDA_Request__c> cdaRequestList = Database.query(query);
        Set<Id> cdaAccIdSet = new Set<Id>();

        for(CDA_Request__c cdaRequest : cdaRequestList) {

            if(!cdaAccIdSet.contains(cdaRequest.Cust_Legal_Entity_Name__c)
            && cdaRequest.Cust_Legal_Entity_Name__r.CreatedDate >= cdaRequest.Date_executed_signed_contract_received__c) {
                cdaAccountWrapper wrapObj = new cdaAccountWrapper();
                wrapObj.cdaRequestName = cdaRequest.Name;
                wrapObj.cdaRequestType = cdaRequest.CDA_Type__c;
                wrapObj.cdaAccountName = cdaRequest.Cust_Legal_Entity_Name__r.Name;
                wrapObj.cdaAccountAddress = cdaRequest.Cust_Legal_Entity_Name__r.Complete_Address__c;
                cdaAccountWrapperList.add(wrapObj);
                cdaAccIdSet.add(cdaRequest.Cust_Legal_Entity_Name__c);
            }
            if(!cdaAccIdSet.contains(cdaRequest.Recipient_Account__c)
            && cdaRequest.Recipient_Account__r.CreatedDate >= cdaRequest.Date_executed_signed_contract_received__c) {
                cdaAccountWrapper wrapObj = new cdaAccountWrapper();
                wrapObj.cdaRequestName = cdaRequest.Name;
                wrapObj.cdaRequestType = cdaRequest.CDA_Type__c;
                wrapObj.cdaAccountName = cdaRequest.Recipient_Account__r.Name;
                wrapObj.cdaAccountAddress = cdaRequest.Recipient_Account__r.Complete_Address__c;
                cdaAccountWrapperList.add(wrapObj);
                cdaAccIdSet.add(cdaRequest.Recipient_Account__c);
            }
        }
    }

    /**
     * Name : sendWeeklyNewCdaAccountsReport
     * This method sends a weekly report of all newly created CDA accounts in last 7 days.
     */
    public void sendWeeklyNewCdaAccountsReport() {
        String reportHeading = UTL_CDAUtility.CDA_REQUEST_TYPE + '\t' + UTL_CDAUtility.CDA_REQUEST_NUMBER + '\t' + UTL_CDAUtility.CDA_ACCOUNT_NAME + '\t' + UTL_CDAUtility.CDA_ACCOUNT_ADDRESS;
        String reportContent = '';
        for(cdaAccountWrapper wrapObj : cdaAccountWrapperList) {
            reportContent += wrapObj.cdaRequestType + '\t' + wrapObj.cdaRequestName + '\t' + wrapObj.cdaAccountName + '\t' + wrapObj.cdaAccountAddress + '\t\n';
        }

        Blob b = Blob.valueof(reportHeading + '\n\n' + reportContent);

        Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
        emailAttach.setFileName(EMAIL_ATTACHMENT_NAME);
        emailAttach.setBody(b);

        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setCharset('UTF-8');
        emailToSend.setPlainTextBody('Please find attached new CDA accounts report created in last 7 days.');
        emailToSend.setSubject('New CDA Accounts Report');

        List<String> toRecipients = new List<String>();

        //Fecth and assign to-recepient
        CDA_Settings__c settings = CDA_Settings__c.getOrgDefaults();
        if(settings != null && settings.New_CDA_Accounts_Report_Recipients__c != null){
            toRecipients.addAll(settings.New_CDA_Accounts_Report_Recipients__c.split(';'));
        }

        //toRecipients.add('babita.dadarwal@metacube.com');

        emailToSend.setToAddresses(toRecipients);

        if(UTL_CDAUtility.multiLingualTemplateSettingsMap.get(UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID) != null
        && UTL_CDAUtility.multiLingualTemplateSettingsMap.get(UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID).Template_Id__c != null) {
            emailToSend.setOrgWideEmailAddressId(UTL_CDAUtility.multiLingualTemplateSettingsMap.get(UTL_CDAUtility.CDA_ORG_WIDE_EMAIL_ID).Template_Id__c);
        }

        emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttach});

        try
        {
            if(UTL_CDAUtility.isSendOutgoingEmails && !Test.isRunningTest()) {
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
            }
        }
        catch(Exception e)
        {
            System.debug('CDA New CDA Accounts Report Email Failed: ' + e.getMessage());
        }
    }

    /**
     * Name : cdaAccountWrapper
     * This wrapper class is used to store all newly inserted CDA Accouts with CDA request information.
     */
    private class cdaAccountWrapper {
        private string cdaRequestName;
        private string cdaRequestType;
        private string cdaAccountName;
        private string cdaAccountAddress;
    }
}