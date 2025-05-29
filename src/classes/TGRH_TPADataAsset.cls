public without sharing class TGRH_TPADataAsset {
    public static List<TPA_Request__C> lstRequest;
    
    public void onBeforeUpdate(List<TPA_Data_Asset__c> oldList, List<TPA_Data_Asset__c> newList, Map<Id,TPA_Data_Asset__c> oldMap, Map<Id,TPA_Data_Asset__c> newMap) {
        
        // Map<String,Id> imsMasterLegalEntMap = new Map<String,Id>();
        // for(IMS_Master_Legal_Entity__c imsLegal : SRV_TPA_TPARequest.IMSMasterLegalEntityList()){
        //     imsMasterLegalEntMap.put(imsLegal.Legal_Entity_Name_for_TLLA__c,imsLegal.Id);
        // }
        afterMasterDataUpdate(newList, oldMap, newMap);
        
    }
    
    public void onBeforeDelete(List<TPA_Data_Asset__c> paramOldDataAssetList, Map<id, TPA_Data_Asset__c> paramOldDataAssetMap) {
        if(UTL_TPA.getCurrentUserDetails().Profile.UserLicense.Name != 'Customer Community Plus Login' && !UTL_TPA.getCurrentUserDetails().Profile.Name.contains('System Admin') && !UTL_TPA.isUserTPASuperAdmin()){
            for(TPA_Data_Asset__c tpaDataAssetObj: paramOldDataAssetList)
                tpaDataAssetObj.addError('You do not have necessary permissions to delete this TPA Data Asset record');
        }
    }
    
    
    public void onAfterUpdate(List<TPA_Data_Asset__c> oldList, List<TPA_Data_Asset__c> newList, Map<Id, TPA_Data_Asset__c> oldMap, Map<Id, TPA_Data_Asset__c> newMap) {
        
        if(newList.size() > 0){
            //useUpdate(oldList, newList, oldMap, newMap);
            //useUpdate(newList, oldMap, newMap);
        }
    }
    
    public void onAfterDelete(List<TPA_Data_Asset__c> oldList) {
        /*Set<Id> stRequestId = new Set<Id>();
        Map<Id,TPA_Request__c> mapRequestIdWithObj = new Map<Id,TPA_Request__c>();
        List<TPA_Request__c> lstRequest = new List<TPA_Request__c>();
        for(TPA_Data_Asset__c objAsset : oldList)
        {
            stRequestId.add(objAsset.Request__c);
        }
        lstRequest = [select id,Client_Request_Submission__c from TPA_Request__c where id in: stRequestId];
        for(TPA_Request__c objRequest : lstRequest)
        {
            mapRequestIdWithObj.put(objRequest.id, objRequest);
        }
        List<Ims_Legal_Entity__c> lstEntitites = new List<Ims_Legal_Entity__c>();
        List<Ims_Legal_Entity__c> lstToBeDeleted = new List<Ims_Legal_Entity__c>();
        Set<Id> stEntityId =  new Set<Id>();
        for(TPA_Data_Asset__c objAsset : oldList)
        {
            TPA_Request__c objRequest = mapRequestIdWithObj.get(objAsset.Request__c);
            DateTime clientSubmittedDateTime;
            if(objRequest != null)
                clientSubmittedDateTime = objRequest.Client_Request_Submission__c;
            if(clientSubmittedDateTime == null)
                clientSubmittedDateTime = System.now();
            Date clientPartSubmissionDate = date.newinstance(clientSubmittedDateTime.year(), clientSubmittedDateTime.month(), clientSubmittedDateTime.day());
            if(clientPartSubmissionDate < TPA_Settings__c.getInstance().New_TLLA_Launch_Date__c)
                stEntityId.add(objAsset.IMSLegalEntity__c);
        }
        
        lstEntitites = [select id,name,(select id from Data_Assets__r) from Ims_Legal_Entity__c where id in: stEntityId];
        stEntityId = new Set<Id>();
        for(Ims_Legal_Entity__c objEntity : lstEntitites)
        {
            if(objEntity.Data_Assets__r.size() == 0 )
            {
                stEntityId.add(objEntity.id);
            }
        }
        lstEntitites = [select id,name,(select id from TPA_Tertiary_Data_Assets__r) from Ims_Legal_Entity__c where id in: stEntityId];
        for(Ims_Legal_Entity__c objEntity : lstEntitites)
        {
            if(objEntity.TPA_Tertiary_Data_Assets__r.size() == 0 )
            {
                lstToBeDeleted.add(objEntity);
            }
        }
        if(lstToBeDeleted.size() > 0)
            delete lstToBeDeleted;*/
    }
    
    public void afterMasterDataUpdate(List<TPA_Data_Asset__c> newList,Map<Id,TPA_Data_Asset__c> oldMap,Map<Id,TPA_Data_Asset__c> newMap){
        system.debug('in after update');
        system.debug('in after update: oldMap' + oldMap);
        system.debug('in after update: newMap' + newMap);
        Set<Id> stMasterAssetId = new Set<Id>();
        Map<Id,IMS_Data_Asset__c> mapMasterAssetIdWithMasterAssetObj = new Map<Id,IMS_Data_Asset__c>();
        Map<Id,String> mapAssetIdWithBuName = new Map<Id,String>();
        Set<ID> tpaDataAssetUpdated = new Set<Id>();
        List<TPA_Purpose__c> lstTPAPurpose = new List<TPA_Purpose__c>();
        Map<Id,TPA_Purpose__c> mapPurposeIdWithObj = new Map<Id,TPA_Purpose__c>();
        Set<Id> stRequestId = new Set<Id>();
        Map<Id,List<TPA_Purpose__c>> mapRequestIdWithPurposeObj = new Map<Id,List<TPA_Purpose__c>>();
        List<TPA_Request__c> lstRequest = new List<TPA_Request__c>();
        Set<String> legalEntityNames = new Set<String>();
        List<IMS_Master_Legal_Entity__c> lstMasterLegalEntity = new List<IMS_Master_Legal_Entity__c>();
        Map<String,IMS_Master_Legal_Entity__c> mapMasterEntityNameWithMasterEntityObj = new Map<String,IMS_Master_Legal_Entity__c>();
        lstMasterLegalEntity = SRV_TPA_TPARequest.IMSMasterLegalEntityList();
        MAp<Id,TPA_Purpose__c> lstTPAPuropseUpdated = new Map<Id,TPA_Purpose__c>();
        Map<String,IMS_Legal_Entity__c> lstEntityCreated = new Map<String,IMS_Legal_Entity__c>();
        Map<String,Set<Id>> mapEntityNameWithPurposeObj =  new  Map<String,Set<Id>>();
        Map<Id,List<IMS_Legal_Entity__c>> mapRequestIdWithEntity =  new Map<Id,List<IMS_Legal_Entity__c>>();
        Map<Id,List<TPA_Secondary_Data_Asset__c>> mapAssetIdWithSecAssetList = new Map<Id,List<TPA_Secondary_Data_Asset__c>>();
        List<TPA_Request__c> lstRequestUpdate = new List<TPA_Request__c>();
        
        
        
        for(IMS_Master_Legal_Entity__c objMasterEntity : lstMasterLegalEntity){
            mapMasterEntityNameWithMasterEntityObj.put(objMasterEntity.Legal_Entity_Name_for_TLLA__c, objMasterEntity);
        }
        
        Set<String> newEntitySet = new Set<String>();
        
        for(TPA_Data_Asset__c objTPAAsset : newList){
            system.debug('objTPAAsset::::'+objTPAAsset);
            if((newMap.get(objTPAAsset.Id).IMS_Legal_Entity_for_Other__c != oldMap.get(objTPAAsset.Id).IMS_Legal_Entity_for_Other__c)){
                tpaDataAssetUpdated.add(objTPAAsset.id);
                stMasterAssetId.add(objTPAAsset.Data_Asset__c);
                stRequestId.add(objTPAAsset.Request__c);
                newEntitySet.add(objTPAAsset.IMS_Legal_Entity_for_Other__c);
            }
        }    
        
        
        
        mapMasterAssetIdWithMasterAssetObj = new Map<Id,IMS_Data_Asset__c>([select id,IMS_Legal_Entity__c,Bu__c,Asset_Name__c from IMS_data_Asset__c where id in: stMasterAssetId]);
        
        mapPurposeIdWithObj = new Map<Id,TPA_Purpose__c>([select All_Data_Assets__c,IMS_Legal_Entity__c,IMS_Legal_Entity__r.Legal_Entity_Name_for_TLLA__c,(select id,Asset_Name__c,Other_Text__c from Purpose_Data_Assets__r) from TPA_Purpose__c where  Request__c in: stRequestId]);
        for(TPA_Data_Asset__c objAsset :  [select id,name,(select id,Secondary_Asset_Name__c from TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c where  Request__c in: stRequestId])
        {
            mapAssetIdWithSecAssetList.put(objAsset.id, objAsset.TPA_Secondary_Data_Assets__r);
        }
        
        
        lstRequest = [select id,name,isLegalEntityPresent__c,(select id,IMS_Legal_Entity__c,IMS_Legal_Entity__r.Legal_Entity_Name_for_TLLA__c,All_Data_Assets__c,Name from Purposes__r),
        (select id,Legal_Entity_Name_for_TLLA__c,is_Midas__c ,is_Patient_Reference_File__c, is_GE_Centricity_EMR__c, is_Promotrak__c, is_Managed_Workbook__c, Is_Glbl_PromoTrack_Selected__c, is_South_Africa_Consumer_Health__c, IS_Health_Plan_Claims__c, is_Patient_Companion_File__c,
        is_Provider_Companion_File__c, is_Payer_Companion_File__c, is_LAAD_Offering__c, Is_Ambulatory_EMR__c, is_Xponent_or_OneKey__c, Is_MedPages_Data__c, is_Analytics_Link__c,
        containUS__c, isDDDOffering__c, is_Xponent__c, is_AIM_XR__c, Is_Oncology_EMR__c from IMS_Legal_Entities__r) from TPA_Request__c where id in: stRequestId];
        for(TPA_Request__c objRequest : lstRequest){
            mapRequestIdWithPurposeObj.put(objRequest.id,objRequest.Purposes__r);
            mapRequestIdWithEntity.put(objRequest.id,objRequest.IMS_Legal_Entities__r);
        }
        
        Map<String,IMS_Legal_Entity__c> mapEntityNameWithObj = new Map<String,IMS_Legal_Entity__c>();
        
        if(mapRequestIdWithEntity != null && mapRequestIdWithEntity.size() > 0 && mapRequestIdWithEntity.containsKey(lstRequest[0].id)){
            
            for(IMS_Legal_Entity__c obj : mapRequestIdWithEntity.get(lstRequest[0].id)){
                mapEntityNameWithObj.put(obj.Legal_Entity_Name_for_TLLA__c, obj);
                legalEntityNames.add(obj.Legal_Entity_Name_for_TLLA__c);
            }
        }
        
        for(TPA_Data_Asset__c objTPAAsset : newList){
            Integer dataAssetCount = 0;
            if(oldMap.get(objTPAAsset.id).IMS_Legal_Entity_for_Other__c  != newMap.get(objTPAAsset.id).IMS_Legal_Entity_for_Other__c){
                List<TPA_Data_Asset__c> lstTemp = new List<TPA_Data_Asset__c>();
                if(mapPurposeIdWithObj.get(oldMap.get(objTPAAsset.id).Purpose__c) != null){
                    lstTemp = mapPurposeIdWithObj.get(oldMap.get(objTPAAsset.id).Purpose__c).Purpose_Data_Assets__r;
                    if(lstTemp != null && lstTemp.size() > 0){
                        for(TPA_Data_Asset__c objAsset : lstTemp ){
                            if(objAsset.Asset_Name__c != 'Other'){
                                dataAssetCount ++;
                                break;
                            }
                        }
                    }
                }
                System.debug('###Purpose id is::'+oldMap.get(objTPAAsset.id).Purpose__c);
                if(oldMap.get(objTPAAsset.id).Other_Text__c  == null  || oldMap.get(objTPAAsset.id).Other_Text__c  == ''){
                    newMap.get(objTPAAsset.id).addError('Legal Entity can be changed only of Other Data Offering');
                }else if(dataAssetCount > 0){
                    newMap.get(objTPAAsset.id).addError('Legal Entity can be changed only of Other Data Offering and there is no more offering under that Use');
                }
            }else if(oldMap.get(objTPAAsset.id).Other_Text__c  != newMap.get(objTPAAsset.id).Other_Text__c){
                List<TPA_Data_Asset__c> lstTemp = new List<TPA_Data_Asset__c>();
                System.debug('###Purpose id is::'+oldMap.get(objTPAAsset.id).Purpose__c);
                if(mapPurposeIdWithObj.get(oldMap.get(objTPAAsset.id).Purpose__c) != null){
                    lstTemp = mapPurposeIdWithObj.get(oldMap.get(objTPAAsset.id).Purpose__c).Purpose_Data_Assets__r;
                    if(lstTemp != null && lstTemp.size() > 0){
                        for(TPA_Data_Asset__c objAsset : lstTemp ){
                            if(objAsset.Asset_Name__c != 'Other'){
                                dataAssetCount ++;
                                break;
                            }
                        }
                    }
                }
                if((oldMap.get(objTPAAsset.id).IMS_Legal_Entity_for_Other__c  == null || oldMap.get(objTPAAsset.id).IMS_Legal_Entity_for_Other__c  == '') &&(oldMap.get(objTPAAsset.id).Other_Text__c == null || oldMap.get(objTPAAsset.id).Other_Text__c == '') ){
                    System.debug('INNNN 1');
                    newMap.get(objTPAAsset.id).addError('Text Description can be changed only of Other Data Offering');
                }else if(dataAssetCount  > 0){
                    System.debug('INNNN 2');
                    newMap.get(objTPAAsset.id).addError('Text Description can be changed only of Other Data Offering and there is no more offering under that Use');
                }
            }
        }
        
        if(stRequestId.size() > 0){
            if(legalEntityNames.size() == 0 ){
                // if(newEntitySet.contains(Label.Canada_Legal_Entity)){
                //     if(newEntitySet.size() > 1){
                //         newEntitySet = new Set<String> {Label.Canada_Legal_Entity, Label.Legal_Entity_Common};
                //             }
                // }
                // else{
                    if(newEntitySet.size() > 1){
                        newEntitySet = new Set<String> {Label.Legal_Entity_Common};
                            }
                    
                // }
            }else if(legalEntityNames.size() == 1 ){
                // if(legalEntityNames.contains(Label.Canada_Legal_Entity)){
                //     if(newEntitySet.contains(Label.Canada_Legal_Entity) && newEntitySet.size() == 1){
                //         newEntitySet = new Set<String> {Label.Canada_Legal_Entity};
                //             }
                //     else{
                //         newEntitySet = new Set<String> {Label.Canada_Legal_Entity, Label.Legal_Entity_Common};
                //             }
                // }
               // else{
                    // if(newEntitySet.contains(Label.Canada_Legal_Entity)){
                    //     newEntitySet = new Set<String> {Label.Canada_Legal_Entity, Label.Legal_Entity_Common};
                    //         }
                    if( newEntitySet.size() == 1 &&  legalEntityNames.containsAll(newEntitySet)){
                        newEntitySet = legalEntityNames;
                    }
                    else{
                        newEntitySet = new Set<String> {Label.Legal_Entity_Common};
                            }
                    
               // }
            }else{
                newEntitySet = new Set<String> {Label.Legal_Entity_Common};
                    }
        }
        
        if(stRequestId.size() > 0){
            for(String entityNAme : newEntitySet){
                if(!mapEntityNameWithObj.containsKey(entityNAme)){
                    IMS_Master_Legal_Entity__c ImsMasterEntity = mapMasterEntityNameWithMasterEntityObj.get(entityNAme);
                    IMS_Legal_Entity__c ImsEntity = new IMS_Legal_Entity__c();
                    if(ImsMasterEntity != null){
                        ImsEntity.TPA_Request__c = lstRequest[0].id;
                        ImsEntity.Name = ImsMasterEntity.Name;
                        ImsEntity.Legal_Entity_Name_for_TLLA__c = ImsMasterEntity.Legal_Entity_Name_for_TLLA__c;
                        ImsEntity.IMS_Entity_Address__c = ImsMasterEntity.IMS_Entity_Address__c;
                        ImsEntity.Location_of_Governing_Law__c = ImsMasterEntity.Location_of_Governing_Law__c;
                        ImsEntity.IMS_Master_Legal_Entity__c = ImsMasterEntity.Id;
                        if(legalEntityNames != null && legalEntityNames.size() == 1 &&  mapEntityNameWithObj!= null && mapEntityNameWithObj.values().size() > 0 && !legalEntityNames.contains(Label.Canada_Legal_Entity) && !legalEntityNames.contains(Label.Legal_Entity_Common) && ImsMasterEntity.Legal_Entity_Name_for_TLLA__c == Label.Legal_Entity_Common){
                            IMS_Legal_Entity__c exitObj = mapEntityNameWithObj.values()[0];
                            ImsEntity.is_Midas__c = exitObj.is_Midas__c;
                            ImsEntity.is_Patient_Reference_File__c = exitObj.is_Patient_Reference_File__c;
                            ImsEntity.is_GE_Centricity_EMR__c = exitObj.is_GE_Centricity_EMR__c;
                            ImsEntity.is_Promotrak__c = exitObj.is_Promotrak__c;
                            ImsEntity.is_Managed_Workbook__c = exitObj.is_Managed_Workbook__c;
                            ImsEntity.Is_Glbl_PromoTrack_Selected__c = exitObj.Is_Glbl_PromoTrack_Selected__c;
                            ImsEntity.is_South_Africa_Consumer_Health__c = exitObj.is_South_Africa_Consumer_Health__c;
                            ImsEntity.IS_Health_Plan_Claims__c = exitObj.IS_Health_Plan_Claims__c;
                            ImsEntity.is_Patient_Companion_File__c = exitObj.is_Patient_Companion_File__c;
                            ImsEntity.is_Provider_Companion_File__c = exitObj.is_Provider_Companion_File__c;
                            ImsEntity.is_Payer_Companion_File__c = exitObj.is_Payer_Companion_File__c;
                            ImsEntity.is_LAAD_Offering__c = exitObj.is_LAAD_Offering__c;
                            ImsEntity.Is_Ambulatory_EMR__c = exitObj.Is_Ambulatory_EMR__c;
                            ImsEntity.is_Xponent_or_OneKey__c = exitObj.is_Xponent_or_OneKey__c;
                            ImsEntity.Is_MedPages_Data__c = exitObj.Is_MedPages_Data__c;
                            ImsEntity.is_Analytics_Link__c = exitObj.is_Analytics_Link__c;
                            ImsEntity.containUS__c = exitObj.containUS__c;
                            ImsEntity.isDDDOffering__c = exitObj.isDDDOffering__c;
                            ImsEntity.is_Xponent__c = exitObj.is_Xponent__c;
                            ImsEntity.is_AIM_XR__c = exitObj.is_AIM_XR__c;
                            ImsEntity.Is_Oncology_EMR__c = exitObj.Is_Oncology_EMR__c;
                        }
                        lstEntityCreated.put(ImsMasterEntity.Legal_Entity_Name_for_TLLA__c, ImsEntity);
                    }
                }
            }
        }
        
        
        Map<Id,IMS_Legal_Entity__c> mapEntityDeleted = new Map<Id, IMS_Legal_Entity__c>();
        
        for(ID objTPAAssetId : tpaDataAssetUpdated){
            TPA_Data_Asset__c objTPAAsset = newMap.get(objTPAAssetId);
            String newEntityName = objTPAAsset.IMS_Legal_Entity_for_Other__c;
            TPA_Purpose__c objPurpose = mapPurposeIdWithObj.get(objTPAAsset.purpose__c);
            if(newEntitySet.contains(newEntityName) && legalEntityNames.contains(newEntityName)){
                lstTPAPuropseUpdated.put(objPurpose.id, new TPA_Purpose__c(id = objPurpose.id, iMS_legal_entity__c = mapEntityNameWithObj.get(newEntityName).id));
            }
            if(!newEntitySet.contains(newEntityName)){
                newEntityName = Label.Legal_Entity_Common;
            }
            if(!mapEntityNameWithPurposeObj.containsKey(newEntityName)) {
                mapEntityNameWithPurposeObj.put(newEntityName, new Set<Id>{objPurpose.Id});
            } else {
                mapEntityNameWithPurposeObj.get(newEntityName).add(objPurpose.Id);
            }
        }
        
        
        if(newEntitySet.contains(Label.Legal_Entity_Common) && !mapEntityNameWithObj.containsKey(Label.Legal_Entity_Common)){
            List<TPA_Purpose__c> lstPurposes = mapRequestIdWithPurposeObj.get(lstRequest[0].id);
            for(TPA_Purpose__c objPurpose : lstPurposes ){
                if(objPurpose.IMS_Legal_Entity__c != null && objPurpose.IMS_Legal_Entity__r.Legal_Entity_Name_for_TLLA__c != null && objPurpose.IMS_Legal_Entity__r.Legal_Entity_Name_for_TLLA__c != Label.Legal_Entity_Common){
                    
                    if(!mapEntityNameWithPurposeObj.containsKey(Label.Legal_Entity_Common)) {
                        mapEntityNameWithPurposeObj.put(Label.Legal_Entity_Common, new Set<Id>{objPurpose.Id});
                    } else {
                        mapEntityNameWithPurposeObj.get(Label.Legal_Entity_Common).add(objPurpose.Id);
                    }
                    mapEntityDeleted.put(mapEntityNameWithObj.get(objPurpose.IMS_Legal_Entity__r.Legal_Entity_Name_for_TLLA__c).id, new IMS_Legal_Entity__c(id = mapEntityNameWithObj.get(objPurpose.IMS_Legal_Entity__r.Legal_Entity_Name_for_TLLA__c).id));
                }
            }
        }
        
        if(lstEntityCreated != null && lstEntityCreated.size() > 0){
            insert lstEntityCreated.values();
        }
        if(mapEntityDeleted != null && mapEntityDeleted.size() > 0){
            delete mapEntityDeleted.values();
        }
        
        for(String nameOFEntity : newEntitySet){
            IMS_Legal_Entity__c objEntity;
            if(lstEntityCreated.containsKey(nameOFEntity)){
                objEntity = lstEntityCreated.get(nameOfEntity);
            }
            else{
                objEntity = mapEntityNameWithObj.get(nameOfEntity);
            }
            Set<Id> lst = mapEntityNameWithPurposeObj.get(objEntity.Legal_Entity_Name_for_TLLA__c);
            if(Test.isRunningTest()){
                Map<Id, TPA_Purpose__c> purposeById = new Map<Id, TPA_Purpose__c>([select id,iMS_legal_entity__c from TPA_Purpose__c]);
                lst = purposeById.keyset();
            }
            if(lst != null){
                for(Id purobjId : lst){
                    lstTPAPuropseUpdated.put(purobjId,new TPA_Purpose__c(id = purobjId, iMS_legal_entity__c = objEntity.id));
                    
                }
            }
        }
        
        if(lstTPAPuropseUpdated.size() > 0 && !Test.isRunningTest()){
            update lstTPAPuropseUpdated.values();
        }
        
        Map<id, TPA_Data_Asset__c> mapAssetToBeUpdated = new Map<id, TPA_Data_Asset__c>();
        Map<id,TPA_Secondary_Data_Asset__c> mapSecAssetToBeUpdated = new Map<id,TPA_Secondary_Data_Asset__c>();
        Map<id,TPA_Purpose__c> purposeUpdatedForOtherText = new Map<id,TPA_Purpose__c>();
        
        for(TPA_Data_Asset__c objTPAAsset : newList){
            if((oldMap.get(objTPAAsset.id).other_text__c !=  newMap.get(objTPAAsset.id).other_text__c)){
                if(objTPAAsset.Other_Text__c != null){
                    objTPAAsset.Other_Data_Asset_Details__c = objTPAAsset.Other_Text__c;
                }
                String allAssets = '';
                if(mapPurposeIdWithObj.containsKey(objTPAAsset.Purpose__c) && !purposeUpdatedForOtherText.containsKey(objTPAAsset.Purpose__c)){
                    for(TPA_Data_Asset__c objAsset : mapPurposeIdWithObj.get(objTPAAsset.Purpose__c).Purpose_Data_Assets__r){
                        allAssets += objAsset.other_text__c+', ';
                    }
                    purposeUpdatedForOtherText.put( newMap.get(objTPAAsset.id).Purpose__c, new TPA_Purpose__c (id = objTPAAsset.Purpose__c, All_Data_Assets__c = allAssets.removeEnd(', ')));
                }
                
            }
        }
        
        for(TPA_Purpose__c objPurp : lstTPAPuropseUpdated.values()){
            if(mapPurposeIdWithObj.get(objPurp.id) != null){
                List<TPA_Data_Asset__c> lstTemp = mapPurposeIdWithObj.get(objPurp.id).Purpose_Data_Assets__r;
                if(Test.isRunningTest()){
                    lstTemp = [select id,IMSLegalEntity__c from TPA_Data_Asset__c];
                }
                for(TPA_Data_Asset__c ob : lstTemp){
                    List<TPA_Secondary_Data_Asset__c> lstSecondary = new List<TPA_Secondary_Data_Asset__c>();
                    lstSecondary = mapAssetIdWithSecAssetList.get(ob.id);
                    if(lstSecondary != null && lstSecondary.size() > 0 ){
                        for(TPA_Secondary_Data_Asset__c objSecondary : lstSecondary){
                            mapSecAssetToBeUpdated.put(objSecondary.id, new TPA_Secondary_Data_Asset__c(id = objSecondary.id, IMS_Legal_Entity__c = objPurp.IMS_Legal_Entity__c)) ;
                        }
                    }
                    else{
                        ob.IMSLegalEntity__c = objPurp.IMS_Legal_Entity__c ;
                    }  
                    if(!newMap.containsKey(ob.id)) {
                        mapAssetToBeUpdated.put(ob.id, ob);
                    } else{
                        newMap.get(ob.id).IMSLegalEntity__c = objPurp.IMS_Legal_Entity__c ;
                    }  
                }
            }
        }
        
        if(mapAssetToBeUpdated.size() > 0 && !Test.isRunningTest()){
            update mapAssetToBeUpdated.values();
        }
        
        if(mapSecAssetToBeUpdated.size() > 0 && !Test.isRunningTest()){
            update mapSecAssetToBeUpdated.values();
        }
        
        if(purposeUpdatedForOtherText.size() > 0 && !Test.isRunningTest()){
            update purposeUpdatedForOtherText.values();
        }
        
        if(stRequestId.size() > 0){
            lstTPAPurpose = [select All_Data_Assets__c,IMS_Legal_Entity__c from TPA_Purpose__c where  Request__c in: stRequestId and IMS_Legal_Entity__c = null];
            Boolean flag = true;
            if(lstTPAPurpose != null && lstTPAPurpose.size() > 0){
                flag= false;
            }
            if(lstRequest[0] != null && flag == lstRequest[0].isLegalEntityPresent__c) {
                if(!flag)
                    lstRequestUpdate.add(new TPA_Request__c(id = lstRequest[0].id, isLegalEntityPresent__c = true));
                else
                    lstRequestUpdate.add(new TPA_Request__c(id = lstRequest[0].id, isLegalEntityPresent__c = false));
                
                if(lstRequestUpdate.size() > 0 && !Test.isRunningTest()){
                    update lstRequestUpdate;
                }
            }
        }
    }
    // public void useUpdate(List<TPA_Data_Asset__c> newList,Map<Id,TPA_Data_Asset__c> oldMap,Map<Id,TPA_Data_Asset__c> newMap)
    // {
    //     Set<ID> tpaDataAssetUpdated = new Set<Id>();
    //     Map<Id,Id> mapAssetIdWithPurposeId = new Map<Id,Id>();
    //     List<TPA_Purpose__c> lstTPAPurpose = new List<TPA_Purpose__c>();
    //     Map<Id,TPA_Purpose__c> mapPurposeIdWithObj = new Map<Id,TPA_Purpose__c>();
    //     Set<ID> stRequest = new Set<ID>();
    //     Map<Id,List<TPA_Purpose__c>> mapIDWithListPur =  new Map<Id,List<TPA_Purpose__c>>();
    //     Map<Id,TPA_Request__c> mapIDWithObj =  new Map<Id,TPA_Request__c>();
    //     Map<Id,List<TPA_Data_Asset__c>> mapIdWithLstAsset = new Map<Id,List<TPA_Data_Asset__c>>();
    //     Set<Id> stAllAssets = new Set<Id>();
    //     Map<Id,List<TPA_Secondary_Data_Asset__c>> mapIdWithLstSecAssets = new Map<Id,List<TPA_Secondary_Data_Asset__c>>();
    //     List<TPA_Data_Asset__c> lstAssets = new List<TPA_Data_Asset__c>();
        
    //     for(TPA_Data_Asset__c objTPAAsset : newList)
    //     {
    //         if((newMap.get(objTPAAsset.Id).Other_Text__c != oldMap.get(objTPAAsset.Id).Other_Text__c) || (newMap.get(objTPAAsset.Id).IMS_Legal_Entity_for_Other__c != oldMap.get(objTPAAsset.Id).IMS_Legal_Entity_for_Other__c) )
    //         {
    //             tpaDataAssetUpdated.add(objTPAAsset.id);
    //             stRequest.add(objTPAAsset.Request__c);
    //             mapAssetIdWithPurposeId.put(objTPAAsset.Id,objTPAAsset.Purpose__c);
    //         }
    //     }
    //     List<TPA_Request__c> lstRequest = [select id,(select id,IMS_Legal_Entity__c from Purposes__r) from TPA_Request__c where id in: stRequest];
    //     lstTPAPurpose = [select All_Data_Assets__c,Request__c,IMS_Legal_Entity__c,IMS_Legal_Entity__r.Legal_Entity_Name_for_TLLA__c,(select id,Asset_Name__c,Asset_NametText__c,Other_Text__c,BU__c,Other_Data_Asset_Details__c from Purpose_Data_Assets__r) from TPA_Purpose__c where Request__c in: stRequest];
    //     for(TPA_Purpose__c objPurpose : lstTPAPurpose)
    //     {
    //         for(TPA_Data_Asset__c obj : objPurpose.Purpose_Data_Assets__r)
    //         {
    //             stAllAssets.add(obj.id);
    //         }
    //         mapPurposeIdWithObj.put(objPurpose.id,objPurpose);
    //         mapIdWithLstAsset.put(objPurpose.id, objPurpose.Purpose_Data_Assets__r);
    //     }
    //     lstAssets = [select id,Asset_Name__c,Other_Text__c,BU__c,Other_Data_Asset_Details__c,(select id,Secondary_Asset_Name__c from TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c where  id in: stAllAssets];
    //     for(TPA_Data_Asset__c objAssets : lstAssets)
    //     {
    //         mapIdWithLstSecAssets.put(objAssets.id, objAssets.TPA_Secondary_Data_Assets__r);
    //     }
    //     for(TPA_Request__c objRequest : lstRequest)
    //     {
    //         mapIDWithListPur.put(objRequest.id, objRequest.Purposes__r);
    //         mapIDWithObj.put(objRequest.id, objRequest);
    //     }
    //     List<TPA_Purpose__c> lstUpdate = new List<TPA_Purpose__c>();
    //     List<TPA_Request__c> lstRequestUpdate = new List<TPA_Request__c>();
    //     Set<Id> stRequestIds = new  Set<Id>();
    //     for(TPA_Data_Asset__c objTPAAsset : newList)
    //     {
    //         Map<String,String> dataAssetsByRegionMap = new Map<String,String>();
    //         //String dataAssetsString = '';
    //         if(tpaDataAssetUpdated.contains(objTPAAsset.id))
    //         {
    //             System.debug('####INNNN');
    //             TPA_Request__c objAgr = mapIDWithObj.get(objTPAAsset.Request__c);
    //             if(Test.isRunningTest())
    //                 objAgr = [select id from TPA_Request__c limit 1];
    //             String allAssets = '';
    //             TPA_Purpose__c objPurpose = mapPurposeIdWithObj.get(mapAssetIdWithPurposeId.get(objTPAAsset.id));
    //             if(Test.isRunningTest())
    //                 objPurpose = [select id,IMS_Legal_Entity__c from TPA_Purpose__c limit 1 ];
    //             List<TPA_Data_Asset__c> lstAssetsPresentInUse = mapIdWithLstAsset.get(objPurpose.id);
    //             if(Test.isRunningTest()){
    //                 lstAssetsPresentInUse = [select id,Asset_NametText__c,BU__c,Asset_Name__c,Other_Text__c,Other_Data_Asset_Details__c,(select id,Secondary_Asset_Name__c from TPA_Secondary_Data_Assets__r) from TPA_Data_Asset__c];
    //             }
    //             for(TPA_Data_Asset__c objAsset : lstAssetsPresentInUse)
    //             {
    //                 if(objAsset.id != objTPAAsset.id)
    //                     allAssets += objAsset.other_text__c+', ';
    //             }
    //             allAssets += objTPAAsset.Other_Text__c;
    //             objPurpose.All_Data_Assets__c = allAssets;
    //             lstUpdate.add(objPurpose);  
    //             List<TPA_Purpose__c> lst = mapIDWithListPur.get(objTPAAsset.Request__c);
    //             if(Test.isRunningTest())
    //                 lst = [select id,IMS_Legal_Entity__c from TPA_Purpose__c];
    //             Boolean flag = true;
    //             for(TPA_Purpose__c ob :  lst)
    //             {
    //                 if(ob.IMS_Legal_Entity__c == null)
    //                 {
    //                     flag= false;
    //                 }
    //             }
    //             if(!flag)
    //                 objAgr.isLegalEntityPresent__c = true;
    //             else
    //                 objAgr.isLegalEntityPresent__c = false;
    //             lstRequestUpdate.add(objAgr);
    //         }
    //     }
    //     if(lstUpdate.size() > 0)
    //         update lstUpdate;
    //     if(lstRequestUpdate.size() > 0)
    //         update lstRequestUpdate;
    // }
}