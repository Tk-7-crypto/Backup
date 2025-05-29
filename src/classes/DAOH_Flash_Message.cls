public class DAOH_Flash_Message {
    public static void InsertRecords(List<Flash_Message__c> Records){
         System.debug('Inside InsertRecords');
         for(Flash_Message__c fm : Records)
         {
             if(fm.Parent__c == null && fm.ContactId__c == null && fm.Email_Adresss__c != null && fm.Pillar__c == 'Technology Solutions'){
                 List<string> EMailIds = fm.Email_Adresss__c.split(';'); 
                 List<string> EmailIds2 = new List<string>();
                 Map<string, Contact> cts = new Map<string,Contact>([SELECT Email,Id FROM CONTACT WHERE EMail in : EMailIds]);
                 
                 List<Flash_Message__c> fmsgs = new List<Flash_Message__c>();
                 for(String key:cts.keySet()){   
                     Flash_Message__c fMessage = new Flash_Message__c(
                         ContactId__c = cts.get(key).Id,
                         Message__c = fm.Message__c,
                         Start_Date__c = fm.Start_Date__c,
                         End_Date__c = fm.End_Date__c,
                         Email_Adresss__c = cts.get(key).Email,
                         Parent__c = fm.Id
                     );
                     fmsgs.Add(fMessage);
                     EmailIds2.Add(cts.get(key).Email);                   
                 }    
                 //Processing records with Error
                 for(string e : EMailIds){
                     if(!EmailIds2.Contains(e)){
                         Flash_Message__c fMessage = new Flash_Message__c(                             	 
                             Message__c = 'No Contact found linked to Email : ' + e,
                             Start_Date__c = fm.Start_Date__c,   
                             End_Date__c = fm.End_Date__c,		
                             Email_Adresss__c = e,
                             Parent__c = fm.Id
                         );
                         fmsgs.Add(fMessage);
                     }
                 }
                 insert fmsgs;     
             } 
         }         
     }
    
    public static void UpdateRecord(List<Flash_Message__c> newList, Map<Id, Flash_Message__c> oldMap){
        for(Flash_Message__c newObj : newList){
            Flash_Message__c oldObj = oldMap.get(newObj.Id);
            if(newObj.Parent__c == null && newObj.ContactId__c == null){
                if(newObj.Message__c != oldObj.Message__c || newObj.End_Date__c != oldObj.End_Date__c){
                    List<Flash_Message__c> fMessages = [SELECT Id,Message__c,End_Date__c,Name FROM Flash_Message__c WHERE ContactId__c!= null and Parent__c =: newObj.id];
                    for(Flash_Message__c fm : fMessages){
                        fm.Message__c = newObj.Message__c;
                        fm.Start_Date__c = newObj.Start_Date__c;
                        fm.End_Date__c = newObj.End_Date__c;
                    }
                    update fMessages;                    
                }
            }
        }        
    }
}
