public class DAO_LiveChatTranscript  extends fflib_SObjectDomain {

    /**
     * Constructor of this class
     * @params sObjectList List<Case>
     */
    public DAO_LiveChatTranscript(List<LiveChatTranscript> sObjectList) {
        super(sObjectList);
    }

    /**
     * Constructor Class for construct new Instance of This Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_LiveChatTranscript(sObjectList);
        }
    }

    /**
     * This method is used for before insert of the case trigger.
     * @return void
     */
    public override void onBeforeInsert()  {
        DAOH_LiveChatTranscript.searchOrCreateContactLead((List<LiveChatTranscript>)Records);
        
    }
    
    public override void onAfterInsert()  {
        DAOH_LiveChatTranscript.changeCaseOwner((List<LiveChatTranscript>)Records);
        
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords)  {
        //DAOH_LiveChatTranscript.searchOrCreateContactLead((List<LiveChatTranscript>)Records);
        
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords)  {
        //DAOH_LiveChatTranscript.createTasktoContactOrLead((List<LiveChatTranscript>)Records,(Map<Id,LiveChatTranscript>)existingRecords);
        
    }
}