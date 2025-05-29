global with sharing class CPQ_ProductAttributeCallback implements Apttus_Config2.CustomClass.IProductAttributeCallback {
    public static String selectPricingTool;
    public static Id quoteId;
    public static List<Quote_Requisites__c> quoteRequisitesList = new List<Quote_Requisites__c>();
    //This is the first method that is executed when the callback is invoked.
    global void start(Apttus_Config2.ProductConfiguration cart) {
        List<PermissionSetAssignment> psaList = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =: CON_CPQ.Q2_Permission_Set];
        if (psaList.size() > 0) {																																																  
            Id pId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
            Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(pId, new Set<String>{CON_CPQ.ID, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL, CON_CPQ.IQVIA_QUOTE});
            selectPricingTool = proposal.Select_Pricing_Tool__c;
            quoteId = proposal.IQVIA_Quote__c;
            Set<Id> quoteIdSet = new Set<Id>{quoteId};
            if (selectPricingTool == CON_CPQ.Q2_Solutions) {
                String condition = 'Quote__c IN: quoteIdSet AND Type__c = \'' + CON_CPQ.STUDY_TYPE + '\'';
                quoteRequisitesList = new SLT_QuoteRequisites().getQuoteRequisitesRecord(quoteIdSet, new Set<String>{CON_CPQ.Id, CON_CPQ.SERVICE_LINE, CON_CPQ.BID_HISTORY_STUDY_NUMBER, CON_CPQ.CLINICAL_TYPE, CON_CPQ.NUMBER_OF_ANALYTE, CON_CPQ.SPECIMEN_TYPE}, condition);
            }
        }
    }
    //This method is invoked only when you enable Has Attribute field for the product.
    global void setDefaults(Apttus_Config2.LineItem lineItem, Apttus_Config2__ProductAttributeValue__c prodAttr) {
        Apttus_Config2__LineItem__c prodLineItem = lineItem.getLineItemSO();
        if (selectPricingTool == CON_CPQ.Q2_Solutions && quoteRequisitesList.size() > 0) {
            UTL_CPQ_ProductAttributeCallback.autoSelectAttributeForQ2Solution(prodLineItem, prodAttr, quoteRequisitesList);
        }
    }
    //This the last method that is executed after the callback is invoked.
    global void finish() {}
}