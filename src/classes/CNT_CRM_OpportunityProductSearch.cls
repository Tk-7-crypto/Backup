/*
 * Version       : 1.0
 * Description   : Apex Controller for Opportunity Product Screens
 */
public class CNT_CRM_OpportunityProductSearch {
    
    public static Decimal decimalPlace{get;set;}
    public static Decimal decimalPlaceStep{get;set;}
    public CNT_CRM_OpportunityProductSearch(ApexPages.StandardController controller) {
        
    }
    
    /**
     * This method used to search product by given filter
     * @params  String fiterObjString
     * @params  List<String> priceBookEntryFieldList
     * @params  List<String> fieldsAPIList
     * @params  Integer recordLimit
     * @return  OpportunityWrapper
     */
    @AuraEnabled
    public static List<PriceBookEntryWrapper> getPriceBookEntriesBySearchFilter(String pbeWrapperJson, List<String> pbeFieldList, List<String> productFilterFieldList, List<String> pbeFilterFieldList, Integer recordLimit, String andOrCondition) {
        PriceBookEntryWrapper pbeWrapper = (PriceBookEntryWrapper)JSON.deserialize(pbeWrapperJson, PriceBookEntryWrapper.Class);
        List<PriceBookEntryWrapper> pbeWrapperList = null;
        try {
            pbeWrapperList = SRV_CRM_PriceBookEntry.getFilteredPriceBookEntries(pbeWrapper, new Set<String>(pbeFieldList), productFilterFieldList, pbeFilterFieldList, recordLimit, andOrCondition);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return pbeWrapperList;
    }
    
    @AuraEnabled
    public static List<PriceBookEntryWrapper> getRecentProductList(String pbeWrapperJson, List<String> pbeFieldList, List<String> productFilterFieldList, List<String> pbeFilterFieldList, Integer recordLimit, String andOrCondition){
        List<String> productIdSet = new List<String>();
        List<AggregateResult> ars = new SLT_OpportunityLineItems().getRecentProductId();
        for(AggregateResult ar:ars){
            productIdSet.add(String.valueOf(ar.get('product2Id')));
        }
        if(ars.isEmpty())
            productIdSet.add('\'\'');
        PriceBookEntryWrapper pbew = (PriceBookEntryWrapper)JSON.deserialize(pbeWrapperJson, PriceBookEntryWrapper.Class);
        pbew.productIds = productIdSet;
        return getPriceBookEntriesBySearchFilter(JSON.serialize(pbew), pbeFieldList, productFilterFieldList, pbeFilterFieldList, recordLimit, andOrCondition);
    }
    
    /**
     * This method used to search product by given filter
     * @params  Integer recordLimit
     * @return  List<OpportunityWrapper.PriceBookEntryWrapper>
     */
    @AuraEnabled
    public static List<PriceBookEntryWrapper> getFavoriteProducts(Id oppId, String source) {
        List<PriceBookEntryWrapper> pbeWrapperList = null;
        try {
            pbeWrapperList = SRV_CRM_PriceBookEntry.getUserFavoriteProducts(oppId, source);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return pbeWrapperList;
    }
    
    /**
     * This method used to get field detail of product object
     * @params  String objectName
     * @params  List<String> fieldAPINameList
     * @return  List<ObjectFieldsWrapper>
     */
    @AuraEnabled
    public static List<OpportunityWrapper> getProductSearchInitData(String objectName, List<String> fieldAPINameList, Id opportunityId, List<String> oppFieldList, List<String> defaultProductfieldList, String source) {
        List<OpportunityWrapper> oppWrapper = new List<OpportunityWrapper>();
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        Map<Id, Quote__c> idToQuoteMap = new Map<Id, Quote__c>();
        Opportunity opportunityRecord = new Opportunity();
        Quote__c quoteRecord = new Quote__c();
        List<ObjectFieldsWrapper> objectFieldsWrapperList = null;
        Default_Product_Search__c defaultProductSearch = new Default_Product_Search__c();
        List<Default_Product_Search__c> defaultProductSearchList = null;
        Set<Id> userIdSet = new Set<Id>{ UserInfo.getUserId() };
        try {
            objectFieldsWrapperList = SRV_CRM_Product.getProductFieldsDetail(objectName, fieldAPINameList);
            defaultProductSearchList = SRV_CRM_Default_Product_Search.getDefaultProductSearchFilter(userIdSet, new Set<String>(defaultProductfieldList));
            if(source == 'Opportunity'){
                idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{opportunityId}, new Set<String>(oppFieldList));
            } else if(source == 'Quote__c'){
                idToQuoteMap = new SLT_IQVIA_Quote().getQuoteMap(new Set<Id>{opportunityId}, new Set<String>(oppFieldList));
            }
            if(defaultProductSearchList.size() > 0) {
                defaultProductSearch = defaultProductSearchList[0];
            }
            
			/* if(defaultProductSearch.Default_Territory__c ==  null) {
                List<User> userList = getUserDetails();
                defaultProductSearch.Default_Territory__c = userList[0].User_Country__c;
            }*/ 
			
            if(idToOpportunityMap.size() > 0) {
                opportunityRecord = idToOpportunityMap.get(opportunityId);
                oppWrapper.add(new OpportunityWrapper(opportunityRecord, objectFieldsWrapperList, defaultProductSearch));
            } else if(idToQuoteMap.size() > 0) {
                quoteRecord = idToQuoteMap.get(opportunityId);
                oppWrapper.add(new OpportunityWrapper(quoteRecord, objectFieldsWrapperList, defaultProductSearch));
            }
            
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        } 
        return oppWrapper;
    }
    
    @AuraEnabled
    public static Map<String,String> getTextFieldValues(String fieldApiName){
        Map<String,String> returnMap = new Map<String,String>();
        List<String> fieldValues = new List<String>();

        for(AggregateResult ar : new SLT_Product2().getAllFieldValues(fieldApiName)){
         	fieldValues.add((String)ar.get(fieldApiName));
        }
        returnMap.put(fieldApiName,JSON.serialize(fieldValues));
        List<PermissionSetAssignment> psa = new SLT_PermissionSetAssignment().selectByPermissionSetsForUserId(new Set<String>{'Id'}, new Set<Id>{UserInfo.getUserId()}, new Set<String>{'Sales_with_BNF'});
        if(psa.size() > 0) {
            returnMap.put('Sales_with_BNF','true');
        }else{
            returnMap.put('Sales_with_BNF','false');
        }
        return returnMap;
    } 
    
    /**
     * This method used to get list of OLIs
     * @params  Id opportunityId
     * @params  List<String> oliFields
     * @return  List<OpportunityWrapper>
     */
    @AuraEnabled
    public static List<OpportunityWrapper> getListOfOLI(Id opportunityId, List<String> oliFields) {
        List<OpportunityWrapper> opportunityWrapperList = new List<OpportunityWrapper>();
        List<OpportunityLineItem> oliList = null;
        try {
            String objectName = CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API;
            Set<Id> oppIdset = new Set<Id>();
            Set<String> fieldSet;
            oppIdset.add(opportunityId);
            fieldSet = new Set<String>(oliFields);
            oliList = SRV_CRM_OpportunityLineItem.getListOfOLI(oppIdset, fieldSet);
            List<OpportunityLineItemWrapper> oliWrapperList = new List<OpportunityLineItemWrapper>();
            for(OpportunityLineItem oli : oliList) {
                oliWrapperList.add(new OpportunityLineItemWrapper(oli));
            }
            opportunityWrapperList.add(new OpportunityWrapper(oliWrapperList));
        } catch(exception ex) {
            throw new AuraHandledException (JSON.serialize(ex));
        }
        return opportunityWrapperList;
    }
    
    @AuraEnabled
    public static List<CPQ_QuoteUtilityWO.QuoteLineItemWrapper> getListOfQLI(Id opportunityId) {
        List<CPQ_QuoteUtilityWO.QuoteLineItemWrapper> quoteWrapperList = new List<CPQ_QuoteUtilityWO.QuoteLineItemWrapper>();
        quoteWrapperList = CPQ_QuoteUtilityWO.getQuoteLineItemDetails(new Set<ID>{opportunityId});
        return quoteWrapperList;
    }
    
    /**
     * This method used to get field detail of Oli object
     * @params  String fieldData
     * @return  List<UTL_Sobject.ObjectFieldsWrapper>
     */
    @AuraEnabled
    public static List<ObjectFieldsWrapper> getOLIFieldDetail(String fieldData) {
        List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        try {
            List<String> fieldList = fieldData.split(',');
            objectSelectedFieldList = new UTL_Sobject(CON_CRM.OPPORTUNITYLINEITEM_OBJECT_API).getSobjectFieldDetails(fieldList);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return objectSelectedFieldList;
    }
    
    /**
     * This method used to get field detail of Oli object
     * @params  String objectName
     * @params  List<String> fieldList
     * @return  List<UTL_Sobject.ObjectFieldsWrapper>
     */
    @AuraEnabled
    public static List<ObjectFieldsWrapper> getSobjectFieldDetail(String objectName, List<String> fieldList) {
        List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        try {
            objectSelectedFieldList = new UTL_Sobject(objectName).getSobjectFieldDetails(fieldList);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return objectSelectedFieldList;
    }
    
    /**
     * This method is used to clone Opportunity records. 
     * @params  Id oppId
     * @params  Map<String,String> opportunity 
     * @params  Boolean isCloneOpportunity 
     * @params  Integer pricePercentAdjustment 
     * @params  Integer monthMoved
     * @params  Boolean isCloneProduct
     * @params  Boolean isCloneRevenueSchedule
     * @params  Boolean isCloneContactRole
     */    
    @AuraEnabled
    public static Id cloneOpportunityProducts(Id opportunityId, Map<String, String> mapTofieldValue, Decimal pricePercentAdjustment, Integer monthMoved, Map<String, Boolean> objectTypeToIsCloneMap) {
        Id createdOpportunityId = null;
        try {
            createdOpportunityId = SRV_CRM_Opportunity.cloneOpportunity(opportunityId, mapTofieldValue, true, pricePercentAdjustment, monthMoved, objectTypeToIsCloneMap);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return createdOpportunityId;
    }
    
    
    @AuraEnabled
    public static List<OpportunityLineItem> getInactiveOpportunityProducts(Id opportunityId){
        List<OpportunityLineItem> inactiveProductList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> inactiveProduct = new List<OpportunityLineItem>();
        Set<String> productNameSet = new Set<String>();
        Set<String> oliFieldSet = new Set<String>{'Id', 'Name', 'ProductCode', 'Product_Name__c'};
        
        try {
            inactiveProductList = new SLT_OpportunityLineItems(false).selectByOppIdandInactive(new Set<Id>{opportunityId}, oliFieldSet);
            
            if(inactiveProductList.size() > 0){
                for(OpportunityLineItem oli : inactiveProductList){
                    if(!productNameSet.contains(oli.Product_Name__c+oli.ProductCode)){
                        productNameSet.add(oli.Product_Name__c+oli.ProductCode);
                        inactiveProduct.add(oli);
                    }
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return inactiveProduct;
    }
    
    /**
     * This method used to perform CRUD on OLI
     * @params  String action
     * @params  String recordJSON
     */
    @AuraEnabled
    public static List<Id> crudOliRecord(String recordJSON) {
        List<Id> oliIdList = new List<Id>();
        try {
            List<OpportunityLineItemWrapper> oliWrapList = (List<OpportunityLineItemWrapper>)JSON.deserialize(recordJSON, List<OpportunityLineItemWrapper>.class);
            if(oliWrapList.size() > 0) {
                oliIdList = SRV_CRM_OpportunityLineItem.updateOliRecords(oliWrapList);
            }
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oliIdList;
    }
    
    /**
     * This method used to perform CRUD on OLI
     * @params  String action
     * @params  String recordJSON
     */
    @AuraEnabled
    public static void crudFavoriteProductRecord(String action, String recordJSON) {
        try {
            List<Favorite_Product__c> favoriteProductList = (List<Favorite_Product__c>)JSON.deserialize(recordJSON, List<Favorite_Product__c>.class);
            String objectName = CON_CRM.FAVORITEPRODUCT_OBJECT_API;
            SRV_CRM_Favorite_Product.modifyFavoriteProductRecords(favoriteProductList, objectName, action);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }

   /**
     *This method used to perform update
	 * @params  String productid
	 * @params  String userid
	 * @params  String comment
	 */
    @AuraEnabled
    public static void editFavoriteProductRecord(Id productId, String comment,String category) {
        List<Favorite_Product__c> favoriteProduct_List = new List<Favorite_Product__c>();
        try{
            List<Favorite_Product__c> favoriteProductList = new SLT_FavoriteProduct().selectByProduct2Id(productId);
            if(!favoriteProductList.isEmpty()){
                for(Favorite_Product__c favoriteProduct : favoriteProductList){
                    favoriteProduct.Id = favoriteProduct.id;
                    favoriteProduct.Product__c = productId;
                    favoriteProduct.User__c = UserInfo.getUserId();
                    favoriteProduct.User_Comment__c = comment;
                    favoriteProduct.Category__c = category;
                    favoriteProduct_List.add(favoriteProduct);
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        
        update favoriteProduct_List;
    }
    
    /**
     * This method used to update default product filter
     * @params  String defaultFilterObjString
     */
    @AuraEnabled
    public static void updateDefaultProductSearchFilter(String defaultFilterObjString) {
        try {
            Default_Product_Search__c filterProductSearch = (Default_Product_Search__c)JSON.deserialize(defaultFilterObjString, Default_Product_Search__c.Class);
            if(filterProductSearch.Id == null) {
                filterProductSearch.User__c = UserInfo.getUserId();
            }
            SRV_CRM_Default_Product_Search.updateDefaultProductSearchFilter(new List<Default_Product_Search__c>{filterProductSearch});
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    /**
     * This method used to get Opportunity Detail
     * @params  Id oppId
     * @params  String oppFields
     * @return  Opportunity
     */
    @AuraEnabled
    public static Opportunity getOpportunityDetails(Id oppId, List<String> oppFields) {
        Opportunity opp = new Opportunity();
        if(oppId != null) {
            Set<String> oppFieldSet = new Set<String>(oppFields);
            oppFieldSet.add('Amount');
            Set<Id> oppIdSet = new Set<Id>{oppId};
            Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
            try {
                idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(oppIdSet, oppFieldSet);   
                if(idToOpportunityMap.size() > 0) {
                    opp = idToOpportunityMap.get(oppId);
                    Decimal oppAmount = opp.Amount;
                    if(oppAmount != null){
                        String oppAmountStr = String.valueOf(oppAmount);
                        List<String> oppAmountStrSplit = oppAmountStr.split('\\.');
                        if(oppAmountStrSplit.size() > 1){
                            String decimalStr = oppAmountStrSplit[1];  // fetching decimal part (string after '.')
                            if(decimalStr.length() > 5){
                                opp.Amount = Math.round(opp.Amount);   // if decimal places is greater than 6 thn usign round
                            }
                        }
                    }
                }
            } catch (exception ex) {
                throw new AuraHandledException(JSON.serialize(ex));
            }
        }
        return opp;
    }
     /*
     * This method used to get Quote Detail
     * @params  Id quoteId
     * @return  Quote__c
     */
    @AuraEnabled
    public static Quote__c getQuoteDetails(Id quoteId, List<String> quoteFields) {
        Quote__c quote = new Quote__c();
        if(quoteId != null) {
            Set<String> quoteFieldSet = new Set<String>(quoteFields);
            Set<Id> quoteIdSet = new Set<Id>{quoteId};
            Map<Id, Quote__c> idToQuoteMap = new Map<Id, Quote__c>();
            idToQuoteMap = new SLT_IQVIA_Quote().getQuoteMap(quoteIdSet, quoteFieldSet);
            quote = idToQuoteMap.get(quoteId);
        }
        return quote;
    }
    /**
     * This method used to get Opportunity Lineitem Details
     * @params  List<Id> oppId
     * @params  List<String> oliFields
     * @return  List<OpportunityLineItem>
     */
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItemsDetail(List<Id> oliIdList, List<String> oliFieldList) {
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        try {
            oliList = SRV_CRM_OpportunityLineItem.getOpportunityLineItemsDetail(new Set<Id>(oliIdList), new Set<String>(oliFieldList));   
        } catch (exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oliList;
    }
    
    /**
     * This method used to fetch OpportunityLineItemSchedule
     * @params  Id opportunityLineItemId
     * @params  List<String> oliFields
     * @params  List<String> schFields
     * @return  OpportunityWrapper
     */
    @AuraEnabled
    public static OpportunityWrapper getOpportunityLineItemSchedule(Id opportunityLineItemId, List<String> oliFields, List<String> schFields) {
        OpportunityWrapper oppWrapper = new OpportunityWrapper();
        Set<Id> oliIdSet = new Set<Id>();
        oliIdSet.add(opportunityLineItemId);
        Map<Id, OpportunityLineItem> idToOliMap = new Map<Id, OpportunityLineItem>();
        try {
            idToOliMap = SRV_CRM_OpportunityLineItemSchedule.getOpportunityLineItemSchedule(oliIdSet, new Set<String>(oliFields), new Set<String>(schFields));
            if(idToOliMap.size() > 0) {
                List<OpportunityLineItemWrapper> lineItemWrapperList = new List<OpportunityLineItemWrapper>();
                OpportunityLineItemWrapper lineItemWrapper = null;
                for(OpportunityLineItem oli : idToOliMap.values()) {
                    lineItemWrapper = new OpportunityLineItemWrapper(oli);
                    lineItemWrapperList.add(lineItemWrapper);
                }
                CurrencyType currTpe = [SELECT DecimalPlaces FROM CurrencyType where IsoCode =: idToOliMap.values()[0].CurrencyIsoCode];
                decimalPlace = currTpe.DecimalPlaces;
                if(currTpe.DecimalPlaces != 0) {
                    Decimal num = Math.pow(10, currTpe.DecimalPlaces);
                    decimalPlaceStep = 1/num;
                } else {
                    decimalPlaceStep = currTpe.DecimalPlaces;
                }
                
                oppWrapper = new OpportunityWrapper(lineItemWrapperList, decimalPlace, decimalPlaceStep);
            }
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oppWrapper;
    }
    
    /**
     * This method used to fetch OpportunityLineItemSchedule
     * @params  String jsonWrapper
     * @return  OpportunityWrapper
     */
    @AuraEnabled
    public static OpportunityWrapper establishSchedule(String jsonWrapper) {
        OpportunityWrapper oppWrapper = new OpportunityWrapper();
        try {
            OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper establishWrapper = (OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper)JSON.deserialize(jsonWrapper, OpportunityWrapper.EsatblisOpportunityLineItemScheduleWrapper.class);
            Map<Id, OpportunityLineItem> idToOliMap = new Map<Id, OpportunityLineItem>();
            if(establishWrapper.oliId != null) {
                idToOliMap = SRV_CRM_OpportunityLineItemSchedule.insertOLISch(establishWrapper);
                if(idToOliMap.size() > 0) {
                    List<OpportunityLineItemWrapper> lineItemWrapperList = new List<OpportunityLineItemWrapper>();
                    OpportunityLineItemWrapper lineItemWrapper = null;
                    for(OpportunityLineItem oli : idToOliMap.values()) {
                        lineItemWrapper = new OpportunityLineItemWrapper(oli);
                        lineItemWrapperList.add(lineItemWrapper);
                    }
                    oppWrapper = new OpportunityWrapper(lineItemWrapperList);
                }
            }
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oppWrapper;
    }
    
    /**
     * This method used to update OpportunityLineItemSchedule
     * @params  String jsonWrapper
     */
    @AuraEnabled
    public static void updateOliSchedule(String jsonWrapper) {
        try {
            List<OpportunityLineItemScheduleWrapper> schWrapperList = (List<OpportunityLineItemScheduleWrapper>)JSON.deserialize(jsonWrapper, List<OpportunityLineItemScheduleWrapper>.class);
            if(schWrapperList.size() > 0) {
                SRV_CRM_OpportunityLineItemSchedule.crudOliSchedule(schWrapperList);
            }
        } catch(SRV_CRM_OpportunityLineItemSchedule.OpportunityLineItemScheduleServiceException exc) {
            throw new AuraHandledException(JSON.serialize(exc));
        }  catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    /**
     * This method used to get User Detail
     * @return  List<User>
     */
    @AuraEnabled(cacheable = true)
    public static List<User> getUserDetails() {
        List<User> usersList = new List<User>();
        usersList = SRV_CRM_User.getUserDetail(new Set<Id> {UserInfo.getUserId()});
        return usersList;
    }
    
    /**
     * This method used to getMulesoft Opportunity Sync Records By Opp Id
     * @return  List<Mulesoft_Opportunity_Sync__c>
     */
    @AuraEnabled
    public static List<Mulesoft_Opportunity_Sync__c> getMulesoftOpportunitySyncByOppIds(List<Id> oppIdList) {
        List<Mulesoft_Opportunity_Sync__c> muleSoftOppSyncList = new List<Mulesoft_Opportunity_Sync__c>();
        try {
            muleSoftOppSyncList = SRV_CRM_MulesoftOpportunitySync.getMulesoftOpportunitySyncByOppIds(new Set<Id>(oppIdList));
        } catch (exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return muleSoftOppSyncList;
    }
    
    /**
     * This method used to getMulesoft Opportunity Sync Records By Opp Id
     * @return  List<Mulesoft_Opportunity_Sync__c>
     */
    @AuraEnabled
    public static String getErrorIfLQMaterialProducts(Id oppId) {
        String errorMsg = '';
        Legacy_Org_Link__c legacyOrgLink = Legacy_Org_Link__c.getOrgDefaults();
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        Set<String> fieldSet = new Set<String>{'Id', 'LQ_Opportunity_Id__c'};
        try {
            idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{oppId}, fieldSet);
            if(idToOpportunityMap.size() > 0) {
                Id lqOppId = idToOpportunityMap.values()[0].LQ_Opportunity_Id__c;
                errorMsg = 'https://' + legacyOrgLink.Legacy_Quintiles_URL__c + '/' + lqOppId + '/e?retURL=%2F' + lqOppId;  
            }
        } catch (exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return errorMsg;
    }
    
    /**
     * This method used to get CurrencyType Decimal Detail
     * @return  List<User>
     */
    @AuraEnabled
    public static void decimalPlaceValue() {
        String oppId = Apexpages.currentPage().getParameters().get('id');
        if(oppId != null) {
            Set<String> oppFieldSet = new Set<String>{'CurrencyIsoCode'};
            Set<Id> oppIdSet = new Set<Id>{oppId};
            String isoCode;
            Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
            try {
                idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(oppIdSet, oppFieldSet);   
                if(idToOpportunityMap.size() > 0) {
                    Opportunity opp = idToOpportunityMap.get(oppId);
                    isoCode = opp.CurrencyIsoCode;
                    CurrencyType currTpe = [SELECT DecimalPlaces FROM CurrencyType where IsoCode =: isoCode];
                    decimalPlace = currTpe.DecimalPlaces;
                    if(currTpe.DecimalPlaces != 0) {
                        Decimal num = Math.pow(10, currTpe.DecimalPlaces);
                        decimalPlaceStep = 1/num;
                    } else {
                        decimalPlaceStep = currTpe.DecimalPlaces;
                    }
                }
            } catch (exception ex) {
                throw new AuraHandledException(JSON.serialize(ex));
            }
        }
    }
    @AuraEnabled
    public static String fetchContactRecordTypeId(){
        return CON_CRM.CONTACT_RECORD_TYPE_IQVIA_USER_CONTACT;
    }
    
    /**
     * This method used to fetch OpportunityLineItemSchedule
     * @params  Id mibnfId
     * @return  List<SObject>
     */
    @AuraEnabled(cacheable=true)
    public static List<MIBNFCompWrapper> getMIBNFComponent(Id mibnfId){
        Set<String> submittedStatus = new Set<String>{'Submitted', 'LO Accepted', 'RA Accepted', 'SAP Rejected','SAP Contract Confirmed', 'SAP Contract Pending'};
        List <MIBNF_Component__c> mibnfComponents = new SLT_MIBNF_Component().selectByMIBNFIdAndNotStatus(new Set<String> {'Id', 'Name', 'Bill_To__r.Name', 'Client_PO_Number__c', 'Invoice_Header_Text__c', 'Contract_Value__c','BNF_Status__c', 'MIBNF__r.Contract_Value__c', 'MIBNF__r.Name', 'Opportunity__r.Is_Any_BNF_Submitted__c','CurrencyIsoCode'}, mibnfId, submittedStatus);
        List<MIBNFCompWrapper> mibnfCompWrapperList = new List<MIBNFCompWrapper>();
        MIBNFCompWrapper mibnfCompWrapper = new MIBNFCompWrapper();
        Map<Id,List<Billing_Schedule_Item__c>> oliIdToBillingSchMap = new Map<Id,List<Billing_Schedule_Item__c>>();
        Map<Id,OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>();
        Boolean canChangeOppAmount = true;
        List<MI_BNF_LineItem__c> mibnfLineItems = new List<MI_BNF_LineItem__c>();
        Map<Id, Set<Id>> mibnfCompIdToOiliMap = new Map<Id, Set<Id>>();
		Set<Id> oliIds = new Set<Id>();
        
        if(mibnfComponents.size() > 0){
            mibnfLineItems = new SLT_MIBNFLineItem().selectByFilter(new Set<Id>{mibnfId}, new Set<String>{'Id','MIBNF_Component__c','Opportunity_Line_Itemid__c'}, 'MIBNF_Component__r.MIBNF__c = \''+mibnfId + '\'');
            for(MI_BNF_LineItem__c lineItem : mibnfLineItems){
                oliIds.add(lineItem.Opportunity_Line_Itemid__c);
                if(mibnfCompIdToOiliMap.containskey(lineItem.MIBNF_Component__c)){
                    mibnfCompIdToOiliMap.get(lineItem.MIBNF_Component__c).add(lineItem.Opportunity_Line_Itemid__c);
                }else{
                    mibnfCompIdToOiliMap.put(lineItem.MIBNF_Component__c, new Set<Id>{lineItem.Opportunity_Line_Itemid__c});
                }
            }
            system.debug(mibnfCompIdToOiliMap);
            system.debug(mibnfComponents);
            canChangeOppAmount = getCanUpdateOppPrice(mibnfComponents[0].Opportunity__c, mibnfComponents[0].Opportunity__r.Is_Any_BNF_Submitted__c);
            oliMap = new Map<Id,OpportunityLineItem>(new SLT_OpportunityLineItems().selectByOLIIds(oliIds, new Set<String>{'Id', 'Name', 'UnitPrice','Product2.Name','CurrencyIsoCode'}));
            oliIdToBillingSchMap = getBillingSchedule(oliIds);
            for(MIBNF_Component__c mibnfComp: mibnfComponents){
                Set<ID> oliListOfMibnf = new Set<ID> ();
                Map<Id, OpportunityLineItem> oliMapOfMibnf = new Map<Id, OpportunityLineItem>();
                Map<Id,List<Billing_Schedule_Item__c>> oliIdToBillingSchMapOfMibnf = new Map<Id,List<Billing_Schedule_Item__c>>();
                if(mibnfCompIdToOiliMap.get(mibnfComp.Id) != null ){
                    oliListOfMibnf = mibnfCompIdToOiliMap.get(mibnfComp.Id);
                    oliMapOfMibnf = new Map<Id, OpportunityLineItem>();
                    oliIdToBillingSchMapOfMibnf = new Map<Id,List<Billing_Schedule_Item__c>>();
                    system.debug(oliListOfMibnf);
                    system.debug(oliMap.keyset());
                    for(OpportunityLineItem oli : oliMap.values()){
                        if(oliListOfMibnf.contains(oli.id)){
                            oliMapOfMibnf.put(oli.id, oli);
                            oliIdToBillingSchMapOfMibnf.put(oli.id,oliIdToBillingSchMap.get(oli.id));
                        }
                    }
                    mibnfCompWrapper = new MIBNFCompWrapper(mibnfComp, oliMapOfMibnf, oliIdToBillingSchMapOfMibnf, canChangeOppAmount);
                }else{
                    mibnfCompWrapper = new MIBNFCompWrapper(mibnfComp, new Map<Id, OpportunityLineItem>(), new Map<Id,List<Billing_Schedule_Item__c>>(), canChangeOppAmount);
                }
                mibnfCompWrapperList.add(mibnfCompWrapper);
            }            
        }
		system.debug(mibnfCompWrapperList);
        return mibnfCompWrapperList;
    }
    
    public static Boolean getCanUpdateOppPrice(Id oppId, Boolean  isBnfSubmitted){
        Boolean canChangeOppAmount = false;
        Set<Id> oppIdSet = new Set<Id>{oppId};
            Boolean approvedPricingAssitantExist = false;
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        system.debug(isBnfSubmitted);//cannot update
        if(!mulesoftSetting.Ignore_Validation_Rules__c) {
            system.debug(mulesoftSetting);
            Set<String> fieldSet = new Set<String>{'Id', 'PA_Status__c', 'LI_Record_Id__c', 'Opportunity__c', 'Opportunity__r.PA_Required__c'};
                List<Proxy_Pricing_Assistant__c> proxyPAList = new SLT_ProxyPricingAssistant().selectByOpportunityIds(oppIdSet, fieldSet);
            for(Proxy_Pricing_Assistant__c ppaRecord : proxyPAList) {
                if(ppaRecord.PA_Status__c == CON_CRM.PA_STATUS_APPROVED || ppaRecord.PA_Status__c == CON_CRM.SUBMITTED) {
                    approvedPricingAssitantExist = true;
                    break;
                }
            }
            system.debug(proxyPAList);
            system.debug(approvedPricingAssitantExist);//cannot update
            if(!approvedPricingAssitantExist && !isBnfSubmitted){
                system.debug(approvedPricingAssitantExist);
                system.debug(canChangeOppAmount);
                canChangeOppAmount = true;
            }
        }
        system.debug(canChangeOppAmount);
        return canChangeOppAmount;
    }
    
    /**
     * This method used to fetch OpportunityLineItems BillingSchedule
     * @params  Id mibnfId
     * @return  List<SObject>
     */
    public static Map<Id,List<Billing_Schedule_Item__c>> getBillingSchedule(Set<Id> oliIds){
        Map<Id,OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>();
        List<Billing_Schedule_Item__c> billingScheduleItemList = new List<Billing_Schedule_Item__c>();
        Map<Id,Id> oliToBnfIdMap = new Map<Id,Id>();
        Map<Id,List<Billing_Schedule_Item__c>> OliToBillSch = new Map<Id,List<Billing_Schedule_Item__c>>();

        if(oliIds.size()>0){
            billingScheduleItemList = [Select id, Billing_Date__c, Billing_Schedule__c, Billing_Amount__c, Billing_Schedule__r.OLIId__c from Billing_Schedule_Item__c where Billing_Schedule__r.OLIId__c IN :oliIds];
        }
        system.debug(billingScheduleItemList);
        for(Billing_Schedule_Item__c billsch : billingScheduleItemList){
            billsch.Billing_Amount__c = billsch.Billing_Amount__c.setScale(2);
            if(OliToBillSch.containsKey(billsch.Billing_Schedule__r.OLIId__c)){
                OliToBillSch.get(billsch.Billing_Schedule__r.OLIId__c).add(billsch);
            }else{
                OliToBillSch.put(billsch.Billing_Schedule__r.OLIId__c, new List<Billing_Schedule_Item__c>{billsch});
            }
        }
        system.debug(OliToBillSch);
        return OliToBillSch;
    }
    
    /** 
     * This method used to fetch OpportunityLineItemSchedule
     * @params  String recordJSON
     * @params  List<String> oliFields
     * @params  List<String> schFields
     * @return  List<String>
     */
    @AuraEnabled
    public static Boolean massUpdateBNF(String recordJSON, String invoiceTextValue, String billingPlanMap, String bnfValue) {
        system.debug(recordJSON + ' - - - - ' + invoiceTextValue+ ' - ' + billingPlanMap+ ' - ' + bnfValue + ' - ');

        if(!MI_BNF_Approval_Extension.CustomApprovalPage){
           MI_BNF_Approval_Extension.CustomApprovalPage = true; //to avoid bnf's can not be approved from this screen error.
        }
         
        Decimal noOfRecordsUpdatedForBillingPlan = 0;
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{
                					MIBNF_Component__c.SObjectType,
               		 				OpportunityLineItem.SObjectType, 
                                    OpportunityLineItemSchedule.SObjectType, 
                					Billing_Schedule_Item__c.SObjectType,
                					MI_BNF_LineItem__c.SObjectType});
        List<String> ErrorMsgs = new List<String>();
        Boolean changesMade = false;
        Boolean toCommit = false;
        Boolean UserIsSysAdmin = false;
        Map<Id, Boolean> AllowedToApproveMap = new Map<Id, Boolean>();  
        Boolean hasAccessBNFAll = false;
        Boolean AllowedToApprove = true;
        List<MIBNF_Component__c> checkForSysAdminAndApprover = new List<MIBNF_Component__c>();
        Set<Id> checkForSysAdminAndApproverIds = new Set<Id>();
        Map<Id,Date> billingPlanDateMap = new Map<Id,Date>();
        Set<String> notSubmittedRejectedStatus = new Set<String>{'New', 'Rejected', 'SAP Rejected', 'LO Rejected', 'RA Rejected'};
        Set<String> submittedStatus = new Set<String>{'Submitted', 'LO Accepted', 'RA Accepted'};
   
        Map<Id,List<MI_BNF_LineItem__c>> mibnfDetailMap = new Map<Id,List<MI_BNF_LineItem__c>>();
        List<MIBNF_Component__c> mibnfData = new List<MIBNF_Component__c>();
              
        List<MIBNF_Component__c> bnfsToReject = new List<MIBNF_Component__c>();
        List<MIBNF_Component__c> bnfsToUpdate = new List<MIBNF_Component__c>(); //invoiceheader or bnf status update
        List<MIBNF_Component__c> createRevisedBnfList = new List<MIBNF_Component__c>(); //bnfs for which new revised bnf will be created        
        Set<Id> revisedOlis = new Set<Id>();
        List<OpportunityLineItem> revisedOliList = new List<OpportunityLineItem>();
		List<Billing_Schedule_Item__c> billingScheduleItemList = new List<Billing_Schedule_Item__c>();
        List<Billing_Schedule_Item__c> billingScheduleItemListUpdated = new List<Billing_Schedule_Item__c>();
        
        Set<Id> mibnfComponentsIds = (Set<Id>) JSON.deserialize(recordJSON, Set<Id>.class);
        
        Set<id> olids = new Set<id>(); 
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Map<Id,OpportunityLineItem> oliMap = new Map<Id,OpportunityLineItem>();
        
        if(billingPlanMap != null){
            billingPlanDateMap = (Map<Id,Date>)JSON.deserialize(billingPlanMap,Map<Id,Date>.class);
        }
        system.debug(mibnfComponentsIds);
        if(mibnfComponentsIds != null ){
            mibnfData = getMibnfDetailsWithLineItem(mibnfComponentsIds);
            system.debug(mibnfData);
            for(MIBNF_Component__c mibnfComp : mibnfData){
                List<MI_BNF_LineItem__c> lineItemList = new List<MI_BNF_LineItem__c>();
                if(mibnfComp.MI_BNF_LineItems__r.size() > 0){
                    for(MI_BNF_LineItem__c mibnfLineItem : mibnfComp.MI_BNF_LineItems__r){
                        lineItemList.add(mibnfLineItem);
                        olids.add(mibnfLineItem.Opportunity_Line_Itemid__c);
                    }
                    mibnfDetailMap.put(mibnfComp.id, lineItemList);
                }
            }
            system.debug(mibnfDetailMap.values());
            if((bnfValue != null && bnfValue != '') || billingPlanDateMap.size() > 0){
                oliList = new SLT_OpportunityLineItems().selectByOLIIds(olids, new Set<String>{'Id', 'UnitPrice', 'HasRevenueSchedule', 'Product_Material_Type_Text__c','Product2.Item_Category_Group__c'});
                oliMap = new Map<Id, OpportunityLineItem>(oliList);
                system.debug(oliMap.values());
            }
            system.debug(oliList);
        }
        for(MIBNF_Component__c mibnfComp : mibnfData){
            if(notSubmittedRejectedStatus.contains(mibnfComp.BNF_Status__c)){
                if(invoiceTextValue != null && invoiceTextValue != ''){
                    mibnfComp.Invoice_Header_Text__c = invoiceTextValue;
                    bnfsToUpdate.add(mibnfComp);
                }
            }/*else if(submittedStatus.contains(mibnfComp.BNF_Status__c)){
                //mibnfComp.BNF_Status__c = 'Rejected';
                mibnfComp.Rejection_Reasons__c = 'Other';
                mibnfComp.Rejection_Reasons_Multi__c = 'Other';
                bnfsToReject.add(mibnfComp);
                if(invoiceTextValue != null && invoiceTextValue != ''){
                    mibnfComp.Invoice_Header_Text__c = invoiceTextValue;
                }
                //bnfsToUpdate.add(mibnfComp);
                throw new massUpdateFailException('You cannot modify the record, as it is already in the approval process. Please reject it first to make changes.');
            }else if(mibnfComp.BNF_Status__c == 'SAP Contract Confirmed'){
                createRevisedBnfList.add(mibnfComp);
                for(List<MI_BNF_LineItem__c> mibnfLineItemList : mibnfDetailMap.values()){
                    for(MI_BNF_LineItem__c mibnfLineItem : mibnfLineItemList){
                        revisedOlis.add(mibnfLineItem.Opportunity_Line_Itemid__c);
                        revisedOliList.add(oliMap.get(mibnfLineItem.Opportunity_Line_Itemid__c));
                    }
                }
            }
            
            if(mibnfComp.BNF_Status__c == 'SAP Rejected'){
                checkForSysAdminAndApprover.add(mibnfComp);
                checkForSysAdminAndApproverIds.add(mibnfComp.id);
            }*/
        }
        system.debug(bnfsToUpdate);
        system.debug(bnfsToReject);
        system.debug(createRevisedBnfList);
        system.debug(checkForSysAdminAndApprover);
        SavePoint sp = Database.setSavePoint();
        
        try{ 
            /*if(bnfValue != null && bnfValue != '' && checkForSysAdminAndApprover.size() > 0){
                //to handle scenario where BNF status is SAP Rejected and price change request is made. 
                User U = [select Id, Sales_Org__c,Profile.Name from User where Id = :UserInfo.getUserId()][0];
                UserIsSysAdmin = U.Profile.Name.contains('Administrator') ? true : false;
                system.debug(UserIsSysAdmin);
                List<PermissionSetAssignment> permSetAssList = new SLT_PermissionSetAssignment().selectByPermissionSetForUserId(new Set<String>{'Id', 'PermissionSet.Name', 'AssigneeId'}, new Set<Id>{Userinfo.getUserId()},'Modify_all_privileges_on_BNF');
                if(permSetAssList.size() > 0) {
                    hasAccessBNFAll = true; 
                }
                system.debug(hasAccessBNFAll);
                List<ProcessInstanceWorkitem> pWitemList = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetId(checkForSysAdminAndApproverIds);
                system.debug(pWitemList);
                for(ProcessInstanceWorkitem pWitem : pWitemList){
                    if(pWitem.ActorId != U.Id ){
                        AllowedToApprove = false;
                        break;
                    }     
                }
                system.debug(AllowedToApprove);
                if(!(UserIsSysAdmin || AllowedToApprove || hasAccessBNFAll)) {
                    throw new massUpdateFailException('Products from Submitted BNF cannot be edited.');
                }
            }*/
            /*if(bnfsToReject.size() > 0){
                rejectMibnfComponents(bnfsToReject);
            }
            if(createRevisedBnfList.size() > 0){
                createRevisedBNF(mibnfData, invoiceTextValue, mibnfDetailMap, submitForApproval, uow);
                toCommit = true;
            }*/
            if((bnfValue != null && bnfValue != '') || (billingPlanDateMap.size() > 0) ){
                billingScheduleItemList = [Select id, Billing_Date__c, Billing_Schedule__c, Billing_Amount__c, Billing_Schedule__r.OLIId__c from Billing_Schedule_Item__c where Billing_Schedule__r.OLIId__c IN :olids];//Billing_Date__c IN :billingPlanDateMap.keyset() AND
            }
            system.debug(billingScheduleItemList);
            if(bnfValue != null && bnfValue != '' && mibnfDetailMap.values().size()> 0){
                system.debug(revisedOliList);
                billingScheduleItemListUpdated = updateOLIPrice(billingScheduleItemList, oliList, Decimal.valueOf(bnfValue), uow, revisedOliList); // pass a revised list here 
                toCommit = true;
            }
            if(billingPlanDateMap.size() > 0 && mibnfDetailMap.values().size()> 0){
                Decimal noOfBillingPlanUpdate = 0;
                noOfBillingPlanUpdate = updateBillingPlan(billingScheduleItemListUpdated.size() >0 ? billingScheduleItemListUpdated:billingScheduleItemList, billingPlanDateMap, uow);
                if(noOfBillingPlanUpdate > 0)
                    toCommit = true;
            }
            
            if(bnfsToUpdate.size() > 0){
                Decimal noOfUpdates = 0;
                bnfsToUpdate.size();
                uow.registerDirty(bnfsToUpdate);
                toCommit = true;
            }
            if(toCommit){
                uow.commitWork();
                changesMade = true;
               /* if(submitForApproval && bnfsToUpdate.size() > 0){
                    submitForApprovalMethod(bnfsToUpdate);
                }*/
                //return new List<Boolean>{toCommit, noOfRecordsUpdatedForBillingPlan};
            }
        }catch(Exception ex){
            Database.rollback(sp);
            changesMade = false;
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            ErrorMsgs.add(ex.getMessage());
            throw new massUpdateFailException(ex.getMessage());
        }
        return changesMade;
    }
    
    /*public static void rejectMibnfComponents(List<MIBNF_Component__c> bnfsToReject){
        Set<Id> rejectBnfsIds = new Set<Id>();
        for(MIBNF_Component__c bnf : bnfsToReject){
            rejectBnfsIds.add(bnf.id);
        }
        List<ProcessInstanceWorkitem> pWitemList = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetId(rejectBnfsIds);
        system.debug(pWitemList);
        Map<Id, Id> mibnfCompIdToWorkItemIdMap = new Map<Id,Id>();
        for(ProcessInstanceWorkitem pWitem : pWitemList){
            mibnfCompIdToWorkItemIdMap.put(pWitem.ProcessInstance.TargetObjectId, pWitem.id);
        }
        List<Approval.ProcessWorkitemRequest> reqList = new List<Approval.ProcessWorkitemRequest>();
        for(MIBNF_Component__c mibnfComp: bnfsToReject){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Reject');
            if(mibnfCompIdToWorkItemIdMap.containsKey(mibnfComp.id)){
                req.setWorkitemId(mibnfCompIdToWorkItemIdMap.get(mibnfComp.id));
                // Reject the request for approval
                reqList.add(req);
            }      
        }
        try{
            if(reqList.size() > 0){
                List<Approval.ProcessResult> resultList =  Approval.process(reqList);
                pWitemList = new SLT_ProcessInstanceWorkitem().getProcessInstanceWorkitemByTargetId(rejectBnfsIds);//query for double rejection scenario - RA Accepted status
                system.debug(pWitemList);
                mibnfCompIdToWorkItemIdMap = new Map<Id,Id>();
                if(pWitemList.size() > 0){
                    for(ProcessInstanceWorkitem pWitem : pWitemList){
                        mibnfCompIdToWorkItemIdMap.put(pWitem.ProcessInstance.TargetObjectId, pWitem.id);
                    }
                    List<Approval.ProcessWorkitemRequest> reqList2 = new List<Approval.ProcessWorkitemRequest>();
                    for(MIBNF_Component__c mibnfComp: bnfsToReject){
                        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                        req.setAction('Reject');
                        if(mibnfCompIdToWorkItemIdMap.containsKey(mibnfComp.id)){
                            req.setWorkitemId(mibnfCompIdToWorkItemIdMap.get(mibnfComp.id));
                            // Reject the request for approval 
                            reqList2.add(req);
                        }      
                    }  
                    if(reqList2.size() > 0){
                        resultList =  Approval.process(reqList2);
                    }
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            String errorMessage = '';
            if(ex.getMessage().contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY')){
                errorMessage = 'You cannot modify the record, as it is already in the approval process.';
            }
            throw new massUpdateFailException(errorMessage != '' ? errorMessage : ex.getMessage());
        }
    }
    */
    public static List<Billing_Schedule_Item__c> updateOLIPrice(List<Billing_Schedule_Item__c> billingScheduleItemList, List<OpportunityLineItem> oliList, Decimal bnfValue, fflib_SObjectUnitOfWork uow, List<OpportunityLineItem> revisedOliList){
        
        system.debug(bnfValue<0);
        Set<id> oliIds = new Set<Id>();
        Set<Id> oliForBillingSchedule = new Set<Id>();
        Set<Id> revisedOliIds = new Set<Id>();
        List<Billing_Schedule_Item__c> billingSchItemScheduleListToUpdate = new List<Billing_Schedule_Item__c>();
        List<OpportunityLineItem> oliListToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliListToUpdateSchedule = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> lineItemScheduleListToUpdate = new List<OpportunityLineItemSchedule>();
        /*for(OpportunityLineItem oli :  revisedOliList){
            revisedOliIds.add(oli.id);
        }*/
        for(OpportunityLineItem oli : oliList){
            if(oli.UnitPrice != 0 && oli.HasRevenueSchedule && (oli.Product_Material_Type_Text__c == 'ZREP' || oli.Product_Material_Type_Text__c == 'ZPUB') ){
                oliListToUpdateSchedule.add(oli);
                oliIds.add(oli.id);
                if(oli.Product_Material_Type_Text__c == 'ZREP' || (oli.Product_Material_Type_Text__c == 'ZPUB' && oli.Product2.Item_Category_Group__c == 'ZLIC')){
                  oliForBillingSchedule.add(oli.id);
                }
            }else {
                if(oli.UnitPrice != null){
                    oli.UnitPrice =  oli.UnitPrice + oli.UnitPrice*bnfValue*0.01; 
                    oliListToUpdate.add(oli);
                }
            }
        }
        system.debug(oliListToUpdate);
        system.debug(oliListToUpdateSchedule);
        List<OpportunityLineItemSchedule> oliRevisedSchedule = new List<OpportunityLineItemSchedule>();
        if(oliListToUpdateSchedule.size() > 0){
            List<OpportunityLineItemSchedule> exisitngLineItemSchedule = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(oliIds,new Set<String>{'Id', 'OpportunityLineItemId', 'Type', 'Revenue', 'Quantity', 'Description', 'ScheduleDate' });
            system.debug(exisitngLineItemSchedule);
            //Map<Id,List<OpportunityLineItemSchedule>> oliToScheduleMap = new Map<Id,List<OpportunityLineItemSchedule>>();
            
            if(exisitngLineItemSchedule.size() > 0){
                for(OpportunityLineItemSchedule oliSch : exisitngLineItemSchedule){
                    /*if(revisedOliIds != null && revisedOliIds.contains(oliSch.OpportunityLineItemId)){
                        if(oliToScheduleMap.containsKey(oliSch.OpportunityLineItemId)){
                            oliToScheduleMap.get(oliSch.OpportunityLineItemId).add(oliSch);
                            
                        }else{
                            oliToScheduleMap.put(oliSch.OpportunityLineItemId,new List<OpportunityLineItemSchedule>{oliSch});
                        } 
                        oliRevisedSchedule.add(oliSch);
                    }else{*/
                        oliSch.Revenue = oliSch.Revenue + oliSch.Revenue*bnfValue*0.01;
                        lineItemScheduleListToUpdate.add(oliSch);
                        system.debug(oliSch.Revenue*bnfValue*0.01);
                    //}
                    
                }
                
                /*for(OpportunityLineItem oli : revisedOliList){
                    String revisedRevenueSch = '';
                    Decimal revisedPrice = 0;
                    
                    system.debug(oliToScheduleMap);
                    for(OpportunityLineItemSchedule oliSch : oliToScheduleMap.get(oli.id)){
                        Decimal revisedRevenue = 0;
                        revisedRevenue = oliSch.Revenue + oliSch.Revenue*0.01*bnfValue; 
                        revisedRevenueSch += String.valueOf(oliSch.ScheduleDate.Year()) + ('0'+String.valueOf(oliSch.ScheduleDate.Month())).right(2) + ('0'+String.valueOf(oliSch.ScheduleDate.Day())).right(2) + ':' + String.valueOf(revisedRevenue)+ '|';
                        revisedPrice += revisedRevenue;
                    }
                    if(bnfValue != 0){
                        oli.Revised_Revenue_Schedule__c = revisedRevenueSch;
                        oli.Revised_Price__c = revisedPrice;
                        oliListToUpdate.add(oli);
                    }
                }*/
                system.debug(lineItemScheduleListToUpdate);
            }
            
        }
        if(oliForBillingSchedule.size() > 0) {            
            system.debug(billingScheduleItemList);
            
            if(billingScheduleItemList.size() > 0) {
                Decimal billingAmount = 0;
                system.debug(bnfValue);
                for(Billing_Schedule_Item__c billingScheduleItem : billingScheduleItemList){
                    system.debug(billingScheduleItem);
                    billingScheduleItem.Billing_Amount__c = billingScheduleItem.Billing_Amount__c +billingScheduleItem.Billing_Amount__c*0.01*bnfValue;
                    billingSchItemScheduleListToUpdate.add(billingScheduleItem);
                }
            }
            system.debug(billingSchItemScheduleListToUpdate);
        }
        try{
            system.debug(oliListToUpdate);
            system.debug(lineItemScheduleListToUpdate);
            system.debug(billingSchItemScheduleListToUpdate);
            
            if(oliListToUpdate.size() > 0){
                uow.registerDirty(oliListToUpdate);
            }
            if(lineItemScheduleListToUpdate.size() > 0){
                uow.registerDirty(lineItemScheduleListToUpdate);
            }
            if(billingSchItemScheduleListToUpdate.size() > 0){
                uow.registerDirty(billingSchItemScheduleListToUpdate);
            }
        }catch(Exception ex){
            system.debug(ex.getStackTraceString());
            system.debug(ex.getMessage());
            throw new massUpdateFailException(ex.getMessage());
        }finally{
            return billingSchItemScheduleListToUpdate;
        }
        return billingSchItemScheduleListToUpdate;
    }
    
    public static Decimal updateBillingPlan(List<Billing_Schedule_Item__c> billingScheduleItemList, Map<Id,Date> billingPlanDateMap, fflib_SObjectUnitOfWork uow){
        List<Billing_Schedule_Item__c> billingSchItemScheduleListToUpdate = new List<Billing_Schedule_Item__c>();

        if(billingScheduleItemList.size() > 0){
            for(Billing_Schedule_Item__c billSchItem: billingScheduleItemList){
                if(billingPlanDateMap.keyset().contains(billSchItem.id)){
                    billSchItem.Billing_Date__c = billingPlanDateMap.get(billSchItem.id);
                    billingSchItemScheduleListToUpdate.add(billSchItem);
                }
            }  
            system.debug(billingSchItemScheduleListToUpdate);
            /*if(billingScheduleItemListwithBillingDate.size() > 0) {
                for(Billing_Schedule_Item__c billingScheduleItem : billingScheduleItemListwithBillingDate){
                    Date existingDate = billingScheduleItem.Billing_Date__c;
                    if(billingPlanDateMap.containsKey(existingDate)){
                        billingScheduleItem.Billing_Date__c = billingPlanDateMap.get(existingDate);
                        billingSchItemScheduleListToUpdate.add(billingScheduleItem);
                    }
                }
            }*/
            system.debug(billingSchItemScheduleListToUpdate);
        }
        try{
            if(billingSchItemScheduleListToUpdate.size() > 0){
                uow.registerDirty(billingSchItemScheduleListToUpdate);
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            throw new massUpdateFailException(ex.getMessage());
        }
        return billingSchItemScheduleListToUpdate.size();
    }
    
    
    public static List<MIBNF_Component__c> getMibnfDetailsWithLineItem(Set<Id> bnfIds){
        Set<String> lineItemFields = new Set<String>{'Id', 'Name', 'MIBNF_Component__c', 'Opportunity_Line_Itemid__c', 'MIBNFComponent_OLI_ID__c', 'Total_Price__c'};
            Set<String> mibnfCompFields = new Set<String>{'Id', 'Name', 'MIBNF__c', 'Addendum__c', 'BNF_Status__c', 'Manual_Handling_in_SAP__c', 'Billing_Frequency__c', 'Revised_BNF_Date__c',
                'Payment_Terms__c', 'Additional_Delivery_Date_Information__c', 'Revised_BNF_Reason__c', 'Delivery_Date__c', 'Client_PO_Number__c',
                'Revised_BNF_Comment__c', 'Invoice_Header_Text__c', 'Billing_Currency__c', 'SAP_Contract__c', 'Additional_Billing_Date_Information__c',
                'Invoice_Default_Day__c', 'Is_this_a_retainer_downpayment__c', 'Subscription_Type__c', 'Retainer_Data_Value__c', 'Specification__c', 'Description__c',
                'Print_Shop__c', 'Travel_Amount__c', 'Accomodation_Amount__c', 'Sub_Contractor_Amount__c', 'Hono__c', 'X2nd_Copy__c', 'X2nd_Copy_SAP_Contact__c', 'Ship_To__c',
                'Ship_To_SAP_Contact__c','Cover_Sheet__c', 'Cover_Sheet_SAP_Contact__c', 'Carbon_Copy__c', 'Bill_To__c', 'Bill_To_SAP_Contact__c', 'SAP_Master_Contract__c', 'Carbon_Copy_SAP_Contact__c',
                'CurrencyIsoCode', 'BNF_Description__c', 'Sold_To__c', 'Sold_To__r.SAP_Reference__c', 'Project_Name__c', 'Comments__c'};
                    List<MIBNF_Component__c> mibnfList = new SLT_MIBNF_Component().getMibnfCompByIdsWithLineItem(bnfIds, mibnfCompFields, lineItemFields);
        system.debug(mibnfList);
        return mibnfList;
    }
    
    @AuraEnabled
    public static String getFavoriteProductReport(){
        String userName = UserInfo.getUserName();
        String reporturl;
        try{
            Report re = [SELECT Id FROM Report Where DeveloperName = 'Favorite_Product_DF' LIMIT 1];
            if(re != null){
                reporturl = URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/Report/'+re.Id+'/view?queryScope=userFolders&fv0='+userName;
            }else{
                throw new AuraHandledException('Report does not exiest please contect admin.');
            }
        }catch(Exception ex){
            if(ex.getMessage() == 'List has no rows for assignment to SObject'){
                throw new AuraHandledException('Report does not exiest please contect admin.');
            }else{
                throw new AuraHandledException(ex.getMessage());
            }
        }
        return reportUrl.replaceAll(' ','%20');
    }
    
	/** 
     * This method used to create Quote line items
     * @params  String productDataJson
	 * @params String featureSettings
     * @return  UTL_CPQ_Services.WPR_CPQ_ReturnItems with details if line item created successfully or not
     */
    @AuraEnabled
    public static UTL_CPQ_Services.WPR_CPQ_ReturnItems createQuoteLineItems(String productDataJson, String featureSettings){
        return UTL_CPQ_Services.insertQLIs(String.valueOf(productDataJson), String.valueOf(featureSettings));
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItemWrapper> getTherapyAreaByProduct(String recordJSON){
        List<OpportunityLineItemWrapper> oliWrapList = new List<OpportunityLineItemWrapper>();
        List<String> allTherapyAreaList = new List<String>();
        List<Schema.PicklistEntry> therapyAreaPickEntryList = OpportunityLineItem.Therapy_Area__c.getDescribe().getPicklistValues();
        Map<String, String> allTherapyAreaMap = new Map<String,String>();
        Map<String, String> therapyAreaKeyToValueMap = new Map<String, String>();
        for(Schema.PicklistEntry pickEntry : therapyAreaPickEntryList){
            allTherapyAreaMap.put(pickEntry.getLabel(),pickEntry.getValue());
            allTherapyAreaList.add(pickEntry.getLabel());
            therapyAreaKeyToValueMap.put(pickEntry.getValue().substringBetween('[',']'), pickEntry.getValue()); 
        }
        
        try{
            oliWrapList = (List<OpportunityLineItemWrapper>)JSON.deserialize(recordJSON, List<OpportunityLineItemWrapper>.class);
            
            for(OpportunityLineItemWrapper oli: oliWrapList){
                List<String> therapyAreaoptionList = new List<String>();
                Map<String,String> therapyAreaoptionMap = new Map<String,String>();
                therapyAreaoptionMap.put('--None--', '');
                therapyAreaoptionList.add('--None--');
                if(oli.oliRecord.Product2.Therapy_Class__c == null || oli.oliRecord.Product2.Therapy_Class__c == ''){
                    therapyAreaoptionMap.putAll(allTherapyAreaMap);
                    therapyAreaoptionList.addAll(allTherapyAreaList);
                }else{
                    for (String therapyAreaOption : oli.oliRecord.Product2.Therapy_Class__c.split(':')){
                        if(therapyAreaKeyToValueMap.containsKey(therapyAreaOption)){
                            therapyAreaoptionMap.put(therapyAreaKeyToValueMap.get(therapyAreaOption),therapyAreaKeyToValueMap.get(therapyAreaOption));
                            therapyAreaoptionList.add(therapyAreaKeyToValueMap.get(therapyAreaOption));
                        }
                        /*
                        if(oli.Therapy_Area__c != null && !therapyAreavaluesSet.contains(oli.Therapy_Area__c)) {
                            therapyAreaoptionList.add(new SelectOption(oli.Therapy_Area__c, oli.Therapy_Area__c));
                        }*/
                    }
                }
                oli.therapyAreaOptions = therapyAreaoptionList;
            }
            
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return oliWrapList;
    }
    
    /*public static void createRevisedBNF(List<MIBNF_Component__c> MIBNF_CompList, String invoiceHeader, Map<Id,List<MI_BNF_LineItem__c>> mibnfDetailMap, Boolean submitForApproval, fflib_SObjectUnitOfWork uow){
        List<MIBNF_Component__c> MIBNF_Comp_RevisedList = new List<MIBNF_Component__c>();
        List<MI_BNF_LineItem__c> RevisedCompList = new List<MI_BNF_LineItem__c>();
        List<MI_BNF_LineItem__c> mibnfLineItemList = [Select Total_Price__c, Opportunity_Line_Itemid__c,MIBNF_Component__c,CurrencyIsoCode From MI_BNF_LineItem__c where MIBNF_Component__c IN :MIBNF_CompList];
        Map<Id,List<MI_BNF_LineItem__c>> mibnfLineItemMap = new Map<Id,List<MI_BNF_LineItem__c>>();
        Set<Id> oliIdSetToRevisePrice = new Set<Id>();
        system.debug(mibnfDetailMap);
        for(MIBNF_Component__c MIBNF_Comp : MIBNF_CompList){
            MIBNF_Component__c MIBNF_Comp_Revised = MIBNF_Comp.clone(false, true, false, false); 
            MIBNF_Comp_Revised.BNF_Status__c = 'New';
            MIBNF_Comp_Revised.Addendum__c = true;
            MIBNF_Comp_Revised.Orignal_BNF__c = MIBNF_Comp.id;
            MIBNF_Comp_Revised.Revised_BNF_Date__c = System.today();
            MIBNF_Comp_Revised.Invoice_Header_Text__c = invoiceHeader != null? invoiceHeader : MIBNF_Comp.Invoice_Header_Text__c;
            MIBNF_Comp_RevisedList.add(MIBNF_Comp_Revised);
        }
        
        
        try{
            system.debug(MIBNF_Comp_RevisedList);
            if(MIBNF_Comp_RevisedList.size() > 0){
                uow.registerNew(MIBNF_Comp_RevisedList);
                insertMibnfLineItem(mibnfDetailMap, MIBNF_Comp_RevisedList, uow);
                if(submitForApproval){
                    submitForApprovalMethod(MIBNF_Comp_RevisedList);
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            throw new massUpdateFailException(ex.getMessage());
        }
    }
    
    public static Decimal insertMibnfLineItem(Map<Id,List<MI_BNF_LineItem__c>> mibnfDetailMap, List<MIBNF_Component__c> MIBNF_Comp_RevisedList, fflib_SObjectUnitOfWork uow){
        List<MI_BNF_LineItem__c> revisedCompList = new List<MI_BNF_LineItem__c>();
        for(MIBNF_Component__c MIBNF_Comp_Revised : MIBNF_Comp_RevisedList){
           for(MI_BNF_LineItem__c lineItem: mibnfDetailMap.get(MIBNF_Comp_Revised.Orignal_BNF__c)) {
                //oliListToRevisePrice.add(lineItem.Opportunity_Line_Itemid__c);
                MI_BNF_LineItem__c MIBNF_LineItem_Revised=new MI_BNF_LineItem__c(); 
                MIBNF_LineItem_Revised.Opportunity_Line_Itemid__c=lineItem.Opportunity_Line_Itemid__c;
                MIBNF_LineItem_Revised.MIBNF_Component__c=MIBNF_Comp_Revised.Id;
                MIBNF_LineItem_Revised.Total_Price__c=lineItem.Total_Price__c;
                MIBNF_LineItem_Revised.CurrencyIsoCode=lineItem.CurrencyIsoCode;
               	uow.registerNew(MIBNF_LineItem_Revised, MI_BNF_LineItem__c.MIBNF_Component__c, MIBNF_Comp_Revised);
                revisedCompList.add(MIBNF_LineItem_Revised);
            } 
        }
        system.debug(revisedCompList);
        return revisedCompList.size();
    }   
    
    public static void submitForApprovalMethod(List<MIBNF_Component__c> bnfstoSubmitForApproval){
        system.debug(bnfstoSubmitForApproval);
        List<Approval.ProcessSubmitRequest> reqList = new List<Approval.ProcessSubmitRequest>();
        for(MIBNF_Component__c mibnfComp: bnfstoSubmitForApproval){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(mibnfComp.id);
            reqList.add(req);
        }
        try{
            List<Approval.ProcessResult> resultList =  Approval.process(reqList);
            system.debug(resultList);
        }catch(Exception ex){
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            throw new massUpdateFailException(ex.getMessage());
        }
    }*/ 
    
    @AuraEnabled
    public static Boolean checkNonEMEAOpportunity(Id OpportunityId){
        Boolean isNonEmeaOpp = false;
        Map<Id, String> oppToQuoteMap = CPQ_QuoteUtilityWO.validateQuoteSyncWithOpportunities(new Set<Id>{OpportunityId});
        if(oppToQuoteMap.get(OpportunityId) == 'Error:NonEMEAEligibleOpportunity'){
            isNonEmeaOpp = true;
        }
        return isNonEmeaOpp;
    }
    public class massUpdateFailException extends Exception {}
}