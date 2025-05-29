public class DAO_DataPortalQueueUserdetails extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<CSM_QI_Data_Portal_Queue_User_details__c>
     */
    public DAO_DataPortalQueueUserdetails(List<CSM_QI_Data_Portal_Queue_User_details__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_DataPortalQueueUserdetails(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the case trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_DataPortalQueueUserdetails.getDefaultAccountQueueConfig((List<CSM_QI_Data_Portal_Queue_User_details__c>)Records);
    }
    
        /**
     * This method is used for before insert of the case trigger.
     * @return void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_DataPortalQueueUserdetails.getDefaultAccountQueueConfig((List<CSM_QI_Data_Portal_Queue_User_details__c>)Records);
    }
}