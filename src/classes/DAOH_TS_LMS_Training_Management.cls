public class DAOH_TS_LMS_Training_Management {
	public static void setAccountOfContact(List<TS_LMS_Training_Management__c> Records)
    {
        Set<Id> ids = new Set<Id>();
        for(TS_LMS_Training_Management__c ttm : Records){
            ids.add(ttm.Contact__c);
        }
        List<Contact> contactsList;
        if(ids !=null && ids.size()>0){
           contactsList = new SLT_Contact().getContactEmails(ids);
        }
        Map<Id,Id> accId = new Map<Id,Id>();
        if(contactsList != null  && contactsList.size() > 0){
            for(Contact c : contactsList){
                accId.put(c.Id,c.AccountId);
            }
        }
 		for(TS_LMS_Training_Management__c ttm : Records){
            if(accId.containsKey(ttm.Contact__c)){
                ttm.Account_Name__c = accId.get(ttm.Contact__c);
            }
        }
    }
}