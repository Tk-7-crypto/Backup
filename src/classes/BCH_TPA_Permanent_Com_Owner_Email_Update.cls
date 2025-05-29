global class BCH_TPA_Permanent_Com_Owner_Email_Update implements Database.Batchable<sObject>, Database.Stateful {
    Date todayDate = System.now().date();
    List<IMS_Data_Asset__c> dataAssetListToUpdate = new List<IMS_Data_Asset__c>();
    List<IMS_Secondary_Data_Asset__c> secDataAssetListToUpdate = new List<IMS_Secondary_Data_Asset__c>();
    List<TPA_Assigned_TP_Processor__c> processedRecords = new List<TPA_Assigned_TP_Processor__c>();
    Set<Id> uniqueIds = new Set<Id>();
    Set<Id> uniqueSecIds = new Set<Id>();
    Public String comEmailId = '';
    global BCH_TPA_Permanent_Com_Owner_Email_Update(){
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Is_Permanent_Commercial_Owner__c,Is_Record_Processed__c,Effective_Date__c,Commercial_Owner_Email__c, New_Permanent_Commercial_Owner_Full_Name__c, New_Permanent_Commercial_Owner_Email__c, Offering_Names__c,Action__c from TPA_Assigned_TP_Processor__c where Is_Permanent_Commercial_Owner__c = true and Effective_Date__c = :todayDate and Is_Record_Processed__c = false';
        if(comEmailId != ''){
            query += ' and Commercial_Owner_Email__c like : comEmailId';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> objList){
        
        for(sObject sobj: objList){
            system.debug('permOwnerChange');
            TPA_Assigned_TP_Processor__c permOwnerChange = (TPA_Assigned_TP_Processor__c)sobj;
            String commericalEmail = '%' + permOwnerChange.Commercial_Owner_Email__c + '%';
            system.debug('commericalEmail'+commericalEmail);
            List<String> offList = new List<String>();
            system.debug('permOwnerChange.Offering_Names__c'+permOwnerChange.Offering_Names__c);
            if(permOwnerChange.Offering_Names__c != null && permOwnerChange.Offering_Names__c != ''){
                system.debug('permOwnerChange.Offering_Names__c'+permOwnerChange.Offering_Names__c);
                offList = permOwnerChange.Offering_Names__c.split(';');
            }
            system.debug('offList'+offList);
            for(IMS_Data_Asset__c dataAsset : [Select Id,Asset_Name__c,BU__c,Geo_Level__c,Commercial_Owner_Email__c,Commercial_Manager_Name__c From IMS_Data_Asset__c where Is_Active__c = true and Commercial_Owner_Email__c like : commericalEmail]){
                String key = dataAsset.BU__c+'->'+dataAsset.Geo_Level__c+'->'+dataAsset.Asset_Name__c;
                system.debug('key'+key);
                if(offList.size() > 0 && offList.indexOf(key) != -1 && permOwnerChange.Action__c != null){
                    if(permOwnerChange.Action__c.contains('add') && !uniqueIds.contains(dataAsset.Id)){
                        system.debug('Add');
                        List<String> emailList = new List<String>();
                        List<String> nameList = new List<String>();
                        if(permOwnerChange.New_Permanent_Commercial_Owner_Email__c != null && permOwnerChange.New_Permanent_Commercial_Owner_Email__c != '' && permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c != null && permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c != ''){
                            emailList = permOwnerChange.New_Permanent_Commercial_Owner_Email__c.toLowercase().split(';');
                        	nameList = permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c.toLowercase().split(';');
                        }
                        Integer index = -1;
                        String comName = '';
                        Boolean emailUpdated = false;
                        if(emailList.size() > 0){
                            for(String email: emailList) {
                                if(dataAsset.Commercial_Owner_Email__c != '' && dataAsset.Commercial_Owner_Email__c.containsIgnoreCase(email)){
                                    continue;
                                }
                                else{
                                    index = emailList.indexOf(email);
                                    dataAsset.Commercial_Owner_Email__c += ';'+email;
                                    if(index != -1 && nameList.size() > 0 && index < nameList.size()){
                                        comName = nameList[index];
                                    }
                                    if(comName != null && comName != ''){
                                        dataAsset.Commercial_Manager_Name__c += ';'+comName;
                                    }
                                    emailUpdated = true;
                                    
                                }
                            }
                        }
                        if(emailUpdated){
                           uniqueIds.add(dataAsset.Id);
                           dataAssetListToUpdate.add(dataAsset); 
                        }
                    }
                    if(permOwnerChange.Action__c.contains('transfer') && !uniqueIds.contains(dataAsset.Id) && dataAsset.Commercial_Owner_Email__c != '' && dataAsset.Commercial_Owner_Email__c.toLowercase().indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase()) != -1){
                        system.debug('transfer');
                        List<String> emailList = new List<String>();
                        List<String> nameList = new List<String>();
                        List<String> emailListPermanent = new List<String>();
                        List<String> nameListPermanent = new List<String>();
                        if(dataAsset.Commercial_Owner_Email__c != null && dataAsset.Commercial_Owner_Email__c != '' && dataAsset.Commercial_Manager_Name__c != null && dataAsset.Commercial_Manager_Name__c != ''){
                            emailList = dataAsset.Commercial_Owner_Email__c.toLowercase().split(';');
                        	nameList = dataAsset.Commercial_Manager_Name__c.toLowercase().split(';');
                        }
                        Integer index = -1;
                        String comName = '';
                        if(emailList.size() > 0){
                            index = emailList.indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                        }
                        if(index != -1 && nameList.size() > 0 && index < nameList.size()){
                            comName = nameList[index];
                        }
                        if(permOwnerChange.New_Permanent_Commercial_Owner_Email__c != null && permOwnerChange.New_Permanent_Commercial_Owner_Email__c != '' && permOwnerChange.New_Permanent_Commercial_Owner_Email__c != ''){
                            emailListPermanent = permOwnerChange.New_Permanent_Commercial_Owner_Email__c.toLowercase().split(';');
                            nameListPermanent = permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c.toLowercase().split(';');
                        }
                        Integer indexPermanent = -1;
                        String emailPermanent = '';
                        String comNamePermanent = '';
                        if(emailListPermanent.size() > 0){
                            for(String email: emailListPermanent){
                                if(dataAsset.Commercial_Owner_Email__c.containsIgnoreCase(email)){
                                    continue;
                                }
                                else{
                                    indexPermanent = emailListPermanent.indexOf(email);
                                    emailPermanent += email + ';';
                                    comNamePermanent += nameListPermanent[indexPermanent] + ';';
                                }
                            }
                        }
                        if(emailPermanent != null && emailPermanent != ''){
                            dataAsset.Commercial_Owner_Email__c = dataAsset.Commercial_Owner_Email__c.toLowercase().replace(permOwnerChange.Commercial_Owner_Email__c.toLowercase(),emailPermanent.subString(0, emailPermanent.length()-1));
                            if(comName != null && comName != ''){
                                dataAsset.Commercial_Manager_Name__c = dataAsset.Commercial_Manager_Name__c.toLowercase().replace(comName,comNamePermanent.subString(0, comNamePermanent.length()-1)); 
                            }
                            uniqueIds.add(dataAsset.Id);
                            dataAssetListToUpdate.add(dataAsset);
                        }else {
                            if(dataAsset.Commercial_Owner_Email__c.toLowercase().endswith(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase())){
                                dataAsset.Commercial_Owner_Email__c = dataAsset.Commercial_Owner_Email__c.toLowercase().remove(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                                if(comName != null && comName != '' && dataAsset.Commercial_Manager_Name__c != null && dataAsset.Commercial_Manager_Name__c.toLowercase().indexOf(comName) != -1){
                                    dataAsset.Commercial_Manager_Name__c = dataAsset.Commercial_Manager_Name__c.toLowercase().remove(';'+comName);
                                }
                                uniqueIds.add(dataAsset.Id);
                                dataAssetListToUpdate.add(dataAsset);
                            }
                            else {
                                dataAsset.Commercial_Owner_Email__c = dataAsset.Commercial_Owner_Email__c.toLowercase().remove(permOwnerChange.Commercial_Owner_Email__c.toLowercase()+';');
                                if(comName != null && comName != '' && dataAsset.Commercial_Manager_Name__c != null && dataAsset.Commercial_Manager_Name__c.toLowercase().indexOf(comName) != -1){
                                        dataAsset.Commercial_Manager_Name__c = dataAsset.Commercial_Manager_Name__c.toLowercase().remove(comName+';');
                                }
                                uniqueIds.add(dataAsset.Id);
                                dataAssetListToUpdate.add(dataAsset);
                            }
                        }
                    }
                    if(permOwnerChange.Action__c.contains('remove') && !uniqueIds.contains(dataAsset.Id) && dataAsset.Commercial_Owner_Email__c != '' && dataAsset.Commercial_Owner_Email__c.toLowercase().indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase()) != -1){
                        system.debug('Remove');
                        List<String> nameList = new List<String>();
                        List<String> emailList = dataAsset.Commercial_Owner_Email__c.toLowercase().split(';');
                        if(dataAsset.Commercial_Manager_Name__c != null && dataAsset.Commercial_Manager_Name__c != ''){
                            nameList = dataAsset.Commercial_Manager_Name__c.toLowercase().split(';');
                        }
                        Integer index = -1;
                        String comName = '';
                        if(emailList.size() > 0){
                            index = emailList.indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                        }
                        if(index != -1 && nameList.size() > 0 && index < nameList.size()){
                            comName = nameList[index];
                        }
                        if(dataAsset.Commercial_Owner_Email__c.toLowercase().endswith(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase())){
                            dataAsset.Commercial_Owner_Email__c = dataAsset.Commercial_Owner_Email__c.toLowercase().remove(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                            if(comName != null && comName != '' && dataAsset.Commercial_Manager_Name__c != null && dataAsset.Commercial_Manager_Name__c.toLowercase().indexOf(comName) != -1){
                                dataAsset.Commercial_Manager_Name__c = dataAsset.Commercial_Manager_Name__c.toLowercase().remove(';'+comName);
                            }
                        }
                        else {
                            dataAsset.Commercial_Owner_Email__c = dataAsset.Commercial_Owner_Email__c.toLowercase().remove(permOwnerChange.Commercial_Owner_Email__c.toLowercase()+';');
                            if(comName != null && comName != '' && dataAsset.Commercial_Manager_Name__c != null && dataAsset.Commercial_Manager_Name__c.toLowercase().indexOf(comName) != -1){
                                dataAsset.Commercial_Manager_Name__c = dataAsset.Commercial_Manager_Name__c.toLowercase().remove(comName+';');
                            }
                        }
                        uniqueIds.add(dataAsset.Id);
                        dataAssetListToUpdate.add(dataAsset);
                    
                        // dataAsset.Commercial_Manager_Name__c = dataAsset.Commercial_Manager_Name__c.remove(permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c);
                        // dataAsset.Commercial_Owner_Email__c = dataAsset.Commercial_Owner_Email__c.remove(permOwnerChange.New_Permanent_Commercial_Owner_Email__c);
                        // dataAssetListToUpdate.add(dataAsset);
                        //TGRH_TPA_IMSDataAsset.batchToExecute = false;
                    }
                    
                }
                
            }
            
            for(IMS_Secondary_Data_Asset__c secDataAsset : [Select Id,Secondary_Asset_Name__c,Primary_Data_Asset__r.Asset_Name__c,Primary_Data_Asset__r.Geo_Level__c,Primary_Data_Asset__r.BU__c,Geo_Level__c,Commercial_Manager_Name__c,Commercial_Manager_Email__c From IMS_Secondary_Data_Asset__c where Is_Active__c = true and Commercial_Manager_Email__c like : commericalEmail ]){
                String key = secDataAsset.Primary_Data_Asset__r.BU__c+'->'+secDataAsset.Primary_Data_Asset__r.Geo_Level__c+'->'+secDataAsset.Primary_Data_Asset__r.Asset_Name__c+'->'+secDataAsset.Secondary_Asset_Name__c;
                system.debug('key'+key);
                if(offList.size() > 0 && offList.indexOf(key) != -1 && permOwnerChange.Action__c != null){
                    if(permOwnerChange.Action__c.contains('add') && !uniqueSecIds.contains(secDataAsset.Id)){
                        system.debug('add');
                        List<String> emailList = new List<String>();
                        List<String> nameList = new List<String>();
                        if(permOwnerChange.New_Permanent_Commercial_Owner_Email__c != null && permOwnerChange.New_Permanent_Commercial_Owner_Email__c != '' && permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c != null && permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c != ''){
                            emailList = permOwnerChange.New_Permanent_Commercial_Owner_Email__c.toLowercase().split(';');
                            nameList = permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c.toLowercase().split(';');
                        }
                        Integer index = -1;
                        String comName = '';
                        Boolean emailUpdated = false;
                        if(emailList.size() > 0){
                            for(String email: emailList) {
                                if(secDataAsset.Commercial_Manager_Email__c.containsIgnoreCase(email)){
                                    continue;
                                }
                                else{
                                    index = emailList.indexOf(email);
                                    secDataAsset.Commercial_Manager_Email__c += ';'+email;
                                    if(index != -1 && nameList.size() > 0 && index < nameList.size()){
                                        comName = nameList[index];
                                    }
                                    if(comName != null && comName != ''){
                                        secDataAsset.Commercial_Manager_Name__c += ';'+comName;
                                    }
                                    emailUpdated = true;
                                }
                            }
                            if(emailUpdated){
                                uniqueSecIds.add(secDataAsset.Id);
                                secDataAssetListToUpdate.add(secDataAsset);
                            }
                        }
                    }
                    if(permOwnerChange.Action__c.contains('transfer') && !uniqueSecIds.contains(secDataAsset.Id) && secDataAsset.Commercial_Manager_Email__c != '' && secDataAsset.Commercial_Manager_Email__c.toLowercase().indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase()) != -1){
                        system.debug('transfer');
                        List<String> emailList = new List<String>();
                        List<String> nameList = new List<String>();
                        List<String> emailListPermanent = new List<String>();
                        List<String> nameListPermanent = new List<String>();
                        if(secDataAsset.Commercial_Manager_Email__c != null && secDataAsset.Commercial_Manager_Email__c != '' && secDataAsset.Commercial_Manager_Name__c != null && secDataAsset.Commercial_Manager_Name__c != ''){
                            emailList = secDataAsset.Commercial_Manager_Email__c.toLowercase().split(';');
                            nameList = secDataAsset.Commercial_Manager_Name__c.toLowercase().split(';');
                        }
                        
                        Integer index = -1;
                        String comName = '';
                        if(emailList.size() > 0){
                            index = emailList.indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                        }
                        if(index != -1 && nameList.size() > 0 && index < nameList.size()){
                            comName = nameList[index];
                        }
                        if(permOwnerChange.New_Permanent_Commercial_Owner_Email__c != null && permOwnerChange.New_Permanent_Commercial_Owner_Email__c != '' && permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c != null && permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c != ''){
                           emailListPermanent = permOwnerChange.New_Permanent_Commercial_Owner_Email__c.toLowercase().split(';');
                           nameListPermanent = permOwnerChange.New_Permanent_Commercial_Owner_Full_Name__c.toLowercase().split(';'); 
                        }
                        Integer indexPermanent = -1;
                        String emailPermanent = '';
                        String comNamePermanent = '';
                        if(emailListPermanent.size() > 0){
                            for(String email: emailListPermanent){
                                if(secDataAsset.Commercial_Manager_Email__c.containsIgnoreCase(email)){
                                    continue;
                                }
                                else{
                                    indexPermanent = emailListPermanent.indexOf(email);
                                    emailPermanent += email + ';';
                                    comNamePermanent += nameListPermanent[indexPermanent] + ';';
                                }
                            }
                            
                        }
                        if(emailPermanent != null && emailPermanent != ''){
                            secDataAsset.Commercial_Manager_Email__c = secDataAsset.Commercial_Manager_Email__c.toLowercase().replace(permOwnerChange.Commercial_Owner_Email__c.toLowercase(),emailPermanent.subString(0, emailPermanent.length()-1));
                            if(comName != null && comName != ''){
                                secDataAsset.Commercial_Manager_Name__c = secDataAsset.Commercial_Manager_Name__c.toLowercase().replace(comName,comNamePermanent.subString(0, comNamePermanent.length()-1)); 
                            }
                            uniqueSecIds.add(secDataAsset.Id);
                            secDataAssetListToUpdate.add(secDataAsset);
                        }else {
                            if(secDataAsset.Commercial_Manager_Email__c.toLowercase().endswith(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase())){
                                secDataAsset.Commercial_Manager_Email__c = secDataAsset.Commercial_Manager_Email__c.toLowercase().remove(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                                if(comName != null && comName != '' && secDataAsset.Commercial_Manager_Name__c != null && secDataAsset.Commercial_Manager_Name__c.toLowercase().indexOf(comName) != -1){
                                    secDataAsset.Commercial_Manager_Name__c = secDataAsset.Commercial_Manager_Name__c.toLowercase().remove(';'+comName);
                                }
                                uniqueSecIds.add(secDataAsset.Id);
                                secDataAssetListToUpdate.add(secDataAsset);
                            }
                            else {
                                secDataAsset.Commercial_Manager_Email__c = secDataAsset.Commercial_Manager_Email__c.toLowercase().remove(permOwnerChange.Commercial_Owner_Email__c.toLowercase()+';');
                                if(comName != null && comName != '' && secDataAsset.Commercial_Manager_Name__c != null && secDataAsset.Commercial_Manager_Name__c.toLowercase().indexOf(comName) != -1){
                                    secDataAsset.Commercial_Manager_Name__c = secDataAsset.Commercial_Manager_Name__c.toLowercase().remove(comName+';');
                                }
                                uniqueSecIds.add(secDataAsset.Id);
                                secDataAssetListToUpdate.add(secDataAsset);
                            }
                        } 
                    }
                    if(permOwnerChange.Action__c.contains('remove') && !uniqueSecIds.contains(secDataAsset.Id) && secDataAsset.Commercial_Manager_Email__c != '' && secDataAsset.Commercial_Manager_Email__c.toLowercase().indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase()) != -1){
                        system.debug('remove');
                        List<String> nameList = new List<String>();
                        List<String> emailList = secDataAsset.Commercial_Manager_Email__c.toLowercase().split(';');
                        if(secDataAsset.Commercial_Manager_Name__c != null && secDataAsset.Commercial_Manager_Name__c != ''){
                            nameList = secDataAsset.Commercial_Manager_Name__c.toLowercase().split(';');
                        }
                        Integer index = -1;
                        String comName = '';
                        if(emailList.size() > 0){
                            index = emailList.indexOf(permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                        }
                        if(index != -1 && nameList.size() > 0 && index < nameList.size()){
                            comName = nameList[index];
                        }
                        if(secDataAsset.Commercial_Manager_Email__c.toLowercase().endswith(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase())){
                            secDataAsset.Commercial_Manager_Email__c = secDataAsset.Commercial_Manager_Email__c.toLowercase().remove(';'+permOwnerChange.Commercial_Owner_Email__c.toLowercase());
                            if(comName != null && comName != '' && secDataAsset.Commercial_Manager_Name__c != null && secDataAsset.Commercial_Manager_Name__c.indexOf(comName) != -1){
                                secDataAsset.Commercial_Manager_Name__c = secDataAsset.Commercial_Manager_Name__c.toLowercase().remove(';'+comName); 
                            }
                        }
                        else {
                            secDataAsset.Commercial_Manager_Email__c = secDataAsset.Commercial_Manager_Email__c.toLowercase().remove(permOwnerChange.Commercial_Owner_Email__c.toLowercase()+';');
                            if(comName != null && comName != '' && secDataAsset.Commercial_Manager_Name__c != null && secDataAsset.Commercial_Manager_Name__c.toLowercase().indexOf(comName) != -1){
                                secDataAsset.Commercial_Manager_Name__c = secDataAsset.Commercial_Manager_Name__c.toLowercase().remove(comName+';'); 
                            }
                        }
                        uniqueSecIds.add(secDataAsset.Id);
                        secDataAssetListToUpdate.add(secDataAsset);
                        //TGRH_TPA_IMSDataAsset.batchToExecute = false;
                    }
                    
                }
            }
            permOwnerChange.Is_Record_Processed__c = true;
            processedRecords.add(permOwnerChange);
        }
        
    }
    global void finish(Database.BatchableContext BC){
        if(dataAssetListToUpdate != null && dataAssetListToUpdate.size() > 0){
            update dataAssetListToUpdate;
        }
        if(secDataAssetListToUpdate != null && secDataAssetListToUpdate.size() > 0){
            update secDataAssetListToUpdate;
        }
        if(processedRecords != null && processedRecords.size() > 0){
            update processedRecords;
        }
    }
    
}
