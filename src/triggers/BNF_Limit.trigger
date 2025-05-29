/****************************************************************************************
Name            : BNF_Limit
Author          : Himanshu Parashar
Created Date    : April 17, 2012
Use             : BNF2__c trigger which prevent creating two BNF per opportunity except revised BNF.                  
****************************************************************************************/

trigger BNF_Limit on BNF2__c (before insert, before update) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {
        Set<ID> OppIDset = new Set<ID>();
        Set<String> OppBNFCountSet=new Set<String>();
        Map<id, Set<ID>> opportunityToBNFList = new Map<id, Set<ID>>();
        
        // Get All the BNF Opportunity in set
        for(BNF2__c BNF : Trigger.New)
        {
            OppIDset.add(BNF.Opportunity__c);
        }
        
        // Create Map of Opportunity and BNF count
        for(BNF2__c bnf :[Select Opportunity__c, id from BNF2__c Where Addendum__c = false and Opportunity__c in : OppIDset])
        {       
            if(opportunityToBNFList.containsKey(bnf.Opportunity__c)) {
                opportunityToBNFList.get(bnf.Opportunity__c).add(bnf.id);
            } else {
                Set<ID> setOfBnfIds = new Set<ID>();
                setOfBnfIds.add(bnf.id);
                opportunityToBNFList.put(bnf.Opportunity__c, setOfBnfIds);
            }
        }
        
        //system.assert(false, opportunityToBNFList);
        for(BNF2__c newbnf : Trigger.new) {
            if(newbnf.id == null && newbnf.Addendum__c==false && opportunityToBNFList.containsKey(newbnf.Opportunity__c))
            {
                newbnf.addError('Only one BNF can be created per opportunity.  To create a revised BNF ensure that the "Revised BNF" is selected.');
            } else if (newbnf.Addendum__c == false && opportunityToBNFList.containsKey(newbnf.Opportunity__c)) {     	
                if(!(opportunityToBNFList.get(newbnf.Opportunity__c).contains(newbnf.id))) {
                    newbnf.addError('Only one BNF can be created per opportunity.  To create a revised BNF ensure that the "Revised BNF" is selected.');
                }
            }
        }    
    }
    /*
    // Create Map of Opportunity and BNF count
    for(AggregateResult agr :[Select Opportunity__c from BNF2__c Where Addendum__c = false and Opportunity__c in : OppIDset Group by Opportunity__c having count(id)>=1])
    {
        OppBNFCountSet.add(String.valueof(agr.get('Opportunity__c')));
    }
    
    
    for(BNF2__c newbnf : Trigger.new) {
        if(newbnf.Addendum__c==false && OppBNFCountSet.contains(String.valueof(newbnf.Opportunity__c)))
        {
            newbnf.addError('Only one BNF can be created per opportunity.  To create a revised BNF ensure that the "Revised BNF" is selected.');
        }
     }*/
}