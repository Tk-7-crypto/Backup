@isTest
public class TST_DAOH_TpaOffNotificationAccountMap { 
	@isTest
    static void DAOH_TpaOffNotificationAccountMapTest1(){
        Address__c acc = UTL_TPA_SetupTestData.getAddress();
        insert acc;
        
        TPA_Offering_Notification_Mapping__c tpaOffNotifMap1 = new TPA_Offering_Notification_Mapping__c();
        insert tpaOffNotifMap1;
        
        TPA_Off_Notification_Account_Mapping__c tpaOffNotifAccMap = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = acc.Id, TPA_Offering_Notification_Mapping_Rule__c = tpaOffNotifMap1.Id);
        insert tpaOffNotifAccMap;
        
        DAOH_TpaOffNotificationAccountMap.updateParentRules(new List<TPA_Off_Notification_Account_Mapping__c>{tpaOffNotifAccMap});
    }
}