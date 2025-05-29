public with sharing class SLT_TPAAMAClientVendorSearchMap extends fflib_SObjectSelector {
	public Schema.SObjectType getSObjectType() {
		return TPA_AMA_Client_Vendor_Search_Map__c.sObjectType;
	}
 	
	public List<Schema.SObjectField> getSObjectFieldList() { 
		return new List<Schema.SObjectField> {
			TPA_AMA_Client_Vendor_Search_Map__c.Id,
			TPA_AMA_Client_Vendor_Search_Map__c.Name,
			TPA_AMA_Client_Vendor_Search_Map__c.AMA_Account_Search_Text__c,
			TPA_AMA_Client_Vendor_Search_Map__c.Business_Remarks_Notes__c,
			TPA_AMA_Client_Vendor_Search_Map__c.TPA_Account_Address__c
		};
	}
	
	public List<TPA_AMA_Client_Vendor_Search_Map__c> getTPAAMAClientVendorSearchMapDataByCondition(String condition){
		return (List<TPA_AMA_Client_Vendor_Search_Map__c>)Database.query(newQueryFactory(true).setCondition(condition).toSOQL());
	}
	
	public static SLT_TPAAMAClientVendorSearchMap instance = new SLT_TPAAMAClientVendorSearchMap();
}