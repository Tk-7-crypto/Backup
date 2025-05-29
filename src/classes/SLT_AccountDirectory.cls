public class SLT_AccountDirectory extends fflib_SObjectSelector{
 	/**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            Account_Directory__c.Id,
            Account_Directory__c.Account__c,
            Account_Directory__c.Approver_Name__c,
            Account_Directory__c.Role__c,
            Account_Directory__c.Approver_Email__c,
            Account_Directory__c.Is_Active__c
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return Account_Directory__c.sObjectType;
    }

    /**
    * This method used to get Account_Directory__c by Id
    * @return  List<Account_Directory__c>
    */
    public List<Account_Directory__c> selectById(Set<Id> idSet){

        return (List<Account_Directory__c>) selectSObjectsById(idSet);
    }

    /*
    * This method is use to query Account Directory data by Role and account
    *
	  */
    public static List<Account_Directory__c> selectAccountDirectoryByCondition(String role,String account,String customerName){
        String query = 'SELECT Id, Name, Account__c, Account__r.name, Approver_Name__c, Role__c, Is_Active__c, Approver_Email__c FROM Account_Directory__c where Is_Active__c = true';
        if(role != CON_CPQ.NONE && role != null && role != ' '){
            query += ' And Role__c = \''+ role +'\'';
        }
        if(account != CON_CPQ.NONE && account != null){
            query += ' And Account__r.name = \''+ account +'\'';
        }
        if(customerName != CON_CPQ.NONE && customerName !=null & customerName != ' '){
            query += ' And Approver_Name__c = \''+ customerName +'\'';
        }
        query += ' Order by Account__r.Name ';
        return Database.query(query);
    }
    
    /*
    * This method is use to query Account Directory data by Role set, Account Name Set and Customer Name Set
    *
	  */
    public static List<Account_Directory__c> selectAccountDirectory(Set<String> roleSet,Set<String> accountSet,Set<String> customerNameSet){
        String query = 'SELECT Id, Name, Account__c, Account__r.name, Approver_Name__c, Role__c, Is_Active__c, Approver_Email__c FROM Account_Directory__c WHERE Is_Active__c = true AND (Role__c IN : roleSet OR Account__r.name IN : accountSet OR Approver_Name__c IN : customerNameSet) ORDER BY Account__r.Name';
        return Database.query(query);
    }
}