/**
 * Author : Ronak Mehta
 * Created Date : 08-11-2024
 * This is Site_Submission__c trigger handler class.
 **/
public class DAO_Site_Submission extends fflib_SObjectDomain {
    
    //Constructor of this class
    public DAO_Site_Submission(List<Site_Submission__c> sObjectList) {
        super(sObjectList);
    }
    
    //Constructor Class for construct new Instance of This Class
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Site_Submission(sObjectList);
        }
    }
    
    //Override method Before Insert Call
    public override void onBeforeInsert(){
        DAOH_Site_Submission.setDefaultvalue((List<Site_Submission__c>)Records, null);
        DAOH_Site_Submission.setRiskAdjustedOpportunityEstimate((List<Site_Submission__c>)Records);
    }
    
    /**
     * This method is used for before update of the Account trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Site_Submission.setRiskAdjustedOpportunityEstimate((List<Site_Submission__c>)Records);
    }
    
}
