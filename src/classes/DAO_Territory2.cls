/**
 * This is Territory2 trigger handler class.
 * version : 1.0
 */ 
public class DAO_Territory2 extends fflib_SObjectDomain{
    
    /**
     * Constructor of this class
     * @params sObjectList List<Territory2>
     */
    public DAO_Territory2(List<Territory2> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Territory2(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the opportunity trigger.
     * @return void
     */
    public override void onBeforeInsert() {
        DAOH_Territory2.setLeafNode((List<Territory2>)Records, null);
    }
    
    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert(){
        DAOH_Territory2.setLeafNode((List<Territory2>)Records, null);
    }
    
    /**
     * Override method After Update Call
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        DAOH_Territory2.setLeafNode((List<Territory2>)Records, (Map<Id,Territory2>)existingRecords);
    }
    
    /**
     * Override method Before Delete Call
     */
    public override void onAfterDelete(){
        DAOH_Territory2.setLeafNode((List<Territory2>)Records, null);    
    }

}