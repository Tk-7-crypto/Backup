/**
 * This class is used to for reall the aproval request in BNF and MIBNF. 
 */ 
public class EXT_CRM_Recall_Approval_Request {
    public Id recordId{set; get;}
    private Id processInstanceWorkItemId;
    public String comment{set; get;}
    public Boolean disable {get;set;}
    public String targetObject{set; get;}
    public String createdBy{set; get;}
    public String objectName{set; get;}
    public String createdById{set; get;}
    
    /**
     * Construtor for getting record of processInstanceworkItem.
     */ 
   public EXT_CRM_Recall_Approval_Request(){
        this.recordId =   ApexPages.currentPage().getParameters().get('Id');
        if(this.recordId != Null){
           List<ProcessInstanceWorkitem> piWorkItems = [SELECT Id,ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name,CreatedById, CreatedBy.Name
                                                           FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                           AND ProcessInstance.Status = 'Pending']; 
            if(piWorkItems.size() > 0){
                this.targetObject = piWorkItems[0].ProcessInstance.TargetObject.Name;
                this.createdBy =  piWorkItems[0].CreatedBy.Name;
                this.processInstanceWorkItemId = piWorkItems[0].Id;
                this.disable = false;
                this.objectName = recordId.getSObjectType().getDescribe().getLabel();
                this.createdById = piWorkItems[0].CreatedById;
            }
            
            if(this.recordId.getSObjectType().getDescribe().getName() == 'BNF2__c'){
                BNF2__c bnf = new SLT_BNF().selectById(new Set<Id>{recordId}, new Set<String>{'BNF_Status__c'})[0];
                this.disable = (bnf.BNF_Status__c != 'Submitted');
            }
            
            if(this.recordId.getSObjectType().getDescribe().getName() == 'MIBNF_Component__c'){
                MIBNF_Component__c bnf = new SLT_MIBNF_Component().selectById(new Set<Id>{recordId}, new Set<String>{'BNF_Status__c'})[0];
                this.disable = (bnf.BNF_Status__c != 'Submitted');
            }
            
            if(this.disable){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot recall this BNF when BNF Status is not equal to Summitted.'));
            }
        }
        else{
            this.disable = true;
        }
    }
    
    /**
     *  Method is used to recall the approval process.  
     */ 
    public void recall_Request(){
	
        this.recordId =   ApexPages.currentPage().getParameters().get('Id');
        String cmt ;
        if(comment !=null && comment.length() > 3500){
            cmt = comment.SubString(0,3500) + '...';
        }else{
           cmt =  comment;
        }
        Recall_Approval__e recallApproval = new Recall_Approval__e(RecordId__c = recordId, Recall_User_Name__c	 = UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), Comment__c = cmt);
        Database.SaveResult result1 = EventBus.publish(recallApproval);
    }
    
    /**
     * Redirect the privious page.
     */ 
    public PageReference Cancel(){
        return new PageReference('/'+recordId);
    }
}