public class DAO_Budget extends fflib_SObjectDomain {
    
   /**
 * This is Budget (pse__Budget__c) trigger handler class.
 * version : 1.0
 */
    
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<pse__Budget__c>
     */
    public DAO_Budget(List<pse__Budget__c> sObjectList) {
        super(sObjectList);
        Configuration.disableTriggerCRUDSecurity();
        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Budget(sObjectList);
        }
    }
    
    public override void onBeforeInsert() {
			DAOH_PSA_Budget.updateFieldsOnStatusUpdate((List<pse__Budget__c>)Records, (Map<Id,pse__Budget__c>) existingRecords);
    }
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
			DAOH_PSA_Budget.updateFieldsOnStatusUpdate((List<pse__Budget__c>)Records, (Map<Id,pse__Budget__c>) existingRecords);
    }
}
