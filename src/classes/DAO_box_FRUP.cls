/**
 * This is FRUP trigger handler class.
 * version : 1.0
 */ 
public class DAO_box_FRUP extends fflib_SObjectDomain{
    
	/**
     * Constructor of this class
     * @params sObjectList List<box__FRUP__c>
     */
    public DAO_box_FRUP(List<Opportunity> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_box_FRUP(sObjectList);
        }
    }
    
    /**
     * Override method After Insert Call
     */
    public override void onAfterInsert(){
        DAOH_box_FRUP.generateBoxFolderURLonOpp((List<box__FRUP__c>)records);
    }
}