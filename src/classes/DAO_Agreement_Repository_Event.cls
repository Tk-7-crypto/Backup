public class DAO_Agreement_Repository_Event extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<Agreement_Repository_Event__e>
     */
    public DAO_Agreement_Repository_Event(List<Agreement_Repository_Event__e> sObjectList) {
        super(sObjectList);
        if(UTL_ExecutionControl.disableTriggerCRUDAGR) {
            Configuration.disableTriggerCRUDSecurity();       
        }
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Agreement_Repository_Event(sObjectList);
        }
    }
    
    /**
     * This method is used for after insert of the Agreement trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Agreement_Repository_Event.updateARComments((List<Agreement_Repository_Event__e>)Records);  
    }
}