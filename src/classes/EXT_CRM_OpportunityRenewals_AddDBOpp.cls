/**
* This class is the implementation of 'Add Opp' button on the DB.
*
* Date : 19th Oct, 2010.
* Author : Metacube Software Ltd.
*/

public class EXT_CRM_OpportunityRenewals_AddDBOpp {
    public transient String searchOppNum {get; set;}
    
    public List<Opportunity> resultOppList {get; private set;}
    
    public String oppId {get; set;}
    
    public Boolean isAddSuccessful {get; set;}
    
    public PageReference doSearch() {
        if( (searchOppNum == null) || searchOppNum.trim() == '' || searchOppNum.length() < 2) {            
            String msg = 'Search term must be two or more characters long.';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,  msg);            
            ApexPages.addMessage(myMsg);
            return null;
        }
        resultOppList = (List<Opportunity>)[FIND : searchOppNum+'*' RETURNING Opportunity(id, name, 
                                owner.name, Account.name, Opportunity_Number__c)][0];
        System.debug('inside method resultOppList = ' + resultOppList );                              
        return null;
    }
    
    public PageReference addDBOpportunity() {
        //check if a renewal task already exists for this opp - done in trigger.  
        //check if this opp has already been cloned
        System.debug('oppId = ' + oppId);
        
        
        //check if already a renewal task has been created for the opp
        List<Renewal_Task__c> rtList = [select id, owner.name, owner.email, Cloning_Status__c from Renewal_Task__c
                                        where Opportunity__c = :oppId AND Cloning_Status__c != :CON_CRM_OpportunityRenewals.CLONED_STATUS_STR AND Is_Removed__c = FALSE];
        
        System.debug('rtList = ' + rtList );                                        
        if(  rtList.size() > 0) {
            isAddSuccessful = false;
            String msg = 'This opportunity already exists on ' + rtList[0].owner.name + '\'s Dashboard and state is : ';
            
            msg += (rtList[0].Cloning_Status__c != null)? rtList[0].Cloning_Status__c  : ' Not Defined.' ;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,  msg);            
            ApexPages.addMessage(myMsg);
            return null;
        } 
        /*
        Renewal_Dashboard_Settings__c R = Renewal_Dashboard_Settings__c.getOrgDefaults();
        String RenewalYear = String.valueOf(R.Renewal_Year__c.round());
        String SOQL_Query = 'select id, Opportunity_Number__c from Opportunity where From_Opportunity__c = \''+ oppId + '\' and Name like \'%Renewal%'+ RenewalYear +'%\'';
        system.debug('SOQL_Query: '+ SOQL_Query);
        List<opportunity> clonedOppList = Database.query(SOQL_Query);
        if(  clonedOppList.size() > 0) {
            isAddSuccessful = false;
            String msg = 'This opportunity has already been cloned as <a href="/' + clonedOppList[0].id + '" target="_blank">' + clonedOppList[0].Opportunity_Number__c + '</a>.';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,  msg);            
            ApexPages.addMessage(myMsg);
            return null;
        }*/
        
        opportunity opp = [select id, CloseDate, CurrencyIsoCode from Opportunity where id = :oppId limit 1 ][0];
                                               
        SavePoint sp = Database.setSavePoint();
        try {   
            Renewal_Task__c rt = new Renewal_Task__c();
            rt.ownerId = UserInfo.getUserId();
            rt.Cloning_Status__c = '' ; 
            rt.Opportunity__c = oppId ;
            rt.Is_Removed__c = FALSE;
            if(opp != null ) {
                rt.CurrencyIsoCode = opp.CurrencyIsoCode;
                if(opp.CloseDate != null) 
                    rt.Targeted_Close_Date__c = opp.CloseDate.addMonths(12);
             }
                
            insert rt;
            isAddSuccessful = true;
        }catch (Exception ex){
           //roll back the transcation
           database.rollback(sp);
           isAddSuccessful = false;
           System.debug(LoggingLevel.ERROR, 'Server error while adding opportunities : ' + ex.getMessage());           
           ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Server error occured while processing your request.' + ex.getMessage());                        
           //add error on page
           ApexPages.addMessage(errMsg );
          }
        return null;
    }
    
}