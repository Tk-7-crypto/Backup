public class DAOH_QueueUserRelationship {

    public static void customEmailAddressValidation(List<Queue_User_Relationship__c> queueUserList){
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern patt = null;
        Matcher match = null;
        if(queueUserList != null && queueUserList.size() > 0){
            for(Queue_User_Relationship__c queueUserRecord : queueUserList){
                if(queueUserRecord.AFU_Queue_Email__c != null && queueUserRecord.AFU_Queue_Email__c != ''){
                    patt = Pattern.compile(emailRegex);
                    match = patt.matcher(queueUserRecord.AFU_Queue_Email__c.trim());
                    if(!match.matches()){
                        queueUserRecord.AFU_Queue_Email__c.addError('Invalid email address format : '+queueUserRecord.AFU_Queue_Email__c);
                    }
                }
                if(queueUserRecord.Queue_Emails_Text__c != null && queueUserRecord.Queue_Emails_Text__c != ''){
                    for(String mail : queueUserRecord.Queue_Emails_Text__c.split(';')){
                        patt = Pattern.compile(emailRegex);
                        match = patt.matcher(mail.trim());
                        if(!match.matches()){
                            queueUserRecord.Queue_Emails_Text__c.addError('Enter a valid email address(es) separated by semicolon');
                        }
                    }
                }
            }
        }
    }

    
    public static void updateDefaultQueue(List<Queue_User_Relationship__c> newList, Map<Id,Queue_User_Relationship__c> oldMap){
        List<Id> usIdList = new List<Id>();
        Map<Id,String> uspMap = new Map<Id,String>();
        List<Id> idList = new List<Id>();
        List<Queue_User_Relationship__c> qurIdList = new List<Queue_User_Relationship__c>();
        for(Queue_User_Relationship__c q : newList){
            if(q.isDefaultQueue__c && q.isDefaultQueue__c != oldMap.get(q.Id).isDefaultQueue__c){
                usIdList.add(q.User__c);
                idList.add(q.Id);
                if(q.Pillar__c != null){
                    uspMap.put(q.User__c, q.Pillar__c);
                }
                    
            }
        }
        if(usIdList != null && !usIdList.isEmpty()){
            List<Queue_User_Relationship__c> qList = Database.query('select Id,isDefaultQueue__c,User__c,Pillar__c from Queue_User_Relationship__c where User__c in :usIdList and id not in : idList and isDefaultQueue__c = true');
            for(Queue_User_Relationship__c q : qList){
                if(uspMap.containsKey(q.User__c) && uspMap.get(q.User__c) == q.Pillar__c){
                    q.isDefaultQueue__c = false;
                    qurIdList.add(q);
                }
            }
        }
        if(qurIdList != null && !qurIdList.isEmpty()){
            try{
                update qurIdList;
            }catch(DmlException e){
                
            }
        }
    }
}