public class TGRH_TPA_AgreementAdditionalField {
    List<TPA_Agreement_Additional_Field__c> newList;
    List<TPA_Request__c> tpaRequestList;
    TPA_Request__c tpaRequest;
    List<Task> taskToInsertList = new List<Task>();
    String Subject;
    public static Boolean isPartiallyRenewed = false;

    public void onBeforeInsert(List<TPA_Agreement_Additional_Field__c> newList) {
        system.debug('CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail: ' + CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail);
        if(CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail) {
            saveExcludedOfferingsInRenewal(newList);      
        }
    }

    public void onBeforeUpdate(List<TPA_Agreement_Additional_Field__c> newList, List<TPA_Agreement_Additional_Field__c> oldTpaReqList, Map<Id, TPA_Agreement_Additional_Field__c> newMap, Map<Id, TPA_Agreement_Additional_Field__c> oldMap) {
        system.debug('CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail: ' + CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail);
        if(CNT_TPA_RequestSubmissionForm.IsUpdateRenewalOfferinfDetail) {
            saveExcludedOfferingsInRenewal(newList);      
        }else{
            List<TPA_Request__c> reqToUpdate = new List<TPA_Request__c>();
            List<Id> requestIDs = new List<Id>();
            Map<id, TPA_Request__c> allRequestsMap = new Map<id,TPA_Request__c>();
            for(TPA_Agreement_Additional_Field__c newAgg : newList){
                requestIDs.add(newAgg.Related_TPA_Request__c);
            }
            List<TPA_Request__c> allRequestList = [select id,Is_Partially_Renewed__c,Partially_Renewed_Date__c  from TPA_Request__c where id =: requestIDs];
            for(TPA_Request__c request : allRequestList){
                if(!allRequestsMap.containsKey(request.id)){
                    allRequestsMap.put(request.id, request);
                }
            }
            for(TPA_Agreement_Additional_Field__c newAgg : newList){
                if(newAgg.Excluded_Offerings_In_Renewal__c != oldMap.get(newAgg.id).Excluded_Offerings_In_Renewal__c){
                    if((newAgg.Description_of_Removal__c == null || newAgg.Description_of_Removal__c == '') ){         
                        newAgg.Description_of_Removal__c.addError('Please List the Reason of Removal of Offering');
                    }else{
                        newAgg.Excluded_Offering_s_updated_on__c = Date.today();
                        newAgg.Excluded_Offering_s_updated_by__c = UTL_TPA.getCurrentUserDetails().Name;
                        if(newAgg.Excluded_Offerings_In_Renewal__c != null){
                            newAgg.Excluded_Offerings_In_Renewal__c = newAgg.Excluded_Offerings_In_Renewal__c.replaceAll(';;+',';').removeEnd(';').removeStart(';');
                            if(allrequestsMap.containsKey(newAgg.Related_TPA_Request__c) && allrequestsMap.get(newAgg.Related_TPA_Request__c).Is_Partially_Renewed__c == false){
                                TPA_Request__c currentRequest= allRequestsMap.get(newAgg.Related_TPA_Request__c);
                                currentRequest.Is_Partially_Renewed__c = true;
                                currentRequest.Partially_Renewed_Date__c = Datetime.now();
                                reqToUpdate.add(currentRequest);
                            }
                            if(oldMap.get(newAgg.id).Excluded_Offerings_In_Renewal__c == null || oldMap.get(newAgg.id).Excluded_Offerings_In_Renewal__c == ''){//If It was previously Blank
                                for(String newOfferings : newAgg.Excluded_Offerings_In_Renewal__c.split(';')){
                                    newAgg.Offering_s_Removed_from_DDN__c = newAgg.Offering_s_Removed_from_DDN__c.replace(newOfferings, '');
                                }
                            }else if(oldMap.get(newAgg.id).Excluded_Offerings_In_Renewal__c.length() < newAgg.Excluded_Offerings_In_Renewal__c.length()){// If it has some values previously
                                for(String newOfferings : newAgg.Excluded_Offerings_In_Renewal__c.split(';')){
                                    newAgg.Offering_s_Removed_from_DDN__c = newAgg.Offering_s_Removed_from_DDN__c.replace(newOfferings, '');
                                }
                            }else{// If Offering are removed
                                for(String oldOfferings : oldMap.get(newAgg.id).Excluded_Offerings_In_Renewal__c.split(';')){
                                    if( !(newAgg.Excluded_Offerings_In_Renewal__c.contains(oldOfferings))){
                                        if(newAgg.Offering_s_Removed_from_DDN__c == null){
                                            newAgg.Offering_s_Removed_from_DDN__c = oldOfferings;
                                        }else{
                                            newAgg.Offering_s_Removed_from_DDN__c += ';' + oldOfferings;
                                        }
                                    }
                                }
                            }
                            newAgg.Offering_s_Removed_from_DDN__c = newAgg.Offering_s_Removed_from_DDN__c.replaceAll(';;+',';').removeEnd(';').removeStart(';');
                        }
                        else{
                            if(allrequestsMap.containsKey(newAgg.Related_TPA_Request__c)){
                                TPA_Request__c currentRequest= allRequestsMap.get(newAgg.Related_TPA_Request__c);
                                currentRequest.Is_Partially_Renewed__c = false;
                                currentRequest.Partially_Renewed_Date__c = null;
                                reqToUpdate.add(currentRequest);
                            }
                            if(newAgg.Offering_s_Removed_from_DDN__c == null){
                                newAgg.Offering_s_Removed_from_DDN__c = oldMap.get(newAgg.id).Excluded_Offerings_In_Renewal__c;
                            }else{
                                newAgg.Offering_s_Removed_from_DDN__c += ';' + oldMap.get(newAgg.id).Excluded_Offerings_In_Renewal__c;
                            }
                        }       
                    }
                }
            }
            system.debug(reqToUpdate);
            if(reqToUpdate.size() > 0){
                update reqToUpdate;
            }
        }
    }

