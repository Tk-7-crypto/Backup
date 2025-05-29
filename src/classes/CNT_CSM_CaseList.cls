public with sharing class CNT_CSM_CaseList {
    @AuraEnabled
    public static List<CSM_Community_ListView_Config__c> getCSMCommunityListViewConfig(){   
        List<CSM_Community_ListView_Config__c> values= new List<CSM_Community_ListView_Config__c>();
        values =  CSM_Community_ListView_Config__c.getall().values();
        return values;
    }

    @AuraEnabled
    public static List<CSM_Community_ListView_Config__c> getCSMCommunityListViewForCurrentUser(){   
        List<CSM_Community_ListView_Config__c> listViews= new List<CSM_Community_ListView_Config__c>();
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null) {
                String pillar = users[0].Contact.Portal_Case_Type__c;
                String userType = users[0].Contact.Contact_User_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';

                List<String> restricted_product = new List<String>();
                String restricted_product_condition = '';
                List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'Product__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                if(dataList != null && !dataList.isEmpty()){
                    for (Integer i=0; i<dataList.size(); i++) {
                        if(dataList[i].Product__c != null ){
                            restricted_product.add('Restricted_Product__c LIKE \'%' + dataList[i].Product__c + '%\'');
                        }
                    }
                    restricted_product_condition = ' (' + String.join(restricted_product, ' OR ') + ')';
                } else {
                    restricted_product_condition = ' Restricted_Product__c= \'\'';
                }
                String fields = 'Name, Portal_Case_Type__c, en__c, fr__c, it__c, jp__c, order__c, pt__c, ru__c, de__c, es__c, ja__c, pl__c, zh__c, Restricted_Product__c';
                String contact_role_conditions = '';
                if (userType == 'Rep User') {
                    contact_role_conditions ='Restricted_User_Type__c = \'Rep User\' AND '; 
                }
                listViews = Database.query('select ' + fields + ' from CSM_Community_ListView_Config__c where Portal_Case_Type__c  in (' + pillar + ') and ' + contact_role_conditions + restricted_product_condition + ' order by order__c asc');
            }
        }
        return listViews;
    }

    @AuraEnabled
    public static List<Contact> getUserContact(){ 
        List<User> users = new List<User>();
        users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Contact> contacts=new List<Contact>();
        if(users != null && users.size() > 0){
            contacts = new SLT_Contact().selectByContactIdList(new Set<Id> {users[0].ContactId}, new Set<String>{'Portal_Case_Type__c','AccountId'});            
        }
        return contacts;
    }
}
