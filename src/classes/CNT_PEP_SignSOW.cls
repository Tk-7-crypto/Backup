public class CNT_PEP_SignSOW {
    
    @AuraEnabled
    public static String getrelatedContractId(String contractId){ 
        //Query Contract Fields
        Contract relatedcontract = new SLT_Contract().selectContractById(contractId);
        String paymentmethod;
        paymentmethod = relatedcontract.Payment_method__c + ';' + relatedcontract.SOW_status__c+';'+relatedcontract.Notification_Counter__c+';'+relatedcontract.New_Contract_Number__c+';'+relatedcontract.Non_Standard_Contract__c+';'+relatedcontract.Renewal_Status__c;
        
        return paymentmethod;
    }    
    
    @AuraEnabled
    public static String getContractId(String contractId, String signSOW_online){ 
        String templateId = '';
        Boolean signSOWonline = False;

        if(signSOW_online == 'True'){
            signSOWonline = True;
        }
        
        Set<Id> agencyProgramSetIds = new Set<Id>();
        List<Contract_Template__c> contractTemplateList = new List<Contract_Template__c>();
        
        
        //Query Contract Fields
        Contract relatedcontract = new SLT_Contract().selectContractById(contractId);
        String childContractNumber=relatedcontract.ContractNumber;
        System.debug(childContractNumber);
        List<Contract> parentContract=new SLT_Contract().selectParentContract(childContractNumber);
        

        
        String relatedAgencyProgram=relatedcontract.Agency_Program__c;

        //Search the « Agency Program » with the same Product as the Contract
            List<Agency_Program__c> agencyprogramList = new SLT_Agency_Program().fetchRelatedAgencyProgramById(relatedAgencyProgram);

            if(agencyprogramList.size() > 0){
                for(Agency_Program__c ag : agencyprogramList){
                    agencyProgramSetIds.add(ag.Id);
                }
            }
        
        //Search the « Contract Template » where the Country = Account.Country OR Master = true
        //If a « Contract Template » exist with a corresponding country, use the template ID or else use the template ID of the Master 
        if(agencyProgramSetIds.size() > 0){
            contractTemplateList = [SELECT ID, Master__c, Country__c, TemplateID__c
                                    FROM Contract_Template__c
                                    WHERE Agency_Program__c IN: agencyProgramSetIds
                                    AND (Country__c =: relatedcontract.Account.AccountCountry__c) LIMIT 1];
            
            if(contractTemplateList.size() == 0){
                contractTemplateList = [SELECT ID, Master__c, Country__c, TemplateID__c
                                        FROM Contract_Template__c
                                        WHERE Agency_Program__c IN: agencyProgramSetIds
                                        AND Master__c = True LIMIT 1];
            }
        }
                
        if(contractTemplateList.size() > 0){
            templateId = contractTemplateList[0].TemplateID__c;
        }else{
            templateId = '';
        }
        
        String returnURL = '';
        
        //Use the template ID to construct the URL for the DocuSign signature  '1c78eee1-0897-4f1e-b4ee-418c2cf34f72'
        if(!Test.isRunningTest()){
        	returnURL = CNT_PEP_SendToDocusign.SendNow_WithRest(signSOWonline, contractId, templateId);
        }
        
        system.debug('returnURL-----SendNow_WithRest-------'+returnURL);        
        
        if(parentContract.size()>0)
        {
            parentContract[0].Renewal_Status__c='Renewal Contracting';
            update parentContract;
        }
        
        return returnURL;
    }
    @AuraEnabled
    public static String renewContractController(String contractId){ 
        Contract newContract = new Contract();
        
        Contract contractToBeRenewed=new SLT_Contract().selectContractToRenew(contractId);
        
        Id agencyProgramId=contractToBeRenewed.Agency_Program__c;
        Agency_Program__c relatedAgency = new SLT_Agency_Program().fetchAgencyProgramById(agencyProgramId);
        
        Id userInfo=UserInfo.getUserId();
        List<User> usersList = new SLT_User().selectAccountIdByUser(userInfo);
        Set<String> fieldSet=new Set<String>{'AccountCountry__c'};
        List<Account> acc=new SLT_Account().getAccountCountry(fieldSet, usersList[0].AccountId);
        Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
        String relatedAgencyId=relatedAgency.Id;
        String country=acc[0].AccountCountry__c;
        List<Agency_Program_Financials__c> apfProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetails(agencyProgramFinancialsPrice, relatedAgencyId, country);
        List<Agency_Program_Financials__c>  defaultProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetailsDefault(agencyProgramFinancialsPrice, relatedAgencyId);
        
        if(usersList.size() > 0){
            Id contractPRM_RT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
            
            
            newContract.AccountId = usersList[0].AccountId;
            newContract.Name = relatedAgency.Name;
            newContract.Status = null;
            newContract.ContractTerm = 12;
            newContract.RecordTypeId = contractPRM_RT;
            newContract.SOW_status__c = 'Awaiting Signature';
            if(apfProduct.size()>0)
            {
                newContract.Product__c = apfProduct[0].Product__c;
                newContract.Budget__c = apfProduct[0].Price__c;
                newContract.CurrencyIsoCode = apfProduct[0].CurrencyIsoCode;
            }
            else
            {
                newContract.Product__c = defaultProduct[0].Product__c;
                newContract.Budget__c = defaultProduct[0].Price__c;
                newContract.CurrencyIsoCode = defaultProduct[0].CurrencyIsoCode;
            }
            newContract.Agency_Program__c = relatedAgency.Id;
            newContract.Payment_status__c = 'Payment Required';
            newContract.PRM_Contract_type__c = 'Agency Program SOW';
            newContract.PRM_Parent_Contract_Number__c=contractToBeRenewed.ContractNumber;
            newContract.StartDate=contractToBeRenewed.EndDate.AddDays(1);
            newContract.EndDate=newContract.StartDate.addMonths(relatedAgency.Duration_in_month__c.intValue())-1;
            Database.insert(newContract, true);            
            
            String newContractId=newContract.Id;
            Contract newContractNumber= new SLT_Contract().selectNewContractById(newContractId);
            contractToBeRenewed.New_Contract_Number__c=newContractNumber.ContractNumber;
            contractToBeRenewed.Renewal_Status__c='Renewal Requested';
            
            updateContract(contractToBeRenewed);
        }
        
        return newContract.Id;
    }
    
    @AuraEnabled
    public static String renewNonStandardContractController(String contractId)
    {
        String developerName='PRM_Non_Standard_ContractRenewal';
        PEP_DocuSign_credentials__c docuSignCredentials = PEP_DocuSign_credentials__c.getInstance();
        String[] toAddresses =new String[]{docuSignCredentials.PSO_Team_Mailbox__c};
        String[] toCC=new String[]{docuSignCredentials.PSO_TeamLead_Email__c};
        UTL_PEP.sendMail(contractId,developerName,toAddresses,toCC);	
        
        Contract newContract = new Contract();
        
        Contract contractToBeRenewed=new SLT_Contract().selectContractToRenew(contractId);
        
        Id agencyProgramId=contractToBeRenewed.Agency_Program__c;
        Agency_Program__c relatedAgency = new SLT_Agency_Program().fetchAgencyProgramById(agencyProgramId);
        
        Id userInfo=UserInfo.getUserId();
        List<User> usersList = new SLT_User().selectAccountIdByUser(userInfo);
        Set<String> fieldSet=new Set<String>{'AccountCountry__c'};
        List<Account> acc=new SLT_Account().getAccountCountry(fieldSet, usersList[0].AccountId);
        Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
        String relatedAgencyId=relatedAgency.Id;
        String country=acc[0].AccountCountry__c;
        List<Agency_Program_Financials__c> apfProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetails(agencyProgramFinancialsPrice, relatedAgencyId, country);
        List<Agency_Program_Financials__c>  defaultProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetailsDefault(agencyProgramFinancialsPrice, relatedAgencyId);

        if(usersList.size() > 0){
            Id contractPRM_RT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
            
            
            newContract.AccountId = usersList[0].AccountId;
            newContract.Name = relatedAgency.Name;
            newContract.Status = null;
            newContract.ContractTerm = 12;
            newContract.RecordTypeId = contractPRM_RT;
            newContract.SOW_status__c = 'Awaiting Signature';
            if(apfProduct.size()>0)
            {
                newContract.Product__c = apfProduct[0].Product__c;
                newContract.Budget__c = apfProduct[0].Price__c;
                newContract.CurrencyIsoCode = apfProduct[0].CurrencyIsoCode;
            }
            else
            {
                newContract.Product__c = defaultProduct[0].Product__c;
                newContract.Budget__c = defaultProduct[0].Price__c;
                newContract.CurrencyIsoCode = defaultProduct[0].CurrencyIsoCode;
            }
            newContract.Agency_Program__c = relatedAgency.Id;
            newContract.Payment_status__c = 'Payment Required';
            newContract.PRM_Contract_type__c = 'Agency Program SOW';
            newContract.PRM_Parent_Contract_Number__c=contractToBeRenewed.ContractNumber;
            newContract.Non_Standard_Contract__c=True;
            newContract.Renewal_Status__c=null;
            Database.insert(newContract, true);            
            
            String newContractId=newContract.Id;
            Contract newContractNumber= new SLT_Contract().selectNewContractById(newContractId);
            contractToBeRenewed.New_Contract_Number__c=newContractNumber.ContractNumber;
            contractToBeRenewed.Renewal_Status__c='Renewal Requested';
            updateContract(contractToBeRenewed);
        }
        
        return newContract.Id;
        
    }
    
    @AuraEnabled
    public static void updateContract(Contract contractToBeRenewed)
    {
        update contractToBeRenewed;
    }
    
    @AuraEnabled
    public static String getChildContract(String contractId)
    {
        Contract currentContract=new SLT_Contract().selectNewContractById(contractId);
        String currentContractNumber=currentContract.ContractNumber;
        List<Contract> childContract=new SLT_Contract().selectChildContract(currentContractNumber);
        if(childContract.size()>0)
        {
            return childContract[0].Id;
        }
        else
        {
        return '';
        }
    }
}