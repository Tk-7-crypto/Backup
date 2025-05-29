public class DAO_FeedComment  extends fflib_SObjectDomain {
    
    /**
    * Constructor of this class
    * @params sObjectList List<Case>
    */
    public DAO_FeedComment(List<FeedComment> sObjectList) {
        super(sObjectList);
    }
    
    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_FeedComment(sObjectList);
        }
    }
    
    /**
    * This method is used for before insert of the Activity__c trigger.
    * @return void
    */
    public override void onBeforeInsert() {
        DAOH_FeedComment.technoCaseDonotSaveFeedComment((List<FeedComment>)Records); 
    }
    public override void onAfterInsert() {
        DAOH_FeedComment.createJiraComment((List<FeedComment>)Records);
    }
}