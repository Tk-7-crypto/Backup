@isTest
public  class TST_CLM_TestDataFactory {
    
    public static Apttus__APTS_Agreement__c createAgreement(Id recordTypeId,Boolean isInsert) {
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Apttus__Contract_Start_Date__c = Date.today();
        agreement.RecordTypeId = recordTypeId;
        if(recordTypeId == null){
            agreement.RecordTypeId = CON_CLM.PSA_RECORDTYPEID;
        }
        if(recordTypeId == CON_CLM.MSA_RECORDTYPEID || recordTypeId == CON_CLM.VENDOR_RECORDTYPEID
            || recordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID || recordTypeId == CON_CLM.PSA_RECORDTYPEID 
            || recordTypeId == CON_CLM.RWLP_RECORDTYPEID || recordTypeId == CON_CLM.AMA_RECORDTYPEID || recordTypeId == CON_CLM.GENERIC_RECORDTYPEID 
            || recordTypeId == CON_CLM.AMESA_RECORDTYPEID || recordTypeId == CON_CLM.OSA_RECORDTYPEID || recordTypeId == CON_CLM.RWS_RECORDTYPEID) {
            agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
            agreement.Apttus__Status__c = CON_CLM.REQUEST;
        }
        if(isInsert){
            insert agreement;
        }
        return agreement;
    }

    public static Agreement_Extension__c createAgreementExtension(Id agreementId,Boolean isInsert){
        Agreement_Extension__c agreementExtension = new Agreement_Extension__c();
        agreementExtension.Agreement__c =  agreementId;
        if(isInsert){
            insert agreementExtension;
        }
        return agreementExtension;

    }

    public static Document createDocument(Boolean isInsert) {
        Document doc = new Document();
        doc.body = Blob.valueOf('Unit Test Attachment Body');
        doc.AuthorId = UserInfo.getUserId();
        doc.FolderId = UserInfo.getUserId();
        doc.Name= 'Test doc';
        doc.ContentType= 'pdf';
        if(isInsert) {
            insert doc;
        }
        return doc;
    }   

    public static Attachment createAttachment(Id parentId, String attachmentName, Boolean isInsert) {
        Attachment attach = new Attachment();
        attach.Name = attachmentName;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.Body = bodyBlob;
        attach.ParentId = parentId;
        if(isInsert) {
            insert attach;
        }
        return attach;
    }

    public static ContentVersion createContentVersion(Boolean isInsert) {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        if(isInsert) {
            insert contentVersionInsert;
        }
        return contentVersionInsert;
    }

    public static Apttus__APTS_Template__c createAPTSTemplate(Boolean isInsert) {
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name='SCM Global Rapid SOW';
        template.Apttus__Language__c = 'English';
        template.Apttus__IsActive__c = true;
        template.Apttus__Agreement_Types__c = CON_CLM.PSA_RECORD_TYPE_NAME;
        template.Country__c = 'USA';
        template.Legal_Entities__c = CON_CLM.IQVIA_AG;
        if(isInsert){
            insert template;
        }
        return template;
    }

    public static Task createTask(Id whatId, Boolean isInsert){
        Task taskObj = UTL_TestData.createTask('test', whatId, 'open','normal');
        taskObj.OwnerId = UserInfo.getUserId();
        taskObj.Status = 'Not Started';
        if(isInsert)
            insert taskObj;
        return taskObj;
    }

    public static Template_Selection_Criteria__c createTemplateSelectionCriteria(String criteriaName, String templateName, String agreementType,String keyValue,Boolean isInsert){
        Template_Selection_Criteria__c templateSelection = new Template_Selection_Criteria__c();
        templateSelection.Name =  criteriaName;
        templateSelection.Template_Name__c = templateName;
        templateSelection.Key_Value__c =  keyValue;
        templateSelection.Template_Type__c =  agreementType;
        if(isInsert){
            insert templateSelection;
        }
        return templateSelection;
    }

    public static Apttus__APTS_Template__c createTemplate(String templateName, String agreementType, String contractLang, String recordTypeName, String country, String legalEntity, Boolean isInsert){
        Apttus__APTS_Template__c template = new Apttus__APTS_Template__c();
        template.Name =  templateName;
        template.Apttus__IsActive__c = true;
        template.Apttus__Agreement_Types__c = recordTypeName;
        template.Apttus__Language__c = contractLang;
        template.Apttus__Type__c = agreementType;
        template.Country__c = country;
        template.Apttus__IsActive__c = true;
        template.Legal_Entities__c = legalEntity;
        if(isInsert){
            insert template;
        }
        return template;
    }

