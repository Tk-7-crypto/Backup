public class SLT_Agency_Program extends fflib_SObjectSelector {
    
/**
* constructor to initialise CRUD and FLS
*/
    public SLT_Agency_Program() {
        super(false, false, false);
    }
    
/**
* constructor to initialise CRUD and FLS with a parameter for FLS.
*/
    public SLT_Agency_Program(Boolean enforceFLS) {
        super(false, true, enforceFLS);
    }
    
/**
* This method used to get field list of sobject
* @return  List<Schema.SObjectField>
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
/**
* This method used to set up type of sobject
* @return  Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return Agency_Program__c.sObjectType;
    }
    
    public List<Agency_Program__c> fetchAllActiveAgencyProgram(Set<String> fieldSet){
        string activeStatus = CON_PEP.S_PEP_ACTIVE_STATUS;
        return ((List<Agency_Program__c>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Status__c =: activeStatus').toSOQL()));
    }
    public Agency_Program__c fetchRelatedAgencyProgram(String agencyProgramId){
        return  Database.query('SELECT Name, Product__c FROM Agency_Program__c WHERE id =: agencyProgramId LIMIT 1');
    }
    public List<Agency_Program__c> fetchActiveAgencyProgram(){
        string activeStatus = CON_PEP.S_PEP_ACTIVE_STATUS;
        return  Database.query('SELECT Id, (SELECT Id,EndDate,Notification_Counter__c FROM Contracts__r where New_Contract_Number__c=NULL AND Notification_Counter__c < 4 ORDER BY Id DESC LIMIT 1), Name, Description__c, CurrencyIsoCode, Duration_in_month__c, Price__c, Product__c, Status__c FROM Agency_Program__c where status__c =: activeStatus ORDER BY Name ASC');
    }
    public Agency_Program__c fetchAgencyProgramById(Id agencyProgramId){
        return  Database.query('SELECT Id,Name, Product__c,Duration_in_month__c FROM Agency_Program__c WHERE id =: agencyProgramId LIMIT 1');
    }
    public List<Agency_Program__c> fetchRelatedAgencyProgramById(String relatedAgencyProgram){
        return  Database.query('SELECT Id, Product__c,Duration_in_month__c,First_Notification__c,Second_Notification__c,Third_Notification__c FROM Agency_Program__c WHERE ID =: relatedAgencyProgram');
    }
    public List<Agency_Program__c> fetchActiveAgencyPrograms(String accountCountry,Id recordTypeId){
        string activeStatus = CON_PEP.S_PEP_ACTIVE_STATUS;
        return  Database.query('SELECT Id,(SELECT Id,Price__c,CurrencyIsoCode FROM Agency_Program_Financials__r WHERE Country__c =:accountCountry AND RecordTypeId =:recordTypeId LIMIT 1), (SELECT Id,EndDate,Notification_Counter__c FROM Contracts__r WHERE New_Contract_Number__c=NULL AND Notification_Counter__c < 4 ORDER BY Id DESC LIMIT 1), Name, Description__c, CurrencyIsoCode, Duration_in_month__c, Price__c, Product__c, Status__c, Visible_in_PRM__c FROM Agency_Program__c WHERE status__c =: activeStatus ORDER BY Name ASC');
    }
    
    public List<Agency_Program__c> fetchActiveAgencyProgramsDefault(Id recordTypeId,Set<Id> apId){
        string activeStatus = CON_PEP.S_PEP_ACTIVE_STATUS;
        return  Database.query('SELECT Id,(SELECT Id,Price__c,CurrencyIsoCode FROM Agency_Program_Financials__r WHERE Default__c=true AND RecordTypeId =:recordTypeId LIMIT 1), (SELECT Id,EndDate,Notification_Counter__c FROM Contracts__r WHERE New_Contract_Number__c=NULL AND Notification_Counter__c < 4 ORDER BY Id DESC LIMIT 1), Name, Description__c, CurrencyIsoCode, Duration_in_month__c, Price__c, Product__c, Status__c, Visible_in_PRM__c FROM Agency_Program__c WHERE status__c =: activeStatus And Id IN:apId ORDER BY Name ASC');
    }
}
