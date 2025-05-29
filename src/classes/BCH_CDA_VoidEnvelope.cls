/*
 * Author :  Sweta Sharma
 * Purpose : Batch class to void Envelope. Details : ER-3556 Date : 16th May 2017  
 */
global class BCH_CDA_VoidEnvelope implements Database.Batchable < sObject > , Database.AllowsCallouts {

    Set < id > list_DS_StatusIds;

    /**
     * Method to initialize the docusign status id set.
     */
    public void setStatusIds(Set < id > list_DS_StatusIds) {
        this.list_DS_StatusIds = list_DS_StatusIds;
    }

    /**
     * Start Mehod of Batch.
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Updated by Babita Dadarwal under Item #26 Start
        return Database.getQueryLocator([select id, dsfs__DocuSign_Envelope_ID__c, 
                                                CDA_Request__c, 
                                                CDA_Request__r.Status__c,
                                                CDA_Request__r.CDA_Id__c,
                                                CDA_Request__r.Recipient_Account_Name_Formula__c 
                                         from dsfs__DocuSign_Status__c 
                                         where id in: list_DS_StatusIds]);
        // Updated by Babita Dadarwal under Item #26 End
    }

    /**
     * Execute Method of Batch.
     */
    global void execute(Database.BatchableContext BC, List < dsfs__DocuSign_Status__c > list_DS_StatusRecords) {
        // Updated by Babita Dadarwal under Item #26 Start
        // String str = list_DS_StatusRecords.get(0).CDA_Request__r.Recipient_Account_Name_Formula__c + ' and ' + list_DS_StatusRecords.get(0).CDA_Request__r.QI_Legal_Entity_Name__r.name + ' has been voided.  This request may have been voided either because changes were requested or because the request was canceled by QuintilesIMs or ' + list_DS_StatusRecords.get(0).CDA_Request__r.QI_Legal_Entity_Name__r.name;
        String str = '';
        List<String> parameters = new List<String>();

        parameters.add(String.valueOf(list_DS_StatusRecords.get(0).CDA_Request__r.get('CDA_Id__c')));
        parameters.add(list_DS_StatusRecords.get(0).CDA_Request__r.Recipient_Account_Name_Formula__c);

        if(list_DS_StatusRecords.get(0).CDA_Request__r.Status__c == UTL_CDAUtility.STATUS_CANCELEDBYREQUESTOR) {
            // str = 'This request has been cancelled.';
            str = String.format(Label.CDA_Void_Reason_For_Request_Canceled_By_Requestor, parameters);
        }
        // Added by Babita Dadarwal under CR-11539 Start
        else if(list_DS_StatusRecords.get(0).CDA_Request__r.Status__c == UTL_CDAUtility.STATUS_CONTRACTEXECUTED) {
            str = Label.CDA_Void_Reason_For_Contract_Executed_Request;
        }
        // Added by Babita Dadarwal under CR-11539 End
        else {
            str = Label.CDA_Void_Reason_For_Request_Recall; //Updated by Babita Dadarwal under CR-11387
        }
        SRV_CDA_DocusignStatus.voidEnvelope(list_DS_StatusRecords.get(0).dsfs__DocuSign_Envelope_ID__c,str);
        //SRV_CDA_DocusignStatus.voidEnvelope(list_DS_StatusRecords.get(0).dsfs__DocuSign_Envelope_ID__c, 'Again Submitted for Signature process with modified Request.');
        // Updated by Babita Dadarwal under Item #26 End 
        
    }

    /**
     * Finish Method of Batch.
     */
    global void finish(Database.BatchableContext BC) {}
}