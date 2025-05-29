public class UTL_CDA_RequestEditWrapper {
    @AuraEnabled
    public Map<String, ObjectFieldsWrapper> cdaRequestFieldsDetailMap { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> iqviaBusinessCdaTypeDependencyMap { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> iqviaBusinessDisclosurePeriodDependencyMap { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> cdaTypeCdaLanguageDependencyMap { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> cdaTypeCompetContractCapDependencyMap { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> competContractStudySponDependencyMap { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> custLegalEntityCountryStateDependencyMap { get; set; }
    
    @AuraEnabled
    public Map<String, List<String>> recipientAccCountryStateDependencyMap { get; set; }
    
    @AuraEnabled
    public String loggedInUserType { get; set; }
    
    @AuraEnabled
    public CDA_Settings__c cdaSettingValues { get; set; }
    
    @AuraEnabled
    public CDA_Request__c cdaRequest { get; set; }
    
    @AuraEnabled
    public User loggedIdUserDetail { get; set; }

    @AuraEnabled
    public List<UTL_CDAUtility.cdaAdditionalContactWrapper> cdaAdditionalContactWrapperList {get; set;}
}