    /**
     * This method used to insert Opportunity put Stage at your end
     * @params  Id accountId 
     * @return  Opportunity
     */
    public static Opportunity createOpportunity(Boolean isInsert) {
        Indication_List__c indication = new Indication_List__c(Name = 'Test Indication', Therapy_Area__c = 'Acute Care');
        insert indication;
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpportunity';
        opp.stageName = '7a. Closed Won';
        opp.CloseDate = System.today().addYears(1);
        opp.Probability = 10;
        opp.Budget_Available__c = 'Yes';
        opp.Contract_Start_Date__c = system.today();
        opp.Contract_End_Date__c = system.today().addYears(1);
        opp.LeadSource = 'Account Planning';
        opp.CurrencyIsoCode = 'USD';
        opp.Line_of_Business__c = 'Commercial Solutions';
        opp.Is_this_a_renewal__c = 'No';
        opp.Primary_Win_Reason__c ='Project Performance';
        opp.Win_Type__c = 'Non-competitive bid';
        opp.Is_this_IQVIA_Biotech__c = 'No';
        opp.Path_Probability__c = 'Potential';
        opp.Drug_Product_Name__c = 'Health Product';
        opp.Indication_List__c = indication.Id;
        opp.Potential_Competitor_1__c = comp.Id;
        if(isInsert) {
            insert opp;
        }
        return opp;
    }

    public static CLM_Configuration__c createClmConfigurationSetting(Boolean isInsert) {
        CLM_Configuration__c clmConfiguration = new CLM_Configuration__c();
        clmConfiguration.Responding_to_Redlining__c = 'https://test.example.com';
        clmConfiguration.orgWideEmailAddressId__c = null;
        if(isInsert) {
            insert clmConfiguration;
        }
        return clmConfiguration;
    }

    public static CLM_Docusign_Configuration__c createClmDocusignConfigurationSetting(Boolean isInsert) {
        CLM_Docusign_Configuration__c clmConfiguration = new CLM_Docusign_Configuration__c();
        clmConfiguration.Name = 'Test';
        clmConfiguration.SFS_Message__c = 'Please click on \'Review Document\' to proceed with the signature process.';
        clmConfiguration.SFS_Subject__c = '{Apttus__APTS_Agreement__c.Name} is ready for Signature';
        clmConfiguration.Expire_Void_Envelope__c = true;
        clmConfiguration.Days_before_Envelope_is_Expired_Voided__c = 1;
        clmConfiguration.Day_Prior_to_Warn_of_expiration__c = 1;
        clmConfiguration.Send_Reminder__c = true;
        clmConfiguration.Reminder_Interval__c = 1;
        clmConfiguration.Reminder_Repeat_Interval_in_Days__c = 1;
        if(isInsert) {
            insert clmConfiguration;
        }
        return clmConfiguration;
    }

    public static dsfs__DocuSign_Envelope__c createDocuSignEnvelope(Boolean isInsert, Id agreementId) {
        dsfs__DocuSign_Envelope__c envelope1 = new dsfs__DocuSign_Envelope__c();
        envelope1.dsfs__Source_Object__c = agreementId;
        envelope1.dsfs__DocuSign_Email_Subject__c = 'Test';
        if(isInsert) {
            insert envelope1;
        }
        return envelope1;
    }

    public static dsfs__DocuSign_Envelope_Document__c createDocuSignEnvelopeDocument(Boolean isInsert, Id envelopeID) {
        dsfs__DocuSign_Envelope_Document__c envelopeDocument = new dsfs__DocuSign_Envelope_Document__c();
        envelopeDocument.dsfs__Document_Name__c = 'Test Doc';
        envelopeDocument.dsfs__Attachment_Name__c = 'Test Attach';
        envelopeDocument.dsfs__DocuSign_EnvelopeID__c = envelopeID;
        envelopeDocument.dsfs__SFDocument_Type__c = 'Content';
        if(isInsert) {
            insert envelopeDocument;
        }
        return envelopeDocument;
    }

    public static dsfs__DocuSign_Status__c createDocuSignStatus(Boolean isInsert, Id envelopeId, Id agreementId) {
        dsfs__DocuSign_Status__c docusignStatus = new dsfs__DocuSign_Status__c();
        docusignStatus.Agreement__c = agreementId;
        docusignStatus.dsfs__DocuSign_Envelope_ID__c = envelopeId;
        docusignStatus.dsfs__Envelope_Status__c = 'Sent';
        if(isInsert) {
            insert docusignStatus;
        }
        return docusignStatus;
    }

    public static Address__c createAddress(Boolean isInsert) {
        Address__c addressObj = new Address__c();
        addressObj.Name = 'Test Address';
        if(isInsert) {
            insert addressObj;
        }
        return addressObj;
    }

