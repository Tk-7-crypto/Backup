public class CNT_CPQ_ATCClassesController{
    public static Map<String, Set<String>> hierarchy1ToHierarchy2Map = new Map<String, Set<String>>();
    public static Map<String, Set<String>> hierarchy2ToHierarchy3Map = new Map<String, Set<String>>();
    public static Map<String, Set<String>> hierarchy3ToHierarchy4Map = new Map<String, Set<String>>();
    public static Map<String, Decimal> hierarchyToMarketShareMap = new Map<String, Decimal>();
    public static Map<String, Decimal> hierarchyToMarketShareValueMap = new Map<String, Decimal>();
    public static Map<String, String> hierarchyToQuarterMap = new Map<String, String>();
    
    @AuraEnabled(cacheable=true)
    public static String getATC_Classes(Id lineItemId){
        String productCode;
        String country;
        String year;
        String productMarketType;
        String atcOTC;
        String standardType;
        String subProduct;
        Set<String> lineItemFieldSet = CON_CPQ.FIELDSET;
        lineItemFieldSet.addAll(CON_CPQ.ATCMARKETSHAREFIELDSET);
        
        Apttus_Config2__LineItem__c lineItem = new SLT_LineItem().selectByLineItemID(lineItemId, lineItemFieldSet);
        productCode = lineItem.Apttus_Config2__OptionId__r.ProductCode != null ? lineItem.Apttus_Config2__OptionId__r.ProductCode : '';
        country = lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c != null ? lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c : '';
        year = lineItem.Start_Date_Year__c != null ? String.valueOf(lineItem.Start_Date_Year__c).removeEnd('.00') : '';
        subProduct = lineItem.Apttus_Config2__AttributeValueId__r.Sub_Product__c != null ? lineItem.Apttus_Config2__AttributeValueId__r.Sub_Product__c : '' ;
        
        for (CPQ_AMESA_Partial_Product_Pricings__c amesaMetaData : [SELECT Id, CPQ_Product_Code__c, Country__c, Type__c, Market_Type__c, Standard_Type__c FROM CPQ_AMESA_Partial_Product_Pricings__c WHERE CPQ_Product_Code__c =: productCode AND Country__c =: country LIMIT 1]) {
            productMarketType = amesaMetaData.Market_Type__c != null ? amesaMetaData.Market_Type__c : '';
            atcOTC = amesaMetaData.Type__c != null ? amesaMetaData.Type__c : '';
            standardType = amesaMetaData.Standard_Type__c != null ? amesaMetaData.Standard_Type__c : '';
            break;
        }
        List<ATC_OTC_Classification__c> atcClasses = new List<ATC_OTC_Classification__c>();
        atcClasses = new SLT_ATCOTCClassification().selectedATCOTCrecoreds(productMarketType, lineItem.Apttus_Config2__AttributeValueId__r.Eligible_Countries__c, atcOTC, subProduct, CON_CPQ.ATCOTCFIELDSET, standardType);
        atcClasses.sort();
        for (ATC_OTC_Classification__c atcClass : atcClasses) {
            Set<String> hierarchy2List = new Set<String>();
            Set<String> hierarchy3List = new Set<String>();
            Set<String> hierarchy4List = new Set<String>();
            
            if (hierarchy1ToHierarchy2Map.get(atcClass.Hierarchy1_Name__c) == null) {
                hierarchy2List.add(atcClass.Hierarchy2_Name__c);
            }
            else {
                hierarchy2List = hierarchy1ToHierarchy2Map.get(atcClass.Hierarchy1_Name__c);
                hierarchy2List.add(atcClass.Hierarchy2_Name__c);
            }
            hierarchy1ToHierarchy2Map.put(atcClass.Hierarchy1_Name__c, hierarchy2List);
            
            if (hierarchy2ToHierarchy3Map.get(atcClass.Hierarchy2_Name__c) == null) {
                hierarchy3List.add(atcClass.Hierarchy3_Name__c);
            }
            else {
                hierarchy3List = hierarchy2ToHierarchy3Map.get(atcClass.Hierarchy2_Name__c);
                hierarchy3List.add(atcClass.Hierarchy3_Name__c);
            }
            hierarchy2ToHierarchy3Map.put(atcClass.Hierarchy2_Name__c, hierarchy3List);
            
            if (hierarchy3ToHierarchy4Map.get(atcClass.Hierarchy3_Name__c) == null) {
                hierarchy4List.add(atcClass.Hierarchy4_Name__c);
            }
            else {
                hierarchy4List = hierarchy3ToHierarchy4Map.get(atcClass.Hierarchy3_Name__c);
                hierarchy4List.add(atcClass.Hierarchy4_Name__c);
            }
            hierarchy3ToHierarchy4Map.put(atcClass.Hierarchy3_Name__c, hierarchy4List);
            
            if (atcClass.Hierarchy4_Name__c == null) {
                hierarchyToMarketShareMap.put(atcClass.Hierarchy3_Name__c, atcClass.Market_Share__c);
                hierarchyToMarketShareValueMap.put(atcClass.Hierarchy3_Name__c, atcClass.Market_Share_Value__c);
            }
            else {
                hierarchyToMarketShareMap.put(atcClass.Hierarchy4_Name__c, atcClass.Market_Share__c);
                hierarchyToMarketShareValueMap.put(atcClass.Hierarchy4_Name__c, atcClass.Market_Share_Value__c);
            }
            if (atcClass.Hierarchy4_Name__c == null) {
                hierarchyToQuarterMap.put(atcClass.Hierarchy3_Name__c, atcClass.Quarter__c);
            }
            else {
                hierarchyToQuarterMap.put(atcClass.Hierarchy4_Name__c, atcClass.Quarter__c);
            }            
        }
        Set<String> hierarchy1List = hierarchy1ToHierarchy2Map.keySet();
        List<WPR_CPQ_HierarchyWrapper> hierarchyClassesList = new List<WPR_CPQ_HierarchyWrapper>();
        for (String hierarchy1 : hierarchy1List) {
            hierarchyClassesList.add(new WPR_CPQ_HierarchyWrapper(hierarchy1, null, null, null, null, getChildHierarchyList(hierarchy1)));
        }
        return (JSON.serialize(hierarchyClassesList, true) + '&&&' + atcOTC + '&&&' + lineItem.Selected_ATC_OTC_Codes__c + '&&&' + lineItem.Apttus_Config2__AttributeValueId__r.Market_Share__c);
        
    }
    
    public static List<WPR_CPQ_HierarchyWrapper> getChildHierarchyList(String hierarchyName){
        List<WPR_CPQ_HierarchyWrapper> hierarchyClassesList = new List<WPR_CPQ_HierarchyWrapper>();
        Set<String> hierarchyList = new Set<String>();
        hierarchyList = hierarchy1ToHierarchy2Map.get(hierarchyName);
        
        if (hierarchyList == null) {
            hierarchyList = hierarchy2ToHierarchy3Map.get(hierarchyName);
            if (hierarchyList == null) {
                hierarchyList = hierarchy3ToHierarchy4Map.get(hierarchyName);
            }
        }
        List<String> sortedHierarchyList = new List<String>(hierarchyList);
        sortedHierarchyList.sort();
        for (String hierarchy : sortedHierarchyList) {
            Decimal hierarchyMarketShare = hierarchyToMarketShareMap.get(hierarchy) != null ? hierarchyToMarketShareMap.get(hierarchy) : null;
            Decimal hierarchyMarketShareValue = hierarchyToMarketShareValueMap.get(hierarchy) != null ? hierarchyToMarketShareValueMap.get(hierarchy) : null;
            String hierarchyQuarter = hierarchyToQuarterMap.get(hierarchy) != null ? hierarchyToQuarterMap.get(hierarchy) : '';
            if (hierarchyMarketShare == null) {
                hierarchyClassesList.add(new WPR_CPQ_HierarchyWrapper(hierarchy, null, null, null, null, getChildHierarchyList(hierarchy)));
            }
            else {
                hierarchyClassesList.add(new WPR_CPQ_HierarchyWrapper(hierarchy, hierarchyMarketShare.setScale(2), hierarchyMarketShareValue, hierarchyMarketShare, hierarchyQuarter, null));
            }
        }
        return hierarchyClassesList;
    }

    @AuraEnabled(cacheable=false)
    public static String saveMarketShare(Id lineItemId, Decimal marketShare, String selectedAtcOtcCodes, String financialQuarter, String selectedATCOTCAggregateJSON){
        
        Map<String, Decimal> aggregateATCOTCMap  = (Map<String, Decimal>) json.deserialize(selectedATCOTCAggregateJSON, Map<String, Decimal>.class);
        try {
            Apttus_Proposal__Proposal__c updateProposal;
            Apttus_Config2__ProductAttributeValue__c productAttributeValueRecord = new SLT_ProductAttributeValue().selectedProductAttributeRecords(lineItemId, CON_CPQ.PRODUCTATTRIBUTEVALUEFIELDSET);
            
            fflib_SObjectUnitOfWork uowLineItem = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus_Config2__LineItem__c.SobjectType
                }
            );
            
            if (productAttributeValueRecord.Eligible_Countries__c != CON_CPQ.SOUTH_AFRICA) {
                productAttributeValueRecord.Market_Share__c = marketShare;
                uowLineItem.registerDirty(new Apttus_Config2__LineItem__c(Id = lineItemId, Apttus_Config2__PricingStatus__c = CON_CPQ.PENDING, Selected_ATC_OTC_Codes__c = selectedAtcOtcCodes));
                uowLineItem.commitWork();
            }
            else {
                uowLineItem.registerDirty(new Apttus_Config2__LineItem__c(Id = lineItemId, Apttus_Config2__PricingStatus__c = CON_CPQ.PENDING, Selected_ATC_OTC_Codes__c = selectedAtcOtcCodes, Apttus_Config2__Quantity__c = aggregateATCOTCMap.get('Count') < 1 ? 1 : aggregateATCOTCMap.get('Count')));
            	productAttributeValueRecord.Market_Share__c = null;
                uowLineItem.commitWork();
            }
            
            fflib_SObjectUnitOfWork uowProductAttributeValue = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus_Config2__ProductAttributeValue__c.SobjectType
                }
            );
            uowProductAttributeValue.registerDirty(productAttributeValueRecord);
            uowProductAttributeValue.commitWork();
            
            if (!String.isBlank(financialQuarter)) {
                Apttus_Config2__LineItem__c lineItemWithProposal = new SLT_LineItem().selectByLineItemID(lineItemId, CON_CPQ.FIELDSET);
                if (lineItemWithProposal.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Quarter__c == null) {
                    updateProposal = new Apttus_Proposal__Proposal__c(Id=lineItemWithProposal.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, Quarter__c = convertQuartervalue(financialQuarter, null) );
                } else {
                    updateProposal = new Apttus_Proposal__Proposal__c(Id=lineItemWithProposal.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__c, Quarter__c = convertQuartervalue(financialQuarter, convertStringtoQuarter(lineItemWithProposal.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Quarter__c)) );
                }
                if ((lineItemWithProposal.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Quarter__c != updateProposal.Quarter__c) || lineItemWithProposal.Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Quarter__c == null) {
                    update updateProposal;
                }
            }
            String cartLink = generateCartLink(lineItemId);
            return cartLink;
        } catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
	
    @AuraEnabled
    public static String handleCancle(Id lineItemId){
        try {
            String cartLink = generateCartLink(lineItemId);
            return cartLink;
        } catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
	
    public static String generateCartLink(Id lineItemId){
        Apttus_Config2__LineItem__c lineItem = new SLT_LineItem().selectByLineItemID(lineItemId, CON_CPQ.CARTLINKFIELDSET);
        Id cartId = lineItem.Apttus_Config2__ConfigurationId__r.Id;
        Id tempObjId = [SELECT Id FROM Apttus_Config2__TempObject__c WHERE Apttus_Config2__ConfigurationId__c =: cartId].Id;
        String baseOrgLink = URL.getOrgDomainUrl().toExternalForm();
        String cartLink;
        Boolean IsSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if (IsSandbox) {
            String sandBoxLink = baseOrgLink.substringBefore('.');
            sandBoxLink = sandBoxLink+CON_CPQ.AMESA_CART_LINK;
            cartLink = sandBoxLink;
        }
        else {
            String productionLink = baseOrgLink.substringBefore('.');
            productionLink = productionLink+CON_CPQ.AMESA_CART_LINK.remove('.sandbox');
            cartLink = productionLink;
        }
        cartLink = cartLink.replace('tempObjId', tempObjId);
        cartLink = cartLink.replace('cartId', cartId);
        return cartLink;
    }
	
    public static String convertQuartervalue(String currentQuarter, String previousQuarter){
        String quarterValue;
        List<String> tempQuarterList;
        tempQuarterList = previousQuarter != null? new List<String>{previousQuarter, currentQuarter} : new List<String>{currentQuarter};
        tempQuarterList.sort();
        List<String> st = tempQuarterList[tempQuarterList.size()-1].split(' ');
        switch on st[1] {
            when 'Q1' {
                quarterValue = 'March '+st[0];
            }
            when 'Q2' {
                quarterValue = 'June '+st[0];
            }
            when 'Q3' {
                quarterValue = 'September '+st[0];
            }
            when 'Q4' {
                quarterValue = 'December '+st[0];
            }
        }
        return quarterValue;
    }
    public static String convertStringtoQuarter(String previousQuarter){
        String quarterValue;
        List<String> st = previousQuarter.split(' ');
        switch on st[0] {
            when 'March' {
                quarterValue = st[1]+' Q1';
            }
            when 'June' {
                quarterValue = st[1]+' Q2';
            }
            when 'September' {
                quarterValue = st[1]+' Q3';
            }
            when 'December' {
                quarterValue = st[1]+' Q4';
            }
        }
       return quarterValue;
    }
	
    public class WPR_CPQ_HierarchyWrapper {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Decimal marketShare {get;set;}
        @AuraEnabled
        public Decimal marketShareValue {get;set;}
        @AuraEnabled
        public Decimal marketShareWithPrecision {get;set;}
        @AuraEnabled
        public String quarter {get;set;}
        @AuraEnabled
        public List<WPR_CPQ_HierarchyWrapper> items {get;set;}
        
        public WPR_CPQ_HierarchyWrapper(String name, Decimal marketShare, Decimal marketShareValue, Decimal marketShareWithPrecision, String quarter, List<WPR_CPQ_HierarchyWrapper> items){
            this.name = name;
            this.marketShare = marketShare;
            this.marketShareValue = marketShareValue;
            this.marketShareWithPrecision = marketShareWithPrecision;
            this.quarter = quarter;
            this.items = items;
        }
    }
}
