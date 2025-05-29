/*
 * Version       : 1.0
 * Description   : Service Class for PriceBookEntry
 */
global class SRV_CRM_PriceBookEntry {
    
    /**
     * service method to get filter pricebookentries
     * @params  Product2 fiterProductObj
     * @params  Set<String> pbEntryFieldSet
     * @params  List<String> fieldsAPIList
     * @params  Integer recordLimit
     * @return  OpportunityWrapper
     */
    public static List<PriceBookEntryWrapper> getFilteredPriceBookEntries(PriceBookEntryWrapper pbeWrapper, Set<String> pbeFieldSet, List<String> productFilterFieldList, List<String> pbeFilterFieldList, Integer recordLimit, String andOrCondition) {
        List<PriceBookEntryWrapper> pbEntryWrapperList = new List<PriceBookEntryWrapper>();
        List<PriceBookEntry> pbEntryList = null;
        try {
            if(pbeWrapper.productRecord.Territory__c != null) {
                Map<String, Territory_lookup__mdt> territoryLookupMetadataMap = new SLT_TerritoryLookup().getTerritoryLookup();
                if(territoryLookupMetadataMap.containsKey(pbeWrapper.productRecord.Territory__c)) {
                    String territoryRegion = territoryLookupMetadataMap.get(pbeWrapper.productRecord.Territory__c).AND_Territory_Region__c ;
                    String territories = '';
                    territories = CON_CRM.BACKSLASH + pbeWrapper.productRecord.Territory__c + CON_CRM.BACKSLASH + CON_CRM.COLON + CON_CRM.BACKSLASH + territoryRegion + CON_CRM.BACKSLASH + CON_CRM.COLON + CON_CRM.BACKSLASH + CON_CRM.GLOBAL_REGION + CON_CRM.BACKSLASH;
                    if(territories != null) {
                        pbeWrapper.productRecord.Territory__c = territories; 
                    }
                } else {
                    String territories = '';
                    territories = CON_CRM.BACKSLASH + pbeWrapper.productRecord.Territory__c + CON_CRM.BACKSLASH + CON_CRM.COLON + CON_CRM.BACKSLASH + CON_CRM.GLOBAL_REGION + CON_CRM.BACKSLASH;
                    if(territories != null) {
                        pbeWrapper.productRecord.Territory__c = territories; 
                    }
                }
            }
            String condition = genrateWhereClause(pbeWrapper, pbeFieldSet, productFilterFieldList, pbeFilterFieldList, andOrCondition);
            pbEntryList = new SLT_PriceBookEntry().getPbEntriesByFilterParams(condition, pbeWrapper, pbeFieldSet, recordLimit);
            Integer totalRecords = 0;
            if(pbEntryList.size() >= recordLimit){
                totalRecords = new SLT_PriceBookEntry().getPbEntriesCountByFilterParams(condition, pbeWrapper);
            }
            for(PriceBookEntry pbEntry : pbEntryList) {
                pbEntryWrapperList.add(new PriceBookEntryWrapper(pbEntry.Product2, pbEntry,totalRecords,recordLimit));
            }
        } catch(Exception ex) {
            throw new PriceBookEntryServiceException(new List<String>{ex.getMessage()});
        }   
        return pbEntryWrapperList;
    }
    
    public static String genrateWhereClause(PriceBookEntryWrapper pbeWrapper, Set<String> pbeFieldSet, List<String> productFilterFieldList, List<String> pbeFilterFieldList, String andOrCondition){
        String condition = CON_CRM.SINGLE_SPACE;
        Product2 productRecord = pbeWrapper.productRecord;
        PriceBookEntry pbeRecord = pbeWrapper.pbeRecord;
        List<String> productIds = pbeWrapper.productIds;
        Boolean OrConditionNeed = false;
        
        if(andOrCondition == 'OR' && productFilterFieldList.contains('Name') && productFilterFieldList.contains(CON_CRM.PRODUCTCODE_FIELD)){
            OrConditionNeed = true;
            condition += CON_CRM.ROUND_BRACKET_OPEN + CON_CRM.SINGLE_SPACE;
            condition += CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + CON_CRM.NAME_FIELD + CON_CRM.LIKE_LOGIC + CON_CRM.BACKSLASH + CON_CRM.PERCENT_LOGIC + productRecord.get(CON_CRM.NAME_FIELD) + CON_CRM.PERCENT_LOGIC + CON_CRM.BACKSLASH + CON_CRM.OR_LOGIC + CON_CRM.SINGLE_SPACE;
            condition += CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + CON_CRM.PRODUCTCODE_FIELD + CON_CRM.LIKE_LOGIC + CON_CRM.BACKSLASH + CON_CRM.PERCENT_LOGIC + productRecord.get(CON_CRM.PRODUCTCODE_FIELD) + CON_CRM.PERCENT_LOGIC + CON_CRM.BACKSLASH;
            condition += CON_CRM.ROUND_BRACKET_CLOSE + CON_CRM.AND_LOGIC;
        }
        
        for(String filterField : productFilterFieldList) {
            if((filterField == CON_CRM.NAME_FIELD || filterField == CON_CRM.PRODUCTCODE_FIELD)){
                if(OrConditionNeed == true){
                    //logic already added
                }else if(OrConditionNeed == false){
                    condition += CON_CRM.SINGLE_SPACE + CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + filterField + CON_CRM.LIKE_LOGIC + CON_CRM.BACKSLASH + CON_CRM.PERCENT_LOGIC + productRecord.get(filterField) + CON_CRM.PERCENT_LOGIC + CON_CRM.BACKSLASH + CON_CRM.AND_LOGIC;
                }
            }else if(filterField == CON_CRM.UNIT_NAME_FIELD || filterField == CON_CRM.PRODUCTGROUP || filterField == CON_CRM.HIERARCHY_GLOBAL_CODE_DES || filterField == CON_CRM.GLOBAL_PRODUCT_CODE_FIELD) {
                condition += CON_CRM.SINGLE_SPACE + CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + filterField + CON_CRM.LIKE_LOGIC + CON_CRM.BACKSLASH + CON_CRM.PERCENT_LOGIC + productRecord.get(filterField) + CON_CRM.PERCENT_LOGIC + CON_CRM.BACKSLASH + CON_CRM.AND_LOGIC;
            } else if(filterField == CON_CRM.OPPORTUNITY_TERRITORY_FIELD_API) {
                List<String> territories = ((String)productRecord.get(filterField)).split(CON_CRM.COLON);
                condition += CON_CRM.SINGLE_SPACE + CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + filterField + CON_CRM.IN_LOGIC + territories + CON_CRM.AND_LOGIC;
            } else if(filterField == 'PSA_PROJECT_REQUIRED__c') {//for Checkbox field 
                condition += CON_CRM.SINGLE_SPACE + CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + filterField + CON_CRM.EQUAL_LOGIC + productRecord.get(filterField) + CON_CRM.AND_LOGIC;
            } else if(filterField == 'Hierarchy_Chain__c') {
                // do nothing
            } else {
                condition += CON_CRM.SINGLE_SPACE + CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + filterField + CON_CRM.EQUAL_LOGIC + CON_CRM.BACKSLASH + productRecord.get(filterField) + CON_CRM.BACKSLASH + CON_CRM.AND_LOGIC;
            }
        }
        if(productIds != null && productIds.size() > 0){
            condition += CON_CRM.SINGLE_SPACE + CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + 'Id' + CON_CRM.IN_LOGIC + CON_CRM.COLON + ' productIds' + CON_CRM.AND_LOGIC;
        }
        for(String filterField : pbeFilterFieldList) {
            condition += CON_CRM.SINGLE_SPACE + filterField + CON_CRM.EQUAL_LOGIC + CON_CRM.BACKSLASH + pbeRecord.get(filterField) + CON_CRM.BACKSLASH + CON_CRM.AND_LOGIC;
        }
        String defaultCondition = CON_CRM.ACTIVE_TRUE + CON_CRM.AND_LOGIC +  CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + CON_CRM.ACTIVE_TRUE + CON_CRM.AND_LOGIC + CON_CRM.PRODUCT_OBJECT + CON_CRM.DOT_LOGIC + CON_CRM.INTERFACEDWITHMDM_TRUE;
        if(productFilterFieldList.size() + pbeFilterFieldList.size() > 0) {
            condition = condition.removeEnd(CON_CRM.AND_LOGIC);
            condition = CON_CRM.ROUND_BRACKET_OPEN + condition + CON_CRM.ROUND_BRACKET_CLOSE + CON_CRM.AND_LOGIC;
        }
        condition += defaultCondition;
        return condition;
    }
    
    /**
     * service method to get favorite products
     * @params  Integer recordLimit
     * @return  OLIWrapper
     */
    public static List<PriceBookEntryWrapper> getUserFavoriteProducts(Id oppId, String source) {
        List<PriceBookEntry> priceBookEntryList = null;
        List<PriceBookEntryWrapper> pbeWrapperList = new List<PriceBookEntryWrapper>();
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> productFavoriteSet = new set<Id>();
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        Map<Id, Quote__c> idToQuoteMap = new Map<Id, Quote__c>();
        try {
            List<Favorite_Product__c> favoriteProductList = new SLT_FavoriteProduct().getUserFavoriteProducts();
            for(Favorite_Product__c fav : favoriteProductList) {
                productIdSet.add(fav.Product__c);
            }
            if(productIdSet.size() > 0) {
                Set<id> recordIdSet = new Set<Id>();
                recordIdSet.add(oppId);
                set<String> fieldset = new Set<String>{'id','CurrencyIsoCode','Product2.Name','Product2.Billing_System__c','Product2.Hierarchy_Level__c','Product2.Description','Product2.ProductCode', 'Product2.CanUseRevenueSchedule', 'Product2.Material_Type__c', 'Product2.Offering_Group_Code__c', 'Product2.Delivery_Type__c','Product2.Offering_Group__c','Product2.Offering_Type__c','Product2.Offering_Segment__c','Product2.COE_Name__c','Product2.Product_Group__c','Product2.Unit_Name__c','Product2.ProductGroup__c','Product2.Territory__c','Product2.Excluded_From_Pricing_Assistant__c','Product2.Material_Group_1__c','Product2.Therapy_Class__c'};
                if(source == 'Opportunity'){
                    idToOpportunityMap = new SLT_Opportunity().getOpportunityById(recordIdSet, new Set<String>{'Id','CurrencyIsoCode'});
                    System.debug(idToOpportunityMap);
                    priceBookEntryList = new SLT_PriceBookEntry().getPbEntriesByProductIds(productIdSet, fieldset, idToOpportunityMap.get(oppId).CurrencyIsoCode);
                } else if(source == 'Quote__c'){
                    idToQuoteMap = new SLT_IQVIA_Quote().getQuoteMap(recordIdSet, new Set<String>{'Id','CurrencyIsoCode'});
                    priceBookEntryList = new SLT_PriceBookEntry().getPbEntriesByProductIds(productIdSet, fieldset, idToQuoteMap.get(oppId).CurrencyIsoCode);
                }
                for(PriceBookEntry pbe : priceBookEntryList) {
                    productFavoriteSet.add(pbe.Product2Id);
                }
                List<Favorite_Product__c> favoriteProduct_List = new SLT_FavoriteProduct().selectByProductId(productFavoriteSet);
                for(PriceBookEntry pbe : priceBookEntryList) {
                    for(Favorite_Product__c fav :favoriteProduct_List){
                        if(pbe.Product2Id == fav.Product__c){
                            pbeWrapperList.add(new PriceBookEntryWrapper(pbe.Product2,pbe,fav));
                        }
                    }
                }
            }
        } catch(Exception ex) {
            String errMsg = ex.getMessage() + ' ' + ex.getStackTraceString();
            throw new PriceBookEntryServiceException(new List<String>{errMsg});
        }
        return pbeWrapperList;
    }
    
    // Exception Class for PriceBookEntry Service
    public Class PriceBookEntryServiceException extends Exception {
        
        List<String> errorList;
        
        /**
         * constructor
         * @params  List<String> errorList
         */ 
        public PriceBookEntryServiceException(List<String> errorList) {
            this.errorList = errorList;
        }
    }


}