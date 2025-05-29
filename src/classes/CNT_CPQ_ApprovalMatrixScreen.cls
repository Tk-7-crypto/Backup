public class CNT_CPQ_ApprovalMatrixScreen {

    @auraEnabled
    public static List<ApprovalMatrixWithKeyWrapper> getApproverGroups() {
        List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().getApproverGroupWithApprovalMatrixList();
        List<ApprovalMatrixWithKeyWrapper> ApprovalMatrixWithKeyWrapperList = new List<ApprovalMatrixWithKeyWrapper>();
        for(Approver_Group__c approverGroup : approverGroupList) {     
            Approver_Group__c approverGroupObj = new Approver_Group__c(Id = approverGroup.Id, Name = approverGroup.Name);
            List<ApprovalMatrixWrapper> approvalMatrixWrapperList = new List<ApprovalMatrixWrapper>();
            for(Approval_Matrix__c approvalMatrix : approverGroup.Approval_Matrix__r) {
                ApprovalMatrixWrapper approvalMatrixWrapper = new ApprovalMatrixWrapper(approvalMatrix, false);
                approvalMatrixWrapperList.add(approvalMatrixWrapper);
            }            
            ApprovalMatrixWithKeyWrapperList.add(new ApprovalMatrixWithKeyWrapper(approverGroupObj, approvalMatrixWrapperList));
        }        
        return ApprovalMatrixWithKeyWrapperList;
    }
    
    @auraEnabled
    public static void updateApprovalMatrix(String approvalMatrixData) {
    
        List<ApprovalMatrixWithKeyWrapper> approvalMatrixWithKeyWrapper = (List<ApprovalMatrixWithKeyWrapper>)JSON.deserialize
            (approvalMatrixData,List<ApprovalMatrixWithKeyWrapper>.class);
        List<Approval_Matrix__c> approvalMatrixToUpdate = new List<Approval_Matrix__c>();
        for(ApprovalMatrixWithKeyWrapper approvalMatrixWithKey : approvalMatrixWithKeyWrapper) {
            for(ApprovalMatrixWrapper approvalWrapper : approvalMatrixWithKey.approvalMatrixWrapperObj){
                if(approvalWrapper.isEdit==true) {
                    approvalMatrixToUpdate.add(approvalWrapper.approvalMatrix);
                }
            }
        }
        if(approvalMatrixToUpdate.size()>0){
            update approvalMatrixToUpdate;
        }
        
    }
    
    public class ApprovalMatrixWrapper{
    
       @AuraEnabled public Approval_Matrix__c approvalMatrix{get;set;}
       @AuraEnabled public Boolean isEdit{get;set;}
       public ApprovalMatrixWrapper(Approval_Matrix__c approvalMatrix, Boolean isEdit){
           this.approvalMatrix = approvalMatrix;
           this.isEdit = isEdit;
        }
   }
    
    public class ApprovalMatrixWithKeyWrapper {

        @AuraEnabled public Approver_Group__c key{get;set;}
        @AuraEnabled public List<ApprovalMatrixWrapper> approvalMatrixWrapperObj{get;set;}
        public ApprovalMatrixWithKeyWrapper(Approver_Group__c key, List<ApprovalMatrixWrapper> approvalMatrixWrapperObj){
           this.key = key;
           this.approvalMatrixWrapperObj = approvalMatrixWrapperObj;
        }
    }
}