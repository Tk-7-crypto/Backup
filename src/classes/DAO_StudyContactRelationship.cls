public class DAO_StudyContactRelationship extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<Study_Contact_Relationship__c>
    */
    public DAO_StudyContactRelationship(List<Study_Contact_Relationship__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_StudyContactRelationship(sObjectList);
        }
    }
    
    /**
    * This method is used for after insert of the case trigger.
    * @return void
    */
    public override void onAfterInsert() {
        DAOH_StudyContactRelationship.saveAuditLogAfterInsertStudyContactRelationship((List<Study_Contact_Relationship__c>)Records); 
    }
    /**
    * This method is used for after update of the case trigger.
    * @params  existingRecords Map<Id,SObject>
    * @return  void
    */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.S_STUDY_CONTACT_RELATIONSHIP);
        
        if(fields != null){ 
            DAOH_StudyContactRelationship.saveAuditLogAfterUpdateStudyContactRelationshipFields((List<Study_Contact_Relationship__c>)Records,(Map<Id,Study_Contact_Relationship__c>)existingRecords,fields); 
        }
        
    }
}