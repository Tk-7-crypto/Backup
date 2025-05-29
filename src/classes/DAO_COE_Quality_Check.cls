public class DAO_COE_Quality_Check extends fflib_SObjectDomain {
    
    /**
* Constructor of this class
* @params sObjectList List<Case>
*/
    public DAO_COE_Quality_Check(List<Case> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_COE_Quality_Check(sObjectList);
        }
    }
    
    /**
* This method is used for before insert of the case trigger.
* @return void
*/
    public override void onBeforeInsert() { 
        DAOH_COE_Quality_Check.checkOverallCompliance((List<CSM_QI_Tech_COE_QualityCheck__c>)Records);
        DAOH_COE_Quality_Check.AddCSATAnswers((List<CSM_QI_Tech_COE_QualityCheck__c>)Records);
        DAOH_COE_Quality_Check.UpdateFromCaseFields((List<CSM_QI_Tech_COE_QualityCheck__c>)Records);
        //DAOH_COE_Quality_Check.UpdateCaseFields((List<CSM_QI_Tech_COE_QualityCheck__c>)Records);  //Can't call in before as it don't generate CreatedBy
    }
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)
    {
        DAOH_COE_Quality_Check.checkOverallCompliance((List<CSM_QI_Tech_COE_QualityCheck__c>)Records);
    }
    public override void onAfterInsert() {
        DAOH_COE_Quality_Check.UpdateCaseFields((List<CSM_QI_Tech_COE_QualityCheck__c>)Records);
    }
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
    }
}
