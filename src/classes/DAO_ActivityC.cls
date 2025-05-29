public class DAO_ActivityC extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<Case>
    */
    public DAO_ActivityC(List<Activity__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ActivityC(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Activity__c trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_ActivityC.updateActivityAutoFillSiteContactStudy((List<Activity__c>)Records,null); 
    }
    
    /**
    * This method is used for before insert of the Activity__c trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_ActivityC.updateActivityAutoFillSiteContactStudy((List<Activity__c>)Records,(Map<Id,Activity__c>)existingRecords); 
        DAOH_ActivityC.checkForAttachmentOnRDCaseActivities((List<Activity__c>)Records, (Map<Id,Activity__c>)existingRecords);
    }
    
    /**
    * This method is used for before insert of the Activity__c trigger.
    * @return void
    */
    public override void onAfterInsert() {
        DAOH_ActivityC.saveAuditLogAfterInsertActivityC((List<Activity__c>)Records); 
        DAOH_ActivityC.sendOutlookMeetingRequest((List<Activity__c>)Records, null);
        DAOH_ActivityC.addTimesheet((List<Activity__c>)Records,null);
        DAOH_ActivityC.updateCaseFields((List<Activity__c>)Records, null);
    }
    /**
    * This method is used for before update of the Activity__c trigger.
    * @params  existingRecords Map<Id,SObject>
    * @return  void
    */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.S_ACTIVITYC);
        
        if(fields != null){ 
            DAOH_ActivityC.saveAuditLogAfterUpdateActivityCFields((List<Activity__c>)Records,(Map<Id,Activity__c>)existingRecords,fields); 
        }
        DAOH_ActivityC.sendOutlookMeetingRequest((List<Activity__c>)Records, (Map<Id, Activity__c>)existingRecords);
        DAOH_ActivityC.addTimesheet((List<Activity__c>)Records, (Map<Id, Activity__c>)existingRecords);
        DAOH_ActivityC.updateCaseFields((List<Activity__c>)Records, (Map<Id, Activity__c>)existingRecords);
    }
}