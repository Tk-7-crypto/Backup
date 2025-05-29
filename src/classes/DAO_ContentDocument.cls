/**
 * This is Content Document Domain class.
 * version : 1.0
 */
public with sharing class DAO_ContentDocument extends fflib_SObjectDomain {

     /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_ContentDocument(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ContentDocument(sObjectList);
        }
    }
      
    /**
    * This method is used for before delete of the ContentDocument trigger.
    */
    public override void onBeforeDelete() {
        DAOH_CSM_ContentDocument.updateCountForAttachmentOnRDCaseActivities((List<ContentDocument>)Records);
        DAOH_CLM_ContentDocument.validateCDForIQAGR((List<ContentDocument>)Records);
    }
}
