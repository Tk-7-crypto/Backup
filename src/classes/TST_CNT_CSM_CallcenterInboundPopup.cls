@isTest
private class TST_CNT_CSM_CallcenterInboundPopup {
    
    @testSetup
    static void dataSetup() {
        
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Account acct1 = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct1;
        /* Added Start */
        Account acct2 = new Account(
            Name = 'TestAcc2',
            RDCategorization__c = 'Sponsor',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct2;
        Study__c study= new Study__c(Name = 'CaseTestStudy', Sponsor__c = acct2.Id);
        insert study;
        /* Added End */
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='918197783299', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com');
        insert Con;
        
        User u = [select id from user where id = : UserInfo.getUserId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='Rnd group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            Queue_User_Relationship__c qur1 = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User',
                TECH_QueueUser__c = qur.Id,
                Group_Id__c = grpUser.group.Id);
            
            insert qur1;
            
            /**List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
            Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
            queues.Name = 'Rnd Services';
            queues.QueueName__c = 'Rnd Services';
            queues.Type__c = 'Queue';
            queues.Group_Id__c = grpUser.group.Id;
            insert queues;
            
            Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
            queueUser.Name = 'Rnd Services';
            queueUser.QueueName__c = 'Rnd Services';
            queueUser.Type__c = 'User';
            queueUser.User__c = UserInfo.getUserId();
            queueUser.Group_Id__c = grpUser.group.Id;
            queueUser.IsDefaultQueue__c = true;
            queueUser.TECH_QueueUser__c = queues.Id;
            insert queueUser;*/
            
            Entitlement ent = new Entitlement(Name='Testing', AccountId=acct2.Id,Type = 'R_D',
                                              BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                              StartDate=Date.valueof(System.now().addDays(-2)), 
                                              EndDate=Date.valueof(System.now().addYears(2)));
            insert ent;
            
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Study__c =study.Id,
                Sponsor__c = acct2.Id,   
                Origin = 'Chat',
                Status = 'In Progress',
                OwnerId = u.Id,
                //EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase,
                CurrentQueue__c = qur1.Id
            );
            try{
                insert c;  
            }catch (DmlException e) {
                System.debug('Failed to Insert :'+e);
            }
            
        }
        
        InboundNumber__c studydata = new InboundNumber__c(pq__c='pv1' , vmbox__c='pv2' , project__c ='pv3' , country__c='pv4' , language__c='pv5' , queue__c='pv6' , study__c='pv7' , los__c='pv9');
        studydata.greeting_text__c='Thank you for calling the IQVIA Contact Center, My name is Mallikarjuna Reddy B Please can you confirm you are comfortable to continue the call in English? (engage interpreter if needed)May I have your First and Last name please and a call back number in case we get disconnectedCan I confirm you are calling in relation to a **IVR OPTION**';
        studydata.Salesforce_LOS__c = 'EDC Support';
        InboundNumber__c defaultm = new InboundNumber__c();
        defaultm.greeting_text__c='Thank you for calling the IQVIA Contact Center, My name is Mallikarjuna Reddy B Please can you confirm you are comfortable to continue the call in English? (engage interpreter if needed)May I have your First and Last name please and a call back number in case we get disconnectedCan I confirm you are calling in relation to a **IVR OPTION**';
        defaultm.pq__c='DEFAULT';
        insert new List<InboundNumber__c>{defaultm,studydata};
    }
    
    public testmethod static void testGreetingMessage() {

        PageReference pageRef = Page.VFP_CSM_CallcenterInboundPopup;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('callCenterValues','{\"contactChannelAddress\":\"918197783299\",\"dialed_number\":\"918197783299\",\"project_code\":\"STS\",\"country\":\"USA\",\"language\":\"ENG\",\"Overflow\":\"No\",\"Queue\":\"GCC_REGISTRY_STS_ENG\",\"study_protocol_name\":\"Registry_STS\",\"line_of_service\":\"GCC_REG\",\"call_recording_consent\":\"No\",\"originalLanguage\":\"N/A\"}');

        CNT_CSM_CallcenterInboundPopup popUp=new CNT_CSM_CallcenterInboundPopup();
        popUp.displayPopUpModel();
        popUp.closePopUpModel();
        popUp.createCase();
        
    }

}
