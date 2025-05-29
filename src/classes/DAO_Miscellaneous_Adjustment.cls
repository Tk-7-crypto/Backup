public class DAO_Miscellaneous_Adjustment extends fflib_SObjectDomain{
    
 /**
 * This is Miscellaneous Adjustment (pse__Miscellaneous_Adjustment__c) trigger handler class.
 * version : 1.0
 */
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<pse__Miscellaneous_Adjustment__c>
     */
    public DAO_Miscellaneous_Adjustment(List<pse__Miscellaneous_Adjustment__c> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Miscellaneous_Adjustment(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
			DAOH_PSA_Miscellaneous_Adjustment.updateFieldsOnStatusUpdate((List<pse__Miscellaneous_Adjustment__c>)Records, (Map<Id,pse__Miscellaneous_Adjustment__c>) existingRecords);
    }
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
			DAOH_PSA_Miscellaneous_Adjustment.updateFieldsOnStatusUpdate((List<pse__Miscellaneous_Adjustment__c>)Records, (Map<Id,pse__Miscellaneous_Adjustment__c>) existingRecords);
    }
}
