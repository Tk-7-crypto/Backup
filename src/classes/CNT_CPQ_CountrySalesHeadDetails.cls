public without sharing class CNT_CPQ_CountrySalesHeadDetails {
    
    @AuraEnabled
    public static List<String> getSelectOptions(sObject objObject, String fieldName) {
        List <String> allOptions = new List <String> ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        List < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();            
        for (Schema.PicklistEntry a: values) {
            allOptions.add(a.getValue());
        }
        allOptions.sort();
        return allOptions;
    }
    
    @AuraEnabled
    public static List<String> getValueSet(sObject objObject, String fieldName) {
        Set <String> allOptions = new Set <String> ();
        List<Country_Sales_Head__c> countrySalesHeadList = SLT_CountrySalesHead.selectCountrySalesHeadByFilter(CON_CPQ.NONE,CON_CPQ.NONE,CON_CPQ.NONE);
        if(fieldName == CON_CPQ.COUNTRY_SALES_FIELD){
            for(Country_Sales_Head__c countrySalesHeadObj : countrySalesHeadList){
                allOptions.add(countrySalesHeadObj.Country_Sales__c);
            }
        }
        else if(fieldName == CON_CPQ.CUSTOMER_NAME_FIELD){
            for(Country_Sales_Head__c countrySalesHeadObj : countrySalesHeadList){
                allOptions.add(countrySalesHeadObj.Approver_Name__c);
            }
        }
        return new List<String>(allOptions);
    }
    
    @AuraEnabled
    public static List<CountrySalesHeadWrapper> getCountrySalesHeadData(String saleType, String countrySale, String customerName){
        Map<String,Map<String, CountrySalesHeadCustomerWrapper>> customerToCountrySalesHeadListMap = new Map<String,Map<String, CountrySalesHeadCustomerWrapper>>();
        Set<String> salesTypeSet = CON_CPQ.SALES_TYPE_PICKLIST_SET;
        List<CountrySalesHeadWrapper> countrySalesHeadWrapperList = new List<CountrySalesHeadWrapper>();
        List<Country_Sales_Head__c> countrySalesHeadList = SLT_CountrySalesHead.selectCountrySalesHeadByFilter(saleType,countrySale,customerName);
        
        for(Country_Sales_Head__c countrySalesHead : countrySalesHeadList) {
            if(customerToCountrySalesHeadListMap.containsKey(countrySalesHead.Country_Sales__c)){
                Map<String, CountrySalesHeadCustomerWrapper> SaleTypeToCountrySalesHeadMAP = customerToCountrySalesHeadListMap.get(countrySalesHead.Country_Sales__c);
                SaleTypeToCountrySalesHeadMAP.get(countrySalesHead.Sale_Type__c).countrySalesHead = countrySalesHead;
            } else {  
                Map<String, CountrySalesHeadCustomerWrapper> SaleTypeToCountrySalesHeadMAP = new Map<String, CountrySalesHeadCustomerWrapper>();
                for(String salesTypeName : salesTypeSet){
                    SaleTypeToCountrySalesHeadMAP.put(salesTypeName,new CountrySalesHeadCustomerWrapper(new Country_Sales_Head__c(Country_Sales__c = countrySalesHead.Country_Sales__c, Approver_Name__c = CON_CPQ.N_A, Sale_Type__c = salesTypeName)));
                }    
                SaleTypeToCountrySalesHeadMAP.get(countrySalesHead.Sale_Type__c).countrySalesHead = countrySalesHead;
                customerToCountrySalesHeadListMap.put(countrySalesHead.Country_Sales__c, SaleTypeToCountrySalesHeadMAP);
            }
        }
        
        for(String country: customerToCountrySalesHeadListMap.keyset()){
            Map<String, CountrySalesHeadCustomerWrapper> SaleTypeToCountrySalesHeadMAP = customerToCountrySalesHeadListMap.get(country);
            List<CountrySalesHeadCustomerWrapper> countrySalesHeadCustomerWrapperList= SaleTypeToCountrySalesHeadMAP.Values();
            countrySalesHeadWrapperList.add(new CountrySalesHeadWrapper(country,countrySalesHeadCustomerWrapperList,false,false));
        }         
        return countrySalesHeadWrapperList;
    }
    
    @AuraEnabled
    public static void updateCountrySalesHead(String countrySalesHeadData) {
        List<CountrySalesHeadWrapper> CountrySalesHeadWrapperList = (List<CountrySalesHeadWrapper>)JSON.deserialize(countrySalesHeadData, List<CountrySalesHeadWrapper>.class);
        List<Country_Sales_Head__c> CountrySalesHeadUpdateList = new List<Country_Sales_Head__c>();
        List<Country_Sales_Head__c> CountrySalesHeadDeleteList = new List<Country_Sales_Head__c>();

        for(CountrySalesHeadWrapper countrySalesHeadWrapperObject : CountrySalesHeadWrapperList) {   
            if(countrySalesHeadWrapperObject.isEdit == true) {
                for(CountrySalesHeadCustomerWrapper countrySalesHeadCustomerWrapper  : countrySalesHeadWrapperObject.countrySalesHeadCustomerWrapperList){
                    if(countrySalesHeadCustomerWrapper.countrySalesHead.Approver_Name__c != null && countrySalesHeadCustomerWrapper.countrySalesHead.Approver_Name__c != CON_CPQ.N_A &&  countrySalesHeadCustomerWrapper.countrySalesHead.Approver_Name__c != ''){
                        CountrySalesHeadUpdateList.add(countrySalesHeadCustomerWrapper.countrySalesHead);
                    } else if(countrySalesHeadCustomerWrapper.countrySalesHead != null && countrySalesHeadCustomerWrapper.countrySalesHead.Id != null){
                        CountrySalesHeadDeleteList.add(countrySalesHeadCustomerWrapper.countrySalesHead);
                    }
                }
            }
        }
        if(CountrySalesHeadUpdateList.size() > 0){
            upsert CountrySalesHeadUpdateList;
        }
        if(CountrySalesHeadDeleteList.size() > 0){
            delete CountrySalesHeadDeleteList;
        }

    }
    
    @AuraEnabled
    public static void deleteCountrySalesHead(String countrySalesHeadData) {
        List<CountrySalesHeadWrapper> CountrySalesHeadWrapperList = (List<CountrySalesHeadWrapper>)JSON.deserialize(countrySalesHeadData, List<CountrySalesHeadWrapper>.class);
        List<Country_Sales_Head__c> CountrySalesHeadDeleteList = new List<Country_Sales_Head__c>();
        
        for(CountrySalesHeadWrapper countrySalesHeadWrapperObject : CountrySalesHeadWrapperList) {   
            if(countrySalesHeadWrapperObject.isDelete == true) {
                for(CountrySalesHeadCustomerWrapper countrySalesHeadCustomerWrapperObj  : countrySalesHeadWrapperObject.countrySalesHeadCustomerWrapperList){
                    if(countrySalesHeadCustomerWrapperObj.countrySalesHead != null && countrySalesHeadCustomerWrapperObj.countrySalesHead.Id != null){
                        CountrySalesHeadDeleteList.add(countrySalesHeadCustomerWrapperObj.countrySalesHead);
                    }
                }
            }
        }
        if(CountrySalesHeadDeleteList.size() > 0){
            delete CountrySalesHeadDeleteList;
        }
    }
    
    public class CountrySalesHeadWrapper{
        @AuraEnabled public String country{get;set;}
        @AuraEnabled public List<CountrySalesHeadCustomerWrapper> countrySalesHeadCustomerWrapperList{get;set;} 
        @AuraEnabled public Boolean isEdit{get;set;}
        @AuraEnabled public Boolean isDelete{get;set;}
        public CountrySalesHeadWrapper(String country, List<CountrySalesHeadCustomerWrapper> countrySalesHeadCustomerWrapperList, Boolean isEdit, Boolean isDelete){
            this.country = country;
            this.countrySalesHeadCustomerWrapperList = countrySalesHeadCustomerWrapperList;
            this.isEdit = isEdit;
            this.isDelete = isDelete;
        }
    }
    
    public class CountrySalesHeadCustomerWrapper{
        @AuraEnabled public Country_Sales_Head__c countrySalesHead{get;set;}
        public CountrySalesHeadCustomerWrapper(Country_Sales_Head__c countrySalesHead){
            this.countrySalesHead = countrySalesHead;
        }
    }
    
}