@isTest
private class TST_BidTeamDashboardController {
    
    public static testmethod void testDashboard() {
        //insert org locked customsetting
        BidTeamDashboardSettings__c bs = new BidTeamDashboardSettings__c(
                                             DashboardLocked__c = false,
                                             Locked_Message__c = 'msg');
        insert bs;
        
        Mulesoft_Integration_Control__c mulesoftSetting = new Mulesoft_Integration_Control__c();
        mulesoftSetting.Is_Mulesoft_User__c = true;
        upsert mulesoftSetting;
        
        //create PIC user
        Profile pr = [select id from profile where name like 'System Administrator' limit 1];
        
        String al = ('t' + System.now()).right(4) + 'a@gmail.com';
        User u = new User(FirstName = 'Test' + System.now(),ProfileId = pr.id, LastName = 'User' + System.now(),Bid_Team_Target__c = 1000,
                          alias =('t' + System.now()).right(8), Username = 'tstusr1@imshealth.com.uat', Email = 'testusr@iqvia.com', 
                          CommunityNickname = 't' + + System.now() + '.User', TimeZoneSidKey = 'Asia/Kolkata', LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', PIC_Eligible__c = true, Change_Request_Description__c = 'test',
                          Change_Request_Ticket_Number__c ='test description', employeeNumber= '080808081');
        insert u;
        //insert Principal Incharge
        Principal_In_Charge__c picUser = new Principal_In_Charge__c(User__c = u.id, name=u.lastname + ', ' + u.firstname);
        insert picUser;
       
        
        //  Test parameters
        Integer iNumTestOpps = 3;
        
        Map<Integer,String> StageName_Map = new Map<Integer,String>();
        
        // *****Fill the Map******
        StageName_Map.put(1,'1 - Identify Opportunity');
        StageName_Map.put(2,'2 - Verify Opportunity');
        StageName_Map.put(3,'3 - Understand Pre Proposal');
        StageName_Map.put(4,'4 - Develop & Deliver Proposal');
        StageName_Map.put(5,'5 - Negotiate Contract Ts & Cs');
        StageName_Map.put(6,'6a - Closed Won');
        
        //  Create test accounts, opportunities etc.
        Account acct1 = new Account(Name='SPO ProdFlag Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct1;
        Map<Id,Opportunity> OpportunityInsert_Map = new Map<Id,Opportunity>();
        List<Opportunity> InsertOppList = new List<Opportunity>();
        
        Integer j = 1;
        for (Integer i=0;i<iNumTestOpps;i++)
        {
            //Add test opportunity
            Opportunity oppty1 = new Opportunity(Name = 'SPO ProdFlag Test Oppty');
            oppty1.StageName = '1 - Identify Opportunity';
            oppty1.CloseDate = System.today();
            oppty1.AccountId = acct1.Id;
            oppty1.CurrencyIsoCode = 'USD';
            InsertOppList.add(oppty1);      
        }
        insert InsertOppList;        
        List<Bid_Team_Credit__c> fSummaryList = new List<Bid_Team_Credit__c>();
        //create Bid Team Credit Records
        for(Opportunity opp : InsertOppList) {
           String stgStr = '';
           if(opp.stagename == '1 - Identify Opportunity') {stgStr = '1';}
           if(opp.stagename == '2 - Verify Opportunity') {stgStr = '2';}
           if(opp.stagename == '3 - Understand Pre Proposal') {stgStr = '3';}
           if(opp.stagename == '4 - Develop & Deliver Proposal') {stgStr = '4';}
           if(opp.stagename == '5 - Negotiate Contract Ts & Cs') {stgStr = '5';}
           if(opp.stagename == '6a - Closed Won') {stgStr = '6';}
           if(opp.stagename == '6b - Closed Lost') {stgStr = '6';}
           if(opp.stagename == 'In Hand') {stgStr = 'RIH';}
           if(opp.stagename == 'Budget') {stgStr = '0';}
    
    
            Bid_Team_Credit__c fSummary = new Bid_Team_Credit__c(
                                                                    C_S_Recognised_Revenue__c = 100,/*opp.amount/4.0,*/
                                                                    C_S_Unrecognised_Revenue__c = 100,/*opp.amount/4.0,*/
                                                                    Financial_Year__c = 2012,
                                                                    FY_Impact__c = 400,/*opp.amount,*/
                                                                    I_A_Recognised_Revenue__c = 100,/*opp.amount/4.0,*/
                                                                    I_A_Unrecognised_Revenue__c = 100,/*opp.amount/4.0,*/
                                                                    Opportunity__c = opp.id,    
                                                                    Stage__c = stgStr);
                fSummaryList.add(fSummary);
           }
         insert fSummaryList;
        
        //start the test
        ApexPages.currentPage().getParameters().put('runasid', u.id );
        BidTeamDashboardController bc = new BidTeamDashboardController();
        bc.userId = u.Id;
        bc.updateRunAsUser();
        system.assertNotEquals(null, bc.getRihVsTargetPercentage());
        system.assertNotEquals(null, bc.getBidTeamTargetAmount());
        system.assertNotEquals(null, bc.getPipeline1To4TotalAmount());
        system.assertNotEquals(null, bc.getPipeline5TotalAmount());
        system.assertNotEquals(null, bc.getWnihTotalAmount());
        system.assertNotEquals(null, bc.getUnRecognisedTotal());
        system.assertNotEquals(null, bc.getRecognisedTotal());
        system.assertNotEquals(null, bc.getPipelineTotalAmount());
        bc.getPipelineToGoPercentage();
        bc.getBidTeamTarget();
        
    }
    
    public static testmethod void noDataTestDashboard(){
        //insert org locked customsetting
        BidTeamDashboardSettings__c bs = new BidTeamDashboardSettings__c(
                                             DashboardLocked__c = true,
                                             Locked_Message__c = 'msg');
        insert bs;
        //start the test
        BidTeamDashboardController bc = new BidTeamDashboardController();
        system.assertEquals(true, bc.hasErrMsg);
    }

}