    public static Agreement_Contacts__c createAgreementContact(Apttus__APTS_Agreement__c agreement, Boolean isInsert, String role) {
        Contact contactRec;
        if(role == 'Account') {
            List<Contact> contactRecList = new List<Contact>([SELECT FirstName, LastName, Email, EmployeeNumber__c FROM Contact WHERE Email='testcontactRec1@example.com' LIMIT 1]);
            if(contactRecList.isEmpty()) {
                contactRec = new Contact(FirstName='Test', LastName='Contact', Email='testcontactRec1@example.com', 
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId());
                insert contactRec;
            }
            else {
                contactRec = contactRecList[0];
            }
        }
        else if(role == 'Legal Entity 1' || role == 'Legal Entity 2' || role == 'Legal Entity 3') {
            List<Contact> contactRecList = new List<Contact>([SELECT FirstName, LastName, Email, EmployeeNumber__c FROM Contact WHERE Email='testcontactRec2@example.com' LIMIT 1]);
            if(contactRecList.isEmpty()) {
                contactRec = new Contact(FirstName='Test', LastName='Contact', Email='testcontactRec2@example.com', EmployeeNumber__c = '23',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IQVIA User Contact').getRecordTypeId());
                insert contactRec;
            }
            else {
                contactRec = contactRecList[0];
            }
        }
        Agreement_Contacts__c agreementContact = new Agreement_Contacts__c();
        agreementContact.Agreement__c = agreement.Id;
        agreementContact.Docusign_Role__c = role;
        agreementContact.Contact__c = contactRec.Id;
        if(role == 'Account'){
            agreementContact.Type__c = 'Contact';
        }
        else if(role == 'Legal Entity 1' || role == 'Legal Entity 2' || role == 'Legal Entity 3'){
            agreementContact.Type__c = 'IQVIA User Contact';
        }
        if(isInsert) {
            insert agreementContact;
        }
        return agreementContact;
    }

    public static Agreement_Contacts__c createAgreementContacts(Id agreementId, Boolean isInsert) {
        Agreement_Contacts__c agreementContact = new Agreement_Contacts__c();
        agreementContact.Agreement__c = agreementId;
        if(isInsert) {
            insert agreementContact;
        }
        return agreementContact;
    }

    public static dsfs__DocuSign_Envelope_Recipient__c createDocusignRecipient(dsfs__DocuSign_Envelope__c envelope, Boolean isInsert) {
        dsfs__DocuSign_Envelope_Recipient__c docusignRecipient = new dsfs__DocuSign_Envelope_Recipient__c();
        docusignRecipient.dsfs__DocuSign_Signer_Type__c = 'Signer';
        docusignRecipient.dsfs__DocuSign_EnvelopeID__c = envelope.Id;
        docusignRecipient.dsfs__Recipient_Email__c = 'abc@example.com';
        docusignRecipient.dsfs__DocuSign_Signature_Name__c = 'Test';
        docusignRecipient.dsfs__RoleValue__c = 1;
        if(isInsert) {
            insert docusignRecipient;
        }
        return docusignRecipient;
    }

    public static Apttus__Agreement_Clause__c createAgreementClause(Id agreementId, Boolean isInsert) {
        Apttus__Agreement_Clause__c agreementClause = new Apttus__Agreement_Clause__c();
        agreementClause.Apttus__Agreement__c = agreementId;
        if(isInsert) {
            insert agreementClause;
        }
        return agreementClause;
    }

    public static Apttus_Proposal__Proposal__c createProposalQuote(Boolean isInsert) {
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Proposal_Name__c = 'Test Proposal Quote';
        proposal.Select_Pricing_Tool__c = 'CPQ_UPT';
        if(isInsert) {
            insert proposal;
        }
        return proposal;
    }

    public static CLM_Field_Mappings__c createClmAgreementQuoteFieldMappingSetting(Boolean isInsert) {
        CLM_Field_Mappings__c agrQuoteFieldMapping = new CLM_Field_Mappings__c();
        agrQuoteFieldMapping.Name = '1';
        agrQuoteFieldMapping.Source_Field_API_Name__c = 'Select_Pricing_Tool__c';
        agrQuoteFieldMapping.Target_Field_API_Name__c = 'Select_Pricing_Tool__c';
        agrQuoteFieldMapping.Record_Type_Developer_Name__c = 'PSA';
        agrQuoteFieldMapping.Object_API_Name__c = 'Apttus__APTS_Agreement__c';
        if(isInsert) {
            insert agrQuoteFieldMapping;
        }
        return agrQuoteFieldMapping;
    }

    public static Account createAccount(String accountName, Boolean isInsert) {
        Account acc = new Account();
        acc.Name = accountName;
        acc.AccountCountry__c = 'IN';
        acc.CustomerSegment__c = 'GOVERNMENT';
        acc.Sub_Industry__c = 'STATE';
        if(isInsert) {
            insert acc;
        }
        return acc;
    }

    public static ContentVersion createContentVersionWithLink(Id parentId, String title){
        Blob blobData = Blob.valueOf('Unit Test Attachment Body');
        ContentVersion contentVersionRecord = new ContentVersion();
        contentVersionRecord.title = title;
        contentVersionRecord.PathOnClient = title;
        contentVersionRecord.IsMajorVersion = true;
        contentVersionRecord.VersionData = blobData;
        insert contentVersionRecord;

        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title =: title];

        ContentDocumentLink contentDocumentlink = new ContentDocumentLink();
        contentDocumentlink.ContentDocumentId = document.Id;
        contentDocumentlink.LinkedEntityId = parentId;
        insert contentDocumentlink;

        return contentVersionRecord;
    }

