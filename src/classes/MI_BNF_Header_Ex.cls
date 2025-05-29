public with sharing class MI_BNF_Header_Ex {
    
    
    public MIBNF2__c MIBNF;
    public Boolean IsEditable = true;
    public Boolean UserIsSysAdmin {get;private set;}
    public Boolean ErrorFlag{get;private set;}
    private Boolean hasAccessBNFAll;
     
    public MI_BNF_Header_Ex (ApexPages.StandardController controller) 
    { 
        IsEditable = true;
        this.hasAccessBNFAll = false;
        List<PermissionSetAssignment> permSetAssList = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() and  PermissionSet.Name = 'Modify_all_privileges_on_BNF'];
        if(permSetAssList.size() > 0) {
            hasAccessBNFAll = true; 
        }
        ErrorFlag=false;
        MIBNF = (MIBNF2__c)controller.getRecord();
        User CurrentUser = [select Id,Profile.Name from User where Id = :userInfo.getUserId()];
        this.UserIsSysAdmin = CurrentUser.Profile.Name.toUpperCase().contains('SYSTEM ADMINISTRATOR');         
		Set<Id> MIBNF_Comp_Id_Set = new Set<Id>();
        for (MIBNF_Component__c MIBNF_Comp:[Select Id,BNF_Status__c From MIBNF_Component__c where MIBNF__c=:MIBNF.Id])
        {
            MIBNF_Comp_Id_Set.add(MIBNF_Comp.Id);            
        }       
        //  Check for any pending approvals on any of the child MIBNF's
        List<ProcessInstanceWorkitem> P_list = new List<ProcessInstanceWorkitem>([select Id, ProcessInstance.Id, ProcessInstance.TargetObjectId, ActorId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId in :MIBNF_Comp_Id_Set]);
        if (P_list.size() > 0)         
             IsEditable = false;
        //  If any of the child MIBNF's is assigned to the current user, allow them to edit
        for (ProcessInstanceWorkitem P:P_list)
        {
        	if (P.ActorId == userInfo.getUserId())
        		IsEditable = true;
        }
               
    }
    
    // Prevent user from editing Header Details if any child BNF in Approval Stage
    public Pagereference Redirect()
    {
             
         if (!IsEditable && !UserIsSysAdmin && !hasAccessBNFAll)
         {
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Multi Invoice Header cannot be edited once related BNF\'s have been approved.');
             ApexPages.addMessage(errMsg); 
             ErrorFlag=true;
         }
        return null;         
    }
    
    // Cancel Action
    public Pagereference Cancel()
    {
         pageReference retURL=new pageReference(ApexPages.currentPage().getParameters().get('retURL'));
         return retURL;
         
     }
}