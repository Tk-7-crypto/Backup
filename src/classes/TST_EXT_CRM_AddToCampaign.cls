@isTest
public class TST_EXT_CRM_AddToCampaign {
    
    @TestSetUp
    static void testSetUp(){
        Account acct = new Account (Name = 'Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        List<Contact> contactList = new List<Contact>();
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact1',
            AccountId = acct.Id
        );
        contactList.add(con); 
        
        Contact con1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact2',
            AccountId = acct.Id
        );
        contactList.add(con1);
        
        Contact con3 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact3',
            AccountId = acct.Id
        );
        contactList.add(con3);  
        insert  contactList;
        
        Campaign campaign = new Campaign(
            Name = 'Test Campaign',
            IsActive = TRUE
        );            
        insert campaign;
        
        
        List<CampaignMember> members = new List<CampaignMember>();
        CampaignMember member = new CampaignMember(
            ContactId = con.Id,
            Status = 'sent',
            CampaignId = campaign.Id
        ); 
        members.add(member); 
        
        CampaignMember member1 = new CampaignMember(
            ContactId = con1.Id,
            Status = 'sent',
            CampaignId = campaign.Id
        ); 
        members.add(member1);
        insert members; 
    }
    
    @isTest
    static void testAddContactToCampaign(){
        List<Contact> contactList = [Select Id from Contact];
        List<CampaignMember> cmList = [Select id , ContactID, CampaignId from CampaignMember];
        
        Test.startTest();
        PageReference pageRef = Page.VFP_CRM_AddToCampaign;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(contactList);
        setCtr.setSelected(contactList);
        EXT_CRM_AddToCampaign controller = new EXT_CRM_AddToCampaign(setCtr);
        controller.AddToCampaignRecords();
        Campaign camp = [Select Id from Campaign];
        controller.cmp  = new CampaignMember(campaignid = camp.Id);
        controller.AddToCampaignRecords();
        Test.stopTest();         
    }
    
    @isTest
    static void testAddContactToCampaignwithNoContacts(){
        List<Contact> contactList = new List<Contact>();
            
        Test.startTest();
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(contactList);
        setCtr.setSelected(contactList);
        EXT_CRM_AddToCampaign controller = new EXT_CRM_AddToCampaign(setCtr);        
        controller.AddToCampaignRecords();
        controller.getStatusOptions();
        Test.stopTest();         
    }
}