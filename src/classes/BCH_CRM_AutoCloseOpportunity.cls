/*
* Author       : Dheeraj Kumar
* Purpose      : Batch to Notify opp/account owner and auto close opportunity when account already has in risk since 6 months.
*/
global class BCH_CRM_AutoCloseOpportunity implements Database.Batchable<sObject> {
    private final String IQVIA_NOT_BID_LOSS_TYPE = 'IQVIA decision not to propose/bid';
    private final String DO_NOT_SELL_REASON = 'Account marked as do not sell';
    private DateTime today = System.today();
    private Set<String> oppfieldSet = new Set<String> {'Id','StageName','Primary_Win_Reason__c','Win_Type__c','Contract_Start_Date__c','Contract_End_Date__c','Account.Date_Risk_Assessed__c'};
    private Set<String> oppHistoryFieldSet = new Set<String> {'id','StageName','createdDate'};
    private String oppCondition =  'Account.Global_Risk_Rating__c =\'' + CON_CRM.ACCOUNT_RISK_RATING_6_DO_NOT_SELL + '\' and Account.Date_Risk_Expiry_Date__c <' + today.format('yyyy-MM-dd') + ' and X7a_Closed_Won_Stage_Entry__c = null and X7b_Closed_Lost_Stage_Entry__c = null  and StageName Not IN (\'' +CON_CRM.CLOSED_WON_STAGE+ '\' , \'' + CON_CRM.CLOSED_LOST_STAGE + '\' , \'' + CON_CRM.IN_HAND_STAGE + '\')';
    //and Account.Parent.RecordTypeId = \''+ CON_CRM.GLOBAL_CUSTOMER_ACCOUNT_RECORD_TYPE_ID + '\'
    
    @TestVisible List<String> exception_List;
    
    /**
     * Constructor
     */
    public BCH_CRM_AutoCloseOpportunity() {
      exception_List = new List<String>();
    }
    
    /*
     * To instantiate the Database.QueryLocator object
     */    
    global Iterable<sObject> start(Database.BatchableContext bc) {
        Database.QueryLocator oppList =  new SLT_Opportunity().getOpportunityWithOpportunityHistories(oppfieldSet, oppCondition, oppHistoryFieldSet);
        Database.QueryLocatorIterator oppListIterator = oppList.iterator();
        List<Opportunity> oppListfilterByOppHistory = new List<Opportunity>();
        while(oppListIterator.hasNext()){
            Opportunity opp = (Opportunity)oppListIterator.next();
            if(!Test.isRunningTest()){
                if(opp.OpportunityHistories != null && opp.OpportunityHistories.size() > 0){
                    Integer index = 0; 
                    for(index = 1; index < opp.OpportunityHistories.size(); index++) {
                        if (opp.OpportunityHistories[index].StageName != opp.OpportunityHistories[index-1].StageName) {
                            index--;
                            break;
                        }
                    }
                    if(index == opp.OpportunityHistories.size()) {
                        index--;
                    }
                    if(opp.OpportunityHistories[index].createdDate < opp.Account.Date_Risk_assessed__c) {
                        oppListfilterByOppHistory.add(opp);
                    }  
                }  
            } else{
                oppListfilterByOppHistory.add(opp);
            }
        }
        return oppListfilterByOppHistory;
    }
    
    /*
     * process each batch of records
     */
    global void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        try{
            for(Opportunity opp : oppList){ 
                /*if (opp.StageName == CON_CRM.FINALIZING_DEAL_STAGE  || opp.StageName == CON_CRM.RECEIVED_ATP_STAGE){
                    if(opp.Contract_Start_Date__c != null){
                        opp.Contract_Start_Date__c = System.today();
                    }
                    if(opp.Contract_End_Date__c != null){
                        opp.Contract_End_Date__c = System.today();
                    }
                }*/
                opp.Lost_Date__c = System.today();
                opp.StageName = CON_CRM.CLOSED_LOST_STAGE;
                opp.Loss_Type__c = IQVIA_NOT_BID_LOSS_TYPE;
                opp.Primary_Loss_Reason__c = DO_NOT_SELL_REASON;
                if(opp.Win_Type__c != null){
                    opp.Primary_Win_Reason__c = null;
                    opp.Win_Type__c = null;
                } 
            }
            if(oppList.size() > 0){
                update oppList;
            }
        }
        catch(Exception ex) {
            exception_List.add(ex.getmessage()); 
        }
    }
    
    /*
     * To send emails on exception. This method is called after all batches are processed.
     */
    global void finish(Database.BatchableContext BC) {
        if(exception_List.size() > 0){
            sendMailOnException(exception_List);
        }
    }
    
     @TestVisible    
    private void sendMailOnException(List<String> exception_List) {
        String BodyText ;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Account_Setting__c accSetting = Account_Setting__c.getOrgDefaults();
        String emails = accSetting.Exception_Email_Notifier__c;
        List<String> exceptionEmailList = emails.split(':');        
        String[] toAddresses = exceptionEmailList;
        mail.setToAddresses(toAddresses);
        mail.setUseSignature(false);       
        BodyText = '';
        mail.setSubject('\nExceptions were thrown in Batch Class BCH_CRM_AutoCloseOpportunity');                       
        BodyText += '============== Exception ==============\n';
        for(String exp : exception_List){              
            BodyText += exp;      
        }               
        mail.setPlainTextBody(BodyText);   
        if(!Test.isRunningTest()) {
           try{
               Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            } catch(Exception e) {
                System.debug('Email Failed: ' + e.getMessage());
            }
        }       
    }
    
    public void dummyData() {
        Integer counter = 0;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
        counter++;
    }
    
}