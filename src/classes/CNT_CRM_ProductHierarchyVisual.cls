/**
* Version : 1.0
* An apex controller that exposes the OpportunitySplit Component.
*/
public class CNT_CRM_ProductHierarchyVisual {
    
    /**
     * This method returns Product Records.
     * @params  String currentChain
     * @return List<Product2>
     */
    @AuraEnabled
    public static List<Product2> getProductDetails(String currentChain, String territory, Boolean isLWCScreen, Boolean isMaterialLevel) {
        List<Product2> productList = new List<Product2>();
        String GlobalProduct = '';
        if(!isLWCScreen) {
            GlobalProduct = 'GP';
        }
        if(currentChain == null) {
            currentChain = '';
        }
        try {
            Set<String> fieldSet = new Set<String>{'id','name','ProductCode','Hierarchy_Chain__c','Offering_Group__c','Territory__c','Offering_Segment__c','Offering_Type__c','COE_Name__c','Product_Group__c','Unit_Name__c','ProductGroup__c','Hierarchy_Global_Code_Description__c', 'Enable_Regional_Hierarchy__c'};
            String filterCondition = CON_CRM.INTERFACEDWITHMDM_TRUE + CON_CRM.AND_LOGIC;
            filterCondition += '(Hierarchy_Chain__c LIKE \'' + currentChain + GlobalProduct + '%\') AND (NOT Hierarchy_Chain__c LIKE \'' + currentChain + GlobalProduct + '%->%\') AND isActive = true';
            if(territory != null) {
            	filterCondition += ' AND  territory__c = \'' +  territory + '\'';
            }
            if(isMaterialLevel) {
                filterCondition += ' AND Material_Type__c = \'ZPUB\'';
            }
            System.debug('filterCondition ' + filterCondition);
            System.debug('territory ' + territory);
            productList = SRV_CRM_Product.getProductsWithFilter(fieldSet, filterCondition);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return productList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> fetchTerritory1(String productId){
        List<Map<String,String>> pickListValuesList= new List<Map<String,String>>();
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Delivery_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            Map<String, String> crrMap = new Map<String,String>();
            crrMap.put('label',pickListVal.getLabel());
            crrMap.put('value',pickListVal.getLabel());
            pickListValuesList.add(crrMap);
        }    
        return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> fetchTerritory(String productId) {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Delivery_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            Map<String,String> crrMap = new Map<String,String>();
            pickListValuesList.add(pickListVal.getLabel());
        }    
        return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> fetchHierarchyChain() {
        List<String> Hierarchychain = new List<String>();
        String defaultHierarchyChain;
        List<Default_Product_Search__c> defaultProductSearchList = SRV_CRM_Default_Product_Search.getDefaultProductSearchFilter(new Set<Id>{ UserInfo.getUserId() }, new Set<String>{'Default_Hierarchy_Chain__c'});
        if(defaultProductSearchList.size() > 0){
            defaultHierarchyChain = defaultProductSearchList[0].Default_Hierarchy_Chain__c;
        }
        if(defaultHierarchyChain != null){
            String oldChain = '';
            Hierarchychain.add(oldChain);
            for(String chain: defaultHierarchyChain.split('->')){
                oldChain = oldChain + chain +  '->';
                Hierarchychain.add(oldChain.removeEnd('->'));
            }
        }
        return Hierarchychain;
    }
}