public class CNT_CRM_DeleteBNF {
    
    private BNF2__c bnfRecord;
    
    
    public CNT_CRM_DeleteBNF(ApexPages.StandardController controller) {
        bnfRecord = (BNF2__c)controller.getRecord();
    }
    
    
    public PageReference deleteBNFRecord() {
        try {
            delete bnfRecord;
            String bnfPrefix = BNF2__c.SobjectType.getDescribe().getKeyPrefix();
            return new PageReference('/' + bnfPrefix);
        } catch(Exception e) {
            return null;
        }
    }
    
}