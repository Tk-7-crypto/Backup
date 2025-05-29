public class CPQ_Utility {
    public static final String S_Master = CON_CPQ.MASTER;
    public static final String S_User = CON_CPQ.User;
    public static List<String> downloadUrlList { get; set; }
    public static List<Attachment> attachmentList { get; set; }
    public static Id oppId { get; set; }
    private static String baseUrl = URL.getOrgDomainUrl().toExternalForm() + CON_CPQ.URL_SERVICE_dATA45;
    public static Boolean createTask = true;
    public static Id recordTypeId;
    public static Boolean isRunningTest = false;
    public static Id proposalBudgetRecordTypeId {
        get {
            if (proposalBudgetRecordTypeId == null){
                proposalBudgetRecordTypeId = SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(
                    CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET).getRecordTypeId();
                return proposalBudgetRecordTypeId;
            }
            else
                return proposalBudgetRecordTypeId;
        }
        set;
    }
    
    public static Id proposalRDSNonSFRecordTypeId {
        get {
            if (proposalRDSNonSFRecordTypeId == null){
                proposalRDSNonSFRecordTypeId = SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(
                    CON_CPQ.RDS_NON_SF).getRecordTypeId();
                return proposalRDSNonSFRecordTypeId;
            }
            else
                return proposalRDSNonSFRecordTypeId;
        }
        set;
    }
    
    // Get Tech Solution record type id of Proposal
    public static Id proposalTechSolutionRecordTypeId {
        get {
            if (proposalTechSolutionRecordTypeId == null){
                proposalTechSolutionRecordTypeId = SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(
                    CON_CPQ.TECH_SOLUTION).getRecordTypeId();
                return proposalTechSolutionRecordTypeId;
            }
            else
                return proposalTechSolutionRecordTypeId;
        }
        set;
    }
    
    public static Messaging.SingleEmailMessage getSingleMessage(String emailTemplateName, Id whatId, Id whoId, List<String> addressList) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<EmailTemplate> emailTemplate = new SLT_EmailTemplate().selectEmailDTemplateByDeveloperName(
        	emailTemplateName, new Set<String>{CON_CPQ.Id});
        if (emailTemplate.size() > 0) {
            Messaging.SingleEmailMessage mailTemp = Messaging.renderStoredEmailTemplate(
            emailTemplate[0].Id, whoId, whatId);
            mail.setSubject(mailTemp.getSubject());
            mail.setHtmlBody(mailTemp.getHtmlbody());
            mail.setUseSignature(false); 
            mail.setBccSender(false); 
            mail.setSaveAsActivity(false);
            mail.setWhatId(whoId); 
            mail.setToAddresses(addressList);
            return mail;
        }
        return null;
    }

    public static Set<String> getIdFieldSet() {
        return new Set<String> {CON_CPQ.ID};
    }

    public static Map<String, List<UTL_CPQ_GetObjectsRest.Objects>> getObjectList() {
        Map<String, List<UTL_CPQ_GetObjectsRest.Objects>> responseMap = new Map<String, List<UTL_CPQ_GetObjectsRest.Objects>> ();
        List<UTL_CPQ_GetObjectsRest.Objects> tempObjectList = new List<UTL_CPQ_GetObjectsRest.Objects> ();
        UTL_CPQ_GetObjectsRest.Objects tempObject = new UTL_CPQ_GetObjectsRest.Objects();
        Http httpRequest = new Http();
        String tempobjName, packageName;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseUrl + CON_CPQ.SOBJECTS);
        request.setMethod(CON_CPQ.GET);
        request.setHeader(CON_CPQ.AUTHORIZATION, CON_CPQ.BEARER + UserInfo.getSessionId());
        request.setHeader(CON_CPQ.CONTENT_TYPE, CON_CPQ.APPLICATION_JSON);
        HttpResponse res = httpRequest.send(request);

        SobjectResponseList apiResponse = (SobjectResponseList) JSON.deserialize(res.getBody(), SobjectResponseList.class);
	
        for (SobjectResponse sobjectItem : apiResponse.sobjects) {
            tempobjName = sobjectItem.name;
            if (sobjectItem.triggerable) {
                if (sobjectItem.custom) {
                    if (tempobjName.countMatches('__') > 1) {
                        packageName = tempobjName.split('__')[0];
                    } else {
                        packageName = CON_CPQ.CUSTOM_OBJECTS;
                    }
                } else {
                    packageName = CON_CPQ.STANDARD_OBJECTS;
                }
                tempObjectList = responseMap.get(packageName) != null ? responseMap.get(packageName) : new List<UTL_CPQ_GetObjectsRest.Objects> ();
                tempObject = new UTL_CPQ_GetObjectsRest.Objects();
                tempObject.label = sobjectItem.label;
                tempObject.apiName = tempobjName;
                tempObjectList.add(tempObject);
                responseMap.put(packageName, tempObjectList);
            }
        }
        return responseMap;

    }
    public static List<UTL_CPQ_GetFieldsRest.FieldsList> getObjectFields(String objectName) {
        List<UTL_CPQ_GetFieldsRest.FieldsList> responseList = new List<UTL_CPQ_GetFieldsRest.FieldsList> ();
        Map<String, Schema.SObjectField> allFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for (String strField : allFields.keySet()) {
            Schema.DescribeFieldResult tempSOF = allFields.get(strField).getDescribe();
            if (!tempSOF.isUpdateable()) {
                continue;
            }
            string pckval;

            UTL_CPQ_GetFieldsRest.FieldsList tempF = new UTL_CPQ_GetFieldsRest.FieldsList();
            tempF.label = tempSOF.getLabel();
            tempF.apiName = tempSOF.getName();
            tempF.description = tempSOF.getInlineHelpText();
            tempF.sdataType = String.valueOf(tempSOF.getType());

            if (tempF.sdataType == String.valueOf(Schema.DisplayType.Picklist)) {
                List<Schema.Picklistentry> picklistValuesList = tempSOF.getpicklistValues();

                for (integer index = 0; index < picklistValuesList.Size(); index++) {
                    if (pckval != null) {
                        pckval = pckval + picklistValuesList[index].getvalue() + CON_CPQ.SEMICOLON;
                    } else {
                        pckval = picklistValuesList[index].getvalue() + CON_CPQ.SEMICOLON;
                    }
                }
            }
            tempF.picklistValue = pckval;
            tempF.IsRequired = tempSOF.isNillable() ? false : true;
            responseList.add(tempF);
        }

        return responseList;
    }
    public static List<UTL_GetTemplateDataRest.TemplateData> getTemplateData(String templateName) {
        List<UTL_GetTemplateDataRest.TemplateData> responseList = new List<UTL_GetTemplateDataRest.TemplateData> ();
        UTL_GetTemplateDataRest.TemplateData tempDataInstance = new UTL_GetTemplateDataRest.TemplateData();
        for (Template_Data__c tempData : new SLT_Template_Data().selectTemplateDatabyName(templateName)) {
            tempDataInstance = new UTL_GetTemplateDataRest.TemplateData();
            tempDataInstance.cellReference = tempData.Cell_Reference__c;
            tempDataInstance.dmlType = tempData.DML_Type__c;
            tempDataInstance.fieldName = tempData.Field_Name__c;
            tempDataInstance.objectName = tempData.Object_Name__c;
            tempDataInstance.packageName = tempData.Package_Name__c;
            tempDataInstance.templateVersion = Integer.valueOf(tempData.version__c);
            if (tempData.Field_Name__c.contains('__r')) {
                String objectN = CPQ_Utility.getObjectApiNameFromLookupField(tempData.Object_Name__c,tempData.Field_Name__c.substringBefore('.').replace('__r', '__c'));
                String fieldN = tempData.Field_Name__c.substringAfter('.');
                tempDataInstance.sdataType = String.valueOf(Schema.getGlobalDescribe().get(objectN).getDescribe().fields.getMap().get(fieldN).getDescribe().getType());
            } else {
                tempDataInstance.sdataType = String.valueOf(Schema.getGlobalDescribe().get(tempData.Object_Name__c).getDescribe().fields.getMap().get(tempData.Field_Name__c).getDescribe().getType());
            }
            responseList.add(tempDataInstance);
        }
        return responseList;
    }

    public static String getObjectApiNameFromLookupField(String objectApiName, String lookupFiledApiName) {
        String objectName = objectApiName;
        String fieldName =  lookupFiledApiName;
        Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe();

        for(Schema.SObjectType reference : f.getReferenceTo()) {
            return reference.getDescribe().getName();
        }
        return null;
    }
    public class VersionResponse {
        public String label;
        public String url;
        public String version;
    }
    private class SobjectResponse {
        private Boolean custom;
        private String label;
        private String name;
        private Boolean triggerable;
    }
    private class SobjectResponseList {
	    private List<SobjectResponse> sobjects;
    }
      
    public static Double getCurrencyConvertedValue(Decimal requestedCurrencyConversionRate, Decimal currentCurrencyConversionRate, Double value) {
        return (requestedCurrencyConversionRate/currentCurrencyConversionRate) * value;
    }
    
    public static Apex_Error_Log__c createApexErrorLogRecord(Id recordId,String errorMessage,String objectName) {
        Apex_Error_Log__c logRecord = new Apex_Error_Log__c();
        logRecord.Record_Id__c = recordId;
        logRecord.Error_Message__c = errorMessage;
        logRecord.Object__c = objectName;
        logRecord.Record_Processed__c = false;
        logRecord.Running_User__c = UserInfo.getUserId();
        insert logRecord;
        return logRecord;
    }
    

    public static Apttus_Proposal__Proposal__c cloneClinical(Id clinicalBidId, String pricingTool) {
        Apttus_Proposal__Proposal__c clonedBudget = new Apttus_Proposal__Proposal__c();
        
        if (clinicalBidId != null) {
            clonedBudget.Clinical_Bid__c = clinicalBidId;
        
            Set<String> clinicalToBudgetCloneFieldSet = new Set<String>();
            for (Schema.FieldSetMember field : 
                Schema.SObjectType.Bid_History__c.fieldSets.getMap().get(CON_CPQ.AGREEMENT_FIELDSET_CLINICAL_TO_BUDGET_CLONING).getFields()) {
                clinicalToBudgetCloneFieldSet.add(field.getFieldPath());
            }
            clinicalToBudgetCloneFieldSet.add(CON_CPQ.BID_HISTORY_OPPORTUNITY_ACCOUNT_ID);
            Bid_History__c clinicalBid = new SLT_Bid_History().getClinicalBidDetails(clinicalBidId, clinicalToBudgetCloneFieldSet);
            for (string fieldName: clinicalToBudgetCloneFieldSet) {
                if (fieldName != CON_CPQ.BID_HISTORY_OPPORTUNITY_ACCOUNT_ID && fieldName != CON_CPQ.NAME) {
                    clonedBudget.put(fieldName,clinicalBid.get(fieldName));
                }
            }
            clonedBudget.Apttus_Proposal__Account__c = clinicalBid.Bid_History_Related_Opportunity__r.AccountId;
        }    
        return clonedBudget;
    }
    
    public static Apttus_Proposal__Proposal__c cloneBudget(Id clinicalBidId, Id parentBudgetId, String pricingTool, String scenario, String budgetType, String parentScenario, String parentBudgetType) {
        Apttus_Proposal__Proposal__c clonedBudget = cloneClinical(clinicalBidId, pricingTool);
        clonedBudget.Apttus_Proposal__RelatedProposalId__c = parentBudgetId;
        Set<String> budgetToBudgetCloneFieldSet = new Set<String>();
        Boolean isScenarioPicklistChange = scenario != parentScenario;
        String childBudgetTypeToSearch = '%'+budgetType+'%';
        String parentBudgetTypeToSearch = '%'+parentBudgetType+'%';
        List<CPQ_Cloning_Field_Set__mdt> mappings = [SELECT Cloning_Fields__c FROM CPQ_Cloning_Field_Set__mdt WHERE Child_Budget_Type__c LIKE :childBudgetTypeToSearch AND Parent_Budget_Type__c  LIKE :parentBudgetTypeToSearch AND Is_Scenario_Picklist_Changed__c =: isScenarioPicklistChange];
        if(mappings.size() > 0 && mappings[0].Cloning_Fields__c != null){
            List<String> cloningFieldsList = mappings[0].Cloning_Fields__c.split(CON_CPQ.SEMICOLON);
            budgetToBudgetCloneFieldSet.addAll(cloningFieldsList);
        }
        budgetToBudgetCloneFieldSet.add(CON_CPQ.RELATED_AGREEMENT_STATUS_CATEGORY);
        List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getProposalsById(new Set<Id>{parentBudgetId}, budgetToBudgetCloneFieldSet);
        if(budgetList.size() > 0){
            Apttus_Proposal__Proposal__c parentBudget = budgetList.get(0);
            if (parentBudget.Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c != CON_CPQ.REQUEST &&
                parentBudget.Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c != CON_CPQ.CATEGORY_IN_BUDGETING &&
                parentBudget.Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c != CON_CPQ.IN_AUTHORING &&
                parentBudget.Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c != CON_CPQ.IN_APPROVAL &&
                parentBudget.Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c != CON_CPQ.IN_SIGNATURES &&
                childBudgetTypeToSearch != CON_CPQ.CHNAGE_ORDER) {
                    parentBudget.Apttus_QPComply__MasterAgreementId__c = null;
                    
                }
            budgetToBudgetCloneFieldSet.remove(CON_CPQ.RELATED_AGREEMENT_STATUS_CATEGORY);
            for (String fieldName : budgetToBudgetCloneFieldSet) {
                clonedBudget.put(fieldName, parentBudget.get(fieldName));
            }
        }
        return clonedBudget;
    }
    
    public static void markAsPrimary(Boolean markAsPrimary, Id oppId, Id budgetId) {
        Set<String> fieldSet = new Set<String>{
            CON_CPQ.ID,
            CON_CPQ.APTTUS_PROPOSAL_PRIMARY
        };
        Set<ID> opportunityIdSet = new Set<Id>();
        opportunityIdSet.add(oppId);
        String condition = 'Apttus_Proposal__Opportunity__c in :opportunityIdSet and Apttus_Proposal__Primary__c = true and Id != \'' + budgetId + '\'';
        List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getQuoteByRelatedOpportunity(opportunityIdSet, fieldSet, condition);
        if (proposalList.size() > 0) {
            for (Apttus_Proposal__Proposal__c proposal : proposalList) {
                proposal.Apttus_Proposal__Primary__c = false;
            } 
            update proposalList;
        }
    }

    public static void syncBudgetWithOpportunity(Id budgetId)
    {
        Set<Id> proposalIdSet = new Set<Id>{budgetId};
        Set<String> budgetLineItemFieldSet =  new Set<String> {CON_CPQ.ID,
            CON_CPQ.QUOTE_LINE_ITEM_PRODUCT, 
            CON_CPQ.BIDGRID_COUNTRY,
            CON_CPQ.IQVIA_LINE_TYPE,
            CON_CPQ.QUOTE_LINE_ITEM_NETPRICE,
            CON_CPQ.QUOTE_LINE_ITEM_QUANTITY , 
            CON_CPQ.QUOTE_LINE_ITEM_DESCRIPTION, 
            CON_CPQ.SALE_TYPE_FIELD, 
            CON_CPQ.REVENUE_TYPE_FIELD, 
            CON_CPQ.RELATED_BUDGET_BID_CURRENCY,
            CON_CPQ.RELATED_BUDGET_RELATED_OPPORTUNITY_CURRENCYISOCODE,
            CON_CPQ.RELATED_BUDGET_THERAPY_AREA,
            CON_CPQ.FIELD_RELATED_BUDGET_OPPORTUNITY,
            CON_CPQ.CLOSE_DATE,
            CON_CPQ.BILLING_SYSTEM
        };
        List<Apttus_Proposal__Proposal_Line_Item__c> budgetLineItemsList = new SLT_ProposalLineItems().selectByProposalIdsAndIQVIAType(
            new Set<Id>{budgetId}, budgetLineItemFieldSet, CON_CPQ.CRM_Product);
        if(budgetLineItemsList.size() > 0) {
            Set<Id> SAPOLIList = new Set<Id>();
            Set<Id> budgetLineItemIDs = new Set<Id>();
            Date oppCloseDate = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CloseDate;
            
            List<OpportunityLineItem> oppLineItemList = 
                new SLT_OpportunityLineItems().selectOLIByOpportunityId(new Set<ID>{budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c});
            Map<String, List<OpportunityLineItem>> product_countryToLineItemMap = new Map<String, List<OpportunityLineItem>>();
            for (OpportunityLineItem opportunityLineItem : oppLineItemList)
            {
                if (opportunityLineItem.Agreement_Line_Item_Id__c != null) {
                    if (opportunityLineItem.Billing_System__c == CON_CPQ.SAP) {
                        SAPOLIList.add(opportunityLineItem.Id);
                    }
                    if(product_countryToLineItemMap.containsKey(opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c)) {
                        List<OpportunityLineItem> oliList = product_countryToLineItemMap.get(opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c);
                        oliList.add(opportunityLineItem);
                        product_countryToLineItemMap.put(opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c, oliList);
                    }
                    else {
                        product_countryToLineItemMap.put(opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c, new List<OpportunityLineItem> {opportunityLineItem});
                    }
                }
            }
            
            String bidCurrency = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.CurrencyIsoCode;
            String oppCurrencyCode = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode;
            Map<String, CurrencyType> isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getSelectedCurrencyTypeByIsoCode(new Set<String>{bidCurrency,oppCurrencyCode});
            
            Set<Id> productIdSet = new Set<Id>();
            
            for (Apttus_Proposal__Proposal_Line_Item__c budgetLineItem : budgetLineItemsList)
            {
                productIdSet.add(budgetLineItem.Apttus_Proposal__Product__c);
            }
    
            if (productIdSet.size() > 0)
            {
                Set<String> priceBookFieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.ISACTIVE};           
                List<PriceBook2> standardPriceBook = new SLT_PriceBook2().getStandardPriceBook(priceBookFieldSet);
                if (standardPriceBook.size() > 0)
                {
                    Map<String, Id> productToPriceBook = new Map<String, Id>();
                    Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.ISACTIVE, CON_CPQ.CURRENCYISOCODE, CON_CPQ.PRODUCTID};
                    List<PriceBookEntry> priceBookEntryList = new SLT_PriceBookEntry().getStandardPriceBookByName(fieldSet, 
                        productIdSet, standardPriceBook[0].Id, new List<String>{oppCurrencyCode});
                    for (PricebookEntry priceBookEntry : priceBookEntryList) {
                        if (priceBookEntry.IsActive == true)
	                        productToPriceBook.put(priceBookEntry.Product2Id + priceBookEntry.CurrencyIsoCode, priceBookEntry.Id);
                    }
                    List<OpportunityLineItemSchedule> exisitngLineItemSchedule = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(SAPOLIList, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITYLINEITEMID});
                    Map<Id, List<OpportunityLineItemSchedule>> OLIScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
                    for (OpportunityLineItemSchedule oli : exisitngLineItemSchedule) {
                        if (!OLIScheduleMap.containskey(oli.OpportunityLineItemId)) {
                            OLIScheduleMap.put(oli.OpportunityLineItemId, new List<OpportunityLineItemSchedule> {oli});
                        } else {
                            List<OpportunityLineItemSchedule> oliList = OLIScheduleMap.get(oli.OpportunityLineItemId);
                            oliList.add(oli);
                            OLIScheduleMap.put(oli.OpportunityLineItemId, oliList);
                        }
                    }
                    Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
                    
                    List<OpportunityLineItem> opportunityLinetemList = new List<OpportunityLineItem>();
                    Set<Id> oppProductIds = new Set<Id>();														  
                    for(Apttus_Proposal__Proposal_Line_Item__c budgetLineItem : budgetLineItemsList)
                    {
                        ID productId = budgetLineItem.Apttus_Proposal__Product__c;
                        if (product_countryToLineItemMap != null && productId != null && product_countryToLineItemMap.containskey(productId + '&&' + budgetLineItem.BIDGRID_COUNTRY__C)){
                            List<OpportunityLineItem> lineItemList = product_countryToLineItemMap.get(productId + '&&' + budgetLineItem.BIDGRID_COUNTRY__C);
							OpportunityLineItem oppLineItem = lineItemList[0];
                            oppLineItem.UnitPrice = CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(oppCurrencyCode).conversionRate, 
                                    isoCodeTocurrencyTypeMap.get(bidCurrency).conversionRate, (double)budgetLineItem.Apttus_QPConfig__NetPrice__c);
                            oppLineItem.Quantity = budgetLineItem.Apttus_Proposal__Quantity__c;
                            oppLineItem.Description = budgetLineItem.Apttus_Proposal__Description__c;
                            oppLineItem.Delivery_Country__c = budgetLineItem.BIDGRID_COUNTRY__C;
                            oppLineItem.Sale_Type__c = budgetLineItem.Sale_Type__c;
                            oppLineItem.Revenue_Type__c = budgetLineItem.Revenue_Type__c;
                            oppLineItem.Therapy_Area__c = budgetLineItem.Apttus_Proposal__Proposal__r.Therapy_Area__c;
                            oppLineItem.Agreement_Line_Item_Id__c = budgetLineItem.Id;
                            opportunityLinetemList.add(oppLineItem);
                            oppProductIds.add(oppLineItem.Id);
                            if (SAPOLIList.Size()>0 && SAPOLIList.contains(oppLineItem.Id) ) {
                                if(OLIScheduleMap!= null && OLIScheduleMap.Size() >0 && OLIScheduleMap.containsKey(oppLineItem.Id)){
                                    List<OpportunityLineItemSchedule> oliSchList = OLIScheduleMap.get(oppLineItem.Id);
                                    Integer numberOfInstallment = oliSchList.size();
                                    Decimal price = oppLineItem.UnitPrice;
                                    Decimal amount = Math.floor(price/numberOfInstallment);
                                    Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                                    for(integer index = 0; index < numberOfInstallment; index++) {
                                        oliSchList[index].Revenue = amount;
                                    }
                                    oliSchList[numberOfInstallment - 1].Revenue = price - sumOfAmount;
                                    lineItemScheduleMap.put(oppLineItem.Id, oliSchList);
                                }
                            } 
                            lineItemList.remove(0);
                            if(lineItemList.size() > 0 ) {
                                product_countryToLineItemMap.put(productId + '&&' + budgetLineItem.BIDGRID_COUNTRY__C, lineItemList);
                            }
                            else {
                                product_countryToLineItemMap.remove(productId + '&&' + budgetLineItem.BIDGRID_COUNTRY__C);
                            }
                        }
                        else if (productId != null 
                           && productIdSet.contains(productId) 
                           && productToPriceBook.containsKey(productId + oppCurrencyCode))
                        {
                            Id priceBookEntryId = productToPriceBook.get(productId + oppCurrencyCode);
                            OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c,
                                priceBookEntryId =  priceBookEntryId, 
                                Product2Id =  productId,
                                UnitPrice = CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(oppCurrencyCode).conversionRate, 
                                    isoCodeTocurrencyTypeMap.get(bidCurrency).conversionRate, (double)budgetLineItem.Apttus_QPConfig__NetPrice__c),
                                Quantity = budgetLineItem.Apttus_Proposal__Quantity__c, 
                                Description = budgetLineItem.Apttus_Proposal__Description__c,
                                Delivery_Country__c = budgetLineItem.BIDGRID_COUNTRY__C,
                                Sale_Type__c = budgetLineItem.Sale_Type__c, 
                                Revenue_Type__c = budgetLineItem.Revenue_Type__c,
                                Therapy_Area__c = budgetLineItem.Apttus_Proposal__Proposal__r.Therapy_Area__c,
                                Agreement_Line_Item_Id__c = budgetLineItem.Id);
                            opportunityLinetemList.add(oppLineItem);
                            
                            if (budgetLineItem.Apttus_Proposal__Product__r.Billing_System__c == CON_CPQ.SAP) {
                                budgetLineItemIDs.add(budgetLineItem.Id);
                            }
                        }
                    }
                    if (oppProductIds.size() > 0) {
                        List<OpportunityLineItem> opportunityLinetemListToDelete = new List<OpportunityLineItem>();
                        for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
                            
                            if (!oppProductIds.contains(opportunityLineItem.Id)) {
                                opportunityLinetemListToDelete.add(opportunityLineItem);
                            }
                        }
                        
                        if (opportunityLinetemListToDelete.size() > 0) {
                            delete opportunityLinetemListToDelete;
                        }
                    } else {
                        delete oppLineItemList;
                    }
                    
                    if (opportunityLinetemList.size() > 0) {
                        upsert opportunityLinetemList;
                    }
                    
                    // Insert Revenue schedules first time when OLI gets created
                    CPQ_Settings__c cpqSetting = CPQ_Settings__c.getOrgDefaults();
                    for (OpportunityLineItem oppLineItem :opportunityLinetemList) {
                        
                        if  (!OLIScheduleMap.containskey(oppLineItem.ID) && (budgetLineItemIDs.contains(oppLineItem.Agreement_Line_Item_Id__c))) {
                            List<OpportunityLineItemSchedule> oliSchList = new List<OpportunityLineItemSchedule>();
                            Integer numberOfInstallment = (Integer)cpqSetting.No_of_Installment_for_Schedule_Creation__c;
                            Decimal price = oppLineItem.UnitPrice;
                            Decimal amount = Math.floor(price/numberOfInstallment);
                            Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                            Date revenueDate = oppCloseDate;
                            for (integer index = 0; index < numberOfInstallment - 1; index++) {
                                OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = amount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                                revenueDate = revenueDate.addMonths(1);
                                prepareMapForOlis(lineItemScheduleMap, oliSchedule);
                            }
                            OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price - sumOfAmount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                            prepareMapForOlis(lineItemScheduleMap, oliSchedule);
                        }
                    }
                    if (lineItemScheduleMap.size() > 0) {
                        if(!test.isRunningTest()) {
                            QUE_CPQ_TimeDelayForSchedule scheduleUpdate = new QUE_CPQ_TimeDelayForSchedule(lineItemScheduleMap, budgetId); 
                            Id jobId = System.enqueueJob(scheduleUpdate);
                        }
                    }
                    else {
                        update new Apttus_Proposal__Proposal__c(Id = budgetId,Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = '');
                    }
                }
            }
        }
    }

    public static void syncProtocolNumberOnOpp(Set<Id> quoteIdSet) {
        List<Opportunity> listOfOppToBeUpdate = new List<Opportunity>();
        Set<Id> oppIdSet = new Set<Id>();
        String condition = 'Id IN :quoteIdSet AND Record_Type_Developer_Name__c = \'RDS_Budget\'';
        try {
            for (Apttus_Proposal__Proposal__c proposal : new SLT_Proposal().getProposalByQuoteIds(new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.APTTUS_PROPOSAL_OPPORTUNITY, CON_CPQ.APPROVAL_STAGE, CON_CPQ.PROTOCOL_NUMBER, 'Apttus_Proposal__Opportunity__r.Protocol_Number__c'}, condition, quoteIdSet)) {
                if (String.isBlank(proposal.Apttus_Proposal__Opportunity__r.Protocol_Number__c) && String.isNotBlank(proposal.Protocol_Number__c)) {
                    Opportunity opp = new Opportunity();
                    opp.Id = proposal.Apttus_Proposal__Opportunity__c;
                    opp.Protocol_Number__c = proposal.Protocol_Number__c;
                    listOfOppToBeUpdate.add(opp);
                    oppIdSet.add(opp.Id); 
                }
            }
            if (listOfOppToBeUpdate.size() > 0) {
                UTL_ExecutionControl.stopTriggerExecution = true;
                update listOfOppToBeUpdate;
                System.enqueueJob(new CNT_RFP_UnityFlag_Queuable(CON_CBEx.OPPORTUNITY_OBJECT, new List<Id>(oppIdSet)));
                UTL_ExecutionControl.stopTriggerExecution = false;
            }
        } catch(Exception e) {
            throw new CPQ_CustomException(e.getMessage());
        }
    }
    private static void prepareMapForOlis(Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleMap, OpportunityLineItemSchedule oliSchedule){
        List<OpportunityLineItemSchedule> tempOlisList = lineItemScheduleMap.get(oliSchedule.OpportunityLineItemId);
        if(tempOlisList == null){
            tempOlisList = new List<OpportunityLineItemSchedule>();
            lineItemScheduleMap.put(oliSchedule.OpportunityLineItemId, tempOlisList);
        }
        tempOlisList.add(oliSchedule);
    }
    
    public static void deleteQuoteLineItems(Id quoteID) {
        delete new SLT_ProposalLineItems().selectByQuoteId(quoteID);
    }
	
    public static String getPDLocation(Id ownerId) {
        List<User> userList = new SLT_User().selectActiveUserByUserId(new Set<Id> {ownerId}, new Set<string> {CON_CPQ.ID, CON_CPQ.Name, CON_CPQ.REGION});
        if (userList.size() > 0)
            return userList[0].Region__c;
        else
            return null;       
    }
	
    @testVisible
    private static String getTotalIQVIAFeesCDSRange(Decimal totalIQVIAFeesCDS, String isThisIQB) {
        String totalIQVIAFeesCDSRange;
        if(isThisIQB == CON_CPQ.YES_TITLE_CASE) { 
            if(totalIQVIAFeesCDS <= 3000000 || totalIQVIAFeesCDS == NULL) {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_0TO3;
            } else {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_3;
            } 
        }
        else {
            if(totalIQVIAFeesCDS <= 3000000 || totalIQVIAFeesCDS == NULL) {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_0TO3;
            } else if(totalIQVIAFeesCDS > 3000000 && totalIQVIAFeesCDS <= 5000000) {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_3TO5;
            } else if(totalIQVIAFeesCDS > 5000000 && totalIQVIAFeesCDS <= 10000000) {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_5TO10;
            } else if(totalIQVIAFeesCDS > 10000000 && totalIQVIAFeesCDS <= 20000000) {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_10TO20;
            } else if(totalIQVIAFeesCDS > 20000000 && totalIQVIAFeesCDS <= 25000000) {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_20TO25;
            } else if(totalIQVIAFeesCDS > 25000000 && totalIQVIAFeesCDS <= 50000000) {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_25TO50;
            } else {
                totalIQVIAFeesCDSRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_50;
            }
        }
        return totalIQVIAFeesCDSRange;
    }
    
    @testVisible
    private static String getTotalIQVIAFeesRange(String oppType, String accountCountry, String potentialRegion, Decimal winProbability, Decimal totalIQVIAFeesCDS, String isThisIQB) {
        String totalIQVIAFeesRange;
        String winProbabilityValue = CPQ_Utility.getWinProbabilityRange(winProbability, isThisIQB);
        String potentialRegionValue = CPQ_Utility.getdeliveryPotentialRegion(accountCountry, potentialRegion, isThisIQB);
        if (isThisIQB == CON_CPQ.NO_TITLE_CASE) {
            if (oppType == CON_CPQ.OPPORTUNITY_TYPE_LIMITED_SERVICE_RFP || oppType == CON_CPQ.OPPORTUNITY_TYPE_FULL_SERVICE_RFP || oppType == CON_CPQ.OPPORTUNITY_TYPE_PROGRAM_STRATEGIC_PARTNERSHIP || oppType == CON_CPQ.OPPORTUNITY_TYPE_FSP) {
                if(potentialRegionValue == CON_CPQ.REGION_EMEA_EMEA && winProbabilityValue == CON_CPQ.WIN_PROBABILITY_0 && totalIQVIAFeesCDS >= 5000000) {
                    totalIQVIAFeesRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_5;
                } else if((potentialRegionValue == CON_CPQ.REGION_ASIA_PASIFIC || potentialRegionValue == CON_CPQ.JAPAN) && winProbabilityValue == CON_CPQ.WIN_PROBABILITY_50 && totalIQVIAFeesCDS >= 3000000) {
                    totalIQVIAFeesRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_3;
                } else if((potentialRegionValue == CON_CPQ.REGION_ASIA_PASIFIC || potentialRegionValue == CON_CPQ.JAPAN) && winProbabilityValue == CON_CPQ.WIN_PROBABILITY_1TO49 && totalIQVIAFeesCDS >= 5000000) {
                    totalIQVIAFeesRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_5;
                } else {
                    return totalIQVIAFeesRange;
                }
            }
            if (oppType == CON_CPQ.OPPORTUNITY_TYPE_PRICE_PER_PT || oppType == CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK || oppType == CON_CPQ.OPPORTUNITY_TYPE_BALLPARK_REQUIRING_IQVIA_DEFINED_CSP_STRATEGY) {
                if(potentialRegionValue == CON_CPQ.REGION_EMEA_EMEA && winProbabilityValue == CON_CPQ.WIN_PROBABILITY_0 && totalIQVIAFeesCDS >= 10000000) {
                    totalIQVIAFeesRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_10;
                } else if((potentialRegionValue == CON_CPQ.REGION_ASIA_PASIFIC || potentialRegionValue == CON_CPQ.JAPAN) && winProbabilityValue == CON_CPQ.WIN_PROBABILITY_0 && totalIQVIAFeesCDS >= 7000000) {
                    totalIQVIAFeesRange = CON_CPQ.TOTAL_IQVIA_FEES_CDS_7;
                } else {
                    return totalIQVIAFeesRange;
                } 
            }
        }
        return totalIQVIAFeesRange;
    }
     
    
    @testVisible
    private static String getWinProbabilityRange(Decimal winProbability, String isThisIQB) {
        String winProbabilityRange;
        if (isThisIQB == CON_CPQ.NO_TITLE_CASE) {
            if (winProbability == 0) {
               winProbabilityRange = CON_CPQ.WIN_PROBABILITY_0; 
            } else if (winProbability > 1 && winProbability <= 49){
                winProbabilityRange = CON_CPQ.WIN_PROBABILITY_1TO49;
            } else {
                winProbabilityRange = CON_CPQ.WIN_PROBABILITY_50;
            }
        }
        return winProbabilityRange;
    }
    
    @testVisible
    private static String getdeliveryPotentialRegion(String accountCountry, String potentialRegion, String isThisIQB) {
        String deliveryPotentialRegion;
        if (isThisIQB == CON_CPQ.NO_TITLE_CASE) {
            Map<String,IQVIA_Account_Country_Region_Mapping__mdt> accountCountryRegionMap = new Map<String,IQVIA_Account_Country_Region_Mapping__mdt>();
            accountCountryRegionMap = new SLT_IQVIAAccountCountryRegionMapping().getaccountCountryToRegionMetadataMap();
            if(!String.isBlank(accountCountry) && accountCountryRegionMap.containsKey(accountCountry)) {
                if ( potentialRegion.contains(accountCountryRegionMap.get(accountCountry).Potential_Region__c)) {
                    deliveryPotentialRegion = accountCountryRegionMap.get(accountCountry).Potential_Region__c;
                }
            }
        }
        return deliveryPotentialRegion;
    }
    
    public static String getChallengeMatrixAction(Id ownerId, Decimal totalIqviaFeeCDS, String oppType, String status, String isThisIQB, Decimal winProbability, String accountCountry, String potentialRegion) {
        String totalIQVIAFeesCDS = '';
        String winProbabilityRange = '';
        String deliveryPotentialRegion = '';
        List<Challenge_Matrix__c> challengeMatrix = new List<Challenge_Matrix__c>();
        if(status == CON_CPQ.FINAL_SIGN_OFF) {
            totalIQVIAFeesCDS = getTotalIQVIAFeesCDSRange(totalIqviaFeeCDS, isThisIQB);
            challengeMatrix = new SLT_ChallangeMatrix().selectChallangeMatrixCondition(totalIQVIAFeesCDS, oppType, CON_CPQ.REVIEW_TYPE_SIGNOFF, isThisIQB);
        } 
        else {
            if (isThisIQB == CON_CPQ.YES) {
                totalIQVIAFeesCDS = getTotalIQVIAFeesCDSRange(totalIqviaFeeCDS, isThisIQB);
                challengeMatrix = new SLT_ChallangeMatrix().selectChallangeMatrixCondition(totalIQVIAFeesCDS, oppType, CON_CPQ.REVIEW_TYPE_CHALLENGE, isThisIQB);
            } else {
                totalIQVIAFeesCDS = getTotalIQVIAFeesRange(oppType, accountCountry, potentialRegion, winProbability, totalIqviaFeeCDS, isThisIQB);
                winProbabilityRange = getWinProbabilityRange(winProbability, isThisIQB);
                deliveryPotentialRegion = getdeliveryPotentialRegion (accountCountry, potentialRegion, isThisIQB);
                challengeMatrix = new SLT_ChallangeMatrix().selectChallangeMatrixConditionChallenge(totalIQVIAFeesCDS, oppType, CON_CPQ.REVIEW_TYPE_CHALLENGE, isThisIQB, winProbabilityRange, deliveryPotentialRegion);
            } 
        }
        if(challengeMatrix.size() > 0) {
            if(challengeMatrix[0].Action__c == CON_CPQ.PD_LOCATION_CHECK){
                String pDLocation = getPDLocation(ownerId);
                if (pDLocation != '' && pDLocation != null) {
                    if(pDLocation == CON_CPQ.REGION_EMEA){
                        return CON_CPQ.CALL;                    
                    } else {
                        return CON_CPQ.EMAIL;
                    }
                }
                else 
                    return null;
            } else {
                return challengeMatrix[0].Action__c;
            }
        }
        return null;
    }
    
    public static void createProposalTeamMemberRecord(List<Apttus_Proposal__Proposal__c> budgets, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
        Set<Id> clinicalBidIds = new Set<Id>();
        Set<String> budgetTypes = new Set<String>();
        Set<String> budgetTools = new Set<String>();
        Set<String> rrRoles = new Set<String>();
        List<Apttus_Proposal__Proposal__c> filteredBudgets = new List<Apttus_Proposal__Proposal__c>();
        for (Apttus_Proposal__Proposal__c budget : budgets) {
            if (CPQ_Utility.proposalBudgetRecordTypeId == budget.RecordTypeId && budget.Clinical_Bid__c != null && 
                (oldMap == null && budget.Apttus_Proposal__Proposal_Category__c != null)) {
                    clinicalBidIds.add(budget.Clinical_Bid__c);
                    filteredBudgets.add(budget);
                    budgetTypes.add(budget.Apttus_Proposal__Proposal_Category__c);
                    budgetTools.add(budget.Select_Pricing_Tool__c);
                }
        }
        
        List<Proposal_Team_Member_and_RR_Mapping__mdt> mappings = [SELECT Budget_Tool__c, Budget_Type__c, RR_Subgroups__c, Team_Member_Role__c 
                FROM Proposal_Team_Member_and_RR_Mapping__mdt WHERE Budget_Tool__c IN : budgetTools AND Budget_Type__c IN : budgetTypes];
        Map<String, List<MappingWrapper>> mappingMap = new Map<String, List<MappingWrapper>>();
        MappingWrapper mappingObj;
        String key;
        for (Proposal_Team_Member_and_RR_Mapping__mdt mapping : mappings) {
            key = mapping.Budget_Tool__c +'&&&'+ mapping.Budget_Type__c;
            mappingObj = new MappingWrapper();
            mappingObj.role = mapping.Team_Member_Role__c;
            mappingObj.rrGroups = mapping.RR_Subgroups__c.split(CON_CPQ.SEMICOLON);
            rrRoles.addAll(mapping.RR_Subgroups__c.split(CON_CPQ.SEMICOLON));
            if (mappingMap.containsKey(key)) {
                List<MappingWrapper> listOfMappings = mappingMap.get(key);
                listOfMappings.add(mappingObj);
                mappingMap.put(key, listOfMappings);
            } else {
                mappingMap.put(key, new List<MappingWrapper> {mappingObj});
            }
        }
       
        List<pse__Assignment__c> assignmentList = new SLT_Assignment().getAssignmentByAgreementRecordTypeAndStatus(clinicalBidIds, CON_CPQ.ACCEPTED, CON_CPQ.OWF_ASSIGNMENT, rrRoles);
        Map<Id,Map<String,List<pse__Assignment__c>>> mapOfAssignmentsByAutomaticAndClinicalBid = new Map<Id,Map<String,List<pse__Assignment__c>>>();
        
        for (pse__Assignment__c assignment : assignmentList) {
            if (!mapOfAssignmentsByAutomaticAndClinicalBid.containsKey(assignment.Bid_History__c)) {
                if (assignment.Pse__Resource_Request__r.Is_Created_Automatically__c) {
                    mapOfAssignmentsByAutomaticAndClinicalBid.put(assignment.Bid_History__c, 
                        new Map<String,List<pse__Assignment__c>> {CON_CPQ.AUTOMATIC => new List<pse__Assignment__c> {assignment}});
                } else {
                    mapOfAssignmentsByAutomaticAndClinicalBid.put(assignment.Bid_History__c, 
                        new Map<String,List<pse__Assignment__c>> {CON_CPQ.MANUAL => new List<pse__Assignment__c> {assignment}});
                }
            }
            else {
                Map<String,List<pse__Assignment__c>>  mapOfAssignmentsByAutomaticOrManual = mapOfAssignmentsByAutomaticAndClinicalBid.get(assignment.Bid_History__c);
                if (assignment.Pse__Resource_Request__r.Is_Created_Automatically__c) {
                    if (mapOfAssignmentsByAutomaticOrManual.containsKey(CON_CPQ.AUTOMATIC)) {
                        List<pse__Assignment__c>  listOfAssignments = mapOfAssignmentsByAutomaticOrManual.get(CON_CPQ.AUTOMATIC);
                        listOfAssignments.add(assignment);
                        mapOfAssignmentsByAutomaticOrManual.put(CON_CPQ.AUTOMATIC, listOfAssignments);                        
                    } else {
                        mapOfAssignmentsByAutomaticOrManual.put(CON_CPQ.MANUAL, new List<pse__Assignment__c> {assignment});                        
                    }
                }
                else {
                    if (mapOfAssignmentsByAutomaticOrManual.containsKey(CON_CPQ.MANUAL)) {
                        List<pse__Assignment__c>  listOfAssignments = mapOfAssignmentsByAutomaticOrManual.get(CON_CPQ.MANUAL);
                        listOfAssignments.add(assignment);
                        mapOfAssignmentsByAutomaticOrManual.put(CON_CPQ.MANUAL,listOfAssignments);
                    } else {
                        mapOfAssignmentsByAutomaticOrManual.put(CON_CPQ.MANUAL, new List<pse__Assignment__c> {assignment});                        
                    }
                }
                mapOfAssignmentsByAutomaticAndClinicalBid.put(assignment.Bid_History__c, mapOfAssignmentsByAutomaticOrManual);
            }
        }
        
        List<Team_Member__c> teamMembersToInsertList  = new List<Team_Member__c>();
        for (Apttus_Proposal__Proposal__c budget : filteredBudgets) {
            List<MappingWrapper> listOfMappings = mappingMap.get(budget.Select_Pricing_Tool__c +'&&&'+ budget.Apttus_Proposal__Proposal_Category__c);
            
            if (mapOfAssignmentsByAutomaticAndClinicalBid.size() > 0 && (!(listOfMappings == null || listOfMappings.isEmpty()))) {                
                for (MappingWrapper mapping : listOfMappings) {
                    teamMemberRecordForSubgroup = new List<String>();
                    List<String> lstMappingSubGroup = mapping.rrGroups;
                    if (mapOfAssignmentsByAutomaticAndClinicalBid.get(budget.Clinical_Bid__c).containsKey(CON_CPQ.Automatic)) {
                        List<pse__Assignment__c> assignments = mapOfAssignmentsByAutomaticAndClinicalBid.get(budget.Clinical_Bid__c).get(CON_CPQ.Automatic);
                        teamMembersToInsertList.addAll(createTeamMemberRecord(assignments, lstMappingSubGroup, mapping.role, budget.Id));
                    }
                    if (mapOfAssignmentsByAutomaticAndClinicalBid.get(budget.Clinical_Bid__c).containsKey(CON_CPQ.MANUAL)){
                      	List<pse__Assignment__c> assignments = mapOfAssignmentsByAutomaticAndClinicalBid.get(budget.Clinical_Bid__c).get(CON_CPQ.MANUAL);
                        teamMembersToInsertList.addAll(createTeamMemberRecord(assignments, lstMappingSubGroup, mapping.role, budget.Id));
                    }
                }
            }
        }
        if (teamMembersToInsertList.size() > 0) {
            try {
                insert teamMembersToInsertList; 
            }
            catch (DmlException ex) {
                String errorMessage = ex.getDmlMessage(0) + '\n' + ex.getStackTraceString();
                throw new AuraHandledException('Error Exception happend' + ex.getDmlMessage(0));
            }
        }
    }
    private static List<String> teamMemberRecordForSubgroup;
    private static List<Team_Member__c> createTeamMemberRecord(List<pse__Assignment__c> assignments, List<String> lstMappingSubGroup, String role, Id budgetId) {
        List<Team_Member__c> teamMembersToInsertList = new List<Team_Member__c>();
        
        for (String mappingSubGroup : lstMappingSubGroup) {
            for (pse__Assignment__c assignment : assignments) {
                String mappingGroup;
                if (mappingSubGroup == CON_CPQ.TSL_JAPAN) {
                    mappingGroup = mappingSubGroup.substringBefore(CON_CPQ.HYPHEN);
                }
                else {
                    mappingGroup = mappingSubGroup;
                }
                if (assignment.pse__Resource_Request__r.SubGroup__c == mappingSubGroup && (teamMemberRecordForSubgroup.isEmpty() || (!teamMemberRecordForSubgroup.contains(mappingGroup)))) {
                    Team_Member__c teamMember = new Team_Member__c(Member_Role__c = role, 
                                                                   User__c = assignment.pse__Resource__r.pse__Salesforce_User__c, Proposal__c = budgetId, Role_from_RR__c = assignment.pse__Resource_Request__r.SubGroup__c);
                    teamMembersToInsertList.add(teamMember);
                    //Condition modified under LC-10187 to remove ref of Reviewer/Final Reviewer picklist value from Team Member object
                    if (/*role != CON_CPQ.QC_REVIEWER && role != CON_CPQ.FINAL_QC_REVIEWER &&*/ role != CON_CPQ.FUNCTIONAL_REVIEWER)
                        teamMemberRecordForSubgroup.add(mappingGroup);
                }
            }
        }
        
        return teamMembersToInsertList;
    }

    @future
    public static void syncOpportunityProductsIntoCartLineItems(String proposal) {
        Apttus_Proposal__Proposal__c newBudget = (Apttus_Proposal__Proposal__c)JSON.deserialize(proposal,Apttus_Proposal__Proposal__c.class);
        List<Apttus_Config2__ProductConfiguration__c> cartsToAdd = new List<Apttus_Config2__ProductConfiguration__c>();
        String cartId;
        Set<Id> tsJPProductSet = new Set<Id>();
        List<Apttus_Config2__PriceListItem__c > priceListItem = [SELECT ID, Apttus_Config2__ProductId__c, Apttus_Config2__ProductCode__c FROM Apttus_Config2__PriceListItem__c WHERE Apttus_Config2__PriceListId__r.Name =: 'Tech Solution Japan' AND Apttus_Config2__Active__c =: true];
        for (Apttus_Config2__PriceListItem__c priceList : priceListItem ) {
            tsJPProductSet.add(priceList.Apttus_Config2__ProductId__c);
        }
        
        // For Cloned Proposal, Configuration and Line Item should not be created (cloned proposal should have value populated in Related Quote/Proposal field)
        if(newBudget.Apttus_QPConfig__PriceListId__c != null && newBudget.Apttus_Proposal__RelatedProposalId__c == null){
            
            Map<Id, OpportunityLineItem> opportunityLineItemMap = 
                new SLT_OpportunityLineItems().selectByOpportunityId(
                    new Set<Id>{newBudget.Apttus_Proposal__Opportunity__c}, 
                    new Set<String> {CON_CPQ.PRODUCTID, CON_CPQ.QUANTITY}
                );
            
            // If Opportunity products are attached to Opportunity then only create cart line items
            if(opportunityLineItemMap.size() > 0){
                
                //Step 1: Create new Configuration record
                Apttus_CPQApi.CPQ.CreateCartRequestDO request = new Apttus_CPQApi.CPQ.CreateCartRequestDO();
                request.QuoteId = newBudget.Id;
                Apttus_CPQApi.CPQ.CreateCartResponseDO response = Apttus_CPQApi.CPQWebService.createCart(request);
                
                // Retrieve Configuration Id and Status from Configuration record (created from above API)
                List<Apttus_Config2__ProductConfiguration__c> carts = 
                    new SLT_ProductConfiguration().selectFieldSetById(
                        new Set<Id>{response.CartId}, 
                        new Set<String> {CON_CPQ.ID, CON_CPQ.PRODUCT_CONFIG_STATUS}
                    );
                
                if(carts.size() > 0) {
                    
                    cartId = carts[0].Id;
                    
                    //Step 2: Add Opportunity Product to Cart Line Item
                    List <Apttus_CPQApi.CPQ.SelectedProductDO> selectedProdDOList = new List<Apttus_CPQApi.CPQ.SelectedProductDO>();
                    for(OpportunityLineItem oppProduct : opportunityLineItemMap.values()){
                        if (tsJPProductSet.contains(oppProduct.Product2Id)) {
                            Apttus_CPQApi.CPQ.SelectedProductDO selProdDO = new Apttus_CPQApi.CPQ.SelectedProductDO();
                            selProdDO.ProductID = oppProduct.Product2Id;
                            selProdDO.Quantity = oppProduct.Quantity;
                            selProdDO.StartDate = newBudget.Apttus_Proposal__ExpectedStartDate__c;
                            selProdDO.EndDate = newBudget.Apttus_Proposal__ExpectedEndDate__c;
                            selectedProdDOList.add(selProdDO);
                        }
                    }
                
                if(selectedProdDOList.size() > 0){
                    Apttus_CPQApi.CPQ.AddMultiProductRequestDO multiProductRequest = new Apttus_CPQApi.CPQ.AddMultiProductRequestDO ();
                    multiProductRequest.CartId = cartId;
                    multiProductRequest.SelectedProducts = selectedProdDOList;
                    Apttus_CPQApi.CPQ.AddMultiProductResponseDO response1 = Apttus_CPQApi.CPQWebService.addMultiProducts(multiProductRequest);
                }  
                    
                    //Step 3: Validate cart
                    Apttus_Config2.CPQWebService.validateCart(cartId); 
                    
                    //Step 4: Apply Pricing
                    Apttus_CpqApi.CPQ.UpdatePriceRequestDO objUpdatePriceRequestDO = new Apttus_CpqApi.CPQ.UpdatePriceRequestDO();
                    objUpdatePriceRequestDO.CartId = cartId;
                    Apttus_CpqApi.CPQ.UpdatePriceResponseDO result = Apttus_CpqApi.CPQWebService.updatePriceForCart(objUpdatePriceRequestDO);
                    
                    //Steps 5. Save Cart
                    carts[0].Apttus_Config2__Status__c = CON_CPQ.PRODUCT_CONFIG_STATUS_SAVED;
                    cartsToAdd.add(carts[0]);
                }
            }
        }
        
        if(cartsToAdd.size() > 0){
            update cartsToAdd;
            
            // Update Adjustment Type as "Price Override" default value for all Cart line items
            List<Apttus_Config2__LineItem__c> cartLineItems = new SLT_LineItem().selectByProductConfigId(
                new Set<Id>{cartId},
                new Set<String>{CON_CPQ.LINE_ITEM_ADJUSTMENT_TYPE}
            );
            for(Apttus_Config2__LineItem__c lineItem : cartLineItems){
                lineItem.Apttus_Config2__AdjustmentType__c = CON_CPQ.PRICE_OVERRIDE;
            }
            update cartLineItems;
        }
    }
    
    public class MappingWrapper {
        public String role;
        public List<String> rrGroups;
    }
	
    
    public static void syncBudgetWithOpportunityDynamically(Id budgetId, String tool) {
	    List<String> listOfAttributeNames = new List<String>();
        CPQ_Opp_Sync_Attribute__mdt attMetadata = [SELECT Attribute_List__c, Country__c, Pricing_Tool__c FROM CPQ_Opp_Sync_Attribute__mdt WHERE Pricing_Tool__c =: tool];
        String deliveryCountryAtt = attMetadata.Country__c;
        if (attMetadata.Attribute_List__c != null) {
            listOfAttributeNames = attMetadata.Attribute_List__c.split(CON_CPQ.SEMICOLON);
        }
        List<CPQ_Opp_Sync_Product_Mapping__mdt> productMappings = [SELECT Attribute_Value_1__c, 
            Attribute_Value_2__c, Attribute_Value_3__c, Attribute_Value_4__c, Attribute_Value_5__c, 
            Attribute_Value_6__c, Attribute_Value_7__c, Attribute_Value_8__c, Attribute_Value_9__c, 
            Attribute_Value_10__c, CPQ_Product_Code__c, CPQ_Product_Type__c, DeveloperName, Id, Language, 
            MDM_Product_Code__c, OLIS_Required__c, Product_Name__c, Product_Sync_Type__c, Pricing_Tool__c FROM CPQ_Opp_Sync_Product_Mapping__mdt WHERE Pricing_Tool__c = :tool];
        
        Map<String, Id> mdmCodeToProductIdMap = new Map<String, Id>();
        Map<Id, String> productIdToMDMCodeMap = new Map<Id, String>();
        Map<String, Product2> mdmProductDetailMap = new Map<String, Product2>();
        Map<String, String> productCodeToMDMCodeMappingMap = new Map<String, String>();
        Map<String, List<String>> mdmCodeToProductCodeMappingMap = new Map<String, List<String>>();
        Map<String, CPQ_Opp_Sync_Product_Mapping__mdt> mdmCodeToMetadataMap = new Map<String, CPQ_Opp_Sync_Product_Mapping__mdt>();
        Set<String> optionSet = new Set<String>();
        Set<String> bundleSet = new Set<String>();
        List<OpportunityLineItem> opportunityLinetemList = new List<OpportunityLineItem>();
        Set<Id> oppProductIds = new Set<Id>();	
        Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
        
        for (CPQ_Opp_Sync_Product_Mapping__mdt cospm : productMappings) {
            Integer noOfAttributes = listOfAttributeNames.size();
            String productCodeToMDMCodeMapKey = cospm.CPQ_Product_Code__c;
            if (noOfAttributes > 0) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_1__c;
            }
            if (noOfAttributes > 1) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_2__c;
            }
            if (noOfAttributes > 2) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_3__c;
            }
            if (noOfAttributes > 3) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_4__c;
            }
            if (noOfAttributes > 4) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_5__c;
            }
            productCodeToMDMCodeMappingMap.put(productCodeToMDMCodeMapKey, cospm.MDM_Product_Code__c);
            mdmCodeToMetadataMap.put(cospm.MDM_Product_Code__c, cospm);
            if (mdmCodeToProductCodeMappingMap.containsKey(cospm.MDM_Product_Code__c)) {
                List<String> productCodes = mdmCodeToProductCodeMappingMap.get(cospm.MDM_Product_Code__c);
                productCodes.add(cospm.CPQ_Product_Code__c);
                mdmCodeToProductCodeMappingMap.put(cospm.MDM_Product_Code__c, productCodes);
            } else {
                mdmCodeToProductCodeMappingMap.put(cospm.MDM_Product_Code__c, new List<String> {cospm.CPQ_Product_Code__c});
            }
            if (cospm.Product_Sync_Type__c == CON_CPQ.OPTION) {
                optionSet.add(cospm.CPQ_Product_Code__c);
            } else {
                bundleSet.add(cospm.CPQ_Product_Code__c);
            }
        }
        
        Set<String> budgetLineItemFieldSet =  new Set<String> {CON_CPQ.ID,
            CON_CPQ.RELATED_BUDGET_BID_CURRENCY,
            CON_CPQ.RELATED_BUDGET_RELATED_OPPORTUNITY_CURRENCYISOCODE,
            CON_CPQ.QUOTE_LINE_ITEM_NETPRICE,
            CON_CPQ.QUOTE_LINE_ITEM_PRODUCT,
            CON_CPQ.FIELD_RELATED_BUDGET_OPPORTUNITY,
            CON_CPQ.PROPOSAL_LINE_ITEM_START_DATE,
            CON_CPQ.PROPOSAL_LINE_ITEM_END_DATE,
            CON_CPQ.CLOSE_DATE,
            CON_CPQ.QUOTE_LINE_ITEM_DESCRIPTION,
            CON_CPQ.PLI_ATTRIBUTE_COUNTRY,
            CON_CPQ.PLI_PROPOSAL_DISCOUNT,
            CON_CPQ.PLI_OPTION_PRODUCTCODE,
            CON_CPQ.PLI_BUNDLE_PRODUCTCODE,
            CON_CPQ.RELATED_PROPOSAL_CONVERSION_DATE
        };
        Set<String> attributeFieldSet = new Set<String>();
        attributeFieldSet.addALL(listOfAttributeNames);
        if (!attributeFieldSet.contains(deliveryCountryAtt)) {
            attributeFieldSet.add(deliveryCountryAtt);
        }
        List<Apttus_Proposal__Proposal_Line_Item__c> budgetLineItemsList = new SLT_ProposalLineItems().getProposalLineItemsWithAttributesByQuoteId(new Set<Id>{budgetId}, budgetLineItemFieldSet, optionSet, bundleSet);
        Set<Id> attributeIds = new Set<Id>();
        for (Apttus_Proposal__Proposal_Line_Item__c budgetLineItem : budgetLineItemsList) {
            if (budgetLineItem.Apttus_QPConfig__AttributeValueId__c != null) {
                attributeIds.add(budgetLineItem.Apttus_QPConfig__AttributeValueId__c); 
            }
        }
        Map<Id, Apttus_QPConfig__ProposalProductAttributeValue__c> productAttributeMap = new SLT_ProposalProductAttributeValue().getProposalAttributeRecords(attributeIds, attributeFieldSet);
		
        fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus_Proposal__Proposal__c.SobjectType
            }
        );
        if (budgetLineItemsList.size() > 0) {
            //Decimal discount = (budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Discount_Percent__c != null ? budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Discount_Percent__c : 0)/100;
            String bidCurrency = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.CurrencyIsoCode;
            String oppCurrencyCode = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode;
            Date oppCloseDate = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__r.CloseDate;
            Id oppId = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c;
            Date conversionDate = budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Conversion_Date__c;
            Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap;
            Boolean isCurrencySame = true;
            if (bidCurrency != oppCurrencyCode) {
                isCurrencySame = false;
                isoCodeTocurrencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(new Set<String>{bidCurrency, oppCurrencyCode}, conversionDate);
            }
            
            for (Product2 p : [Select Id, ProductCode, IsActive From Product2 Where ProductCode IN :mdmCodeToProductCodeMappingMap.keySet()]) {
                mdmCodeToProductIdMap.put(p.ProductCode, p.Id);
                productIdToMDMCodeMap.put(p.Id, p.ProductCode);
                mdmProductDetailMap.put(p.ProductCode, p);
            }
            
            List<OpportunityLineItem> oppLineItemList = 
                new SLT_OpportunityLineItems().selectOLIByOpportunityId(new Set<ID>{budgetLineItemsList.get(0).Apttus_Proposal__Proposal__r.Apttus_Proposal__Opportunity__c});
            Map<String, List<OpportunityLineItem>> product_countryToLineItemMap = new Map<String, List<OpportunityLineItem>>();
            Set<Id> SAPOLIList = new Set<Id>();
			
            for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
                if (opportunityLineItem.Agreement_Line_Item_Id__c != null) {
                    if (opportunityLineItem.Billing_System__c == CON_CPQ.SAP) {
                        SAPOLIList.add(opportunityLineItem.Id);
                    }
                    String oliKey = opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c + '&&' + opportunityLineItem.Revenue_Start_Date__c + '&&' + opportunityLineItem.Revenue_End_Date__c;
                    if (product_countryToLineItemMap.containsKey(oliKey)) {
                        List<OpportunityLineItem> oliList = product_countryToLineItemMap.get(oliKey);
                        oliList.add(opportunityLineItem);
                        product_countryToLineItemMap.put(oliKey, oliList);
                    } else {
                        product_countryToLineItemMap.put(oliKey, new List<OpportunityLineItem> {opportunityLineItem});
                    }
                }
            }
            
            Set<String> priceBookFieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.ISACTIVE};           
            List<PriceBook2> standardPriceBook = new SLT_PriceBook2().getStandardPriceBook(priceBookFieldSet);
            Map<String, Id> productToPriceBook = new Map<String, Id>();
            Set<String> nonExistingMDMProducts = new Set<String>();
            Set<String> inactiveMDMProducts = new Set<String>();
            
            if (standardPriceBook.size() > 0) {
                Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.PRODUCTCODE, CON_CPQ.ISACTIVE, CON_CPQ.CURRENCYISOCODE, CON_CPQ.PRODUCTID};
                    List<PriceBookEntry> priceBookEntryList = new SLT_PriceBookEntry().getStandardPriceBookByName(fieldSet, productIdToMDMCodeMap.keySet(), standardPriceBook[0].Id, new List<String>{oppCurrencyCode});
                for (PricebookEntry priceBookEntry : priceBookEntryList) {
                    if (priceBookEntry.IsActive == true) {
                        productToPriceBook.put(priceBookEntry.ProductCode + priceBookEntry.CurrencyIsoCode, priceBookEntry.Id);
                    }
                }
            }
            
            List<OpportunityLineItemSchedule> exisitngLineItemSchedule = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(SAPOLIList, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITYLINEITEMID});
            Map<Id, List<OpportunityLineItemSchedule>> OLIScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
            for (OpportunityLineItemSchedule oli : exisitngLineItemSchedule) {
                if (!OLIScheduleMap.containskey(oli.OpportunityLineItemId)) {
                    OLIScheduleMap.put(oli.OpportunityLineItemId, new List<OpportunityLineItemSchedule> {oli});
                } else {
                    List<OpportunityLineItemSchedule> oliList = OLIScheduleMap.get(oli.OpportunityLineItemId);
                    oliList.add(oli);
                    OLIScheduleMap.put(oli.OpportunityLineItemId, oliList);
                }
            }
            Map<String, List<Apttus_Proposal__Proposal_Line_Item__c>> mergeBudgetLineItemMap = new Map<String, List<Apttus_Proposal__Proposal_Line_Item__c>>();
            for (Apttus_Proposal__Proposal_Line_Item__c budgetLineItem : budgetLineItemsList) {
                String mapKey = budgetLineItem.Apttus_QPConfig__OptionId__c != null ? budgetLineItem.Apttus_QPConfig__OptionId__r.ProductCode : budgetLineItem.Apttus_Proposal__Product__r.ProductCode;
                Apttus_QPConfig__ProposalProductAttributeValue__c propsalAttValue = (productAttributeMap.containsKey(budgetLineItem.Apttus_QPConfig__AttributeValueId__c) ? productAttributeMap.get(budgetLineItem.Apttus_QPConfig__AttributeValueId__c) : null);
                String country = '';
                if (propsalAttValue != null) {
                    for (String attributeFieldName : listOfAttributeNames) {
                        mapKey = mapKey + ':' + propsalAttValue.get(attributeFieldName);
                    }
                    country = (String)propsalAttValue.get(deliveryCountryAtt);
                }
                
                String  mdmProductCode = productCodeToMDMCodeMappingMap.get(mapKey);
                Product2 mdmProduct = mdmProductDetailMap.get(mdmProductCode);
                if(mdmProduct == null){
                    nonExistingMDMProducts.add(mdmProductCode);
                } else if(!mdmProduct.IsActive) {
                    inactiveMDMProducts.add(mdmProductCode);
                }
                Date startDate;
                Date endDate;
                if (budgetLineItem.Apttus_QPConfig__StartDate__c != null) {
                    startDate = budgetLineItem.Apttus_QPConfig__StartDate__c;
                    endDate = (budgetLineItem.Apttus_QPConfig__EndDate__c != null ? budgetLineItem.Apttus_QPConfig__EndDate__c : budgetLineItem.Apttus_QPConfig__StartDate__c.addMonths(11));
                } else {
                    startDate = oppCloseDate;
                    endDate = oppCloseDate.addMonths(11);
                }

                String key = mdmProductCode + '&&' + country + '&&' + startDate + '&&' + endDate;
                if (mergeBudgetLineItemMap.containsKey(key)) {
                    List<Apttus_Proposal__Proposal_Line_Item__c> mergeBudgetLineItemList = mergeBudgetLineItemMap.get(key);
                    mergeBudgetLineItemList.add(budgetLineItem);
                    mergeBudgetLineItemMap.put(key, mergeBudgetLineItemList);
                } else {
                    mergeBudgetLineItemMap.put(key, new List<Apttus_Proposal__Proposal_Line_Item__c> {budgetLineItem});
                }
            }
            if(nonExistingMDMProducts.size() > 0 || inactiveMDMProducts.size() > 0) {
                String exeMSG;
                exeMSG = 'Synchronization to Opportunity cannot be done!!!  ' ;
                exeMSG = exeMSG + (nonExistingMDMProducts.size() > 0 ? '  These MDM Products does not exist : ' + string.join(new List<String>(nonExistingMDMProducts),', ') : '');
                exeMSG = exeMSG + (inactiveMDMProducts.size() > 0 ? '  Inactive MDM Products found : ' + string.join(new List<String>(inactiveMDMProducts),', ') : '');
                uowProposal.registerDirty(new Apttus_Proposal__Proposal__c(Id = budgetId, Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = exeMSG));
            } else {
                for (String key : mergeBudgetLineItemMap.keySet()) {

                    List<String> keyList = key.split('&&');
                    String mdmProductCode = keyList[0];
                    String country = keyList[1];
                    Date startDate = Date.valueOf(keyList[2]);
                    Date endDate = Date.valueOf(keyList[3]);
                    Id priceBookEntryId = productToPriceBook.get(mdmProductCode + oppCurrencyCode);
                    ID productId = mdmCodeToProductIdMap.get(mdmProductCode);
                    Double price = 0;
                    String pliIds = '';
                    String description = '';
                
                    for (Apttus_Proposal__Proposal_Line_Item__c budgetLine : mergeBudgetLineItemMap.get(key)) {
                        price = price + (Double)budgetLine.Apttus_QPConfig__NetPrice__c;
                        pliIds = (pliIds == '' ? (String)budgetLine.Id : pliIds + ';' + (String)budgetLine.Id);
                        description = (description == '' ? budgetLine.Apttus_Proposal__Description__c : (description + '\n' + budgetLine.Apttus_Proposal__Description__c));
                    }
                    String oliKey = productId + '&&' + country + '&&' + startDate + '&&' + endDate;
                
                    if (product_countryToLineItemMap != null && productId != null && product_countryToLineItemMap.containskey(oliKey)){
                        List<OpportunityLineItem> lineItemList = product_countryToLineItemMap.get(oliKey);
                        OpportunityLineItem oppLineItem = lineItemList[0];
                        oppLineItem.UnitPrice = isCurrencySame ? price : (CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(oppCurrencyCode).Conversion_rate__c, 
                                                isoCodeTocurrencyTypeMap.get(bidCurrency).Conversion_rate__c, price));
                        oppLineItem.Quantity = 1;
                        oppLineItem.Description = description;
                        oppLineItem.Delivery_Country__c = country;
                        oppLineItem.Sale_Type__c = CON_CPQ.SALE_TYPE_NEW;
                        oppLineItem.Revenue_Type__c = CON_CPQ.AD_HOC;
                        oppLineItem.Therapy_Area__c = CON_CPQ.NONE;
                        oppLineItem.Agreement_Line_Item_Id__c = pliIds;
                        opportunityLinetemList.add(oppLineItem);
                        oppProductIds.add(oppLineItem.Id);
                    
                        if (SAPOLIList.Size() > 0 && SAPOLIList.contains(oppLineItem.Id) ) {
                            if (OLIScheduleMap != null && OLIScheduleMap.Size() > 0 && OLIScheduleMap.containsKey(oppLineItem.Id)) {
                                List<OpportunityLineItemSchedule> oliSchList = OLIScheduleMap.get(oppLineItem.Id);
                                Integer numberOfInstallment = oliSchList.size();
                                Decimal unitPrice = oppLineItem.UnitPrice;
                                Decimal amount = Math.floor(unitPrice / numberOfInstallment);
                                Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                                for (integer index = 0; index < numberOfInstallment; index++) {
                                    oliSchList[index].Revenue = amount;
                                }
                                oliSchList[numberOfInstallment - 1].Revenue = unitPrice - sumOfAmount;
                                lineItemScheduleMap.put(oppLineItem.Id, oliSchList);
                            }
                        } 
                        lineItemList.remove(0);
                        if (lineItemList.size() > 0 ) {
                            product_countryToLineItemMap.put(oliKey, lineItemList);
                        } else {
                            product_countryToLineItemMap.remove(oliKey);
                        }
                    } else if (productId != null && productIdToMDMCodeMap.containsKey(productId) && productToPriceBook.containsKey(mdmProductCode + oppCurrencyCode)){
                        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = oppId,
                            priceBookEntryId =  priceBookEntryId,
                            Product2Id =  productId,
                            UnitPrice = isCurrencySame ? price : (CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(oppCurrencyCode).Conversion_rate__c, 
                                        isoCodeTocurrencyTypeMap.get(bidCurrency).Conversion_rate__c, price)),
                            Quantity = 1,
                            Delivery_Country__c = country,
                            Description = description,
                            Revenue_End_Date__c = endDate,
                            Revenue_Start_Date__c = startDate,
                            Agreement_Line_Item_Id__c = pliIds,
                            Sale_Type__c = CON_CPQ.SALE_TYPE_NEW, 
                            Revenue_Type__c = CON_CPQ.AD_HOC,
                            Therapy_Area__c = CON_CPQ.NONE);
                    
                        opportunityLinetemList.add(oppLineItem);
                    }
                }

                fflib_SObjectUnitOfWork uowOpplineItem = new fflib_SObjectUnitOfWork (
                    new Schema.SObjectType[] {
                        OpportunityLineItem.SobjectType
                    }
                );
                if (oppProductIds.size() > 0) {
                    List<OpportunityLineItem> opportunityLinetemListToDelete = new List<OpportunityLineItem>();
                    for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
                    
                        if (!oppProductIds.contains(opportunityLineItem.Id)) {
                            opportunityLinetemListToDelete.add(opportunityLineItem);
                        }
                    }
                
                    if (opportunityLinetemListToDelete.size() > 0) {
                        uowOpplineItem.registerDeleted(opportunityLinetemListToDelete);
                        uowOpplineItem.commitWork();
                    }
                } else {
                    uowOpplineItem.registerDeleted(oppLineItemList);
                    uowOpplineItem.commitWork();
                }
            
                if (opportunityLinetemList.size() > 0) {
                    fflib_SObjectUnitOfWork uowUpsertOpplineItem = new fflib_SObjectUnitOfWork (
                        new Schema.SObjectType[] {
                            OpportunityLineItem.SobjectType
                        }
                    );
                    uowUpsertOpplineItem.registerUpsert(opportunityLinetemList);
                    uowUpsertOpplineItem.commitWork();
                
                    for (OpportunityLineItem oppLineItem : opportunityLinetemList) {
                    
                        CPQ_Opp_Sync_Product_Mapping__mdt metaDataRecord = mdmCodeToMetadataMap.get(productIdToMDMCodeMap.get(oppLineItem.Product2Id));
                        if (metaDataRecord.OLIS_Required__c && !OLIScheduleMap.containskey(oppLineItem.ID)) {
                            List<OpportunityLineItemSchedule> oliSchList = (lineItemScheduleMap.containsKey(oppLineItem.ID) ? 
                                lineItemScheduleMap.get(oppLineItem.ID) : new List<OpportunityLineItemSchedule>());
                            Integer numberOfInstallment = oppLineItem.Revenue_End_Date__c.day() >= oppLineItem.Revenue_Start_Date__c.day() ? (oppLineItem.Revenue_Start_Date__c.monthsBetween(oppLineItem.Revenue_End_Date__c))+1 : oppLineItem.Revenue_Start_Date__c.monthsBetween(oppLineItem.Revenue_End_Date__c);
                            Decimal price = oppLineItem.UnitPrice;
                            Decimal amount = Math.floor(price / numberOfInstallment);
                            Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                            Date revenueDate = oppLineItem.Revenue_Start_Date__c;
                            for (integer index = 0; index < numberOfInstallment - 1; index++) {
                                OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = amount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                                revenueDate = revenueDate.addMonths(1);
                                oliSchList.add(oliSchedule);
                            }
                            OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price - sumOfAmount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                            oliSchList.add(oliSchedule);
                            lineItemScheduleMap.put(oppLineItem.ID, oliSchList);
                        }
                    }
                    if (lineItemScheduleMap.size() > 0) {
                        if (!test.isRunningTest()) {
                            QUE_CPQ_TimeDelayForSchedule scheduleUpdate = new QUE_CPQ_TimeDelayForSchedule(lineItemScheduleMap, budgetId); 
                            Id jobId = System.enqueueJob(scheduleUpdate);
                        }
                    } else {
                        uowProposal.registerDirty(new Apttus_Proposal__Proposal__c(Id = budgetId, Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = ''));
                    }
                }
            }
        } else {
            uowProposal.registerDirty(new Apttus_Proposal__Proposal__c(Id = budgetId, Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = 'No Proposal Line Items to sync to Opportunity'));
        }
        uowProposal.commitWork();
    }
    
    public static void initialSyncBudgetWithOpportunity (Id budgetId, String tool) {
        List<String> listOfAttributeNames = new List<String>();
        CPQ_Opp_Sync_Attribute__mdt attMetadata = [SELECT Attribute_List__c, Country__c, Pricing_Tool__c FROM CPQ_Opp_Sync_Attribute__mdt WHERE Pricing_Tool__c =: tool];
        String deliveryCountryAtt = attMetadata.Country__c;
        if (attMetadata.Attribute_List__c != null) {
            listOfAttributeNames = attMetadata.Attribute_List__c.split(CON_CPQ.SEMICOLON);
        }
        List<CPQ_Opp_Sync_Product_Mapping__mdt> productMappings = [SELECT Attribute_Value_1__c, 
            Attribute_Value_2__c, Attribute_Value_3__c, Attribute_Value_4__c, Attribute_Value_5__c, 
            Attribute_Value_6__c, Attribute_Value_7__c, Attribute_Value_8__c, Attribute_Value_9__c, 
            Attribute_Value_10__c, CPQ_Product_Code__c, CPQ_Product_Type__c, DeveloperName, Id, Language, 
            MDM_Product_Code__c, OLIS_Required__c, Product_Name__c, Product_Sync_Type__c, Pricing_Tool__c FROM CPQ_Opp_Sync_Product_Mapping__mdt WHERE Pricing_Tool__c = :tool];
        
        Map<String, Id> mdmCodeToProductIdMap = new Map<String, Id>();
        Map<Id, String> productIdToMDMCodeMap = new Map<Id, String>();
        Map<String, Product2> mdmProductDetailMap = new Map<String, Product2>();
        Map<String, String> productCodeToMDMCodeMappingMap = new Map<String, String>();
        Map<String, List<String>> mdmCodeToProductCodeMappingMap = new Map<String, List<String>>();
        Map<String, CPQ_Opp_Sync_Product_Mapping__mdt> mdmCodeToMetadataMap = new Map<String, CPQ_Opp_Sync_Product_Mapping__mdt>();
        Set<String> optionSet = new Set<String>();
        Set<String> bundleSet = new Set<String>();
        List<OpportunityLineItem> opportunityLinetemList = new List<OpportunityLineItem>();
        Set<Id> oppProductIds = new Set<Id>();  
        Map<Id, List<OpportunityLineItemSchedule>> lineItemScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
        
        for (CPQ_Opp_Sync_Product_Mapping__mdt cospm : productMappings) {
            Integer noOfAttributes = listOfAttributeNames.size();
            String productCodeToMDMCodeMapKey = cospm.CPQ_Product_Code__c;
            if (noOfAttributes > 0) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_1__c;
            }
            if (noOfAttributes > 1) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_2__c;
            }
            if (noOfAttributes > 2) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_3__c;
            }
            if (noOfAttributes > 3) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_4__c;
            }
            if (noOfAttributes > 4) {
                productCodeToMDMCodeMapKey = productCodeToMDMCodeMapKey + ':' + cospm.Attribute_Value_5__c;
            }
            productCodeToMDMCodeMappingMap.put(productCodeToMDMCodeMapKey, cospm.MDM_Product_Code__c);
            mdmCodeToMetadataMap.put(cospm.MDM_Product_Code__c, cospm);
            if (mdmCodeToProductCodeMappingMap.containsKey(cospm.MDM_Product_Code__c)) {
                List<String> productCodes = mdmCodeToProductCodeMappingMap.get(cospm.MDM_Product_Code__c);
                productCodes.add(cospm.CPQ_Product_Code__c);
                mdmCodeToProductCodeMappingMap.put(cospm.MDM_Product_Code__c, productCodes);
            } else {
                mdmCodeToProductCodeMappingMap.put(cospm.MDM_Product_Code__c, new List<String> {cospm.CPQ_Product_Code__c});
            }
            if (cospm.Product_Sync_Type__c == CON_CPQ.OPTION) {
                optionSet.add(cospm.CPQ_Product_Code__c);
            } else {
                bundleSet.add(cospm.CPQ_Product_Code__c);
            }
        }
        
        Set<String> budgetLineItemFieldSet =  new Set<String> {CON_CPQ.ID,
            CON_CPQ.RELATED_QUOTE_BID_CURRENCY,
            CON_CPQ.RELATED_QUOTE_RELATED_OPPORTUNITY_CURRENCYISOCODE,
            CON_CPQ.LINE_ITEM_NETPRICE,
            CON_CPQ.LINE_ITEM_PRODUCT,
            CON_CPQ.OPP_FIELD_RELATED_BUDGET_OPPORTUNITY,
            CON_CPQ.QUOTE_LINE_ITEM_START_DATE,
            CON_CPQ.QUOTE_LINE_ITEM_END_DATE,
            CON_CPQ.OPP_CLOSE_DATE,
            CON_CPQ.LINE_ITEM_DESCRIPTION,
            CON_CPQ.LINE_ITEM_ATTRIBUTE_COUNTRY,
            CON_CPQ.LINE_ITEM_OPTION_PRODUCTCODE,
            CON_CPQ.LINE_ITEM_BUNDLE_PRODUCTCODE,
            CON_CPQ.RELATED_QUOTE_CONVERSION_DATE
        };
        Set<String> attributeFieldSet = new Set<String>();
        attributeFieldSet.addALL(listOfAttributeNames);
        if (!attributeFieldSet.contains(deliveryCountryAtt)) {
            attributeFieldSet.add(deliveryCountryAtt);
        }
        List<Apttus_Config2__LineItem__c> budgetLineItemsList = new SLT_LineItem().getLineItemsWithAttributesByQuoteId(new Set<Id>{budgetId}, budgetLineItemFieldSet, optionSet, bundleSet);
        Set<Id> attributeIds = new Set<Id>();
        for (Apttus_Config2__LineItem__c budgetLineItem : budgetLineItemsList) {
            if (budgetLineItem.Apttus_Config2__AttributeValueId__c != null) {
                attributeIds.add(budgetLineItem.Apttus_Config2__AttributeValueId__c); 
            }
        }
        Map<Id, Apttus_Config2__ProductAttributeValue__c> productAttributeMap = new SLT_ProductAttributeValue().getProductAttributeRecords(attributeIds, attributeFieldSet);
        
        fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus_Proposal__Proposal__c.SobjectType
            }
        );
        if (budgetLineItemsList.size() > 0) {
            String bidCurrency = budgetLineItemsList.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.CurrencyIsoCode;
            String oppCurrencyCode = budgetLineItemsList.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.CurrencyIsoCode;
            Date oppCloseDate = budgetLineItemsList.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__r.CloseDate;
            Id oppId = budgetLineItemsList.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c;
            Date conversionDate = budgetLineItemsList.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Conversion_Date__c;
            Boolean isCurrencySame = true;
            Map<String, Currency_Exchange_Rates__c> isoCodeTocurrencyTypeMap;
            if (bidCurrency != oppCurrencyCode) {
                isCurrencySame = false;
                isoCodeTocurrencyTypeMap = new SLT_GridRateCurrency().getSelectedPCGridCurrencyTypeByIsoCode(new Set<String>{bidCurrency, oppCurrencyCode}, conversionDate);
            }
            
            for (Product2 p : [Select Id, ProductCode, IsActive From Product2 Where ProductCode IN :mdmCodeToProductCodeMappingMap.keySet()]) {
                mdmCodeToProductIdMap.put(p.ProductCode, p.Id);
                productIdToMDMCodeMap.put(p.Id, p.ProductCode);
                mdmProductDetailMap.put(p.ProductCode, p);
            }
            
            List<OpportunityLineItem> oppLineItemList = 
                new SLT_OpportunityLineItems().selectOLIByOpportunityId(new Set<ID>{budgetLineItemsList.get(0).Apttus_Config2__ConfigurationId__r.Apttus_QPConfig__Proposald__r.Apttus_Proposal__Opportunity__c});
            Map<String, List<OpportunityLineItem>> product_countryToLineItemMap = new Map<String, List<OpportunityLineItem>>();
            Set<Id> SAPOLIList = new Set<Id>();
            
            for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
                if (opportunityLineItem.Agreement_Line_Item_Id__c != null) {
                    if (opportunityLineItem.Billing_System__c == CON_CPQ.SAP) {
                        SAPOLIList.add(opportunityLineItem.Id);
                    }
                    String oliKey = opportunityLineItem.Product2Id + '&&' + opportunityLineItem.Delivery_Country__c + '&&' + opportunityLineItem.Revenue_Start_Date__c + '&&' + opportunityLineItem.Revenue_End_Date__c;
                    if (product_countryToLineItemMap.containsKey(oliKey)) {
                        List<OpportunityLineItem> oliList = product_countryToLineItemMap.get(oliKey);
                        oliList.add(opportunityLineItem);
                        product_countryToLineItemMap.put(oliKey, oliList);
                    } else {
                        product_countryToLineItemMap.put(oliKey, new List<OpportunityLineItem> {opportunityLineItem});
                    }
                }
            }
            
            Set<String> priceBookFieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.ISACTIVE};           
            List<PriceBook2> standardPriceBook = new SLT_PriceBook2().getStandardPriceBook(priceBookFieldSet);
            Map<String, Id> productToPriceBook = new Map<String, Id>();
            Set<String> nonExistingMDMProducts = new Set<String>();
            Set<String> inactiveMDMProducts = new Set<String>();
            
            if (standardPriceBook.size() > 0) {
                Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.PRODUCTCODE, CON_CPQ.ISACTIVE, CON_CPQ.CURRENCYISOCODE, CON_CPQ.PRODUCTID};
                    List<PriceBookEntry> priceBookEntryList = new SLT_PriceBookEntry().getStandardPriceBookByName(fieldSet, productIdToMDMCodeMap.keySet(), standardPriceBook[0].Id, new List<String>{oppCurrencyCode});
                for (PricebookEntry priceBookEntry : priceBookEntryList) {
                    if (priceBookEntry.IsActive == true) {
                        productToPriceBook.put(priceBookEntry.ProductCode + priceBookEntry.CurrencyIsoCode, priceBookEntry.Id);
                    }
                }
            }
            
            List<OpportunityLineItemSchedule> exisitngLineItemSchedule = new SLT_OpportunityLineItemSchedule().selectByOpportunityLineItemId(SAPOLIList, new Set<String>{CON_CPQ.ID, CON_CPQ.OPPORTUNITYLINEITEMID});
            Map<Id, List<OpportunityLineItemSchedule>> OLIScheduleMap = new Map<Id, List<OpportunityLineItemSchedule>>();
            for (OpportunityLineItemSchedule oli : exisitngLineItemSchedule) {
                if (!OLIScheduleMap.containskey(oli.OpportunityLineItemId)) {
                    OLIScheduleMap.put(oli.OpportunityLineItemId, new List<OpportunityLineItemSchedule> {oli});
                } else {
                    List<OpportunityLineItemSchedule> oliList = OLIScheduleMap.get(oli.OpportunityLineItemId);
                    oliList.add(oli);
                    OLIScheduleMap.put(oli.OpportunityLineItemId, oliList);
                }
            }
            Map<String, List<Apttus_Config2__LineItem__c>> mergeBudgetLineItemMap = new Map<String, List<Apttus_Config2__LineItem__c>>();
            for (Apttus_Config2__LineItem__c budgetLineItem : budgetLineItemsList) {
                String mapKey = budgetLineItem.Apttus_Config2__OptionId__c != null ? budgetLineItem.Apttus_Config2__OptionId__r.ProductCode : budgetLineItem.Apttus_Config2__ProductId__r.ProductCode;
                Apttus_Config2__ProductAttributeValue__c productAttValue = (productAttributeMap.containsKey(budgetLineItem.Apttus_Config2__AttributeValueId__c) ? productAttributeMap.get(budgetLineItem.Apttus_Config2__AttributeValueId__c) : null);
                String country = '';
                if (productAttValue != null) {
                    for (String attributeFieldName : listOfAttributeNames) {
                        mapKey = mapKey + ':' + productAttValue.get(attributeFieldName);
                    }
                    country = (String)productAttValue.get(deliveryCountryAtt);
                }
                String  mdmProductCode = productCodeToMDMCodeMappingMap.get(mapKey);
                Product2 mdmProduct = mdmProductDetailMap.get(mdmProductCode);
                if(mdmProduct == null){
                    nonExistingMDMProducts.add(mdmProductCode);
                } else if(!mdmProduct.IsActive) {
                    inactiveMDMProducts.add(mdmProductCode);
                }
                Date startDate;
                Date endDate;
                if (budgetLineItem.Apttus_Config2__StartDate__c != null) {
                    startDate = budgetLineItem.Apttus_Config2__StartDate__c;
                    endDate = (budgetLineItem.Apttus_Config2__EndDate__c != null ? budgetLineItem.Apttus_Config2__EndDate__c : budgetLineItem.Apttus_Config2__StartDate__c.addMonths(11));
                } else {
                    startDate = oppCloseDate;
                    endDate = oppCloseDate.addMonths(11);
                }

                String key = mdmProductCode + '&&' + country + '&&' + startDate + '&&' + endDate;
                if (mergeBudgetLineItemMap.containsKey(key)) {
                    List<Apttus_Config2__LineItem__c> mergeBudgetLineItemList = mergeBudgetLineItemMap.get(key);
                    mergeBudgetLineItemList.add(budgetLineItem);
                    mergeBudgetLineItemMap.put(key, mergeBudgetLineItemList);
                } else {
                    mergeBudgetLineItemMap.put(key, new List<Apttus_Config2__LineItem__c> {budgetLineItem});
                }
            }
            if(nonExistingMDMProducts.size() > 0 || inactiveMDMProducts.size() > 0) {
                String exeMSG;
                exeMSG = 'Synchronization to Opportunity cannot be done!!!  ' ;
                exeMSG = exeMSG + (nonExistingMDMProducts.size() > 0 ? '  These MDM Products does not exist : ' + string.join(new List<String>(nonExistingMDMProducts),', ') : '');
                exeMSG = exeMSG + (inactiveMDMProducts.size() > 0 ? '  Inactive MDM Products found : ' + string.join(new List<String>(inactiveMDMProducts),', ') : '');
                uowProposal.registerDirty(new Apttus_Proposal__Proposal__c(Id = budgetId, Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = exeMSG));
            } else {
                for (String key : mergeBudgetLineItemMap.keySet()) {

                    List<String> keyList = key.split('&&');
                    String mdmProductCode = keyList[0];
                    String country = keyList[1];
                    Date startDate = Date.valueOf(keyList[2]);
                    Date endDate = Date.valueOf(keyList[3]);
                    Id priceBookEntryId = productToPriceBook.get(mdmProductCode + oppCurrencyCode);
                    ID productId = mdmCodeToProductIdMap.get(mdmProductCode);
                    Double price = 0;
                    String pliIds = '';
                    String description = '';
                
                    for (Apttus_Config2__LineItem__c budgetLine : mergeBudgetLineItemMap.get(key)) {
                        price = price + (Double)budgetLine.Apttus_Config2__NetPrice__c;
                        pliIds = (pliIds == '' ? (String)budgetLine.Id : pliIds + ';' + (String)budgetLine.Id);
                        description = (description == '' ? budgetLine.Apttus_Config2__Description__c : (description + '\n' + budgetLine.Apttus_Config2__Description__c));
                    }
                    String oliKey = productId + '&&' + country + '&&' + startDate + '&&' + endDate;
                
                    if (product_countryToLineItemMap != null && productId != null && product_countryToLineItemMap.containskey(oliKey)){
                        List<OpportunityLineItem> lineItemList = product_countryToLineItemMap.get(oliKey);
                        OpportunityLineItem oppLineItem = lineItemList[0];
                        oppLineItem.UnitPrice = isCurrencySame ? price : (CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(oppCurrencyCode).Conversion_rate__c, 
                                                isoCodeTocurrencyTypeMap.get(bidCurrency).Conversion_rate__c, price));
                        oppLineItem.Quantity = 1;
                        oppLineItem.Description = description;
                        oppLineItem.Delivery_Country__c = country;
                        oppLineItem.Sale_Type__c = CON_CPQ.SALE_TYPE_NEW;
                        oppLineItem.Revenue_Type__c = CON_CPQ.AD_HOC;
                        oppLineItem.Therapy_Area__c = CON_CPQ.NONE;
                        oppLineItem.Agreement_Line_Item_Id__c = pliIds;
                        opportunityLinetemList.add(oppLineItem);
                        oppProductIds.add(oppLineItem.Id);
                    
                        if (SAPOLIList.Size() > 0 && SAPOLIList.contains(oppLineItem.Id) ) {
                            if (OLIScheduleMap != null && OLIScheduleMap.Size() > 0 && OLIScheduleMap.containsKey(oppLineItem.Id)) {
                                List<OpportunityLineItemSchedule> oliSchList = OLIScheduleMap.get(oppLineItem.Id);
                                Integer numberOfInstallment = oliSchList.size();
                                Decimal unitPrice = oppLineItem.UnitPrice;
                                Decimal amount = Math.floor(unitPrice / numberOfInstallment);
                                Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                                for (integer index = 0; index < numberOfInstallment; index++) {
                                    oliSchList[index].Revenue = amount;
                                }
                                oliSchList[numberOfInstallment - 1].Revenue = unitPrice - sumOfAmount;
                                lineItemScheduleMap.put(oppLineItem.Id, oliSchList);
                            }
                        } 
                        lineItemList.remove(0);
                        if (lineItemList.size() > 0 ) {
                            product_countryToLineItemMap.put(oliKey, lineItemList);
                        } else {
                            product_countryToLineItemMap.remove(oliKey);
                        }
                    } else if (productId != null && productIdToMDMCodeMap.containsKey(productId) && productToPriceBook.containsKey(mdmProductCode + oppCurrencyCode)){
                        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = oppId,
                            priceBookEntryId =  priceBookEntryId,
                            Product2Id =  productId,
                            UnitPrice = isCurrencySame ? price : (CPQ_Utility.getCurrencyConvertedValue(isoCodeTocurrencyTypeMap.get(oppCurrencyCode).Conversion_rate__c, 
                                        isoCodeTocurrencyTypeMap.get(bidCurrency).Conversion_rate__c, price)),
                            Quantity = 1,
                            Delivery_Country__c = country,
                            Description = description,
                            Revenue_End_Date__c = endDate,
                            Revenue_Start_Date__c = startDate,
                            Agreement_Line_Item_Id__c = pliIds,
                            Sale_Type__c = CON_CPQ.SALE_TYPE_NEW, 
                            Revenue_Type__c = CON_CPQ.AD_HOC,
                            Therapy_Area__c = CON_CPQ.NONE);
                    
                        opportunityLinetemList.add(oppLineItem);
                    }
                }

                fflib_SObjectUnitOfWork uowOpplineItem = new fflib_SObjectUnitOfWork (
                    new Schema.SObjectType[] {
                        OpportunityLineItem.SobjectType
                    }
                );
                if (oppProductIds.size() > 0) {
                    List<OpportunityLineItem> opportunityLinetemListToDelete = new List<OpportunityLineItem>();
                    for (OpportunityLineItem opportunityLineItem : oppLineItemList) {
                    
                        if (!oppProductIds.contains(opportunityLineItem.Id)) {
                            opportunityLinetemListToDelete.add(opportunityLineItem);
                        }
                    }
                
                    if (opportunityLinetemListToDelete.size() > 0) {
                        uowOpplineItem.registerDeleted(opportunityLinetemListToDelete);
                        uowOpplineItem.commitWork();
                    }
                } else {
                    uowOpplineItem.registerDeleted(oppLineItemList);
                    uowOpplineItem.commitWork();
                }
            
                if (opportunityLinetemList.size() > 0) {
                    fflib_SObjectUnitOfWork uowUpsertOpplineItem = new fflib_SObjectUnitOfWork (
                        new Schema.SObjectType[] {
                            OpportunityLineItem.SobjectType
                        }
                    );
                    uowUpsertOpplineItem.registerUpsert(opportunityLinetemList);
                    uowUpsertOpplineItem.commitWork();
                
                    for (OpportunityLineItem oppLineItem : opportunityLinetemList) {
                    
                        CPQ_Opp_Sync_Product_Mapping__mdt metaDataRecord = mdmCodeToMetadataMap.get(productIdToMDMCodeMap.get(oppLineItem.Product2Id));
                        if (metaDataRecord.OLIS_Required__c && !OLIScheduleMap.containskey(oppLineItem.ID)) {
                            List<OpportunityLineItemSchedule> oliSchList = (lineItemScheduleMap.containsKey(oppLineItem.ID) ? 
                                lineItemScheduleMap.get(oppLineItem.ID) : new List<OpportunityLineItemSchedule>());
                            Integer numberOfInstallment = oppLineItem.Revenue_End_Date__c.day() >= oppLineItem.Revenue_Start_Date__c.day() ? (oppLineItem.Revenue_Start_Date__c.monthsBetween(oppLineItem.Revenue_End_Date__c))+1 : oppLineItem.Revenue_Start_Date__c.monthsBetween(oppLineItem.Revenue_End_Date__c);
                            Decimal price = oppLineItem.UnitPrice;
                            Decimal amount = Math.floor(price / numberOfInstallment);
                            Decimal sumOfAmount = amount * (numberOfInstallment - 1);
                            Date revenueDate = oppLineItem.Revenue_Start_Date__c;
                            for (integer index = 0; index < numberOfInstallment - 1; index++) {
                                OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = amount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                                revenueDate = revenueDate.addMonths(1);
                                oliSchList.add(oliSchedule);
                            }
                            OpportunityLineItemSchedule oliSchedule = new OpportunityLineItemSchedule(Revenue = price - sumOfAmount, OpportunityLineItemId = oppLineItem.ID, ScheduleDate = revenueDate, Type = 'Revenue');
                            oliSchList.add(oliSchedule);
                            lineItemScheduleMap.put(oppLineItem.ID, oliSchList);
                        }
                    }
                    if (lineItemScheduleMap.size() > 0) {
                        if (!test.isRunningTest()) {
                            QUE_CPQ_TimeDelayForSchedule scheduleUpdate = new QUE_CPQ_TimeDelayForSchedule(lineItemScheduleMap, budgetId); 
                            Id jobId = System.enqueueJob(scheduleUpdate);
                        }
                    } else {
                        uowProposal.registerDirty(new Apttus_Proposal__Proposal__c(Id = budgetId, Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = ''));
                    }
                }
            }
        } else {
            uowProposal.registerDirty(new Apttus_Proposal__Proposal__c(Id = budgetId, Execution_Status__c = CON_CPQ.COMPLETED, Execution_Message__c = 'No Line Items to sync to Opportunity'));
        }
        uowProposal.commitWork();
    }
    
    public static Map<String, List<String>> getDependentValuesByControllingValue(String objectName, String dependentFieldName) {
        Schema.DescribeFieldResult dependentField = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().fields.getMap().get(dependentFieldName).getDescribe().getSObjectField().getDescribe();
        Schema.DescribeFieldResult controlField = dependentField.getController().getDescribe();
        List<Schema.PicklistEntry> controlEntries =(controlField.getType() == Schema.DisplayType.Boolean ? null : controlField.getPicklistValues());
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistByControllingPickListMap = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry: dependentField.getPicklistValues()) {
            if (entry.isActive()) {
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                if(base64chars.size() > 0 && base64chars[0] != '') {
                    for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                        Object controlValue = (controlEntries == null ? (Object)(index == 1) : (Object)(controlEntries[index].isActive() ? controlEntries[index].getLabel() : null));
                        Integer bitIndex = index / 6;
                        Integer bitShift = 5 - Math.mod(index, 6);
                        if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) {
                            continue;
                        }
                        if (!dependentPicklistByControllingPickListMap.containsKey((String)controlValue)) {
                            dependentPicklistByControllingPickListMap.put((String)controlValue, new List<String>());
                        }
                        dependentPicklistByControllingPickListMap.get((String)controlValue).add(entry.getLabel());
                    }
                }
            }
        }
        return dependentPicklistByControllingPickListMap;
    }

    public static String getQuoteType(Id bidHistoryId, String pricingTool) {
        String quoteType = null;
        Set<String> bidHistoryFieldSet = CON_CPQ.BID_HISTORY_FIELDSET_FOR_QUOTE_CREATE;
        Bid_History__c bidHistory = new SLT_Bid_History().getClinicalBidDetails(bidHistoryId, bidHistoryFieldSet);
        if (pricingTool.equals(CON_CPQ.Complete_Consent)) {
            if (CON_CPQ.OPPORTUNITY_ONE_TO_SIX_STAGES.contains(bidHistory.Bid_History_Related_Opportunity__r.StageName)) {
                quoteType = bidHistory.Bid_Type__c;
            } else if (CON_CPQ.OPPORTUNITY_7A_ONWARDS_STAGE.contains(bidHistory.Bid_History_Related_Opportunity__r.StageName)) {
                quoteType = CON_CPQ.CHNAGE_ORDER;
            }
        } else if (pricingTool.equals(CON_CPQ.Q2_Solutions)) {
            quoteType = bidHistory.Bid_Type__c;
        }
        return quoteType;
    }

    /*@AuraEnabled
    public static boolean isPermission() {
        boolean havePermission = false;
        CPQ_Settings__c res = [SELECT Id, Package_Namespace_Prefix__c FROM CPQ_Settings__c LIMIT 1];
        for (String nameSpacePrefix : res.Package_Namespace_Prefix__c.split(';')) {
            havePermission = userinfo.isCurrentUserLicensed(nameSpacePrefix);
            if (havePermission == false) {
                break;
            }
        }
        return havePermission;
    }*/

    public static Map<String,Schema.SObjectField> getFields(String sObjectName) {
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
            if (sObjectType != null) {
                Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
                return sObjectDescribe.fields.getMap();
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Object parseFieldValue(String fieldType, Object value) {
        try {
            if (value != null) {
                if (fieldType == 'Date') {
                    return Date.valueOf((String) value);
                } else if (fieldType == 'Boolean') {
                    return Boolean.valueOf((String) value);
                } else if (fieldType == 'Integer' || fieldType == 'Number') {
                    return Integer.valueOf((String) value);
                } else if (fieldType == 'Decimal') {
                    return Decimal.valueOf((String) value);
                }
            }
            return value;
        } catch (Exception e) {
            throw new IllegalArgumentException('Invalid value for field type ' + fieldType + ': ' + value);
        }
    }
}
