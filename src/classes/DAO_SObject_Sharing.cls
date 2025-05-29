/**
* This is SObject Sharing trigger handler class.
* version : 1.0
*/ 
public class DAO_SObject_Sharing extends fflib_SObjectDomain{
    
    /**
		* Constructor of this class
		* @params sObjectList List<Territory2>
	*/
    public DAO_SObject_Sharing(List<SObject_Sharing__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
		* Constructor Class for construct new Instance of This Class
	*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_SObject_Sharing(sObjectList);
        }
    }
    
    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert(){
        DAOH_SObject_Sharing.createTerritorySharingObj((List<SObject_Sharing__c>)Records, null);
    }
    
    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        DAOH_SObject_Sharing.createTerritorySharingObj((List<SObject_Sharing__c>)Records, (Map<Id,SObject_Sharing__c>)existingRecords);
        
    }
}