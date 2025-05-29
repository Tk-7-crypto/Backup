public class CNT_CSM_EinsteinBot_UserFirstName {

    public class TranscriptInput{
        @InvocableVariable(required=true)
        public Id routableId;
    }
    
    public class VisitorName{
        @InvocableVariable(required=true)
        public String firstName;
    }
    
    @InvocableMethod(label='GetFirstName')
    public static List<VisitorName> getFirstName(List<TranscriptInput> transcriptIds){
        List<VisitorName> visitorList = new List<VisitorName>();
        Id transcriptId = transcriptIds[0].routableId;
        LiveChatTranscript chatRecord = [SELECT Name, FirstName__c, LastName__c, Email__c FROM LiveChatTranscript WHERE Id = :transcriptId LIMIT 1];
        VisitorName name = new VisitorName();
        name.firstName = chatRecord.FirstName__c;
        visitorList.add(name);
        return visitorList;
    }
}