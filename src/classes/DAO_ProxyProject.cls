public with sharing class DAO_ProxyProject extends fflib_SObjectDomain {

    /**
    * Constructor of this class
    * @params sObjectList List<Proxy_Project__c>
    */
    public DAO_ProxyProject(List<Proxy_Project__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ProxyProject(sObjectList);
        }
    }
    
     /**
     * This method is used for before insert of the Proxy_Project__c trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_ProxyProject.setQIOLIId((List<Proxy_Project__c>)Records, null);
        DAOH_ProxyProject.updateProjectFieldsFromContact((List<Proxy_Project__c>)Records);
    }
    /**
     * This method is used for before update of the Proxy_Project__c trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_ProxyProject.setQIOLIId((List<Proxy_Project__c>)Records, (Map<Id, Proxy_Project__c>)existingRecords);
        DAOH_ProxyProject.updateProjectFieldsFromContact((List<Proxy_Project__c>)Records);
    }
    
    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert() {   
        
    }
    
    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_ProxyProject.updateSurveyPIC((List<Proxy_Project__c>)Records, (Map<Id, Proxy_Project__c>)existingRecords);
        DAOH_ProxyProject.setOLIDates((List<Proxy_Project__c>)Records, (Map<Id, Proxy_Project__c>)existingRecords);
    }
}