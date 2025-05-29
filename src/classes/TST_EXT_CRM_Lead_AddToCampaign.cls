@isTest
public class TST_EXT_CRM_Lead_AddToCampaign {
    
    @TestSetUp
    static void testSetUp(){
        
        List<Lead> leadList = new List<Lead>();
        List<CampaignMember> members = new List<CampaignMember>();
        
        Lead lead1 = new Lead(
            FirstName = 'Test1',
            LastName = 'Lead1',
            Company  = 'Test Company',
            Country = 'India'
        );
        leadList.add(lead1);  
        
        Lead lead2 = new Lead(
            FirstName = 'Test2',
            LastName = 'Lead2',
            Company = 'Test Company',
            Country = 'India'
        );
        leadList.add(lead2); 
        
        Lead lead3 = new Lead(
            FirstName = 'Test3',
            LastName = 'Lead3',
            Company = 'Test Company',
            Country = 'India'
        );
        leadList.add(lead3);        
        insert leadList;
        
        Campaign campaign = new Campaign(
            Name = 'Test Campaign',
            IsActive = TRUE
        );            
        insert campaign;
        
        CampaignMember member = new CampaignMember(
            LeadId = lead1.Id,
            Status = 'sent',
            CampaignId = campaign.Id
        ); 
        members.add(member); 
        
        CampaignMember member1 = new CampaignMember(
            LeadId = lead2.Id,
            Status = 'sent',
            CampaignId = campaign.Id
        ); 
        members.add(member1); 
        insert members; 
    }
    
    @isTest
    static void testAddLeadToCampaign(){
        List<Lead> leadList = [Select Id from Lead];
        List<CampaignMember> cmList = [Select id , LeadID, CampaignId from CampaignMember];
        
        Test.startTest();
        
        PageReference pageRef = Page.VFP_CRM_Lead_AddToCampaign;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(leadList);
        setCtr.setSelected(leadList);
        EXT_CRM_Lead_AddToCampaign controller = new EXT_CRM_Lead_AddToCampaign(setCtr);
        Campaign camp = [Select Id from Campaign];
        controller.cmp  = new CampaignMember(campaignid = camp.Id);
        controller.AddToCampaignRecords();
        Test.stopTest();  
        
    }
    
    @isTest
    static void testAddLeadToCampaignWithNoLeads(){
        List<Lead> leadList = new List<Lead>();
        
        Test.startTest();
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(leadList);
        setCtr.setSelected(leadList);
        EXT_CRM_Lead_AddToCampaign controller = new EXT_CRM_Lead_AddToCampaign(setCtr);
        controller.AddToCampaignRecords();
        controller.getStatusOptions();
        Test.stopTest();       
    }
}