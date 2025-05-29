public class SLT_Contract_External extends fflib_SObjectSelector{
    
    /**
    * This method used to get field list of sobject
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Contract__x.Id,
            Contract__x.Name__c,
            Contract__x.DisplayUrl,
            Contract__x.ContractNumber__c
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return Contract__x.sObjectType;
    }

    /**
    * This method used to get Contract__x by Id
    * @return  List<Contract__x>
    */
    public List<Contract__x> selectById(Set<Id> idSet){
        return (List<Contract__x>) selectSObjectsById(idSet);
    }

    /*
    * This method is use to query primary agreement of related opportunity which exclude current agreement
    *
    */
    public List<Contract__x> getContractUsingContractNumber(String contractNumber, Set<String> fieldSet){

        return (List<Contract__x>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('ContractNumber__c =: contractNumber').toSOQL());
    }
}