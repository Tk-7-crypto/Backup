/**
   created by Naveena Bagria :ER 797 :29-04-2014
*/

public with sharing class SCM_BNFAddressUpdateHelper 
{   
    //Method that checks if Bill_To has been updated on BNF and then call the method 'UpdateAggr' which updates it on the aggrement
    public void onBeforeInsert(List<BNF2__c>BnfList)
    {
            UpdateBNF(BnfList);                 
    }
    
    //method 'UpdateBnf' to update Bill_To on Aggrement
    public void UpdateBNF(List<BNF2__c>BnfList)
    {
        
        Map<Id,BNF2__c> OppBnfsMap = new Map<Id,BNF2__c>();
        List<Proxy_SCM_Agreement__c>aggrmtsList = new List<Proxy_SCM_Agreement__c>();
        
        //Iterate through BNF's and get related Opportunities
        for(BNF2__c Bnf : BnfList)
        {       
            OppBnfsMap.put(Bnf.Opportunity__c , Bnf);
        } 
        //System.debug('Opps-------->'+OppBnfsMap.keySet());
        /*if(!OppBnfsMap.isEmpty())
        //Updated By Rakesh : 27 Feb 2015 : ER-1584 : Modify RecordType checks
        //aggrmtsList = [Select a.Bill_To__c,a.Opportunity__c From Proxy_SCM_Agreement__c a where a.Opportunity__c IN :OppBnfsMap.keySet() AND ( a.Record_Type_Name__c = 'SOW' OR a.Record_Type_Name__c = 'Academia')];
        
        
        //Iterate through related agreemnts and update Bill_To
        if(aggrmtsList!=null && !aggrmtsList.isEmpty())
        {
            for( Proxy_SCM_Agreement__c aggr : aggrmtsList)
            {
                if(oppBnfsMap.containsKey(aggr.Opportunity__c) && oppBnfsMap.containsKey(aggr.Opportunity__c)!=null)
                {       
                    //oppBnfsMap.get(aggr.Opportunity__c).Bill_To__c = aggr.Bill_To__c ;      
                }
            }   
            
            //Update the related Agreements 
           
            ConstantClass.stopRecrsvTriggerAgreement = true;    
        } */
    }
    
}