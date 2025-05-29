/**
 * This is the Report Drug (Report_Drug__c) trigger handler class.
 * version : 1.0
 */

public class DAO_Report_Drug extends fflib_SObjectDomain{
    private static Map<String, Set<String>> methodToRecordTypeMap = new Map<String, Set<String>>();

    /**
     * Constructor of this class
     * @params sObjectList List<Report_Drug__c>
     */
    public DAO_Report_Drug(List<Report_Drug__c> sObjectList) {
        super(sObjectList);

        methodToRecordTypeMap = new SLT_Apex_RecordType_Control().getRecordTypeControlMap((String)sObjectList.getSObjectType().getDescribe().getName());
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Report_Drug(sObjectList);
        } 
    }
    
    /**
     * This method is used for before insert of the Report_Drug__c  trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Report_Drug.validateFields((List<Report_Drug__c>)Records, null);
    }

    /**
     * This method is used for after insert of the Report_Drug__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
       	DAOH_Report_Drug.updateAggregateReportSanofiProducts((List<Report_Drug__c>)Records, null);

    }

    /**
     * This method is used for before update of the Report_Drug__c  trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
		DAOH_Report_Drug.validateFields((List<Report_Drug__c>)Records, (Map<Id,Report_Drug__c>) existingRecords);
    }

    /**
     * This method is used for after update of the Aggregate_Report__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
    	DAOH_Report_Drug.updateAggregateReportSanofiProducts((List<Report_Drug__c>)Records, (Map<Id,Report_Drug__c>) existingRecords);
    }

    /**
     * This method is used for before delete of the Report_Drug__c trigger.
     * @return void
     */
    public override void onBeforeDelete() {
    }

    /**
     * This method is used for after insert of the Report_Drug__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
      	DAOH_Report_Drug.deleteFromSanofiProducts((List<Report_Drug__c>)Records);
    }

    /**
     * This method is used for after undelete of the Report_Drug__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        
    }
}
