/*
* Version       : 1.0
* Description   : Utility Class for Creating Records in OWF
*/
public class UTL_OWF_TestData {
    /**
    * This method used to insert User List
    * @return  List<User>
    */
    public static List<User> createUser(String profileName, Integer noOfUser) {
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        for(Integer index = 0; index < noOfUser; index++) {
            userList.add(new User(
                ProfileId = profileId,
                LastName = 'lastName123',
                Email = 'testuser3133@iqvia.com',
                Username = 'testuser3133@imshealth.com' + System.currentTimeMillis() + index,
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alia3133',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Change_Request_Description__c = 'test',
                Change_Request_Ticket_Number__c ='test description',
                employeeNumber= '080808081'+index
            ));
        }
        return userList;
    }
    
    /**
    * This method used to insert Account
    * @return  Account
    */
    public static Account createAccount() {
        Trigger_Control_For_Migration__c setting = Trigger_Control_For_Migration__c.getOrgDefaults();
        upsert setting;
        return new Account(Name = 'TestAccount', BillingStreet = 'testStreet', BillingCity = 'testCity', BillingCountry = 'testCountry', BillingPostalCode = '123465',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
    }
    
    /**
    * This method used to insert Contact
    * @params  Id accountId
    * @return  Contact
    */
    public static Contact createContact(Id accountId) {
        Trigger_Control_For_Migration__c setting = Trigger_Control_For_Migration__c.getOrgDefaults();
        upsert setting;
        return new Contact(FirstName = 'TestFirstName', LastName = 'TestContact', accountId = accountId, email = 'test.' + System.currentTimeMillis() + '@iqvia.com');
    }
    
    /**
    * This method used to insert Opportunity
    * @params  Id accountId
    * @return  Opportunity
    */
    public static Opportunity createOpportunity(Id accountId) {
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Opportunity opp = new Opportunity(Name = 'TestOpportunity', 
				accountId = accountId, 
				Drug_Product_Name__c = 'Test Drug Classification',
				Global_project_unit__c = 'AA excluding Japan',
				Is_this_IQVIA_Biotech__c = 'Yes',
				Potential_Services__c = 'Vaccine Study',
				FSP__c = 'No',
				stageName = CON_CRM.IDENTIFYING_OPP_STAGE, 
				FPI_Date__c = system.today().addDays(5),
				Verbatim_Indication_Term__c = 'Test Verbatim Indication',
				Phase_P__c =  'Phase 1',
                Population_Age_Group__c = 'Preterm Infant born at <37 wks gestation',
				Indication_List__c = indication.Id,
				RFP_ReceivedDate__c = system.today(),
				CloseDate = System.today().addYears(1),
				Path_Probability__c = 'Advance to Potential',
				Probability = 10, 
				Line_Of_Business__c = 'Clinical',
				Pass_through_Expenses__c = 100);
        return opp;
    }
    
    /**
    * This method used to insert Apttus__APTS_Agreement__c
    * @return  Apttus__APTS_Agreement__c
    */
    public static Apttus__APTS_Agreement__c createAgreement(Id accountId, Id opportunityId) {
        Trigger_Control_For_Migration__c setting = Trigger_Control_For_Migration__c.getOrgDefaults();
        upsert setting;
        return new Apttus__APTS_Agreement__c(Name = 'TestAptsAgreement', Apttus__Account__c = accountId, Apttus__Related_Opportunity__c = opportunityId,LQ_Bid_Histroy_Id__c = 'Test Id', Apttus__Status_Category__c = CON_CLM.REQUEST, Apttus__Status__c = CON_CLM.REQUEST);
    }
    
    /**
    * This method used to insert Apttus__APTS_Agreement__c
    * @return  Apttus__APTS_Agreement__c
    */
    public static Apttus__APTS_Agreement__c createAgreementByRecordType(Id accountId, Id opportunityId, Id recordTypeId) {
        return new Apttus__APTS_Agreement__c(Name = 'TestAptsAgreement', Apttus__Account__c = accountId, Apttus__Related_Opportunity__c = opportunityId, 
            RecordTypeId = recordTypeId,LQ_Bid_Histroy_Id__c = ''+System.now().time());
    }
    
    /**
    * This method used to insert Bid_History__c
    * @return  Bid_History__c
    */
    public static Bid_History__c createBidHistoryByRecordType(Id accountId, Id opportunityId, Id recordTypeId){
        return new Bid_History__c(Name = 'TestBidHistory', Bid_History_Account__c = accountId, Bid_History_Related_Opportunity__c = opportunityId, 
            RecordTypeId = recordTypeId, Bid_Due_Date__c = system.today().addDays(3),LQ_Bid_Histroy_Id__c = ''+System.now().time(),Require_IQB_Services_Only__c=False,Requested_Services__c='Auditing and Compliance (Clinical)',Patient_Population__c='test',Unblinded_CVs_required__c='None',Is_PPT_Format_Required__c='No');
    }
    
    /**
    * This method used to insert Apttus__APTS_Agreement__c
    * @return  Apttus__APTS_Agreement__c
    */
    public static Bid_History__c createBidHistory(Id accountId, Id opportunityId) {
        Trigger_Control_For_Migration__c setting = Trigger_Control_For_Migration__c.getOrgDefaults();
        upsert setting;
        return new Bid_History__c(Name = 'TestAptsAgreement', Bid_History_Account__c = accountId, Bid_History_Related_Opportunity__c = opportunityId,LQ_Bid_Histroy_Id__c = 'Test Id',Require_IQB_Services_Only__c=False,Requested_Services__c='Auditing and Compliance (Clinical)',Patient_Population__c='test',Unblinded_CVs_required__c='None',Is_PPT_Format_Required__c='No');
    }
    
    /**
    * This method used to insert pse__Grp__c
    * @return pse__Grp__c
    */
    public static pse__Grp__c createGroup(){
        return  new pse__Grp__c( Name = 'TestGroup', CurrencyIsoCode = 'USD' );
    }
    
    /**
    * This method used to insert pse__Permission_Control__c
    * @return  pse__Permission_Control__c
    */
    public static pse__Permission_Control__c createPermissionControl(Contact con, pse__Practice__c practice, pse__Grp__c grp, pse__Region__c region){
        pse__Permission_Control__c perControl = new pse__Permission_Control__c();
        if(con != null){
            perControl.pse__Resource__c = con.Id;
        }
        else if(practice != null){
            perControl.pse__Practice__c =practice.Id;
        }
        else if(grp != null){
            perControl.pse__Group__c =grp.Id;
            List<OWF_Config__c> owfConfig = [Select id from OWF_Config__c limit 10];
            if(owfConfig.size() == 0){
                OWF_Config__c config = UTL_OWF_TestData.createOWFConfig(grp.Id);
                insert config;
            }
        }
        else if(region != null){
            perControl.pse__Region__c =region.Id;
        }
        perControl.pse__User__c = UserInfo.getUserId();
        perControl.pse__Cascading_Permission__c = true;
        perControl.pse__Resource_Request_Entry__c = true;
        perControl.pse__Skills_And_Certifications_Entry__c = true;
        perControl.pse__Skills_And_Certifications_View__c = true;
        perControl.pse__Staffing__c = true;
        perControl.CurrencyIsoCode = 'USD';
        return perControl;
    }
    
    /**
    * This method used to insert  OWF_Config__c
    * @return  OWF_Config__c
    */
    public static OWF_Config__c createOWFConfig(Id grpId) {
        return new OWF_Config__c(OWF_Standard_Group__c = grpId);
    }
    
    /**
    * This method used to insert pse__Proj__c
    * @return  pse__Proj__c
    */
    public static pse__Proj__c createBidProject(Id groupId){
        pse__Proj__c project = new pse__Proj__c();
        project.name = 'Bid Project';
        project.pse__Start_Date__c = system.today().addDays(-30);
        project.pse__End_Date__c = system.today().addDays(10); 
        project.pse__Group__c = groupId;
        project.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Bid').getRecordTypeId();
        return project;
    }
    
    /**
    * This method used to insert pse__Resource_Request__c
    * @return  pse__Resource_Request__c
    */
    public static pse__Resource_Request__c createResourceRequest(Id agreementId, Id opportunityId, Id projectId){
        return new pse__Resource_Request__c(Bid_History__c = agreementId, 
                                            pse__Opportunity__c = opportunityId, pse__Project__c = projectId,
                                            pse__Start_Date__c = Date.today(), 
                                            pse__End_Date__c = Date.today().addDays(10), pse__SOW_Hours__c = 20,
                                            subgroup__c = 'TSL-Japan',Is_Created_Automatically__c = true);
    }
    
    /**
    * This method used to insert pse__Resource_Request__c
    * @return  pse__Resource_Request__c
    */
    public static pse__Resource_Request__c createResourceRequestForBidHistory(Id bidHistoryId, Id opportunityId, Id projectId){
        return new pse__Resource_Request__c(Bid_History__c = bidHistoryId, 
                                            pse__Opportunity__c = opportunityId, pse__Project__c = projectId,
                                            pse__Start_Date__c = Date.today(), 
                                            pse__End_Date__c = Date.today().addDays(10), pse__SOW_Hours__c = 20,
                                            subgroup__c = 'TSL-Japan',Is_Created_Automatically__c = true);
    }
    
    /**
    * This method used to insert pse__Schedule__c
    * @return  pse__Schedule__c
    */
    public static pse__Schedule__c createSchedule(){
        return new pse__Schedule__c(pse__Start_Date__c = Date.today()-8,
                                    pse__End_Date__c = Date.today()+8);
    }
    
    /**
    * This method used to insert pse__Assignment__c
    * @return  pse__Assignment__c
    */
    public static pse__Assignment__c createAssignment(Id agreementId, Id projectId, Id scheduleId, Id resourceId, Id rrId){
        return new pse__Assignment__c(Name = 'Test OWF Assignment', Bid_History__c = AgreementId, pse__Project__c = projectId, pse__Schedule__c = scheduleId,
                                      pse__Resource__c = resourceId, pse__Resource_Request__c = rrId,  
                                      pse__Status__c = 'Pending', pse__Bill_Rate__c = 0 ,
                                      RecordTypeId = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId());
    }
    /**
    * This method used to insert pse__Assignment__c
    * @return  pse__Assignment__c
    */
    public static pse__Assignment__c createAssignmentForBidHistory(Id agreementId, Id projectId, Id scheduleId, Id resourceId, Id rrId){
        return new pse__Assignment__c(Name = 'Test OWF Assignment', Bid_History__c = AgreementId, pse__Project__c = projectId, pse__Schedule__c = scheduleId,
                                      pse__Resource__c = resourceId, pse__Resource_Request__c = rrId,  
                                      pse__Status__c = 'Pending', pse__Bill_Rate__c = 0 ,
                                      RecordTypeId = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId());
    }
    
    /**
    * This method used to insert OWF_Batch_Config__c
    * @return  OWF_Batch_Config__c
    */
    public static OWF_Batch_Config__c setupOWFBatchConfig(String processName){
        return new OWF_Batch_Config__c(Name = processName, Batch_Size__c = 10);
    }
    
    
    /**
    * This method used to insert OWF_Config__c
    * @return  OWF_Config__c
    */
    public static OWF_Config__c setupOWFConfig(Id grpId){
        return new OWF_Config__c(OWF_Standard_Group__c = grpId);
    }
    
    /**
    * This method used to insert pse__Skill__c
    * @return  pse__Skill__c
    */
    public static pse__Skill__c createSkills(String skillName, String type){
        return new pse__Skill__c(Name = skillName, pse__Type__c = type);
    }
    
    /**
    * This method used to insert pse__Resource_Skill_Request__c
    * @return  pse__Resource_Skill_Request__c
    */
    public static pse__Resource_Skill_Request__c createResourceSkillRequest(Id skillId, Id resorceRequestId){
        return new pse__Resource_Skill_Request__c(pse__Is_Primary__c= true, pse__Resource_Request__c = resorceRequestId, pse__Skill_Certification__c = skillId, pse__Minimum_Rating__c = '1 - Limited Exposure');
    }
    
    /**
    * This method used to insert pse__Skill_Certification_Rating__c
    * @return  pse__Skill_Certification_Rating__c
    */
    public static pse__Skill_Certification_Rating__c createSkillCertificationRating(Id skillId, Id resorceId){
        return new pse__Skill_Certification_Rating__c(pse__Resource__c = resorceId, pse__Skill_Certification__c = skillId, pse__Rating__c = '4 - Strong');
    }
    
    
    /**
    * This method used to insert Indication_List__c
    * @return  Indication_List__c
    */
    public static Indication_List__c createIndication(String indicationName, String therapyArea){
        return new Indication_List__c(Name = indicationName, Therapy_Area__c = therapyArea);
    }
    
    /**
    * This method used to insert Days_Off__c
    * @return  Days_Off__c
    */
    public static Days_Off__c createDaysOff(Id contactId){
        return new Days_Off__c(Employee__c = contactId, First_Day_Off__c = System.today(), Last_Day_Off__c = System.today().addDays(3));
    }
    
    
   /**
    * This method used to insert Investigator_Grant__c
    * @return  Investigator_Grant__c
    */
    public static Investigator_Grant__c createInvestigatorGrantByAgreementId(Id agreementId) {
        return new Investigator_Grant__c( Is_this_a_RWI_observational_study__c = 'No', Build_Type__c = 'Ballpark Build', Alt_Budget_required__c = 'No', Benchmark_Range__c = 'High Range');
    }
    
    /**
    * This method used to insert Investigator_Grant__c
    * @return  Investigator_Grant__c
    */
    public static Investigator_Grant__c createInvestigatorGrantByBidHistory(Id bidHistoryId) {
        return new Investigator_Grant__c( Is_this_a_RWI_observational_study__c = 'No', Build_Type__c = 'Ballpark Build', Alt_Budget_required__c = 'No', Benchmark_Range__c = 'High Range', Bid_History__c = bidHistoryId);
    }
    public static CollectionTool__c createCollectionTool(Id bidHistoryId , Id productId){
        return new CollectionTool__c(Site_Global__c='Indianapolis - ADME',
                                     ServiceLine__c = productId,
                                     Bid_History__c = bidHistoryId,
                                     Number_of_Sites__c = 2.00,
                                     Scenario_Number__c = 1.00,
                                     Biological_Matrix_Global__c='BAL - Bronchial alveolar lavage',
                                     Species_Global__c='Bovine',
                                     Type__c = 'BioSciences',
                                     Number_of_Analyte_Global__c='2'
                                    );
    }
    
}
