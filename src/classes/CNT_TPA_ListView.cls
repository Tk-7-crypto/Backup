public without sharing class CNT_TPA_ListView {

    public Id requestId{get;set;}
    public String name{get;set;}
    String requestSubmissionformURL = UTL_TPA.requestSubmissionformURL;
    String EarlyExpiryFormURL = UTL_TPA.TPA_ClientCOM_URL + '/VFP_TPA_EarlyExpiryForm';
    public String isRenew;
    public CNT_TPA_ListView() {
        isRenew = '';
    }

    public PageReference executeAction(){
        requestId = ApexPages.currentPage().getParameters().get('Id');
         name = ApexPages.currentPage().getParameters().get('name');
         if( requestID != null && name != '' ){
            if( name == 'cancel' ){
                 return cancelRecord();
             }
            if( name == 'closedDraft' ){
                 return closedDraftRecord();
             }
            if( name == 'clone' ){
                 isRenew = 'no';
                 return cloneOrRenewRecord();
             }
             if( name == 'renew' ){
                 isRenew = 'yes';
                 return cloneOrRenewRecord();
             }
             if( name == 'view' ){
                 return viewRecord();
             }
             if( name == 'edit' ){
                 return editRecord();
             }
             if (name == 'earlyexpire'){
                 return earlyExpire();
             }
         }
         return null;
    }
    
    public PageReference cloneOrRenewRecord(){

        PageReference clonePage = new PageReference(requestSubmissionformURL);
        clonePage.getParameters().put('id',requestId);
        clonePage.getParameters().put('requestType', (isRenew == 'yes' ? 'renew' : 'clone'));
        clonePage.getParameters().put('type','c');
        clonePage.setRedirect(true);
        return clonePage;
    }
    
    public TPA_Request__c cloneOrRenewRecord(TPA_Request__c originalTpaRequest){

        TPA_Request__c tpaRequest = originalTpaRequest.clone(false,true,false,false);
        tpaRequest.Is_Submitted__c = true;
        tpaRequest.OwnerId = UserInfo.getUserId();
        insert tpaRequest;
        system.debug(originalTpaRequest.Id+ 'cloned id------------'+tpaRequest.Id);
        cloneChildRecords( originalTpaRequest,tpaRequest );
        return SRV_TPA_TPARequest.getRequestInfo( tpaRequest.Id );

    }

    public PageReference cancelRecord(){
         TPA_Request__c tpaRequest = new TPA_Request__c(Id = requestId);
         tpaRequest.Request_Status__c = 'Cancelled';
         update tpaRequest;
         SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'Request Cancelled', true);
         PageReference pageRef = new PageReference('/imshealthPortal/VFP_TPA_CustomLandingPage');
         pageRef.setRedirect(true);
         return pageRef;
    }
    
    public PageReference closedDraftRecord(){
         TPA_Request__c tpaRequest = SRV_TPA_TPARequest.getRequestInfo(requestId);
         tpaRequest.Request_Status__c = 'Draft Closed';
         update tpaRequest;
         SRV_TPA_TPARequest.sendClosedRequestMail(tpaRequest, true);
         SRV_TPA_TPARequest.updateActivityHistory(tpaRequest.Id, 'Request Draft Closed by Client', true);
         PageReference pageRef = new PageReference('/imshealthPortal/VFP_TPA_CustomLandingPage');
         pageRef.setRedirect(true);
         return pageRef;
    }

    public PageReference editRecord(){
        PageReference editPage = new PageReference(requestSubmissionformURL);
        editPage.getParameters().put('id',requestId);
        editPage.getParameters().put('requestType','edit');
        editPage.getParameters().put('type','c');
        editPage.setRedirect(true);
        return editPage;
    }

    public PageReference viewRecord(){
        PageReference viewPage = new PageReference(requestSubmissionformURL);
        viewPage.getParameters().put('id',requestId);
        viewPage.getParameters().put('requestType','view');
        viewPage.getParameters().put('type','c');
        viewPage.setRedirect(true);
        return viewPage;
    }
    
      
    public PageReference earlyExpire(){
        PageReference formPage = new PageReference(EarlyExpiryFormURL);
        formPage.getParameters().put('id',requestId);
        formPage.getParameters().put('requestType','earlyexpire');
        formPage.getParameters().put('type','c');
        formPage.setRedirect(true);
        System.debug(formPage);
        return formPage;
    }

    private void cloneChildRecords( TPA_Request__c originalTpaRequest,TPA_Request__c tpaRequest ){
        List<TPA_Contact__c> tpaContactsToInsertList ;
        Map<Id,TPA_Purpose__c> tpaPurposeToInsertMap ;
        List<TPA_Data_Asset__c> dataAssetToInsertList ;
        Map<Id,TPA_Data_Asset__c> dataAssetToInsertMap = new Map<Id,TPA_Data_Asset__c>();
        List<TPA_Secondary_Data_Asset__c> secDataAssetToInsertList ;
        List<TPA_Secondary_Data_Asset__c> orginalSecDataAssets = new List<TPA_Secondary_Data_Asset__c>();
        List<TPA_Purpose_Description__c> originalPurposeDescriptions = new List<TPA_Purpose_Description__c>();
        List<TPA_Purpose_Description__c> purposeDescriptionToInsertList = new List<TPA_Purpose_Description__c>();
        if( originalTpaRequest.TPA_Request_Contacts__r.size() > 0 ){
            TPA_Contact__c contactToInsert;
            tpaContactsToInsertList = new List<TPA_Contact__c>();
            for( TPA_Contact__c tpaContact : originalTpaRequest.TPA_Request_Contacts__r ){
                contactToInsert = new TPA_Contact__c();
                contactToInsert = tpaContact.clone(false,true,false,false);
                contactToInsert.TPA_Request__c = tpaRequest.Id;
                tpaContactsToInsertList.add( contactToInsert);
            }
        }

        List<TPA_Purpose__c> originalTPAPurposeList = SRV_TPA_TPARequest.getPurposeAndDescriptionList( originalTpaRequest.Id );
        if( originalTPAPurposeList.size() > 0 ){
            TPA_Purpose__c purposeToInsert;
            tpaPurposeToInsertMap = new Map<Id,TPA_Purpose__c>();
            originalPurposeDescriptions = new List<TPA_Purpose_Description__c>();
            for( TPA_Purpose__c tpaPurpose : originalTPAPurposeList ){
                purposeToInsert = new TPA_Purpose__c();
                purposeToInsert = tpaPurpose.clone(false,true,false,false);
                purposeToInsert.Request__c = tpaRequest.Id;
                tpaPurposeToInsertMap.put( tpaPurpose.Id,purposeToInsert);
                originalPurposeDescriptions.add( tpaPurpose.Purpose_Descriptions__r );
            }
        }
         if( originalTpaRequest.TPA_Request_Contacts__r.size() > 0 ){
            insert tpaContactsToInsertList;
        }

        if( originalTPAPurposeList.size() > 0 ){
            insert tpaPurposeToInsertMap.values();
        }
        Map<Id,LIST<TPA_Data_Asset__c>>  originalTPADataAssetMap = SRV_TPA_TPARequest.getPurposeIdDataAssetMap(tpaPurposeToInsertMap.keySet());

        for( Id objId : originalTPADataAssetMap.keySet() ){

            if( originalTPADataAssetMap.get( objId ).size() > 0 ){
                TPA_Data_Asset__c dataAssetToInsert;
                for( TPA_Data_Asset__c tpadataAsset : originalTPADataAssetMap.get( objId )){
                    dataAssetToInsert = new TPA_Data_Asset__c();
                    dataAssetToInsert = tpadataAsset.clone(false,true,false,false);
                    dataAssetToInsert.Request__c = tpaRequest.Id;
                    dataAssetToInsert.Purpose__c = tpaPurposeToInsertMap.get(tpadataAsset.Purpose__c).Id;
                    dataAssetToInsertMap.put( tpadataAsset.Id,dataAssetToInsert);
                }
            }

        }

        if( originalPurposeDescriptions.size() > 0 ){
            TPA_Purpose_Description__c purposeDescriptionToInsert;
            purposeDescriptionToInsertList = new List<TPA_Purpose_Description__c>();
            for( TPA_Purpose_Description__c purDesc : originalPurposeDescriptions ){
                purposeDescriptionToInsert = new TPA_Purpose_Description__c();
                purposeDescriptionToInsert = purDesc.clone(false,true,false,false);
                purposeDescriptionToInsert.Purpose__c = tpaPurposeToInsertMap.get(purDesc.Purpose__c).Id;
                purposeDescriptionToInsertList.add( purposeDescriptionToInsert );
            }

        }
        if( originalTPADataAssetMap.values().size() > 0 ){
        SYSTEM.DEBUG('**********'+dataAssetToInsertMap);
            insert dataAssetToInsertMap.values();
        }
        orginalSecDataAssets = SRV_TPA_TPARequest.getTPASecondaryDataAsset( dataAssetToInsertMap.keySet() );
        if( orginalSecDataAssets.size() > 0 ){
            TPA_Secondary_Data_Asset__c secDataAssetToInsert;
            secDataAssetToInsertList = new List<TPA_Secondary_Data_Asset__c>();
            for( TPA_Secondary_Data_Asset__c secDataAsset : orginalSecDataAssets ){
                secDataAssetToInsert = new TPA_Secondary_Data_Asset__c();
                secDataAssetToInsert = secDataAsset.clone(false,true,false,false);
                secDataAssetToInsert.TPA_Data_Asset__c  = dataAssetToInsertMap.get(secDataAsset.TPA_Data_Asset__c).Id;
                if(secDataAsset.IMS_Secondary_Data_Asset__c != null )
                    secDataAssetToInsert.IMS_Secondary_Data_Asset__c = secDataAsset.IMS_Secondary_Data_Asset__c;
                secDataAssetToInsertList.add( secDataAssetToInsert );
            }
        }
        if( originalPurposeDescriptions.size() > 0 ){
            system.debug( '*******************'+purposeDescriptionToInsertList );
            insert purposeDescriptionToInsertList;
        }
        if( orginalSecDataAssets.size() > 0 ){
            insert secDataAssetToInsertList;
        }
    }
}