public with sharing class CNT_CPQ_RelatedListController {

    @AuraEnabled
    public static List<MappingsWrapper> getColumns(String quoteRequisiteType, String pricingTool) {
        try {
            List<MappingsWrapper> mappingsWrapperList = new List<MappingsWrapper>();
            List<CPQ_Mapping_Field_Set__mdt> mappedFieldList = CPQ_Mapping_Field_Set__mdt.getAll().values();
            if (!mappedFieldList.isEmpty()) {
                for (CPQ_Mapping_Field_Set__mdt record : mappedFieldList) {
                    if (record.Feature_Selection__c == CON_CPQ.FEATURE_SELECTION_RELATED_LIST && record.Quote_Requisite_Type__c == quoteRequisiteType && record.Pricing_Tool__c == pricingTool) {
                        Boolean isEditable = record.Is_Editable__c == true ? CPQ_QuoteUtility.checkEditPermissionForQuoteRequisiteField(record.Field_Api_Name__c) : false;
                        mappingsWrapperList.add(new MappingsWrapper(record.Quote_Requisite_Type__c, record.Field_Label__c, record.Field_Api_Name__c, record.Field_Type__c, isEditable, record.Order_Number__c.intValue(), record.Is_Compact_View__c, record.Sobject_Name__c));
                    }
                }
            }
            return !mappingsWrapperList.isEmpty() ? mappingsWrapperList : null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<SObject> getData(String recordId, List<String> fieldApiNames, String quoteRequisiteType, String objectApiName) {
        try {
            if (!String.isEmpty(recordId) && !fieldApiNames.isEmpty() && !String.isEmpty(quoteRequisiteType)) {
                Set<String> fieldSet = new Set<String>(fieldApiNames);
                String relatedLookupName = ((Id)recordId).getSObjectType().getDescribe().getName();
                String query = 'SELECT ' + String.join(fieldSet, ', ') + ' FROM ' + String.escapeSingleQuotes(objectApiName) + ' WHERE ' + String.escapeSingleQuotes(relatedLookupName) + ' = :recordId' + ' AND Type__c = :quoteRequisiteType';
                return Database.query(query);
            } else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean updateRecords(List<SObject> recordsToUpdate, String objectApiName) {
        try {
            if (!recordsToUpdate.isEmpty() && String.isNotBlank(objectApiName)) {
                Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
                fflib_SObjectUnitOfWork uowProposal = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        sObjectType
                    }
                );
                uowProposal.registerDirty(recordsToUpdate);
                uowProposal.commitWork();
            }
            return true;
        } catch (Exception e) {
            String error = e.getMessage();
            if (e instanceOf DmlException) {
                error = handleDmlException((DmlException)e);
            }
            throw new AuraHandledException(error);
        }
    }
    private static String handleDmlException(DmlException e) {
        String errMsg = '';
        for (Integer i = 0; i < e.getNumDml(); i++) {
            errMsg += e.getDmlMessage(i) + '\n';
        }
        return errMsg;
    }

    public class ColumnWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean editable;
        public ColumnWrapper(String fieldLabel, String fieldName, String fieldType, Boolean isEditable) {
            this.label = fieldLabel;
            this.fieldName = fieldName;
            this.type = fieldType;
            this.editable = isEditable;
        }
    }

    public class MappingsWrapper {
        @AuraEnabled
        public String quoteRequisiteType;
        @AuraEnabled
        public ColumnWrapper columnWrapper;
        @AuraEnabled
        public Integer orderNumber;
        @AuraEnabled
        public Boolean isCompact;
        @AuraEnabled
        public String objectApiName;
        
        public MappingsWrapper(String quoteRequisiteType, String columnLabel, String columnName, String columnType, Boolean isEditable, Integer orderNumber, Boolean isCompact, String objectApiName) {
            this.quoteRequisiteType = quoteRequisiteType;
            this.columnWrapper = new ColumnWrapper(columnLabel, columnName, columnType, isEditable);
            this.orderNumber = orderNumber;
            this.isCompact = isCompact;
            this.objectApiName = objectApiName;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<QuoteLineItemWrapper> getQLIs(Id recordId) {
        List<QuoteLineItemWrapper> quoteLineItemWrapperList = new List<QuoteLineItemWrapper>();
        List<Quote_Line_Item__c> qliList = new SLT_QuoteLineItem().getQuoteLineItemByQuoteId(new Set<Id>{recordId}, CON_CPQ.QLI_FIELD_SET_EMEA);
        for (Quote_Line_Item__c qli: qliList) {
            QuoteLineItemWrapper qliWrap = new QuoteLineItemWrapper();
            qliWrap.Id = qli.Id;
            qliWrap.startDate = String.valueOf(qli.Start_Date__c == null ? qli.Quote__r.Start_Date__c : qli.Start_Date__c);
            qliWrap.productName = qli.Bundle_Product__r.Name;
            qliWrap.productCode = qli.Bundle_Product__r.SAP_Code__c;
            qliWrap.noOfInstallment = Integer.valueOf(qli.Number_of_Installment__c);
            qliWrap.installPeriod = qli.Installment_Period__c;
            qliWrap.discountAmount = qli.Discount_Amount__c;
            qliWrap.discountPercent = qli.Discount_Percent__c;
            qliWrap.listPrice = qli.BasePrice__c == null ? 0 : qli.BasePrice__c;
            qliWrap.country = qli.Country__c;
            qliWrap.salesPrice = qli.Net_Price__c;
            qliWrap.revenueType = qli.Revenue_Type__c;
            qliWrap.salesType = qli.Sales_Type__c;
            qliWrap.currencyIsoCode = qli.Quote__r.currencyIsoCode;
            qliWrap.discountReason = qli.Discount_Reason__c != null ? qli.Discount_Reason__c : qli.Surcharge_Reason__c;
            quoteLineItemWrapperList.add(qliWrap);
        }
        return quoteLineItemWrapperList;
    }

    @AuraEnabled
    public static String updateQLIs(String updatedDataJSON) {
        List<QuoteLineItemWrapper> quoteLineItemWrapperList = (List<QuoteLineItemWrapper>)JSon.deserialize(updatedDataJSON, List<QuoteLineItemWrapper>.class);
        List<Quote_Line_Item__c> qlisToUpdateList = new List<Quote_Line_Item__c>();
        for (QuoteLineItemWrapper qliWrap: quoteLineItemWrapperList) {
            Quote_Line_Item__c qli = new Quote_Line_Item__c();
            if (qliWrap.revenueType != null) {
                qli.Revenue_Type__c = qliWrap.revenueType;
            }
            if (qliWrap.country != null) {
                qli.Country__c = qliWrap.country;
            }
            if (qliWrap.listPrice != null) {
                qli.BasePrice__c = qliWrap.listPrice;
            }
            if (qliWrap.discountAmount != null) {
                qli.Discount_Amount__c = qliWrap.discountAmount;
            }
            if (qliWrap.discountPercent != null) {
                qli.Discount_Percent__c = qliWrap.discountPercent;
            }
            if (qliWrap.startDate != null && qliWrap.startDate != '') {
                qli.Start_Date__c = Date.valueOf(qliWrap.startDate);
            }
            if (qliWrap.salesType != null) {
                qli.Sales_Type__c = qliWrap.salesType;
            }
            if (qliWrap.installPeriod != null) {
                qli.Installment_Period__c = qliWrap.installPeriod;
            }
            if (qliWrap.noOfInstallment != null) {
                qli.Number_of_Installment__c = qliWrap.noOfInstallment;
            }
            if (qliWrap.discountReason != null) {
                if (qliWrap.isDiscount != null && qliWrap.isDiscount == true) {
                    qli.Discount_Reason__c = qliWrap.discountReason;
                    qli.Surcharge_Reason__c = null;
                } else {
                    qli.Surcharge_Reason__c = qliWrap.discountReason;
                    qli.Discount_Reason__c = null;
                }
            }
            qli.Quantity__c = 1;
            qli.Id = qliWrap.Id;
            qlisToUpdateList.add(qli);
        }
        if (!qlisToUpdateList.isEmpty()) {
            try {
                fflib_SObjectUnitOfWork uowQLI = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Quote_Line_Item__c.SobjectType
                    }
                );
                uowQLI.registerDirty(qlisToUpdateList);
                uowQLI.commitWork();
            } catch(Exception e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    return e.getDmlMessage(i);
                }
            }
        }
        return CON_CPQ.SUCCESS;
    }

    public class QuoteLineItemWrapper {
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public Integer noOfInstallment;
        @AuraEnabled
        public String installPeriod;
        @AuraEnabled
        public Double discountAmount;
        @AuraEnabled
        public Double discountPercent;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public Double salesPrice;
        @AuraEnabled
        public Double listPrice;
        @AuraEnabled
        public String revenueType;
        @AuraEnabled
        public String salesType;
        @AuraEnabled
        public String currencyIsoCode;
        @AuraEnabled
        public String discountReason;
        @AuraEnabled
        public Boolean isDiscount;
    }
}