/**
 * This test class is used to test all methods in CON_CSM.
 * version : 1.0
 */
@isTest
private class TST_CON_CSM {
    /**
     * This method is testing all constant in CON_CSM
     */
    static testMethod void testAllCSMConstant() {
        Test.startTest();
        String saccount = CON_CSM.S_ACCOUNT;
     String sasset  = CON_CSM.S_ASSET;
     String ActivityC = CON_CSM.S_ACTIVITYC;
     String s_Case = CON_CSM.S_CASE;
     String s_Contact = CON_CSM.S_CONTACT;
     String StudyC = CON_CSM.S_STUDYC;
     String s_Address = CON_CSM.S_ADDRESS;
     String MailingAddress = CON_CSM.S_MAILINGADDRESS;
     String BillingAddress = CON_CSM.S_BILLINGADDRESS;
     String Hierarchy = CON_CSM.S_HIERARCHY;
     String Id = CON_CSM.S_ID;
     String Name = CON_CSM.S_NAME;
     String CaseNumber = CON_CSM.S_CASENUM;
     String Edited = CON_CSM.S_EDITED;
     String Changed = CON_CSM.S_CHANGED;
     String Added = CON_CSM.S_ADDED;
     String Deleted = CON_CSM.S_DELETED;
     String Picklist = CON_CSM.S_PICKLIST;
     String Number_s = CON_CSM.S_NUMBER;
     String datetime_s = CON_CSM.S_DATETIME;
     String date_s = CON_CSM.S_DATE;
     String String_s = CON_CSM.S_STRING;
     String double_s = CON_CSM.S_DOUBLE;
     String Text = CON_CSM.S_TEXT;
     String Lookup = CON_CSM.S_LOOKUP;
     String Comments = CON_CSM.S_COMMENTS;
     String Created = CON_CSM.S_CREATED;
     String FieldsC = CON_CSM.S_FIELDSC;
    /* Used in EXT_CSM_CaseRelatedToObject*/ 
     String r = CON_CSM.S_R;
     String c = CON_CSM.S_C;
     String Parent = CON_CSM.S_PARENT;
     String SponsorR = CON_CSM.S_SPONSORR;
     String SupplierNameR = CON_CSM.S_SUPPLIERNAMER;
     String OnBehalfOfR = CON_CSM.S_ONBEHALFOFR;
     String ReportsTo = CON_CSM.S_REPORTSTO;
    /* Used in CNT_CSM_FieldHistoryTracking*/ 
     String comma = CON_CSM.S_COMMA;
     String quote = CON_CSM.S_QUOTE;
     String qCommaQ = CON_CSM.S_QCOMAQ;
     String QualifiedApiName = CON_CSM.S_QAPINAME;
     String MasterLabel = CON_CSM.S_MASTERLABEL;
     String Label = CON_CSM.S_LABEL;
     String DataType = CON_CSM.S_DATATYPE;
     String ValueTypeId = CON_CSM.S_VALUETYPEID;
     String ExtraTypeInfo = CON_CSM.S_EXTRATYPEINFO;
     String IsNameField = CON_CSM.S_ISNAMEFIELD;
     String IsFieldHistoryTracked = CON_CSM.S_ISFIELDHISTORYTRACKED;
     String RelationshipName = CON_CSM.S_RELATIONSHIPNAME;
     /* Address Fields in Contact*/
     String MailingState = CON_CSM.S_C_MSTATE;
     String MailingPostal_Code = CON_CSM.S_C_MPOSTALCODE;
     String MailingCountry = CON_CSM.S_C_MCOUNTRY;
     String MailingStreet = CON_CSM.S_C_MSTREET;
     String MailingCity = CON_CSM.S_C_MCITY;
    /* Address Fields in Account*/
     String BillingState = CON_CSM.S_A_BSTATE;
     String BillingPostal_Code = CON_CSM.S_A_BPOSTALCODE;
     String BillingCountry = CON_CSM.S_A_BCOUNTRY;
     String BillingStreet = CON_CSM.S_A_BSTREET;
     String BillingCity = CON_CSM.S_A_BCITY;
        Test.stopTest();
        System.assertEquals('Account', saccount);
        System.assertEquals('Asset', sasset);
    }
}