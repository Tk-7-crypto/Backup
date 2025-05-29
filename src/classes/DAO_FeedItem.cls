public class DAO_FeedItem extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<FeedItem>
     */
    public DAO_FeedItem(List<FeedItem> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_FeedItem(sObjectList);
        }
    }
    
    /**
     * This method is used for before insert of the case trigger.
     * @return void
     */
    public override void onAfterInsert() {
        DAOH_FeedItem.updateOLAonCase((List<FeedItem>)Records);
        DAOH_FeedItem.updateCaseonAttachment((List<FeedItem>)Records);
    }
}
