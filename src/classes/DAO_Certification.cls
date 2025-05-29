/**
 * This is Certification Domain class.
 * version : 1.0
 */
public class DAO_Certification extends fflib_SObjectDomain  {
    /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_Certification(List<SObject> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Certification(sObjectList);
        }
    }
    
    
    public override void onAfterInsert() {
        DAOH_Certification.updateCertificationAccount((List<Certification__c>)Records);
    }
}