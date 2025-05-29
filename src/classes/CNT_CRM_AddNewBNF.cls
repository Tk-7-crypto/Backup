public class CNT_CRM_AddNewBNF {
    
    public User currentUser{get; private set;}
    public Account accountRecord{get; private set;}
    public String opportunityJSONString{get;private set;}
    public String mibnfJSONString{get; private set;}
    public Id quickOppRecordTypeId {get; private set;}
    public String shipToBillToContactRoleJSONString{get; private set;}
    public String shipToContactRoleJSONString{get; private set;}
    public String billToContactRoleJSONString{get; private set;}
    public String coverSheetContactRoleJSONString{get; private set;}
    public String carbonCopyContactRoleJSONString{get; private set;}
    public String secondCopyContactRoleJSONString{get; private set;}
    public String priorOppJSONString{get; private set;}
    public String fieldApiToIdMapJSONString{get;private set;}
    public String bnfPrefix {get;private set;}
    public Boolean isNonMDMUser {get; private set;}
    public String oppContractStartDate {get;set;}
    public String oppContractEndDate {get;set;}
    public CNT_CRM_AddNewBNF() {
        isNonMDMUser = false;
        List<String> roleList = new List<String>();
        roleList.add('Ship To & Bill To');
        roleList.add('Ship To Primary');
        roleList.add('Bill To Primary');
        roleList.add('Cover Sheet Primary');
        roleList.add('Carbon Copy Primary');
        roleList.add('Second Copy');
        List<PermissionSetAssignment> pAssignmentList = [SELECT Id FROM PermissionSetAssignment where AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'BNF_Non_MDM_User'];
        if(pAssignmentList.size() > 0 ) {
          isNonMDMUser = true;  
        }
        bnfPrefix = BNF2__c.SobjectType.getDescribe().getKeyPrefix();
        currentUser = [SELECT Id, Sales_Org__c, Sales_Org_Code__c, User_Country__c, LocaleSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        Id oppId = ApexPages.currentPage().getParameters().get('id');
        System.debug(oppId);
        if(oppId != null) {
            Opportunity opp = [SELECT Id, Name, AccountId, Parent_Opportunity__c, Opportunity_Number__c, LeadSource, Therapy_Area__c, Amount, Type, CurrencyIsoCode,
                               Contract_Term__c, Contract_Type__c, RecordTypeId, Contract_End_Date__c, Contract_Start_Date__c, LI_Contract_Amount__c, Multi_Country_Billing__c FROM Opportunity WHERE Id = :oppId];
            if(opp.Contract_Start_Date__c != null){
            	oppContractStartDate = opp.Contract_Start_Date__c.format();
            }
            if(opp.Contract_End_Date__c != null){
            	oppContractEndDate = opp.Contract_End_Date__c.format();
            }
            opportunityJSONString = JSON.serialize(opp);
            accountRecord = [SELECT Id, Name, BRS_Code__c, SAP_PC_Code__c FROM Account WHERE Id = :opp.AccountId];
            List<MIBNF2__c> mibnfList = [Select Id from MIBNF2__c where Opportunity__c = :opp.Id];
            if(mibnfList.size() > 0) {
                mibnfJSONString = JSON.serialize(mibnfList);
            }
            //quickOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Quick Opportunity').getRecordTypeId();
            List<OpportunityContactRole> oppContactRoleList = [Select Role, Contact.Name, ContactId, Contact.MailingCity, Contact.MailingCountry, 
                                                               Contact.AccountId, Contact.Account.Name, Contact.MailingPostalCode, Contact.MailingState,
                                                               Contact.MailingStreet FROM OpportunityContactRole WHERE OpportunityId = :opp.Id AND 
                                                               Role IN :roleList];
            List<OpportunityContactRole> shipToBillToContactRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> shipToContactRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> billToContactRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> coverSheetContactRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> carbonCopyContactRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> secondCopyContactRoleList = new List<OpportunityContactRole>();
            for(OpportunityContactRole contactRole : oppContactRoleList) {
                if(contactRole.Role == roleList[0]) {
                    shipToBillToContactRoleList.add(contactRole);
                } else if(contactRole.Role == roleList[1]) {
                    shipToContactRoleList.add(contactRole);
                } else if(contactRole.Role == roleList[2]) {
                    billToContactRoleList.add(contactRole);
                } else if(contactRole.Role == roleList[3]) {
                    coverSheetContactRoleList.add(contactRole);
                } else if(contactRole.Role == roleList[4]) {
                    carbonCopyContactRoleList.add(contactRole);
                } else if(contactRole.Role == roleList[5]) {
                    secondCopyContactRoleList.add(contactRole);
                }
            }
            if(shipToBillToContactRoleList.size() > 0) {
                shipToBillToContactRoleJSONString = JSON.serialize(shipToBillToContactRoleList);
            }
            if(shipToContactRoleList.size() > 0) {
                shipToContactRoleJSONString = JSON.serialize(shipToContactRoleList);
            }
            if(billToContactRoleList.size() > 0) {
                billToContactRoleJSONString = JSON.serialize(billToContactRoleList);
            }
            if(coverSheetContactRoleList.size() > 0) {
                coverSheetContactRoleJSONString = JSON.serialize(coverSheetContactRoleList);
            }
            if(carbonCopyContactRoleList.size() > 0) {
                carbonCopyContactRoleJSONString = JSON.serialize(carbonCopyContactRoleList);
            }
            if(secondCopyContactRoleList.size() > 0) {
                secondCopyContactRoleJSONString = JSON.serialize(secondCopyContactRoleList);
            }
            List<Opportunity> priorOppList = [Select Opportunity_Number__c, Name from Opportunity where Id = :opp.Parent_Opportunity__c];
            if(priorOppList.size() > 0) {
                priorOppJSONString = JSON.serialize(priorOppList);
            }
            Map<String, String> fieldApiToIdmap = UTL_Sobject.getCustomFieldByIds('BNF2');
            fieldApiToIdMapJSONString = JSON.serialize(fieldApiToIdmap);
        }
    }    
}