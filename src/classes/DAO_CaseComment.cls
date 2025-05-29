public class DAO_CaseComment  extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<CaseComment>
     */
    public DAO_CaseComment(List<CaseComment> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_CaseComment(sObjectList);
        }
    }

    /**
     * This method is used for after insert of the CaseComment trigger.
     * @return void filterOppRelatedCaseComment
     */
    public override void onAfterInsert() {
        DAOH_CaseComment.updateStatusforLogAWorkNoteonCase((List<CaseComment>)Records);
        DAOH_CaseComment.updateCSATInternalObject((List<CaseComment>)Records);
        DAOH_CaseComment.updateTechAFUFlagOnNewComment((List<CaseComment>)Records);
        DAOH_CaseComment.sendNotificationBell((List<CaseComment>)Records);
    }  
    
    /**
     * This method is used for after update of the CaseComment trigger.
     * @params  existingRecords Map<Id,SObject>
     * @return  void
     */
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        DAOH_CaseComment.updateStatusforLogAWorkNoteonCase((List<CaseComment>)Records);
        DAOH_CaseComment.updateCSATInternalObject((List<CaseComment>)Records);
    }
    
    public override void onBeforeDelete() {
       DAOH_CaseComment.deleteCSATInternalObject((List<CaseComment>)Records);
    }
}