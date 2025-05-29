trigger LineBreak on BNF2__c (before insert, before update) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {  
        for (BNF2__c  cBNF : Trigger.new) {
            
            // checking only if the revenue comments is not equal to NULL
            if(cBNF.Comments__c<>NULL)
            {
                
                Integer LB = 0;
                Integer LastSpace = 0;
                String newComment = '';
                Integer enter = 0;
                String comment = cBNF.Comments__c; 
                
                
                
                for(Integer i= 0;i<comment.length();i++)
                {    
                    newComment = newComment+comment.substring(i,i+1);
                    LB = LB + 1;
                    
                    // checking if line break                   
                    if((comment.substring(i,i+1)=='\n')||(comment.substring(i,i+1)==' '))
                    {
                        LB = 0;
                        //LastSpace=0;
                    }
                    
                    // if 49 character without space then
                    if(LB==49)
                    {
                        newComment = newComment + ' ';
                        LB=0;
                        LastSpace=0;
                    }
                    
                    System.debug('Comment : '+newComment);
                }                    
                
                cBNF.Comments__c = newComment;                 
            }
        }
        
        //Added By Rakesh : 26 March 2015 : ER-854 : START
        if(Trigger.isUpdate)
        {
            List<BNF2__c> BNFListSubmittedForApproval = new List<BNF2__c>(); 
            set<id> BNFoppset=new set<id>();
            for (BNF2__c  cBNF : Trigger.new) 
            {
                if(!string.isBlank(cBNF.BNF_Status__c) && !string.isBlank(trigger.oldMap.get(cBNF.Id).BNF_Status__c) &&
                   trigger.oldMap.get(cBNF.Id).BNF_Status__c != 'Submitted' &&  cBNF.BNF_Status__c == 'Submitted'
                  )
                {
                    BNFListSubmittedForApproval.add(cBNF);
                    BNFoppset.add(cBNF.opportunity__c);
                }
            }
            
            if(BNFoppset.size() > 0 )
            {
                Map<Id, Opportunity> oppMapWithAgreements = new map<id, Opportunity>(); 
                Set<Id> scmAgreementRecordIds = new set<Id>();
                Contract_Management_Setting__c contractSetting = Contract_Management_Setting__c.getInstance();
                string IMSSalesOrgCode = '';
                string legalEntity = '';
                //Create set of SCM agreement record types
                if( contractSetting != null)
                {
                    scmAgreementRecordIds.add(contractSetting.SOW__c);
                }
                
                if( ConstantClass.allowSalesOrgUpdateOnBNF_FromSCM && contractSetting != null && contractSetting.Allow_SalesOrg_Update_In_BNF_From_SCM__c)
                {
                    //Get agreements of selected opportunities
                    oppMapWithAgreements = new map<id, Opportunity>([SELECT Id, (SELECT Id,IMS_Legal_Entity__c FROM Proxy_SCM_Agreements__r where Record_Type_Name__c in : scmAgreementRecordIds and is_Amendment_Record__c = false ) FROM Opportunity where id in :BNFoppset]);
                    
                    if(oppMapWithAgreements.size() > 0 )
                    {
                        map<string, string> salesCodetoSalesOrgNameInBNFMap = ConstantClass.getSalesOrgNameinBNFSystem1('Purchase BNF');
                        for(BNF2__c BNF: BNFListSubmittedForApproval)
                        {
                            //Get legal entity of agreement based on opportunity
                            legalEntity =  ConstantClass.checkAgreementLegalEntityForOpportunity(BNF.opportunity__c, oppMapWithAgreements);             
                            //get sales org code based on legal entity
                            IMSSalesOrgCode = ConstantClass.getSalesOrgCodeforAgreementLegalEntity(legalEntity);
                            if(!string.isBlank(IMSSalesOrgCode) && BNF.Sales_Org_Code__c != IMSSalesOrgCode)
                            {
                                BNF.addError(Label.SCM_BNF_Submission_Message);
                            }
                        }
                    }
                }
            }
        }
        //END : ER-854
    }
}