@isTest(seeAllData=false)
private class TST_TGRH_TPADataAsset {  
    
    static TPA_Data_Asset__c[] dataAssetList = new TPA_Data_Asset__c[]{};
    static TPA_Data_Asset__c[] dataAssetList1;
    static TPA_Data_Asset__c dataAsset;
    
    private static testMethod void testOnAfterInsert(){ 
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>{tpaRequest1,tpaRequest2};
        
        TPA_Request__c agreement1 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[0].Id);
        TPA_Request__c agreement2 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[1].Id );
        List<TPA_Request__c> agreementList = new List<TPA_Request__c>{agreement1,agreement2} ;
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Other');
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Managed Care Workbook - New View');
        imsDataAsset1.IMS_Legal_Entity__c = 'Sample TLLA Name';
        List<IMS_Data_Asset__c> imsDataAssetList = new List<IMS_Data_Asset__c>{imsDataAsset,imsDataAsset1} ;
        insert imsDataAssetList;
        
        IMS_Master_Legal_Entity__c objMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntityWithValue(true, 'Sample Address', 'Sample TLLA Name', 'Sample Title', 'Sample Location', 'Sample Name');
        
        IMS_Master_Legal_Entity__c objMasterLegalEntity1 = UTL_TPA_SetupTestData.getImsMasterLegalEntityWithValue(true, 'Sample Address1', 'Sample TLLA Name1', 'Sample Title1', 'Sample Location1', 'Sample Name1');
        
        IMS_Legal_Entity__c objLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        objLegalEntity.IMS_Master_Legal_Entity__c = objMasterLegalEntity.Id;
        objLegalEntity.TPA_Request__c = agreement1.id;
        objLegalEntity.Name = 'Sample TLLA Name';
        objLegalEntity.Legal_Entity_Name_for_TLLA__c = 'Sample TLLA Name';
        insert objLegalEntity;
        
        TPA_Purpose__c purpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose1.Name = 'APLD';
        purpose1.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose1.Request__c = agreement1.Id;

        TPA_Purpose__c purpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose2.Name = 'Arbitration';
        purpose2.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose2.Request__c = agreement1.Id;

        TPA_Purpose__c purpose3 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose3.Name = 'CHEE';
        purpose3.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose3.Request__c = agreement1.Id;

        TPA_Purpose__c purpose4 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose4.Name = 'TA';
        purpose4.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose4.Request__c = agreement1.Id;

        TPA_Purpose__c purpose5 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose5.Name = 'SSAT';
        purpose5.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose5.Request__c = agreement1.Id;

        TPA_Purpose__c purpose6 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose6.Name = 'CRM';
        purpose6.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose6.Request__c =agreement1.Id;

        TPA_Purpose__c purpose7 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose7.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose7.Name = 'MOMA';
        purpose7.Request__c = agreement1.Id;

        TPA_Purpose__c purpose8 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose8.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose8.Name = 'PR';
        purpose8.Request__c = agreement1.Id;

        TPA_Purpose__c purpose9 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose9.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose9.Name = 'PMR';
        purpose9.Request__c = agreement1.Id;

        TPA_Purpose__c purpose10 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose10.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose10.Name = 'RM';
        purpose10.Request__c = agreement1.Id;

        TPA_Purpose__c purpose11 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose11.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose11.Name = 'DTPC';
        purpose11.Request__c = agreement1.Id;
        
        List<TPA_Purpose__c> purposeList = new List<TPA_Purpose__c>{purpose1,purpose2,purpose3,purpose4,purpose5,purpose6,purpose7,purpose8,purpose9,purpose10,purpose11} ;
        insert purposeList;
      
        
       
        
        // TPA_Data_Asset__c dataAsset11 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        // dataAsset11.Is_IMS_AGProduct__c = true;
        // dataAsset11.hasXponentPlanTrak__c = true;
        // dataAsset11.Data_Asset__c = imsDataAssetList[0].Id;
        // dataAsset11.Request__c = agreementList[0].Id;
        // insert dataAsset11;
        
        // TPA_Data_Asset__c dataAsset12 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        // dataAsset12.IMSLegalEntity__c = objLegalEntity.id;
        // dataAsset12.Is_IMS_AGProduct__c = true;
        // dataAsset12.hasXponentPlanTrak__c = true;
        // dataAsset12.Data_Asset__c = imsDataAssetList[0].Id;
        // dataAsset12.Request__c = agreementList[0].Id;
        // insert dataAsset12;
        
        // List<TPA_Data_Asset__c> lstDelete = new List<TPA_Data_Asset__c>();
        // lstDelete.add(dataAsset11);
        // List<TPA_Data_Asset__c> lstDelete1 = new List<TPA_Data_Asset__c>();
        // lstDelete1.add(dataAsset12);

        dataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[0].Id);
        dataAsset.hasXponentPlanTrak__c = true;
        dataAsset.BU__c = 'US';
        dataAsset.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset.Is_Restricted_Data__c = true;
        dataAsset.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset1 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[2].Id);
        dataAsset1.Is_IMS_AGProduct__c = true;
        dataAsset1.hasXponentPlanTrak__c = true;
        dataAsset1.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset1.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[2].Id);
        // dataAsset2.Is_Restricted_Data__c = true;
        // dataAsset2.Data_Asset__c = imsDataAssetList[0].Id;
        // dataAsset2.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset3 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[3].Id);
        // dataAsset3.Is_IMS_AGProduct__c = true;
        // dataAsset3.hasXponentPlanTrak__c = true;
        // dataAsset3.Data_Asset__c = imsDataAssetList[0].Id;
        // dataAsset3.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset4 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[4].Id);
        // dataAsset4.Is_Restricted_Data__c = true;
        // dataAsset4.Data_Asset__c = imsDataAssetList[0].Id;
        // dataAsset4.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset5 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[5].Id);
        // dataAsset5.Is_IMS_AGProduct__c = true;
        // dataAsset5.hasXponentPlanTrak__c = true;
        // dataAsset5.Data_Asset__c = imsDataAssetList[1].Id;
        // dataAsset5.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset6 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[6].Id);
        // dataAsset6.Is_Restricted_Data__c = true;
        // dataAsset6.Data_Asset__c = imsDataAssetList[1].Id;
        // dataAsset6.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset7 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[7].Id);
        // dataAsset7.Is_IMS_AGProduct__c = true;
        // dataAsset7.hasXponentPlanTrak__c = true;
        // dataAsset7.Data_Asset__c = imsDataAssetList[1].Id;
        // dataAsset7.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset8 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[8].Id);
        // dataAsset8.Is_Restricted_Data__c = true;
        // dataAsset8.Data_Asset__c = imsDataAssetList[1].Id;
        // dataAsset8.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset9 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[9].Id);
        // dataAsset9.Is_IMS_AGProduct__c = true;
        // dataAsset9.hasXponentPlanTrak__c = true;
        // dataAsset9.Data_Asset__c = imsDataAssetList[1].Id;
        // dataAsset9.Request__c = agreementList[0].Id;
        
        // TPA_Data_Asset__c dataAsset10 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[10].Id);
        // dataAsset10.Is_Restricted_Data__c = true;
        // dataAsset10.Data_Asset__c = imsDataAssetList[1].Id;
        // dataAsset10.Request__c = agreementList[0].Id;
        
       // dataAssetList1 = new List<TPA_Data_Asset__c>{dataAsset,dataAsset1,dataAsset2,dataAsset3,dataAsset4,dataAsset5,dataAsset6,dataAsset7,dataAsset8,dataAsset9,dataAsset10};
        dataAssetList1 = new List<TPA_Data_Asset__c>{dataAsset,dataAsset1};

        insert dataAssetList1;
        //dataAssetList.addAll( dataAssetList1 );
        
        List<TPA_Data_Asset__c> oldList = new List<TPA_Data_Asset__c>();
        List<TPA_Data_Asset__c> newList = new List<TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> oldMap = new Map<Id,TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> newMap = new Map<Id,TPA_Data_Asset__c>();
        
        // TPA_Data_Asset__c dataAsset13 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[2].Id);
        // dataAsset13.Request__c = agreement1.Id;
        // dataAsset13.IMSLegalEntity__c = objLegalEntity.Id;
        // dataAsset13.Is_IMS_AGProduct__c = true;
        // dataAsset13.hasXponentPlanTrak__c = true;
        // dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        // insert dataAsset13;
        
        // oldList.add(dataAsset13);
        // oldMap.put(dataAsset13.id,dataAsset13);
        // dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        // dataAsset13.Request__c = agreement1.id;
        // update dataAsset13;
        // newList.add(dataAsset13);    
        // newMap.put(dataAsset13.id,dataAsset13);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Alliance TPA Processing']; 
        User u = new User(Alias = 'tpaUser', Email='testUsertpa@iqvia.com',Change_Request_Description__c = 'test ', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testUsertpa@testorg.com', EmployeeNumber ='08080808');
        test.startTest();
        TGRH_TPADataAsset  obj = new TGRH_TPADataAsset();
        
       // obj.onAfterInsert( dataAssetList1, newMap );
       // dataAssetList[2].Data_Asset__c = imsDataAssetList[0].Id;
       // update dataAssetList;
        //obj.onAfterUpdate( dataAssetList);
        // System.runAs(u) 
        // {
        //     try{
        //         delete dataAssetList;
        //     }
        //     catch(Exception ex)
        //     {
        //         System.Assert(ex.getMessage().contains('You do not have necessary permissions to delete this TPA Data Asset record'));
        //     }
        // }
        // obj.afterMasterDataUpdate(newList, oldMap, newMap);
        oldList = new List<TPA_Data_Asset__c>();
        newList = new List<TPA_Data_Asset__c>();
        oldMap = new Map<Id,TPA_Data_Asset__c>();
        newMap = new Map<Id,TPA_Data_Asset__c>();
        TPA_Data_Asset__c dataAsset15 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset15.Other_Text__c = 'Old Text';
        dataAsset15.Request__c = agreement1.Id;
        dataAsset15.IMSLegalEntity__c = objLegalEntity.Id;
        dataAsset15.Is_IMS_AGProduct__c = true;
        dataAsset15.hasXponentPlanTrak__c = true;
        dataAsset15.Data_Asset__c = imsDataAssetList[0].Id;
        //dataAsset15.Request__c = tpaRequestList[0].Id;
        insert dataAsset15;
        
        oldList.add(dataAsset15);
        oldMap.put(dataAsset15.id, dataAsset15);
         dataAsset15.IMS_Legal_Entity_for_Other__c = 'Sample TLLA Name';
        update dataAsset15;
        newList.add(dataAsset15); 
        newMap.put(dataAsset15.id, dataAsset15);
        //obj.afterMasterDataUpdateForOld(oldList, newList, oldMap, newMap);
        test.stopTest();
    }
        
    private static testMethod void testOnAfterInsert1(){
        
        TPA_Settings__c  objSetting = new TPA_Settings__c();
        objSetting.New_TLLA_Launch_Date__c = Date.newInstance(2016, 03, 07);
        objSetting.Base_Url__c = 'no/url';
        objSetting.TPA_RequestSubmitted_Email__c = 'a.a@iqvia.com';
        insert objSetting;
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>{tpaRequest1,tpaRequest2};
        
        TPA_Request__c agreement1 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[0].Id);
        TPA_Request__c agreement2 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[1].Id);
        List<TPA_Request__c> agreementList = new List<TPA_Request__c>{agreement1,agreement2} ;
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'MIDAS');
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Managed Care Workbook - New View');
        imsDataAsset1.IMS_Legal_Entity__c = 'Sample TLLA Name';
        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Other');
        imsDataAsset2.IMS_Legal_Entity__c = 'Sample TLLA Name1';
        IMS_Data_Asset__c imsDataAsset3 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Other');
        imsDataAsset3.IMS_Legal_Entity__c = 'Sample TLLA Name2';
        List<IMS_Data_Asset__c> imsDataAssetList = new List<IMS_Data_Asset__c>{imsDataAsset,imsDataAsset1,imsDataAsset2,imsDataAsset3} ;
        insert imsDataAssetList;
        
        IMS_Master_Legal_Entity__c objMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntityWithValue(true, 'Sample Address', 'Sample TLLA Name', 'Sample Title', 'Sample Location', 'Sample Name');
        
        IMS_Master_Legal_Entity__c objMasterLegalEntity1 = UTL_TPA_SetupTestData.getImsMasterLegalEntityWithValue(true, 'Sample Address1', 'IQVIA Ltd.', 'Sample Title1', 'Sample Location1', 'IQVIA Ltd.');
                
        IMS_Legal_Entity__c objLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        objLegalEntity.IMS_Master_Legal_Entity__c = objMasterLegalEntity.Id;
        objLegalEntity.TPA_Request__c = agreement1.id;
        objLegalEntity.Name = 'Sample TLLA Name';
        objLegalEntity.Legal_Entity_Name_for_TLLA__c = 'Sample TLLA Name';
        insert objLegalEntity;
        
        system.debug('agreement2: ' + agreement2);
        
        IMS_Legal_Entity__c objLegalEntity1 = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        objLegalEntity1.IMS_Master_Legal_Entity__c = objMasterLegalEntity1.Id;
        objLegalEntity1.TPA_Request__c = agreement2.id;
        objLegalEntity1.Name = 'IQVIA Ltd.';
        objLegalEntity1.Legal_Entity_Name_for_TLLA__c = 'IQVIA Ltd.';
        insert objLegalEntity1;
        
        TPA_Purpose__c purpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose1.Name = 'APLD';
        purpose1.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose1.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose2.Name = 'Arbitration / Litigation Analysis';
        purpose2.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose2.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose3 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose3.Name = 'Comparative Health Economic Evaluation';
        purpose3.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose3.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose4 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose4.Name = 'Territory Alignment';
        purpose4.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose4.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose5 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose5.Name = 'Sales Force Segmentation and Targeting';
        purpose5.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose5.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose6 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose6.Name = 'Customer Relationship Management (CRM)';
        purpose6.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose6.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose7 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose7.Name = 'Medicare or Medicaid Analytics';
        purpose7.IMS_Legal_Entity__c = objLegalEntity1.Id;
        purpose7.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose8 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose8.Name = 'Pricing Reimbursement';
        purpose8.IMS_Legal_Entity__c = objLegalEntity1.Id;
        purpose8.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose9 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose9.Name = 'Primary Market Research';
        purpose9.IMS_Legal_Entity__c = objLegalEntity1.Id;
        purpose9.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose10 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose10.Name = 'Risk Management / Safety Surveillance';
        purpose10.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose11 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose11.Name = 'Direct to Prescriber Communication';
        purpose11.IMS_Legal_Entity__c = objLegalEntity1.Id;
        purpose11.Request__c = agreement1.Id;
        
        List<TPA_Purpose__c> purposeList = new List<TPA_Purpose__c>{purpose1,purpose2,purpose3,purpose4,purpose5,purpose6,purpose7,purpose8,purpose9,purpose10,purpose11} ;
        insert purposeList;
        
        List<TPA_Purpose__c> purposeDeleteList = new List<TPA_Purpose__c>{purpose1,purpose2,purpose3,purpose4,purpose5,purpose6,purpose7,purpose8,purpose9,purpose11};
        
        TPA_Data_Asset__c dataAsset11 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset11.Is_IMS_AGProduct__c = true;
        dataAsset11.hasXponentPlanTrak__c = true;
        dataAsset11.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset11;
        
        TPA_Data_Asset__c dataAsset12 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset12.IMSLegalEntity__c = objLegalEntity.id;
        dataAsset12.Is_IMS_AGProduct__c = true;
        dataAsset12.hasXponentPlanTrak__c = true;
        dataAsset12.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset12;
        
        List<TPA_Data_Asset__c> lstDelete = new List<TPA_Data_Asset__c>();
        lstDelete.add(dataAsset11);
        List<TPA_Data_Asset__c> lstDelete1 = new List<TPA_Data_Asset__c>();
        lstDelete1.add(dataAsset12);

        dataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[0].Id);
        dataAsset.hasXponentPlanTrak__c = true;
        dataAsset.BU__c = 'US';
        dataAsset.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset.Is_Restricted_Data__c = true;
        dataAsset.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset1 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset1.Is_IMS_AGProduct__c = true;
        dataAsset1.hasXponentPlanTrak__c = true;
        dataAsset1.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset1.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[2].Id);
        dataAsset2.Is_Restricted_Data__c = true;
        dataAsset2.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset2.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset3 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[3].Id);
        dataAsset3.Is_IMS_AGProduct__c = true;
        dataAsset3.hasXponentPlanTrak__c = true;
        dataAsset3.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset3.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset4 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[4].Id);
        dataAsset4.Is_Restricted_Data__c = true;
        dataAsset4.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset4.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset5 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[5].Id);
        dataAsset5.Is_IMS_AGProduct__c = true;
        dataAsset5.hasXponentPlanTrak__c = true;
        dataAsset5.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset5.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset6 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[6].Id);
        dataAsset6.Is_Restricted_Data__c = true;
        dataAsset6.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset6.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset7 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[7].Id);
        dataAsset7.Is_IMS_AGProduct__c = true;
        dataAsset7.hasXponentPlanTrak__c = true;
        dataAsset7.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset7.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset8 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[8].Id);
        dataAsset8.Is_Restricted_Data__c = true;
        dataAsset8.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset8.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset9 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[9].Id);
        dataAsset9.Is_IMS_AGProduct__c = true;
        dataAsset9.hasXponentPlanTrak__c = true;
        dataAsset9.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset9.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset10 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[10].Id);
        dataAsset10.Is_Restricted_Data__c = true;
        dataAsset10.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset10.Request__c = agreementList[0].Id;
        
        dataAssetList1 = new List<TPA_Data_Asset__c>{dataAsset,dataAsset1,dataAsset2,dataAsset3,dataAsset4,dataAsset5,dataAsset6,dataAsset7,dataAsset8,dataAsset9,dataAsset10};
        insert dataAssetList1;
        dataAssetList.addAll( dataAssetList1 );
        TGRH_TPADataAsset obj = new TGRH_TPADataAsset();
        
        List<TPA_Data_Asset__c> oldList = new List<TPA_Data_Asset__c>();
        List<TPA_Data_Asset__c> newList = new List<TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> oldMap = new Map<Id,TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> newMap = new Map<Id,TPA_Data_Asset__c>();
        
        TPA_Data_Asset__c dataAsset13 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset13.Request__c = agreement1.Id;
        dataAsset13.IMSLegalEntity__c = objLegalEntity.Id;
        dataAsset13.Is_IMS_AGProduct__c = true;
        dataAsset13.hasXponentPlanTrak__c = true;
        dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset13;
        
        oldList.add(dataAsset13);
        oldMap.put(dataAsset13.id,dataAsset13);
        dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset13.Request__c = agreement1.id;
        update dataAsset13;
        newList.add(dataAsset13);    
        newMap.put(dataAsset13.id,dataAsset13);
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'tpaUser', Email='testUsertpa@iqvia.com', Change_Request_Description__c = 'test ' , Change_Request_Ticket_Number__c = 'test', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testUsertpa@testorg.com', EmployeeNumber ='080808081');
                
       // obj.onAfterInsert( dataAssetList1, newMap );
        dataAssetList[2].Data_Asset__c = imsDataAssetList[0].Id;
        update dataAssetList;
        //obj.onAfterUpdate( dataAssetList );
        System.runAs(u) 
        {
            try{
                delete dataAssetList;
            }
            catch(Exception ex)
            {
                System.Assert(ex.getMessage().contains('You do not have necessary permissions to delete this TPA Data Asset record'));
            }
        }
        obj.afterMasterDataUpdate(newList, oldMap, newMap);
        
        oldList = new List<TPA_Data_Asset__c>();
        newList = new List<TPA_Data_Asset__c>();
        oldMap = new Map<Id,TPA_Data_Asset__c>();
        newMap = new Map<Id,TPA_Data_Asset__c>();
        objLegalEntity.Id = null;
        upsert objLegalEntity;
        TPA_Data_Asset__c dataAsset15 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[10].Id);
        dataAsset15.Other_Text__c = 'Old Text';
        dataAsset15.Request__c = agreement1.Id;
        dataAsset15.IMSLegalEntity__c = objLegalEntity.Id;
        dataAsset15.Is_IMS_AGProduct__c = true;
        dataAsset15.hasXponentPlanTrak__c = true;
        dataAsset15.Data_Asset__c = imsDataAssetList[2].Id;
        dataAsset15.IMS_Legal_Entity_for_Other__c = 'Sample TLLA Name';
        insert dataAsset15;
        
        oldList.add(dataAsset15);
        oldMap.put(dataAsset15.id, dataAsset15);
        dataAsset15.Other_Text__c = 'Test Other Name';
        dataAsset15.Other_Text__c = 'Test Other';
        TPA_Data_Asset__c tempAsset = [select id, Other_Text__c, Request__c, Data_Asset__c,IMS_Legal_Entity_for_Other__c,Asset_NametText__c,BU__c,Asset_Name__c,IMSLegalEntity__c,purpose__c from TPA_Data_Asset__C where id =: dataAsset15.id];
        tempAsset.IMS_Legal_Entity_for_Other__c = 'IQVIA Ltd.';
        tempAsset.Data_Asset__c = imsDataAssetList[3].Id;
        system.debug('tempAsset:::'+tempAsset);
        update tempAsset;
        newList.add(tempAsset);
        newMap.put(tempAsset.id, tempAsset);
        delete purposeDeleteList;
        test.stopTest();
    }
    
    private static testMethod void testOnAfterInsertCanadaLE(){
         
        TPA_Settings__c  objSetting = new TPA_Settings__c();
        objSetting.New_TLLA_Launch_Date__c = Date.newInstance(2016, 03, 07);
        objSetting.Base_Url__c = 'no/url';
        objSetting.TPA_RequestSubmitted_Email__c = 'a.a@iqvia.com';
        insert objSetting;
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>{tpaRequest1,tpaRequest2};
        
        TPA_Request__c agreement1 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[0].Id);
        TPA_Request__c agreement2 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[1].Id);
        List<TPA_Request__c> agreementList = new List<TPA_Request__c>{agreement1,agreement2} ;
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'MIDAS');
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Managed Care Workbook - New View');
        imsDataAsset1.IMS_Legal_Entity__c = 'Sample TLLA Name';
        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Other');
        imsDataAsset2.IMS_Legal_Entity__c = 'Sample TLLA Name1';
        IMS_Data_Asset__c imsDataAsset3 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Other');
        imsDataAsset3.IMS_Legal_Entity__c = 'Sample TLLA Name2';
        List<IMS_Data_Asset__c> imsDataAssetList = new List<IMS_Data_Asset__c>{imsDataAsset,imsDataAsset1,imsDataAsset2,imsDataAsset3} ;
        insert imsDataAssetList;
        
        IMS_Master_Legal_Entity__c objMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntityWithValue(true, 'Sample Address', 'IQVIA Ltd.','Sample Title', 'Sample Location', 'IQVIA Ltd.');
        
                
        IMS_Legal_Entity__c objLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        objLegalEntity.IMS_Master_Legal_Entity__c = objMasterLegalEntity.Id;
        objLegalEntity.TPA_Request__c = agreement1.id;
        objLegalEntity.Name = 'Sample TLLA Name';
        objLegalEntity.Legal_Entity_Name_for_TLLA__c = 'IQVIA Solutions Canada Inc.';
        insert objLegalEntity;

        
        TPA_Purpose__c purpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose1.Name = 'APLD';
        purpose1.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose1.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose2.Name = 'Arbitration / Litigation Analysis';
        purpose2.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose2.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose3 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose3.Name = 'Comparative Health Economic Evaluation';
        purpose3.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose3.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose4 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose4.Name = 'Territory Alignment';
        purpose4.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose4.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose5 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose5.Name = 'Sales Force Segmentation and Targeting';
        purpose5.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose5.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose6 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose6.Name = 'Customer Relationship Management (CRM)';
        purpose6.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose6.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose7 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose7.Name = 'Medicare or Medicaid Analytics';
        purpose7.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose7.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose8 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose8.Name = 'Pricing Reimbursement';
        purpose8.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose8.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose9 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose9.Name = 'Primary Market Research';
        purpose9.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose9.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose10 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose10.Name = 'Risk Management / Safety Surveillance';
        purpose10.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose11 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose11.Name = 'Direct to Prescriber Communication';
        purpose11.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose11.Request__c = agreement1.Id;
        
        List<TPA_Purpose__c> purposeList = new List<TPA_Purpose__c>{purpose1,purpose2,purpose3,purpose4,purpose5,purpose6,purpose7,purpose8,purpose9,purpose10,purpose11} ;
        insert purposeList;
        
        List<TPA_Purpose__c> purposeDeleteList = new List<TPA_Purpose__c>{purpose1,purpose2,purpose3,purpose4,purpose5,purpose6,purpose7,purpose8,purpose9,purpose11};
        
        TPA_Data_Asset__c dataAsset11 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset11.Is_IMS_AGProduct__c = true;
        dataAsset11.hasXponentPlanTrak__c = true;
        dataAsset11.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset11;
        
        TPA_Data_Asset__c dataAsset12 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset12.IMSLegalEntity__c = objLegalEntity.id;
        dataAsset12.Is_IMS_AGProduct__c = true;
        dataAsset12.hasXponentPlanTrak__c = true;
        dataAsset12.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset12;
        
        List<TPA_Data_Asset__c> lstDelete = new List<TPA_Data_Asset__c>();
        lstDelete.add(dataAsset11);
        List<TPA_Data_Asset__c> lstDelete1 = new List<TPA_Data_Asset__c>();
        lstDelete1.add(dataAsset12);

        dataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[0].Id);
        dataAsset.hasXponentPlanTrak__c = true;
        dataAsset.BU__c = 'US';
        dataAsset.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset.Is_Restricted_Data__c = true;
        dataAsset.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset1 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset1.Is_IMS_AGProduct__c = true;
        dataAsset1.hasXponentPlanTrak__c = true;
        dataAsset1.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset1.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[2].Id);
        dataAsset2.Is_Restricted_Data__c = true;
        dataAsset2.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset2.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset3 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[3].Id);
        dataAsset3.Is_IMS_AGProduct__c = true;
        dataAsset3.hasXponentPlanTrak__c = true;
        dataAsset3.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset3.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset4 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[4].Id);
        dataAsset4.Is_Restricted_Data__c = true;
        dataAsset4.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset4.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset5 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[5].Id);
        dataAsset5.Is_IMS_AGProduct__c = true;
        dataAsset5.hasXponentPlanTrak__c = true;
        dataAsset5.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset5.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset6 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[6].Id);
        dataAsset6.Is_Restricted_Data__c = true;
        dataAsset6.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset6.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset7 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[7].Id);
        dataAsset7.Is_IMS_AGProduct__c = true;
        dataAsset7.hasXponentPlanTrak__c = true;
        dataAsset7.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset7.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset8 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[8].Id);
        dataAsset8.Is_Restricted_Data__c = true;
        dataAsset8.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset8.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset9 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[9].Id);
        dataAsset9.Is_IMS_AGProduct__c = true;
        dataAsset9.hasXponentPlanTrak__c = true;
        dataAsset9.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset9.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset10 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[10].Id);
        dataAsset10.Is_Restricted_Data__c = true;
        dataAsset10.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset10.Request__c = agreementList[0].Id;
        
        dataAssetList1 = new List<TPA_Data_Asset__c>{dataAsset,dataAsset1,dataAsset2,dataAsset3,dataAsset4,dataAsset5,dataAsset6,dataAsset7,dataAsset8,dataAsset9,dataAsset10};
        insert dataAssetList1;
        dataAssetList.addAll( dataAssetList1 );
        TGRH_TPADataAsset obj = new TGRH_TPADataAsset();
        
        List<TPA_Data_Asset__c> oldList = new List<TPA_Data_Asset__c>();
        List<TPA_Data_Asset__c> newList = new List<TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> oldMap = new Map<Id,TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> newMap = new Map<Id,TPA_Data_Asset__c>();
        
        TPA_Data_Asset__c dataAsset13 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset13.Request__c = agreement1.Id;
        dataAsset13.IMSLegalEntity__c = objLegalEntity.Id;
        dataAsset13.Is_IMS_AGProduct__c = true;
        dataAsset13.hasXponentPlanTrak__c = true;
        dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset13;
        
        oldList.add(dataAsset13);
        oldMap.put(dataAsset13.id,dataAsset13);
        dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset13.Request__c = agreement1.id;
        update dataAsset13;
        newList.add(dataAsset13);    
        newMap.put(dataAsset13.id,dataAsset13);
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'tpaUser', Email='testUsertpa@iqvia.com', Change_Request_Description__c = 'test ' , Change_Request_Ticket_Number__c = 'test', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testUsertpa@testorg.com', EmployeeNumber ='080808081');
                
       // obj.onAfterInsert( dataAssetList1, newMap );
        dataAssetList[2].Data_Asset__c = imsDataAssetList[0].Id;
        update dataAssetList;
        //obj.onAfterUpdate( dataAssetList );
        System.runAs(u) 
        {
            try{
                delete dataAssetList;
            }
            catch(Exception ex)
            {
                System.Assert(ex.getMessage().contains('You do not have necessary permissions to delete this TPA Data Asset record'));
            }
        }
        obj.afterMasterDataUpdate(newList, oldMap, newMap);
        
        oldList = new List<TPA_Data_Asset__c>();
        newList = new List<TPA_Data_Asset__c>();
        oldMap = new Map<Id,TPA_Data_Asset__c>();
        newMap = new Map<Id,TPA_Data_Asset__c>();
        objLegalEntity.Id = null;
        upsert objLegalEntity;
        TPA_Data_Asset__c dataAsset15 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[10].Id);
        dataAsset15.Other_Text__c = 'Old Text';
        dataAsset15.Request__c = agreement1.Id;
        dataAsset15.IMSLegalEntity__c = objLegalEntity.Id;
        dataAsset15.Is_IMS_AGProduct__c = true;
        dataAsset15.hasXponentPlanTrak__c = true;
        dataAsset15.Data_Asset__c = imsDataAssetList[2].Id;
        dataAsset15.IMS_Legal_Entity_for_Other__c = 'Sample TLLA Name';
        insert dataAsset15;
        
        oldList.add(dataAsset15);
        oldMap.put(dataAsset15.id, dataAsset15);
        dataAsset15.Other_Text__c = 'Test Other Name';
        dataAsset15.Other_Text__c = 'Test Other';
        TPA_Data_Asset__c tempAsset = [select id, Other_Text__c, Request__c, Data_Asset__c,IMS_Legal_Entity_for_Other__c,Asset_NametText__c,BU__c,Asset_Name__c,IMSLegalEntity__c,purpose__c from TPA_Data_Asset__C where id =: dataAsset15.id];
        tempAsset.IMS_Legal_Entity_for_Other__c = 'IQVIA Ltd.';
        tempAsset.Data_Asset__c = imsDataAssetList[3].Id;
        system.debug('tempAsset:::'+tempAsset);
        update tempAsset;
        newList.add(tempAsset);
        newMap.put(tempAsset.id, tempAsset);
        delete purposeDeleteList;
        test.stopTest();
    }
    
       private static testMethod void testOnAfterInsertDAUnchanged(){
         
        TPA_Settings__c  objSetting = new TPA_Settings__c();
        objSetting.New_TLLA_Launch_Date__c = Date.newInstance(2016, 03, 07);
        objSetting.Base_Url__c = 'no/url';
        objSetting.TPA_RequestSubmitted_Email__c = 'a.a@iqvia.com';
        insert objSetting;
        
        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTPARequestBlank(true);
        List<TPA_Request__c> tpaRequestList = new List<TPA_Request__c>{tpaRequest1,tpaRequest2};
        
        TPA_Request__c agreement1 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[0].Id);
        TPA_Request__c agreement2 = UTL_TPA_SetupTestData.getTPAAgreementBlank(true, tpaRequestList[1].Id);
        List<TPA_Request__c> agreementList = new List<TPA_Request__c>{agreement1,agreement2} ;
        
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'MIDAS');
        IMS_Data_Asset__c imsDataAsset1 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Managed Care Workbook - New View');
        imsDataAsset1.IMS_Legal_Entity__c = 'Sample TLLA Name';
        IMS_Data_Asset__c imsDataAsset2 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Other');
        imsDataAsset2.IMS_Legal_Entity__c = 'Sample TLLA Name1';
        IMS_Data_Asset__c imsDataAsset3 = UTL_TPA_SetupTestData.getImsDataAssetBlank(false, 'Other');
        imsDataAsset3.IMS_Legal_Entity__c = 'Sample TLLA Name2';
        List<IMS_Data_Asset__c> imsDataAssetList = new List<IMS_Data_Asset__c>{imsDataAsset,imsDataAsset1,imsDataAsset2,imsDataAsset3} ;
        insert imsDataAssetList;
        
        IMS_Master_Legal_Entity__c objMasterLegalEntity = UTL_TPA_SetupTestData.getImsMasterLegalEntityWithValue(true, 'Sample Address', 'IQVIA Ltd.','Sample Title', 'Sample Location', 'IQVIA Ltd.');
        
        IMS_Master_Legal_Entity__c objMasterLegalEntity1 = UTL_TPA_SetupTestData.getImsMasterLegalEntityWithValue(true, 'Sample Address1', 'IQVIA Solutions Canada Inc.', 'Sample Title1', 'Sample Location1', 'IQVIA Solutions Canada Inc.');
                
        IMS_Legal_Entity__c objLegalEntity = UTL_TPA_SetupTestData.getImsLegalEntity_Template();
        objLegalEntity.IMS_Master_Legal_Entity__c = objMasterLegalEntity.Id;
        objLegalEntity.TPA_Request__c = agreement1.id;
        objLegalEntity.Name = 'IQVIA Ltd.';
        objLegalEntity.Legal_Entity_Name_for_TLLA__c = 'IQVIA Ltd.';
        insert objLegalEntity;

        
        TPA_Purpose__c purpose1 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose1.Name = 'APLD';
        purpose1.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose1.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose2 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose2.Name = 'Arbitration / Litigation Analysis';
        purpose2.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose2.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose3 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose3.Name = 'Comparative Health Economic Evaluation';
        purpose3.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose3.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose4 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose4.Name = 'Territory Alignment';
        purpose4.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose4.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose5 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose5.Name = 'Sales Force Segmentation and Targeting';
        purpose5.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose5.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose6 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[0]);
        purpose6.Name = 'Customer Relationship Management (CRM)';
        purpose6.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose6.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose7 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose7.Name = 'Medicare or Medicaid Analytics';
        purpose7.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose7.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose8 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose8.Name = 'Pricing Reimbursement';
        purpose8.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose8.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose9 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose9.Name = 'Primary Market Research';
        purpose9.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose9.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose10 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose10.Name = 'Risk Management / Safety Surveillance';
        purpose10.Request__c = agreement1.Id;
        
        TPA_Purpose__c purpose11 = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequestList[1]);
        purpose11.Name = 'Direct to Prescriber Communication';
        purpose11.IMS_Legal_Entity__c = objLegalEntity.Id;
        purpose11.Request__c = agreement1.Id;
        
        List<TPA_Purpose__c> purposeList = new List<TPA_Purpose__c>{purpose1,purpose2,purpose3,purpose4,purpose5,purpose6,purpose7,purpose8,purpose9,purpose10,purpose11} ;
        insert purposeList;
        
        List<TPA_Purpose__c> purposeDeleteList = new List<TPA_Purpose__c>{purpose1,purpose2,purpose3,purpose4,purpose5,purpose6,purpose7,purpose8,purpose9,purpose11};
        
        TPA_Data_Asset__c dataAsset11 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset11.Is_IMS_AGProduct__c = true;
        dataAsset11.hasXponentPlanTrak__c = true;
        dataAsset11.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset11;
        
        TPA_Data_Asset__c dataAsset12 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset12.IMSLegalEntity__c = objLegalEntity.id;
        dataAsset12.Is_IMS_AGProduct__c = true;
        dataAsset12.hasXponentPlanTrak__c = true;
        dataAsset12.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset12;
        
        List<TPA_Data_Asset__c> lstDelete = new List<TPA_Data_Asset__c>();
        lstDelete.add(dataAsset11);
        List<TPA_Data_Asset__c> lstDelete1 = new List<TPA_Data_Asset__c>();
        lstDelete1.add(dataAsset12);

        dataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[0].Id);
        dataAsset.hasXponentPlanTrak__c = true;
        dataAsset.BU__c = 'US';
        dataAsset.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset.Is_Restricted_Data__c = true;
        dataAsset.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset1 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset1.Is_IMS_AGProduct__c = true;
        dataAsset1.hasXponentPlanTrak__c = true;
        dataAsset1.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset1.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset2 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[2].Id);
        dataAsset2.Is_Restricted_Data__c = true;
        dataAsset2.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset2.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset3 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[3].Id);
        dataAsset3.Is_IMS_AGProduct__c = true;
        dataAsset3.hasXponentPlanTrak__c = true;
        dataAsset3.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset3.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset4 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[4].Id);
        dataAsset4.Is_Restricted_Data__c = true;
        dataAsset4.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset4.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset5 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[5].Id);
        dataAsset5.Is_IMS_AGProduct__c = true;
        dataAsset5.hasXponentPlanTrak__c = true;
        dataAsset5.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset5.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset6 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[6].Id);
        dataAsset6.Is_Restricted_Data__c = true;
        dataAsset6.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset6.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset7 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[7].Id);
        dataAsset7.Is_IMS_AGProduct__c = true;
        dataAsset7.hasXponentPlanTrak__c = true;
        dataAsset7.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset7.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset8 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[8].Id);
        dataAsset8.Is_Restricted_Data__c = true;
        dataAsset8.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset8.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset9 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[9].Id);
        dataAsset9.Is_IMS_AGProduct__c = true;
        dataAsset9.hasXponentPlanTrak__c = true;
        dataAsset9.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset9.Request__c = agreementList[0].Id;
        
        TPA_Data_Asset__c dataAsset10 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[10].Id);
        dataAsset10.Is_Restricted_Data__c = true;
        dataAsset10.Data_Asset__c = imsDataAssetList[1].Id;
        dataAsset10.Request__c = agreementList[0].Id;
        
        dataAssetList1 = new List<TPA_Data_Asset__c>{dataAsset,dataAsset1,dataAsset2,dataAsset3,dataAsset4,dataAsset5,dataAsset6,dataAsset7,dataAsset8,dataAsset9,dataAsset10};
        insert dataAssetList1;
        dataAssetList.addAll( dataAssetList1 );
        TGRH_TPADataAsset obj = new TGRH_TPADataAsset();
        
        List<TPA_Data_Asset__c> oldList = new List<TPA_Data_Asset__c>();
        List<TPA_Data_Asset__c> newList = new List<TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> oldMap = new Map<Id,TPA_Data_Asset__c>();
        Map<Id,TPA_Data_Asset__c> newMap = new Map<Id,TPA_Data_Asset__c>();
        
        TPA_Data_Asset__c dataAsset13 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[1].Id);
        dataAsset13.Request__c = agreement1.Id;
        dataAsset13.IMSLegalEntity__c = objLegalEntity.Id;
        dataAsset13.Is_IMS_AGProduct__c = true;
        dataAsset13.hasXponentPlanTrak__c = true;
        dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        insert dataAsset13;
        
        oldList.add(dataAsset13);
        oldMap.put(dataAsset13.id,dataAsset13);
        dataAsset13.Data_Asset__c = imsDataAssetList[0].Id;
        dataAsset13.Request__c = agreement1.id;
        update dataAsset13;
        newList.add(dataAsset13);    
        newMap.put(dataAsset13.id,dataAsset13);
        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'tpaUser', Email='testUsertpa@iqvia.com', Change_Request_Description__c = 'test ' , Change_Request_Ticket_Number__c = 'test', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testUsertpa@testorg.com', EmployeeNumber ='080808081');
                
        //obj.onAfterInsert( dataAssetList1, newMap );
        dataAssetList[2].Data_Asset__c = imsDataAssetList[0].Id;
        update dataAssetList;
        //obj.onAfterUpdate( dataAssetList );
        System.runAs(u) 
        {
            try{
                delete dataAssetList;
            }
            catch(Exception ex)
            {
                System.Assert(ex.getMessage().contains('You do not have necessary permissions to delete this TPA Data Asset record'));
            }
        }
        obj.afterMasterDataUpdate(newList, oldMap, newMap);
        
        oldList = new List<TPA_Data_Asset__c>();
        newList = new List<TPA_Data_Asset__c>();
        oldMap = new Map<Id,TPA_Data_Asset__c>();
        newMap = new Map<Id,TPA_Data_Asset__c>();
        objLegalEntity.Id = null;
        upsert objLegalEntity;
        TPA_Data_Asset__c dataAsset15 = UTL_TPA_SetupTestData.getTpaDataAsset(purposeList[10].Id);
        dataAsset15.Other_Text__c = 'Old Text';
        dataAsset15.Request__c = agreement1.Id;
        dataAsset15.IMSLegalEntity__c = objLegalEntity.Id;
        dataAsset15.Is_IMS_AGProduct__c = true;
        dataAsset15.hasXponentPlanTrak__c = true;
        dataAsset15.Data_Asset__c = imsDataAssetList[2].Id;
        dataAsset15.IMS_Legal_Entity_for_Other__c = 'IQVIA Solutions Canada Inc';
        insert dataAsset15;
        
        oldList.add(dataAsset15);
        oldMap.put(dataAsset15.id, dataAsset15);
        dataAsset15.Other_Text__c = 'Test Other Name';
        dataAsset15.Other_Text__c = 'Test Other';
        TPA_Data_Asset__c tempAsset = [select id, Other_Text__c, Request__c, Data_Asset__c,IMS_Legal_Entity_for_Other__c,Asset_NametText__c,BU__c,Asset_Name__c,IMSLegalEntity__c,purpose__c from TPA_Data_Asset__C where id =: dataAsset15.id];
        tempAsset.IMS_Legal_Entity_for_Other__c = 'IQVIA Solutions Canada Inc.';
        system.debug('tempAsset:::'+tempAsset);
        update tempAsset;
        newList.add(tempAsset);
        newMap.put(tempAsset.id, tempAsset);
        delete purposeDeleteList;
        test.stopTest();
    }
}