    public static Quote createQuote(String recordTypeName, Id opportunityId, Boolean isInsert) {
        Id recordTypeId =
            SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Quote testQuote = new Quote(Name = 'Test Quote');
        testQuote.OpportunityId = opportunityId;
        testQuote.RecordTypeId = recordTypeId;
        testQuote.Pricing_Tool__c = 'QIP Spreadsheet';
        testQuote.Type__c = 'CNF Quote';
        if(isInsert) {
            insert testQuote;
        }
        return testQuote;
    }

    public static Apttus_Proposal__Proposal__c setProposalData(String recordTypeName, Id opportunityId, String pricingTool, Id bidId, Boolean isInsert) {
        Id recordTypeId =
            SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'test proposal');
        testProposal.Apttus_Proposal__Opportunity__c = opportunityId;
        testProposal.RecordTypeId = recordTypeId;
        testProposal.Select_Pricing_Tool__c = pricingTool;
        testProposal.Clinical_Bid__c = bidId;
        testProposal.Scenario_Number__c = 123.0;
        testProposal.DTE_Study__c = CON_CPQ.YES_TITLE_CASE;
        testProposal.Scenario_Description__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        testProposal.Budget_Iteration__c = 1;
        testProposal.RFP_Scenario__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        testProposal.Apttus_Proposal__Primary__c = true;
        if(isInsert) {
            insert testProposal; 
        }
        return testProposal;
    }
    
    public static Bid_History__c createBidHistory(String recordTypeId, Id opportunityId, Boolean isInsert) {
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Bid_History__c newBid = new Bid_History__c();
        newBid.Bid_History_Related_Opportunity__c = opportunityId;
        newBid.RecordTypeId = recordTypeId;
        if(isInsert) {
            insert newBid;
        }
        return newBid;
    }

    public static IQVIA_Agreement__c createIQAgreement(Id recordTypeId,Boolean isInsert) {
        IQVIA_Agreement__c agreement = new IQVIA_Agreement__c();
        agreement.Contract_Start_Date__c = Date.today();
        agreement.RecordTypeId = recordTypeId;
        agreement.Status_Category__c = CON_CLM.REQUEST;
        agreement.Status__c = CON_CLM.REQUEST;
        
        if(isInsert){
            insert agreement;
        }
        return agreement;
    }

    public static IQVIA_Agreement_Team__c createIQAgreementContact(IQVIA_Agreement__c agreement, Boolean isInsert, String role) {
        Contact contactRec;
        if(role == 'Account') {
            List<Contact> contactRecList = new List<Contact>([SELECT FirstName, LastName, Email, EmployeeNumber__c FROM Contact WHERE Email='testcontactRec1@example.com' LIMIT 1]);
            if(contactRecList.isEmpty()) {
                contactRec = new Contact(FirstName='Test', LastName='Contact', Email='testcontactRec1@example.com', 
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId());
                insert contactRec;
            }
            else {
                contactRec = contactRecList[0];
            }
        }
        else if(role == 'Legal Entity 1' || role == 'Legal Entity 2' || role == 'Legal Entity 3') {
            List<Contact> contactRecList = new List<Contact>([SELECT FirstName, LastName, Email, EmployeeNumber__c FROM Contact WHERE Email='testcontactRec2@example.com' LIMIT 1]);
            if(contactRecList.isEmpty()) {
                contactRec = new Contact(FirstName='Test', LastName='Contact', Email='testcontactRec2@example.com', EmployeeNumber__c = '23',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IQVIA User Contact').getRecordTypeId());
                insert contactRec;
            }
            else {
                contactRec = contactRecList[0];
            }
        }
        IQVIA_Agreement_Team__c agreementTeam = new IQVIA_Agreement_Team__c();
        agreementTeam.Agreement__c = agreement.Id;
        agreementTeam.Docusign_Role__c = role;
        agreementTeam.Contact__c = contactRec.Id;
        if(role == 'Account'){
            agreementTeam.Type__c = 'Contact';
        }
        else if(role == 'Legal Entity 1' || role == 'Legal Entity 2' || role == 'Legal Entity 3'){
            agreementTeam.Type__c = 'IQVIA User Contact';
        }
        if(isInsert) {
            insert agreementTeam;
        }
        return agreementTeam;
    }
}