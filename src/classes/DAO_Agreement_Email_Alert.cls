/**
* This is Agreement Email Alert trigger handler class.
* version : 1.0
*/ 
public class DAO_Agreement_Email_Alert extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<Agreement_Email_Alert__c>
     */
    public DAO_Agreement_Email_Alert(List<Agreement_Email_Alert__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Agreement_Email_Alert(sObjectList);
        }
    }
    
    /**
    * Override method Before Insert Call
    */
    public override void onBeforeInsert(){
        DAOH_Agreement_Email_Alert.checkUserPermissionForUpdate((List<Agreement_Email_Alert__c>)Records, Null);
    }
    
    /**
     * This method is used for before update.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Agreement_Email_Alert.checkUserPermissionForUpdate((List<Agreement_Email_Alert__c>)Records, (Map<Id, Agreement_Email_Alert__c>)existingRecords);
    }
}