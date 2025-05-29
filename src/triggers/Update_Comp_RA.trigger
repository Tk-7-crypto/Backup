trigger Update_Comp_RA on MIBNF2__c (after update) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        set<ID> MIBNF_IDs=new set<ID>();
        Boolean updateChildBNF=false;
        Set<id> Submitted_BNF_set=new Set<id>();
        Map<id,List<MIBNF_Component__c>> MIBNF_Comp_map=new Map<id,List<MIBNF_Component__c>>();
        List<MIBNF_Component__c> updateBNFlist=new List<MIBNF_Component__c>();
        Set<Id> SalesOrgCodeMIBNFSet = new Set<Id>();
        Set<Id> BillToAddressId = new Set<Id>();
        Map<Id,Address__c> BillToAddressMap = new Map<Id,Address__c>();

        //Set<String> status = new Set<String>{'New', 'Rejected', 'RA Rejected', 'LO Rejected'};
        
        //Get All MIBNF ids
        
        for (MIBNF2__c MIBNF : Trigger.new)
        {
            if(MIBNF.Revenue_Analyst__c!=Trigger.oldMap.get(MIBNF.Id).Revenue_Analyst__c)
                MIBNF_IDs.add(MIBNF.ID);
            if(MIBNF.Sales_Org_Code__c != null && MIBNF.Sales_Org_Code__c !=Trigger.OldMap.get(MIBNF.Id).Sales_Org_Code__c ){
                MIBNF_IDs.add(MIBNF.Id);
                SalesOrgCodeMIBNFSet.add(MIBNF.Id);
            }
        }

        //Run only when Revenue analyst has changed
        if(MIBNF_IDs.size()>0)
        {
            Map<id, MIBNF_Component__c> mibnfCompIdToCompMap = new Map<id, MIBNF_Component__c>([select MIBNF__c,Comp_Revenue_Analyst__c,BNF_status__c,Bill_To__c,MIBNF__r.Sales_Org_Code__c from MIBNF_Component__c where MIBNF__c in :MIBNF_IDs]);
            List<ProcessInstanceWorkitem> processInstanceList = [select Id, ActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId IN : mibnfCompIdToCompMap.Keyset()];
            Set<ID> mibnfCompId = new  Set<ID>();
            for(ProcessInstanceWorkitem workItem : processInstanceList ) {
                mibnfCompId.add(workItem.ProcessInstance.TargetObjectId);
            }
            
            for(MIBNF_Component__c com_BNF:mibnfCompIdToCompMap.values())
            {
                if(mibnfCompId.contains(com_BNF.id))
                {
                    Submitted_BNF_set.add(com_BNF.MIBNF__c);
                }
                else
                {
                    List<MIBNF_Component__c> Complst=new List<MIBNF_Component__c>();
                    if(MIBNF_Comp_map.containsKey(com_BNF.MIBNF__c))
                    {
                        Complst=MIBNF_Comp_map.get(com_BNF.MIBNF__c);
                        Complst.add(com_BNF);
                    }
                    else
                        Complst.add(com_BNF);
                    
                    //Create Map if MIBNF and Child component
                    MIBNF_Comp_map.put(com_BNF.MIBNF__c,Complst);
                }
                //setEnabledPaymentTermsBillTo
                if(com_BNF.Bill_To__c != null){
                    BillToAddressId.add(com_BNF.Bill_To__c);
                }
            } 
            //setEnabledPaymentTermsBillTo
            if(BillToAddressId.size() > 0){
                BillToAddressMap = new SLT_Address().selectByAddressId(BillToAddressId, new Set<String>{'Id','Enabled_Sales_Orgs_and_Payment_Terms__c'});
                for (MIBNF_Component__c BNF : mibnfCompIdToCompMap.values()){
                    if(BNF.Bill_To__c != null && BillToAddressId.contains(BNF.Bill_To__c) && SalesOrgCodeMIBNFSet.contains(BNF.MIBNF__c)){
                        String AddressSalesOrgsAndPaymentTerms = BillToAddressMap.get(BNF.Bill_To__c).Enabled_Sales_Orgs_and_Payment_Terms__c;
                        Map<String,String> salesOrgPaymentTermMap = new Map<String,String>();
                        if(AddressSalesOrgsAndPaymentTerms != null){
                            for(String supportedList : AddressSalesOrgsAndPaymentTerms.split(';')){
                                List<String> CodeTermPair = supportedList.split(':');
                                if(CodeTermPair.size() == 2)
                                    salesOrgPaymentTermMap.put(CodeTermPair[0].trim(),CodeTermPair[1].trim());
                            }
                        }
                        BNF.Enabled_PaymentTerms_Bill_To__c = salesOrgPaymentTermMap.get(BNF.MIBNF__r.Sales_Org_Code__c);
                        updateBNFlist.add(BNF);
                    }
                }
            }
            
            //Execute validation on currently updated MIBNF and child bnf if all BNFs are new status       
            for (MIBNF2__c MIBNF : Trigger.new)
            {
                if(Submitted_BNF_set.contains(MIBNF.id) && (MIBNF.Revenue_Analyst__c!=Trigger.oldMap.get(MIBNF.id).Revenue_Analyst__c))
                {
                    MIBNF.adderror('A BNF already submitted for approval so Revenue analyst can not be changed.');
                }
                else
                {
                    if(MIBNF.Revenue_Analyst__c!=Trigger.oldMap.get(MIBNF.id).Revenue_Analyst__c)
                    {
                        updateChildBNF=true;
                        if(MIBNF_Comp_map.containsKey(MIBNF.id))
                        {
                            for(MIBNF_Component__c cc : MIBNF_Comp_map.get(MIBNF.id))
                            {
                                cc.Comp_Revenue_Analyst__c=MIBNF.Revenue_Analyst__c;
                                updateBNFlist.add(cc);
                            }
                        }
                        
                    }
                }
            }
            if(updateBNFlist.size() > 0)
            {    
                update updateBNFlist;
            }                
        }
    }
}