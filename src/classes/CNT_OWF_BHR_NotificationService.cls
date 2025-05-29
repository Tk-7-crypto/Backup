public class CNT_OWF_BHR_NotificationService {

    public CNT_OWF_BHR_NotificationService(ApexPages.StandardController controller) {
        
    }
    
    @AuraEnabled
    Public static void getBidHistoryDetailsAndValidate(Id recordId)
    {
        Set<String> bhrFieldSet = new Set<String>{'Is_this_part_of_a_Program__c',/*'Number_of_Scenarios__c',*/
            'Targeted_Countries__c','Bid_History_Related_Opportunity__c','Bid_History_Related_Opportunity__r.Account.Name','RecordTypeId'};
        Bid_History__c bidHistoryRecord = new SLT_Bid_History(false,false).
                getBidHistoriesById(new Set<Id>{recordId},bhrFieldSet).values()[0];
		List<String> selectedTargetedCountriesList = bidHistoryRecord.Targeted_Countries__c.split(';');  
		OWF_Config__c owfConfig = OWF_Config__c.getInstance();
        if(owfConfig.Enable_Agreement_Notification_Service__c && bidHistoryRecord.RecordTypeId == CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID)
        {
            
            if(((!bidHistoryRecord.Bid_History_Related_Opportunity__r.Account.Name.contains(owfConfig.GSK_Account_Name__c))
            ||
            (bidHistoryRecord.Is_this_part_of_a_Program__c == 'Not part of a program')
            ||(bidHistoryRecord.Number_of_Scenarios__c == 2 ||bidHistoryRecord.Number_of_Scenarios__c == 1)
            ||!(selectedTargetedCountriesList.contains('JP')))){
                throw new AuraHandledException('Your RFP is eligible to use the CRM UPT-SF tool,'
                                                + '\n' +' please select ‘Create Budget’ and continue');
        }  
        }
        
    }
} 