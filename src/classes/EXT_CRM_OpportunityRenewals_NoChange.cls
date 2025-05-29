//********
//  IMS  
//  Created by Anjali Salecha on 12-July-2010
//  Class contain properties and methods to create Opportunity clone with diffrent buisness logics
//  class implements INT_CRM_OpportunityRenewals interface 
///*******

public class EXT_CRM_OpportunityRenewals_NoChange extends INT_CRM_OpportunityRenewals
 {
    
    /////************  Properties   *************///////////// 
    
    //List<Opportunity> listOpportunityToClone{get;set;}
    
    
    /////************  Constructor   *************/////////////
    
    public EXT_CRM_OpportunityRenewals_NoChange()
    {
        
    }   
    
    /////************  Methods   *************/////////////
    
    //Method clone Opportunities for Renewal_Task where Cloning_Action is equal to CON_CRM_OpportunityRenewals.NO_CHANGE_STR
    public List<Renewal_Task__c> CloneOpportunities_For_Renewal_With_NoChange(List<Renewal_Task__c> listRenewalTask)
    {
        try 
        {
            /*Map<ID,Renewal_Task__c> mapOpportunityIdAndRenewalTask = new Map<ID,Renewal_Task__c>();
            if(listRenewalTask != null && listRenewalTask.size()>0)
                for(Renewal_Task__c renewalTask : listRenewalTask)
                    if(renewalTask.Cloning_Action__c != null && renewalTask.Cloning_Action__c.equalsIgnoreCase(CON_CRM_OpportunityRenewals.NO_CHANGE_STR))
                        mapOpportunityIdAndRenewalTask.put(renewalTask.Opportunity__c, renewalTask);
            
            Set<ID> opportunityIds = mapOpportunityIdAndRenewalTask.keySet();
            system.debug('opportunityIds###'+opportunityIds);
            List<Opportunity> listOriginalOpportunity = Database.query(GenerateSelectQueryWithAllFields('Opportunity')+'where ID in :opportunityIds');
            //*/
            
            System.debug('listRenewalTask = ' + listRenewalTask);
            List<Renewal_Task__c> filteredList = new List<Renewal_Task__c>();
            if(listRenewalTask != null && listRenewalTask.size()>0)
                for(Renewal_Task__c renewalTask : listRenewalTask)
                    if(renewalTask.Cloning_Action__c != null && (!renewalTask.Cloning_Action__c.equalsIgnoreCase(CON_CRM_OpportunityRenewals.NO_RENEW_STR)))
                        filteredList.add(renewalTask);
            //Generate list of Opportunities clone from original clone 
            //return CreateOpportunityHierarchyAndItsClone(listOriginalOpportunity,mapOpportunityIdAndRenewalTask);
            return CreateOpportunityHierarchyAndItsClone(filteredList);
        }
        catch(Exception cloneException)
        {
            system.debug('GenerateCloneEception ### '+cloneException.getMessage()); 
            throw cloneException;
        }
    }
    
    //Override abstract class method to set value in Stage field of Opportunity clone
    public override void SetStageField(Opportunity cloneOpportunity, Renewal_Task__c rt) 
    {
        //cloneOpportunity.StageName = '5 - Negotiate Contract Ts & Cs';
        if(rt.Cloning_Action__c == CON_CRM_OpportunityRenewals.CHANGE_DETAIL_STR || rt.Cloning_Action__c == CON_CRM_OpportunityRenewals.NO_CHANGE_STR){
            cloneOpportunity.StageName = CON_CRM_OpportunityRenewals.OPP_STAGE_3;
            cloneOpportunity.Forecast_Category__c = CON_CRM.ON_TRACK;
        }
    }
}