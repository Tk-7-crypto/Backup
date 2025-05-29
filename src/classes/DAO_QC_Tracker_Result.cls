/**
 * This is QC Tracker Result (QC_Tracker_Result__c) trigger handler class.
 * version : 1.0
 */
public class DAO_QC_Tracker_Result extends fflib_SObjectDomain{

    /**
     * Constructor of this class
     * @params sObjectList List<QC_Tracker_Result__c>
     */
    public DAO_QC_Tracker_Result(List<QC_Tracker_Result__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_QC_Tracker_Result(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the QC_Tracker_Result__c  trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_QC_Tracker_Result.populateAggregateReportFieldOnQCT((List<QC_Tracker_Result__c>)Records,null); 
    }

    /**
     * This method is used for before update of the QC_Tracker_Result__c  trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_QC_Tracker_Result.populateAggregateReportFieldOnQCT((List<QC_Tracker_Result__c>)Records,(Map<Id,QC_Tracker_Result__c>) existingRecords);
    }
    
    /**
     * This method is used for after insert of the QC_Tracker_Result__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_QC_Tracker_Result.validateQCTonAggRep((List<QC_Tracker_Result__c>)records, null);
        DAOH_QC_Tracker_Result.validateQCTonSandozAggRep((List<QC_Tracker_Result__c>)records, null);
    }
    
    /**
     * This method is used for after update of the QC_Tracker_Result__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_QC_Tracker_Result.validateQCTonAggRep((List<QC_Tracker_Result__c>)records, (Map<Id,QC_Tracker_Result__c>) existingRecords);
        DAOH_QC_Tracker_Result.validateQCTonSandozAggRep((List<QC_Tracker_Result__c>)records, (Map<Id,QC_Tracker_Result__c>) existingRecords);
    }


}
