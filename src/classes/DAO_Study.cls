public class DAO_Study extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<Case>
    */
    public DAO_Study(List<Case> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Study(sObjectList);
        }
    }
    
    /**
    * This method is used for After insert of the case trigger.
    * @return void
    */
    public override void OnBeforeInsert()
    {
        DAOH_Study.DuplicateCheck((List<Study__c>)Records);
    }
    public override void onAfterInsert() {
        DAOH_Study.saveAuditLogAfterInsertStudy((List<Study__c>)Records); 
    }
    /**
    * This method is used for After update of the case trigger.
    * @params  existingRecords Map<Id,SObject>
    * @return  void
    */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        List<FieldDefinition> fields = new EXT_CSM_FieldDefination().getFieldDetails(CON_CSM.S_STUDYC);
        if(fields != null){ 
            DAOH_Study.saveAuditLogAfterUpdateStudyFields((List<Study__c>)Records,(Map<Id,Study__c>)existingRecords,fields); 
        }
        DAOH_Study.updateCaseWithStudyFields((List<Study__c>)Records,(Map<Id,Study__c>)existingRecords);
    }
}