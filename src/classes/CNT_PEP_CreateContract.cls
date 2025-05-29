/*
* Version       : 1.0
* Description   : Apex Controller to create contract. 
*/
public class CNT_PEP_CreateContract { 
    /* 
    * return Contract Id
    */
    @AuraEnabled 
    public static String createContractController(String agencyProgramId){
        String contractId = '';
        
        //Check if existing Contract exists with same Agency and status 'Awaiting Signature'
        List<Contract> existingContractList = new SLT_Contract().selectExistingContract(agencyProgramId);
        
        if(existingContractList.size() > 0){
            contractId = existingContractList[0].Id;
        }else{
            //get the Name of the Agency Program
            Agency_Program__c relatedAgency = new SLT_Agency_Program().fetchRelatedAgencyProgram(agencyProgramId);
            
            //get the AccountId of the actual Portal User
            Id userInfo=UserInfo.getUserId();
            List<User> usersList =   new SLT_User().selectAccountIdByUser(userInfo);
            Set<String> fieldSet=new Set<String>{'AccountCountry__c'};      
            List<Account> acc=new SLT_Account().getAccountCountry(fieldSet, usersList[0].AccountId);
            Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
            String relatedAgencyId=relatedAgency.Id;
            String country=acc[0].AccountCountry__c;
            List<Agency_Program_Financials__c> apfProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetails(agencyProgramFinancialsPrice, relatedAgencyId, country);
            List<Agency_Program_Financials__c>  defaultProduct=new SLT_Agency_Program_Financials().getAgencyProgramFinancialsDetailsDefault(agencyProgramFinancialsPrice, relatedAgencyId);
            if(usersList.size() > 0){
                Id contractPRM_RT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
                
                Contract cntrt = new Contract();
                cntrt.AccountId = usersList[0].AccountId;
                cntrt.Name = relatedAgency.Name;
                cntrt.Status = null;
                cntrt.ContractTerm = 12;
                cntrt.RecordTypeId = contractPRM_RT;
                cntrt.SOW_status__c = 'Awaiting Signature';
                if(apfProduct.size()>0)
                {
                    cntrt.Product__c = apfProduct[0].Product__c;
                    cntrt.Budget__c = apfProduct[0].Price__c;
                    cntrt.CurrencyIsoCode=apfProduct[0].CurrencyIsoCode;
                }
                else
                {
                    if(defaultProduct.size()>0){
                        cntrt.Product__c = defaultProduct[0].Product__c;
                        cntrt.Budget__c = defaultProduct[0].Price__c;
                        cntrt.CurrencyIsoCode=defaultProduct[0].CurrencyIsoCode;
                    }
                }
                cntrt.Agency_Program__c = agencyProgramId;
                cntrt.Payment_status__c = 'Payment Required';
                cntrt.PRM_Contract_type__c = 'Agency Program SOW';
                Database.insert(cntrt, true);
                
                contractId = cntrt.Id;  
            }
        }

        return contractId;
    }
    
    @AuraEnabled
    public static List<Agency_Program__c> getActiveAgencyProg()
    {
        String activeStatus = CON_PEP.S_PEP_ACTIVE_STATUS;
        Id userInfo=UserInfo.getUserId();
        List<User> usersList=new SLT_User().selectAccountIdByUser(userInfo);
        Set<String> fieldSet=new Set<String>{'AccountCountry__c'};
        List<Account> acc=new SLT_Account().getAccountCountry(fieldSet, usersList[0].AccountId);
        Id agencyProgramFinancialsPrice = Schema.SObjectType.Agency_Program_Financials__c.getRecordTypeInfosByDeveloperName().get('Price').getRecordTypeId();
        String accountCountry='';
        List<Agency_Program__c> activeAgencyPrograms=new List<Agency_Program__c>();
        List<Agency_Program__c> mergedList=new List<Agency_Program__c>();
        List<Agency_Program__c> listToKeep=new List<Agency_Program__c>();
        Set<Id> apId=new Set<Id>();
        
        If(acc.size()>0)
        {
                accountCountry=acc[0].AccountCountry__c;
               activeAgencyPrograms=new SLT_Agency_Program().fetchActiveAgencyPrograms(accountCountry, agencyProgramFinancialsPrice);
            for(Agency_Program__c apc:activeAgencyPrograms)
            {
                
                if(apc.Agency_Program_Financials__r.size()<=0)
                {
                    apId.add(apc.Id);  
                }
                else
                {
                    listToKeep.add(apc);
                }
                
            }

            List<Agency_Program__c> newListAP=new List<Agency_Program__c>();
            newListAP=new SLT_Agency_Program().fetchActiveAgencyProgramsDefault(agencyProgramFinancialsPrice,apId);            
            mergedList.addAll(newListAP); 
            mergedList.addAll(listToKeep);     
        }
        return mergedList;
    }    
}