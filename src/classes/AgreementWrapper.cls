public class AgreementWrapper{
    @AuraEnabled
    public Apttus__APTS_Agreement__c agreement{get;set;}
    @AuraEnabled
    public IQVIA_Agreement__c iqviaAgreement{get;set;}
    @AuraEnabled
    public Agreement_Extension__c agreementExtension{get;set;}
    @AuraEnabled
    public Boolean isUpdatable {get;set;}
    @AuraEnabled
    public Boolean isDeletable {get;set;}
    @AuraEnabled
    public String recordTypeName {get;set;}
    @AuraEnabled
    public Boolean showProjectManagerPrompt {get;set;}
    @AuraEnabled
    public Date dateTrackingStarted {get;set;}
    @AuraEnabled
    public List<Id> contentVersionIds {get;set;}
    @AuraEnabled
    public String docType {get;set;}
    @AuraEnabled
    public String action {get; set;}
    @AuraEnabled
    public String coNumber {get;set;}
    @AuraEnabled
    public Boolean showBudgetPrompt {get;set;}
    @AuraEnabled
    public ContentVersion contentVersion{get;set;}
    @AuraEnabled
    public Opportunity opportunity{get;set;}
    @AuraEnabled
    public BNF2__c BNF{get;set;}
    @AuraEnabled
    public MIBNF_Component__c MiBNF{get;set;}
    
    public AmendAgreementWrapper amendAgreementWrapper {get; set;}

    public AgreementWrapper(){
        
    }
    public AgreementWrapper(Apttus__APTS_Agreement__c agreement,Agreement_Extension__c agreementExtension){
        this.agreement = agreement;
        this.agreementExtension = agreementExtension;
    }
    public AgreementWrapper(Apttus__APTS_Agreement__c agreement, Agreement_Extension__c agreementExtension, IQVIA_Agreement__c iqviaAgreement) {
        this.agreement = agreement;
        this.iqviaAgreement = iqviaAgreement;
        this.agreementExtension = agreementExtension;      
    }
    
    public class AmendAgreementWrapper{
        public String contractId {get; set;}
        public String action {get; set;}
        public String agreementId {get; set;}
        public String recordTypeDeveloperName {get; set;}
        public String type {get; set;}
        public Apttus__APTS_Agreement__c clinicalAgreement {get; set;}
        public Opportunity selectedOpportunity {get; set;}
        public Agreement_Contacts__c agreementContact {get; set;}
        public Date requestDate {get; set;}
        public String contractRanking {get; set;}
    }
    
    public class FileWrapper {
        public String title {get; set;}
        public String id {get;set;}
        public String conVerId {get;set;}
    }   

    public class CPQCLMWrapper {
        public Boolean hasAGRAccess {get; set;}
        public Boolean hasRelatedAgreement {get;set;}
        public Boolean isNonInflightAgreement {get;set;}
        public Boolean activatedPSAFound  {get;set;}
        public Map<Id,Integer> oppToInFlightAgrMap {get;set;}
        public Map<Id,Apttus__APTS_Agreement__c> mapOfPropIdAGR {get;set;}
    }  
}