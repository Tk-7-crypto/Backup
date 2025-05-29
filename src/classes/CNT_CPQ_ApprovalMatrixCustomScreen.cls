public without sharing class CNT_CPQ_ApprovalMatrixCustomScreen {

    @AuraEnabled
    public static List<ApprovalMatrixWithKeyWrapper> getApproverGroups(String approverGroupName, String opportunityType, String customerType,
        String therapyArea, String region, String role, String sales, String md, string customerEmail, String globalProjectUnit, String customer) {
        
        List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().getApproverGroupWithApprovalMatrixListWithApproverGroupFilter(approverGroupName, opportunityType,
            customerType, therapyArea, region, role, sales, md, customerEmail, globalProjectUnit, customer);
            
        List<ApprovalMatrixWithKeyWrapper> approvalMatrixWithKeyWrapperList = new List<ApprovalMatrixWithKeyWrapper>();
        for(Approver_Group__c approverGroup : approverGroupList) {     
            Approver_Group__c approverGroupObj = new Approver_Group__c(Id = approverGroup.Id, Name = approverGroup.Name);
            List<ApprovalMatrixWrapper> approvalMatrixWrapperList = new List<ApprovalMatrixWrapper>();
            for(Approval_Matrix__c approvalMatrix : approverGroup.Approval_Matrix__r) {
                ApprovalMatrixWrapper approvalMatrixWrapper = new ApprovalMatrixWrapper(approvalMatrix, false,false);
                approvalMatrixWrapperList.add(approvalMatrixWrapper);
            }            
            approvalMatrixWithKeyWrapperList.add(new ApprovalMatrixWithKeyWrapper(approverGroupObj, approvalMatrixWrapperList));
        }
        return approvalMatrixWithKeyWrapperList;
    }
    
    @AuraEnabled
    public static void updateApprovalMatrix(String approvalMatrixData) {
        List<ApprovalMatrixWithKeyWrapper> approvalMatrixWithKeyWrapper = (List<ApprovalMatrixWithKeyWrapper>)JSON.deserialize(approvalMatrixData, List<ApprovalMatrixWithKeyWrapper>.class);
        List<Approval_Matrix__c> approvalMatrixToUpdate = new List<Approval_Matrix__c>();
        for(ApprovalMatrixWithKeyWrapper approvalMatrixWithKey : approvalMatrixWithKeyWrapper) {
            for(ApprovalMatrixWrapper approvalWrapper : approvalMatrixWithKey.approvalMatrixWrapperObj){
                if(approvalWrapper.isEdit == true) {
                    approvalMatrixToUpdate.add(approvalWrapper.approvalMatrix);
                }
            }
        }
        if(approvalMatrixToUpdate.size() > 0){
            update approvalMatrixToUpdate;
        }
    }
    
    @AuraEnabled
    public static void deleteApprovalMatrix(String approvalMatrixData) {
        List<ApprovalMatrixWithKeyWrapper> approvalMatrixWithKeyWrapper =
            (List<ApprovalMatrixWithKeyWrapper>)JSON.deserialize(approvalMatrixData, List<ApprovalMatrixWithKeyWrapper>.class);
        List<Approval_Matrix__c> approvalMatrixToDelete = new List<Approval_Matrix__c>();
        for(ApprovalMatrixWithKeyWrapper approvalMatrixWithKey : approvalMatrixWithKeyWrapper) {
            for(ApprovalMatrixWrapper approvalWrapper : approvalMatrixWithKey.approvalMatrixWrapperObj){
                if(approvalWrapper.isDelete == true) {
                    approvalMatrixToDelete.add(approvalWrapper.approvalMatrix);
                }
            }
        }
        if(approvalMatrixToDelete.size() > 0){
            delete approvalMatrixToDelete;
        }
    }
    
    @AuraEnabled
    public static List<String> getSelectOptions(sObject objObject, String fieldName) {
    
        List <String> allOptions = new List <String> ();
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        List < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();            
        for (Schema.PicklistEntry a: values) {
            allOptions.add(a.getValue());
        }        
        allOptions.sort();
        return allOptions;
    }
    
    @AuraEnabled
    public static List<String> getValueSet(String sale, String role) {
        Set <String> allOptions = new Set <String> ();
        Set<String> roleSet = CON_CPQ.ROLE_PICKLIST_SET;
        Set<String> salesTypeSet = CON_CPQ.SALES_TYPE_PICKLIST_SET;
        List<Account_Directory__c> accountDirectoryList = new List<Account_Directory__c>();
        List<Country_Sales_Head__c> countrySalesHeadList = new List<Country_Sales_Head__c>();
        if(roleSet.contains(role)) {
            accountDirectoryList = SLT_AccountDirectory.selectAccountDirectoryByCondition(role, CON_CPQ.NONE, CON_CPQ.NONE);
            for(Account_Directory__c accountDirectory : accountDirectoryList) {
                allOptions.add(accountDirectory.Account__r.name);
            }         
        } else if(role == CON_CPQ.ROLE_SALES_TYPE && (salesTypeSet.contains(sale) || sale == CON_CPQ.SALE_LARGE)) {
            countrySalesHeadList = SLT_CountrySalesHead.selectCountrySalesHeadByFilter(sale,CON_CPQ.NONE,CON_CPQ.NONE);
            for(Country_Sales_Head__c countrySalesHeadObj : countrySalesHeadList) {
                allOptions.add(countrySalesHeadObj.Country_Sales__c);
            }	  
        }
        return new List<String>(allOptions);
    }
    
    @AuraEnabled
    public static List<String> getCustomerValues(String sale, String role, String customer) {
        List<String> customerNameAndEmailList = new List<String>();
        Set<String> roleSet = CON_CPQ.ROLE_PICKLIST_SET;
        Set<String> salesTypeSet = CON_CPQ.SALES_TYPE_PICKLIST_SET;
        List<Account_Directory__c> accountDirectoryList = new List<Account_Directory__c>();
        List<Country_Sales_Head__c> countrySalesHeadList = new List<Country_Sales_Head__c>();
        
        if(roleSet.contains(role)) {
            accountDirectoryList = SLT_AccountDirectory.selectAccountDirectoryByCondition(role, customer, CON_CPQ.NONE);
            if(accountDirectoryList.size() > 0){
                customerNameAndEmailList.add(accountDirectoryList.get(0).Approver_Name__c);
                customerNameAndEmailList.add(accountDirectoryList.get(0).Approver_Email__c);
            }
        } else if(role == CON_CPQ.ROLE_SALES_TYPE && (salesTypeSet.contains(sale) || sale == CON_CPQ.SALE_LARGE)) {
            countrySalesHeadList = SLT_CountrySalesHead.selectCountrySalesHeadByFilter(sale,customer,CON_CPQ.NONE);
            if(countrySalesHeadList.size() > 0){
                customerNameAndEmailList.add(countrySalesHeadList.get(0).Approver_Name__c);
                customerNameAndEmailList.add(countrySalesHeadList.get(0).Approver_Email__c);
            }
        }
        return customerNameAndEmailList;
    }
    
    @AuraEnabled
    public static Approval_Matrix__c createApprovalMatrix(Approval_Matrix__c approvalRecord, Id approvalGroupId, String role){
        approvalRecord.Approver_Group__c = approvalGroupId;
        approvalRecord.Role__c = role;
        insert approvalRecord;
        return approvalRecord;
    }
    
    public class ApprovalMatrixWrapper{
    
        @AuraEnabled public Approval_Matrix__c approvalMatrix{get;set;}
        @AuraEnabled public Boolean isEdit{get;set;}
        @AuraEnabled public Boolean isDelete{get;set;}
        public ApprovalMatrixWrapper(Approval_Matrix__c approvalMatrix, Boolean isEdit, Boolean isDelete){
            this.approvalMatrix = approvalMatrix;
            this.isEdit = isEdit;
            this.isDelete = isDelete;
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