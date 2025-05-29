global class SCH_PEP_ContractExpired Implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        updateContractStatus();
        updateTrainingStatus();
    }
    
    public void updateContractStatus()
    {
        String contractType='PRM Contract';
        
        List<Contract> contracts = [SELECT Id,EndDate,Status,StartDate FROM Contract WHERE RecordType.Name= : contractType 
                                           AND PRM_Contract_type__c IN ('Agency Program SOW','Sandbox Agreement','Data Program','Tech Program') AND ((EndDate < :Date.Today() AND Status != 'Concluded' ) OR(StartDate <= :Date.Today() AND Status = 'Not Started'))];
        
        for(Contract con : contracts)
        {
            con.Status = (con.EndDate < Date.Today() && con.Status != 'Concluded')? 'Concluded':(con.StartDate <= Date.Today() && con.Status == 'Not Started')? 'Active':con.Status;            
        }
        
        update contracts;
         
    }
    
    // Below is the class for changing statuts for training managemnet//
    public void updateTrainingStatus()
    {
        
        List<TS_LMS_Training_Management__c> trainingStatus = [SELECT Id,Status__c,Subscription_End_Date__c,SOW__c FROM TS_LMS_Training_Management__c WHERE SOW__c = true AND Subscription_End_Date__c = :Date.Today() AND Status__c != 'Closed'];
        
        for(TS_LMS_Training_Management__c tltm : trainingStatus)
        {
            tltm.Status__c = 'Closed';            
        }
        
        update trainingStatus;
        
    }
}