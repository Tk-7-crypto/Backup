/*
* controller class for LXC_CLM_CreateAgreementFromOpp 
*/
public class CNT_CLM_CreateAgreementFromOpp {
    /**
     * This method is used to get list of record types
     * @return  List<RecordType>
    */
    @AuraEnabled
    public static List<RecordType> getRecordTypes(String originalRecordId) {
        List<RecordType> listOfRecordTypes =  new List<RecordType>();
        for(RecordTypeInfo info: Apttus__APTS_Agreement__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(originalRecordId.startsWith('006') && info.isActive() && info.isAvailable()
                && info.getRecordTypeId() != CON_CLM.MSA_RECORDTYPEID
                && info.getRecordTypeId() != CON_CLM.AMA_RECORDTYPEID
                && info.getDeveloperName() != 'Master'
                && info.getDeveloperName() != 'Generic') {
                listOfRecordTypes.add(new Recordtype(Id = info.getRecordTypeId(), Name = info.getName(),
                    DeveloperName = info.getDeveloperName()));
            }
            else if(originalRecordId.startsWith('001') && info.isActive() && info.isAvailable()
                && (info.getRecordTypeId() == CON_CLM.MSA_RECORDTYPEID
                || info.getRecordTypeId() == CON_CLM.AMA_RECORDTYPEID
                || info.getRecordTypeId() == CON_CLM.VENDOR_RECORDTYPEID || info.getRecordTypeId() == CON_CLM.OSA_RECORDTYPEID)
                && info.getDeveloperName() != 'Master'
                && info.getDeveloperName() != 'Generic') {
                listOfRecordTypes.add(new Recordtype(Id = info.getRecordTypeId(), Name = info.getName(),
                DeveloperName = info.getDeveloperName()));   
            }
        }
        for(RecordTypeInfo info: IQVIA_Agreement__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(originalRecordId.startsWith('001') && info.isActive() && info.isAvailable()
                && info.getDeveloperName() != 'Master' && info.getDeveloperName() != 'Avacare') {
                if(info.getDeveloperName() == 'USBU') {
                    listOfRecordTypes.add(new Recordtype(Name = CON_CLM.USBU_OTH_AGR_LABEL, DeveloperName = 'USBU_Other_Agreement')); 
                } 
                if(info.getDeveloperName() == 'MSA'){
                     listOfRecordTypes.add(new Recordtype(Id = info.getRecordTypeId(), Name = info.getName(),
                        DeveloperName = 'IQVIA_MSA', SobjectType = 'IQVIA_Agreement__c'));
                }
            }
            if(originalRecordId.startsWith('006') && info.isActive() && info.isAvailable()) {
                if(info.getDeveloperName() != 'Master' && info.getDeveloperName() != 'MSA' && info.getDeveloperName() != 'Avacare' && info.getDeveloperName() != 'Vendor_Agreement') {
                    listOfRecordTypes.add(new Recordtype(Id = info.getRecordTypeId(), Name = info.getName(),
                        DeveloperName = info.getDeveloperName(), SobjectType = 'IQVIA_Agreement__c'));
                }
                if(info.getDeveloperName() == 'USBU') {
                    listOfRecordTypes.add(new Recordtype(Name = CON_CLM.USBU_OTH_AGR_LABEL, DeveloperName = 'USBU_Other_Agreement')); 
                }
                if(info.getDeveloperName() == 'Vendor_Agreement') {
                    listOfRecordTypes.add(new Recordtype(Id = info.getRecordTypeId(), Name = info.getName(),
                        DeveloperName = 'IQVIA_Vendor_Agreement', SobjectType = 'IQVIA_Agreement__c'));
                }
            }
            if(!originalRecordId.startsWith('006') && !originalRecordId.startsWith('001') 
                && info.isActive() && info.isAvailable() && info.getDeveloperName() != 'Master' && info.getDeveloperName() == 'Avacare') {
                listOfRecordTypes.add(new Recordtype(Id = info.getRecordTypeId(), Name = info.getName(),
                    DeveloperName = info.getDeveloperName(), SobjectType = 'IQVIA_Agreement__c'));
            }
        }
        if(FeatureManagement.checkPermission(CON_CLM.CLM_RBU_CUSTOM_PERMISSION) && originalRecordId.startsWith('006')) {
            listOfRecordTypes.add(new Recordtype(Name = CON_CLM.RBU_PATHWAY, DeveloperName = 'RWLP_RBU')); 
        }
        return listOfRecordTypes;
    }