    public void saveExcludedOfferingsInRenewal(List<TPA_Agreement_Additional_Field__c> newList) {
        set<Id> ParentRequestsId = new set<Id>();
        List<TPA_Request__c> reqToUpdate = new List<TPA_Request__c>();
		TPA_Request__c req;
        for(TPA_Agreement_Additional_Field__c AggAdditionalFieldObj : newList) {
            if(AggAdditionalFieldObj.Parent_TPA_Request_Offering_Data__c != null) {
                ParentRequestsId.add(AggAdditionalFieldObj.Related_TPA_Request__c);
            }
        }
        system.debug('ParentRequestsId: ' + ParentRequestsId);
        if(ParentRequestsId .size() > 0) {
            Map<Id, List<TPA_Data_Asset__c>> requestOfferingMap = new Map<Id, List<TPA_Data_Asset__c>>();
            List<TPA_Data_Asset__c> offeringList = [select Id,
                                                           Asset_Name__c, 
                                                           BU__c, 
                                                           Geo_Level__c,
                                                           Purpose__r.Name,
                                                           Request__c, 
                                                    	   Other_Data_Asset_Details__c,
                                                           (select Id, 
                                                                   Name, 
                                                                   Secondary_Asset_Name__c
                                                            from TPA_Secondary_Data_Assets__r) 
                                                    from TPA_Data_Asset__c 
                                                    where Request__c IN : ParentRequestsId];
            system.debug('offeringList: ' + offeringList);
            for(TPA_Data_Asset__c priOffering: offeringList) {
                List<TPA_Data_Asset__c> tempOfferingList = new List<TPA_Data_Asset__c>();
                if(requestOfferingMap.containsKey(priOffering.Request__c)) {
                    tempOfferingList = requestOfferingMap.get(priOffering.Request__c);
                } 
                tempOfferingList.add(priOffering);
                requestOfferingMap.put(priOffering.Request__c, tempOfferingList);
            }
            
            for(TPA_Agreement_Additional_Field__c AggAdditionalFieldObj : newList) {
                String chieldRequestOfferingDetail = '';
                String chieldRequestOffCategoryDetail = '';
                Set<String> chieldCategorySet = new Set<String>();
                String chieldRequestOffCountryDetail = '';
                String chieldRequestOffUseDetail = '';
                system.debug('requestOfferingMap: ' + requestOfferingMap);
                system.debug('AggAdditionalFieldObj: ' + AggAdditionalFieldObj);
                system.debug('AggAdditionalFieldObj.Related_TPA_Request__c: ' + AggAdditionalFieldObj.Related_TPA_Request__c);
                system.debug('requestOfferingMap.get(AggAdditionalFieldObj.Related_TPA_Request__c): ' + requestOfferingMap.get(AggAdditionalFieldObj.Related_TPA_Request__c));
                if(requestOfferingMap.get(AggAdditionalFieldObj.Related_TPA_Request__c) != null) {
                    for(TPA_Data_Asset__c priOffering: requestOfferingMap.get(AggAdditionalFieldObj.Related_TPA_Request__c)) {
                        String offeringKey = '';
                        if(priOffering.TPA_Secondary_Data_Assets__r.size() > 0) {
                            for(TPA_Secondary_Data_Asset__c secOffering : priOffering.TPA_Secondary_Data_Assets__r) {
                                offeringKey = priOffering.BU__c + ':' + priOffering.Asset_Name__c + ':' + secOffering.Secondary_Asset_Name__c;
                                if(chieldRequestOfferingDetail == '' || chieldRequestOfferingDetail == null) {
                                    chieldRequestOfferingDetail = offeringKey;
                                } else {
                                    chieldRequestOfferingDetail += ';' + offeringKey;
                                }
                            }
                        } else {
                            if(priOffering.Asset_Name__c == 'Other'){
                                String updatedOtherName = priOffering.Other_Data_Asset_Details__c.replace(';', ' ').replace(':', ' '); 
                                offeringKey = priOffering.BU__c + ':' + 'Other(' + updatedOtherName + ')';
                            }else{
                                offeringKey = priOffering.BU__c + ':' + priOffering.Asset_Name__c;
                            }
                            if(chieldRequestOfferingDetail == '' || chieldRequestOfferingDetail == Null) {
                                chieldRequestOfferingDetail = offeringKey;
                            } else {
                                chieldRequestOfferingDetail += ';' + offeringKey;
                            }
                        }

                       
                        chieldCategorySet.add(priOffering.Geo_Level__c);
                        if(chieldRequestOffCountryDetail == '' || chieldRequestOffCountryDetail == null) {
                            chieldRequestOffCountryDetail = priOffering.BU__c;
                        } else if(!chieldRequestOffCountryDetail.contains(priOffering.BU__c)){
                            chieldRequestOffCountryDetail += ',' + priOffering.BU__c;
                        }
                        if(chieldRequestOffUseDetail == '' || chieldRequestOffUseDetail == null) {
                            chieldRequestOffUseDetail = priOffering.Purpose__r.Name;
                        } else if(!chieldRequestOffUseDetail.contains(priOffering.Purpose__r.Name)){
                            chieldRequestOffUseDetail += ',' + priOffering.Purpose__r.Name;
                        }
                    }
                }

                chieldRequestOffCategoryDetail = String.join(new List<String>(chieldCategorySet),',');
                system.debug('parentOfferingDetail:' + AggAdditionalFieldObj.Parent_TPA_Request_Offering_Data__c);
                system.debug('chieldRequestOfferingDetail' + chieldRequestOfferingDetail);
                
                string[] parentOfferingDetail = AggAdditionalFieldObj.Parent_TPA_Request_Offering_Data__c.split(';');
                string[] childOfferingDetail = chieldRequestOfferingDetail.split(';');
                AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = '';
                AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = '';
                //Boolean isExistsInChild = false;
                //system.debug('isExistsInChild' + isExistsInChild);
                Map<String, String> excludededOfferingCountryMap = new Map<String, String>();
                for(string offeringKey: parentOfferingDetail) {
                    //isExistsInChild = false;
                    if(!childOfferingDetail.contains(offeringKey)){
                        if(offeringKey.split(':').size() == 3 && !excludededOfferingCountryMap.containsKey(offeringKey.split(':')[1]+':'+offeringKey.split(':')[2])){
                            excludededOfferingCountryMap.put(offeringKey.split(':')[1]+':'+offeringKey.split(':')[2], offeringKey.split(':')[0]);
                        }
                        if(offeringKey.split(':').size() == 2 && !excludededOfferingCountryMap.containsKey(offeringKey.split(':')[1])){
                            excludededOfferingCountryMap.put(offeringKey.split(':')[1], offeringKey.split(':')[0]);
                        }
                        if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c += offeringKey;
                        } else {
                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c += ';' + offeringKey;
                        }
                    }
                    /*for(string childOff: childOfferingDetail) {
                        if(offeringKey == childOff) {
                            isExistsInChild = true;
                            break;
                        }
                    }
                    if(!isExistsInChild) {
                        if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c += offeringKey;
                        } else {
                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c += ';' + offeringKey;
                        }
                    }*/
                }

                for(String ChildOfferings : childOfferingDetail){
                    if(!AggAdditionalFieldObj.Parent_TPA_Request_Offering_Data__c.contains(ChildOfferings)){
                        if(AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c == ''){
                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c += ChildOfferings;
                        }else{
                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c += ';' + ChildOfferings;
                        }
                    }
                }

                List<String> offeringNames = new List<String>();
                if(!excludededOfferingCountryMap.isEmpty()){
                    for(String str: excludededOfferingCountryMap.keySet()){
                        if(str.split(':').size() == 2){
                            offeringNames.add(str.split(':')[0]);
                            offeringNames.add(str.split(':')[1]);
                        }
                        else {
                            offeringNames.add(str);
                        }
                    }

                    List<IMS_Data_Asset__c> masterDataAssetList = [select id,
                                                                   BU__c,
                                                                   Geo_Level__c,
                                                                   Asset_Name__c,
                                                                   Map_To__c,
                                                                   Map_To__r.Asset_Name__c,
                                                                   Map_To__r.BU__c,
                                                                   Map_To_Secondary_Data_Asset__c,
                                                                   Map_To_Secondary_Data_Asset__r.Secondary_Asset_Name__c,
                                                                   Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Asset_Name__c,
                                                                   Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.BU__c,
                                                                   Is_Active__c
                                                                   from IMS_Data_Asset__c
                                                                   where Asset_Name__c in : offeringNames and Is_Active__c = false and (Map_To__c != null or Map_To_Secondary_Data_Asset__c != null)];
                    
                    if(masterDataAssetList != null && masterDataAssetList.size() > 0){
                        for(IMS_Data_Asset__c imsDataOffering: masterDataAssetList){
                            if(excludededOfferingCountryMap.containsKey(imsDataOffering.Asset_Name__c) && excludededOfferingCountryMap.get(imsDataOffering.Asset_Name__c) == imsDataOffering.BU__c){
                                if(imsDataOffering.Map_To__c != null && imsDataOffering.Map_To__r.Asset_Name__c != null && imsDataOffering.Map_To__r.BU__c != null){
                                    String key = imsDataOffering.BU__c + ':' + imsDataOffering.Asset_Name__c;
                                    String childKey = imsDataOffering.Map_To__r.BU__c + ':' + imsDataOffering.Map_To__r.Asset_Name__c;
                                    if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.contains(key) && childOfferingDetail.contains(childKey)){
                                        
                                        if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.endsWith(key)){
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key+';');
                                        }

                                        if(AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.endsWith(childKey)){
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey+';');
                                        }
                                        excludededOfferingCountryMap.remove(imsDataOffering.Asset_Name__c);
                                    }
                                }
                                if(imsDataOffering.Map_To_Secondary_Data_Asset__c != null && imsDataOffering.Map_To_Secondary_Data_Asset__r.Secondary_Asset_Name__c != null && imsDataOffering.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.BU__c != null){
                                    String key = imsDataOffering.BU__c + ':' + imsDataOffering.Asset_Name__c;
                                    String childKey = imsDataOffering.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.BU__c + ':' +imsDataOffering.Map_To_Secondary_Data_Asset__r.Primary_Data_Asset__r.Asset_Name__c + ':' + imsDataOffering.Map_To_Secondary_Data_Asset__r.Secondary_Asset_Name__c;
                                    if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.contains(key) && childOfferingDetail.contains(childKey)){
                                        if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.endsWith(key)){
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key+';');
                                        }

                                        if(AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.endsWith(childKey)){
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey+';');
                                        }
                                        excludededOfferingCountryMap.remove(imsDataOffering.Asset_Name__c);
                                    }
                                }
                            }
                        }
                    } 
                }
                
                if(excludededOfferingCountryMap.keySet().size() > 0){
                    List<IMS_Secondary_Data_Asset__c> masterSecondaryDataAssetList = [select id,
                                                                                      Is_Active__c,
                                                                                      Secondary_Asset_Name__c,
                                                                                      Primary_Data_Asset__c,
                                                                                      Primary_Data_Asset__r.Asset_Name__c,
                                                                                      Primary_Data_Asset__r.BU__c,
                                                                                      Map_To__c,
                                                                                      Map_To__r.Secondary_Asset_Name__c,
                                                                                      Map_To__r.Primary_Data_Asset__r.Asset_Name__c,
                                                                                      Map_To__r.Primary_Data_Asset__r.BU__c,
                                                                                      Map_To_Primary_Data_Asset__c,
                                                                                      Map_To_Primary_Data_Asset__r.Asset_Name__c,
                                                                                      Map_To_Primary_Data_Asset__r.BU__c
                                                                                      from IMS_Secondary_Data_Asset__c
                                                                                      where Is_Active__c = False and Secondary_Asset_Name__c in : offeringNames and (Map_To__c != null or Map_To_Primary_Data_Asset__c != null)];
                    
                    if(masterSecondaryDataAssetList != null && masterSecondaryDataAssetList.size() > 0){
                        for(IMS_Secondary_Data_Asset__c imssecondaryDataOffering: masterSecondaryDataAssetList){
                            if(excludededOfferingCountryMap.containsKey(imssecondaryDataOffering.Primary_Data_Asset__r.Asset_Name__c + ':' + imssecondaryDataOffering.Secondary_Asset_Name__c) && excludededOfferingCountryMap.get(imssecondaryDataOffering.Primary_Data_Asset__r.Asset_Name__c + ':' + imssecondaryDataOffering.Secondary_Asset_Name__c) == imssecondaryDataOffering.Primary_Data_Asset__r.BU__c){
                                if(imssecondaryDataOffering.Map_To__c != null && imssecondaryDataOffering.Map_To__r.Primary_Data_Asset__r.BU__c != null && imssecondaryDataOffering.Map_To__r.Secondary_Asset_Name__c != null){
                                    String key = imssecondaryDataOffering.Primary_Data_Asset__r.BU__c + ':' + imssecondaryDataOffering.Primary_Data_Asset__r.Asset_Name__c + ':' + imssecondaryDataOffering.Secondary_Asset_Name__c;
                                    String childKey = imssecondaryDataOffering.Map_To__r.Primary_Data_Asset__r.BU__c + ':' + imssecondaryDataOffering.Map_To__r.Primary_Data_Asset__r.Asset_Name__c + ':' + imssecondaryDataOffering.Map_To__r.Secondary_Asset_Name__c;
                                    if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.contains(key) && childOfferingDetail.contains(childKey)){
                                        if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.endsWith(key)){
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key+';');
                                        }

                                        if(AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.endsWith(childKey)){
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey+';');
                                        }
                                        excludededOfferingCountryMap.remove(imssecondaryDataOffering.Secondary_Asset_Name__c);
                                    }
                                }
                                if(imssecondaryDataOffering.Map_To_Primary_Data_Asset__c != null && imssecondaryDataOffering.Map_To_Primary_Data_Asset__r.BU__c != null && imssecondaryDataOffering.Map_To_Primary_Data_Asset__r.Asset_Name__c != null){
                                    String key = imssecondaryDataOffering.Primary_Data_Asset__r.BU__c + ':' + imssecondaryDataOffering.Primary_Data_Asset__r.Asset_Name__c + ':' +imssecondaryDataOffering.Secondary_Asset_Name__c;
                                    String childKey = imssecondaryDataOffering.Map_To_Primary_Data_Asset__r.BU__c + ':' + imssecondaryDataOffering.Map_To_Primary_Data_Asset__r.Asset_Name__c;
                                    if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.contains(key) && childOfferingDetail.contains(childKey)){
                                        if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.endsWith(key)){
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c = AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c.remove(key+';');
                                        }

                                        if(AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.endsWith(childKey)){
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey);
                                        }
                                        else {
                                            AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c = AggAdditionalFieldObj.Additional_Offerings_in_Renewal__c.remove(childKey+';');
                                        }
                                        excludededOfferingCountryMap.remove(imssecondaryDataOffering.Secondary_Asset_Name__c);
                                    }
                                }
                            }
                        }
                    }
                }
                 
                
                
                
                //system.debug('isExistsInChild' + isExistsInChild);

                string[] parentOffCountryDetail = AggAdditionalFieldObj.Parent_TPA_Request_Offering_Country_s__c.split(',');
                string[] childOffCountryDetail = chieldRequestOffCountryDetail.split(',');
                AggAdditionalFieldObj.Excluded_Offering_Country_s_In_Renewal__c = '';
                AggAdditionalFieldObj.Included_Offering_Country_s_In_Renewal__c = '';
                //isExistsInChild = false;
                //system.debug('isExistsInChild' + isExistsInChild);
                for(string offeringCountry: parentOffCountryDetail) {
                    //isExistsInChild = false;
                    if(!childOffCountryDetail.contains(offeringCountry)){
                        if(AggAdditionalFieldObj.Excluded_Offering_Country_s_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Offering_Country_s_In_Renewal__c += offeringCountry;
                        } else {
                            AggAdditionalFieldObj.Excluded_Offering_Country_s_In_Renewal__c += ',' + offeringCountry;
                        }
                    }
                    /*for(string childOff: childOffCountryDetail) {
                        if(offeringCountry == childOff) {
                            isExistsInChild = true;
                            break;
                        }
                    }
                    if(!isExistsInChild) {
                        if(AggAdditionalFieldObj.Excluded_Offering_Country_s_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Offering_Country_s_In_Renewal__c += offeringCountry;
                        } else {
                            AggAdditionalFieldObj.Excluded_Offering_Country_s_In_Renewal__c += ',' + offeringCountry;
                        }
                    }*/
                }

                for(String ChildCountry : childOffCountryDetail){
                    if(!AggAdditionalFieldObj.Parent_TPA_Request_Offering_Country_s__c.contains(ChildCountry)){
                        if(AggAdditionalFieldObj.Included_Offering_Country_s_In_Renewal__c == ''){
                            AggAdditionalFieldObj.Included_Offering_Country_s_In_Renewal__c += ChildCountry;
                        }else{
                            AggAdditionalFieldObj.Included_Offering_Country_s_In_Renewal__c += ';' + ChildCountry;
                        }
                    }
                }

                string[] parentOffCategoryDetail = AggAdditionalFieldObj.Parent_TPA_Request_Offering_Category_s__c.split(',');
                string[] childOffCategoryDetail = chieldRequestOffCategoryDetail.split(',');
                AggAdditionalFieldObj.Excluded_Category_s_In_Renewal__c = '';
                AggAdditionalFieldObj.Included_Category_s_In_Renewal__c = '';
                //isExistsInChild = false;
                //system.debug('isExistsInChild' + isExistsInChild);
                for(string offeringCategory: parentOffCategoryDetail) {
                    //isExistsInChild = false;
                    if(!childOffCategoryDetail.contains(offeringCategory)){
                        if(AggAdditionalFieldObj.Excluded_Category_s_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Category_s_In_Renewal__c += offeringCategory;
                        } else {
                            AggAdditionalFieldObj.Excluded_Category_s_In_Renewal__c += ',' + offeringCategory;
                        }
                    }
                    /*for(string childOff: childOffCategoryDetail) {
                        if(offeringCategory == childOff) {
                            isExistsInChild = true;
                            break;
                        }
                    }
                    if(!isExistsInChild) {
                        if(AggAdditionalFieldObj.Excluded_Category_s_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Category_s_In_Renewal__c += offeringCategory;
                        } else {
                            AggAdditionalFieldObj.Excluded_Category_s_In_Renewal__c += ',' + offeringCategory;
                        }
                    }*/
                }

                for(String ChildCategory : childOffCategoryDetail){
                    if(!AggAdditionalFieldObj.Parent_TPA_Request_Offering_Category_s__c.contains(ChildCategory)){
                        if(AggAdditionalFieldObj.Included_Category_s_In_Renewal__c == ''){
                            AggAdditionalFieldObj.Included_Category_s_In_Renewal__c += ChildCategory;
                        }else{
                            AggAdditionalFieldObj.Included_Category_s_In_Renewal__c += ';' + ChildCategory;
                        }
                    }
                }

                string[] parentUseDetail = AggAdditionalFieldObj.Parent_TPA_Request_Use_Data__c.split(',');
                string[] childUseDetail = chieldRequestOffUseDetail.split(',');
                AggAdditionalFieldObj.Excluded_Uses_In_Renewal__c = '';
                AggAdditionalFieldObj.Included_Uses_In_Renewal__c = '';
                //isExistsInChild = false;
                //system.debug('isExistsInChild' + isExistsInChild);
                for(string useDetail: parentUseDetail) {
                    //isExistsInChild = false;
                    if(!childUseDetail.contains(useDetail)){
                        if(AggAdditionalFieldObj.Excluded_Uses_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Uses_In_Renewal__c += useDetail;
                        } else {
                            AggAdditionalFieldObj.Excluded_Uses_In_Renewal__c += ',' + useDetail;
                        }
                    }
                    /*for(string childOff: childUseDetail) {
                        if(useDetail == childOff) {
                            isExistsInChild = true;
                            break;
                        }
                    }
                    if(!isExistsInChild) {
                        if(AggAdditionalFieldObj.Excluded_Uses_In_Renewal__c == '') {
                            AggAdditionalFieldObj.Excluded_Uses_In_Renewal__c += useDetail;
                        } else {
                            AggAdditionalFieldObj.Excluded_Uses_In_Renewal__c += ',' + useDetail;
                        }
                    }*/
                }

                for(String ChildUse : childUseDetail){
                    if(!AggAdditionalFieldObj.Parent_TPA_Request_Use_Data__c.contains(ChildUse)){
                        if(AggAdditionalFieldObj.Included_Uses_In_Renewal__c == ''){
                            AggAdditionalFieldObj.Included_Uses_In_Renewal__c += ChildUse;
                        }else{
                            AggAdditionalFieldObj.Included_Uses_In_Renewal__c += ';' + ChildUse;
                        }
                    }
                }


                AggAdditionalFieldObj.Offering_s_Removed_from_DDN__c = '';
                AggAdditionalFieldObj.Excluded_Offering_s_updated_by__c = '';
                AggAdditionalFieldObj.Excluded_Offering_s_updated_on__c = null;
                AggAdditionalFieldObj.Description_of_Removal__c = '';
                
                req = SRV_TPA_TPARequest.getRequestInfo(AggAdditionalFieldObj.Related_TPA_Request__c);
                if(AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c != '') {
                    system.debug('inside partil update');
                    isPartiallyRenewed = true;
                    req.Is_Partially_Renewed__c = true;
                    req.Partially_Renewed_Date__c = Datetime.now();
                    reqToUpdate.add(req);
                    SRV_TPA_TPARequest.tpaRequest = req;
                }
                else if(req.Is_Partially_Renewed__c && AggAdditionalFieldObj.Excluded_Offerings_In_Renewal__c == '') {
                    system.debug('inside normal update');
                    isPartiallyRenewed = false;
                    req.Is_Partially_Renewed__c = false;
                    req.Partially_Renewed_Date__c = null;
                    reqToUpdate.add(req);
                    SRV_TPA_TPARequest.tpaRequest = req;
                }
            }
            if(reqToUpdate != null && reqToUpdate.size() > 0) {
                system.debug('inside reqToUpdate update');
                update reqToUpdate;
            }
        }
    }
    
    public void onAfterUpdate(List<TPA_Agreement_Additional_Field__c> oldTpaAgreeAdditFieldList, List<TPA_Agreement_Additional_Field__c> newTpaAgreeAdditFieldList, Map<Id,TPA_Agreement_Additional_Field__c> oldTpaAgreeAdditFieldMap, Map<Id,TPA_Agreement_Additional_Field__c> newTpaAgreeAdditFieldMap) {
        
        newList = [SELECT Id, Early_Contract_Expiry_Date__c,Related_TPA_Request__c,Related_TPA_Request__r.Id,Related_TPA_Request__r.Request_Status__c,Vendor_Contact_First_Name__c,Vendor_Contact_Last_Name__c,Vendor_Contact_Title__c,Vendor_Contact_e_mail__c,Authorized_Signer_First_Name__c,Authorized_Signer_Last_Name__c,Authorized_Signer_Title__c,Authorized_Signer_Email__c,Vendor_Compliance_First_Name__c,Vendor_Compliance_Last_Name__c,Vendor_Compliance_Job_Title__c,Vendor_Compliance_Email__c from TPA_Agreement_Additional_Field__c where Id IN : newTpaAgreeAdditFieldMap.keySet() and Related_TPA_Request__r.Request_Status__c = 'In Effect'];
        tpaRequestList = new List<TPA_Request__c>();
        if(newList != null)
        {
            for(TPA_Agreement_Additional_Field__c agrAdditionalFieldObj :newList)
          {
                system.debug('id********'+agrAdditionalFieldObj.Related_TPA_Request__r.Id);
                tpaRequest= [select id,name,Vendor_First_Name__c,Vendor_Contact_Last_Name__c,Vendor_Contact_Title__c,Vendor_e_mail__c,Vendor_Contact_e_mail__c,TPA_Authorised_Signer__c,Authorized_Signer_First_Name__c,Authorized_Signer_Last_Name__c,Authorized_Signer_Title__c,Authorized_Signer_Email__c,Vendor_Compliance_First_Name__c,Vendor_Compliance_Last_Name__c,Vendor_Compliance_Job_Title__c,Vendor_Compliance_Email__c from TPA_Request__c where id =: agrAdditionalFieldObj.Related_TPA_Request__r.Id];
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_First_Name__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_First_Name__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_First_Name__c)
                {
                    Subject = 'Vendor Contact First Name is updated from ' +tpaRequest.Vendor_First_Name__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_First_Name__c;
                    tpaRequest.Vendor_First_Name__c = newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_First_Name__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Last_Name__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Last_Name__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Last_Name__c)
                {
                    Subject = 'Vendor Contact Last Name is updated from ' +tpaRequest.Vendor_Contact_Last_Name__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Last_Name__c;
                    tpaRequest.Vendor_Contact_Last_Name__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Last_Name__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Title__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Title__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Title__c)
                {
                    Subject = 'Vendor Contact Title is updated from ' +tpaRequest.Vendor_Contact_Title__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Title__c;
                    tpaRequest.Vendor_Contact_Title__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_Title__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_e_mail__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_e_mail__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_e_mail__c)
                {
                    Subject = 'Vendor Contact Email is updated from ' +tpaRequest.Vendor_Contact_e_mail__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_e_mail__c;
                    tpaRequest.Vendor_e_mail__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_e_mail__c;
                    tpaRequest.Vendor_Contact_e_mail__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Contact_e_mail__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                if(tpaRequest.TPA_Authorised_Signer__c == 'No')
                {
                    if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_First_Name__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_First_Name__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_First_Name__c)
                    {
                        Subject = 'Authorised Signer First Name is updated from ' +tpaRequest.Authorized_Signer_First_Name__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_First_Name__c;
                        tpaRequest.Authorized_Signer_First_Name__c = newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_First_Name__c;
                        updateActivityHistory(agrAdditionalFieldObj, Subject);
                    }
                    if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Last_Name__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Last_Name__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Last_Name__c)
                    {
                        Subject = 'Authorised Signer Last Name is updated from ' +tpaRequest.Authorized_Signer_Last_Name__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Last_Name__c;
                        tpaRequest.Authorized_Signer_Last_Name__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Last_Name__c;
                        updateActivityHistory(agrAdditionalFieldObj, Subject);
                    }
                    if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Title__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Title__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Title__c)
                    {
                        Subject = 'Authorised Signer Title is updated from ' +tpaRequest.Authorized_Signer_Title__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Title__c;
                        tpaRequest.Authorized_Signer_Title__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Title__c;
                        updateActivityHistory(agrAdditionalFieldObj, Subject);
                    }
                    if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Email__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Email__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Email__c)
                    {
                        Subject = 'Authorised Signer Email is updated from ' +tpaRequest.Authorized_Signer_Email__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Email__c;
                        tpaRequest.Authorized_Signer_Email__c   =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Authorized_Signer_Email__c;
                        updateActivityHistory(agrAdditionalFieldObj, Subject);
                    }
                }
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_First_Name__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_First_Name__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_First_Name__c)
                {
                    Subject = 'Vendor Compliance First Name is updated from ' +tpaRequest.Vendor_Compliance_First_Name__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_First_Name__c;
                    tpaRequest.Vendor_Compliance_First_Name__c = newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_First_Name__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Last_Name__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Last_Name__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Last_Name__c)
                {
                    Subject = 'Vendor Compliance Last Name is updated from ' +tpaRequest.Vendor_Compliance_Last_Name__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Last_Name__c;
                    tpaRequest.Vendor_Compliance_Last_Name__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Last_Name__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Job_Title__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Job_Title__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Job_Title__c)
                {
                    Subject = 'Vendor Compliance Title is updated from ' +tpaRequest.Vendor_Compliance_Job_Title__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Job_Title__c;
                    tpaRequest.Vendor_Compliance_Job_Title__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Job_Title__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                if(newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Email__c != null && newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Email__c !=  oldTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Email__c)
                {
                    Subject = 'Vendor Compliance Email is updated from ' +tpaRequest.Vendor_Compliance_Email__c +' to '+newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Email__c;
                    tpaRequest.Vendor_Compliance_Email__c =  newTpaAgreeAdditFieldMap.get(agrAdditionalFieldObj.id).Vendor_Compliance_Email__c;
                    updateActivityHistory(agrAdditionalFieldObj, Subject);
                }
                tpaRequestList.add(tpaRequest);
          }
            try{
                if( tpaRequestList.size() > 0 )
                {
                    UTL_TPA.modifyRequestForcefully = true;
                    update tpaRequestList;
                    UTL_TPA.modifyRequestForcefully = false;
                }
            }catch(Exception e){
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPA_AgreementAdditionalField.onAfterUpdate:::TPA Request update Failed', '');
            }
            try{
                if( taskToInsertList.size() > 0 ){
                    insert taskToInsertList;
                }
            }catch(Exception e){
                UTL_LogFactory.generateAndCommitLog(TRUE, FALSE, UTL_LogFactory.GUID, e.getMessage(), 'TPA', 'Exception', 'ERROR', 'Line#' + e.getLineNumber() + ':::TGRH_TPA_AgreementAdditionalField.onAfterUpdate:::Task List update Failed', '');
            }
        }
    }
    
    private void updateActivityHistory( TPA_Agreement_Additional_Field__c tpaAgreementAdditionalFieldDataObj,String Subject ){
        Task task = new Task();
        task.WhatId = tpaAgreementAdditionalFieldDataObj.Id;
        task.ActivityDate = system.today();
        task.Status = 'Completed';
        task.CallObject = Subject;
        task.Subject = Subject;
        
        taskToInsertList.add( task );
    }

}
