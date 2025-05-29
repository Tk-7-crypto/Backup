/*
* Version       : 1.0
* Description   : Test data factory for PEP/PRM module project
*/
@isTest
public class TST_PEP_TestDataFactory
{
    private static Integer assetCount = 1;
    public static User createPartnerUser(String mail){            
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
               
        Account ac = TST_PEP_TestDataFactory.createAccount('Acme');
        ac.AccountCountry__c = 'BM' ;
        insert ac; 
    
        Contact con = new Contact(FirstName = 'TestFirstName', LastName ='testCon',AccountId = ac.Id,Email=mail);
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        insert con;  

        List<Product2> lstProd = new List<Product2>{
            new Product2(Name='OCE Sales', Pillar__c = 'Information Offering; Technology Solutions; R&D'),
            new Product2(Name='OCE Marketing', Pillar__c = 'Information Offering; Technology Solutions; R&D')
        };
        insert lstProd;

        List<Asset> lstAsset = new List<Asset>{
            createAsset('Asset '+ assetCount++,ac,lstProd[0],true),
            createAsset('Asset '+ assetCount++,ac,lstProd[1],true)
        };
        insert lstAsset;
        //Integer randomNumber = Integer.valueof((Math.random() * 10)); 
        User user = new User(alias = 'test123', email=mail,
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username=randomizeString('testUser')+'@iqviaTestPartner.com',
                             Change_Request_Description__c = 'test',
                             Change_Request_Ticket_Number__c ='test description',
                             EmployeeNumber = String.valueOf(System.currentTimeMillis())
                            );
                            
        return user ;
    }

