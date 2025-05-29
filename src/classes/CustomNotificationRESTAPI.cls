public inherited sharing class CustomNotificationRESTAPI {
    
    @future(callout=true)
    public static void sendCustomNotificationAfter21Winter(String strNotifiTypeDevName, string lstObjectsJSON, string lstRecipientsJSON,String queueName,string bySource) {
        CustomNotificationType cnt = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = :strNotifiTypeDevName Limit 1];
        List<Case> newList = (List<Case>)JSON.deserialize(lstObjectsJSON, List<Case>.Class);
        Set<String> lstRecipients =(Set<String>)JSON.deserialize(lstRecipientsJSON, Set<String>.class);
        Messaging.CustomNotification note = new Messaging.CustomNotification();
        if(!newList.isEmpty() && !lstRecipients.isEmpty()) {
            for(Case c : newList) {
                if(bySource =='Worknote'){
                    note.setTitle('Worknote is added'); 
                    note.setBody('Case Number '+c.CaseNumber+' has a new Work Note.');
                }
                
                if(bySource =='By Dispatch'){
                    note.setTitle('Case Dispatched'); 
                    note.setBody('Case Number '+c.CaseNumber+' for Account Name ' +c.Account_Name_Article__c+' with priority '+c.Priority+' has been dispatched queue '+queueName);
                }
                if(bySource =='By Assign'){
                    note.setTitle('Case Assigned'); 
                    note.setBody('Case Number '+c.CaseNumber+' for Account Name ' +c.Account_Name_Article__c+
                                 ' with priority '+c.Priority+' has been assigned to you.');
                }
                note.setNotificationTypeId(cnt.id);
                note.setTargetId(c.Id); // target object id
                note.send(lstRecipients);
            }
        
        //note.setSenderId(Userinfo.getUserId());
        
        }
    }
    
    /* @future(callout=true)
    public static void sendCustomNotification(String strNotifiTypeDevName, string lstObjectsJSON, string lstRecipientsJSON,string bySource) {
        String strResponse = null;
        List<Sobject> lstObjects =(List<Sobject>)JSON.deserialize(lstObjectsJSON, List<Sobject>.class);
        List<Id> lstRecipients =(List<Id>)JSON.deserialize(lstRecipientsJSON, List<Id>.class);
        if(String.isNotBlank(strNotifiTypeDevName)) {
            String strResourceQuery = 'tooling/query/?q=select+id,customNotifTypeName+from+CustomNotificationType+where+DeveloperName=\''+ strNotifiTypeDevName +'\'';
            if(Test.isRunningTest()){
                String body = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"CustomNotificationType","records":[{"attributes":{"type":"CustomNotificationType","url":"/services/data/v46.0/tooling/sobjects/CustomNotificationType/0ML8A0000004CNPWA2"},"Id":"0ML8A0000004CNPWA2","CustomNotifTypeName":"NotificationBellForCaseComment"}]}';
                strResponse = body;
            }
            else{
                strResponse = OrgREST.retriveResult(strResourceQuery, 'GET', null);
            }
        }
        map<String, Object> objData;
        
        if(String.isNotBlank(strResponse)) {
            // Deserializeing the response body
            map<String, Object> mapJsonData = (map<String, Object>)JSON.deserializeUntyped(strResponse);
            CustomNotificationType customtype  =new CustomNotificationType(id='0ML8A0000004CNPWA2',CustomNotifTypeName ='NotificationBellForCaseComment');
            list<Object> lstRecordsData = (list<Object>)mapJsonData.get('records');
            if(lstRecordsData!=null && !lstRecordsData.isEmpty()) {
                // Converting each object to readable map to get the data
                objData = (map<String, Object>)lstRecordsData[0];      
            }
        }
        if(!lstObjects.isEmpty() && !lstRecipients.isEmpty()) {
            JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
            jsGen.writeFieldName('inputs');
            jsGen.writeStartArray();
            Case caseQuery =[Select Owner.Name from case where id =:lstObjects[0].id];
            for(sObject obj : lstObjects) {
                jsGen.writeStartObject();
                
                if(objData != null && !objData.isEmpty()){
                    jsGen.writeStringField('customNotifTypeId', (String)objData.get('Id'));
                }

                jsGen.writeFieldName('recipientIds');
                jsGen.writeStartArray();
                for(Id idRecipient : lstRecipients) {
                    jsGen.writeId(idRecipient);
                }
                jsGen.writeEndArray();

                if(bySource =='Worknote'){
                    jsGen.writeStringField('title', 'Worknote is added'	); 
                    jsGen.writeStringField('body', 'Case Number '+(String)obj.get('CaseNumber')+' has a new Work Note.');
                }
                
                if(bySource =='By Dispatch'){
                    jsGen.writeStringField('title', 'Case Dispatched'); 
                    jsGen.writeStringField('body', 'Case Number '+(String)obj.get('CaseNumber')+' for Account Name ' +(String)obj.get('Account_Name_Article__c')+
                                           ' with priority '+(String)obj.get('Priority')+' has been dispatched queue '+caseQuery.Owner.Name);
                }
                if(bySource =='By Assign'){
                    jsGen.writeStringField('title', 'Case Assigned'); 
                    jsGen.writeStringField('body', 'Case Number '+(String)obj.get('CaseNumber')+' for Account Name ' +(String)obj.get('Account_Name_Article__c')+
                                           ' with priority '+(String)obj.get('Priority')+' has been assigned to you.');
                }
                jsGen.writeStringField('targetId', (String)obj.get('Id'));
                
                jsGen.writeEndObject();
            }
            
            jsGen.writeEndArray();
            jsGen.writeEndObject();
            
            // Converting JSON as String
            String strJson = jsGen.getAsString();
            System.debug('strJson ====> '+strJson);
            
            // POST URL to send custom notification
            String strPOSTURL = 'actions/standard/customNotificationAction';
            //String strPOSTURL ='https://iqvia--csmxag.lightning.force.com/lightning/r/Case/5008A000005mTF4QAM/view';
            // Sending post request to send custom notification
            String strPostResponse = OrgREST.retriveResult(strPOSTURL, 'POST', strJson);
        }
    }*/
}