public class DAO_TopicAssignment extends fflib_SObjectDomain {
    
    /**
* Constructor of this class
* @params sObjectList List<TopicAssignment>
*/
    public DAO_TopicAssignment(List<TopicAssignment> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_TopicAssignment(sObjectList);
        }
    }
    
    /**
* This method is used for before insert of the TopicAssignment trigger.
* @return void
*/
    public override void onBeforeInsert() {
        Profile profile = null;
        if(UserInfo.getProfileId() != null){
            profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        }
        if(profile != null && profile.Name != null && (profile.Name == 'Service User' || profile.Name == 'Sales User')){
        	DAOH_TopicAssignment.stopCreateEditDeleteForServiceSalesProfile((List<TopicAssignment>) Records);
        }  
    }
    public override void onBeforeDelete() {
        Profile profile = null;
        if(UserInfo.getProfileId() != null){
            profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        }
        //system.debug('Profile '+profile.Name);
        if(profile != null && profile.Name != null && (profile.Name == 'Service User' || profile.Name == 'Sales User')){
        	DAOH_TopicAssignment.stopCreateEditDeleteForServiceSalesProfile((List<TopicAssignment>) Records);
        }
    }
}