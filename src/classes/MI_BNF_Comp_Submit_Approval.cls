public with sharing class MI_BNF_Comp_Submit_Approval {
    //  -------------------------------------------------------------------------------
    //  Member variables
    //  -------------------------------------------------------------------------------
   
    public MIBNF_Component__c MIBNF_Comp{get;private set;}
    public Boolean errorFlag{get;private set;}
    public Boolean errorFlagID{get;private set;}
    
    //  -------------------------------------------------------------------------------
    //  Constructor function
    //  -------------------------------------------------------------------------------   
     public MI_BNF_Comp_Submit_Approval () 
    {       
            String msgText='';
             //  Issue-09971
            MIBNF_Comp=[Select name,MIBNF__r.Opportunity__c,MIBNF__r.Revenue_Analyst__c,  MIBNF__r.Revenue_Analyst__r.Name, MIBNF__r.Revenue_Analyst__r.User__c,MIBNF__r.Revenue_Analyst__r.User__r.name,Addendum__c,BNF_Status__c,MIBNF__r.Opportunity__r.StageName From MIBNF_Component__c where id=:ApexPages.currentPage().getParameters().get('id') limit 1];
            
    }
    
    public PageReference cancel()
    {
            PageReference oppView;
            if(MIBNF_Comp.id!=null)
            {
               oppView = new PageReference('/apex/MI_BNF_View?id=' + MIBNF_Comp.MIBNF__c);
            }
           
            oppView.setRedirect(true);
            return oppView;
    } 
    
     //submit BNF for approval 
     public PageReference SubmitRequest()
     {
           PageReference oppView = null;
           
           //Processing request          
           try {
                Approval.ProcessSubmitRequest request=new Approval.ProcessSubmitRequest();
                request.setObjectId(MIBNF_Comp.Id);
                //  Issue-09971
                request.setComments('BNF submitted to ' + MIBNF_Comp.MIBNF__r.Revenue_Analyst__r.Name);
                Approval.ProcessResult result = Approval.process(request);
                errorFlag=false;
                oppView = new PageReference('/apex/MI_BNF_View?id=' + MIBNF_Comp.MIBNF__c);      
                oppView.setRedirect(true);
                                  
             }
            catch(Exception e)
            {
                errorFlag=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
          
            return oppView;
     }
}