/**********************************************************************
Created by : Himanshu Parashar
Date : 31 oct 2011
This Trigger update Max Invoice count on MIBNF for MIBNF Component Name

*****************************************************************************/

trigger MIBNF_Comp_CustomNameFormat on MIBNF_Component__c (before insert) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        set<string> MIBNFIdSet=new set<string>();
        set<id> MIBNF_OrignalCompset=new set<id>();
        Map<id,MIBNF_Component__c> MIBNFCompMap;
        List<MIBNF2__c> MIBNFList=new  List<MIBNF2__c>();
        List<MIBNF_Component__c> MIBNFCompList=new  List<MIBNF_Component__c>();
        MIBNF2__c MIBNF;
        MIBNF_Component__c MIBNF_PriorComp;
        Boolean BNFRevised=false;  // flag to store whether BNF is revised or not.
        
        
        
        // Get MIBNF ID's From MIBNF Components
        for(MIBNF_Component__c MIBNF_Comp : trigger.new)
        {
            MIBNFIdSet.add(MIBNF_Comp.MIBNF__c);
            MIBNF_OrignalCompset.add(MIBNF_Comp.Orignal_BNF__c);
        } 
        
        
        // Get MIBNF Max_Invoice_Count__c to update
        Map<id,MIBNF2__c> MIBNFMap=new Map<id,MIBNF2__c>([select id,name,Max_Invoice_Count__c from MIBNF2__c where id in : MIBNFIdSet]);
        
        
        
        //Get MIBNF Component Max_Addendum_Count__c to update if it is revised BNF
        if(MIBNF_OrignalCompset!=null)
            MIBNFCompMap=new Map<id,MIBNF_Component__c>([select name,Max_Addendum_Count__c from MIBNF_Component__c where ID in :MIBNF_OrignalCompset]);
        
        
        Map<Id,MIBNF2__c> MIBNFUpdateMap = new Map<id, MIBNF2__c>();
        Map<Id,MIBNF_Component__c> MIBNFCompUpdateMap = new Map<id, MIBNF_Component__c>();
        
        for(MIBNF_Component__c MIBNF_Comp : trigger.new)
        {
            String BNF_Name;         
            // if revised bnf is false and BNF is created using wizard then create new BNF and update Max_Invoice_Count__c on MIBNF
            if(MIBNF_Comp.Addendum__c==false)
            {   
                MIBNF=new MIBNF2__c(id=MIBNF_Comp.MIBNF__c);
                MIBNF.Max_Invoice_Count__c=MIBNFMap.get(MIBNF_Comp.MIBNF__c).Max_Invoice_Count__c+1;
                
                // Insert into Map if id not in map else find the key in map and update it.
                if(MIBNFUpdateMap.containsKey(MIBNF.id))
                {
                    MIBNFUpdateMap.put(MIBNF.id,MIBNF);
                }
                else
                {
                    MIBNFUpdateMap.put(MIBNF.id,MIBNF);
                }
                
                //MIBNFList.add(MIBNF);
                BNF_Name=((MIBNF.Max_Invoice_Count__c).intValue()/10==0)? '0' + String.valueOf(MIBNF.Max_Invoice_Count__c):String.valueOf(MIBNF.Max_Invoice_Count__c);
                MIBNF_Comp.Name=MIBNFMap.get(MIBNF_Comp.MIBNF__c).name + '-' + BNF_Name;
                BNFRevised=false;
                MIBNFMap.put(MIBNF_Comp.MIBNF__c,MIBNF);
            }
            else
            {
                MIBNF_PriorComp=new MIBNF_Component__c(id=MIBNF_Comp.Orignal_BNF__c);
                MIBNF_PriorComp.Max_Addendum_Count__c=MIBNFCompMap.get(MIBNF_Comp.Orignal_BNF__c).Max_Addendum_Count__c+1;
                MIBNF_PriorComp.Name=MIBNFCompMap.get(MIBNF_Comp.Orignal_BNF__c).name;
                
                // Insert into Map if id not in map else find the key in map and update it.
                if(MIBNFCompUpdateMap.containsKey(MIBNF_PriorComp.id))
                {
                    MIBNFCompUpdateMap.put(MIBNF_PriorComp.id,MIBNF_PriorComp);
                }
                else
                {
                    MIBNFCompUpdateMap.put(MIBNF_PriorComp.id,MIBNF_PriorComp);
                }
                
                
                if(MIBNFCompMap.get(MIBNF_Comp.Orignal_BNF__c).name.contains('-R'))
                {
                    String Prior_BNF_Name= MIBNFCompMap.get(MIBNF_Comp.Orignal_BNF__c).name.substring(0,MIBNFCompMap.get(MIBNF_Comp.Orignal_BNF__c).name.length()-2);
                    String BNF_Name_Count=((MIBNF_Comp.Max_Addendum_Count__c).intValue()/10==0)? '0' + String.valueOf(MIBNF_PriorComp.Max_Addendum_Count__c):String.valueOf(MIBNF_PriorComp.Max_Addendum_Count__c);
                    MIBNF_Comp.Name= Prior_BNF_Name + BNF_Name_Count;
                }
                else
                {
                    BNF_Name=((MIBNF_Comp.Max_Addendum_Count__c).intValue()/10==0)? '0' + String.valueOf(MIBNF_PriorComp.Max_Addendum_Count__c):String.valueOf(MIBNF_PriorComp.Max_Addendum_Count__c);
                    MIBNF_Comp.Name= MIBNFCompMap.get(MIBNF_Comp.Orignal_BNF__c).name + '-R' + BNF_Name;    
                }
                
                MIBNF_Comp.Max_Addendum_Count__c=MIBNF_PriorComp.Max_Addendum_Count__c;
                //MIBNFCompList.add(MIBNF_PriorComp);
                BNFRevised=true;
                MIBNFCompMap.put(MIBNF_PriorComp.id,MIBNF_PriorComp);
                
            }
            
            
            
            
        }
        // Update MIBNF with new Max_Invoice_Count__c field only.
        
        
        if(BNFRevised==false)
        {
            List <MIBNF2__c> MIBNFUpdateSet = new List<MIBNF2__c>();
            MIBNFUpdateSet = MIBNFUpdateMap.values();
            update MIBNFUpdateSet;
        }
        else
        {
            List <MIBNF_Component__c> MIBNFUpdateSet = new List<MIBNF_Component__c>();
            MIBNFUpdateSet = MIBNFCompMap.values();
            update MIBNFUpdateSet;
        }
    }
}