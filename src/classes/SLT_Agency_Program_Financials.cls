public class SLT_Agency_Program_Financials
{    
    public List<Agency_Program_Financials__c> getAgencyProgramFinancialsDetails(Id recordTypeId,String relatedAgencyId,String country){
        return  Database.query('SELECT Product__c,Price__c,CurrencyIsoCode FROM Agency_Program_Financials__c WHERE RecordTypeId=:recordTypeId AND Program_Name__c=:relatedAgencyId AND Country__c=:country LIMIT 1');
    }
    
    public List<Agency_Program_Financials__c> getAgencyProgramFinancialsDetailsDefault(Id recordTypeId,String relatedAgencyId){
        return  Database.query('SELECT Product__c,Price__c,CurrencyIsoCode FROM Agency_Program_Financials__c WHERE RecordTypeId=:recordTypeId AND Program_Name__c=:relatedAgencyId AND Default__c=true LIMIT 1');
    }
    
    public List<Agency_Program_Financials__c> getAgencyProgramFinancialsAddress(Id recordTypeId,String country){
        return  Database.query('SELECT IQVIA_Invoicing_Address__c,IQVIA_Invoicing_Entity_Name__c,Overnight_Mail__c,Postal_Mail__c,SWIFT_BIC_Code__c,Electronic_Payment__c,ACH_Payment__c,Fedwire__c,IQVIA_TIN__c FROM Agency_Program_Financials__c WHERE RecordTypeId=:recordTypeId AND Country__c=:country LIMIT 1');
    }
    
    public List<Agency_Program_Financials__c> getAgencyProgramFinancialsAddressDefault(Id recordTypeId){
        return  Database.query('SELECT IQVIA_Invoicing_Address__c,IQVIA_Invoicing_Entity_Name__c,Overnight_Mail__c,Postal_Mail__c,SWIFT_BIC_Code__c,Electronic_Payment__c,ACH_Payment__c,Fedwire__c,IQVIA_TIN__c FROM Agency_Program_Financials__c WHERE RecordTypeId=:recordTypeId AND Default__c=true LIMIT 1');
    }
    
}