@isTest
public with sharing class TST_CNT_AEA_EmailBodyComposer {
    @testSetup
    static void setup(){
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'CA&S',
            Sub_Group__c = 'CP&A-CA&S',
            Name = 'CA&S'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'ASL',
            Sub_Group__c = 'Analytics Strategy Lead',
            Name = 'ASL'
        ));
        insert resourceToSubGroupSettingList;
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = userInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        insert bidHistory;
        
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: bidHistory.Id];
      
        
        Indication_List__c indicationList = new Indication_List__c(Name= 'Test Indication', Therapy_Area__c = 'Oncology');
        insert indicationList;
        
        List<Agreement_Email_Alert__c> agEmailList = new List<Agreement_Email_Alert__c>{
            new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail1.com', Account__c = acc.Id, Indication__c = indicationList.id),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail2.com', Indication__c = indicationList.id),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail3.com', Region__c = 'Asia Pacific'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail4.com', Intervention_Type__c = 'Vaccine'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail5.com', Drug_Classification_Product_Name__c = 'Test'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail6.com', Phase__c = 'Phase 2'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail7.com', Line_of_Business__c = 'Core Clinical'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail8.com', Level__c = 'CO'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail8.com', Country__c ='US'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail9.com', Incl_on_re_bids__c ='Yes'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail10.com', Is_this_IQVIA_Biotech__c = 'Yes'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail11.com', Is_this_a_virtual_trials_study__c = 'Yes Fully Virtual'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail12.com', Is_there_a_Client_Bid_Grid__c = 'Yes'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail13.com', FSP__c = 'Yes'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail14.com', Service__c = 'Biostatistical'),
                new Agreement_Email_Alert__c(Alerting_Email__c ='Test123@mail14.com', Age_Group__c = 'Infants - 1 Month to 2 Years')
                };
                    INSERT agEmailList;
        Contact con = new Contact(FirstName='Testing', LastName ='Test', accountId=acc.Id, Email ='test@mail.com');
        INSERT con;
    }
    
    static testMethod void testGetRecepients(){
        String actId = [SELECT id FROM Account LIMIT 1].Id;
        String agId = [SELECT id FROM Bid_History__c LIMIT 1].Id;
        //List<Sobject> actMatch =  CNT_AEA_EmailBodyComposer.getRecepients(actId);
        List<Sobject> agMatch =  CNT_AEA_EmailBodyComposer.getRecepients(agId);
        // system.assertEquals(1, actMatch.size());
        //system.assertEquals(12, agMatch.size());
        
    }
    
    static testMethod void testGetRecords(){
        String actId = [SELECT id FROM Account LIMIT 1].Id;
        String agId = [SELECT id FROM Bid_History__c LIMIT 1].Id;
        // Sobject actMatch =  CNT_AEA_EmailBodyComposer.getRecord(actId);
        Sobject therapy =  CNT_AEA_EmailBodyComposer.getRecord(agId);
        Sobject opp =  CNT_AEA_EmailBodyComposer.getOppRecord(agId);
        
    }
    static testMethod void testGeneratePreview(){
        Id folder = [SELECT id FROM Folder WHERE Name = 'Triage Folder'].id;
        EmailTemplate emailTemp = new EmailTemplate (developerName = 'test', FolderId = folder, TemplateType= 'Text', Name = 'test',
                                        IsActive = true, body='Test mail test', Subject = 'Testing'); 
        insert emailTemp;
        String actId = [SELECT id FROM Account LIMIT 1].Id;
        EmailTemplate ema =  CNT_AEA_EmailBodyComposer.generatePreview(emailTemp.Id, actId);
        System.assertEquals(emailTemp.body, ema.body);
        System.assertEquals(emailTemp.Subject, ema.Subject);
    }
    static testMethod void testSendMail(){
        List<String> reciepiants = new List<String>();
        reciepiants.add('test@gmail.com');
        reciepiants.add('test123@mail.com');
        Id folder = [SELECT id FROM Folder WHERE Name = 'Triage Folder'].id;
        EmailTemplate emailTemp = new EmailTemplate (developerName = 'test', FolderId = folder, TemplateType= 'Text', Name = 'test',
                                        IsActive = true, HtmlValue=' Test mail test', Subject = 'Testing'); 
        insert emailTemp;
        String actId = [SELECT id FROM Account LIMIT 1].Id;
         CNT_AEA_EmailBodyComposer.sendMail(emailTemp.Id, actId, reciepiants,reciepiants,reciepiants );
    }
    static testMethod void testGetTemplates(){
        List<String> reciepiants = new List<String>();
        reciepiants.add('test@gmail.com');
        reciepiants.add('test123@mail.com');
        Id folder = [SELECT id FROM Folder WHERE Name = 'Triage Folder'].id;
        EmailTemplate emailTemp = new EmailTemplate (developerName = 'test', FolderId = folder, TemplateType= 'Text', Name = 'BHRtest',
                                        IsActive = true, HtmlValue=' Test mail test', Subject = 'Testing'); 
        insert emailTemp;
        String actId = [SELECT id FROM Account LIMIT 1].Id;
        List<Sobject> emilTemplate =  CNT_AEA_EmailBodyComposer.getEmailTemplates();
        System.assertNotEquals(0, emilTemplate.size());
    }
} 