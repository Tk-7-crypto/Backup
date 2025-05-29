/*
 * Version       : 1.0
 * Description   : Service Class for Opportunity
 */
global class SRV_CRM_Opportunity {
    
    /**
     * This method used to get detail of Opportunity
     * @params  Set<Id> oppIdset
     * @params  Set<string> oppFieldSet
     * @return  Map<Id, Opportunity>
     */
    public static Map<Id, Opportunity> getOppDetail(Set<Id> oppIdset, Set<string> oppFieldSet) {
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        try {
            idToOpportunityMap = new SLT_Opportunity().getOpportunityById(oppIdSet, oppFieldSet);
        } catch (exception ex) {
            String errMsg = ex.getMessage() + CON_CRM.SINGLE_SPACE + ex.getStackTraceString();
            throw new SRV_CRM_Opportunity_Exception(new List<String>{errMsg});
        }
        return idToOpportunityMap;
    }
    
    /**
     * This method used to get Opportunity by with Opportunity Splits and OpportunityTeam Members
     * @params  Set<Id> oppIdset
     * @params  Set<String> oppfieldSet
     * @params  Set<String> oppSplitFieldSet
     * @params  Set<String> oppTeamFieldSet
     * @params  String splitType
     * @return  Map<Id, Opportunity>
     */
    public static Map<Id, Opportunity> getOppByIdWithOppTeamSplits(Set<ID> oppIdSet, Set<String> oppfieldSet, Set<String> oppSplitFieldSet, Set<String> oppTeamFieldSet, String splitType) {
        Map<Id, Opportunity> idToOpportunityMap = new Map<Id, Opportunity>();
        try {
            idToOpportunityMap = new SLT_Opportunity().selectByIdWithOpportuntiyTeamSplits(oppIdSet, oppfieldSet, oppSplitFieldSet, oppTeamFieldSet, splitType);
        } catch (exception ex) {
            String errMsg = ex.getMessage() + CON_CRM.SINGLE_SPACE + ex.getStackTraceString();
            throw new SRV_CRM_Opportunity_Exception(new List<String>{errMsg});
        }
        return idToOpportunityMap;
    }
    
    /**
     * This method is to update the Modified Opportunity Close Date and schedules. 
     * @params  Id oppId
     * @params  String dayMoved 
     * @params  Boolean isToUpdateSchedule 
     * @params  List<String> olifieldList 
     * @params  List<String> oliSchedulefieldList
     */
    public static void updateCloseDateOfOpportunity(Id oppId, Integer dayMove, Boolean isToUpdateSchedule,List<String> olifieldList, List<String> oliSchedulefieldList) {
        Map<Id, Opportunity> idToOpportunityMap = null;
        Set<String> oppFieldList = new Set<String>{'id','CloseDate'};
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType,
                OpportunityLineItemSchedule.SObjectType,
                OpportunityLineItem.SObjectType
            }
        );
        try {
            idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{oppId}, oppFieldList);
            idToOpportunityMap.get(oppId).CloseDate = (idToOpportunityMap.get(oppId).CloseDate).addDays(dayMove);
            uow.registerDirty(idToOpportunityMap.get(oppId));
            if(isToUpdateSchedule) {
                oliList = SRV_CRM_OpportunityLineItem.getOliByIdWithSchedule(new Set<Id>{oppId},new Set<String>(olifieldList), new Set<String>(oliSchedulefieldList));
                for(OpportunityLineItem oli : oliList) {
                    for(OpportunityLineItemSchedule olis : oli.OpportunityLineItemSchedules) {
                       olis.ScheduleDate = (olis.ScheduleDate).addDays(dayMove);
                       uow.registerDirty(olis);
                    }
                    uow.registerDirty(oli);
                }
            }
            uow.commitWork();
        } catch(Exception ex) {
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                   errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
            	errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CRM_Opportunity_Exception(new List<String>(errorMsgList));
        }    
    }
    
    /**
     * This method is used to clone Opportunity records with Products and Contact Roles. 
     * @params  Id oppId
     * @params  Map<String,String> opportunity 
     * @params  Boolean isCloneOpportunity 
     * @params  Integer pricePercentAdjustment 
     * @params  Integer monthMoved
     * @params  Boolean isCloneProduct
     * @params  Boolean isCloneRevenueSchedule
     * @params  Boolean isCloneContactRole
     */
    public static Id cloneOpportunity(Id oppId, Map<String, String> mapTofieldValue, Boolean isDeepClone, Decimal pricePercentAdjustment, Integer monthMoved, Map<String, Boolean> objectTypeToIsCloneMap) {
        Map<Id, Opportunity> idToOpportunityMap = null;
        Boolean isRoundUp = false;
        Map<String, Schema.SObjectField> fMap = Opportunity.Sobjecttype.getDescribe().Fields.getMap();
        Set<string> oppFieldList = new Set<string>();
        List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.Opportunity.FieldSets.Opp_Clone_Fields_Exclude.getFields();
        Set<String> excludeFieldsSet = new Set<String>();
        CON_CRM.IS_CLONE_OPPORTUNITY_FLOW = true;
        for(Schema.FieldSetMember setMember : fieldSetMemberList) {
            excludeFieldsSet.add(setMember.getFieldPath());
        }
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()) { 
                Schema.DescribeFieldResult fd = ft.getDescribe();
                if (fd.isCreateable() && (!excludeFieldsSet.contains(fd.getName()))) { 
                    oppFieldList.add(fd.getName());
                }
            }
        }
        idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{oppId}, oppFieldList);
        Opportunity opportunityRecord = idToOpportunityMap.get(oppId);

        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        String requestedCurrencyType = mapTofieldValue.get('CurrencyIsoCode');
        String currentCurrencyIsoCode = opportunityRecord.CurrencyIsoCode;
        Boolean isCurrencyChanged = (requestedCurrencyType == currentCurrencyIsoCode) ?FAlSE : TRUE;
        if(isCurrencyChanged){
            Map<Id, CurrencyType> idTocurrencyTypeMap = new SLT_CurrencyType().selectAllCurrencyType();
            for(Id currencyTypeId : idTocurrencyTypeMap.keySet()) {
                isoCodeTocurrencyTypeMap.put(idTocurrencyTypeMap.get(currencyTypeId).isoCode,idTocurrencyTypeMap.get(currencyTypeId));
            }
        }
        List<OpportunityLineItem> oliList = null;
        List<OpportunityContactRole> contactRoleList = null;
        List<Drug_Product_Name__c> drugProductList = new List<Drug_Product_Name__c>();

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType,
                    OpportunityContactRole.SObjectType,
                    OpportunityLineItem.SObjectType,
                    Drug_Product_Name__c.SObjectType
                    }
        );
        
        fflib_SObjectUnitOfWork uowForOlis = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] { OpportunityLineItemSchedule.SObjectType }
        );
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            Opportunity opportunityToClone = opportunityRecord.Clone(false, isDeepClone, false, false);
            for(String fieldAPI : mapTofieldValue.keySet()) {
                if(fieldAPI == 'CloseDate') {
                    List<String> dateSplitList = mapTofieldValue.get(fieldAPI).split('-');
                    Date closeDate = Date.newInstance(Integer.valueOf(dateSplitList[0]), Integer.valueOf(dateSplitList[1]), Integer.valueOf(dateSplitList[2]));
                    opportunityToClone.put(fieldAPI, closeDate);
                }
                else {
                    if(fieldAPI == 'Round_Up__c') {
                        isRoundUp = Boolean.valueOf(mapTofieldValue.get(fieldAPI));
                     } else if(fieldAPI == 'Contract_Start_Date__c' ) {
                        if(!(String.IsBlank(mapTofieldValue.get(fieldAPI)))){
                            List<String> dateSplitList = mapTofieldValue.get(fieldAPI).split('-');
                            Date Contract_Start_Date = Date.newInstance(Integer.valueOf(dateSplitList[0]), Integer.valueOf(dateSplitList[1]), Integer.valueOf(dateSplitList[2]));
                            opportunityToClone.put(fieldAPI, Contract_Start_Date);
                        }
                     } else {
                        opportunityToClone.put(fieldAPI, mapTofieldValue.get(fieldAPI));
                     }
                }
            }
            Set<String> objectTypeSet = objectTypeToIsCloneMap.keySet();
            System.debug('opportunityToClone' + opportunityToClone);
            opportunityToClone.Amount = null;
            opportunityToClone.Parent_Opportunity__c = opportunityRecord.id;
            if(oppFieldList.contains('Line_of_Business__c') && oppFieldList.contains('Q2_Budget_Tool__c') && opportunityRecord.Line_of_Business__c == 'Q2 Solutions' && opportunityRecord.Q2_Budget_Tool__c == 'Q2 Bio'){
                opportunityToClone.Parent_Opportunity__c = null;
            }
            uow.registerNew(opportunityToClone);           
            if(objectTypeSet.contains('Product2') && objectTypeToIsCloneMap.get('Product2')) {
                oliList = getClonedOppLineItemWithSchedule(oppId, 'Clone');
                if(oliList != null) {
                    Boolean isRenewalOptions = false;
                    if(objectTypeSet.contains('RenewalOptions') && objectTypeToIsCloneMap.get('RenewalOptions')) {
                        isRenewalOptions = true;
                    }
                    Map<id,PriceBookEntry> priceBookEntryMap =  new Map<id,PriceBookEntry>();
                    if(isCurrencyChanged){
                        set<String> fieldset = new Set<String>{'id','Product2.Id'};
                        Set<Id> productIdSet =  new Set<Id>();
                        for(OpportunityLineItem oli : oliList) {
                            productIdSet.add(oli.Product2Id);
                        }
                        
                        List<PriceBookEntry> priceBookEntryList = new SLT_PriceBookEntry().getPbEntriesByProductIds(productIdSet, fieldset, requestedCurrencyType);
                        for(PriceBookEntry pbe : priceBookEntryList) {
                            priceBookEntryMap.put(pbe.Product2.Id,pbe);
                        }
                    }
                    for(OpportunityLineItem oli : oliList) {
                        /*
                        if(!oli.HasRevenueSchedule && isRenewalOptions) {
                            oli.UnitPrice = (oli.UnitPrice * (1 + pricePercentAdjustment/100)).setScale(2);
                        }*/
                        oli.UnitPrice = (oli.UnitPrice * (1 + pricePercentAdjustment/100)).setScale(2);
                        if(isRoundUp == true && oli.HasRevenueSchedule == false) {
                            oli.UnitPrice =  oli.UnitPrice.round(System.RoundingMode.CEILING);
                        }
                        if ((oli.Product_Material_Type_Text__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZREP || oli.Product_Material_Type_Text__c == CON_CRM.PRODUCT_MATERIAL_TYPE_ZPUB) && String.isBlank(oli.therapy_area__c)){
                            oli.Therapy_Area__c = CON_CRM.OLI_THERAPY_AREA_NONE_0;
                        }
                        if(isRenewalOptions && Integer.valueOf(monthMoved) > 0) {
                            if(oli.Product_Start_Date__c != null) {
                                oli.Product_Start_Date__c = oli.Product_Start_Date__c.addMonths(Integer.valueOf(monthMoved));
                            }
                            if(oli.Product_End_Date__c != null) {
                                oli.Product_End_Date__c = oli.Product_End_Date__c.addMonths(Integer.valueOf(monthMoved)); 
                            }
                        }
                        if(isCurrencyChanged){
                            if(priceBookEntryMap.containsKey(oli.Product2Id)) {
                                oli.PricebookEntryId = priceBookEntryMap.get(oli.Product2Id).id;
                            }
                            if(oli.OpportunityLineItemSchedules.size() == 0) {
                                oli.unitPrice = getCurrencyConversionRate(isoCodeTocurrencyTypeMap, requestedCurrencyType, currentCurrencyIsoCode,(Double)oli.unitPrice);
                            }
                        }
                        oli.Sale_Type__c = CON_CRM.OLI_SALETYPE_REPEAT;
                        uow.registerNew(oli, OpportunityLineItem.OpportunityId, opportunityToClone);
                        if(oli.OpportunityLineItemSchedules.size() > 0) {
                            for(OpportunityLineItemSchedule olis : oli.OpportunityLineItemSchedules) {
                                OpportunityLineItemSchedule olisCloned = olis.clone(false, true, false, false);
                                olisCloned.OpportunityLineItemId = null;
                                if(isRenewalOptions) {
                                    if(Integer.valueOf(monthMoved) > 0) {
                                      olisCloned.ScheduleDate = olisCloned.ScheduleDate.addMonths(Integer.valueOf(monthMoved));  
                                    }
                                    olisCloned.Revenue = olisCloned.Revenue * (1 + pricePercentAdjustment/100);
                                    olisCloned.Revenue = olisCloned.Revenue.setScale(2);
                                    if(isRoundUp == true && oli.HasRevenueSchedule == true) {
                                        olisCloned.Revenue = olisCloned.Revenue.round(System.RoundingMode.CEILING);
                                    }
                                }
                                if(isCurrencyChanged){
                                    olisCloned.Revenue = getCurrencyConversionRate(isoCodeTocurrencyTypeMap, requestedCurrencyType, currentCurrencyIsoCode,(Double)olisCloned.Revenue);
                                }
                                uowForOlis.registerNew(olisCloned, OpportunityLineItemSchedule.OpportunityLineItemId, oli);
                            } 
                        }
                    }
                }
                
            }
            if(objectTypeSet.contains('OpportunityContactRole') && objectTypeToIsCloneMap.get('OpportunityContactRole')) {
                contactRoleList = getClonedOpportunityContactRole(oppId);
                if(contactRoleList != null) {
                    for(OpportunityContactRole contactRole : contactRoleList) {
                        uow.registerNew(contactRole, OpportunityContactRole.OpportunityId, opportunityToClone);
                    }
                }
            }
            if(objectTypeSet.contains('OpportunityDrugProduct') && objectTypeToIsCloneMap.get('OpportunityDrugProduct')) {
                drugProductList = new SLT_DrugProductName().getOppDrugProductByOppId(new Set<Id>{oppId}, new Set<String>{'Opportunity__c', 'Drug_Product__c'});
                if(drugProductList.size() > 0) {
                    for(Drug_Product_Name__c oppDrugProduct : drugProductList.deepclone()) {
                        uow.registerNew(oppDrugProduct, Drug_Product_Name__c.Opportunity__c, opportunityToClone);
                    }
                }
            }
            uow.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = true;
            uowForOlis.commitWork();
            UTL_ExecutionControl.stopTriggerExecution = false;
            if(oliList != null) {
                update oliList;
            }
            if(opportunityToClone.Id != null){
                if(objectTypeSet.contains('IqviaQuote') && objectTypeToIsCloneMap.get('IqviaQuote')) {
                    List<OpportunityLineItem> oldOliList = new SLT_OpportunityLineItems().selectByOpportunityIds(new Set<Id>{oppId} , new Set<String>{'Id'});
                    if(oldOliList.size() > 0 ){
                        Map<Id, String> iqviaQuote = CPQ_QuoteUtilityWO.iqviaQuoteCloneForMultipleOpportunities(new Map<ID,ID>{oppId => opportunityToClone.Id });
                    }
                }
            }
            return opportunityToClone.Id;
        } catch(Exception ex) {
            Database.rollback(sp);
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                    errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
                system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CRM_Opportunity_Exception(new List<String>(errorMsgList));
        }    
    }
    
    /**
     * This method is used to get cloned LineItem with Schedule. 
     * @params  Id opportunityId
     * @params String operationType
     */
    public static List<OpportunityLineItem> getClonedOppLineItemWithSchedule(Id opportunityId , String operationType) {
        List<OpportunityLineItem> oliWithScheduleList  = null;
        Map<String, Schema.SObjectField> oliFieldsMap = OpportunityLineItem.Sobjecttype.getDescribe().Fields.getMap();
        Map<String, Schema.SObjectField> olisFieldsMap = OpportunityLineItemSchedule.Sobjecttype.getDescribe().Fields.getMap();
        Set<string> oliFieldSet = new Set<string>();
        Set<string> olisFieldSet = new Set<string>();
        List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.OpportunityLineItem.FieldSets.OLI_Clone_Fields_Exclude.getFields();
        Set<String> excludeOLIFieldsSet = new Set<String>();
        Set<String> oliFieldsAddOnSoqlSet = new Set<String>{'Product_Material_Type_Text__c'};
        for(Schema.FieldSetMember setMember : fieldSetMemberList) {
            excludeOLIFieldsSet.add(setMember.getFieldPath());
        }
        for (Schema.SObjectField ft : oliFieldsMap.values()) { 
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if (fd.isCreateable() && (!fd.isUnique()) && !excludeOLIFieldsSet.contains(fd.getName())) { 
                    oliFieldSet.add(fd.getName());
                }
            else if(operationType == 'ChangeCurrency' && (fd.getName() == 'LI_OpportunityLineItem_Id__c' || fd.getName() == 'LQ_OpportunityLineItem_Id__c')) {
                oliFieldSet.add(fd.getName());        
            }
        }
        oliFieldSet.add('HasRevenueSchedule');  
        oliFieldSet.addAll(oliFieldsAddOnSoqlSet);

        for (Schema.SObjectField ft : olisFieldsMap.values()) { 
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if (fd.isCreateable() && (!fd.isUnique()) && fd.getName() != 'OpportunityLineItemId') { 
                olisFieldSet.add(fd.getName());
            }
        }
        Map<Id, OpportunityLineItem> idToOLIMap = new SLT_OpportunityLineItems(false).getActiveOlisWithSchedules(new Set<Id>{opportunityId}, oliFieldSet, olisFieldSet);
        if(idToOLIMap.size() > 0) {
            oliWithScheduleList = idToOLIMap.values().deepClone();
        }
        return oliWithScheduleList;
    }
    
    /**
     * This method is used to get cloned Contact Role. 
     * @params  Id opportunityId
     */
    public static List<OpportunityContactRole> getClonedOpportunityContactRole(Id opportunityId) {
        List<OpportunityContactRole> ocrReturnList = null;
        Map<String, Schema.SObjectField> ocrFieldsMap = OpportunityContactRole.SobjectType.getDescribe().Fields.getMap();
        Set<String> ocrFieldSet = new Set<String>();
        for (Schema.SObjectField ft : ocrFieldsMap.values()) { 
            Schema.DescribeFieldResult fd = ft.getDescribe();
            if (fd.isCreateable() && (!fd.isUnique()) && fd.getName() != 'OpportunityId') { 
                ocrFieldSet.add(fd.getName());
            }
        }
        List<OpportunityContactRole> ocrList = new SLT_OpportunityContactRoles().selectByOpportunityId(new Set<Id>{opportunityId}, ocrFieldSet);
        if(ocrList.size() > 0) {
            ocrReturnList = ocrList.deepclone();
        }
        return ocrReturnList;
    }
    
    
    /**
     * This method used to get records of currency Change.
     * @return  List<CurrencyType>
     */
    public static List<CurrencyType> getCurrencyTypeRecords() {
        Map<Id, CurrencyType> currencyTypeMap = new Map<Id, CurrencyType>();
        try {
            currencyTypeMap = new SLT_CurrencyType().selectAllCurrencyType();
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return currencyTypeMap.values();
    }
    
    /**
     * This method is used to save the changed currency of Opportunity records. 
     * @params  Id oppId
     * @params  String requestedCurrencyType
     */   
    public static void changeCurrencyOfOpportunity(Id opportunityId, String requestedCurrencyType) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                OpportunityLineItem.SObjectType
            }
        );
        Map<Id, Opportunity> idToOpportunityMap = null;
        Map<Id, CurrencyType> idTocurrencyTypeMap = new SLT_CurrencyType().selectAllCurrencyType();
        Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new Map<String, CurrencyType>();
        for(Id currencyTypeId : idTocurrencyTypeMap.keySet()) {
            isoCodeTocurrencyTypeMap.put(idTocurrencyTypeMap.get(currencyTypeId).isoCode,idTocurrencyTypeMap.get(currencyTypeId));
        }
        Set<String> oppFieldList = new Set<String>{'id','CurrencyIsoCode','StageName','RD_Product_Count__c'};
        idToOpportunityMap = SRV_CRM_Opportunity.getOppDetail(new Set<Id>{opportunityId}, oppFieldList);
        Opportunity opportunityRecord;
        if(idToOpportunityMap.containsKey(opportunityId)) {
            opportunityRecord = idToOpportunityMap.get(opportunityId);
        }
        String currentCurrencyIsoCode = opportunityRecord.CurrencyIsoCode;
        Set<string> oliFieldSet = new Set<string>{'id','Product2Id','LI_OpportunityLineItem_Id__c','LQ_OpportunityLineItem_Id__c'};
        Set<string> olisFieldSet = new Set<string>{'id'};
        List<OpportunityLineItem> oliList = getClonedOppLineItemWithSchedule(opportunityRecord.id ,'ChangeCurrency');
        Map<Id, OpportunityLineItem> idToOLIMap = new SLT_OpportunityLineItems(false).getOlisWithSchedules(new Set<Id>{opportunityRecord.id}, oliFieldSet, olisFieldSet); 
        Map<String, Id> legacyidToOLIIdMap = new Map<String, Id>();
        String key;
        for(OpportunityLineItem oli : idToOLIMap.values()) {
            key = oli.LI_OpportunityLineItem_Id__c + '-' + oli.LQ_OpportunityLineItem_Id__c;
            legacyidToOLIIdMap.put(key, oli.id);
        }
        Savepoint sp = null;
        Mulesoft_Integration_Control__c mulesoftSetting = Mulesoft_Integration_Control__c.getInstance();
        List<OpportunityLineItemSchedule> oliListToInsert = new List<OpportunityLineItemSchedule>();
        Set<String> errMsgList = new Set<String>();
        Set<String> oppStagesToValidate = new Set<String>();
        oppStagesToValidate.add(CON_CRM.FINALIZING_DEAL_STAGE);
        oppStagesToValidate.add(CON_CRM.RECEIVED_ATP_STAGE);
        oppStagesToValidate.add(CON_CRM.CLOSED_WON_STAGE);
        oppStagesToValidate.add(CON_CRM.CLOSED_LOST_STAGE);
        if(mulesoftSetting.Is_Mulesoft_User__c) {  
            errMsgList.add('Mulesoft User can not change currency of opportunity.');
            throw new SRV_CRM_Opportunity_Exception(new List<String>(errMsgList));
        }
        if(oppStagesToValidate.contains(opportunityRecord.StageName) && opportunityRecord.RD_Product_Count__c > 0) {
            errMsgList.add('Opportunity currency cannot be changed at '+opportunityRecord.StageName+' when Opportunity contains an R&D Product');
            throw new SRV_CRM_Opportunity_Exception(new List<String>(errMsgList));
        }
        try {
            sp = Database.setSavepoint();
            if(oliList != null && oliList.size() > 0) {
                CON_CRM.IS_CURRENCY_CHANGE_FLOW = true;
            }
            Set<Id> productIdSet =  new Set<Id>();
            for(OpportunityLineItem oli : idToOLIMap.values()) {
                uow.registerDeleted(oli);
                productIdSet.add(oli.Product2Id);
            }
            set<String> fieldset = new Set<String>{'id','Product2.Id'};
            List<PriceBookEntry> priceBookEntryList = new SLT_PriceBookEntry().getPbEntriesByProductIds(productIdSet, fieldset, requestedCurrencyType);
            Map<id,PriceBookEntry> priceBookEntryMap =  new Map<id,PriceBookEntry>();
            for(PriceBookEntry pbe : priceBookEntryList) {
                priceBookEntryMap.put(pbe.Product2.Id,pbe);
            }
            uow.commitWork();
            // Reset to mulesoft opportunity flags as Opportunity status should be pending in this flow.
            CON_CRM.MULESOFT_OPP_SYNC_TRIGGER_HAS_RUN = false;
            CON_CRM.MULESOFT_OPP_VALIDATION_TRIGGER_HAS_RUN = false;
            uow = new fflib_SObjectUnitOfWork(
                       new Schema.SObjectType[] {
                           Opportunity.SObjectType
                       }
                   );
            opportunityRecord.CurrencyIsoCode = requestedCurrencyType;
            opportunityRecord.isCurrencyChanged__c = true;
            uow.registerDirty(opportunityRecord);  
            uow.commitWork();
            
            uow = new fflib_SObjectUnitOfWork(
                       new Schema.SObjectType[] {
                           OpportunityLineItem.SObjectType,
                           OpportunityLineItemSchedule.SObjectType   
                       }
                   );
            fflib_SObjectUnitOfWork uowForSchedules = new fflib_SObjectUnitOfWork(
                       new Schema.SObjectType[] {
                           OpportunityLineItemSchedule.SObjectType   
                       }
                   );
            if(oliList != null) {
                for(OpportunityLineItem oli : oliList) {
                    oli.OpportunityId = opportunityRecord.id;
                    oli.Prior_LI_OLI_Id__c = oli.LI_OpportunityLineItem_Id__c;
                    if(legacyidToOLIIdMap.containsKey(oli.LI_OpportunityLineItem_Id__c + '-' + oli.LQ_OpportunityLineItem_Id__c)) {
                        oli.Prior_QI_OLI_Id__c = legacyidToOLIIdMap.get(oli.LI_OpportunityLineItem_Id__c + '-' + oli.LQ_OpportunityLineItem_Id__c);
                    }
                    oli.Prior_LQ_OLI_Id__c = oli.LQ_OpportunityLineItem_Id__c;
                    if(priceBookEntryMap.containsKey(oli.Product2Id)) {
                        oli.PricebookEntryId = priceBookEntryMap.get(oli.Product2Id).id;
                    }
                    if(oli.OpportunityLineItemSchedules.size() == 0) {
                        oli.unitPrice = getCurrencyConversionRate(isoCodeTocurrencyTypeMap, requestedCurrencyType, currentCurrencyIsoCode,(Double)oli.unitPrice);
                    }/*
                    if(oli.Project_Awarded_Price__c != null){
                        oli.Project_Awarded_Price__c = getCurrencyConversionRate(isoCodeTocurrencyTypeMap, requestedCurrencyType, currentCurrencyIsoCode,(Double)oli.Project_Awarded_Price__c);
                    } 
                    if(oli.Signed_Contract_Price__c != null){
                        oli.Signed_Contract_Price__c = getCurrencyConversionRate(isoCodeTocurrencyTypeMap, requestedCurrencyType, currentCurrencyIsoCode,(Double)oli.Signed_Contract_Price__c);
                    }*/ 
                    oli.LI_OpportunityLineItem_Id__c = null;
                    oli.LQ_OpportunityLineItem_Id__c = null;
                    uow.registerNew(oli);
                    if(oli.OpportunityLineItemSchedules.size() > 0) {
                        for(OpportunityLineItemSchedule olis : oli.OpportunityLineItemSchedules) {
                            OpportunityLineItemSchedule olisCloned = olis.clone(false, true, false, false);
                            olisCloned.OpportunityLineItemId = null;
                            olisCloned.Revenue = getCurrencyConversionRate(isoCodeTocurrencyTypeMap, requestedCurrencyType, currentCurrencyIsoCode,(Double)olisCloned.Revenue);
                            uowForSchedules.registerNew(olisCloned, OpportunityLineItemSchedule.OpportunityLineItemId, oli);
                        }
                    }
                }
                uow.commitWork();
                //below assignment will stop reset of oli mulesoft sync flag to reset.
                CON_CRM.OLI_NEW_LIST_OLD_COUNT = -1;
                uowForSchedules.commitWork();
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            Set<String> errorMsgList = new Set<String>();   
            if(ex.getTypeName() == 'System.DmlException') {
                for(Integer i = 0; i < ex.getNumDml(); i++) {
                    errorMsgList.add(ex.getDmlMessage(i));
                }
            }
            else {
                system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                errorMsgList.add(ex.getMessage() + ' ' + ex.getStackTraceString());
            }
            throw new SRV_CRM_Opportunity_Exception(new List<String>(errorMsgList));
        }    
    }
    
    /**
     * This method is used to get currency of new type by exchange rates.
     * @params  Map<String,CurrencyType> currencyTypeMap
     * @params  String requestedCurrency
     * @params  String currentCurrency
     * @params  Currency olisPrice
     * @retrun  Currency 
     */   
    public static Double getCurrencyConversionRate(Map<String,CurrencyType> currencyTypeMap, String requestedCurrency, String currentCurrency, Double  olisPrice) {
        Double modifiedOlisPrice = (currencyTypeMap.get(requestedCurrency).ConversionRate/currencyTypeMap.get(currentCurrency).ConversionRate) * olisPrice;
        return modifiedOlisPrice;
    }
    
    /**
     * This method is used to validate the proxy object on Opportunity. 
     * @params  Id oppId
     * @return  String 
     */   
    public static String validateProxyObjectRecordsForOpportunity(Id opportunityId) {
        String errorMsg = '';
        Integer msgStringLength = 0;
        Set<Id> oppIdSet = new Set<Id> { opportunityId };
        Set<String> oppFieldSet = new Set<String> { 'Id' ,'PA_Required__c' };
        Map<Id, Opportunity> oppMapToId = new SLT_Opportunity().getOpportunityById(oppIdSet, oppFieldSet);
        Set<String> fieldSet = new Set<String> { 'Id' };
        String filterCondition = CON_CRM.OPPORTUNITY_API +' IN :oppIdSet ';
        List<Proxy_BNF__c> proxyBNFList = new List<Proxy_BNF__c>();
        List<BNF2__c> BNFList = new List<BNF2__c>();
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        if(!bnfSetting.Enable_IQVIA_BNF_Validation__c) {
           proxyBNFList = new SLT_ProxyBNF().selectByFilter(oppIdSet, fieldSet, filterCondition); 
        }  
        else {
            BNFList = new SLT_BNF().selectByFilter(oppIdSet, fieldSet, filterCondition); 
        }
        List<Proxy_Pricing_Assistant__c> proxyPAList = new List<Proxy_Pricing_Assistant__c>();
        if(oppMapToId.containsKey(opportunityId) && oppMapToId.get(opportunityId).PA_Required__c) {
            proxyPAList = new SLT_ProxyPricingAssistant().selectByOpportunityIds(oppIdSet, fieldSet); 
        }
        List<Proxy_Project__c> proxyProjectList = new SLT_Proxy_Project().selectByFilter(oppIdSet, fieldSet);
        String filterConditionForAgreement = CON_CRM.OPPORTUNITY_API +' IN :oppIdSet ';
        List<Proxy_SCM_Agreement__c> proxySCMAgreementList = new SLT_ProxySCMAgreement().selectByFilter(oppIdSet, fieldSet, filterConditionForAgreement);
        Set<String> proxyObjectList = new Set<String>();
        if(proxyBNFList != null && proxyBNFList.size() > 0) {
            proxyObjectList.add('BNF/MIBNF');
        }
        if(BNFList != null && BNFList.size() > 0) {
            proxyObjectList.add('BNF');
        }
        if(proxyPAList != null && proxyPAList.size() > 0) {
            proxyObjectList.add('Pricing Assistant');
        } 
        if(proxySCMAgreementList != null && proxySCMAgreementList.size() > 0) {
            proxyObjectList.add('SCM Agreement');
        } 
        if(proxyProjectList != null && proxyProjectList.size() > 0) {
            proxyObjectList.add('Project');
        }
        if(proxyObjectList != null && proxyObjectList.size() > 0) {
            errorMsg = System.Label.CRM_CL0023_OPP_CURRENCY_UPDATE_ERROR + ' ';
            for(String str :proxyObjectList) {
                if(msgStringLength == 0) {
                	errorMsg = errorMsg + str ;
                }
                else if(msgStringLength == proxyObjectList.size() - 1) {
                	errorMsg = errorMsg + ' and ' + str  ;
                }
                else {
                    errorMsg = errorMsg + ', ' + str;
                }
                msgStringLength = msgStringLength + 1;
            }
        }
        return errorMsg;
    }
    
    /**
     * This method is used to validate the proxy object on Opportunity. 
     * @params  Id oppId
     * @return  String 
     */
    public static void updateAccountOnOpportunity(Opportunity opporunityRecord) {
        fflib_SObjectUnitOfWork uowForOpportunity = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Opportunity.SObjectType   
                    }
        );
        Opportunity oppToUpdate = new Opportunity(Id = opporunityRecord.Id, AccountId = opporunityRecord.accountId);
        uowForOpportunity.registerDirty(oppToUpdate);
        uowForOpportunity.commitwork();
    }
    
    /**
     * This method is used to Send email to Opportunities with Credit Assessment Check.
     */
    public static void sendCreditAssessmentCheckEmail(Map<Id, Opportunity> oppMap, List<Credit_control_Threshold__c> creditControlThresholdList, Map<Id, Account> accMap) {
        try{
            DAOH_Opportunity.getCreditAssesmentOpportunity(oppMap, creditControlThresholdList, accMap);            
        }catch(SRV_CRM_Opportunity_Exception exc){
            
        }
    }
    
    /**
     * Exception class for SRV_CRM_Opportunity
     */
    public class SRV_CRM_Opportunity_Exception extends Exception {
        List<String> errorList = new List<String>();
        
        /**
         * constructor of SRV_CRM_Opportunity
         */
        public SRV_CRM_Opportunity_Exception (List<String> errorList) {
            this.errorList = errorList;
        }
    }

}