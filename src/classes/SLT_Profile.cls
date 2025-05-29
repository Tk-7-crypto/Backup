/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Profile
 */
public class SLT_Profile extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Profile() {
        super(false, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */  
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {  
            Profile.Id,
            Profile.Name,
            Profile.UserLicenseId,
            Profile.UserLicense.Name
        };   
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Profile.sObjectType;
    }
    
    /**
     * This method used to get Account by Id
     * @return  List<Account>
     */
    public List<Profile> selectById(Set<Id> idSet) {
        return (List<Profile>) selectSObjectsById(idSet);
    }
	
    /**
     * This method used to get Profile Name
     * @return  List<Profile>
     */
    public List<Profile> selectProfileByName(Set<String> nameSet, Set<String> fieldSet) {
        return (List<Profile>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name IN: nameSet').toSOQL());
    }
    /**
     * This method used to get Profile Name
     * @return  List<Profile>
     */
    public Map<Id, Profile> selectProfileById(Set<Id> idSet, Set<String> fieldSet) {
        return new Map<Id, Profile>((List<Profile>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN: idSet').toSOQL()));
    }
    
    public Profile getProfileByName(Set<String> nameSet, Set<String> fieldSet){
        return (Profile) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Name IN: nameSet').toSOQL());
    }
    
    public List<Profile> getAdminProfiles(Set<String> fieldSet){
        return (List<Profile>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('UserType = \'Standard\' AND PermissionsCustomizeApplication = true').toSOQL());
    }
}