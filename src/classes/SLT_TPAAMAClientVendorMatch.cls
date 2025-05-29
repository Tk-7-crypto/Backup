public with sharing class SLT_TPAAMAClientVendorMatch extends fflib_SObjectSelector {
	public Schema.SObjectType getSObjectType() {
		return TPA_AMA_Client_Vendor_Match__c.sObjectType;
	}
 	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			TPA_AMA_Client_Vendor_Match__c.Client_Name__c,
			TPA_AMA_Client_Vendor_Match__c.Truncated_Name__c,
			TPA_AMA_Client_Vendor_Match__c.Name,
			TPA_AMA_Client_Vendor_Match__c.Mapped_Account_Id__c,
			TPA_AMA_Client_Vendor_Match__c.Mapped_Account_Name__c, 
			TPA_AMA_Client_Vendor_Match__c.IMS_Client_Names__c, 
			TPA_AMA_Client_Vendor_Match__c.IMS_Total_Clients__c, 
			TPA_AMA_Client_Vendor_Match__c.Id, 
			TPA_AMA_Client_Vendor_Match__c.TPA_Account_Address__c
		};
	}
	
	public List<TPA_AMA_Client_Vendor_Match__c> getTPAAMAClientVendorMatchData(String orderByField){
		return (List<TPA_AMA_Client_Vendor_Match__c>)Database.query(newQueryFactory(true).addOrdering(orderByField, fflib_QueryFactory.SortOrder.DESCENDING).toSOQL());
	}
	
	public List<TPA_AMA_Client_Vendor_Match__c> getTPAAMAClientVendorMatchDataByCondition(String condition){
		return (List<TPA_AMA_Client_Vendor_Match__c>)Database.query(newQueryFactory(true).setCondition(condition).toSOQL());
	}
	
	public static SLT_TPAAMAClientVendorMatch instance = new SLT_TPAAMAClientVendorMatch();
}