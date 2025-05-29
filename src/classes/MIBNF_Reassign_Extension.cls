/*
* Name              : MIBNF_Reassign_Extension
* Created By        : Pramod Kumar
* Created Date      : 23 Nov, 2016
* Revision          : 
* Description       : Controller Extension for MIBNF_Reassign Page
*/
public class MIBNF_Reassign_Extension {
    public MIBNF_Component__c mibnfComp{get;set;}
    private String mibnfId;
    public String ApproverComments {public get;public set;}
    public boolean isOwnerQueue{get;set;}
    public String buttonBack {get;set;}
    public Id recordId{set; get;}
    public String comment{set; get;}
    
    /**
   * constructor for MIBNF_Reassign Page
   * @param controller : instance of standardController
   * @return 
   */
    public MIBNF_Reassign_Extension(ApexPages.StandardController controller) {
        buttonBack = 'Cancel';
        isOwnerQueue = false;
        mibnfId = ApexPages.currentPage().getParameters().get('id');
        if(mibnfId != null) {
            mibnfComp = [select Id, Name, Comments__c , createdById, MIBNF__c, createdDate, BNF_Status__c, SAP_SD_Error_Message__c, Comp_Revenue_Analyst__c, First_RA__c, Reassigned_Comp_Revenue_Analyst__c, Comp_Revenue_Analyst__r.Owner.Type from MIBNF_Component__c where id =: mibnfId];
        }
        if(mibnfComp.Comp_Revenue_Analyst__r.Owner.Type == 'Queue') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'BNF\'s assigned to GFSS RA\'s cannot be reassigned, they must be rejected and resubmitted'));
            isOwnerQueue = true;
            buttonBack = 'Back';
        } 
        
    }
  
    /**
   * method used to reassign Revenue Analyst to MIBNF Record
   * @param : None
   * @return : instanse of PageReference 
   */
    public PageReference reassignRA() {
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('mibnf comp Process start');
            List<ProcessInstanceWorkitem> workItemList = [SELECT Id, ActorId, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :mibnfComp.id];
            Revenue_Analyst__c revenueAnalyst = [Select id , User__c from Revenue_Analyst__c where id = :this.mibnfComp.Reassigned_Comp_Revenue_Analyst__c];
            for(ProcessInstanceWorkitem wi : workItemList) {
                wi.ActorId = revenueAnalyst.User__c;
            }
            upsert workItemList;
                   
        } catch(Exception exp) { 
            Database.rollback( sp );
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Exception Occured '+exp));
            return null;
        }
        pageReference retUrl = new pageReference('/'+this.mibnfcomp.Id);
        retUrl.setRedirect(true);
        return retUrl;
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
            Revenue_Analyst__c revenueAnalyst1 = [Select id , User__c from Revenue_Analyst__c where id = :this.mibnfComp.Reassigned_Comp_Revenue_Analyst__c];
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
        PageReference pageRef = new PageReference('/'+this.mibnfComp.id);
        return pageRef;
    }
}