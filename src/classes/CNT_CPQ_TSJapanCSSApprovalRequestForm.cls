/**
 * Controller class for "CSS Submit For Approval" action of TS Japan Proposal
 * version : 1.0 
 */
public with sharing class CNT_CPQ_TSJapanCSSApprovalRequestForm {
    
    public static Map<String, CurrencyType> isoCodeTocurrencyTypeMap {get; set;}
    
    @AuraEnabled
    public static void submitForCSSApproval(String approvalDetailsJSON) {
        ApprovalDetailsWrapper approvalDetails = (ApprovalDetailsWrapper) System.JSON.deserialize(approvalDetailsJSON, ApprovalDetailsWrapper.class);
        
        // Ideally this won't be the case where proposal id is blank
        if(String.isBlank(approvalDetails.proposalId)){
            throw new AuraHandledException('No Proposal Id found to submit for CSS approval');
        }
        
        // Get Approver User Id
        List<User> approverUser = new SLT_User().selectUserByEmail(new Set<String>{approvalDetails.approvalUserEmail});
        
        if(approverUser.size() == 0){
            throw new AuraHandledException('No approver found for CSS approval.');
        }
        
        try {
        
            String target = '<table class="ql-table-blob" border="1" style="width: 700px;margin-top: 0.5rem">';
            String replacement = '<table class="ql-table-blob" border="1" style="width: 700px;" cellspacing="0" cellpadding="0">';
            String templateBody = approvalDetails.templateBody.replace(target, replacement);
            
            target = '<p><br></p><p><b>Product Information:</b></p>';
            replacement = '<p><b>Product Information:</b></p>';
            templateBody = templateBody.replace(target, replacement);
            
            // Store Template Body in Proposal field "Final Review Call Notes"
            // Update "Is_Strategy_Call_Required__c" if Approver and Submitter users are same
            // Update "MedDRA_Classification__c" to ser selected approver name
            updateProposal(approvalDetails.proposalId, templateBody, approverUser[0]);
            
            // Submit for CSS Approval process
            List<Apttus_Proposal__Proposal__c> proposalList = new SLT_Proposal().getProposalFieldsById(new Set<Id> {approvalDetails.proposalId}, new Set<String> {CON_CPQ.Id, CON_CPQ.OWNER});
            submitProposalForCSSApproval(proposalList[0], approverUser[0].Id);
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<CPQ_TS_CSS_Approvers__c> getCSSApprovers(){
        return CPQ_TS_CSS_Approvers__c.getall().values();
    }
    
    @AuraEnabled
    public static ProposalDetails getProposalWithLineItems(Id proposalId){
        Set<String> fieldSet = new Set<String> {
            CON_CPQ.OPPORTUNITY_NUMBER,
            CON_CPQ.PROPOSAL_OPPORTUNITY_NAME,
            CON_CPQ.PROPOSAL_RELATED_ACCOUNT_NAME,
            CON_CPQ.ACCOUNT_TIER_0_5,
            CON_CPQ.EXPECTED_START_DATE,
            CON_CPQ.EXPECTED_END_DATE,
            CON_CPQ.QUOTE_AMOUNT,
            CON_CPQ.SPECIAL_PRICING_EXPLANATION,
            CON_CPQ.SPECIAL_DISCOUNT,
            CON_CPQ.MIN_GROSS_MARGIN,
            CON_CPQ.NAME,
            CON_CPQ.CurrencyIsoCode,
            CON_CPQ.VENDOR_SELECTION_REASON,
            CON_CPQ.VENDOR_COMPITITION_DONE,
            CON_CPQ.VENDOR_USE
        };
                                                
        Set<String> lineItemFieldSet = new Set<String> {
            CON_CPQ.QUOTE_LINE_ITEM_NETPRICE,
            CON_CPQ.QUOTE_LINE_ITEM_RELATED_PRODUCT_NAME,
            CON_CPQ.QUOTE_LINE_ITEM_GROSS_MARGIN,
            CON_CPQ.QUOTE_LINE_ITEM_PASS_THROUGH
        };
                
        List<Apttus_Proposal__Proposal__c> proposals = new SLT_Proposal().getQuoteWithLineItemsById(
            new Set<Id>{proposalId},
            fieldSet,
            lineItemFieldSet
        );
        
        ProposalDetails proposalObj = new ProposalDetails();
        proposalObj.proposalSObject = proposals[0];
        isoCodeTocurrencyTypeMap = new SLT_CurrencyType().getAllCurrencyTypeByIsoCode();
        
        if(proposals[0].CurrencyIsoCode != CON_CPQ.USD){
            
            proposalObj.quoteAmountInUSD = getAmountInUSD(proposals[0].CurrencyIsoCode, (double)proposals[0].Quote_Amount__c);
                                                     
            proposalObj.quoteAmountInJPY = proposalObj.proposalSObject.Quote_Amount__c.setScale(isoCodeTocurrencyTypeMap.get(proposals[0].CurrencyIsoCode).DecimalPlaces);
        }
        
        List<ProposalLineItemDetails> proposalLineItems = new List<ProposalLineItemDetails>(); 
        for(Apttus_Proposal__Proposal_Line_Item__c proposalLineItem : proposals[0].R00N70000001yUfBEAU){
            
            ProposalLineItemDetails proposalLineItemDetail = new ProposalLineItemDetails();
            proposalLineItemDetail.proposalLineItemSObject = proposalLineItem;
            
            if(proposals[0].CurrencyIsoCode != CON_CPQ.USD){
                proposalLineItemDetail.netPriceInUSD = getAmountInUSD(proposals[0].CurrencyIsoCode, (double)proposalLineItem.Apttus_QPConfig__NetPrice__c);
                proposalLineItem.Apttus_QPConfig__NetPrice__c = proposalLineItem.Apttus_QPConfig__NetPrice__c.setScale(isoCodeTocurrencyTypeMap.get(proposals[0].CurrencyIsoCode).DecimalPlaces);
            }
        
            proposalLineItems.add(proposalLineItemDetail);
        }
        proposalObj.proposalLineItems = proposalLineItems;
        return proposalObj;
    }
    
    public static void submitProposalForCSSApproval(Apttus_Proposal__Proposal__c proposalObj, Id approver) {
        List<Id> approverIds = new List<Id>();
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(proposalObj.Id);
        request.setSubmitterId(UserInfo.getUserId()); // Logged in user is the submitter
        request.setNextApproverIds(new List<Id>{approver});
        Approval.ProcessResult result = Approval.process(request);
        CPQ_RMUtility.unlockApprovalProcess(new List<Apttus_Proposal__Proposal__c>{proposalObj});
    }

    public static void updateProposal(Id proposalId, String templateBody, User approverUser) {
        if(proposalId != null){
            Apttus_Proposal__Proposal__c proposalObj = new Apttus_Proposal__Proposal__c();
            proposalObj.Id = proposalId;
            proposalObj.Final_Review_Call_Notes__c = templateBody;
            proposalObj.MedDRA_Classification__c = approverUser.Name;
            proposalObj.Is_Strategy_Call_Required__c = approverUser.Id == UserInfo.getUserId() ? true : false;
            update proposalObj;
        }
    }
    
    // Converts amount in USD format
    public static Decimal getAmountInUSD(String fromCurrency, Double amountToConvertInUSD){
        Decimal amountInUSD = CPQ_Utility.getCurrencyConvertedValue(
            isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).conversionRate, 
            isoCodeTocurrencyTypeMap.get(fromCurrency).conversionRate, 
            amountToConvertInUSD
        );
        
        amountInUSD = amountInUSD.setScale(isoCodeTocurrencyTypeMap.get(CON_CPQ.USD).DecimalPlaces);
        return amountInUSD;
    }
    
    public class ApprovalDetailsWrapper {
        @AuraEnabled public String proposalId {get;set;}
        @AuraEnabled public String approvalUserEmail {get;set;}
        @AuraEnabled public String subject {get;set;}
        @AuraEnabled public String templateBody {get;set;}        
    }
    
    public class ProposalDetails {
        @AuraEnabled
        public Apttus_Proposal__Proposal__c proposalSObject {get; set;}
        @AuraEnabled
        public List<ProposalLineItemDetails> proposalLineItems {get; set;}
        @AuraEnabled
        public Decimal quoteAmountInUSD {get; set;}
        @AuraEnabled
        public Decimal quoteAmountInJPY {get; set;}
    }
    
    public class ProposalLineItemDetails {
        @AuraEnabled
        public Apttus_Proposal__Proposal_Line_Item__c proposalLineItemSObject {get; set;}
        @AuraEnabled
        public Decimal netPriceInUSD {get; set;}
    }
}