    /**
     * This method is used to get pre-populate the fields
     * @params  Id opportunityId
     * @params  Id recordTypeId
     * @return  String
     */
    @AuraEnabled
    public static String getDefaultFieldValues(Id originalRecordId, Id recordTypeId) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        if(originalRecordId != null && String.valueOf(originalRecordId).startsWith('006') && recordTypeId != null) {
            Id opportunityId = originalRecordId;
            gen.writeIdField('RecordTypeId', recordTypeId);
            gen.writeIdField('Apttus__Related_Opportunity__c', opportunityId);
            Opportunity oppRecord = getOpportunityDetails(opportunityId);
            gen.writeStringField('CurrencyIsoCode', oppRecord.CurrencyIsoCode);
            if(oppRecord.AccountId != null) {
                gen.writeIdField('Apttus__Account__c', oppRecord.AccountId);
            } 
            if(recordTypeId == CON_CLM.PSA_RECORDTYPEID) {
                if(String.isNotBlank(oppRecord.Legacy_Quintiles_Opportunity_Number__c)){
                    gen.writeStringField('Project_Number__c', oppRecord.Legacy_Quintiles_Opportunity_Number__c);
                }
                if(oppRecord.Is_this_IQVIA_Biotech__c != null && oppRecord.Is_this_IQVIA_Biotech__c != ''){
                    gen.writeStringField('Study_Design__c', oppRecord.Is_this_IQVIA_Biotech__c);
                }
                if(oppRecord.Protocol_Number__c != null && oppRecord.Protocol_Number__c != ''){
                    gen.writeStringField('Protocol_Number__c', oppRecord.Protocol_Number__c);
                }
                gen.writeStringField('Name', oppRecord.Name);
                if(oppRecord.Line_of_Business__c != CON_CLM.LOB_CLINICAL_TECHNOLOGY){
                    gen.writeStringField('Special_Terms_Included__c',CON_CLM.RESTRICT_CO_AGREEMENT);
                }
            } else if(recordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID) {
                if(String.isNotBlank(oppRecord.Legacy_Quintiles_Opportunity_Number__c)) {
                    gen.writeStringField('Project_Number__c', oppRecord.Legacy_Quintiles_Opportunity_Number__c);
                }
                if(oppRecord.Protocol_Number__c != null && oppRecord.Protocol_Number__c != ''){
                    gen.writeStringField('Protocol_Number__c', oppRecord.Protocol_Number__c);
                }
                if(oppRecord.Proposal_Sent_Date__c != null){
                    gen.writeDateField('Proposal_Date__c', oppRecord.Proposal_Sent_Date__c);
                }
                gen.writeStringField('Name', oppRecord.Name);
            } else if(recordTypeId == CON_CLM.AMESA_RECORDTYPEID) {
                gen.writeStringField('Name', oppRecord.Name);
                gen.writeStringField('Opportunity_Number__c', oppRecord.Opportunity_Number__c);
            }
        }
        if(originalRecordId != null && String.valueOf(originalRecordId).startsWith('001') && recordTypeId != null) {
            Id accountId = originalRecordId;
            gen.writeIdField('RecordTypeId', recordTypeId);
            gen.writeIdField('Apttus__Account__c', accountId);
            Map<Id,Account> mapAccount = new SLT_Account().selectByAccountId(new Set<Id>{accountId}, new Set<String>{'Id','Name','CurrencyIsoCode'});
            Account account = mapAccount.get(accountId);
            gen.writeStringField('CurrencyIsoCode', account.CurrencyIsoCode);
            Map<String, Id> mapLE = getDefaultLegalEntityValuesForMSA();
            if(recordTypeId == CON_CLM.MSA_RECORDTYPEID) {
                gen.writeStringField('Apttus__Term_Months__c', '60');
                String services = getAgreementServicesOptions();
                if(services != null) {
                    gen.writeStringField('Services__c', services);
                }
                if(mapLE != null) {
                    if(mapLE.containsKey(CON_CLM.LEGAL_ENTITY_1_CODE) && mapLE.get(CON_CLM.LEGAL_ENTITY_1_CODE) != null) {
                        gen.writeStringField('Legal_Entity_1__c', mapLE.get(CON_CLM.LEGAL_ENTITY_1_CODE));
                    }
                	if(mapLE.containsKey(CON_CLM.LEGAL_ENTITY_2_CODE) && mapLE.get(CON_CLM.LEGAL_ENTITY_2_CODE) != null) {
                        gen.writeStringField('Legal_Entity_2__c', mapLE.get(CON_CLM.LEGAL_ENTITY_2_CODE));
                    }
                    if(mapLE.containsKey(CON_CLM.LEGAL_ENTITY_3_CODE) && mapLE.get(CON_CLM.LEGAL_ENTITY_3_CODE) != null) {
                        gen.writeStringField('Legal_Entity_3__c', mapLE.get(CON_CLM.LEGAL_ENTITY_3_CODE));
                    }
                }   
            }
        }
        if(originalRecordId != null && !(String.valueOf(originalRecordId).startsWith('006')) 
            && !(String.valueOf(originalRecordId).startsWith('001')) && recordTypeId != null) {
            Id siteSubmissionId = originalRecordId;
            gen.writeIdField('RecordTypeId', recordTypeId);
            gen.writeIdField('Site_Submission__c', siteSubmissionId);
            Set<String> fieldSet = new Set<String>{'Id', 'Name', 'CurrencyIsoCode', 'Opportunity__c', 'Opportunity__r.AccountId'};
            List<Site_Submission__c> siteSubmissionList = new SLT_SiteSubmission().getSiteSubmissionById(new Set<Id>{siteSubmissionId}, fieldSet);
            Site_Submission__c siteSubmission = siteSubmissionList.size() > 0 ? siteSubmissionList[0]: new Site_Submission__c();
            gen.writeStringField('CurrencyIsoCode', siteSubmission.CurrencyIsoCode);
            if(recordTypeId == CON_CLM.AVACARE_IQVIA_RECORDTYPEID) {
                List<Finance_IQVIA_Legal_Entity__c> lstFinanceIQVIAEntity = new SLT_Finance_IQVIA_Legal_Entity()
                    .getFinanceIQVIALegalEntityDetailsByCode(new Set<String>{CON_CLM.AVACARE_LEC}, new Set<String>{'Id'}, new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID});
                if(!lstFinanceIQVIAEntity.isEmpty() && lstFinanceIQVIAEntity[0].Id != null) {
                    gen.writeStringField('Legal_Entity_1__c', lstFinanceIQVIAEntity[0].Id);
                }
                gen.writeStringField('Name', siteSubmission.Name);
                gen.writeStringField('Related_Opportunity__c', siteSubmission.Opportunity__c);
                gen.writeStringField('Status_Category__c', CON_CLM.REQUEST);
                gen.writeStringField('Status__c', CON_CLM.PENDING_TEMPLATES);
                gen.writeStringField('Payment_Term__c', CON_CLM.PAYMENT_TERM_THIRTY);
            }
        }
        gen.writeEndObject();
        return gen.getAsString();
    }
    
	@AuraEnabled
    public static String getAgreementServicesOptions() {
        Map<String, String> mapPicklistLabelValue = new Map<String, String>();
        String picklistValues;
        try {
            String msaRecordTypeId = String.valueOf(CON_CLM.MSA_RECORDTYPEID);
            mapPicklistLabelValue = UTL_CLM.getPicklistOptionsByRecordTypeId('Apttus__APTS_Agreement__c', msaRecordTypeId, 'Services__c');
            mapPicklistLabelValue.keySet().removeAll(CON_CLM.EMEA_SERVICES);
            picklistValues = String.join(new List<String>(mapPicklistLabelValue.keySet()), ';');
        } catch(Exception ex) {
            system.debug(ex);
        }
        return picklistValues;
    }
    
    @AuraEnabled
    public static Map<String, Id> getDefaultLegalEntityValuesForMSA() {
        Map<String, Id> mapFinanceIQVIAEntity = new Map<String, Id>();
        Set<String> codeSet = new Set<String>{CON_CLM.LEGAL_ENTITY_1_CODE, CON_CLM.LEGAL_ENTITY_2_CODE, CON_CLM.LEGAL_ENTITY_3_CODE};
        Set<String> fieldSet = new Set<String>{'Id', 'Legacy_Entity_Code__c'};
        Set<Id> recordTypeIds = new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID};
        try {
            List<Finance_IQVIA_Legal_Entity__c> lstFinanceIQVIAEntity = new SLT_Finance_IQVIA_Legal_Entity()
                .getFinanceIQVIALegalEntityDetailsByCode(codeSet, fieldSet, recordTypeIds);
            if(lstFinanceIQVIAEntity != null && lstFinanceIQVIAEntity.size() > 0) {
                for(Finance_IQVIA_Legal_Entity__c legalEntity : lstFinanceIQVIAEntity) {
                    mapFinanceIQVIAEntity.put(legalEntity.Legacy_Entity_Code__c, legalEntity.Id);
                }
            }
        } 
        catch(Exception ex) {
           throw new AuraHandledException(JSON.serialize(ex));
        }
        return mapFinanceIQVIAEntity;
    }
    
    /**
     * This method is used to check Quote/Proposal details based on Opportunity Id
     * @params  Id opportunityId
     * @return  Boolean
    */
    @AuraEnabled
    public static Boolean validateQuoteDetails(Id opportunityId) {
        List<Apttus_Proposal__Proposal__c> listQuoteProposal = new List<Apttus_Proposal__Proposal__c>();
        if(Schema.sObjectType.Apttus_Proposal__Proposal__c.isAccessible()) {
            listQuoteProposal = new SLT_Proposal().getQuoteByRelatedOpportunity(new Set<Id>{opportunityId},
            new Set<String>{'Id', 'Apttus_Proposal__Opportunity__c', 'Record_Type_Name__c', 'Apttus_Proposal__Approval_Stage__c'}, 
            'Apttus_Proposal__Opportunity__c IN :opportunityIdSet AND Record_Type_Name__c = \'Tech Solution\' AND Apttus_Proposal__Approval_Stage__c != \'Rejected\'');
            if(!listQuoteProposal.isEmpty()) {
                return true;
            }
        }
        return false;
    }

    /**
     * This method is used to get Opportunity details based on Id
     * @params  Id opportunityId
     * @return  Opportunity
    */
    @AuraEnabled
    public static Opportunity getOpportunityDetails(Id opportunityId) {
        List<Opportunity> listOpportunity = SRV_CLM_Opportunity.getOppDetail(new Set<Id>{opportunityId},
            new Set<String>{'Id', 'Name', 'AccountId', 'Account.BillingAddress', 'Account.ShippingAddress', 'Account.ShippingCity', 'Account.ShippingState',
            'Account.ShippingCountry', 'Account.ShippingPostalCode', 'Account.ShippingStreet', 'Legacy_Quintiles_Opportunity_Number__c',
            'Global_project_unit__c', 'Protocol_Number__c','Proposal_Sent_Date__c', 'Line_of_Business__c', 'Is_this_IQVIA_Biotech__c', 'StageName'}).values();
        if(!listOpportunity.isEmpty()) {
            return listOpportunity.get(0);
        }
        return new Opportunity();
    }
    /**
     * This method is used to set defalut legal entity on agg
     * @return  Map<String, Id> mapFinanceIQVIAEntity
    */
    @testVisible
    private static Map<String, Id> setDefaultLegalEntityValuesForGCE() {
        Map<String, Id> mapFinanceIQVIAEntity = new Map<String, Id>();
        Set<String> codeSet = new Set<String>{CON_CLM.LEGAL_ENTITY_2_CODE};
        Set<String> fieldSet = new Set<String>{'Id', 'Legacy_Entity_Code__c'};
        Set<Id> recordTypeIds = new Set<Id>{CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID};
        try {
            List<Finance_IQVIA_Legal_Entity__c> lstFinanceIQVIAEntity = new SLT_Finance_IQVIA_Legal_Entity()
                .getFinanceIQVIALegalEntityDetailsByCode(codeSet, fieldSet, recordTypeIds);
            if(lstFinanceIQVIAEntity != null && lstFinanceIQVIAEntity.size() > 0) {
                for(Finance_IQVIA_Legal_Entity__c legalEntity : lstFinanceIQVIAEntity) {
                    mapFinanceIQVIAEntity.put(legalEntity.Legacy_Entity_Code__c, legalEntity.Id);
                }
            }
        } 
        catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return mapFinanceIQVIAEntity;
    }

    @AuraEnabled
    public static List<Id> getCLMRecordTypeIdsForMVP() {
        return new List<Id>{CON_CLM.MSA_RECORDTYPEID, CON_CLM.AMA_RECORDTYPEID, CON_CLM.VENDOR_RECORDTYPEID,
            CON_CLM.OSA_RECORDTYPEID};
    }
    
    @AuraEnabled
    public static String getAccountCurrency(Id accountId) {
        Map<Id, Account> accountMap = new SLT_Account().selectByAccountId(new Set<Id>{accountId}, new Set<String>{
            'CurrencyIsoCode'});
        return accountMap.isEmpty() ? null : accountMap.get(accountId).CurrencyIsoCode;
    }
    
    /**
     * This method is used to check current user is Admin user or not
     * @return  Boolean
    */
    @AuraEnabled
    public static Boolean checkAdminUser() {
        Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id> {userInfo.getUserId()}, 
            new Set<String>{'ProfileId', 'Name'});
        Map<Id, Profile> systemAdminProfileMap = new Map<Id, Profile>(
            new SLT_Profile().getAdminProfiles(new Set<String> {'Id', 'Name'}));
        if(!systemAdminProfileMap.isEmpty()) {
            User user = !userMap.isEmpty() ? userMap.values()[0] : new User();
            return systemAdminProfileMap.containsKey(user.ProfileId);
        }
        return false;
    }
    
    /**
     * This method is used to get Accessible Record Type Id
     * @return  Id
    */
    @AuraEnabled
    public static Id getAccessibleRecordTypeId() {
        for(RecordTypeInfo info: Apttus__APTS_Agreement__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isActive() && info.isAvailable()) {
                return info.getRecordTypeId();
            }
        }
        return null;
    }
}