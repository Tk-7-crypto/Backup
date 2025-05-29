public class SLT_Contact  extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Contact() {
        super(false, true, false);
    }
    
    public SLT_Contact(Boolean enforceFLS,Boolean enforceCRUD) {
        super(false, enforceFLS, enforceCRUD);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{Contact.Id,Contact.Name, Contact.Email, Contact.FirstName, Contact.LastName};
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Contact.sObjectType;
    }
    
    /**
     * This method used to get Contact by Id
     * @return  Map<Id, Contact>
     */
    public Map<Id, Contact> selectByContactId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Contact>((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public List<Contact> selectByContactIdList(Set<ID> idSet, Set<String> fieldSet) {
        return ((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public Contact selectByEmail(String email) {
        return Database.query('select Id,Email,AccountId from Contact Where Email = \''+ email +'\' LIMIT 1');
    }
    
    public Map<Id, Contact> selectByMobile(String phone) {
        return new Map<Id, Contact>((List<Contact>) Database.query('select Id,Salutation,Name,MailingCity,Phone,MobilePhone,Email,Title,AccountId,Account.Name,toLabel(Account.AccountCountry__c),PreferredLanguage__c from Contact Where (Phone like \'%'+ phone +'%\' or MobilePhone like \'%'+ phone +'%\' or AssistantPhone like \'%'+ phone +'%\' or Company_Local_Phone__c like \'%'+ phone +'%\' or HomePhone like \'%'+ phone +'%\' or OtherPhone like \'%'+ phone +'%\')'));
    }
    
    public List<Contact> selectBySalesforceUserIdList(Set<ID> idSet, Set<String> fieldSet) {
        return ((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Salesforce_User__c in :idSet And RecordType.DeveloperName = \'IQVIA_User_Contact\'').toSOQL())); 
    }
    
    public Contact selectByEmailId(String email) {
        return Database.query('select Id,Name,Email,AccountId from Contact Where Email =:email and Inactive__c = false LIMIT 1');
    }
    
    public List<Contact> selectByEmailIdList(Set<String> emailIds) {
        return Database.query('select Id,Email,AccountId from Contact Where Email in :emailIds LIMIT 1');
    }
    
    public List<Contact> selectByEmailAndAccount(String email, String accountId) {
        return Database.query('select Id,Name,Email,AccountId from Contact Where Email =:email and AccountId =:accountId LIMIT 1');
    }
    public List<Contact> selectByPseSalesforceUserIdList(Set<ID> idSet, Set<String> fieldSet) {
        return ((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('pse__Salesforce_User__c in :idSet').toSOQL()));
    }

    public List<Contact> getContactEmails(Set<Id> contactIds){
        return Database.query('SELECT Id, Email, AccountId, Account.Name, PreferredLanguage__c FROM Contact WHERE Id IN :contactIds');
    }
        
    public List<Contact> selectContactByLiContactId(Set<ID> idSet, Set<String> fieldSet) {
        return ((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LI_Contact_Id__c in :idSet').toSOQL()));
    }
    
    public List<Contact> getContactByUserEmployeeNumber(String employeeNumber) {
        return [SELECT Id FROM Contact WHERE Salesforce_User__r.EmployeeNumber =: employeeNumber];
    }
    
    public List<Contact> getContactByEmployeeNumbers(Set<String> fieldSet, List<String> employeeNumberList) {
        return ((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('EmployeeNumber__c in :employeeNumberList').toSOQL()));
    }
    /**
     * This method used to get Contact by given condition
     * @return  Map<Id, Contact>
     */
    public Map<Id, Contact> selectByContactCondition(Set<ID> idSet, String contCondition, Set<String> fieldSet) {
        return new Map<Id, Contact>((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet and '+contCondition).toSOQL()));
    }
	
    /** 
     * This method is used to get all contact by Account Id
     * @return List<Contact>
     */
    public List<Contact> selectContactByAccId(String AccId, Set<String> fieldSet) {
        return (List<Contact>)Database.query(newQueryFactory(true)
                                             .selectFields(fieldSet)
                                             .setCondition('AccountId = \'' + accId + '\'')
                                             .addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
                                             .toSOQL());
    }

    /**
     * This method used to get Contact by given condition
     * @return  (List<Contact>)
     */
    public List<Contact> selectContactByCondition(Set<String> fieldSet, List<Id> childAccountIds) {
        return ((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('AccountId IN : childAccountIds').toSOQL()));
    }

    public List<Contact> getCSMMINContactEmails(Set<Id> accIds){
        return Database.query('SELECT Id, Email, AccountId FROM Contact WHERE IsMajorIncidentNotification__c = true and AccountId IN :accIds and Inactive__c = false');
    }
    
    public List<Contact> selectContactBasedOnId(Set<Id> contactIds){
        return (List<Contact>)Database.query('SELECT Id, Name, Email, AccountId, CSH_User__c, CSH_User_Last_connection_date__c, PreferredLanguage__c FROM Contact WHERE Id IN :contactIds');
    }
    public List<Contact> selectBySearchString(String searchString, Set<ID> actIdSet, Set<String> fieldSet) {
        return (List<Contact>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name LIKE '+searchString+' AND AccountId IN : actIdSet').toSOQL());
    }
    
    public Map<Id, Contact> selectContactByFieldSet(Set<ID> idSet, Set<String> fieldSet){
        Id contactRecordId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        return new Map<Id, Contact>((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet AND RecordTypeId = :contactRecordId').toSOQL()));
    }
    public contact getContact(){
        return Database.query('SELECT Id, Email FROM Contact WHERE (Email <> null ) Limit 1');
    }

    public List<Contact> selectByEmailIdSet(Set<String> emailIds) {
        return Database.query('SELECT Id, Email, AccountId, RecordTypeId FROM Contact WHERE Email IN :emailIds');
    }
    
    public Contact selectByAccContactId(String accId, String contactId) {
        return Database.query('SELECT Id, Email, AccountId FROM Contact WHERE Id =:contactId and AccountId =:accId LIMIT 1');
    }
    
    public Map<Id, Contact> getContactDetailsMap(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Contact>((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public List<Contact> selectContactsforEmail(String partnerType,String pillar,Set<Id> accId) {
        
        return Database.query('Select Id, Partner_Type__c,EmailOptOut__c FROM Contact WHERE Partner_Type__c INCLUDES (' + partnerType+ ')  AND Portal_Case_Type__c INCLUDES (' + pillar + ') AND AccountId IN: accId AND EmailOptOut__c = false AND PRM_User__c = \'Active\'');
    }
    
    public List<Contact> selectAllContactsforEmail(String partnerType,String pillar) {
        
        return Database.query('Select Id, Partner_Type__c,EmailOptOut__c FROM Contact WHERE Partner_Type__c INCLUDES (' + partnerType+ ')  AND Portal_Case_Type__c INCLUDES (' + pillar + ') AND EmailOptOut__c = false AND PRM_User__c = \'Active\'');
    }
    
    public List<Contact> selectContactsforEmailCSM(String userType,String pillar,Set<Id> accId) {
        
        return Database.query('Select Id, Contact_User_Type__c FROM Contact WHERE Contact_User_Type__c IN ('+userType+') AND Portal_Case_Type__c INCLUDES (' + pillar + ') AND AccountId IN: accId AND EmailOptOut__c = false AND CSH_User__c = \'Yes\'');
    }
    
    public List<Contact> selectAllContactsforEmailCSM(String userType,String pillar) {
        
        return Database.query('Select Id, Contact_User_Type__c FROM Contact WHERE Contact_User_Type__c IN ('+userType+') AND Portal_Case_Type__c INCLUDES (' + pillar + ') AND EmailOptOut__c = false AND CSH_User__c = \'Yes\'');
    }

    public List<Contact> selectBySalesforceUserIdsList(Set<ID> idSet, Set<String> fieldSet) {
        return ((List<Contact>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Salesforce_User__c in :idSet').toSOQL())); 
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactsByEmail(String email) {
        return [SELECT Id, Name, Account.Name, Title, Email FROM Contact WHERE Email = :email and Inactive__c = false];
    }

    /**
    * This method is used to get contact details with help of email address
    * @param Set<String> emails
    * @param Set<Id> recordTypeIds
    * @return List<Contact>
    */
    public List<Contact> getContactsByEmails(Set<String> emails, Set<Id> recordTypeIds) {
        return Database.query('SELECT Id, Email, RecordTypeId, Name FROM Contact WHERE Email IN: emails AND Inactive__c = false AND RecordTypeId IN: recordTypeIds ORDER BY CreatedDate ASC');
    }    
	
    /**
    * This method is used to get contact details with based on condition
    * @param Set<String> firstParam
    * @param String condition
    * @param Set<String> fieldSet
    * @return List<Contact>
    */
    public List<Contact> getContactsByCondition(Set<String> firstParam, String condition, Set<String> fieldSet) {
        return Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }    
}