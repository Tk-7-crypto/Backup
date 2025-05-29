public class CNT_CPQ_QuoteLanding {
    @AuraEnabled
    public static List<RecordTypeDetail> getAvaiableRecordTypes(Id opportunityId) {
        if ((new SLT_Opportunity().getOpportunityDetails(opportunityId, new Set<String>{'Account.AccountStatus__c'})).getSObject('Account').get('AccountStatus__c') == CON_CPQ.INACTIVE) {
            return null;
        }
        List<RecordTypeDetail> recordTypeList = new List<RecordTypeDetail>();
        Map<String, List<String>> recordTypeAndPricingToolMap = new Map<String, List<String>>();
        List<String> pricingTools = new List<String>();
        
        Map<String, String> recordTypesByPermissionSets = new Map<String, String>();
        for(CPQ_Proposal_Create_Settings__c customSetting : CPQ_Proposal_Create_Settings__c.getall().values()){
            recordTypesByPermissionSets.put(customSetting.Permission_Set_Name__c, customSetting.Proposal_Record_Type_Name__c);
        }
        
        // If no custom setting record found then return null and display error message on UI
        if(recordTypesByPermissionSets.size() == 0){
            return recordTypeList;
        }
        // Check for logged in user's permission sets
        List<PermissionSetAssignment> assignedPermissionSets = new SLT_PermissionSetAssignment().selectByPermissionSetsForUserId(
            new Set<String> {CON_CPQ.ID},
            new Set<Id>{UserInfo.getUserId()},
            recordTypesByPermissionSets.keySet()
        );
        
        // If no permission set assigned to user then return null and display error message on UI
        if(assignedPermissionSets.size() == 0){
            return recordTypeList;
        }
        
        String recordTypes;
        List<String> assignedRecordTypes = new List<String>();
        List<String> assignedPermissionSetNames = new List<String>();
        
        // Get assigned permission sets of user and add record types specified in custom settings
        for(PermissionSetAssignment assignedPermissionSet : assignedPermissionSets){
            recordTypes = recordTypesByPermissionSets.get(assignedPermissionSet.PermissionSet.Name);
            assignedPermissionSetNames.add(assignedPermissionSet.PermissionSet.Name);
            if(!String.isBlank(recordTypes)){
                recordTypes = recordTypes.deleteWhitespace();
                assignedRecordTypes.addAll(recordTypes.split(',', -1));
            }
        }
        
        for(CPQ_Proposal_Create_Settings__c customSetting : CPQ_Proposal_Create_Settings__c.getall().values()){
            if(assignedPermissionSetNames.contains(customSetting.Permission_Set_Name__c) && customSetting.Available_Pricing_Tools__c != null){
                if (recordTypeAndPricingToolMap.containsKey(customSetting.Proposal_Record_Type_Name__c)) {
                    pricingTools = recordTypeAndPricingToolMap.get(customSetting.Proposal_Record_Type_Name__c);
                } else {
                    pricingTools = new List<String>();
                }
                pricingTools.add(customSetting.Available_Pricing_Tools__c);
                recordTypeAndPricingToolMap.put(customSetting.Proposal_Record_Type_Name__c, pricingTools);
            }
        }
        
        // Get actual record type id and label to display on UI
        for(RecordType recordType : new SLT_RecordType().getRecordTypesBySObjectType(CON_CPQ.APTTUS_PROPOSAL_PROPOSAL,  assignedRecordTypes)){
            recordTypeList.add(new RecordTypeDetail(recordType.Name, recordType.Id, recordTypeAndPricingToolMap.get(recordType.DeveloperName)));
        }
    
        return recordTypeList;
    }

    @AuraEnabled
    public static String createQuote(String pricingTool, String recordTypeId, Id  opportunityId) {
        try {
            String priceListName;
            Set<String> opportunityFieldSet = new Set<String>();
            for(CPQ_Proposal_Create_Settings__c customSetting : CPQ_Proposal_Create_Settings__c.getall().values()){
                if(customSetting.Available_Pricing_Tools__c == pricingTool)  {
                    priceListName = customSetting.Price_List__c;
                }
            }
			Apttus_Proposal__Proposal__c newBudget = new Apttus_Proposal__Proposal__c();
			newBudget.RecordTypeId = recordTypeId;
			newBudget.Select_Pricing_Tool__c = pricingTool;
			String searchKey = '%'+pricingTool+'%';
			List<CPQ_Mapping_Field_Set__mdt> mappings = [SELECT Opportunity_Field__c, Quote_Field__c, Pricing_Tool__c FROM CPQ_Mapping_Field_Set__mdt WHERE Pricing_Tool__c like :searchKey];
			for (CPQ_Mapping_Field_Set__mdt mapFields : mappings) {
				opportunityFieldSet.add(mapFields.Opportunity_Field__c);
			}
            sobject opportunityRecord = new SLT_Opportunity().getOpportunityDetails(opportunityId, opportunityFieldSet);
            sobject sb = opportunityRecord; 
            for (CPQ_Mapping_Field_Set__mdt mapFields : mappings) {
                String fieldAPIName = mapFields.Opportunity_Field__c;                
                if (fieldAPIName.contains('.')) {
                    List<string> splitedFields = fieldAPIName.split('\\.');
                    for(integer i = 0; i < splitedFields.size() - 1; i++){
                        sb = opportunityRecord.getSobject(splitedFields[i]);   
                    }
                    newBudget.put(mapFields.Quote_Field__c, string.valueof(sb.get(splitedFields[splitedFields.size()-1])));
                } else if (opportunityRecord.get(fieldAPIName) != null) {
				    newBudget.put(mapFields.Quote_Field__c, opportunityRecord.get(mapFields.Opportunity_Field__c));
                }
            }
			List<CPQ_Currency_PriceList_Mapping__mdt> newPriceList = [SELECT CurrencyIsoCode__c, Price_List_Name__c, Pricing_Tool__c FROM CPQ_Currency_PriceList_Mapping__mdt WHERE Pricing_Tool__c =: pricingTool AND CurrencyIsoCode__c =: newBudget.CurrencyIsoCode];
			if(newPriceList.size() > 0){
				priceListName = newPriceList[0].Price_List_Name__c;
			}  
			List<Apttus_Config2__PriceList__c> priceList = new SLT_PriceList().selectByNames(new Set<String> {priceListName}, new Set<String> {CON_CPQ.Name, CON_CPQ.ID});
			if(priceList.size() > 0){
				newBudget.Apttus_QPConfig__PriceListId__c = priceList[0].Id;  
			}
			if(pricingTool == CON_CPQ.AMESA) {
				newBudget.CurrencyIsoCode = CON_CPQ.CURRENCY_CHF;
				Apttus__APTS_Agreement__c[] relatedAgreement = [SELECT Id, Apttus__Related_Opportunity__c, Apttus__Related_Opportunity__r.name FROM Apttus__APTS_Agreement__c WHERE Apttus__Related_Opportunity__c =: opportunityId AND Record_Type__c =: CON_CPQ.AMESA LIMIT 1];
				Apttus_Proposal__Proposal__c[] relatedProposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c =: opportunityId AND Select_Pricing_Tool__c =: CON_CPQ.AMESA AND Record_Type_Name__c =: CON_CPQ.RECORD_TYPE_TECH_SOLUTION];
				if(relatedProposal.size() < 1 && relatedAgreement.size() > 0){
				    return 'AgreementExist';
				}
			}
			if (pricingTool == CON_CPQ.TS_JAPAN) {
				CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
				String additionalNotifier = '';
				if(cpqSetting != null && !String.isBlank(cpqSetting.CSS_Additional_Notifier__c)){
					additionalNotifier = cpqSetting.CSS_Additional_Notifier__c;
				}
				newBudget.Requester_Email__c = additionalNotifier;
				newBudget.CurrencyIsoCode = CON_CPQ.CURRENCY_JPY;
            }
	        fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Apttus_Proposal__Proposal__c.SobjectType
                }
            );
            uowProposal.registerNew(newBudget);
            uowProposal.commitWork();
            if(pricingTool == CON_CPQ.TS_JAPAN) {
				CPQ_Utility.syncOpportunityProductsIntoCartLineItems(JSON.serialize(newBudget));
			}
			CPQ_Utility.markAsPrimary(true, opportunityId, newBudget.Id);
			return newBudget.id;
		} catch (Exception e) {
			throw new AuraHandledException('Error Exception happend' + e.getMessage());
		}
    }
    
    @AuraEnabled
    public static Boolean validClinicalBid(Id opportunityId) {
        Boolean isValidClinicalBid = true;
        Set<Id> sObjectIdSet = new Set<Id>();
        sObjectIdSet.add(opportunityId);
        String condition = '';
        Set<String> fieldSet = new Set<String>{CON_CPQ.ID, CON_CPQ.RELATED_OPPORTUNITY_LINE_OF_BUSINESS, CON_CPQ.BID_HISTORY_OPPORTUNITY, CON_CPQ.BID_STOPPED};
        condition = 'Bid_History_Related_Opportunity__c in :sObjectIdSet AND (Record_Type__c = ' + '\'' + CON_CPQ.RECORD_TYPE_CLINICAL_BID + '\'' + ' OR Record_Type__c = '+ '\'' + CON_CPQ.CONTRACT_POST_AWARD_BID  +'\')';
        List<Bid_History__c> bidHistoryList = new SLT_Bid_History().getBidHistoriesByCondition(fieldSet, condition, sObjectIdSet);
        if (bidHistoryList.size () > 0) {
            isValidClinicalBid = false;
        }
        return isValidClinicalBid;
    }
    
    public class RecordTypeDetail {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public List<String> associatedTools {get; set;}
        
        public RecordTypeDetail(String recordTypeName, String recordTypeId, List<String> pricingTools) {
            this.label = recordTypeName;
            this.value = recordTypeId;
            this.associatedTools = pricingTools;
        }
    }
}
