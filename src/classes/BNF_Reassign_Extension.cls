/*
* Name              : BNF_Reassign_Extension
* Created By        : Pramod Kumar
* Created Date      : 23 Nov, 2016
* Revision          : 
* Description       : Controller Extension for BNF_Reassign Page
*/
public without sharing class  BNF_Reassign_Extension {
    public BNF2__c bnf{get;set;} 
    //private static final String ACTION_REMOVED = 'Removed';
    //private Id OldRAId;
    public String ApproverComments {public get;public set;}
    public boolean isMassReassign {get;set;}
    private List<Id> reassignIdList ;
    public boolean isOwnerQueue{get;set;}
    public String buttonBack {get;set;}
    public Id recordId{set; get;}
    public String comment{set; get;}
    
    
    /**
   * constructor for BNF_Reassign Page
   * @param 
   * @return 
   */
    public BNF_Reassign_Extension() {
        buttonBack = 'Cancel';
        isMassReassign = false;
        isOwnerQueue = false;
        String bnfId = ApexPages.currentPage().getParameters().get('id');
        String reassignIds = ApexPages.currentPage().getParameters().get('ids');
        if(bnfId != null) {
            bnf = [select Id, Name, Comments__c , createdById, Revenue_Analyst__c, createdDate , First_RA__C, SAP_SD_Error_Message__c, Revenue_Analyst__r.Owner.Type, Reassigned_Revenue_Analyst__c from BNF2__c where id =: bnfId];
            if(bnf.Revenue_Analyst__r.Owner.Type == 'Queue') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'BNF\'s assigned to GFSS RA\'s cannot be reassigned, they must be rejected and resubmitted'));
                isOwnerQueue = true;
                buttonBack = 'Back';
            } 
          
        }
        System.debug('reassignIds--'+reassignIds);
        if(reassignIds != null) {
            isMassReassign = true;
            BNF = new BNF2__c();
            reassignIdList = reassignIds.split(',');
            System.debug('reassignIdList--'+reassignIdList);
        }     
    }
    
    /**
   * method used to reassign Revenue Analyst to BNF Record
   * @param : None
   * @return : instanse of PageReference 
   */
    public PageReference reassignRA() {
        List<Id> targetObjectIds = new List<Id>();
        if(isMassReassign) {
            targetObjectIds.addAll(reassignIdList);
        } else {
            targetObjectIds.add(this.BNF.id);
        }
        Savepoint sp = Database.setSavepoint();
        try {
                List<ProcessInstanceWorkitem> workItemList = [SELECT Id, ActorId, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :targetObjectIds];
                Revenue_Analyst__c revenueAnalyst = [Select id , User__c from Revenue_Analyst__c where id = :this.BNF.Reassigned_Revenue_Analyst__c];
                for(ProcessInstanceWorkitem wi : workItemList) {
                    wi.ActorId = revenueAnalyst.User__c;
                }
                upsert workItemList;
                //upsert BNF;
            
        } catch(Exception exp) {
            Database.rollback( sp );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception Occured '+exp));
            return null;
        }
        return Cancel();
                
    }
    
    /**
     *  Method is used to recall the approval process.  
     */ 
    public PageReference Reassign_Request(){
        this.recordId =   ApexPages.currentPage().getParameters().get('Id');
        String cmt ;
        if(comment !=null && comment.length() > 3500){
            cmt = comment.SubString(0,3500) + '...';
        }else{
           cmt =  comment;
        }
         Savepoint sp = Database.setSavepoint();
        try{
            Revenue_Analyst__c revenueAnalyst1 = [Select id , User__c from Revenue_Analyst__c where id = :this.BNF.Reassigned_Revenue_Analyst__c];
            Reassign__e rassign = new Reassign__e(RecordId__c = recordId, Reassign_Approver__c =revenueAnalyst1.User__c, Comment__c = cmt);
            Database.SaveResult result1 = EventBus.publish(rassign);
        }catch(Exception exp) {
            Database.rollback( sp );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception Occured '+exp));
            return null;
        }
        
        return Cancel();
    }
    
    public PageReference Cancel(){
        PageReference pageRef;
        if(isMassReassign)
            pageRef = new PageReference('/apex/ApprovalItems');
        else if(bnf.id != null)
            pageRef = new PageReference('/'+this.bnf.id);
        else 
            pageRef = null;
        
        return pageRef;
    }
}