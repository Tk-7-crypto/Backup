public class EXT_CRM_SubmitBNF {
    public BNF2__c currentBNFRecord {get;set;}
    public Boolean isError {get;set;}
    public String errorMessage {get;set;}
    public EXT_CRM_SubmitBNF(ApexPages.StandardController controller) {
        currentBNFRecord = (BNF2__c)controller.getRecord();
        isError = false;
        errorMessage = '';
        currentBNFRecord = [Select BNF_Status__c, Revenue_Analyst__c, Revenue_Analyst__r.Name, Client__r.PO_Number__c, Client_PO_Number__c, Cover_Sheet_Company__r.Cover_Sheet__c, Cover_Sheet_Company__c , Cover_Sheet_Contact__c , Cover_Sheet_Address__c,Revenue_Analyst__r.User__c, Opportunity__c, Addendum__c from BNF2__c where Id =: currentBNFRecord.id];
    }
    
    public PageReference submitForApproval(){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        if(currentBNFRecord.Addendum__c == true) {
            req1.setComments('Revised BNF submitted to ' + currentBNFRecord.Revenue_Analyst__r.Name);
        }
        else {
            req1.setComments('Initial BNF creation and submitted to ' + currentBNFRecord.Revenue_Analyst__r.Name);
        }
        req1.setNextApproverIds(new List<Id>{currentBNFRecord.Revenue_Analyst__r.User__c});
        req1.setObjectId(currentBNFRecord .id);
        try{
            Approval.ProcessResult result = Approval.process(req1);
        }
        catch(Exception e){
            errorMessage = e.getMessage();
            isError = true;
        }
        
        return null;
    }
}