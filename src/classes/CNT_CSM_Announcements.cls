public class CNT_CSM_Announcements {
    @AuraEnabled
    public static String getUserSessionId(){
        return CNT_PEP_SessionPageController.fetchUserSessionId();
    }
    @AuraEnabled(cacheable=true)
    public static List<CSM_QI_Announcement__c> getAnnouncementsForCurrentUser(Boolean includeExpired){
        List<CSM_QI_Announcement__c> announcements = new List<CSM_QI_Announcement__c>();
        List<User> users = new List<User>();
        if(UserInfo.getUserType().contains(CON_CSM.S_CUSTOMER_SUCCCESS)) {
            users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Portal_Case_Type__c','Contact.Contact_User_Type__c','AccountId','Contact.Remove_KB_Access__c'});
            if (users.size() > 0 && users[0].Contact != null && users[0].AccountId != null && users[0].Contact.Remove_KB_Access__c != true) {
                List<CSM_QI_Announcement__c> announcements1 = new List<CSM_QI_Announcement__c>();
                List<CSM_QI_Announcement__c> announcements2 = new List<CSM_QI_Announcement__c>();
                List<CSM_QI_Announcement__c> announcements3 = new List<CSM_QI_Announcement__c>();
                List<CSM_QI_Announcement__c> announcements4 = new List<CSM_QI_Announcement__c>();

                String selectedFields = 'Id, Subject__c, Description__c, CreatedDate, Expiry_Date__c';
                
                String pillar = users[0].Contact.Portal_Case_Type__c;
                pillar = '\'' + pillar.replace(';','\',\'') +'\'';
                String userType = users[0].Contact.Contact_User_Type__c;
                List<asset> assets = new List<asset>();
                String productsIds ='',prodIds = '',removeProdIds ='';
                List<Id> prodList = new List<Id>();
                if (pillar.indexOf('R&D') == -1) {
                    List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
                    if(dataList != null && !dataList.isEmpty()){
                        for (Integer i=0; i<dataList.size(); i++) {
                            if(dataList[i].ProductId__c != null ){
                                prodList.add(dataList[i].ProductId__c);
                                prodIds += '\''+ dataList[i].ProductId__c+'\'';
                                if(i < dataList.size()-1){
                                    prodIds += ',';
                                }
                            }
                        }
                        if(prodList != null && !prodList.isEmpty()){
                            assets = new SLT_Asset().getAssetsWithFilter(new Set<String>{'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id in ('+prodIds+')'); 
                        }
                    }else{
                        List<Id> removeProd = new List<Id>();
                        List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                        for (Integer i=0; i<prodDataList.size(); i++) {
                            if(prodDataList[i].Product__c != null ){
                                removeProd.add(prodDataList[i].Product__c);
                                removeProdIds += '\''+ prodDataList[i].Product__c+'\'';
                                if(i < prodDataList.size()-1){
                                    removeProdIds += ',';
                                }
                            }
                            
                        }    
                        if(removeProd.size()>1){
                            assets = new SLT_Asset().getAssetsWithFilter(new Set<String>{'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\' AND Product2Id not in  ('+removeProdIds+')'); 
                        }else{
                            assets = new SLT_Asset().getAssetsWithFilter(new Set<String>{'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\'');     
                        }
                    }
                    
                    for (Integer i=0; i<assets.size(); i++) {
                        productsIds += '\''+ assets[i].Product2Id+'\'';
                        if(i < assets.size()-1){
                            productsIds += ',';
                        }
                    }
                }
                
                String expriredCondition = '';
                if (! includeExpired) {
                    expriredCondition = 'and Expiry_Date__c >= TODAY'; 
                }

                String productsCondition ='';
                /*Added by Malli CSM-1116*/
                if(prodList != null && prodList.isEmpty()){
                    if (pillar.indexOf('R&D') == -1) {
                        productsCondition = 'Id not in (select CSM_Announcement__c from CSM_QI_Announcement_Product_Relationship__c) and';    
                    }
                    announcements1 =  Database.query('select ' + selectedFields + ' from CSM_QI_Announcement__c where ' + productsCondition + ' Id not in (select CSM_Announcement__c from CSM_QI_Announcement_Account_Relationship__c) and Contact_User_Type__c Includes (\'' + userType+ '\') and Pillar__c Includes (' + pillar + ') ' + expriredCondition );
                    announcements.addAll(announcements1);
                    
                    if (pillar.indexOf('R&D') == -1) {
                        productsCondition = 'Id not in (select CSM_Announcement__c from CSM_QI_Announcement_Product_Relationship__c) and';    
                    }
                    announcements2 =  Database.query('select ' + selectedFields + ' from CSM_QI_Announcement__c where ' + productsCondition + ' Id in (select CSM_Announcement__c from CSM_QI_Announcement_Account_Relationship__c where account__c =\''+ users[0].AccountId +'\') and Contact_User_Type__c Includes (\'' + userType+ '\') and Pillar__c Includes (' + pillar + ') ' + expriredCondition);
                    announcements.addAll(announcements2);
                }
                /*Added by Malli CSM-1116*/

                if (pillar.indexOf('R&D') == -1) {
                    productsCondition = 'Id in (select CSM_Announcement__c from CSM_QI_Announcement_Product_Relationship__c where product__c in ('+ productsIds +') ) and';    
                    announcements3 =  Database.query('select ' + selectedFields + ' from CSM_QI_Announcement__c where ' + productsCondition + ' Id not in (select CSM_Announcement__c from CSM_QI_Announcement_Account_Relationship__c) and Contact_User_Type__c Includes (\'' + userType+ '\') and Pillar__c Includes (' + pillar + ') ' + expriredCondition );
                    announcements.addAll(announcements3);
            
                    productsCondition = 'Id in (select CSM_Announcement__c from CSM_QI_Announcement_Product_Relationship__c where product__c in ('+ productsIds +') ) and';
                    announcements4 =  Database.query('select ' + selectedFields + ' from CSM_QI_Announcement__c where ' + productsCondition + ' Id in (select CSM_Announcement__c from CSM_QI_Announcement_Account_Relationship__c where account__c =\''+ users[0].AccountId +'\') and Contact_User_Type__c Includes (\'' + userType+ '\') and Pillar__c Includes (' + pillar + ') ' + expriredCondition );
                    announcements.addAll(announcements4);
                }  
            }
        }
        return announcements;
    }
    
    @AuraEnabled 
    public static List<CSM_QI_Announcement__c> getAnnouncementsForCurrentPRMUser(Boolean homePage,Boolean restricted){
        List<User> users = new List<User>();
        List<CSM_QI_Announcement__c> announcements = new List<CSM_QI_Announcement__c>();
        List<CSM_QI_Announcement__c> announcements1 = new List<CSM_QI_Announcement__c>();
        List<CSM_QI_Announcement__c> announcements2 = new List<CSM_QI_Announcement__c>();
        List<CSM_QI_Announcement__c> announcements3 = new List<CSM_QI_Announcement__c>();
        List<CSM_QI_Announcement__c> announcements4 = new List<CSM_QI_Announcement__c>();
        List<CSM_QI_Announcement__c> announcements5 = new List<CSM_QI_Announcement__c>();
        List<CSM_QI_Announcement__c> announcements6 = new List<CSM_QI_Announcement__c>();
        
        users = new SLT_User().selectContactDetailByUser(new Set<Id> {userInfo.getUserId()}, new Set<String> {'Contact.Partner_Type__c','Contact.Portal_Case_Type__c','AccountId'});
        String userAccountId = users[0].AccountId;
        String partnerType = users[0].Contact.Partner_Type__c;
        partnerType = '\'' + partnerType.replace(';','\',\'') +'\'';
        String pillar = users[0].Contact.Portal_Case_Type__c;
        pillar = '\'' + pillar.replace(';','\',\'') +'\''; 
        
        String expiredCondition = '';
        if (homePage) {
            expiredCondition = 'and Expiry_Date__c >= TODAY'; 
        }
        
        String productsIds ='';
        List<asset> assets = new SLT_Asset().getAssetsWithFilter(new Set<String>{'Product2Id'}, 'AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id !=\'\''); 
        for (Integer i=0; i<assets.size(); i++) {
            productsIds += '\''+ assets[i].Product2Id+'\'';
            if(i < assets.size()-1){
                productsIds += ',';
            }
        }
        
        if(restricted == true){
            announcements1 = new SLT_Announcements().selectAnnouncements1(partnerType, pillar, expiredCondition);
            announcements.addAll(announcements1);
        }else{
            announcements6 = new SLT_Announcements().selectAnnouncements6(partnerType, pillar, expiredCondition);
            announcements.addAll(announcements6);
        }        
        
        announcements2 = new SLT_Announcements().selectAnnouncements2(partnerType, pillar, expiredCondition, userAccountId);
        announcements.addAll(announcements2);
        
        if(restricted == true){
            announcements3 = new SLT_Announcements().selectAnnouncements3(partnerType, pillar, expiredCondition, productsIds);
            announcements.addAll(announcements3);
        }else{
            announcements5 = new SLT_Announcements().selectAnnouncements5(partnerType, pillar, expiredCondition, productsIds);
            announcements.addAll(announcements5);
        }
        
        announcements4 = new SLT_Announcements().selectAnnouncements4(partnerType, pillar, expiredCondition, productsIds, userAccountId);
        announcements.addAll(announcements4);
        
        return announcements;
    }
    
    @AuraEnabled 
    public static PRM_BaseUrl__c getPRMOrgBaseUrlSetting(){
        return PRM_BaseUrl__c.getOrgDefaults();
    } 
}
