@isTest(SeeAllData=false)
public class TST_BCH_TPA_Permanent_Com_Owner_Email_Up {
    public static Date todayDate = System.now().date();
    @TestSetup 
    static void setup() {
	
        List<TPA_Assigned_TP_Processor__c> ownerList = new List<TPA_Assigned_TP_Processor__c>();
        List<IMS_Data_Asset__c> lstDataAsset = new List<IMS_Data_Asset__c>();
        IMS_Data_Asset__c dataAsset1 = new IMS_Data_Asset__c(Is_Active__c = true, Asset_Name__c = 'PrimaryDataAsset1', BU__c = 'United States',Geo_Level__c = 'Sub-National',Commercial_Owner_Email__c = 'test@tst1.com', Commercial_Manager_Name__c = 'TestName',IMS_Legal_Entity__c = 'IQVIA AG');
        IMS_Data_Asset__c dataAsset2 = new IMS_Data_Asset__c(Is_Active__c = true, Asset_Name__c = 'PrimaryDataAsset2', BU__c = 'United States',Geo_Level__c = 'Sub-National',Commercial_Owner_Email__c = 'test@tst1.com', Commercial_Manager_Name__c = 'TestName', IMS_Legal_Entity__c = 'IQVIA AG');
        IMS_Data_Asset__c dataAsset3 = new IMS_Data_Asset__c(Is_Active__c = true, Asset_Name__c = 'PrimaryDataAsset3', BU__c = 'United States',Geo_Level__c = 'National',Commercial_Owner_Email__c = 'test@tst1.com', Commercial_Manager_Name__c = 'TestName', IMS_Legal_Entity__c = 'IQVIA AG');
        lstDataAsset.add(dataAsset1);
        lstDataAsset.add(dataAsset2);
        lstDataAsset.add(dataAsset3);
        insert lstDataAsset;
		
		IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = dataAsset1.id, Geo_Level__c= 'Sub-National',Secondary_Asset_Name__c= 'secondaryasset',Commercial_Manager_Name__c='TestName',Commercial_Manager_Email__c= 'test@tst1.com',additional_terms_required__c = true, Is_Active__c = true);
        insert imsSecondaryDataAsset;
		
        

        
    }
    
    
    static testMethod void unitTest1() {
        TPA_Assigned_TP_Processor__c assignedTPProcessorObj = new TPA_Assigned_TP_Processor__c();
        assignedTPProcessorObj.Is_Permanent_Commercial_Owner__c = true;
        assignedTPProcessorObj.Commercial_Owner_Email__c = 'test@tst1.com';
        assignedTPProcessorObj.New_Permanent_Commercial_Owner_Full_Name__c = 'test123';
        assignedTPProcessorObj.New_Permanent_Commercial_Owner_Email__c = 'test@tst2.com';
        assignedTPProcessorObj.Action__c = 'transferowner';
        assignedTPProcessorObj.Effective_Date__c =  todayDate;
        assignedTPProcessorObj.Offering_Names__c = 'United States->National->PrimaryDataAsset3;United States->Sub-National->PrimaryDataAsset1->secondaryasset;';
        insert assignedTPProcessorObj;
        List<TPA_Assigned_TP_Processor__c> ownerList = [select id,Is_Permanent_Commercial_Owner__c,Effective_Date__c,Commercial_Owner_Email__c, New_Permanent_Commercial_Owner_Full_Name__c, New_Permanent_Commercial_Owner_Email__c, Offering_Names__c,Action__c from TPA_Assigned_TP_Processor__c ];
        List<IMS_Data_Asset__c> dataAssetListToUpdate = [Select Id,Asset_Name__c,BU__c,Geo_Level__c,Commercial_Owner_Email__c,Commercial_Manager_Name__c From IMS_Data_Asset__c where Is_Active__c = true];
        List<IMS_Secondary_Data_Asset__c> secDataAssetListToUpdate = [Select Id,Secondary_Asset_Name__c,Primary_Data_Asset__r.Asset_Name__c,Primary_Data_Asset__r.BU__c,Geo_Level__c,Commercial_Manager_Name__c,Commercial_Manager_Email__c From IMS_Secondary_Data_Asset__c where Is_Active__c = true];
        BCH_TPA_Permanent_Com_Owner_Email_Update bchObj = new BCH_TPA_Permanent_Com_Owner_Email_Update();
		Database.executeBatch(bchObj,1);
    }
    
    static testMethod void unitTest2() {
        TPA_Assigned_TP_Processor__c assignedTPProcessorObj = new TPA_Assigned_TP_Processor__c();
        assignedTPProcessorObj.Is_Permanent_Commercial_Owner__c = true;
        assignedTPProcessorObj.Commercial_Owner_Email__c = 'test@tst1.com';
        assignedTPProcessorObj.New_Permanent_Commercial_Owner_Full_Name__c = 'TestName';
        assignedTPProcessorObj.New_Permanent_Commercial_Owner_Email__c = 'test@tst1.com';
        assignedTPProcessorObj.Action__c = 'removeowner';
        assignedTPProcessorObj.Effective_Date__c =  todayDate;
        assignedTPProcessorObj.Offering_Names__c = 'United States->National->PrimaryDataAsset3;United States->Sub-National->PrimaryDataAsset1->secondaryasset;';
        insert assignedTPProcessorObj;
        List<TPA_Assigned_TP_Processor__c> ownerList = [select id,Is_Permanent_Commercial_Owner__c,Effective_Date__c,Commercial_Owner_Email__c, New_Permanent_Commercial_Owner_Full_Name__c, New_Permanent_Commercial_Owner_Email__c, Offering_Names__c,Action__c from TPA_Assigned_TP_Processor__c ];
        List<IMS_Data_Asset__c> dataAssetListToUpdate = [Select Id,Asset_Name__c,BU__c,Geo_Level__c,Commercial_Owner_Email__c,Commercial_Manager_Name__c From IMS_Data_Asset__c where Is_Active__c = true];
        List<IMS_Secondary_Data_Asset__c> secDataAssetListToUpdate = [Select Id,Secondary_Asset_Name__c,Primary_Data_Asset__r.Asset_Name__c,Primary_Data_Asset__r.BU__c,Geo_Level__c,Commercial_Manager_Name__c,Commercial_Manager_Email__c From IMS_Secondary_Data_Asset__c where Is_Active__c = true];
        BCH_TPA_Permanent_Com_Owner_Email_Update bchObj = new BCH_TPA_Permanent_Com_Owner_Email_Update();
		Database.executeBatch(bchObj,1);
    }
    
    static testMethod void unitTest3() {
        TPA_Assigned_TP_Processor__c assignedTPProcessorObj = new TPA_Assigned_TP_Processor__c();
        assignedTPProcessorObj.Is_Permanent_Commercial_Owner__c = true;
        assignedTPProcessorObj.Commercial_Owner_Email__c = 'test@tst1.com';
        assignedTPProcessorObj.New_Permanent_Commercial_Owner_Full_Name__c = 'TestName';
        assignedTPProcessorObj.New_Permanent_Commercial_Owner_Email__c = 'test@tst12.com';
        assignedTPProcessorObj.Action__c = 'addowner';
        assignedTPProcessorObj.Effective_Date__c =  todayDate;
        assignedTPProcessorObj.Offering_Names__c = 'United States->National->PrimaryDataAsset3;United States->Sub-National->PrimaryDataAsset1->secondaryasset;';
        insert assignedTPProcessorObj;
        List<TPA_Assigned_TP_Processor__c> ownerList = [select id,Is_Permanent_Commercial_Owner__c,Effective_Date__c,Commercial_Owner_Email__c, New_Permanent_Commercial_Owner_Full_Name__c, New_Permanent_Commercial_Owner_Email__c, Offering_Names__c,Action__c from TPA_Assigned_TP_Processor__c ];
        List<IMS_Data_Asset__c> dataAssetListToUpdate = [Select Id,Asset_Name__c,BU__c,Geo_Level__c,Commercial_Owner_Email__c,Commercial_Manager_Name__c From IMS_Data_Asset__c where Is_Active__c = true];
        List<IMS_Secondary_Data_Asset__c> secDataAssetListToUpdate = [Select Id,Secondary_Asset_Name__c,Primary_Data_Asset__r.Asset_Name__c,Primary_Data_Asset__r.BU__c,Geo_Level__c,Commercial_Manager_Name__c,Commercial_Manager_Email__c From IMS_Secondary_Data_Asset__c where Is_Active__c = true];
        BCH_TPA_Permanent_Com_Owner_Email_Update bchObj = new BCH_TPA_Permanent_Com_Owner_Email_Update();
		Database.executeBatch(bchObj,1);
    }
    

}
