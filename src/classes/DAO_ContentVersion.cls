public class DAO_ContentVersion extends fflib_SObjectDomain {

     /**
     * Constructor of this class
     * @params sObjectList List<SObject>
     */
    public DAO_ContentVersion(List<SObject> sObjectList) {
        super(sObjectList);
    }
    
    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_ContentVersion(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the Content Document Link trigger.
     * @return void
     */
    public override void onBeforeInsert() {   
        DAOH_CLM_ContentVersion.validateCVForIQAGR((List<ContentVersion>)Records, null);
    }
    
    /**
     * This method is used for before insert of the ContentDocumentLink trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_ContentVersion.callOutContentVersiontoBISMSN((List<ContentVersion>)Records);
    }
    
    /**
    * This method is used for before update of the ContentVersion trigger.
    */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        DAOH_CLM_ContentVersion.validateCVForIQAGR((List<ContentVersion>)Records, (Map<Id, ContentVersion>)existingRecords);
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
        
    }
}