/*
* Version       : 0.0.1
* Description   : This Apex Class is Utility Class for Services
* Created By    : Danish Khan
* Created For   : Utility Class for Internal or External Service Request for QLI.
*/
public class UTL_CPQ_Services {
    
    public static WPR_CPQ_ReturnItems insertQLIs(String jsonBody, String featureSettings) {
        String ExceptionLogs;
        WPR_CPQ_ReturnItems items = new WPR_CPQ_ReturnItems();
        Set<String> objFields = new Set<String>();
        items.quote = '';
        String unoTool;
        try {
            fflib_SObjectUnitOfWork uowQuoteLines = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Quote_Line_Item__c.SobjectType
                }
            );
            Map<String, Object> headerInfo = featureSettings != null && ((Map<String, Object>)JSON.deserializeUntyped(featureSettings)).size() > 0 ? ((Map<String, Object>)JSON.deserializeUntyped(featureSettings)) : null;
            Map<String, String> fieldMappings = new Map<String, String>();
            String condition = 'Object_Name__c = \'Quote_Line_Item__c\' AND Version__c = 1 AND Status__c = \'Active\' WITH SECURITY_ENFORCED';
            if (headerInfo != null && headerInfo.containsKey('internalCall') && headerInfo.get('internalCall') == false) {
                for (Template_Data__c mapping : new SLT_Template_Data().getTemplateDataByCondition(condition, new Set<String>{'Cell_Reference__c', 'Field_Name__c'})) {
                    fieldMappings.put(mapping.Cell_Reference__c, mapping.Field_Name__c);
                }
            }   
            for (Schema.SObjectField field : Schema.SObjectType.Quote_Line_Item__c.fields.getMap().values()) {
                objFields.add('' + field);
            }
            List<Quote_Line_Item__c> recordsToInsert = new List<Quote_Line_Item__c>();
            Quote__c quote;
            Boolean flag = true;
            if (jsonBody != null && ((List<Object>)JSON.deserializeUntyped(jsonBody)).size() > 0) {
                String recordId = '';
                
                if (headerInfo.containsKey('internalCall') && headerInfo.get('internalCall') == true) {
                    recordId = String.valueOf(((Map<String, Object>)(((List<Object>)JSON.deserializeUntyped(jsonBody))[0])).get('Quote__c'));
                } else {
                    recordId = String.valueOf(((Map<String, Object>)(((List<Object>)JSON.deserializeUntyped(jsonBody))[0])).get('Quote'));
                }
                if (recordId != null && recordId != '') {
                    condition = 'Id = \''+ recordId + '\'';
                    quote = (new SLT_IQVIA_Quote().getQuotesByCondition(new Set<String>{CON_CPQ.Id, CON_CPQ.START_DATE, CON_CPQ.END_DATE, CON_CPQ.IQVIA_QUOTE_PRICING_TOOL, CON_CPQ.CURRENCYISOCODE}, condition, null))[0];
                    unoTool = quote.Pricing_Tools__c.contains(';') ? null : quote.Pricing_Tools__c;
                }
                items.isSuccess = true;
                for (Object traceRecordData : (List<Object>)JSON.deserializeUntyped(jsonBody)) {
                    Map<String, Object> recordMap = (Map<String, Object>) traceRecordData;
                    Quote_Line_Item__c newRecord = new Quote_Line_Item__c();
                    items.quote = String.valueOf(recordMap);
                    flag = false;
                    if ((recordMap.containsKey('Tool') && recordMap.get('Tool') != null && fieldMappings.containsKey('Tool') && fieldMappings.get('Tool') == 'Pricing_Tool__c') || 
                        (headerInfo.containsKey('internalCall') && headerInfo.get('internalCall') == true && recordMap.containsKey('Pricing_Tool__c') && recordMap.get('Pricing_Tool__c') != null) || unoTool != null) {
                        flag = true;
                        for (String key : recordMap.keySet()) {
                            if (headerInfo != null && headerInfo.containsKey('internalCall') && headerInfo.get('internalCall') == true && objFields.contains(key)) {
                                newRecord.put(key, recordMap.get(key));
                            } else if (fieldMappings.containsKey(key)) {
                                String fieldApiName = fieldMappings.get(key);
                                newRecord.put(fieldApiName, recordMap.get(key));
                            }
                        }
                    }
                    if (flag) {
                        recordsToInsert.add(newRecord);
                    } else if (headerInfo != null && headerInfo.containsKey('partialSave') && headerInfo.get('partialSave') == false) {
                        break;
                    }
                }
            }
            if (recordsToInsert.size() > 0) {
                recordsToInsert = updateStartEndDate(recordsToInsert, quote, unoTool);
                if (!items.isSuccess && headerInfo != null && headerInfo.containsKey('partialSave') && (Boolean)headerInfo.get('partialSave') == true) {
                    uowQuoteLines.registerNew(recordsToInsert);
                    uowQuoteLines.commitWork();
                    items.errorMsg += ' Record other than failed is inserted partially.';
                } else if (items.isSuccess) {
                    uowQuoteLines.registerNew(recordsToInsert);
                    uowQuoteLines.commitWork();
                }
            } else {
                items.isSuccess = false;
                items.errorMsg = 'Header information from Quote is missing.';
            }
            return items;
        } catch (System.Exception e) {
            items.isSuccess = false;
            items.errorMsg = e.getMessage();
            return items;
        }
    }
    public static List<Quote_Line_Item__c> updateStartEndDate(List<Quote_Line_Item__c> recordsToInsert, Quote__c quote, String tool) {
        
        for (Quote_Line_Item__c qli : recordsToInsert) {
            qli.Pricing_Tool__c = tool;
            if (quote.Start_Date__c != null) {
                qli.Start_Date__c = quote.Start_Date__c;
            }
            if (quote.End_Date__c != null) {
                qli.End_Date__c = quote.End_Date__c;
            }
            if (qli.Bundle_Product__c != null && qli.Option_Product__c == null) {
                qli.Include_In_Summary__c = True;
            }
            if (quote.CurrencyIsoCode != null) {
                qli.CurrencyIsoCode = quote.CurrencyIsoCode;
            }
        }
        return recordsToInsert;
    }
    public class WPR_CPQ_ReturnItems {
        @AuraEnabled
        public Boolean isSuccess {get; set;}
        @AuraEnabled
        public String errorMsg {get; set;}
        @AuraEnabled
        public String quote {get; set;}
    }
}