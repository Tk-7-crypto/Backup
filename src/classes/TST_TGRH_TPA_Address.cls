@isTest
public class TST_TGRH_TPA_Address { 
    private static testMethod void TGRH_TPA_Address() {
        
        List<Address__c> lstAdd = [Select id from Address__c where Primary_Vendor_Address__c = false];
        lstAdd[0].Vendor_Tier__c = 'N';
        lstAdd[0].Primary_Vendor_Address__c = true;
        update lstAdd[0];
    }
    
    @TestSetup static void setup() {
        Account acc = new Account(Name = 'Test Acc',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        
        List<Address__c> lst= new List<Address__c> ();
        Address__c testAddrs = new Address__c(Account__c = acc.Id, recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, Name = 'TPA Test Acc', CurrencyIsoCode = 'USD', Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Is_AMA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test', Primary_Vendor_Address__c = true);
        Address__c testAddrs1 = new Address__c(Account__c = acc.Id, recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, Name = 'TPA Test Acc1', CurrencyIsoCode = 'USD', Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9991, is_TPA_Account__c=true, Is_AMA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test', Primary_Vendor_Address__c = false);
        lst.add(testAddrs);
        lst.add(testAddrs1);
        insert lst;

        Address__c add1 = [Select id from Address__c where Primary_Vendor_Address__c = true];
        Address__c add2 = [Select id from Address__c where Primary_Vendor_Address__c = false];


        Watch_List__c watchObj1 = UTL_TPA_SetupTestData.createWatchList(add1.Id);
        watchObj1.Offering__c = 'Asset 1';
        watchObj1.Use__c = 'test purpose';
        watchObj1.Always_Approved__c = true; 
        insert watchObj1;
        Watch_List__c watchObj2 = UTL_TPA_SetupTestData.createWatchList(add2.Id);
        watchObj2.Offering__c = 'Asset 1';
        watchObj2.Use__c = 'test purpose';
        insert watchObj2;
        
        IMS_TPA_Purpose__c imsTpaPurpose = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name');
        TPA_Purpose_Category__c tpaPurposeCategory = UTL_TPA_SetupTestData.createTpaPurposeCategory('Expert Analysis');
        
        IMS_TPA_Purpose__c imsTpaPurpose1 = UTL_TPA_SetupTestData.createIMSTpaPurposeData('United States','test name1');
        IMS_Data_Asset__c imsDataAsset = UTL_TPA_SetupTestData.createImsDataAsset(true);
        
        
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = UTL_TPA_SetupTestData.createIMSSecondaryDataAsset(imsDataAsset, true ,'test');
        
        TPA_Text_Editor__c tpaUseDefinition1 = new TPA_Text_Editor__c(Page_Name__c = 'testOfferings', Content__c = 'Test Offerings Notification', Page_Title__c = imsDataAsset.Id, Page_Type__c = 'Tpa Offering Notifications');
        insert tpaUseDefinition1;
        
        TPA_Text_Editor__c tpaUseDefinition3 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 3', 'Notification_Content', 'TPA Offering Addendum');
        TPA_Text_Editor__c tpaUseDefinition4 = UTL_TPA_SetupTestData.createTpaTestEditorData('testOfferings', 'Test Offerings Notification 4', 'Notification_Content', 'TPA Offering Notifications');
        
        TPA_Offering_Notification_Mapping__c offNotObj = new TPA_Offering_Notification_Mapping__c(IMS_Primary_Data_Asset__c = imsDataAsset.Id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id,IMS_TPA_Purpose__c = imsTpaPurpose.id,TLLA_Additional_Terms__c = tpaUseDefinition3.id, IsActive__c = true,Country__c = 'United States');
        insert offNotObj;
        
        TPA_Off_Notification_Account_Mapping__c accmapObj1 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = add1.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj.id);
        insert accmapObj1;
        
        TPA_Off_Notification_Account_Mapping__c accmapObj2 = new TPA_Off_Notification_Account_Mapping__c(Vendor_Account_Address__c = add2.id, TPA_Offering_Notification_Mapping_Rule__c = offNotObj.id);
        insert accmapObj2;

        TPA_AMA_Client_Vendor_Search_Map__c searchMapObj = new TPA_AMA_Client_Vendor_Search_Map__c(AMA_Account_Search_Text__c = 'TPA Test Acc', TPA_Account_Address__c = add1.id);
        insert searchMapObj;

        TPA_AMA_Parent_Child_Account_Crosswalk__c parChildObj = new TPA_AMA_Parent_Child_Account_Crosswalk__c(Child_Account_Address__c = add2.id, Parent_Account_Address__c = add1.id);
        insert parChildObj;
		
        
    }
}
