public class DAO_StudySiteContactRelationship  extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<StudySiteContactRelationship__c>
     */
    public DAO_StudySiteContactRelationship(List<StudySiteContactRelationship__c> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_StudySiteContactRelationship(sObjectList);
        }
    }
         /**
     * This method is used for after insert of the case trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_StudySiteContactRelationship.saveAuditLogAfterInsertStudySiteContactRelationship((List<StudySiteContactRelationship__c>)Records); 
    }
     /**
     * This method is used for after update of the case trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
   public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.S_STUDY_SITE_CON_RELATIONSHIP);
       
       if(fields != null){ 
           DAOH_StudySiteContactRelationship.saveAuditLogAfterUpdateStudySiteContactRelationshipFields((List<StudySiteContactRelationship__c>)Records,(Map<Id,StudySiteContactRelationship__c>)existingRecords,fields); 
       }
       DAOH_StudySiteContactRelationship.updateCaseWithSiteContactFields((List<StudySiteContactRelationship__c>)Records,(Map<Id,StudySiteContactRelationship__c>)existingRecords);
   }
}