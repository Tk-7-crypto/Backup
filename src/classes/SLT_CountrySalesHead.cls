public class SLT_CountrySalesHead extends fflib_SObjectSelector{
 	/**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){

        return new List<Schema.SObjectField> {
            Country_Sales_Head__c.Id,
            Country_Sales_Head__c.Sale_Type__c,
            Country_Sales_Head__c.Approver_Name__c,
            Country_Sales_Head__c.Country_Sales__c,
            Country_Sales_Head__c.Is_Active__c,
            Country_Sales_Head__c.Approver_Email__c
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){

        return Country_Sales_Head__c.sObjectType;
    }

    /**
    * This method used to get Account_Directory__c by Id
    * @return  List<Country_Sales_Head__c>
    */
    public List<Country_Sales_Head__c> selectById(Set<Id> idSet){
        return (List<Country_Sales_Head__c>) selectSObjectsById(idSet);
    }
    
    public static List<Country_Sales_Head__c> selectCountrySalesHeadByFilter(String saleType,String countrySales,String approverName){
        
        String query = 'select id,Country_Sales__c,Approver_Name__c,Sale_Type__c,Is_Active__c,Approver_Email__c from Country_Sales_Head__c where Is_Active__c = true';
        if(saleType != CON_CPQ.NONE && saleType != null){
            query += ' And Sale_Type__c = \''+ saleType +'\'';
        }if(countrySales != CON_CPQ.NONE && countrySales != null){
            query += ' And Country_Sales__c = \''+ countrySales +'\'';
        }if(approverName != CON_CPQ.NONE && approverName !=null ){
            query += ' And Approver_Name__c = \''+ approverName +'\'';
        }
        query += ' Order By Country_Sales__c';
        return Database.query(query);
    }
    
    /*
    * This method is use to query Account Directory data by Sale Type set, Country Sales Set and and Approver Name Set
    *
	  */
    public static List<Country_Sales_Head__c> selectCountrySalesHead(Set<String> saleTypeSet,Set<String> countrySalesSet,Set<String> approverNameSet){
        String query = 'SELECT Id,Country_Sales__c,Approver_Name__c,Sale_Type__c,Is_Active__c,Approver_Email__c FROM Country_Sales_Head__c WHERE Is_Active__c = true AND (Sale_Type__c IN :saleTypeSet OR Country_Sales__c IN :countrySalesSet OR Approver_Name__c IN :approverNameSet) ORDER BY Country_Sales__c';
        return Database.query(query);
    }
}