public class DAO_Knowledge extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Knowledge__kav>
     */
    public DAO_Knowledge(List<Knowledge__kav> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Knowledge(sObjectList);
        }
    }

    public override void onBeforeInsert() {
        DAOH_Knowledge.setDefaultValuesinDraftStatus((List<Knowledge__kav>)Records);
        DAOH_Knowledge.updateVisibleToPartner((List<Knowledge__kav>)Records);
    }

    /**
     * This method is used for before insert of the Knowledge__kav trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_Knowledge.addAccountKnowledgeRecord((List<Knowledge__kav>)Records);
        //DAOH_Knowledge.updateVisibleToPartner((List<Knowledge__kav>)Records);
    }
    
    public override void  onAfterUpdate(Map<Id,SObject> existingRecords) {
        //DAOH_Knowledge.updateVisibleToPartner((List<Knowledge__kav>)Records);
        DAOH_Knowledge.deleteArticleOrder((List<Knowledge__kav>)Records, (Map<Id,Knowledge__kav>)existingRecords);
    }
    
     public override void  onBeforeUpdate(Map<Id,SObject> existingRecords) {
        DAOH_Knowledge.updateVisibleToPartner((List<Knowledge__kav>)Records);
    }
        
}