@isTest
public class TST_CNT_TPA_Com_Owner_Chnge_Request_Form {
    @isTest
    static void CNT_TPA_ContinueNotificationProcesstest(){
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();

        TPA_Assigned_TP_Processor__c obj1 = new TPA_Assigned_TP_Processor__c(Commercial_Owner_Email__c = 'a@a.in', Temporary_Commercial_Owner_Email__c = 'a@a.in', Out_of_Office_Leave_End_Date__c = Date.Today().addDays(10),Out_of_Office_Leave_Start_Date__c = Date.Today().addDays(-10));
        insert obj1;

        TPA_Assigned_TP_Processor__c obj = new TPA_Assigned_TP_Processor__c(Commercial_Owner_Email__c = 'a@a.in', Temporary_Commercial_Owner_Email__c = 'a@a.in', Out_of_Office_Leave_End_Date__c = Date.Today().addDays(10),Out_of_Office_Leave_Start_Date__c = Date.Today().addDays(-10));
       
        
        Test.startTest();
        PageReference pageRef = Page.VFP_TPA_Com_Owner_Change_Request_Form;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CSId', 'a@a.in');
                 

        CNT_TPA_Com_Owner_Chnge_Request_Form controller = new CNT_TPA_Com_Owner_Chnge_Request_Form();
        controller.getassignedTPProcessorObj();
        String tpaRequestJSON2 = JSON.serialize(obj);
        CNT_TPA_Com_Owner_Chnge_Request_Form.saveRequest(tpaRequestJSON2);
        String Data = CNT_TPA_Com_Owner_Chnge_Request_Form.jsonAssignedTPProcessorList;
        String validDomains = controller.validEmailDomains;
        String oferingList = CNT_TPA_Com_Owner_Chnge_Request_Form.jsonOfferingList;
        CNT_TPA_Com_Owner_Chnge_Request_Form.deleteCurrentRecord(JSON.serialize(obj1.id));
        CNT_TPA_Com_Owner_Chnge_Request_Form.getJSONAssignedTPProUseOffCombMap(JSON.serialize(obj.Commercial_Owner_Email__c));
        Test.stopTest();
    }
    
    @isTest
    static void CNT_TPA_Com_Owner_Chnge_Request_Formtest(){
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = 'test' , BU__c = 'United States' , Geo_Level__c = 'Sub-National');
        insert imsDataAsset;
        String tpaRequestJSON2 = JSON.serialize(imsDataAsset);
        CNT_TPA_Com_Owner_Chnge_Request_Form.saveRequest(tpaRequestJSON2);
    }
    
}