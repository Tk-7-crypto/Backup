public class DAOH_Sales_Revenue {
    
    /**
     * This method is used to set record Fields
     * @params  List<Sales_Revenue__c> newList
     * @return  void
     */
    public static void setSalesRevenueFields(List<Sales_Revenue__c> newList){
        Set<String> productFieldSet = new Set<String>{'Id', 'Name'};
            Set<String> productCodeSet = new Set<String>();
        Map<String,Id> productCodeToIdMap = new Map<String,Id>();
        
        for(Sales_Revenue__c sr: newList){
            if(String.isNotBlank(sr.Product_Code__c) && (sr.Scenario__c == 'Revenue' || sr.Scenario__c == 'Pipeline')){
                productCodeSet.add(sr.Product_Code__c);
            }
        }
        
        if(productCodeSet.size() > 0){
            for(Product2 pro: new SLT_Product2().getProductsByProductCode(productFieldSet, productCodeSet)){
                productCodeToIdMap.put(pro.ProductCode, Pro.Id);
            }
            
            for(Sales_Revenue__c sr: newList){
                if(productCodeToIdMap.containskey(sr.Product_Code__c) && String.isNotBlank(sr.Product_Code__c) && (sr.Scenario__c == 'Revenue' || sr.Scenario__c == 'Pipeline')){
                    sr.Product__c = productCodeToIdMap.get(sr.Product_Code__c);
                }
            }
        }
    }
}