trigger UpdateOpportunityNum on BNF2__c (before insert, before update) 
{
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {
        Map<Id,String> Opportunity_Id_Map = new Map<Id,String>();
        for (BNF2__c cBNF : Trigger.new) 
        {
            Opportunity_Id_Map.put(cBNF.Opportunity__c,cBNF.Opportunity__c);
        }
        Map<Id,Opportunity> Opportunity_Map = new Map<Id,Opportunity>([Select Opportunity_Number__c,Amount,CurrencyIsoCode,LI_Contract_Amount__c from Opportunity where Id in :Opportunity_Id_Map.keySet()]);
        for (BNF2__c cBNF : Trigger.new) 
        {
            //Created by: Matt Yeoh, salesforce.com
            //Description: This Apex trigger keeps the opportunity number
            // and Contract Value field value in synch
            //Create on: 10/08/2007
            
            //Get Opportunity Information for BNF
            String sBNFOpptyNumber = cBNF.Opportunity_Number__c;
            Id OpptyId = cBNF.Opportunity__c;
            Id bnfId = cBNF.Id;
            String sCurrency = cBNF.CurrencyIsoCode;
            Double sContractVal = cBNF.Contract_Value__c;
            Boolean bUpdateContinue = false;
            Opportunity soOppty = Opportunity_Map.get(cBNF.Opportunity__c);     
            if(soOppty.Opportunity_Number__c != sBNFOpptyNumber)
            {
                //Update the BNF
                cBNF.Opportunity_Number__c = soOppty.Opportunity_Number__c; 
                bUpdateContinue=true;
            }
            if(soOppty.Amount != sContractVal)
            {
                //Update the BNF
                cBNF.Contract_Value__c = soOppty.Amount;
                bUpdateContinue=true;
            }
            if(soOppty.CurrencyIsoCode != sCurrency)
            {
                //Update the BNF
                cBNF.CurrencyIsoCode = soOppty.CurrencyIsoCode;
                bUpdateContinue=true;
            }
        }
    }
}