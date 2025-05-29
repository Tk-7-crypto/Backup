/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for User
 */
public without sharing class SLT_User extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS 
     */
    public SLT_User() {
        super(false, false, false); 
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            User.Id,
            User.Name,
            User.accountId,
            User.contactId,
            User.FirstName,
            User.LastName,
            User.User_Country__c,
            User.Email,
            User.ProfileId,
            User.UserRoleId,
            User.IsActive,
            User.Username,
            User.Alias,
            User.UserType,
            User.EmployeeNumber
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return User.sObjectType;
    }
    
    /**
     * This method used to get User by Id
     * @return  List<User>
     */
    public List<User> selectById(Set<ID> idSet) {
        return (List<User>) selectSObjectsById(idSet);
    }
   /**
     * This method used to get User by Id
     * @return  Map<Id, User>
     */
    public Map<Id, User> selectByUserId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, User>((List<User>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
	
	public List<User> selectByContactIdAndCountry(String profileName, Set<ID> idSet) {
        return Database.query('SELECT id, contactId, Country from user where Profile.Name Like: profileName AND contactId in :idSet limit 1');
    }
    
    /**
     * This method used to get User by Id
     * @return  Map<Id, User>
     */
    public List<User> selectByContactId(Set<ID> idSet, Set<String> fieldSet) {
        return (List<User>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('ContactId != null and ContactId in :idSet').toSOQL());
    }

    public User selectUserByUserId(Set<ID> idSet) {
        return Database.query('SELECT LastLoginDate,contactId,LastLoginValue__c,EmailPreferencesAutoBcc,Email FROM User WHERE Id IN :idSet limit 1');
    }
    
    /**
     * This method is used to get all users with contact
     * @return List<user>
     */
    public List<User> selectUserWithContact(Set<String> fieldSet) {
        return (List<User>)Database.query(newQueryFactory(true)
                              .selectFields(fieldSet)
                              .setCondition('ContactId != null')
                              .addOrdering('contact.Account.Name', fflib_QueryFactory.SortOrder.ASCENDING)
                              .toSOQL());
    }

    /**
     * This Method is Used to get Users with username
     * @params : String userName
     * @params : Integer numberOfUsers
     * @returns : returns the related results by quering the database.
     */
    public static List<User> getUsersByName(String userName, Integer numberOfUsers) {
        return Database.query('SELECT Id, Name, Username, Email, Phone from User WHERE Name LIKE :userName AND IsActive = true limit :numberOfUsers');
    }
	
	/**
     * This Method is Used to get Users with username
     * @params : String userName
     * @params : Integer numberOfUsers
	 * @params : String license
     * @returns : returns the related results by quering the database.
     */
    public static List<User> getUsersByNameWithLicense(String userName, Integer numberOfUsers, String license) {
        return Database.query('SELECT Id, Name, Username, Email, Phone from User WHERE Name LIKE :userName AND IsActive = true AND profile.UserLicense.Name LIKE :license limit :numberOfUsers');
    }

    /**
     * This method is used to get the users records related to these user ids.
     * @params : List<Id> userIdList
     * @returns : returns the related results by quering the database.
     */
    public static List<User> getUsersByUserIds(List<Id> userIdsList) {
        return Database.query('Select ID,Name,IsActive,User.UserRole.Name,contactId,Title,MobilePhone,Phone from User where Id In: userIdsList');
    }

    public List<User> selectUserByName(String name) {
        return Database.query('SELECT Id,GBO_CRM_Compliance_Category__c from User WHERE Name LIKE \'' + name + '\' AND IsActive = true limit 1');
    }
    public List<User> selectActiveUserByUserId(Set<ID> idSet, Set<String> fieldSet) {
        return (List<User>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :idSet AND  IsActive = true ').toSOQL());
    }

    public List<User> selectUserByAccountId (Set<ID> accountIdSet){
        return Database.query('SELECT Id, AccountId, userRole.PortalRole from User WHERE AccountId IN :accountIdSet AND IsActive = true');
    }
    
    public List<User> selectManagerUserByAccountId (Set<ID> accountIdSet){
        return Database.query('SELECT Id, AccountId, Email, userRole.PortalRole, ContactId, Contact.Email from User WHERE AccountId IN :accountIdSet AND userRole.PortalRole =\'Manager\' AND IsActive = true');
    }
    
    public List<User> selectByManagerId(Set<ID> idSet, Set<String> fieldSet) {
        return (List<User>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('ManagerId != null and Id in :idSet').toSOQL());
    }
    
    public Map<Id,User> selectMapOfActiveUserByUserId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, User>((List<User>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :idSet AND  IsActive = true ').toSOQL()));
    }

    public List<User> selectContactDetailByUser(Set<ID> idSet, Set<String> fieldSet){
        return (List<User>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id IN :idSet AND  IsActive = true ').toSOQL());
    }
    public User selectUserByLoggedInUser(Id userInfo) {
        return Database.query('SELECT ContactId, Contact.AccountId, Contact.Partner_Type__c,Name,Email from user where contactid !=null AND Id = :userInfo');
    }
    public List<User> selectAccountIdByUser(Id userInfo) {
        return Database.query('SELECT ContactId, AccountId from user where Id = :userInfo');
    }
    
    public List<User> selectContactIdOrEmailByUser(Set<ID> idSet,Set<String> emailSet, Set<String> fieldSet){
        return (List<User>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('ContactId IN :idSet OR Email IN :emailSet').toSOQL());
    }

    public List<User> selectAccountCountryByUser(Id userInfo) {
        return Database.query('SELECT ContactId, AccountId, Account.AccountCountry__c from user where Id = :userInfo');
    }
    
    public List<User> selectUserByEmployeeNumber(Set<String> employeeNumberSet , Set<String> fieldSet) {
        return (List<User>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('EmployeeNumber IN :employeeNumberSet').toSOQL());
    }

    public List<User> getUserDetailByIds(Set<String> fieldSet, Set<Id> Ids){
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_Profile().configureQueryFactoryFields(queryFactory, 
            User.ProfileId.getDescribe().getRelationShipName());
        if(fieldSet == null) {
            return (List<User>) Database.query(queryFactory.setCondition('Id in :Ids').toSOQL());
        } else {
            return (List<User>) Database.query(queryFactory.selectFields(fieldSet).setCondition('Id in :Ids').toSOQL());
        }
    }
    
    public List<User> getUserByUserNameCondition(String userNameCondition) {
        return Database.query(userNameCondition);
    }
    
    public List<User> geUsersByManagerId(Id managerId) {
        return Database.query('Select Id from User where ManagerId = :managerId');
    }

    public List<User> getUserByProfileNames(Set<Id> contactId, Set<String> profileNames) {
        String userId = UserInfo.getUserId();
        return Database.query('SELECT Profile.Name,IsActive,UserRole.Name,AccountId,LastLoginDate,ContactId,Contact.MailingCountry,Contact.Inactive__c FROM USER WHERE ((ContactId IN : contactId AND Profile.Name IN: profileNames) or Id =:userId)');
    }


    /**
     * This method used to get all the users of a group
     * @params  String groupName
     * @return  List<User>
     */
    public List<User> getUsersByGroupName(String groupName){
        return [SELECT Id, Name, Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.name =: groupName)];
    }

    /**
     * This method used to get all the users by name
     * @params  String lstNames
     * @return  List<User>
     */
    public List<User> selectUserByName(List<String> lstNames) {
        return Database.query('SELECT Id, User.Email FROM User WHERE Name IN : lstNames AND IsActive = true');
    }

    public List<User> getPRMManagerUsers(Set<Id> managerId) {
        return Database.query('SELECT Id,UserRole.PortalRole,IsPrmSuperUser,Profile.Name FROM User WHERE Id IN:managerId AND UserRole.PortalRole =\'Manager\' AND Profile.Name = \'PRM Community User\' AND IsActive = true');
    }
    
    public Map<Id, User> getPRMUsers(Set<Id> managerId) {
        return new Map<Id, User>((List<User>)Database.query('SELECT Id,UserRole.PortalRole,IsPrmSuperUser,Profile.Name FROM User WHERE Id IN:managerId AND Profile.Name = \'PRM Community User\' AND IsActive = true'));
    }
    public List<User> selectUserByUserContactId(Set<ID> idSet) {
        return Database.query('SELECT LastLoginDate,contactId,LastLoginValue__c FROM User WHERE ContactId IN :idSet');
    }
    
    /**
     * This method used to get all the users by Email
     * @params  String userEmails
     * @return  List<User>
     */
    public List<User> selectUserByEmail(Set<String> userEmails) {
        return Database.query('SELECT Id, Email, Name FROM User WHERE Email IN : userEmails AND IsActive = true AND Profile.UserLicense.Name = \'Salesforce\'');
    }
    
    /**
     * This method used to get User with Permission Sets by Id
     * @return  List<User>
     */
    public List<User> selectUserWithPermissionSetByUserId(Set<Id> userIds, 
                                                          Set<String> fieldSet, 
                                                          Set<String> permissionSetFields,
                                                          Set<String> permissionSetNames) {

        fflib_QueryFactory qf = new fflib_QueryFactory(User.SObjectType)
            .selectFields(fieldSet)
            .setCondition('Id IN :userIds ');     
        qf.subselectQuery('PermissionSetAssignments', true)
            .selectFields(permissionSetFields)
            .setCondition('PermissionSet.Name IN :permissionSetNames ');
        return (List<User>) Database.query(qf.toSOQL());
    }
    
    public List<User> getUserById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<User>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
    
    public Map<Id, User> getUserByIdProfileNames(Set<Id> Ids, Set<String> profileNames) {
        return new Map<Id, User>((List<User>)Database.query('SELECT Id,Profile.Name,IsActive,ContactId,LastLoginDate,LastLoginValue__c FROM USER WHERE ID IN : Ids AND Profile.Name IN: profileNames'));
    }
    
    public Map<Id, User> getAvacareUserById(Set<ID> idSet, Set<String> fieldSet) {
        Set<String> UserTypes = New Set<String>{'Avacare','EPG Collaborative','EPG IME','EPG'};
        return new Map<Id, User>((List<User>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet AND User_Type__c IN :UserTypes').toSOQL()));
    }
}