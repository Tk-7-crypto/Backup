public class DAO_TPAAMAClientVendorSearchMap extends fflib_SObjectDomain {

	/**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_TPAAMAClientVendorSearchMap(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TPAAMAClientVendorSearchMap(sObjectList);
        }
    }
    
    /**
     * This method is used for before update of the TPA_AMA_Client_Vendor_Search_Map__c trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onafterinsert() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPAAMAClientVendorSearchMap.onAfterInsert((List<TPA_AMA_Client_Vendor_Search_Map__c>)Records);
        }
    }
    
    /**
     * This method is used for after update of the TPA_AMA_Client_Vendor_Search_Map__c trigger.
     * @return void
     */    
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) { 
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            DAOH_TPAAMAClientVendorSearchMap.onAfterUpdate((List<TPA_AMA_Client_Vendor_Search_Map__c>)Records, existingRecords.values(), new Map<Id, TPA_AMA_Client_Vendor_Search_Map__c>((List<TPA_AMA_Client_Vendor_Search_Map__c>)Records), (Map<Id, TPA_AMA_Client_Vendor_Search_Map__c>)existingRecords);
        }
    }
}