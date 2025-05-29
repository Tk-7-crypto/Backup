public class DAO_StudySiteRelationship extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<Study_Site_Relationship__c>
    */
    public DAO_StudySiteRelationship(List<Study_Site_Relationship__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_StudySiteRelationship(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the case trigger.
    * @return void
    */
    public override void onAfterInsert() {
        DAOH_StudySiteRelationship.saveAuditLogAfterInsertStudySiteRelationship((List<Study_Site_Relationship__c>)Records); 
    }
    /**
    * This method is used for before update of the case trigger.
    * @params  existingRecords Map<Id,SObject>
    * @return  void
    */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.S_STUDY_SITE_RELATIONSHIP);
        
        if(fields != null){ 
            DAOH_StudySiteRelationship.saveAuditLogAfterUpdateStudySiteRelationshipFields((List<Study_Site_Relationship__c>)Records,(Map<Id,Study_Site_Relationship__c>)existingRecords,fields); 
        }
        
    }
}