    public static User createPartnerUserByAccount(String mail , Account acc){            
        Id prmProfileId = [select id from profile where name =: CON_PEP.S_P_PEP_COMMUNITY ].id;
    
     
        Contact con = new Contact(FirstName = 'TestFirstName', LastName ='testCon',AccountId = acc.id,Email=mail);
        con.Partner_Type__c = 'Integrator Partner; Data Partner';
        insert con;  

        List<Product2> lstProd = new List<Product2>{
            new Product2(Name='OCE Sales', Pillar__c = 'Information Offering; Technology Solutions; R&D'),
            new Product2(Name='OCE Marketing', Pillar__c = 'Information Offering; Technology Solutions; R&D')
        };
        insert lstProd;

        List<Asset> lstAsset = new List<Asset>{
            createAsset('Asset '+ assetCount++,acc,lstProd[0],true),
            createAsset('Asset '+ assetCount++,acc,lstProd[1],true)
        };
        insert lstAsset;

        User user = new User(alias = 'test123', email=mail,
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = prmProfileId, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username=randomizeString('testUser')+'@iqviaTestPartner.com', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
                            
        return user ;
    }

    public static String randomizeString(String name){        
        String charsForRandom = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 6) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), charsForRandom.length());
            randStr += charsForRandom.substring(idx, idx+1);
        }
        return name+randStr;
    }

    //get for system administrator profile id
    public static id getProfileAdminId(){
        return ([Select Id From Profile 
                Where name = 'Administrateur système' 
                    OR name = 'System Administrator'
                    OR name = 'Amministratore del sistema'
                    OR name = 'Systemadministrator'
                    OR name = 'Systemadministratör'
                    OR name = 'Administrador do sistema'
                    OR name = 'Systeembeheerder'
                    OR name = 'Systemadministrator'].Id);
    }

    //create admin user
    public static User createAdminUser(String name, String email){
        Id profId = getProfileAdminId();
        //Integer randomNumber = Integer.valueof((Math.random() * 10));
        return new User(
            Username = randomizeString(Name) +'@iqviaPartnerAdmin.com',
            LastName = 'AdminUser',
            FirstName = 'Test',
            Email = email,
            Alias = 'adm',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profId, 
            Change_Request_Description__c = 'test', 
            Change_Request_Ticket_Number__c ='test description',
            EmployeeNumber = String.valueOf(System.currentTimeMillis())
        );
    }

    public static Product2 createProduct(String name){
        return new Product2(Name=name, Pillar__c = 'Information Offering; Technology Solutions; R&D');
    }

    public static Asset createAsset(String name, Account acc, Product2 prod, Boolean visibleCSH){
        return new Asset(Name = name
            ,AccountId = acc.Id
            ,Product2Id=prod.Id
            ,Visible_in_CSH__c = visibleCSH
            ,Visible_in_LMS__c = true);
    }

    public static Learning_Path__c createLearningPath(String enrollmtId,String label,
                                    String pathURL, Product2 prod, Integer prog, User user){
        return new Learning_Path__c(
            Learning_Path_Enrollment_ID__c = randomizeString(enrollmtId),
            Learning_Path_Label__c = label,
            LMS_learning_path_URL__c = pathURL, 
            Product2ID__c = prod.Id,
            Progress__c = prog,
            Salesforce_User_ID__c = user.Id
        );
    }

    public static Certification__c createCertification(String certId,String label,
            Date certifDate, String pathName, String certifURL, Product2 prod, User user, String version){
        return new Certification__c(
            Certification_Id__c = randomizeString(certId),
            Certification_label__c = label,
            Certified_date__c = certifDate,
            Learning_path_Name__c = pathName,
            LMS_certification_URL__c = certifURL,
            Product2ID__c =prod.Id,
            Salesforce_User_ID__c = user.Id,
            Version__c = version
        );
    }

    public static Classroom_Course__c createClassroomCourse(String enrollmtId,String label,
           String dur , String status, Learning_Path__c learnPath, String courseURL, String add, Product2 prod, User user,
           Date schStart, Date schEnd){
        return new Classroom_Course__c(
            Classroom_enrollment_ID__c = randomizeString(enrollmtId),
            Classroom_label__c = label,
            Duration__c = dur,
            Enrollment_status__c = status,
            Learning_Path_ID__c = learnPath.Id,
            LMS_Classroom_Course_URL__c = courseURL,
            Location_address__c = add,
            Product2ID__c = prod.Id,
            Salesforce_User_ID__c = user.Id,
            Scheduled_start_date__c = schStart,
            Scheduled_end_date__c = schEnd
        );
    }

    public static AccountTeamMember createAccountTeamMember(Account ac, Id userId, String teamMemberRole) {
        return new AccountTeamMember(
            AccountId = ac.Id, 
            UserId = userId, 
            TeamMemberRole = teamMemberRole, 
            AccountAccessLevel = 'Edit');
    }
    
    public static Lead createLead (String email, String product,String company, String lname, String jTitle){
        Id prmLeadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_LED_RECORDTYPE).getRecordTypeId();
        return new Lead(
            RecordTypeId = prmLeadRecTypeId,
            Email = email,
            Status = 'Not Started',
            Product__c = product ,
            LeadSource = 'Partner Referral',
            Company = company,
            LastName = lname,
            FirstName='Test Name',
            Title = jTitle );
    }

    public static Announcement__c createAnnouncement(String subject, String status, String description, String parttype, String partRoles){
        return new Announcement__c(
            Subject__c =  subject,
            Description__c = description,
            Status__c = status,
            Partner_roles__c = partRoles,
            Partner_type__c = parttype
        );
    }
    
    public static Account createAccount(String name) {
       return new Account(
            Name = name,
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE'
       );
    }
    
    public static Targeted_Account_Announcement__c createTargetedAccountAnnouncement(String announcementId, String accountId) {
        return new Targeted_Account_Announcement__c(
            AnnouncementID__c = announcementId,
            AccountID__c = accountId
        );
    }
    
    public static Targeted_User_Announcement__c createTargetedUserAnnouncement(String announcementId, String userId) {
        return new Targeted_User_Announcement__c(
            AnnouncementID__c = announcementId,
            UserID__c = userId
        );
    }

    
    public static Contract createContract(String name, Id accId , Id prodId){
        Id prmCtrRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
        return new Contract(
            RecordTypeId = prmCtrRecTypeId
            ,Name = name
            ,AccountId = accId
            ,Status = null
            ,ContractTerm = 12
            ,SOW_status__c = 'Awaiting Signature'
            ,Payment_status__c = 'Payment Required'
            ,Product__c = prodId
         );
    }
    
     public static Contract createContract(String name, Id accId ){
        Id prmCtrRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(CON_PEP.S_PEP_CTR_RECORDTYPE).getRecordTypeId();
        return new Contract(
            RecordTypeId = prmCtrRecTypeId
            ,Name = name
            ,AccountId = accId
            ,Status = null
            ,ContractTerm = 12
            ,SOW_status__c = 'Awaiting Signature'
            ,Payment_status__c = 'Payment Required'
         );
    }

    public static Attachment createAttachment(String name, Id parentId){
        return new Attachment(Name = name
            ,ParentId = parentId
            ,Body = Blob.valueOf('Unit Test Attachment Body'));
    }

    public static PEP_DocuSign_credentials__c createCredentials(){
        return new PEP_DocuSign_credentials__c(
            AccountId__c = '968fe61e-bd8a-42ea-9b80-2c4e83062c85'
            ,UserId__c = 'rpoorun@fr.imshealth.com'
            ,Password__c = 'Visualforce01'
            ,IntegratorsKey__c = 'e7bb3f3f-ab15-4862-b0e0-64ad9fb9c74f'
            ,Domain_Name__c = 'https://devxgk-iqvia.cs17.force.com');
    }

    public static Agency_Program__c createAgencyProgram(Product2 prod){
        return new Agency_Program__c(Product__c = prod.Id
                                    ,Name = prod.Name
                                    ,Status__c = 'Inactive');
         
    }
    
    public static Contract_Template__c createContractTemplate(Agency_Program__c ap){
        return new Contract_Template__c ( Master__c = True
                                         ,Country__c = 'United States of America'
                                         ,TemplateID__c = '433d9867-fdc9-47cd-8e02-7015d01e7b2e'
                                         ,Agency_Program__c = ap.Id);
    }

    public static ContentVersion createContentVersion(){
        return new ContentVersion(
            Title = 'OceSalesCert',
            PathOnClient = 'OceSalesCert.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );

    }
    
    public static ContentDocumentLink createContentDocLink (Id LinkedEntityId){
        
        ContentVersion contentVersion = createContentVersion();
        insert contentVersion;  

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Title = 'OceSalesCert'];
        //create ContentDocumentLink  record 

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = LinkedEntityId;
        cdl.ContentDocumentId = documents[0].Id;
        
        return cdl;

    }
    
    public static EmailTemplate createEmailTemplate(String name, String developerName, String templateType){
        EmailTemplate testEmailTemplate = new EmailTemplate();
        testEmailTemplate.isActive = true;
        testEmailTemplate.Name = name;
        testEmailTemplate.DeveloperName = developerName;
        testEmailTemplate.TemplateType = templateType;
        return testEmailTemplate;
    }
    
    public static In_APP_Guidance__c createInAppGuidance(String pageName)
    {
        In_APP_Guidance__c testGuidance = new In_APP_Guidance__c();
        testGuidance.Name = pageName;
        testGuidance.Feature_Description__c = 'Test';
        testGuidance.IsActive__c = true;
        testGuidance.Expiration_Date__c = Date.newInstance(2099, 12, 9);
        return testGuidance;
    }

}