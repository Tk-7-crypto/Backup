/*
* Version       : 1.0
* Description   :Apex Controller for LXC_PEP_ContractList
*/
public with sharing class CNT_PEP_ContractList {
    @AuraEnabled
    public static List<Contract> getContract(){
        Id userInfo=UserInfo.getUserId();
        User contactUser = new SLT_User().selectUserByLoggedInUser(userInfo);
        String userAccountId=contactUser.Contact.AccountId;
        List<Contract> lstContract = new List<Contract>();        
        Id contractPRM_RT = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
        if(contactUser!= null)
        {
            lstContract= new SLT_Contract().selectByPRMContract(contractPRM_RT,userAccountId);  
        }           
        return lstContract; 
    }
}