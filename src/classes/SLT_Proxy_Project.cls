/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Proxy Project Object.
 */
public class SLT_Proxy_Project extends fflib_SObjectSelector {
    
    /**
     * constructor to initialize CRUD and FLS
     */
    public SLT_Proxy_Project() {
        super(false, true, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Proxy_Project__c.sObjectType;
    }
    
    /**
     * This method used to get Proxy project by OpportunityId
     * @return List<Proxy_BNF__c>
     */
    public List<Proxy_Project__c> selectByFilter(Set<ID> oppIdSet, Set<String> fieldSet ) {
        String filterCondition = 'Opportunity__c in : oppIdSet AND Record_Type_Name__c = \'Project\'';
        return (List<Proxy_Project__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(filterCondition).toSOQL());
    }
            
    /**
     * This method used to get Proxy project by QI OLI Id
     * @return List<Proxy_Project__c>
     */
    public List<Proxy_Project__c> selectByQIOLIId(Set<ID> idSet, Set<String> fieldSet ) {
        return (List<Proxy_Project__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('QI_OpportunityLineItem_Id__c in :idSet AND (Opportunity__r.X5_Finalizing_Deal_Stage_Entry__c != null OR Opportunity__r.X6_Received_ATP_LOI_Stage_Entry__c != null OR Opportunity__r.X7a_Closed_Won_Stage_Entry__c  != null OR Opportunity__r.In_Hand_Stage_Entry__c != null)').toSOQL());
    }

    /**
     * This method used to get Proxy project by LI_Record_Id__c.
     * @return List<Proxy_Project__c>
     */
    public List<Proxy_Project__c> selectByLIRecordId(Set<ID> idSet, Set<String> fieldSet ) {
        return (List<Proxy_Project__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('LI_Record_Id__c in :idSet').toSOQL());
    }

    public List<Proxy_Project__c> selectByOpportunityId(Set<ID> idSet, Set<String> fieldSet ) {
        return (List<Proxy_Project__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Opportunity__c in :idSet').toSOQL());
    }
    
    /**
    * This method used to get Proxy Project by Opp id and record type name
    * @return List<Proxy_Project__c>
    */  
    public List<Proxy_Project__c> getProjectsByOpportunityIdAndRecordType(Set<String> oppIdSet, String recordTypeName ) {
        return [SELECT Id, Opportunity__c, Delivery_PIC_Offering_Segment__c, Delivery_PIC_Offering_Type__c,
                Delivery_PIC_Product_COE__c, Delivery_PIC_Business_Unit__c, Delivery_PIC_User_Country__c, 
                Business_Unit__c
                FROM Proxy_Project__c 
                WHERE Record_Type_Name__c =: recordTypeName 
                AND Opportunity__c in :oppIdSet 
               ];
    }
    
    public Map<Id, Proxy_Project__c> getProxyProjectByOppIDAndRecordTypeName(Set<ID> oppIdSet, String recordTypeName, Set<String> fieldSet) {
        fflib_QueryFactory proxyProjectQueryFactory = newQueryFactory(true);
        String queryString = proxyProjectQueryFactory.selectFields(fieldSet).setCondition('Opportunity__c in :oppIdSet AND Record_Type_Name__c =: recordTypeName').toSOQL();
        List<Proxy_Project__c> proxyProjectsList= (List<Proxy_Project__c>) Database.query(queryString);
        Map<Id, Proxy_Project__c> proxyProjetByOpportunity = new Map<Id, Proxy_Project__c>();
        for( Proxy_Project__c project : proxyProjectsList ) {
            proxyProjetByOpportunity.put(project.Opportunity__c, project);
        }
        return proxyProjetByOpportunity;
    }
    
    public List<Proxy_Project__c> getPlannedProjectByOppId(Set<Id> idSet, Set<String> fieldSet){
        return (List<Proxy_Project__c>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Project_Status__c =\'Planned\' AND Opportunity__c IN :idSet AND LI_OpportunityLineItem_Id__c = null').toSOQL());
    }
}