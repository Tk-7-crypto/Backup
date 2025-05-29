/**
 * This is Sd Run (SD_Runs__c) trigger handler class.
 * version : 1.0
 */
public class DAO_Sd_Run extends fflib_SObjectDomain{
    
    public static Decimal autoNumber = 0;

    /**
     * Constructor of this class
     * @params sObjectList List<SD_Runs__c>
     */
    public DAO_Sd_Run(List<SD_Runs__c> sObjectList){
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable{
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Sd_Run(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the SD_Runs__c  trigger.
     * @return void
     */
    public override void onBeforeInsert(){
      //DAOH_Sd_Run.populateSdRunIdField((List<SD_Runs__c>)Records,null); 
      DAOH_Sd_Run.populateSdRunUniqueId((List<SD_Runs__c>)Records,null); 
      DAOH_Sd_Run.validateSDRunFields((List<SD_Runs__c>)Records,null);
    }  
    
    /**
    * This method is used for before update of the SD_Runs__c  trigger.
    * @return void
    */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Sd_Run.validateSDRunFields((List<SD_Runs__c>)Records,(Map<Id,SD_Runs__c>) existingRecords);
    }
    
    /**
     * This method is used for after insert of the SD_Runs__c  trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Sd_Run.synchronizeProjectEvents((List<SD_Runs__c>)Records, null);
        DAOH_Sd_Run.createDeliverables((List<SD_Runs__c>)Records, null);
        DAOH_Sd_Run.insertAuditLogOnUpdate((List<SD_Runs__c>)Records, null);
        if(Mulesoft_Integration_Control__c.getInstance() != null 
           && (Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c 
               || !Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c))
        {
            DAOH_Sd_Run.sendEmailNotification((List<SD_Runs__c>)Records,null);
        }
    }

    
    /**
     * This method is used for after update of the SD_Runs__c trigger.
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Sd_Run.synchronizeProjectEvents((List<SD_Runs__c>)Records, null);
        DAOH_Sd_Run.createDeliverables((List<SD_Runs__c>)Records, (Map<Id,SD_Runs__c>) existingRecords);
        DAOH_Sd_Run.insertAuditLogOnUpdate((List<SD_Runs__c>)Records, (Map<Id,SD_Runs__c>) existingRecords);
        System.debug('Limits insertAuditLogOnUpdate: '+Limits.getQueries());
        DAOH_Sd_Run.updtRltdPJEToUpdtReciepients((List<SD_Runs__c>)Records, (Map<Id,SD_Runs__c>) existingRecords);
        if(Mulesoft_Integration_Control__c.getInstance() != null 
           && (Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c 
               || !Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c))
        {
            DAOH_Sd_Run.sendEmailNotification((List<SD_Runs__c>)Records,(Map<Id,SD_Runs__c>) existingRecords);
        }
    }
    /**
     * This method is used for after delete of the SD_Runs__c trigger.
     * @return void
     */
    public override void onAfterDelete() {
        DAOH_Sd_Run.insertAuditLog((List<SD_Runs__c>)Records,'DELETE');
    }
    /**
     * This method is used for after undelete of the SD_Runs__c trigger.
     * @return void
     */
    public override void onAfterUnDelete() {
        DAOH_Sd_Run.synchronizeProjectEvents((List<SD_Runs__c>)Records, null);
        DAOH_Sd_Run.insertAuditLog((List<SD_Runs__c>)Records,'UNDELETE');
    } 
} 
