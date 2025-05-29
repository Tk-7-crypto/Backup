public class DAOH_Contract_PRM {
    
    public static void updateContract(List<Contract> newList,Map<Id, Contract> oldMap) {
        Set<Id> conId=new Set<Id>();
        for(Contract con:newList)
        {
            if(con.Notification_Counter__c==2 && oldMap.get(con.Id).Notification_Counter__c==1)
            {
                con.Renewal_Status__c='Time to Renew';
            }
            
            if(con.Non_Standard_Contract__c==False && (con.Agency_Program__c!=NULL || con.Agency_Program__c!='') && (con.PRM_Contract_type__c=='Agency Program SOW' || con.PRM_Contract_type__c=='Sandbox Agreement' || con.PRM_Contract_type__c=='Data Program'))
            {
                conId.add(con.Id);
            }
        }
        Set<String> fieldSet=new Set<String>{'AccountId','Agency_Program__c'};
        List<Contract> currentContract=new SLT_Contract().fetchContract(conId, fieldSet);

        if(currentContract.size()>0)
        {
           Set<String> fieldSet1=new Set<String>{'AccountCountry__c'};
            List<Account> acc=new SLT_Account().getAccountCountry(fieldSet1, currentContract[0].AccountId);
            String relatedAgencyId=currentContract[0].Agency_Program__c;
            String country=acc[0].AccountCountry__c;
            Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
            List<Agency_Program_Financials__c> apfProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetails(agencyProgramFinancialsPrice, relatedAgencyId, country);
            List<Agency_Program_Financials__c>  defaultProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetailsDefault(agencyProgramFinancialsPrice, relatedAgencyId);
            
            for(Contract con:newList)
            {
                if(con.Non_Standard_Contract__c==False && (con.Agency_Program__c!=NULL || con.Agency_Program__c!='') && (con.PRM_Contract_type__c=='Agency Program SOW' || con.PRM_Contract_type__c=='Sandbox Agreement' || con.PRM_Contract_type__c=='Data Program'))
                {
                    if(apfProduct.size()>0)
                    {
                        con.Product__c = apfProduct[0].Product__c;
                        con.Budget__c = apfProduct[0].Price__c;
                        con.CurrencyIsoCode = apfProduct[0].CurrencyIsoCode;
                    }
                    else
                    {
                        if(defaultProduct.size()>0){
                            con.Product__c = defaultProduct[0].Product__c;
                            con.Budget__c = defaultProduct[0].Price__c;
                            con.CurrencyIsoCode = defaultProduct[0].CurrencyIsoCode;
                        }
                    }
                }
            }
        }
        
    } 
    
    public static void updateParentContract(List<Contract> newList,Map<Id, Contract> oldMap) {
        Set<Id> conId=new Set<Id>();
        Set<Id> parentConId=new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Id','ContractNumber'};
        Integer flag=0;
        for(Contract con:newList)
        {
            conId.add(con.Id);
        }
        List<Contract> relatedcontract = new SLT_Contract().selectByContractIdList(conId,fieldSet);        
        List<Contract> parentContract=new SLT_Contract().selectParentContract(relatedcontract[0].ContractNumber);
        if(parentContract.size()>0){
            for(Contract con:newList)
            {
                if(con.SOW_status__c=='Signed' && con.SOW_status__c!=oldMap.get(con.Id).SOW_status__c)
                {
                    parentContract[0].Renewal_Status__c='Renewed';
                    flag=1;
                }
            }
            if(flag==1)
            {
                update parentContract;
            }
        }
    }

    public static void insertContract(List<Contract> newList,Map<Id, Contract> oldMap) 
    {
        Set<Id> conId=new Set<Id>();
        for(Contract con:newList)
        {
            if(con.Non_Standard_Contract__c==False && (con.Agency_Program__c!=NULL || con.Agency_Program__c!=''))
            {
                conId.add(con.Id);
            }
        }
        
        Set<String> fieldSet=new Set<String>{'AccountId','Agency_Program__c'};
        List<Contract> currentContract=new SLT_Contract().fetchContract(conId, fieldSet); 
        if(currentContract.size()>0)
        {
            Set<String> fieldSet1=new Set<String>{'AccountCountry__c'};
            List<Account> acc=new SLT_Account().getAccountCountry(fieldSet1, currentContract[0].AccountId);
            Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
            String relatedAgencyId=currentContract[0].Agency_Program__c;
            String country=acc[0].AccountCountry__c;
            List<Agency_Program_Financials__c> apfProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetails(agencyProgramFinancialsPrice, relatedAgencyId, country);
            List<Agency_Program_Financials__c>  defaultProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetailsDefault(agencyProgramFinancialsPrice, relatedAgencyId);
            
            Id contractPRM_RT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
            List<Contract> contractToUpdate=new List<Contract>();
            for(Contract con:newList)
            {
                if(con.Non_Standard_Contract__c==False && (con.Agency_Program__c!=NULL || con.Agency_Program__c!='') && (con.PRM_Contract_type__c=='Agency Program SOW' || con.PRM_Contract_type__c=='Sandbox Agreement' || con.PRM_Contract_type__c=='Data Program'))
                {
                    Contract cc=new Contract(Id=con.Id,RecordTypeId=contractPRM_RT,AccountId=con.AccountId,Status='Not Started',Agency_Program__c=con.Agency_Program__c);
                    
                    if(apfProduct.size()>0)
                    {
                        cc.Product__c = apfProduct[0].Product__c;
                        cc.Budget__c = apfProduct[0].Price__c;
                        cc.CurrencyIsoCode = apfProduct[0].CurrencyIsoCode;
                    }
                    else
                    {
                        if(defaultProduct.size()>0){
                            cc.Product__c = defaultProduct[0].Product__c;
                            cc.Budget__c = defaultProduct[0].Price__c;
                            cc.CurrencyIsoCode = defaultProduct[0].CurrencyIsoCode;
                        }
                    }
                    contractToUpdate.add(cc); 
                }
            }
            update contractToUpdate;
        }
    }
    
}