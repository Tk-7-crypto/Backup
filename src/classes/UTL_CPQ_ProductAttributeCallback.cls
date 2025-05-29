public class UTL_CPQ_ProductAttributeCallback {
    public static void autoSelectAttributeForQ2Solution(Apttus_Config2__LineItem__c lineItem, Apttus_Config2__ProductAttributeValue__c prodAttribute, List<Quote_Requisites__c> quoteRequisitesList) {
        if (quoteRequisitesList.size() >= (Integer)lineItem.Apttus_Config2__LineNumber__c) {
            prodAttribute.Study_Number__c = quoteRequisitesList[(Integer)lineItem.Apttus_Config2__LineNumber__c - 1].Study_Number__c;
            prodAttribute.Clinical_Type__c = quoteRequisitesList[(Integer)lineItem.Apttus_Config2__LineNumber__c - 1].Clinical_Type__c;
            prodAttribute.Specimen_Type__c = quoteRequisitesList[(Integer)lineItem.Apttus_Config2__LineNumber__c - 1].Specimen_Type__c;
            prodAttribute.Number_of_Analyte__c = quoteRequisitesList[(Integer)lineItem.Apttus_Config2__LineNumber__c - 1].Number_of_Analyte_Global__c;
            lineItem.Quote_Requisites__c = quoteRequisitesList[(Integer)lineItem.Apttus_Config2__LineNumber__c - 1].Id;
        }
    }
}