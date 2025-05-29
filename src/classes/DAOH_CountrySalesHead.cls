public class DAOH_CountrySalesHead {

    public static void inActiveOldRecord(List<Country_Sales_Head__c> records){
        Map<String, Country_Sales_Head__c> saleTypeToCountrySalesHeadMap = new Map<String, Country_Sales_Head__c>();
        Set<String> saleTypeSet = new Set<String>();
        Set<String> countrySalesSet = new Set<String>();
        for(Country_Sales_Head__c countrySalesHead :(List<Country_Sales_Head__c>) records){
            saleTypeSet.add(countrySalesHead.Sale_Type__c);
            countrySalesSet.add(countrySalesHead.Country_Sales__c);
        }

        for(Country_Sales_Head__c countrySalesHead : SLT_CountrySalesHead.selectCountrySalesHead(saleTypeSet, countrySalesSet, new Set<String>())){
            saleTypeToCountrySalesHeadMap.put(countrySalesHead.Sale_Type__c+'-'+countrySalesHead.Country_Sales__c, countrySalesHead);
        }

        if(saleTypeToCountrySalesHeadMap.size() > 0 ){
            for(Country_Sales_Head__c countrySalesHead :(List<Country_Sales_Head__c>) records){
                if(saleTypeToCountrySalesHeadMap.containsKey(countrySalesHead.Sale_Type__c+'-'+countrySalesHead.Country_Sales__c))
                    countrySalesHead.addError(CON_CPQ.COUNTRY_SALES_HEAD_ERROR);
            }
        }
    }
}