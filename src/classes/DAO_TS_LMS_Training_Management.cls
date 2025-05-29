public class DAO_TS_LMS_Training_Management extends fflib_SObjectDomain {

    /**
    * Constructor of this class
    * @params sObjectList List<TS_LMS_Training_Management__c>
    */
    public DAO_TS_LMS_Training_Management(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TS_LMS_Training_Management(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the TS_LMS_Training_Management__c trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_TS_LMS_Training_Management.setAccountOfContact((List<TS_LMS_Training_Management__c>)Records);
    }
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_TS_LMS_Training_Management.setAccountOfContact((List<TS_LMS_Training_Management__c>)Records);
    }
}