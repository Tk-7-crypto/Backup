@isTest
public class TST_DAOH_Flash_Message {
    @IsTest
    static void testInsertRecords() {
        Account newAccount = UTL_TestData.createAccount();
        insert newAccount;
        
        Contact con =  new Contact(FirstName = 'TestFirstName', Email ='vinaymauryably@gmail.com' , LastName = 'TestContact', accountId = newAccount.id);
        insert con;
        //insert con;
        List<Flash_Message__c> flashMessageList = New List<Flash_Message__c>();
        Flash_Message__c flashMessage = new Flash_Message__c
            (Email_Adresss__c = 'vinaymauryably@gmail.com;vinaymauryably@outlook.com',
             Message__C='Sample',
             Start_Date__c =system.today(),
             Parent__c = null
            );
        flashMessageList.add(flashMessage);
        insert flashMessageList;
        DAOH_Flash_Message.InsertRecords(flashMessageList);
        
        
        List<Flash_Message__c> fMessages = [SELECT Id,Message__c,End_Date__c,Name FROM Flash_Message__c WHERE ContactId__c!= null and Parent__c =: flashMessage.id];
         for(Flash_Message__c fm : fMessages){
                        fm.Message__c = 'newObj.Message__c';
                       
                    }
        
        update fMessages;
        
        //DAOH_Flash_Message.UpdateRecord(flashMessageList);
        
        
        
        //InsertRecords
    }
}