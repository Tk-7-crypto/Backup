public class DAO_IMS_Legal_Entity extends fflib_SObjectDomain {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_IMS_Legal_Entity(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_IMS_Legal_Entity(sObjectList);
        }
    }

    /**
     * Override method Before Delete Call
     */
    public override void onBeforeDelete() {
        if(!UTL_TPA.tpaSetting.Is_Skip_TPA_Triggers__c) {
            //DAOH_IMS_Legal_Entity.onBeforeDelete((List<IMS_Legal_Entity__c>)Records);
        }
    }
}