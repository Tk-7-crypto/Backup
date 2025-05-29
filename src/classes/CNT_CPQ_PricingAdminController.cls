public class CNT_CPQ_PricingAdminController {
    @AuraEnabled(cacheable=true)
    public static WPR_CPQ_PricingWrapper getPricingDetails(String pricingTool) {
        String priceList = '';
        for (CPQ_Proposal_Create_Settings__c cpcs : CPQ_Proposal_Create_Settings__c.getall().values()) {
            if (cpcs.Available_Pricing_Tools__c == pricingTool) {
                priceList = cpcs.Master_Price_List__c;
            }
        }
        WPR_CPQ_PricingWrapper pricingObj = new WPR_CPQ_PricingWrapper();
        Map<String, List<CPQ_AMESA_Partial_Product_Pricings__c>> partialPricingWithYearandCountryMap = new Map<String, List<CPQ_AMESA_Partial_Product_Pricings__c>>();
        Set<Integer> partialPricingYears = new Set<Integer>();
        List<String> groupAttributeList = new List<String>();
        Map<String, String> groupAttributeLabelMap = new Map<String, String>();
        List<String> attributeAPINameList = new List<String>();
        List<String> attributeLabelList = new List<String>();
        String objectName = 'Apttus_Config2__ProductAttributeValue__c';
        String fieldName; 
        String existingFullYear;
        String country;
        String percent;
        Boolean reviewAllCheck;
        Boolean isPartialPricingRequired;
        String baseCurrency;
        List<String> attributePercentList = new List<String>();
        Map<String, String> countryPercentMap = new Map<String, String>();
        for (CPQ_Pricing_Admin_Settings__c customSetting : CPQ_Pricing_Admin_Settings__c.getall().values()) {
            if (customSetting.Pricing_Tool__c == pricingTool) {
                fieldName = customSetting.Group_Attribute__c;
                attributeLabelList = customSetting.Attribute_Label_List__c.split(';');
                attributeAPINameList.addAll(customSetting.Attribute_List__c.split(';'));
                if (customSetting.Attribute_List2__c != null) {
                    attributeAPINameList.addAll(customSetting.Attribute_List2__c.split(';'));
                }
                existingFullYear = customSetting.Cloned_From_Existing_Year__c;
                if (customSetting.Attribute_Percent_Map__c != null) {
                   attributePercentList = customSetting.Attribute_Percent_Map__c.split(';');  
                }
                reviewAllCheck = customSetting.Review_All__c;
                isPartialPricingRequired = customSetting.Partial_Pricing_Required__c;
                baseCurrency = customSetting.Base_Currency__c;
            }
        }
        Map<String, boolean> groupReviewMap = new Map<String, boolean>();
        if (attributePercentList != null) {
            for (String key : attributePercentList) {
                List<String> countryPercentList = key.split(':');
                country = countryPercentList[0];
                percent = countryPercentList[1];
                groupReviewMap.put(country, true);
                countryPercentMap.put(country, percent);
            }  
        }
        
        if (isPartialPricingRequired) {
            List<CPQ_AMESA_Partial_Product_Pricings__c> partialPricingList = [SELECT Id, Final_Price_with_LMPT__c, Standard_Type__c, CurrencyIsoCode, CPQ_Product_Code__c, CPQ_ProductName__c, Data_Delivery_Frequency__c, Final_Price__c, Final_Price_with_molecule__c, Market_Type__c, Key__c, Product_Name__c, Type__c, Year__c, Country__c, isActive__c FROM CPQ_AMESA_Partial_Product_Pricings__c WHERE Final_Price__c != null Order By Key__c];
            for (CPQ_AMESA_Partial_Product_Pricings__c partialPricing : partialPricingList) {
                String key = partialPricing.Year__c+':'+partialPricing.Country__c;
                partialPricingYears.add(Integer.ValueOf(partialPricing.Year__c));
                
                if (partialPricingWithYearandCountryMap.containsKey(key)) {
                    List<CPQ_AMESA_Partial_Product_Pricings__c> partialList = partialPricingWithYearandCountryMap.get(key);
                    partialList.add(partialPricing);
                    partialPricingWithYearandCountryMap.put(key, partialList);
                } else {
                    partialPricingWithYearandCountryMap.put(key, new List<CPQ_AMESA_Partial_Product_Pricings__c> {partialPricing});
                }
            }
        }
        Map<String, String> attributeMap = new Map<String, String>();
        for(Integer i=0; i<attributeAPINameList.size(); i++){
            attributeMap.put(attributeLabelList[i], attributeAPINameList[i]);
        }
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> pickListEntryList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : pickListEntryList) {
            groupAttributeList.add(pickListVal.getValue());
            groupAttributeLabelMap.put(pickListVal.getValue(), pickListVal.getLabel());
        }
        
        Set<String> pliFieldSet = new Set<String>();
        Set<String> pmFieldSet = new Set<String>();
        Set<String> pmeFieldSet = new Set<String>();
        for (Schema.FieldSetMember field : 
             Schema.SObjectType.Apttus_Config2__PriceListItem__c.fieldSets.getMap().get('Pricing_Admin_Field_Set').getFields()) {
             pliFieldSet.add(field.getFieldPath());
        }
        for (string pliField: pliFieldSet) {
            pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.' + pliField);
        }
        
        for (Schema.FieldSetMember field : 
             Schema.SObjectType.Apttus_Config2__PriceMatrix__c.fieldSets.getMap().get('Pricing_Admin_Field_Set').getFields()) {
             pmFieldSet.add(field.getFieldPath());
        }
        for (string pmField: pmFieldSet) {
            pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.' + pmField);
            if (pmField == 'Apttus_Config2__Dimension1Id__c') {
                pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__r.Apttus_Config2__Datasource__c');
            }
            else if (pmField == 'Apttus_Config2__Dimension2Id__c') {
                pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__r.Apttus_Config2__Datasource__c');
            }
            else if (pmField == 'Apttus_Config2__Dimension3Id__c') {
                pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__r.Apttus_Config2__Datasource__c');
            }
            else if (pmField == 'Apttus_Config2__Dimension4Id__c') {
                pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__r.Apttus_Config2__Datasource__c');
            }
            else if (pmField == 'Apttus_Config2__Dimension5Id__c') {
                pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__r.Apttus_Config2__Datasource__c');
            }
            else if (pmField == 'Apttus_Config2__Dimension6Id__c') {
                pmeFieldSet.add('Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6Id__r.Apttus_Config2__Datasource__c');
            }			
        }
        
        for (Schema.FieldSetMember field : 
             Schema.SObjectType.Apttus_Config2__PriceMatrixEntry__c.fieldSets.getMap().get('Pricing_Admin_Field_Set').getFields()) {
             pmeFieldSet.add(field.getFieldPath());
        }

        String condition = 'Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Name LIKE :priceList AND Apttus_Config2__AdjustmentAmount__c != null';
        List<Apttus_Config2__PriceMatrixEntry__c> pmeList = new SLT_PriceMatrixEntry().getPriceMatrixEntriesByPriceList(pmeFieldSet, condition, priceList);

        Set<String> nonActivePricingYears = new Set<String>();
        Map<String, List<Apttus_Config2__PriceMatrixEntry__c>> yearCountryPMEMap = new Map<String, List<Apttus_Config2__PriceMatrixEntry__c>>();
        Set<Integer> pricingYears = new Set<Integer>();
        for (Apttus_Config2__PriceMatrixEntry__c pme : pmeList) {
            if (pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Active__c) {
                String groupAttribute;
                if (groupAttributeList.contains(pme.Apttus_Config2__Dimension1Value__c)) {
                    groupAttribute = pme.Apttus_Config2__Dimension1Value__c;
                }
                else if (groupAttributeList.contains(pme.Apttus_Config2__Dimension2Value__c)) {
                    groupAttribute = pme.Apttus_Config2__Dimension2Value__c;
                }
                else if (groupAttributeList.contains(pme.Apttus_Config2__Dimension3Value__c)) {
                    groupAttribute = pme.Apttus_Config2__Dimension3Value__c;
                }
                else if (groupAttributeList.contains(pme.Apttus_Config2__Dimension4Value__c)) {
                    groupAttribute = pme.Apttus_Config2__Dimension4Value__c;
                }
                else if (groupAttributeList.contains(pme.Apttus_Config2__Dimension5Value__c)) {
                    groupAttribute = pme.Apttus_Config2__Dimension5Value__c;
                }
                
                String pricingYear = pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c.substringBetween('"(Start Date Year = ', ')"');
                if (pricingYear != null) {
                    pricingYears.add(Integer.ValueOf(pricingYear));
                }
                String yearCountryKey = pricingYear + ':' + groupAttribute;
                
                if (yearCountryPMEMap.containsKey(yearCountryKey)) {
                    List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixEntryList = yearCountryPMEMap.get(yearCountryKey);
                    priceMatrixEntryList.add(pme);
                    yearCountryPMEMap.put(yearCountryKey, priceMatrixEntryList);
                } else {
                    yearCountryPMEMap.put(yearCountryKey, new List<Apttus_Config2__PriceMatrixEntry__c> {pme});
                }
            } else {
                String pricingYear = pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c.substringBetween('"(Start Date Year = ',')"');
                if (pricingYear != null) {
                    nonActivePricingYears.add(pricingYear);
                }
                if (!pme.Partial_Save__c) {
                    Set<String> dimensionSet = new Set<String>{pme.Apttus_Config2__Dimension1Value__c, pme.Apttus_Config2__Dimension2Value__c, pme.Apttus_Config2__Dimension3Value__c, pme.Apttus_Config2__Dimension4Value__c, pme.Apttus_Config2__Dimension5Value__c};
                    for (String trace : dimensionSet) {
                        if (groupReviewMap.containsKey(trace)) {
                            groupReviewMap.put(trace, false);
                        }
                    }
                }
            }
        }

        List<Integer> sortedPricingYears = new List<Integer>(pricingYears);
        sortedPricingYears.sort();
        pricingYears.clear();
        pricingYears.addAll(sortedPricingYears);
        
        Map<String, String> countryToLocalCurrencyMap = new Map<String, String>();
        
        for (CPQ_Local_Currency_Mapping__mdt clcm : [SELECT Country__c, Local_Currency_Code__c FROM CPQ_Local_Currency_Mapping__mdt WHERE Pricing_Tool__c =: pricingTool]) {
            countryToLocalCurrencyMap.put(clcm.Country__c, clcm.Local_Currency_Code__c);
        }
        pricingObj.countryToLocalCurrencyMap = countryToLocalCurrencyMap;
        pricingObj.reviewedStatusMap = groupReviewMap;
        pricingObj.groupAttributeFieldName = fieldName;
        pricingObj.attributeList = attributeAPINameList;
        pricingObj.attributeMap = attributeMap;
        pricingObj.existingPricingYears = pricingYears;
        pricingObj.existingPartialPricingYears = partialPricingYears;
        pricingObj.yearWithCountryPMEMap = yearCountryPMEMap;
        pricingObj.attributeLabelMap = groupAttributeLabelMap;
        pricingObj.yearWithCountryPartialPricingMap = partialPricingWithYearandCountryMap;
        pricingObj.nonActivePricingYears = nonActivePricingYears;
        pricingObj.existingFullYears = existingFullYear;
        pricingObj.countryToPercentMap = countryPercentMap;
        pricingObj.isReviewAll = reviewAllCheck;
        pricingObj.isPartialPricingRequired = isPartialPricingRequired;
        pricingObj.baseCurrency = baseCurrency;
        return pricingObj;
    }
    
    @AuraEnabled
    public static String processBatchItems(String PMEList, String PMList, String PLIList, String newYear, String pricingTool, Integer currentState, Integer totalChunks) {

        Map<String, List<SObject>> objectListMap = new Map<String, List<SObject>>();
        objectListMap.put('PriceMatrixEntry', ((Map<Id, Apttus_Config2__PriceMatrixEntry__c>) json.deserialize(PMEList, Map<Id, Apttus_Config2__PriceMatrixEntry__c>.class)).values());
            
        if (currentState == 1) {
            objectListMap.put('PriceListItem', ((Map<Id, Apttus_Config2__PriceListItem__c>) json.deserialize(PLIList, Map<Id, Apttus_Config2__PriceListItem__c>.class)).values());
            objectListMap.put('PriceMatrix', ((Map<Id, Apttus_Config2__PriceMatrix__c>) json.deserialize(PMList, Map<Id, Apttus_Config2__PriceMatrix__c>.class)).values());
 
            BCH_CPQ_CreatePriceListItem pliBatch = new BCH_CPQ_CreatePriceListItem(objectListMap, newYear, pricingTool, totalChunks, currentState);
            Id batchJobId = Database.executeBatch(pliBatch);
            updateBatchJobIdInCPQAdminSettings(batchJobId, pricingTool);
        } else {
            BCH_CPQ_CreatePriceMatrixEntry pmeBatch = new BCH_CPQ_CreatePriceMatrixEntry(objectListMap.get('PriceMatrixEntry'), newYear, pricingTool, totalChunks, currentState);
            Id batchJobId = Database.executeBatch(pmeBatch);
            updateBatchJobIdInCPQAdminSettings(batchJobId, pricingTool);
        }
        return 'success';
    }
    @AuraEnabled
    public static WPR_CPQ_ParentRecordWrapper savePriceMatrixEntries(List<Apttus_Config2__PriceMatrixEntry__c> insertPMEList, List<Apttus_Config2__PriceMatrixEntry__c> updatePMEList, String newYear, String existingYear, String  priceMatrixJSON, String attributeToPercentageMap, String pricingTool, String IdToPLI, String IdToPM) {
        try {
            WPR_CPQ_ParentRecordWrapper parentRecord = new WPR_CPQ_ParentRecordWrapper();

            String priceList = '';
            for (CPQ_Proposal_Create_Settings__c cPCS : CPQ_Proposal_Create_Settings__c.getall().values()) {
                if (cPCS.Available_Pricing_Tools__c == pricingTool) {
                    priceList = cPCS.Master_Price_List__c;
                }
            }
            if (newYear == null) {
                parentRecord.Status = 'Update';
                for (Apttus_Config2__PriceMatrixEntry__c updatePME : updatePMEList) {
                    updatePME.Review_by_User__c = UserInfo.getUserId();
                }
                update updatePMEList; 
                return parentRecord;
            }
            else {
                String lastPLIMigId;
                String lastPMMigId;
                String lastPMEMigId;
                Map<Id, Apttus_Config2__PriceMatrix__c> priceMatrixMap = (Map<Id, Apttus_Config2__PriceMatrix__c>) json.deserialize(priceMatrixJSON, Map<Id, Apttus_Config2__PriceMatrix__c>.class);
                Map<String, String> attributePercentMap = (Map<String, String>) json.deserialize(attributeToPercentageMap, Map<String, String>.class);

                CPQ_Pricing_Admin_Settings__c pASetting = new CPQ_Pricing_Admin_Settings__c();
                for (CPQ_Pricing_Admin_Settings__c customSetting : CPQ_Pricing_Admin_Settings__c.getall().values()) {
                    if (customSetting.Pricing_Tool__c == pricingTool) {
                        List<String> migIdList = customSetting.Last_Stored_Migration_Id__c.split(';');
                        lastPLIMigId = migIdList[0];
                        lastPMMigId = migIdList[1];
                        lastPMEMigId = migIdList[2];
                        pASetting = customSetting;
                    }
                }
                List<Apttus_Config2__PriceListItem__c> newPLIList = new List<Apttus_Config2__PriceListItem__c>();
                List<Apttus_Config2__PriceMatrix__c> newPMList = new List<Apttus_Config2__PriceMatrix__c>();
                List<Apttus_Config2__PriceMatrixEntry__c> newPMEList = new List<Apttus_Config2__PriceMatrixEntry__c>();

                Map<String, Apttus_Config2__PriceListItem__c> midToPLIMap = (IdToPLI == null ? new Map<String, Apttus_Config2__PriceListItem__c>() : (Map<String, Apttus_Config2__PriceListItem__c>) json.deserialize(IdToPLI, Map<String, Apttus_Config2__PriceListItem__c>.class));
                Map<String, Apttus_Config2__PriceMatrix__c> midToPMMap = (IdToPM == null ? new Map<String, Apttus_Config2__PriceMatrix__c>() : (Map<String, Apttus_Config2__PriceMatrix__c>) json.deserialize(IdToPM, Map<String, Apttus_Config2__PriceMatrix__c>.class));
                
                List<Apttus_Config2__PriceListItem__c> bundleProductPLI = [SELECT Id, Apttus_Config2__ProductId__r.NAME, Apttus_Config2__Criteria__c, Apttus_Config2__PriceListId__c, Apttus_Config2__ProductId__c, Apttus_Config2__ChargeType__c, Apttus_Config2__Frequency__c, Apttus_Config2__PriceMethod__c, Apttus_Config2__PriceType__c, Apttus_Config2__ListPrice__c, Apttus_Config2__Active__c, Migration_Id__c FROM Apttus_Config2__PriceListItem__c WHERE Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c =: CON_CPQ.BUNDLE AND Apttus_Config2__PriceListId__r.NAME =: priceList];
                for (Apttus_Config2__PriceListItem__c bundlePLI : bundleProductPLI){
                    if (bundlePLI.Apttus_Config2__Criteria__c.contains(existingYear)) {
                        Apttus_Config2__PriceListItem__c newPLI1 = new Apttus_Config2__PriceListItem__c();
                        
                        newPLI1.Apttus_Config2__Criteria__c = bundlePLI.Apttus_Config2__Criteria__c.replace(existingYear, newYear);
                        newPLI1.Apttus_Config2__PriceListId__c = bundlePLI.Apttus_Config2__PriceListId__c;
                        newPLI1.Apttus_Config2__ProductId__c = bundlePLI.Apttus_Config2__ProductId__c;
                        newPLI1.Apttus_Config2__ChargeType__c = bundlePLI.Apttus_Config2__ChargeType__c;
                        newPLI1.Apttus_Config2__Frequency__c = bundlePLI.Apttus_Config2__Frequency__c;
                        newPLI1.Apttus_Config2__PriceMethod__c = bundlePLI.Apttus_Config2__PriceMethod__c;
                        newPLI1.Apttus_Config2__PriceType__c = bundlePLI.Apttus_Config2__PriceType__c;
                        newPLI1.Apttus_Config2__ListPrice__c = bundlePLI.Apttus_Config2__ListPrice__c;
                        newPLI1.Apttus_Config2__Active__c = false;
                        newPLI1.Id = bundlePLI.Id;
                        
                        List<String> pliMigIdSplits = lastPLIMigId.split('-');
                        String newPLIMigId = generateMigrationId(pliMigIdSplits[0], Integer.ValueOf(pliMigIdSplits[1]));
                        newPLI1.Migration_Id__c = newPLIMigId;
                        lastPLIMigId = newPLIMigId;
                        newPLIList.add(newPLI1);
                    }
                }
                Set<String> pliFieldSet = new Set<String>();
                Set<String> pmFieldSet = new Set<String>();
                Set<String> pmeFieldSet = new Set<String>();
                for (Schema.FieldSetMember field : 
                     Schema.SObjectType.Apttus_Config2__PriceListItem__c.fieldSets.getMap().get('Pricing_Admin_Field_Set').getFields()) {
                     pliFieldSet.add(field.getFieldPath());
                }
                for (Schema.FieldSetMember field : 
                     Schema.SObjectType.Apttus_Config2__PriceMatrix__c.fieldSets.getMap().get('Pricing_Admin_Field_Set').getFields()) {
                     pmFieldSet.add(field.getFieldPath());
                }
                for (Schema.FieldSetMember field : 
                     Schema.SObjectType.Apttus_Config2__PriceMatrixEntry__c.fieldSets.getMap().get('Pricing_Admin_Field_Set').getFields()) {
                     pmeFieldSet.add(field.getFieldPath());
                }

                for (Apttus_Config2__PriceMatrixEntry__c pme : insertPMEList) {
                    Apttus_Config2__PriceMatrix__c existingPM = priceMatrixMap.get(pme.Apttus_Config2__PriceMatrixId__c);
                    if (!midToPLIMap.containsKey(existingPM.Apttus_Config2__PriceListItemId__r.Id)) {

                        Apttus_Config2__PriceListItem__c newPLI = new Apttus_Config2__PriceListItem__c();
                        for (String pliField : pliFieldSet) {
                            if (pliField != 'Apttus_Config2__ProductName__c') {
                                newPLI.put(pliField, existingPM.Apttus_Config2__PriceListItemId__r.get(pliField));
                            }
                        }
                        newPLI.Apttus_Config2__Criteria__c = existingPM.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c.replace(existingYear, newYear);
                        newPLI.Apttus_Config2__Active__c = false;
                        newPLI.Id = existingPM.Apttus_Config2__PriceListItemId__r.Id;

                        List<String> pliMigIdSplits = lastPLIMigId.split('-');
                        String newPLIMigId = generateMigrationId(pliMigIdSplits[0], Integer.ValueOf(pliMigIdSplits[1]));
                        newPLI.Migration_Id__c = newPLIMigId;
                        lastPLIMigId = newPLIMigId;
                        newPLIList.add(newPLI);
                        midToPLIMap.put(existingPM.Apttus_Config2__PriceListItemId__c, newPLI);

                        Apttus_Config2__PriceMatrix__c newPM = new Apttus_Config2__PriceMatrix__c();
                        newPM.Id = existingPM.Id;
                        for (String pmField : pmFieldSet) {
                            newPM.put(pmField, existingPM.get(pmField));
                        }
                        newPM.Apttus_Config2__PriceListItemId__r = new Apttus_Config2__PriceListItem__c(Migration_Id__c = newPLIMigId);

                        List<String> pmMigIdSplits = lastPMMigId.split('-');
                        String newPMMigId = generateMigrationId(pmMigIdSplits[0], Integer.ValueOf(pmMigIdSplits[1]));
                        newPM.Migration_Id__c = newPMMigId;
                        lastPMMigId = newPMMigId;
                        newPMList.add(newPM);
                        midToPMMap.put(pme.Apttus_Config2__PriceMatrixId__c, newPM);
					
                        Apttus_Config2__PriceMatrixEntry__c newPME = new Apttus_Config2__PriceMatrixEntry__c();
                        newPME.Id = pme.Id;
                        for (String pmeField : pmeFieldSet) {
                            if (pmeField != 'Apttus_Config2__PriceMatrixId__c') {
                                newPME.put(pmeField, pme.get(pmeField));
                            }
                        }
                        newPME.Apttus_Config2__PriceMatrixId__r = new Apttus_Config2__PriceMatrix__c(Migration_Id__c = newPMMigId);
                        newPME.Previous_Amount__c = pme.Apttus_Config2__PriceOverride__c;
                        newPME.Partial_Save__c = false;

                        List<String> pmeMigIdSplits = lastPMEMigId.split('-');
                        String newPMEMigId = generateMigrationId(pmeMigIdSplits[0], Integer.ValueOf(pmeMigIdSplits[1]));
                        newPME.Migration_Id__c = newPMEMigId;
                        lastPMEMigId = newPMEMigId;
                        newPMEList.add(newPME);
                    }
                    else {
                        Apttus_Config2__PriceListItem__c newPLI = midToPLIMap.get(existingPM.Apttus_Config2__PriceListItemId__c);
                        if (!midToPMMap.containsKey(pme.Apttus_Config2__PriceMatrixId__c)) {
                            Apttus_Config2__PriceMatrix__c newPM = new Apttus_Config2__PriceMatrix__c();
                            newPM.Id = existingPM.Id;
                            for (String pmField : pmFieldSet) {
                                newPM.put(pmField, existingPM.get(pmField));
                            }
                            newPM.Apttus_Config2__PriceListItemId__r = new Apttus_Config2__PriceListItem__c(Migration_Id__c = newPLI.Migration_Id__c);

                            List<String> pmMigIdSplits = lastPMMigId.split('-');
                            String newPMMigId = generateMigrationId(pmMigIdSplits[0], Integer.ValueOf(pmMigIdSplits[1]));
                            newPM.Migration_Id__c = newPMMigId;
                            lastPMMigId = newPMMigId;
                            newPMList.add(newPM);
                            midToPMMap.put(pme.Apttus_Config2__PriceMatrixId__c, newPM);

                            Apttus_Config2__PriceMatrixEntry__c newPME = new Apttus_Config2__PriceMatrixEntry__c();
                            newPME.Apttus_Config2__PriceMatrixId__r = new Apttus_Config2__PriceMatrix__c(Migration_Id__c = newPMMigId);
                            for (String pmeField : pmeFieldSet) {
                                if (pmeField != 'Apttus_Config2__PriceMatrixId__c') {
                                    newPME.put(pmeField, pme.get(pmeField));
                                }
                            }
                            newPME.Previous_Amount__c = pme.Apttus_Config2__PriceOverride__c;
                            newPME.Partial_Save__c = false;
                            newPME.Id = pme.Id;
                            List<String> pmeMigIdSplits = lastPMEMigId.split('-');
                            String newPMEMigId = generateMigrationId(pmeMigIdSplits[0], Integer.ValueOf(pmeMigIdSplits[1]));
                            newPME.Migration_Id__c = newPMEMigId;
                            lastPMEMigId = newPMEMigId;
                            newPMEList.add(newPME);
                        }
                        else {
                            Apttus_Config2__PriceMatrix__c newPM = midToPMMap.get(pme.Apttus_Config2__PriceMatrixId__c);

                            Apttus_Config2__PriceMatrixEntry__c newPME = new Apttus_Config2__PriceMatrixEntry__c();
                            newPME.Apttus_Config2__PriceMatrixId__r = new Apttus_Config2__PriceMatrix__c(Migration_Id__c = newPM.Migration_Id__c);
                            for (String pmeField : pmeFieldSet) {
                                if (pmeField != 'Apttus_Config2__PriceMatrixId__c') {
                                    newPME.put(pmeField, pme.get(pmeField));
                                }
                            }
                            newPME.Previous_Amount__c = pme.Apttus_Config2__PriceOverride__c;
                            newPME.Partial_Save__c = false;
                            newPME.Id = pme.Id;
                            List<String> pmeMigIdSplits = lastPMEMigId.split('-');
                            String newPMEMigId = generateMigrationId(pmeMigIdSplits[0], Integer.ValueOf(pmeMigIdSplits[1]));
                            newPME.Migration_Id__c = newPMEMigId;
                            lastPMEMigId = newPMEMigId;
                            newPMEList.add(newPME);
                        }
                    }
                }
                pASetting.Last_Stored_Migration_Id__c = lastPLIMigId+';'+lastPMMigId+';'+lastPMEMigId;
                pASetting.Cloned_From_Existing_Year__c = existingYear;
                String countryPercentKey;
                for (String country: attributePercentMap.keyset()) {
                    if (countryPercentKey == null) {
                        countryPercentKey = country + ':' + attributePercentMap.get(country);
                    } else {
                        countryPercentKey = countryPercentKey + ';' + country + ':' + attributePercentMap.get(country);
                    }
                }
                pASetting.Attribute_Percent_Map__c = countryPercentKey;
                update pASetting;
                
                parentRecord.IdToPLIMap = midToPLIMap;
                parentRecord.IdToPMMap = midToPMMap;
                parentRecord.PLIList = newPLIList;
                parentRecord.PMList = newPMList;
                parentRecord.PMEList = newPMEList;
                parentRecord.Status = 'Insert';    
                return parentRecord;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }
    
    public static String generateMigrationId(String prefix, Integer lastNumber) {
        Integer temp = lastNumber;
        Integer count = 0;
        while (temp != 0) {
            temp = temp / 10;
            count = count + 1;
        }
        String zeros = '';
        if (count > 0) {
            for (Integer i = 0; i < (7-count); i++){
                zeros = zeros + '0';
            }
        } 
        else {
            zeros = '000000';
        }
        
        lastNumber = lastNumber + 1;
        String newMigId = prefix + '-' + zeros + String.ValueOf(String.ValueOf(lastNumber));
        return newMigId;
    }

    @AuraEnabled
    public static String savePartialPricing(List<CPQ_AMESA_Partial_Product_Pricings__c > insertPartialList, List<CPQ_AMESA_Partial_Product_Pricings__c > updatePartialList, String newYear, String existingYear, String pricingTool) {
        try {
            String lastMigId;
            if (newYear == null) {
                update updatePartialList;
                return 'Update';
            }
            else {
                CPQ_Pricing_Admin_Settings__c cpas = new CPQ_Pricing_Admin_Settings__c();
                for (CPQ_Pricing_Admin_Settings__c customSetting : CPQ_Pricing_Admin_Settings__c.getall().values()) {
                    if (customSetting.Pricing_Tool__c == pricingTool) {
                        cpas = customSetting;
                        lastMigId = customSetting.Partial_Last_Stored_Migration_Id__c;
                    }
                }

                List<CPQ_AMESA_Partial_Product_Pricings__c> newPartialPricingList = new List<CPQ_AMESA_Partial_Product_Pricings__c>();
                for(CPQ_AMESA_Partial_Product_Pricings__c partialPricing : insertPartialList){
                    List<String> MigIdSplits = lastMigId.split('-');
                    String newPartialMigId = generateMigrationId(MigIdSplits[0], Integer.ValueOf(MigIdSplits[1]));
                    lastMigId = newPartialMigId;
                    CPQ_AMESA_Partial_Product_Pricings__c newPartialPricing = new CPQ_AMESA_Partial_Product_Pricings__c();
                    newPartialPricing.CPQ_Product_Code__c = partialPricing.CPQ_Product_Code__c;
                    newPartialPricing.CPQ_ProductName__c = partialPricing.CPQ_ProductName__c;
                    newPartialPricing.Data_Delivery_Frequency__c = partialPricing.Data_Delivery_Frequency__c;
                    newPartialPricing.Final_Price__c = partialPricing.Final_Price__c;
                    newPartialPricing.Final_Price_with_molecule__c = partialPricing.Final_Price_with_molecule__c;
                    newPartialPricing.Market_Type__c = partialPricing.Market_Type__c;
                    newPartialPricing.Key__c = partialPricing.Key__c.replace(existingYear, newYear);
                    newPartialPricing.Product_Name__c = partialPricing.Product_Name__c;
                    newPartialPricing.Type__c = partialPricing.Type__c;
                    newPartialPricing.Country__c = partialPricing.Country__c;
                    newPartialPricing.Year__c = newYear;
                    newPartialPricing.isActive__c = partialPricing.isActive__c;
                    newPartialPricing.CurrencyIsoCode = partialPricing.CurrencyIsoCode;
                    newPartialPricing.Final_Price_with_LMPT__c = partialPricing.Final_Price_with_LMPT__c;
                    newPartialPricing.Standard_Type__c = partialPricing.Standard_Type__c;
                    newPartialPricing.Migration_Id__c = newPartialMigId;
                    newPartialPricingList.add(newPartialPricing);
                }
                insert newPartialPricingList;
                cpas.Partial_Last_Stored_Migration_Id__c = lastMigId;
                update cpas;
                return 'Insert';
            }
        }
        catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateBatchJobIdInCPQAdminSettings(String batchJobId, String pricingTool){
        CPQ_Pricing_Admin_Settings__c adminSettingsToUpdate;
        for (CPQ_Pricing_Admin_Settings__c customSetting : CPQ_Pricing_Admin_Settings__c.getall().values()) {
            if (customSetting.Pricing_Tool__c == pricingTool) {
                customSetting.Batch_Job_Id__c = batchJobId;
                adminSettingsToUpdate = customSetting;
                break;
            }
        }
        if (adminSettingsToUpdate != null) {
            update adminSettingsToUpdate;
        }
    }
    
    @AuraEnabled
    public static Map<String, Object> getBatchJobResult(String pricingTool){
        Map<String, Object> resultMap = new Map<String, Object>();
        Id batchJobId;
        for (CPQ_Pricing_Admin_Settings__c customSetting : CPQ_Pricing_Admin_Settings__c.getall().values()) {
            if (customSetting.Pricing_Tool__c == pricingTool) {
                List<String> temp = new List<String>();
                if (customSetting.Batch_Job_Id__c != null) {
                    temp = customSetting.Batch_Job_Id__c.split(':');
                }
                if (!String.isBlank(customSetting.Batch_Job_Id__c)) {
                    if (customSetting.Batch_Job_Id__c != 'Completed' && temp[0] != 'Processed ') {
                        batchJobId = customSetting.Batch_Job_Id__c;
                        resultMap.put('batchJobId', batchJobId);
                    } else if (temp[0] != 'Processed ') {
                        resultMap.put('status', 'Completed');
                    } else {
                       resultMap.put('status', customSetting.Batch_Job_Id__c);
                    }
                }
                break;
            }
        }  
        if (batchJobId != null) {
            List<AsyncApexJob> apexJob = [SELECT Id, ApexClass.Name, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id =: batchJobId ORDER BY CreatedDate DESC LIMIT 1 ];
            
            if (apexJob.size() == 1) {
                resultMap.put('ApexClassName', apexJob[0].ApexClass.Name);
                resultMap.put('NumberOfErrors', apexJob[0].NumberOfErrors);
                resultMap.put('JobItemsProcessed', apexJob[0].JobItemsProcessed);
                resultMap.put('TotalJobItems', apexJob[0].TotalJobItems);
                if (apexJob[0].Status == 'Failed' || apexJob[0].Status == 'Aborted' || apexJob[0].NumberOfErrors > 0) {
                    resultMap.put('status', apexJob[0].Status);
                    updateBatchJobIdInCPQAdminSettings('', pricingTool);
                }
            }
        }
        return resultMap;
    }
    @AuraEnabled
    public static Map<String, String> getAvailablePricingTool() {
        List<PermissionSetAssignment> psaList = [SELECT Id, PermissionSet.name FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()];
        List<String> availablePermissionSet = new List<String>();
        for(PermissionSetAssignment psa : psaList){
            availablePermissionSet.add(psa.PermissionSet.name);
        }
        List<CPQ_Pricing_Admin_Settings__c> pasList = [SELECT Id, Permission_Set_Name__c, Pricing_Tool__c, Object_Name__c FROM CPQ_Pricing_Admin_Settings__c  WHERE Permission_Set_Name__c IN :availablePermissionSet];
        Map<String, String> toolToObjectNameMap = new Map<String, String>();
        
        for(CPQ_Pricing_Admin_Settings__c pas : pasList){
            if (!toolToObjectNameMap.containsKey(pas.Pricing_Tool__c)) {
                toolToObjectNameMap.put(pas.Pricing_Tool__c, pas.Object_Name__c);
            }
        }
        if(toolToObjectNameMap.size() > 0){
            return toolToObjectNameMap;
        }
        return null;
    }
    @AuraEnabled
    public static List<Apttus_Config2__PriceMatrixEntry__c> getInactivePriceMatrixEntries(String selectedPricingYear, String selectedCountry, String pricingTool) {
        String priceList = ''; 
        for (CPQ_Proposal_Create_Settings__c cpcs : CPQ_Proposal_Create_Settings__c.getall().values()) {
            if (cpcs.Available_Pricing_Tools__c == pricingTool) {
                priceList = cpcs.Master_Price_List__c;
            }
        }
        
        List<Apttus_Config2__PriceMatrixEntry__c> priceMatrixEntryList = new List<Apttus_Config2__PriceMatrixEntry__c>();
        
        for (Apttus_Config2__PriceMatrixEntry__c pme : [ SELECT ID, Migration_Id__c, Apttus_Config2__Dimension1Value__c, 
                                                         Apttus_Config2__Dimension2Value__c, 
                                                         Apttus_Config2__Dimension3Value__c, 
                                                         Apttus_Config2__Dimension4Value__c, 
                                                         Apttus_Config2__Dimension5Value__c,
                                                         Apttus_Config2__Dimension6Value__c, 
                                                         Apttus_Config2__AdjustmentAmount__c,
                                                         Apttus_Config2__AdjustmentType__c, 
                                                         Apttus_Config2__PriceMatrixId__c, 
                                                         Apttus_Config2__PriceOverride__c, 
                                                         Apttus_Config2__Sequence__c, Partial_Save__c, Previous_Amount__c,
                                                         Apttus_Config2__PriceMatrixId__r.Migration_Id__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Sequence__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__r.Apttus_Config2__Datasource__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__r.Apttus_Config2__Datasource__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__r.Apttus_Config2__Datasource__c,
                                                         Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1ValueType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2ValueType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3ValueType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4ValueType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension1Id__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension2Id__c,
                                                         Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension3Id__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__c,Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension4Id__r.Apttus_Config2__Datasource__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__r.Apttus_Config2__Datasource__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6Id__r.Apttus_Config2__Datasource__c, 
                                                         Apttus_Config2__PriceMatrixId__r.Apttus_Config2__MatrixType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5ValueType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6ValueType__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension5Id__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__Dimension6Id__c,
                                                         Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Migration_Id__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ProductId__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ChargeType__c,
                                                         Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Frequency__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceMethod__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ProductName__c, Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c,
                                                         Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ListPrice__c FROM Apttus_Config2__PriceMatrixEntry__c 
                                                         WHERE Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Name LIKE :priceList 
                                                         AND Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Active__c = False
                                                         ORDER BY Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__ProductName__c, Apttus_Config2__AdjustmentAmount__c]) {
            
            // Filter price matrix entries based on selected pricing year stored in charge criteria of price list item
            
            if ((selectedCountry == pme.Apttus_Config2__Dimension1Value__c || selectedCountry == pme.Apttus_Config2__Dimension2Value__c ||
                selectedCountry == pme.Apttus_Config2__Dimension3Value__c || selectedCountry == pme.Apttus_Config2__Dimension4Value__c ||
                selectedCountry == pme.Apttus_Config2__Dimension5Value__c ) && pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c.contains(selectedPricingYear)) {
                priceMatrixEntryList.add(pme);
            }
        }
        return priceMatrixEntryList;
    }
    @AuraEnabled
    public static String updatePriceMatrixEntries(List<Apttus_Config2__PriceMatrixEntry__c> updatePMEList) {
        
        try {
            if (updatePMEList != null && updatePMEList.size() > 0) {
                for (Apttus_Config2__PriceMatrixEntry__c pme : updatePMEList) {
                    if (pme.Partial_Save__c) {
                        pme.Review_by_User__c = UserInfo.getUserId();
                    }
                }
                update updatePMEList;
                return 'Updated';
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
        return '';
    }
    @AuraEnabled
    public static String activatePriceBookEntries(String selectedPricingYear, String pricingTool) {
        String priceList = ''; 
        for (CPQ_Proposal_Create_Settings__c cpcs : CPQ_Proposal_Create_Settings__c.getall().values()) {
            if (cpcs.Available_Pricing_Tools__c == pricingTool) {
                priceList = cpcs.Master_Price_List__c;
            }
        }
        try {
            Boolean isAllReviewd = true;
            Set<Apttus_Config2__PriceListItem__c> priceListItemSet = new Set<Apttus_Config2__PriceListItem__c>();
            for (Apttus_Config2__PriceListItem__c bundlePLIList : [SELECT ID, Apttus_Config2__Active__c, Apttus_Config2__Criteria__c FROM Apttus_Config2__PriceListItem__c WHERE Apttus_Config2__ProductId__r.Apttus_Config2__ConfigurationType__c =: CON_CPQ.BUNDLE AND Apttus_Config2__PriceListId__r.NAME  =: priceList AND Apttus_Config2__Active__c = FALSE]) {
                if (bundlePLIList.Apttus_Config2__Criteria__c.contains(selectedPricingYear)) {
                    priceListItemSet.add(new Apttus_Config2__PriceListItem__c(Id = bundlePLIList.ID, Apttus_Config2__Active__c = true));
                }
            }
            for (Apttus_Config2__PriceMatrixEntry__c pme : [ SELECT 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c, 
                                                             Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c, Review_by_User__c 
                                                             FROM Apttus_Config2__PriceMatrixEntry__c 
                                                             WHERE Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__PriceListId__r.Name LIKE :priceList 
                                                             AND Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Active__c = False]) {
                
                // Filter price book entries based on selected pricing year stored in charge criteria of price list item
                if (pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__r.Apttus_Config2__Criteria__c.contains(selectedPricingYear)) {
                    if (pme.Review_by_User__c != null) {
                        priceListItemSet.add(new Apttus_Config2__PriceListItem__c(Id = pme.Apttus_Config2__PriceMatrixId__r.Apttus_Config2__PriceListItemId__c, Apttus_Config2__Active__c = true));
                    }
                    else {
                        isAllReviewd = false;
                        break;
                    }
                }
            }
            if (isAllReviewd && !priceListItemSet.isEmpty()) {
                List<Apttus_Config2__PriceListItem__c> priceListItemList = new List<Apttus_Config2__PriceListItem__c>();
                priceListItemList.addAll(priceListItemSet);
                update priceListItemList;
                return 'Activated';
            }
            else {
                return 'Not Activated';
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error Exception happend' + e.getMessage());
        }
    }

    public class WPR_CPQ_PricingWrapper {
        @AuraEnabled
        public List<String> attributeList{get;set;}
        @AuraEnabled
        public Map<String,String> attributeMap{get;set;}
        @AuraEnabled
        public String groupAttributeFieldName {get;set;}
        @AuraEnabled
        public Set<Integer> existingPricingYears {get;set;}
        @AuraEnabled
        public Set<Integer> existingPartialPricingYears {get;set;}
        @AuraEnabled
        public Map<String, String> attributeLabelMap {get;set;}
        @AuraEnabled
        public Map<String, List<Apttus_Config2__PriceMatrixEntry__c>> yearWithCountryPMEMap {get;set;}
        @AuraEnabled
        public Map<String, List<CPQ_AMESA_Partial_Product_Pricings__c>> yearWithCountryPartialPricingMap {get;set;}
        @AuraEnabled
        public String existingFullYears {get;set;}
        @AuraEnabled
        public Set<String> nonActivePricingYears {get;set;}
        @AuraEnabled
        public Map<String, String> countryToPercentMap {get;set;}
        @AuraEnabled
        public Boolean isReviewAll{get;set;}
        @AuraEnabled
        public Boolean isPartialPricingRequired{get;set;}
        @AuraEnabled
        public String baseCurrency{get;set;}
        @AuraEnabled
        public Map<String, boolean> reviewedStatusMap{get;set;}
        @AuraEnabled
        public Map<String, String> countryToLocalCurrencyMap{get;set;}
    }
    public class WPR_CPQ_ParentRecordWrapper {
        @AuraEnabled
        public Map<String, Apttus_Config2__PriceListItem__c> IdToPLIMap;
        @AuraEnabled
        public Map<String, Apttus_Config2__PriceMatrix__c> IdToPMMap;
        @AuraEnabled
        public List<Apttus_Config2__PriceListItem__c> PLIList;
        @AuraEnabled
        public List<Apttus_Config2__PriceMatrix__c> PMList;
        @AuraEnabled
        public List<Apttus_Config2__PriceMatrixEntry__c> PMEList;
        @AuraEnabled
        public String Status;
    }
}
