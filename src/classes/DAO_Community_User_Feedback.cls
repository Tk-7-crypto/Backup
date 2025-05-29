public class DAO_Community_User_Feedback extends fflib_SObjectDomain {
    
    /**
* Constructor of this class
* @params sObjectList List<Community_User_Feedback__c>
*/
    public DAO_Community_User_Feedback(List<Community_User_Feedback__c> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Community_User_Feedback (sObjectList);
        }
    }
    
    public override void onAfterInsert() {
        DAOH_Community_User_Feedback.feedbackAlert((List<Community_User_Feedback__c>)Records);
    }

}