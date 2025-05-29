@isTest
public class TST_CNT_CSM_FlashMessage {
    @IsTest
    static void testGetFlashMessage() {
        
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        
        Contact con = UTL_TestData.createContact(newAccount.id);
        insert con;
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId(); 
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Id recordTypeIdTechno = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        Id recordTypeIdData = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA Case').getRecordTypeId();
        Id recordTypeIdAP = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        Id recordTypeIdAR = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Id recordTypeIdCreate = Schema.SObjectType.case.getRecordTypeInfosByName().get('DATA CREATE Service').getRecordTypeId();
        case newCase = new Case(
            Origin = 'Chat',
            Status = 'New',
            LOS__C = 'CRC Lab',
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OneKeyID__c = 'WFRD00890450',
            OneKey_LastName__c = 'BISMUTH',
            OneKey_FirstName__c = 'ALAIN',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdAP
        );
        insert newCase;
        
            case newCase1 = new Case(
            Origin = 'Chat',
            Status = 'New',
            LOS__C = 'CRC Lab',
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OneKeyID__c = 'WFRD00890450',
            //OneKey_LastName__c = 'BISMUTHI',
            //OneKey_FirstName__c = 'ALAINI',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno
        );
        insert newCase1;
        
        case newCase2 = new Case(
            Origin = 'Chat',
            Status = 'New',
            LOS__C = 'CRC Lab',
            CurrentQueue__c=queues.Id,
            InitialQueue__c = 'Q1',
            OneKeyID__c = 'WFRD00890450',
            //OneKey_LastName__c = 'BISMUTHI',
            //OneKey_FirstName__c = 'ALAINI',
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = recordTypeIdTechno
        );
        insert newCase2;
        Case case1 =[SELECT ID,CaseNumber FROM case where Id= :newCase.Id LIMIT 1];
        Flash_Message__c fm = new Flash_Message__c(LOS__C = 'CRC Lab',Message__C='',Start_Date__c =system.today(),Pillar__c ='R&D');        
        insert fm;
        string losMessage = CNT_CSM_FlashMessage.GetFlashMessage('', case1.CaseNumber,recordTypeIdAP);
        System.assertEquals('', losMessage);
        
        Flash_Message__c fm1 = new Flash_Message__c(Queue__c = newCase.CurrentQueue__c ,Message__C='',Start_Date__c =system.today(),Pillar__c ='R&D');        
        insert fm1;
        string Message = CNT_CSM_FlashMessage.GetFlashMessage('', case1.CaseNumber,recordTypeIdAP);
        System.assertEquals('', Message);
        
        
        Flash_Message__c fmm = new Flash_Message__c(ContactId__c = con.Id,Message__C='Sample',Start_Date__c =system.today());
        insert fmm;
        string TechMessage = CNT_CSM_FlashMessage.getFlashMessage(con.Id, '',recordTypeIdTechno);
         System.assertEquals('Sample', TechMessage);
        
        System.assertEquals(false,CNT_CSM_FlashMessage.checkIfSNStatusCancelled(recordTypeIdAR,null, newCase.Id));
        System.assertEquals(false,CNT_CSM_FlashMessage.checkSNStatusForParent(newCase.Id));
        System.assertEquals(false,CNT_CSM_FlashMessage.getReasonForLateMessage(newCase2.Id,recordTypeIdTechno));
        System.assertEquals(false,CNT_CSM_FlashMessage.getReasonForLateMessageForCreate(newCase2.Id));
        System.assertEquals(true,CNT_CSM_FlashMessage.checkTimeSheetMessage(newCase2.Id,recordTypeIdCreate));
    }
    
}
