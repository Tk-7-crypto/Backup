public with sharing class SLT_ApproverGroup extends fflib_SObjectSelector {
    public SLT_ApproverGroup() {
        super(false, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Approver_Group__c.Id,
            Approver_Group__c.Name
        };
    }    
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Approver_Group__c.sObjectType;
    }
    
    public List<Approver_Group__c> selectById(Set<ID> idSet) {
        return (List<Approver_Group__c>) selectSObjectsById(idSet);
    }
    
    public List<Approver_Group__c> getApproverGroupWithApprovalMatrixList() {
        return Database.query('SELECT Id, Name, (SELECT Id, Name, Approver_Group__c, Opportunity_Type__c, Region__c, X0_5M_USD__c, X5_10M_USD__c,'+
            'X10_20M_USD__c,' + 'X20_50M_USD__c, X50M_USD__c FROM Approval_Matrix__r) FROM Approver_Group__c');
    }
    
    public List<Approver_Group__c> getApproverGroupWithApprovalMatrixListWithApproverGroupFilter(String approverGroupName, String opportunityType,
        String customerType, String therapyArea, String region, String role, String sales, String md, String customerEmail,
        String globalProjectUnit, String customer) {  
        
        String approverGroupType = String.escapeSingleQuotes(approverGroupName.trim());
        String val = '\'%' + String.escapeSingleQuotes(approverGroupName.trim()) + '%\'';
        String approverGroupOpportunity = '\'%' + String.escapeSingleQuotes(opportunityType.trim()) + '%\'';
        
        if(approverGroupType == CON_CPQ.APPROVER_GROUP_TSSU){
            return Database.query('SELECT Id, Name, (SELECT Id, Name, Approver_Group__c, Opportunity_Type__c, Role__c, Sales__c, Md__c, Region__c,' +
                'Global_Project_Unit__c, Customer__c, ' + customerType + ' ,Therapy_Area__c, ' + customerEmail + ' FROM Approval_Matrix__r WHERE ' +  customerType +
                ' != null AND Opportunity_Type__c LIKE ' + approverGroupOpportunity + 'AND Region__c LIKE \'' + region + '\' AND Therapy_Area__c LIKE \'' + therapyArea +
                '\' AND Role__c LIKE \'' + role + '\' ) FROM Approver_Group__c Where Name LIKE ' + val);
        }
        else if(approverGroupType == CON_CPQ.APPROVER_GROUP_PL){
            return Database.query('SELECT Id, Name, (SELECT Id, Name, Approver_Group__c, Opportunity_Type__c, Role__c, Sales__c, Md__c, Region__c,' +
                'Global_Project_Unit__c, Customer__c, ' + customerType + ' ,Therapy_Area__c, ' + customerEmail + ' FROM Approval_Matrix__r WHERE ' + customerType +
                ' != null AND Opportunity_Type__c LIKE ' + approverGroupOpportunity + 'AND Role__c LIKE \'' + role + '\' AND Therapy_Area__c LIKE \'' + therapyArea +
                '\' AND Global_Project_Unit__c LIKE \'' + globalProjectUnit + '\' ) FROM Approver_Group__c Where Name LIKE ' + val);
        }
        else if(approverGroupType == CON_CPQ.APPROVER_GROUP_PL_CUSTOMER){
            return Database.query('SELECT Id, Name, (SELECT Id, Name, Approver_Group__c, Opportunity_Type__c, Role__c, Sales__c, Md__c, Region__c,' +
                'Global_Project_Unit__c, Customer__c, ' + customerType + ' ,Therapy_Area__c, ' + customerEmail +  ' FROM Approval_Matrix__r WHERE ' + customerType +
                ' != null AND Opportunity_Type__c LIKE ' + approverGroupOpportunity + 'AND Role__c LIKE \'' + role + '\' AND Therapy_Area__c LIKE \'' + therapyArea +
                '\' AND Customer__c LIKE \'' + customer + '\') FROM Approver_Group__c Where Name LIKE ' + '\'%' + CON_CPQ.APPROVER_GROUP_PL + '%\'');
        }
        else{
            return Database.query('SELECT Id, Name, (SELECT Id, Name, Approver_Group__c, Opportunity_Type__c, Role__c, Sales__c, Md__c, Region__c,' +
                'Global_Project_Unit__c, Customer__c, ' + customerType + ' ,Therapy_Area__c, ' + customerEmail + ' FROM Approval_Matrix__r WHERE '+ customerType +
                ' != null AND Opportunity_Type__c LIKE ' + approverGroupOpportunity + 'AND Region__c LIKE \'' + region + '\' AND Sales__c LIKE \'' + sales +
                '\' AND MD__c LIKE \'' + md + '\' AND Role__c LIKE \'' + role + '\') FROM Approver_Group__c Where Name LIKE ' + val);
        }
    }
}