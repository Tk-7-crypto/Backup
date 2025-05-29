public class DAOH_TpaOffNotificationAccountMap {
    static Map<ID, TPA_Offering_Notification_Mapping__c> parenRules = new Map<ID, TPA_Offering_Notification_Mapping__c>();
    static List<Id> listIds = new List<Id>();
	
    public static void updateParentRules(List<TPA_Off_Notification_Account_Mapping__c> recordsToUpdate) {
        listIds = new List<Id>();
        for (TPA_Off_Notification_Account_Mapping__c childObj : recordsToUpdate) {
            listIds.add(childObj.TPA_Offering_Notification_Mapping_Rule__c);
        }
        
        parenRules = new Map<Id, TPA_Offering_Notification_Mapping__c>([SELECT id, Vendor_Accounts_Name__c, (select id, Vendor_Account_Address__c, Vendor_Account_Address__r.Name, Vendor_Account_Address__r.id from TPA_Off_Notification_Account_Mapping__r) FROM TPA_Offering_Notification_Mapping__c WHERE ID IN :listIds]);
    
    	String address = '';
        for (TPA_Off_Notification_Account_Mapping__c childObj: recordsToUpdate) {
            TPA_Offering_Notification_Mapping__c myParentOpp = parenRules.get(childObj.TPA_Offering_Notification_Mapping_Rule__c);
            address = '';
            for(TPA_Off_Notification_Account_Mapping__c obj : myParentOpp.TPA_Off_Notification_Account_Mapping__r) {
                address += obj.Vendor_Account_Address__r.Name + '; ';
            }
            myParentOpp.Vendor_Accounts_Name__c = address;
            myParentOpp.Is_Vendor_Specific_Rule__c  = true;
        }
        
        if(parenRules != null) {
            update parenRules.values();
        }
    }
}
