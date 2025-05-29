/**************************************************************************************
This Trigger prevent user to create BNF if any Multi Invoice Exist on BNF's Opportunity
Created By : Himanshu Parashar
**************************************************************************************/

trigger MI_BNF_Check on BNF2__c (before insert) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {  
        set<id> BNFoppset=new set<id>();
        set<id> MIBNFoppset=new set<id>();
        
        for(BNF2__c BNF : Trigger.New)
        {
            BNFoppset.add(BNF.opportunity__c);
        }
        
        for(MIBNF2__c MIBNFList:[select Opportunity__c from MIBNF2__c where Opportunity__c in : BNFoppset])
        {
            MIBNFoppset.add(MIBNFList.Opportunity__c);
        }
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        for(BNF2__c BNF: Trigger.new)
        {
            if(bnfSetting.Enable_IQVIA_BNF_Validation__c && MIBNFoppset.contains(BNF.Opportunity__c))
                BNF.adderror('A Multi Invoice BNF already exists for this opportunity. BNF cannot be created.');
        } 
    }
}