public class DAO_Topic extends fflib_SObjectDomain {
    
    /**
* Constructor of this class
* @params sObjectList List<Topic>
*/
    public DAO_Topic(List<Topic> sObjectList) {
        super(sObjectList);
    }
    
    /**
* Constructor Class for construct new Instance of This Class
*/
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_Topic(sObjectList);
        }
    }
    
    /**
* This method is used for before insert of the Topic trigger.
* @return void
*/
    public override void onBeforeInsert() {
        /* Profile profile = null;
        if(UserInfo.getProfileId() != null){
            profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        }
        if(profile != null && profile.Name != null && (profile.Name == 'Service User' || profile.Name == 'Sales User')){
        	DAOH_Topic.stopCreateEditDeleteForServiceSalesProfile((List<Topic>) Records);
        } */
    }
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        /* Profile profile = null;
        if(UserInfo.getProfileId() != null){
            profile = DAOH_Case.getCSMProfile(UserInfo.getProfileId());
        }
        if(profile != null && profile.Name != null && (profile.Name == 'Service User' || profile.Name == 'Sales User')){
        	DAOH_Topic.stopCreateEditDeleteForServiceSalesProfile((List<Topic>) Records);
        } */
    }
}