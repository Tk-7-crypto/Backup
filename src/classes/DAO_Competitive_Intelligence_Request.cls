/**
* This is Competitive Intelligence Request trigger handler class.
* version : 1.0
*/ 
public class DAO_Competitive_Intelligence_Request extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<Opportunity>
     */
    public DAO_Competitive_Intelligence_Request(List<Competitive_Intelligence_Request__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Competitive_Intelligence_Request(sObjectList);
        }
    }
    
    /**
     * This method is used for before update.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Competitive_Intelligence_Req.updatedFieldValue((List<Competitive_Intelligence_Request__c>)Records, (Map<Id, Competitive_Intelligence_Request__c>)existingRecords);
    }
    
}