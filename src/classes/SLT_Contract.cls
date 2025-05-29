public class SLT_Contract extends fflib_SObjectSelector {
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Contract() {
        super(false, true, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() { 
        return new List<Schema.SObjectField>{
            Contract.Id,
            Contract.Name,
            Contract.ContractNumber,
            Contract.Parent_Contract__c,
            Contract.Parent_Contract_Number__c,
            Contract.Ultimate_Parent_Contract_Number__c,
            Contract.AccountId,
            Contract.Legal_Entity_Customer__c,
            Contract.Legal_Entity_Quintiles__c,
            Contract.Opportunity_Number__c,
            Contract.Opportunity_Name__c,
            Contract.Opportunity_Link__c,
            Contract.Other_Opportunities__c,
            Contract.Project_Number__c,
            Contract.Therapy_Area__c,
            Contract.Drug_Product_Name__c,
            Contract.Global_Project_Unit__c,
            Contract.Delivery_Unit__c,
            Contract.Data_Transfer_Agreement_included__c,
            Contract.Negotiating_Office__c,
            Contract.Date_Tracking_started__c,
            Contract.Protocol_Number__c,
            Contract.Cost_Point_Project_Code__c,
            Contract.Account.Name,
            Contract.Parent_Contract__r.ContractNumber
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Contract.sObjectType;
    }
    
    /**
     * This method used to get Contact by Id
     * @return  Map<Id, Contact>
     */
    public Map<Id, Contract> selectByContractId(Set<ID> idSet, Set<String> fieldSet) {
        return new Map<Id, Contract>((List<Contract>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public List<Contract> selectByContractIdList(Set<ID> idSet, Set<String> fieldSet) {
        return ((List<Contract>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    
    public Map<Id, Contract> selectCNFContractsByProjAndChangeOrderNumber(Set<String> projNumSet, Set<String> chanOrdSet, Set<String> fieldSet) {
        string cnfGBORecordType = CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO;
        return new Map<Id, Contract>((List<Contract>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project_Number__c in :projNumSet AND Change_Order_Number__c in :chanOrdSet AND Change_Order_Parent__c = null AND RecordTypeId = :cnfGBORecordType').toSOQL()));
    }
    public Map<Id, Contract> fetchParentContract(Set<Id> idSet, Set<String> fieldSet){
        return new Map<Id, Contract>((List<Contract>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    public List<Contract> fetchContract(Set<Id> idSet, Set<String> fieldSet){
        return ((List<Contract>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL()));
    }
    public List<Contract> getContractUsingContractNumber(String contractNumber, Set<String> fieldSet){
        return (List<Contract>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ContractNumber =: contractNumber').toSOQL());
    }
    public List<Contract> selectByPRMContract(ID contractPRM_RT,String userAccountId) {
        return Database.query('SELECT Id,ContractNumber,Name,SOW_status__c,Status,Date_executed_signed_contract_received__c,StartDate,EndDate FROM Contract where AccountId =:userAccountId AND RecordTypeId=:contractPRM_RT ORDER BY Date_executed_signed_contract_received__c DESC');
    }
    public List<Contract> selectExistingContract(String agencyProgramId) {
        return Database.query('SELECT Id, AccountId, Name, Status, ContractTerm, SOW_status__c, Payment_status__c,New_Contract_Number__c FROM Contract WHERE Agency_Program__c =: agencyProgramId AND New_Contract_Number__c=NULL AND Notification_Counter__c<4 ORDER BY ID DESC LIMIT 1');
    }
    public Contract selectContractById(String contractId) {
        return Database.query('SELECT ID,ContractNumber, Payment_method__c, SOW_status__c,Notification_Counter__c,New_Contract_Number__c,Product__c,Non_Standard_Contract__c,Renewal_Status__c, AccountId, tolabel(Account.AccountCountry__c),Agency_Program__c FROM Contract WHERE ID =: contractId limit 1');
    }
    public Contract selectContractToRenew(String contractId) {
        return Database.query('Select Id,Agency_Program__c,ContractNumber,EndDate from Contract where Id=:contractId LIMIT 1');
    }
    public Contract selectNewContractById(String newContractId) {
        return Database.query('select ContractNumber from Contract where ID=:newContractId');
    }
    public List<Contract> selectChildContract(String currentContractNumber) {
        return Database.query('SELECT Id from Contract WHERE PRM_Parent_Contract_Number__c=: currentContractNumber');
    }
    public List<Contract> selectParentContract(String childContractNumber) {
        return Database.query('SELECT Id,Renewal_Status__c,ContractNumber FROM Contract WHERE New_Contract_Number__c=:childContractNumber');
    }
    public List<Contract> getContractByContractNumber(Set<String> contractNumberSet, Set<String> fieldSet){
        return (List<Contract>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ContractNumber in: contractNumberSet').toSOQL());
    }
    public List<Contract> getContractByContractNumberCondition(String contractNumberCondition) {
        return Database.query(contractNumberCondition);
    }
    public List<Contract> getContractByStatus(Set<ID> accId) {
		return Database.query('Select Id, AccountId from Contract WHERE Status =\'Active\' AND  PRM_Contract_type__c IN (\'Agency Program SOW\', \'Sandbox Agreement\',\'Data Program\',\'Tech Program\') AND AccountId IN :accId');             
    }
    /**
     * This method used to get Contract by conditon
     * @return Contract List
     */
    public List<Contract> getContractListByCondition(Set<String> fields, String condition, Set<Id> contractIds) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
    public List<Contract> getContractByAssetName(Set<ID> accId,Set<String> assetNameSet) {
		return Database.query('Select Id, AccountId,Agency_Program__r.Name from Contract WHERE Agency_Program__r.Name IN :assetNameSet AND Status =\'Active\' AND  PRM_Contract_type__c IN (\'Agency Program SOW\', \'Sandbox Agreement\',\'Data Program\',\'Tech Program\') AND AccountId IN :accId');             
    }
}