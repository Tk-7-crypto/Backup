/**
* @Author   :   Babita Dadarwal
* Purpose   :   Utility class for all TPA test classes for test data setup.
*/

@isTest
public class UTL_TPA_SetupTestData {
    public static Date todayDate = Date.today();

    //**************** Custom Settings **************//

    public static void createMultilingualTemplateSettingData() {
        String templateid = getTestEmailTemplateId();
        list<TPA_Multilingual_Template_Setting__c> setObjList = new list<TPA_Multilingual_Template_Setting__c>();

        TPA_Multilingual_Template_Setting__c obj1 = new TPA_Multilingual_Template_Setting__c(Name = 'Test1', label__c = 'TLLA', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj2 = new TPA_Multilingual_Template_Setting__c(Name = 'Test2', label__c = 'TLLA', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj3 = new TPA_Multilingual_Template_Setting__c(Name = 'Test3', label__c = 'SuppLangCode-FieldName-LocalName', Language__c = 'English', Translated_Template_Name__c = 'en_US=English~English_Translation__c~English', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj4 = new TPA_Multilingual_Template_Setting__c(Name = 'Test4', label__c = 'SuppLangCode-FieldName-LocalName', Language__c = 'Japanese', Translated_Template_Name__c = 'ja=Japanese~Japanese_Translation__c~???', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj5 = new TPA_Multilingual_Template_Setting__c(Name = 'Test5', label__c = 'Use Definition Template', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj6 = new TPA_Multilingual_Template_Setting__c(Name = 'Test6', label__c = 'Use Definition Template', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj7 = new TPA_Multilingual_Template_Setting__c(Name = 'Test7', label__c = 'Email Agreement for signature', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj8 = new TPA_Multilingual_Template_Setting__c(Name = 'Test8', label__c = 'Email Agreement for signature', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
 
        TPA_Multilingual_Template_Setting__c obj9 = new TPA_Multilingual_Template_Setting__c(Name = 'Test9', label__c = 'Client Courtesy Renew', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj10 = new TPA_Multilingual_Template_Setting__c(Name = 'Test10', label__c = 'Client Courtesy Renew', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj11 = new TPA_Multilingual_Template_Setting__c(Name = 'Test11', label__c ='Email FollowUp of Ack DD', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj14 = new TPA_Multilingual_Template_Setting__c(Name = 'Test14', label__c ='Email FollowUp of Ack DD', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj12 = new TPA_Multilingual_Template_Setting__c(Name = 'Test12', label__c ='Email 3Day Notice of Ack DD', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj15 = new TPA_Multilingual_Template_Setting__c(Name = 'Test15', label__c ='Email 3Day Notice of Ack DD', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj13 = new TPA_Multilingual_Template_Setting__c(Name = 'Test13', label__c ='Email Ack of DD', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj16 = new TPA_Multilingual_Template_Setting__c(Name = 'Test16', label__c ='Email Ack of DD', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        
        TPA_Multilingual_Template_Setting__c obj17 = new TPA_Multilingual_Template_Setting__c(Name = 'Test17', label__c ='Accnt on Hold Due To Fail DD', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj18 = new TPA_Multilingual_Template_Setting__c(Name = 'Test18', label__c ='Accnt on Hold Due To Fail DD', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj23= new TPA_Multilingual_Template_Setting__c(Name = 'Test23', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Language__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj24= new TPA_Multilingual_Template_Setting__c(Name = 'Test24', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Record_Localized_For__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj25= new TPA_Multilingual_Template_Setting__c(Name = 'Test25', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Tpa_Agreement__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj26= new TPA_Multilingual_Template_Setting__c(Name = 'Test26', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Tpa_Request__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj27= new TPA_Multilingual_Template_Setting__c(Name = 'Test27', label__c ='fieldsPopulateDynam', Language__c = '', Translated_Template_Name__c = 'Data_Asset_List__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj28= new TPA_Multilingual_Template_Setting__c(Name = 'Test28', label__c ='fieldsPopulateDynam', Language__c = '', Translated_Template_Name__c = 'List_Of_Uses__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj29= new TPA_Multilingual_Template_Setting__c(Name = 'Test29', label__c ='fieldsPopulateDynam', Language__c = '', Translated_Template_Name__c = 'Offerings_With_Category__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj30= new TPA_Multilingual_Template_Setting__c(Name = 'Test30', label__c ='fieldsPopulateDynam', Language__c = '', Translated_Template_Name__c = 'PurposeWithDataAsset__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj31= new TPA_Multilingual_Template_Setting__c(Name = 'Test31', label__c ='fieldsPopulateDynam', Language__c = '', Translated_Template_Name__c = 'PurposeWithOfferings__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj32= new TPA_Multilingual_Template_Setting__c(Name = 'Test32', label__c ='fieldsPopulateDynam', Language__c = '', Translated_Template_Name__c = 'TPA_Purpose_Picklist_Apttus__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj33= new TPA_Multilingual_Template_Setting__c(Name = 'Test33', label__c ='Multi Select Picklist With Comma', Language__c = '', Translated_Template_Name__c = 'Employee_Accessing_Data_Location_Values__c=Employee_Accessing_Data_Location__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj34= new TPA_Multilingual_Template_Setting__c(Name = 'Test34', label__c ='Multi Select Picklist With Comma', Language__c = '', Translated_Template_Name__c = 'IMS_Data_Country_Location_Values__c=IMS_Data_Country_Location__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj35= new TPA_Multilingual_Template_Setting__c(Name = 'Test35', label__c ='MultiSelect Picklist To Translate', Language__c = '', Translated_Template_Name__c = 'Employee_Accessing_Data_Location__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj36= new TPA_Multilingual_Template_Setting__c(Name = 'Test36', label__c ='MultiSelect Picklist To Translate', Language__c = '', Translated_Template_Name__c = 'IMS_Data_Country_Location__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj37= new TPA_Multilingual_Template_Setting__c(Name = 'Test37', label__c ='SuppLangCode-FieldName-LocalName', Language__c = '', Translated_Template_Name__c = 'ja=Japanese~Japanese_Translation__c~???', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj38= new TPA_Multilingual_Template_Setting__c(Name = 'Test38', label__c ='SuppLangCode-FieldName-LocalName', Language__c = '', Translated_Template_Name__c = 'en_US=English~English_Translation__c~English', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj39= new TPA_Multilingual_Template_Setting__c(Name = 'Test39', label__c ='SupportedLanguageCodeFieldMap', Language__c = 'English', Translated_Template_Name__c = 'en_US=English~English_Translation__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj40= new TPA_Multilingual_Template_Setting__c(Name = 'Test40', label__c ='SupportedLanguageCodeFieldMap', Language__c = 'Japanese', Translated_Template_Name__c = 'ja=Japanese~Japanese_Translation__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj41= new TPA_Multilingual_Template_Setting__c(Name = 'Test41', label__c ='Email Week Reminder V Sub', Language__c = 'Japanese', Translated_Template_Name__c = 'ja=Japanese~Japanese_Translation__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj42= new TPA_Multilingual_Template_Setting__c(Name = 'Test42', label__c ='Email Week Reminder V Sign', Language__c = 'Japanese', Translated_Template_Name__c = 'ja=Japanese~Japanese_Translation__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj43= new TPA_Multilingual_Template_Setting__c(Name = 'Test43', label__c ='Email Reminder of New Request', Language__c = 'Japanese', Translated_Template_Name__c = 'ja=Japanese~Japanese_Translation__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj44= new TPA_Multilingual_Template_Setting__c(Name = 'Test44', label__c ='Compliance Program Doc', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj45= new TPA_Multilingual_Template_Setting__c(Name = 'Test45', label__c ='Compliance Program Doc', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj46= new TPA_Multilingual_Template_Setting__c(Name = 'Test46', label__c ='Std T&C Doc', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj47= new TPA_Multilingual_Template_Setting__c(Name = 'Test47', label__c ='Std T&C Doc', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj48= new TPA_Multilingual_Template_Setting__c(Name = 'Test48', label__c ='Restricted Data Security Doc', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj49= new TPA_Multilingual_Template_Setting__c(Name = 'Test49', label__c ='Restricted Data Security Doc', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj50= new TPA_Multilingual_Template_Setting__c(Name = 'Test50', label__c ='Apttus Purpose MultiPicklist', Language__c = 'English', Translated_Template_Name__c = 'TPA_Purpose_Picklist_Apttus__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj51= new TPA_Multilingual_Template_Setting__c(Name = 'Test51', label__c ='Apttus Purpose MultiPicklist', Language__c = 'Japanese', Translated_Template_Name__c = 'TPA_Purpose_Picklist_Apttus_Ja__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj52= new TPA_Multilingual_Template_Setting__c(Name = 'Test52', label__c ='Email Business Rule', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj53= new TPA_Multilingual_Template_Setting__c(Name = 'Test53', label__c ='Email Business Rule', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj54 = new TPA_Multilingual_Template_Setting__c(Name = 'Test54', label__c = 'Email Pre Cancellation Sub', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj55 = new TPA_Multilingual_Template_Setting__c(Name = 'Test55', label__c = 'Email Pre Cancellation Sub', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj56 = new TPA_Multilingual_Template_Setting__c(Name = 'Test56', label__c = 'Email Pre Cancellation Sign', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj57 = new TPA_Multilingual_Template_Setting__c(Name = 'Test57', label__c = 'Email Pre Cancellation Sign', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj58 = new TPA_Multilingual_Template_Setting__c(Name = 'Test58', label__c = 'Email Post Cancellation Sub', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj59 = new TPA_Multilingual_Template_Setting__c(Name = 'Test59', label__c = 'Email Post Cancellation Sub', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj60 = new TPA_Multilingual_Template_Setting__c(Name = 'Test60', label__c = 'Email Post Cancellation Sign', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj61 = new TPA_Multilingual_Template_Setting__c(Name = 'Test61', label__c = 'Email Post Cancellation Sign', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj62 = new TPA_Multilingual_Template_Setting__c(Name='SuppLangCode-FieldName-LocalName2',Label__c = 'SuppLangCode-FieldName-LocalName', Translated_Template_Name__c = 'en_US=English~English_Translation__c~English');

        TPA_Multilingual_Template_Setting__c obj63 = new TPA_Multilingual_Template_Setting__c(Name = 'Test63', label__c = 'Email Data Release Vendor', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj64 = new TPA_Multilingual_Template_Setting__c(Name = 'Test64', label__c = 'Email Data Release Vendor', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj65 = new TPA_Multilingual_Template_Setting__c(Name = 'Test65', label__c = 'Email Agreement for signature', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj66 = new TPA_Multilingual_Template_Setting__c(Name = 'Test66', label__c = 'Email Agreement for signature', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj67 = new TPA_Multilingual_Template_Setting__c(Name = 'Test67', label__c = 'Email Data Release Client', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj68 = new TPA_Multilingual_Template_Setting__c(Name = 'Test68', label__c = 'Email Data Release Client', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj69 = new TPA_Multilingual_Template_Setting__c(Name = 'Test69', label__c = 'Email Renewal Noti Client', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj70 = new TPA_Multilingual_Template_Setting__c(Name = 'Test70', label__c = 'Email Renewal Noti Client', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj71 = new TPA_Multilingual_Template_Setting__c(Name = 'Test71', label__c = 'Email Pending Expiration', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj72 = new TPA_Multilingual_Template_Setting__c(Name = 'Test72', label__c = 'Email Pending Expiration', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj73 = new TPA_Multilingual_Template_Setting__c(Name = 'Test73', label__c = 'Email Post Expiration', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj74 = new TPA_Multilingual_Template_Setting__c(Name = 'Test74', label__c = 'Email Post Expiration', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj75 = new TPA_Multilingual_Template_Setting__c( Name = 'Test75', Translated_Template_Id__c = '95E7F69B-6828-4A8B-93B9-20E73F2CE4DC', label__c = 'Docusign Template');
        TPA_Multilingual_Template_Setting__c obj76= new TPA_Multilingual_Template_Setting__c(Name = 'Test76', label__c ='In Draft Request Deletion Template ID', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj77= new TPA_Multilingual_Template_Setting__c(Name = 'Test77', label__c ='In Draft Request Deletion Template ID', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj78 = new TPA_Multilingual_Template_Setting__c(Name = 'Test78', label__c = 'Email DS Envelope Declined', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj79 = new TPA_Multilingual_Template_Setting__c(Name = 'Test79', label__c = 'Email DS Envelope Declined', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj80 = new TPA_Multilingual_Template_Setting__c(Name = 'Email V Registration Number English', Label__c = 'Email V Registration Number', Language__c = 'English', Translated_Template_Id__c = templateid, Translated_Template_Name__c = 'Vendor Registration Number Notification');
        TPA_Multilingual_Template_Setting__c obj81 = new TPA_Multilingual_Template_Setting__c(Name = 'Email New and Edited Request English', Label__c = 'Email New and Edited Request', Language__c = 'English', Translated_Template_Id__c = templateid, Translated_Template_Name__c = 'Vendor Template To Update TPLLM');
        TPA_Multilingual_Template_Setting__c obj82 = new TPA_Multilingual_Template_Setting__c(Name = 'Email CompetitiveServices English', Label__c = 'Email CompetitiveServices', Language__c = 'English', Translated_Template_Id__c = templateid, Translated_Template_Name__c = 'Vendor Registration Number Notification');
        TPA_Multilingual_Template_Setting__c obj83 = new TPA_Multilingual_Template_Setting__c(Name = 'Client Submission Renew English', Label__c = 'Client Submission Renew', Language__c = 'English', Translated_Template_Id__c = '');
        
        TPA_Multilingual_Template_Setting__c obj84 = new TPA_Multilingual_Template_Setting__c(Name = 'VSN Cancelation Confirmation English', Label__c = 'VSN Cancelation Confirmation', Language__c = 'English', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj85 = new TPA_Multilingual_Template_Setting__c(Name = 'VSN TP Processor Notification English', Label__c = 'VSN TP Processor Notification', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj86 = new TPA_Multilingual_Template_Setting__c(Name = 'Direct To Client', Label__c = 'Direct To Client:LAAD Response to TPUS', Language__c = 'English', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj87 = new TPA_Multilingual_Template_Setting__c(Name = 'DirectToClient_LAAD', Label__c = 'DirectToClient_LAAD_Ques_Compliance_Temp__c', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj88 = new TPA_Multilingual_Template_Setting__c(Name = 'VSN TPProcessor', Label__c = 'VSN TPProcessor Sales Communication Result', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj89 = new TPA_Multilingual_Template_Setting__c(Name = 'VSN Client Contact', Label__c = 'VSN Client Contact Notification', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj90= new TPA_Multilingual_Template_Setting__c(Name = 'Test90', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Legacy_Id__c', Translated_Template_Id__c = '');

        TPA_Multilingual_Template_Setting__c obj91 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 1', Label__c = 'Email Helpful Hint 1', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj92 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 2', Label__c = 'Email Helpful Hint 2', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj93 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 3', Label__c = 'Email Helpful Hint 3', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj94 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 4', Label__c = 'Email Helpful Hint 4', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj95 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 5', Label__c = 'Email Helpful Hint 5', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj96 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 6', Label__c = 'Email Helpful Hint 6', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj97 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 7', Label__c = 'Email Helpful Hint 7', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj98 = new TPA_Multilingual_Template_Setting__c(Name = 'Email Helpful Hint 8', Label__c = 'Email Helpful Hint 8', Language__c = 'English', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj99= new TPA_Multilingual_Template_Setting__c(Name = 'Test99', label__c ='Email Pending Vendor Response on DDN', Language__c = 'English', Translated_Template_Id__c = templateid);
		
        TPA_Multilingual_Template_Setting__c obj100= new TPA_Multilingual_Template_Setting__c(Name = 'Test100', label__c ='Email TPA Request on Hold', Language__c = 'English', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj101 = new TPA_Multilingual_Template_Setting__c(Name = 'Test101', label__c ='Pending TPA Request Report', Language__c = 'English', Translated_Template_Id__c = templateid);
		TPA_Multilingual_Template_Setting__c obj102 = new TPA_Multilingual_Template_Setting__c(Name = 'Test102', label__c ='TPA Send Pending TPA Request Report', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj103 = new TPA_Multilingual_Template_Setting__c(Name = 'Test103', label__c ='Email Country Offering Workbook Report', Language__c = 'English', Translated_Template_Id__c = templateid);


        TPA_Multilingual_Template_Setting__c obj104 = new TPA_Multilingual_Template_Setting__c(Name = 'Test104', label__c ='Email AMA DDN Acknowledgment Notice', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj105 = new TPA_Multilingual_Template_Setting__c(Name = 'Test105', label__c ='Email Vendor Renewal Noti Old', Language__c = 'English', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj106 = new TPA_Multilingual_Template_Setting__c(Name = 'Test106', label__c ='Email Vendor Renewal Notification', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj107 = new TPA_Multilingual_Template_Setting__c(Name = 'Test107', label__c ='Email CompetitiveServices', Language__c = 'English', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj108 = new TPA_Multilingual_Template_Setting__c(Name = 'Test108', label__c ='In Draft Request Closed Template ID', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj109 = new TPA_Multilingual_Template_Setting__c(Name = 'Test109', label__c ='In Draft Request Closed Template ID', Language__c = 'Japanese', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj110 = new TPA_Multilingual_Template_Setting__c(Name = 'Test110', label__c ='Email Discontinue Offering Sharing', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj111 = new TPA_Multilingual_Template_Setting__c(Name = 'Test111', label__c ='Email Discontinue Offering Sharing', Language__c = 'Japanese', Translated_Template_Id__c = templateid);
        
        TPA_Multilingual_Template_Setting__c obj112= new TPA_Multilingual_Template_Setting__c(Name = 'Test112', label__c ='Email Reminder Vendor Response on DDN', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj113= new TPA_Multilingual_Template_Setting__c(Name = 'Test113', label__c ='Compliance Hold Res Legal', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj114= new TPA_Multilingual_Template_Setting__c(Name = 'Test114', label__c ='Email Pending on DDN Signature to Hold', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj115= new TPA_Multilingual_Template_Setting__c(Name = 'Test115', label__c ='Email to Response Commercial Owners', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj116= new TPA_Multilingual_Template_Setting__c(Name = 'Test116', label__c ='Email to Response TP Processors', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj117= new TPA_Multilingual_Template_Setting__c(Name = 'Test117', label__c ='Email to Tp Processor removal of Compliance Hold', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj118= new TPA_Multilingual_Template_Setting__c(Name = 'Test118', label__c ='Email to notify commercial owner', Language__c = 'English', Translated_Template_Id__c = templateid);
		TPA_Multilingual_Template_Setting__c obj119= new TPA_Multilingual_Template_Setting__c(Name = 'Test119', label__c ='Email to notify TP Processor', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj120= new TPA_Multilingual_Template_Setting__c(Name = 'Test120', label__c ='Email to Client IQVIA Aisle off', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj121= new TPA_Multilingual_Template_Setting__c(Name = 'Test121', label__c ='Reminder to TP Pro of Void', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj122= new TPA_Multilingual_Template_Setting__c(Name = 'Test122', label__c ='TPA Cancel Email', Language__c = 'English', Translated_Template_Id__c = templateid);
		TPA_Multilingual_Template_Setting__c obj123= new TPA_Multilingual_Template_Setting__c(Name = 'Test123', label__c ='Email Direct to Client message', Language__c = 'English', Translated_Template_Id__c = templateid);
		TPA_Multilingual_Template_Setting__c obj124= new TPA_Multilingual_Template_Setting__c(Name = 'Test124', label__c ='Email Direct to Client Offering', Language__c = 'English', Translated_Template_Id__c = templateid);
		TPA_Multilingual_Template_Setting__c obj125= new TPA_Multilingual_Template_Setting__c(Name = 'Test125', label__c ='Email TPA Request on Hold', Language__c = 'Japanese', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj126= new TPA_Multilingual_Template_Setting__c(Name = 'Test126', label__c ='Apttus Purpose MultiPicklist', Language__c = 'French', Translated_Template_Name__c = 'TPA_Purpose_Picklist_Apttus_Ja__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj127= new TPA_Multilingual_Template_Setting__c(Name = 'Test127', label__c ='Billing Adderss Missing No TLLA', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj128= new TPA_Multilingual_Template_Setting__c(Name = 'Test128', label__c ='TPA DDN Partial Modify Email', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj129= new TPA_Multilingual_Template_Setting__c(Name = 'Test129', label__c ='TPA DDN Partial Modify Email', Language__c = 'Japanese', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj130= new TPA_Multilingual_Template_Setting__c(Name = 'Test130', label__c ='Email for 50 Or More Licenses', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj131= new TPA_Multilingual_Template_Setting__c(Name = 'Test131', label__c ='Weekday Draft Reminder Mail', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj132= new TPA_Multilingual_Template_Setting__c(Name = 'Test132', label__c ='GSTIN / VAT number Invoice Mail', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj133= new TPA_Multilingual_Template_Setting__c(Name = 'Test133', label__c ='In Client Draft Notification', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj134= new TPA_Multilingual_Template_Setting__c(Name = 'Test134', label__c ='In Draft Request Closed Template ID', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj135 = new TPA_Multilingual_Template_Setting__c(Name = 'Test135', label__c ='Confirmation of Comm Owner Temp Change', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj136 = new TPA_Multilingual_Template_Setting__c(Name = 'Test136', label__c ='Temp Comm Owner Expiration email', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj137 = new TPA_Multilingual_Template_Setting__c(Name = 'Test137', label__c ='Email to Vendor Secure Tech of Other', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj138 = new TPA_Multilingual_Template_Setting__c(Name = 'Test138', label__c ='TPA Certification email', Language__c = 'English', Translated_Template_Id__c = templateid);

        TPA_Multilingual_Template_Setting__c obj139= new TPA_Multilingual_Template_Setting__c(Name = 'Test139', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Project_include_directToPrescriberComm__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj140= new TPA_Multilingual_Template_Setting__c(Name = 'Test140', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'IMS_Data_Physical_Location__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj141= new TPA_Multilingual_Template_Setting__c(Name = 'Test141', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'IMS_Data_Physical_Location_Other__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj142= new TPA_Multilingual_Template_Setting__c(Name = 'Test142', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'IMS_Data_Country_Location__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj143= new TPA_Multilingual_Template_Setting__c(Name = 'Test143', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'IMS_Data_Country_Location_Values__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj144= new TPA_Multilingual_Template_Setting__c(Name = 'Test144', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Employee_Accessing_Data_Location__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj145= new TPA_Multilingual_Template_Setting__c(Name = 'Test145', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Employee_Accessing_Data_Location_Values__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj146= new TPA_Multilingual_Template_Setting__c(Name = 'Test146', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Data_Delivered_By__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj147= new TPA_Multilingual_Template_Setting__c(Name = 'Test147', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Data_Asset_List__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj148= new TPA_Multilingual_Template_Setting__c(Name = 'Test148', label__c ='FieldsAsException', Language__c = '', Translated_Template_Name__c = 'Client_Region__c', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj149= new TPA_Multilingual_Template_Setting__c(Name = 'Test149', label__c ='VSN Client Contact Acknowledgement Email', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj150= new TPA_Multilingual_Template_Setting__c(Name = 'Test150', label__c ='For Your Records Mail on Offering Deletion', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj151 = new TPA_Multilingual_Template_Setting__c(Name = 'Test151', label__c ='Email Client Confirm Response', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj152 = new TPA_Multilingual_Template_Setting__c(Name = 'Test152', label__c ='Email Confirm Response to TPUS', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj153 = new TPA_Multilingual_Template_Setting__c(Name = 'Test153', label__c ='Email Client Confirmation Req', Language__c = 'English', Translated_Template_Id__c = templateid);
        TPA_Multilingual_Template_Setting__c obj154= new TPA_Multilingual_Template_Setting__c(Name = 'Test154', label__c ='Early Expiry Confirmation Email', Language__c = 'English', Translated_Template_Id__c = templateid); 
        TPA_Multilingual_Template_Setting__c obj155= new TPA_Multilingual_Template_Setting__c(Name = 'Test155', label__c ='Early Expiry Confirmation AMA Email', Language__c = 'English', Translated_Template_Id__c = templateid); 

        TPA_Multilingual_Template_Setting__c obj156 = new TPA_Multilingual_Template_Setting__c(Name = 'Test166', label__c = 'TLLA Before April', Language__c = 'English', Translated_Template_Name__c = '', Translated_Template_Id__c = '');
        TPA_Multilingual_Template_Setting__c obj157 = new TPA_Multilingual_Template_Setting__c(Name = 'Test167', label__c = 'TLLA Before April', Language__c = 'Japanese', Translated_Template_Name__c = '', Translated_Template_Id__c = '');


        
        setObjList.add(obj1); 
        setObjList.add(obj2);
        setObjList.add(obj3);
        setObjList.add(obj4);
        setObjList.add(obj5);
        setObjList.add(obj6);
        setObjList.add(obj7);
        setObjList.add(obj8);
        setObjList.add(obj9);
        setObjList.add(obj10);
        setObjList.add(obj11);
        setObjList.add(obj12);
        setObjList.add(obj13);
        setObjList.add(obj14);
        setObjList.add(obj15);
        setObjList.add(obj17);
        setObjList.add(obj18);
        setObjList.add(obj16);
        setObjList.add(obj23);
        setObjList.add(obj24);
        setObjList.add(obj25);
        setObjList.add(obj26);
        setObjList.add(obj27);
        setObjList.add(obj28);
        setObjList.add(obj29);
        setObjList.add(obj30);
        setObjList.add(obj31);
        setObjList.add(obj32);
        setObjList.add(obj33);
        setObjList.add(obj34);
        setObjList.add(obj35);
        setObjList.add(obj36);
        setObjList.add(obj37);
        setObjList.add(obj38);
        setObjList.add(obj39);
        setObjList.add(obj40);
        setObjList.add(obj41);
        setObjList.add(obj42);
        setObjList.add(obj43);
        setObjList.add(obj44);
        setObjList.add(obj45);
        setObjList.add(obj46);
        setObjList.add(obj47);
        setObjList.add(obj48);
        setObjList.add(obj49);
        setObjList.add(obj50);
        setObjList.add(obj51);
        setObjList.add(obj52);
        setObjList.add(obj53);
        setObjList.add(obj54);
        setObjList.add(obj55);
        setObjList.add(obj56);
        setObjList.add(obj57);
        setObjList.add(obj58);
        setObjList.add(obj59);
        setObjList.add(obj60);
        setObjList.add(obj61);
        setObjList.add(obj62);
        setObjList.add(obj63);
        setObjList.add(obj64);
        setObjList.add(obj65);
        setObjList.add(obj66);
        setObjList.add(obj67);
        setObjList.add(obj68);
        setObjList.add(obj69);
        setObjList.add(obj70);
        setObjList.add(obj71);
        setObjList.add(obj72);
        setObjList.add(obj73);
        setObjList.add(obj74);
        setObjList.add(obj75);
        setObjList.add(obj76);
        setObjList.add(obj77);
        setObjList.add(obj78);
        setObjList.add(obj79);
        setObjList.add(obj80);
        setObjList.add(obj81);
        setObjList.add(obj82);
        setObjList.add(obj83);
        setObjList.add(obj84);
        setObjList.add(obj85);
        setObjList.add(obj86);
        setObjList.add(obj87);
        setObjList.add(obj88);
        setObjList.add(obj89);
        setObjList.add(obj90);
        setObjList.add(obj91);
        setObjList.add(obj92);
        setObjList.add(obj93);
        setObjList.add(obj94);
        setObjList.add(obj95);
        setObjList.add(obj96);
        setObjList.add(obj97);
        setObjList.add(obj98);
        setObjList.add(obj99);
        setObjList.add(obj100);
        setObjList.add(obj101);
        setObjList.add(obj102);
        setObjList.add(obj103);
		setObjList.add(obj104);
        setObjList.add(obj105);
        setObjList.add(obj106);
        setObjList.add(obj107);
        setObjList.add(obj108);
        setObjList.add(obj109);
        setObjList.add(obj110);
        setObjList.add(obj111);
        setObjList.add(obj112);
        setObjList.add(obj113);
        setObjList.add(obj114);
        setObjList.add(obj115);
        setObjList.add(obj116);
        setObjList.add(obj117);
        setObjList.add(obj118);
        setObjList.add(obj119);
        setObjList.add(obj120);
        setObjList.add(obj121);
        setObjList.add(obj122);
        setObjList.add(obj123);
        setObjList.add(obj124);
        setObjList.add(obj125);
        setObjList.add(obj126);
        setObjList.add(obj127);
        setObjList.add(obj128);
        setObjList.add(obj129);
        setObjList.add(obj130);
        setObjList.add(obj131);
        setObjList.add(obj132);
        setObjList.add(obj133);
        setObjList.add(obj134);
        setObjList.add(obj135);
        setObjList.add(obj136);
        setObjList.add(obj137);
        setObjList.add(obj138);
        setObjList.add(obj139);
        setObjList.add(obj140);
        setObjList.add(obj141);
        setObjList.add(obj142);
        setObjList.add(obj143);
        setObjList.add(obj144);
        setObjList.add(obj145);
        setObjList.add(obj146);
        setObjList.add(obj147);
        setObjList.add(obj148);
        setObjList.add(obj149);
        setObjList.add(obj150);
        setObjList.add(obj151);
        setObjList.add(obj152);
        setObjList.add(obj153);
        setObjList.add(obj154);
        setObjList.add(obj155);
        setObjList.add(obj156);
        setObjList.add(obj157);
        
        insert setObjList;
    }

    public static void createTPAReportsDashboardsSettingdata() {
        List<TPA_Reports_Dashboards_Setting__c> settingObjList = new List<TPA_Reports_Dashboards_Setting__c>();
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'Requests After Date', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'Requests After Date', Setting_Value__c = '2015-06-01T00:00:00Z'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'Requests chunk size to pull', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'Requests chunk size to pull', Setting_Value__c = '1000'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'Test Accounts to Exclude', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'Test Accounts to Exclude', Setting_Value__c = 'true'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'Top N Records in DB', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'Top N Records in DB', Setting_Value__c = '10'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'TPA Status To Exclude', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'TPA Status To Exclude', Setting_Value__c = 'Cancelled'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'BU1', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'BU1', Setting_Value__c = 'Global,Algeria,Argentina'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'BU2', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'BU2', Setting_Value__c = 'France,Georgia,Germany'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'BU3', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'BU3', Setting_Value__c = 'Sweden,Switzerland,Tunisia'));
        settingObjList.add(new TPA_Reports_Dashboards_Setting__c(Name = 'BU4', Setting_Type__c = 'Reports', Setting_Unique_Name__c = 'BU4', Setting_Value__c = 'Test4'));
        insert settingObjList;
    }

    public static void createMultilingualGlobalSettingsData() {
        list<TPA_Multilingual_Global_Settings__c> setObjList = new list<TPA_Multilingual_Global_Settings__c>();

        TPA_Multilingual_Global_Settings__c obj1 = new TPA_Multilingual_Global_Settings__c(Name = 'Test1', Supported_Language_Field_Map__c = 'Japanese~Japanese_Translation__c;English~English_Translation__c',Supported_Language_Code_with_Field_Map__c = 'ja=Japanese~Japanese_Translation__c~日本語;en_US=English~English_Translation__c~English');

        setObjList.add(obj1);

        insert  setObjList;
    }

    /*public static void createTPAReqAggMappingSettingsData() {
        List<TPA_Request_Ageement_Mapping__c> settingDataList = new List<TPA_Request_Ageement_Mapping__c>();

        TPA_Request_Ageement_Mapping__c record1 = new TPA_Request_Ageement_Mapping__c(Name = 'test1' , Field_Api_Name__c = 'Client_Address__c');

        settingDataList.add(record1);

        insert settingDataList;
    }*/

    /**
     * Added by Vikram Singh during refactoring task on 05th April, 2018
     * Creates Custom settings based on Organization
     */
    public static TPA_Settings__c createTPASettingsDataBasedOnOrganization() {
        Profile newTpProcessorProfile = [SELECT Id FROM Profile WHERE Name like 'US TP Processor Profile CCP%' Limit 1];

        TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,
                                                        Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),
                                                        TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com,test1@test1.com',
                                                        Manual_Review_For_Special_Client_And_Use__c='001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication',
                                                        Email_Pending_Cancellation_Sign__c=accessEmailTemplate('TPA Cancelation Pending Mail').id,
                                                        TPA_DRN_Mails_Copy_To__c  = 'test@test.com,test1@test1.com',
                                                        Shared_Email__c = 'test@test.com',
                                                        SetupOwnerId = UserInfo.getOrganizationId(),
                                                        New_CCP_Profile_Ids__c = newTpProcessorProfile.id,
                                                        TPA_Send_Emails__c = true,
                                                        Stop_TLLA_Generation_Notice_Id__c = accessEmailTemplate('Stop TLLA Generation Notice').id,
                                                        TPA_From_Orgwide_Email_Id__c = '0D2V00000008PiU',
                                                        TPA_Batch_Mail_Ids__c = 'test@test.com',
                                                        TPA_From_Address_For_Data_Release__c = '0D270000000CbU7',
                                                        Deployment_Date__c = '2015-06-27',
                                                        TP_US_Mail_Id__c = 'Test@test.com',
                                                        TPA_Mail_ID__c = 'tpatestemail@test.com',
                                                        TPA_Executed_AMA_Agreement_Template__c = '00Xc0000000Mu3q',
                                                        TPA_Log_Report_Recipients__c = 'test.t@g.co',
                                                        TLLA_Rescheduler_Execution_Time__c = 60,
                                                        TPA_Log_Tracking_Report_Id__c = Null,
                                                        TPA_New_Helpful_Hints_Functionality_Date__c = Date.newInstance(2020, 11, 01),
                                                        TPA_Auto_Exception_Rpt_Recepients_Local__c = 'test@test.com',
                                                        Include_Test_Records_in_Exception_Report__c = true,
                                                        Monthly_OneKey_Report__c = '00O4C000000JUIk~test@test.com;',
                                                        Base_Url_Public__c = String.valueOf(URL.getOrgDomainUrl()),
                                                        IMS_health_logo_url__c = String.valueOf(URL.getOrgDomainUrl())+'&file=weqwdasz',
                                                        New_DDN_Requirement_Deployment_Date__c = Date.newInstance(2020, 01, 01), 
                                                        TPA_DocuSign_CC_Email_List__c = 'testUser1:test1@test.com,testUser2:test2@test.com',
                                                        TPA_50_or_More_Licenses_Email_Ids__c = 'testID1@test.com;testID2@test.com');
        insert tpaSetting;
        return tpaSetting;
    }

    /**
    * @description : Setup TPA_Settings__c custom setting data.
    */
    public static TPA_Settings__c createTPASettingsData() {
        Profile newTpProcessorProfile = [SELECT Id FROM Profile WHERE Name like 'US TP Processor Profile CCP%' Limit 1];

        TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,
                                                        Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),
                                                        TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com,test1@test1.com',
                                                        Manual_Review_For_Special_Client_And_Use__c='001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication',
                                                        Email_Pending_Cancellation_Sign__c=accessEmailTemplate('TPA Cancelation Pending Mail').id,
                                                        TPA_DRN_Mails_Copy_To__c  = 'test@test.com,test1@test1.com',
                                                        Shared_Email__c = 'test@test.com',
                                                        SetupOwnerId=Userinfo.getProfileId(),
                                                        New_CCP_Profile_Ids__c = newTpProcessorProfile.id,
                                                        TPA_Send_Emails__c = true,
                                                        Stop_TLLA_Generation_Notice_Id__c = accessEmailTemplate('Stop TLLA Generation Notice').id,
                                                        TPA_From_Orgwide_Email_Id__c = '0D2V00000008PiU',
                                                        TPA_Batch_Mail_Ids__c = 'test@test.com',
                                                        TPA_From_Address_For_Data_Release__c = '0D270000000CbU7',
                                                        Deployment_Date__c = '2015-06-27',
                                                        TP_US_Mail_Id__c = 'Test@test.com',
                                                        TPA_Executed_AMA_Agreement_Template__c = '00Xc0000000Mu3q',
                                                        TPA_Log_Report_Recipients__c = 'test.t@g.co',
                                                        TLLA_Rescheduler_Execution_Time__c = 60,
                                                        Modify_Agreement_Request__c = true,
                                                        TPA_Log_Tracking_Report_Id__c = Null,
                                                        TPA_Auto_Exception_Rpt_Recepients_Local__c = 'test@test.com',
                                                        TPA_Auto_Exception_Rpt_Recepients_Legal__c = 'test@test.com',
                                                        Include_Test_Records_in_Exception_Report__c = true,
                                                        TPA_Supported_Languages__c = 'English~Japanese~French',
                                                        Base_Url_Public__c = String.valueOf(URL.getOrgDomainUrl()),
                                                        IMS_health_logo_url__c = String.valueOf(URL.getOrgDomainUrl())+'&file=weqwdasz',
                                                        New_DDN_Requirement_Deployment_Date__c = Date.newInstance(2020, 01, 01), 
                                                        TPA_New_Helpful_Hints_Functionality_Date__c = Date.newInstance(2020, 11, 01),
                                                        TPA_50_or_More_Licenses_Email_Ids__c = 'testID1@test.com;testID2@test.com');
        insert tpaSetting;
        return tpaSetting;
    }

    public static TPA_Settings__c getTPASettingsData() {
        Profile newTpProcessorProfile = [SELECT Id FROM Profile WHERE Name like 'US TP Processor Profile CCP%' Limit 1];

        TPA_Settings__c tpaSetting = new TPA_Settings__c(Is_Potential_Vendor_Submitted__c = true,
                                                        Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),
                                                        TPA_RequestSubmitted_Email__c = 'neha.bansal@metacube.com,test1@test1.com',
                                                        Manual_Review_For_Special_Client_And_Use__c='001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication',
                                                        Email_Pending_Cancellation_Sign__c=accessEmailTemplate('TPA Cancelation Pending Mail').id,
                                                        TPA_DRN_Mails_Copy_To__c  = 'test@test.com,test1@test1.com',
                                                        Shared_Email__c = 'test@test.com',
                                                        SetupOwnerId=Userinfo.getProfileId(),
                                                        New_CCP_Profile_Ids__c = newTpProcessorProfile.id,
                                                        TPA_Send_Emails__c = true,
                                                        Stop_TLLA_Generation_Notice_Id__c = accessEmailTemplate('Stop TLLA Generation Notice').id
                                                        ,TPA_From_Orgwide_Email_Id__c = '0D2V00000008PiU',
                                                        TPA_Batch_Mail_Ids__c = 'test@test.com',TPA_From_Address_For_Data_Release__c = '0D270000000CbU7',
                                                        Deployment_Date__c = '2015-06-27',
                                                        TP_US_Mail_Id__c = 'Test@test.com', TPA_Executed_AMA_Agreement_Template__c = '00Xc0000000Mu3q', 
                                                        TPA_New_Helpful_Hints_Functionality_Date__c = Date.newInstance(2020, 11, 01),
                                                        TPA_Admin_Email_Address__c = 'test@test.com'
                                                        );
        return tpaSetting;
    }

    public static Privacy_Policy_TPA__c getPrivacyPolicySetting() {
        Privacy_Policy_TPA__c settingObj = new Privacy_Policy_TPA__c(SetupOwnerId = UserInfo.getOrganizationId(),
                                                                    ContractUserName__c = 'testUsername@metacube.com',
                                                                    ContractPassword__c = 'testPassword',
                                                                    ContractAPIURL__c = String.valueOf(URL.getOrgDomainUrl()));
        insert settingObj;
        return settingObj;
    }

    public static void createContractManagementSettingData() {
        Contract_Management_Setting__c  contractSetting = new Contract_Management_Setting__c();
        contractSetting.CPC__c = '01270000000E07DAAS';
        insert contractSetting;
    }

    /**
     * Added by: Vikram Singh Fartyal
     * Creates Setting data for TPA_Status_Sequence__c
     */
    public static void createStatusSequenceSettingData() {
        TPA_Status_Sequence__c seq = new TPA_Status_Sequence__c( Name = '0', Status_Value__c = 'Awaiting Vendor Submission' );
        TPA_Status_Sequence__c seq1 = new TPA_Status_Sequence__c( Name = '1', Status_Value__c = 'In Review By IQVIA' );
        TPA_Status_Sequence__c seq2 = new TPA_Status_Sequence__c( Name = '2', Status_Value__c = 'Awaiting Vendor Signature' );
        TPA_Status_Sequence__c seq3 = new TPA_Status_Sequence__c( Name = '3', Status_Value__c = 'Expired' );

        List<TPA_Status_Sequence__c> sequences = new List<TPA_Status_Sequence__c>{ seq, seq1, seq2, seq3 };
        insert sequences;
    }

    /**
     * Added by: Vikram Singh Fartyal
     * Creates Setting data for Global_Holidays__c
     */
    public static void createGlobalHolidaysSettingData() {
        Global_Holidays__c globalHol = new Global_Holidays__c( Name = '1', Holiday__c = Date.today() );
        insert globalHol;
    }

    // get test email template Id
    public static String templateId = '';
    public static Id getTestEmailTemplateId() {
        if(templateId != null && templateId != '') {
            return templateId;
        }
        List<EmailTemplate> emailTemplateList = [SELECT Id, Name FROM EmailTemplate WHERE Name = 'Vendor Template To Update TPLLM'];
        if(emailTemplateList.size() > 0) {
            templateId = emailTemplateList[0].Id;
        }   
        system.debug('templateId1: ' + templateId);
        return templateId;
    }

    /**
     * Added by: Vikram Singh Fartyal
     * Create ATC data for ATC__c
     */
    public static ATC__c createATC() {
        ATC__c tpaATC = new ATC__c( ATC_Code__c = '123', Name_Eng__c = 'Test ATC' );
        insert tpaATC;
        return tpaATC;
    }

    /**
     * Added by: Vikram Singh Fartyal
     * Create TPA Request ATC data for TPA_Request_ATC__c
     */
    public static void createTpaRequestATC(TPA_Request__c tpaRequest) {
        ATC__c tpaATC = createATC();
        TPA_Request_ATC__c tpaRequestATC = new TPA_Request_ATC__c( TPA_Request__c = tpaRequest.id,ATC__c = tpaATC.id );
        insert tpaRequestATC;
    }
    
    public static Id getTPAVendorAddressRecordTypeId {
        get {
            if(getTPAVendorAddressRecordTypeId == null) {
                getTPAVendorAddressRecordTypeId  = Schema.SObjectType.Address__c.getRecordTypeInfosByName().get('TPA Unvalidated Addresses').getRecordTypeId();
            }
            return getTPAVendorAddressRecordTypeId;
        }
        set;
    }
    
    public static Address__c getAddressByNameAndRegNo(String accountName, Integer RegNo) {
        return new Address__c( name = accountName,
                              recordTypeId = getTPAVendorAddressRecordTypeId,
                              Is_TPA_Account__c = true,
                              Vendor_Registration_Number__c = RegNo,
                              Street__c = 'Test',
                              City__c = 'Test',
                              State__c = 'Test',
                              Country__c = 'Test',
                              PostalCode__c = 'Test',
                              TPA_Local_Address_Required__c = false  
                             );
    }

    /**
     * Return a test TPA account without inserting it.
     */
    public static Address__c getAccount() {
        Address__c testAddress = new Address__c( name = 'TPA Test Account',
                                                recordTypeId = getTPAVendorAddressRecordTypeId,
                                                Is_TPA_Account__c = true,
                                                Vendor_Registration_Number__c = 123,
                                                Country__c = 'India',
                                                State__c = 'Delhi',
                                                City__c = 'Test',
                                                Street__c = 'Test',
                                                PostalCode__c = '123',
                                                TPA_Local_Address_Required__c = false);
        return testAddress;
    }
    
    public static Address__c getAddress() {
        Address__c testAddress = new Address__c( name = 'TPA Test Account',
                                                recordTypeId = getTPAVendorAddressRecordTypeId,
                                                Is_TPA_Account__c = true,
                                                Country__c = 'India',
                                                State__c = 'Delhi',
                                                City__c = 'Test',
                                                Street__c = 'Test',
                                                PostalCode__c = '123',
                                                TPA_Local_Address_Required__c = false);
        //insert testAddress;
        return testAddress;
    }
    
    public static Contact_Address_Crosswalk__c getjunctionRecord(String contactId, String addressId) {
        Contact_Address_Crosswalk__c crosswalkObj = new Contact_Address_Crosswalk__c( 
                                                                                    Address__c = addressId,
                                                                                    Contact__c = contactId);
        return crosswalkObj;
    } 

    public static Address__c getBlankAccount() {
        return new Address__c(recordTypeId = getTPAVendorAddressRecordTypeId);
    }

    /**
     * Return a test TPA contact without inserting it.
     */
    public static Contact getContact() {
        Contact testContact = new Contact(firstName = 'testfirstname',
                                          LastName = 'Test',
                                          CurrencyIsoCode = 'USD',
                                          Email = 'test@mail.com',
                                          Title = 'Dev');
        return testContact;
    }

    /**
     * Return a test user.
     */
    public static User getUser () {
        User testUser = new User(Alias = 'standt',
                                 Email = 'standarduser@testorg.com',
                                 EmailEncodingKey = 'UTF-8',
                                 FirstName = 'TestFName',
                                 LastName = 'TestLName',
                                 LanguageLocaleKey = 'en_US',
                                 LocaleSidKey = 'en_US',
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 IsActive = true,
                                 UserName = 'standarduser@testorg.com' + String.valueof(DateTime.now().getTime())
                                );
        return testUser;
    }

    public static RecordType getRecordType() {
        RecordType RecType = [Select Id, Name from RecordType where SobjectType='TPA_Request__c' and  name = 'CPC' limit 1];
        return RecType;
    }

    /**
     * Return a test TPA Request.
     */
    public static TPA_Request__c getTestTPARequest() {
        TPA_Request__c tpaRequest = new TPA_Request__c( Client_Region__c = 'US',
                                                        Data_Provided_By__c = 'IQVIA in lieu of Client',
                                                        Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
                                                        AMA_USPrescriberData__c = 'Yes',
                                                        Does_the_request_require_information_con__c = 'Yes',
                                                        Vendor_Company_Name__c = 'Test company',
                                                        Is_Submitted__c = true,
                                                        Is_CPC_Renewal_Notice_Sent__c = true,
                                                        Is_CPC_Expiration_Notice_Sent__c = true,
                                                        Vendor_Contact_Email_Client__c = 'test@mail.com',
                                                        Authorized_Signer_Email__c = 'test@mail.com',
                                                        Data_Access_End_Date__c = todayDate,
                                                        Request_Status__c = 'Awaiting Vendor Submission');
        return tpaRequest;
    }

    /**
     * Return a blank TPA Request.
     */
    public static TPA_Request__c getTPARequestBlank(boolean isInsert) {
        TPA_Request__c tpaRequest = new TPA_Request__c();
        if(isInsert) {
            insert tpaRequest;
        }
        return tpaRequest;
    }

    /**
     * Return a blank TPA Agreement.
     */
    public static TPA_Request__c getTPAAgreementBlank(boolean isInsert, String reqId) {
        TPA_Request__c tpaAgreement = new TPA_Request__c();
        if(isInsert) {
            insert tpaAgreement;
        }
        return tpaAgreement;
    }

    /**
    * @description : Get a test TPA Agreement.
    */
    public static TPA_Request__c getAgreement() {

        TPA_Request__c testAgreement = new TPA_Request__c(Data_Access_End_Date__c = todayDate.addDays(5),
                                                                                Requires_Manual_Review__c = false,
                                                                                Is_TPA_Signed_Contract_Attached__c = true,
                                                                                Vendor_Language__c =  'English',
                                                                                Is_Submitted__c = true);

        return testAgreement;
    }

    public static TPA_Request__c getTestAgreement() {

        TPA_Request__c testAgreement = new TPA_Request__c(Data_Access_End_Date__c = todayDate.addDays(5),
                                                                                Requires_Manual_Review__c = false,
                                                                                Is_TPA_Signed_Contract_Attached__c = true,
                                                                                TP_Processor_Email__c = 'test@mail.com');

        return testAgreement;
    }

    public static TPA_Request__c getNewTestAgreement(Id ServiceProviderId, Boolean IsTPASignedContractAttached,
                                                            Id ServiceProviderContactId, id ClientId, id ClientContactId) {

       TPA_Request__c TestAgreement = new TPA_Request__c(
                                   Sent_for_Signatures_on__c = todayDate,
                                   Data_Access_End_Date__c = todayDate.addDays(-3),
                                   Is_Submitted__c = true,
                                   Requires_Manual_Review__c = true,
                                   Request_status__c = 'In Review By IQVIA',
                                   Service_Provider_Address__c = ServiceProviderId ,
                       Is_TPA_Signed_Contract_Attached__c = IsTPASignedContractAttached,
                       Client_Address__c = getAddress().Id,
                       ClientContact__c = ClientContactId);

       return testAgreement;
   }
    
    public static Account getAccountObjectRecord(string accountName) {
        return new Account( name = accountName,
                          Region_Territory__c = 'India',
                          BillingState = 'Delhi',
                          BillingCity = 'Test',
                          BillingStreet = 'Test',
                          BillingPostalCode = '123',
                          CustomerSegment__c = 'GOVERNMENT',
                          Sub_Industry__c = 'STATE' );
    }

    /**
     * Purpose : Get a test TPA Account.
     */
    public static Address__c getTestAccount()
    {
        Account testAccount = new Account( name = 'TPA Test Account',
                                          BillingCountry = 'India',
                                          BillingState = 'Delhi',
                                          BillingCity = 'Test',
                                          BillingStreet = 'Test',
                                          BillingPostalCode = '123',
                                          CustomerSegment__c = 'GOVERNMENT',
                                          Sub_Industry__c = 'STATE' );
        insert testAccount;                                  

        Address__c testAddress = new Address__c( name = 'TPA Test Account',
                                          recordTypeId = getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
                                          Vendor_Registration_Number__c = 123,
                                          Account__c = testAccount.Id,
                                          Street__c = 'Test',
                                          City__c = 'Test',
                                          State__c = 'Test',
                                          Country__c = 'Test',
                                          PostalCode__c = 'Test' 
                                        );
            insert testAddress;                                  
        List<account> lst = [select name,BillingPostalCode, id from account];
        system.debug('size: '+lst.size());

        system.debug('testAccount: '+testAccount);
        return testAddress;
    }

    public static Address__c getTestAccountByNameAndRegNum(String accountName, Integer RegNo)
    {
        Account testAccount;
        Address__c testAddress;
        List<Address__c> ListAddress = [select Id,Name from Address__c where vendor_registration_number__c=: RegNo LIMIT 1];
        if(ListAddress.size() == 0)
        {
            testAccount = new Account( name = accountName,
                                      			AccountCountry__c = 'IN',
                                              Region_Territory__c = 'India',
                                              BillingState = 'Delhi',
                                              BillingCity = 'Test',
                                              BillingStreet = 'Test',
                                              BillingPostalCode = '123',
                                              CustomerSegment__c = 'GOVERNMENT',
                                              Sub_Industry__c = 'STATE' );
            insert testAccount;
            testAddress = new Address__c( name = accountName,
                                          recordTypeId = getTPAVendorAddressRecordTypeId,
                                          Is_TPA_Account__c = true,
                                          Vendor_Registration_Number__c = RegNo,
                                          Account__c = testAccount.Id,
                                          Street__c = 'Test',
                                          City__c = 'Test',
                                          State__c = 'Test',
                                          Country__c = 'Test',
                                          PostalCode__c = 'Test',
                                          TPA_Local_Address_Required__c = false  
                                        );
            insert testAddress;
        }
        else
        {
              testAddress = ListAddress[0];
        }
           return testAddress;
    }

    /**
    * Purpose : Get a test TPA Contact.
    */
    public static Contact getTestContact(Address__c testAddress)
    {
        Contact testContact = new Contact( FirstName = 'TestFirstName',
                                           LastName = 'Test',
                                           CurrencyIsoCode = 'USD',
                                           Email = 'test@mail.com',
                                           Title = 'Dev',
                                           Portal_Case_Type__c = 'Information Offering' );

        testContact.AccountId = testAddress.Account__c;

        insert testContact ;
        return testContact;
    }

    public static User createTestUser ( Contact testContact , Profile p){
        //List<UserRole> userRole_1 = [SELECT Id FROM UserRole WHERE DeveloperName = 'GLOBAL' LIMIT 1];
        User testUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,//UserRoleId = userRole_1[0].Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com', contactid=testContact.id);
        insert testUser;
        return testUser;
    }

    public static User createActiveTestUser (Contact testContact, Profile p, String usrAlias, String usrEmail, String usrName){
        User testUser = new User(Alias = usrAlias, Email = usrEmail,
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id, IsActive = true,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = usrName, contactid = testContact.id);
        insert testUser;
        return testUser;
    }

    public static User createInactiveTestUser (Contact testContact, Profile p, String usrAlias, String usrEmail, String usrName){
        User testUser = new User(Alias = usrAlias, Email = usrEmail,
                          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                          LocaleSidKey = 'en_US', ProfileId = p.Id, IsActive = false,
                          TimeZoneSidKey = 'America/Los_Angeles', UserName = usrName, contactid = testContact.id);
        insert testUser;
        return testUser;
    }

    /**
    * Purpose : Get a test TPA Request.
    */
    public static TPA_Request__c getTPARequest()
    {
        //Account testAccount = getTestAccountByNameAndRegNum('test account 3', 9898);
        Address__c testAddress = getTestAccountByNameAndRegNum('test account 3', 9898);
        Account testAccount = [select Id, Name from Account where Id=: testAddress.Account__c];
        Contact testContact = getTestContact(testAddress);

        TPA_Request__c tpaRequest = new TPA_Request__c(Client_Region__c = 'US',
                                                       Data_Provided_By__c = 'IQVIA in lieu of Client',
                                                       Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
                                                       AMA_USPrescriberData__c = 'Yes',
                                                       Does_the_request_require_information_con__c = 'Yes',
                                                       Vendor_Company_Name__c = 'Test company',
                                                       Is_CPC_Renewal_Notice_Sent__c = true,
                                                       Is_CPC_Expiration_Notice_Sent__c = true,
                                                       Vendor_Contact_Email_Client__c = 'test@mail.com',
                                                       Authorized_Signer_Email__c = 'test@mail.com',
                                                       Client_Language__c = 'English',
                                                       Vendor_Language__c = 'English',
                                                       Is_Submitted__c = true,
                                                       Request_Status__c = 'In Effect',
                                                       Data_Access_End_Date__c = todayDate.addDays(3),
                                                       Vendor_e_mail__c = 'test@mail.com',
                                                       TP_Processor_Email__c = 'test@mail.com',
                                                       Is_Potential_Vendor_Case__c = true);

        tpaRequest.OwnerId = UserInfo.getUserId();
      //  tpaRequest.Service_Provider__c = testAccount.Id;
        tpaRequest.Service_Provider_Address__c= testAddress.Id;
        tpaRequest.Data_Access_End_Date__c = todayDate;
        tpaRequest.ClientContact__c = testContact.id;

        insert tpaRequest;
        return tpaRequest;
    }

    public static TPA_Request__c getTPARequestByVendorAccount(Id vendorAccountId )
    {
        date strtDate = date.newInstance(2014, 1, 1);
        TPA_Request__c tpaRequest = new TPA_Request__c(
            OwnerId = UserInfo.getUserId(),
            Client_Region__c = 'US',
            Data_Provided_By__c = 'IQVIA in lieu of Client',
            Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
            AMA_USPrescriberData__c = 'Yes',
            Does_the_request_require_information_con__c = 'Yes',
            Service_Provider_Address__c = vendorAccountId,
            Client_Address__c = vendorAccountId,
           // Service_Provider_Address__c = getAddress().Id,
            TPA_Request_Marked_as__c = 'Public',
            Vendor_Company_Name__c = 'Test company',
            LastAction__c = 'Request Edited By Client',
            Is_Submitted__c = true,
            Data_Access_End_Date__c = strtDate.addDays(5),
            TP_Processor_Email__c = 'test@mail.com'
        );
        insert tpaRequest;
        return tpaRequest;
    }

    /**
    * Purpose : Get a test TPA Agreement.
    */
    public static TPA_Request__c getAgreement(TPA_Request__c tpaRequest)
    {
        date strtDate = date.newInstance(2014, 1, 1);

        Address__c testAccount = getTestAccountByNameAndRegNum('test account 4', 4344);

        TPA_Request__c TestAgreement = new TPA_Request__c(Data_Access_End_Date__c = strtDate.addDays(5),
                                                            Requires_Manual_Review__c = false,
                                                            Is_TPA_Signed_Contract_Attached__c = true,
                                                            Vendor_Language__c =  'English',
                                                            Request_Status__c = 'In Effect',
                                                            TP_Processor_Email__c = 'test@mail.com');


        insert TestAgreement;
        return TestAgreement;
    }

    public static AMA_Agreement_Detail__c getAMAAgreementDetail(String DBL, String ContractType, Id reqId)
    {

        AMA_Agreement_Detail__c amaAgg = new AMA_Agreement_Detail__c(AMA_Manual_Review__c = false, Is_AMA_License_Required__c = true,
                                                                     DBL__c = DBL, 
                                                                     Send_DBL_Notification_To_AMA__c = true, TPA_Request__c = reqId, Current_Year_Fees__c = 21000,Next_Year_Fees__c = 56000,
                                                                    Initial_Termination_Date__c = date.newInstance(2017, 12, 31), Agreement_End_Date__c = date.newInstance(2020, 12, 31),
                                                                    Date_Agreement_Activated__c = system.now());
        insert amaAgg;
        return amaAgg;
    }

    public static AMA_Agreement_Detail__c getAMAAgreementDetailBlank(Id reqId)
    {
        AMA_Agreement_Detail__c amaAgg = new AMA_Agreement_Detail__c(TPA_Request__c = reqId);
        return amaAgg;
    }

    public static TPA_Request__c getAgreementByName()
    {
        date strtDate = date.newInstance(2014, 1, 1);

        TPA_Request__c TestAgreement = new TPA_Request__c(Data_Access_Start_Date__c = strtDate,
                                                                                Data_Access_End_Date__c = strtDate.addDays(5),
                                                                                Requires_Manual_Review__c = false,
                                                                                TP_Processor_Email__c = 'ab@gmail.com',
                                                                                Is_TPA_Signed_Contract_Attached__c = true);


        insert TestAgreement;
        return TestAgreement;
    }

    public static void createCrossWalkData()
    {
        list<TPA_Language_Cross_Walk__c> crossWalkObjList = new list<TPA_Language_Cross_Walk__c>();
        TPA_Language_Cross_Walk__c crossWalkObj1 = new TPA_Language_Cross_Walk__c(Name = 'Test1',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'VoidReason',
                                                                                  English_Translation__c = 'Test Void reason in English',
                                                                                  Japanese_Translation__c = 'Test Void reason in Japanese'
                                                                                 );
        TPA_Language_Cross_Walk__c crossWalkObj2 = new TPA_Language_Cross_Walk__c(Name = 'Test2',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'IQVIA TPA Program: TPA_Number, Signature Request for Client_Name',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );
        TPA_Language_Cross_Walk__c crossWalkObj3 = new TPA_Language_Cross_Walk__c(Name = 'Test3',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'Ducusign Dynamic Message',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );

        TPA_Language_Cross_Walk__c crossWalkObj4 = new TPA_Language_Cross_Walk__c(Name = 'Test4',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'Manual VoidReason',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );

        TPA_Language_Cross_Walk__c crossWalkObj5 = new TPA_Language_Cross_Walk__c(Name = 'Test5',
                                                                                  Object_Type__c = 'IMS_TPA_Purpose__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'Offering Category',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );

        TPA_Language_Cross_Walk__c crossWalkObj6 = new TPA_Language_Cross_Walk__c(Name = 'Test6',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = '--None--',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );
        TPA_Language_Cross_Walk__c crossWalkObj7 = new TPA_Language_Cross_Walk__c(Name = 'Test7',
                                                                                  Object_Type__c = 'IMS_Data_Asset__c',
                                                                                  Control_Type__c = 'Picklist',
                                                                                  Default_Value__c = 'Geo_Level__c',
                                                                                  field_type__c = 'Geo_Level__c',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );
        TPA_Language_Cross_Walk__c crossWalkObj8 = new TPA_Language_Cross_Walk__c(Name = 'Test8',
                                                                                  Object_Type__c = 'IMS_TPA_Purpose__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'Permitted Use',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );
        TPA_Language_Cross_Walk__c crossWalkObj9 = new TPA_Language_Cross_Walk__c(Name = 'Test9',
                                                                                  Object_Type__c = 'IMS_TPA_Purpose__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'IQVIA Data',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );
        TPA_Language_Cross_Walk__c crossWalkObj10 = new TPA_Language_Cross_Walk__c(Name = 'Test10',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'NewReqVendorNotificationSubject',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                  );
        TPA_Language_Cross_Walk__c crossWalkObj11 = new TPA_Language_Cross_Walk__c(Name = 'Test11',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'EditReqVendorNotificationSubject',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                  );
        TPA_Language_Cross_Walk__c crossWalkObj12 = new TPA_Language_Cross_Walk__c(Name = 'Test12',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'RenewVendorNotification',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                  );
        TPA_Language_Cross_Walk__c crossWalkObj13 = new TPA_Language_Cross_Walk__c(Name = 'Test13',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'priorTPAs',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                  );
        TPA_Language_Cross_Walk__c crossWalkObj14 = new TPA_Language_Cross_Walk__c(Name = 'Test14',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'priorVendorcontactname',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                  );
        TPA_Language_Cross_Walk__c crossWalkObj15 = new TPA_Language_Cross_Walk__c(Name = 'Test15',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'priorVendorcontactemail',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                  );
        TPA_Language_Cross_Walk__c crossWalkObj16 = new TPA_Language_Cross_Walk__c(Name = 'Test16',
                                                                                  Object_Type__c = 'TPA_Request__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'priorDDNAckLink',
                                                                                  field_type__c = '',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                  );
        TPA_Language_Cross_Walk__c crossWalkObj17 = new TPA_Language_Cross_Walk__c(Name = 'Test17',
                                                                                  Object_Type__c = 'IMS_TPA_Purpose__c',
                                                                                  Control_Type__c = 'Record',
                                                                                  Default_Value__c = 'Data Offerings',
                                                                                  English_Translation__c = 'Test Vaule in English',
                                                                                  Japanese_Translation__c = 'Test Vaule in Japanese'
                                                                                 );
        crossWalkObjList.add(crossWalkObj7);
        crossWalkObjList.add(crossWalkObj8);
        crossWalkObjList.add(crossWalkObj9);
        crossWalkObjList.add(crossWalkObj1);
        crossWalkObjList.add(crossWalkObj2);
        crossWalkObjList.add(crossWalkObj3);
        crossWalkObjList.add(crossWalkObj4);
        crossWalkObjList.add(crossWalkObj5);
        crossWalkObjList.add(crossWalkObj6);
        crossWalkObjList.add(crossWalkObj10);
        crossWalkObjList.add(crossWalkObj11);
        crossWalkObjList.add(crossWalkObj12);
        crossWalkObjList.add(crossWalkObj13);
        crossWalkObjList.add(crossWalkObj14);
        crossWalkObjList.add(crossWalkObj15);
        crossWalkObjList.add(crossWalkObj16);
        crossWalkObjList.add(crossWalkObj17);

        insert crossWalkObjList;
    }

    /**
     * Name
     * @param: TPA_Request__c, TPA_Request__c]
     * @type {TPA}
     * description: Creates Localized data in given language for a TPA Request
     */
    public static void createRequestLocalizedData(TPA_Request__c tpaRequest) {
        List<TPA_Request_Localized__c> tpaReqLocList = new List<TPA_Request_Localized__c>();
        tpaReqLocList.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'client', TPA_Request__c = tpaRequest.Id, Language__c = tpaRequest.Client_Language__c));
        tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'client', TPA_Request__c = tpaRequest.Id, Language__c = tpaRequest.Client_Language__c));
        tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'vendor', TPA_Request__c = tpaRequest.Id, Language__c = tpaRequest.Vendor_Language__c));
        tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'client-vendor', TPA_Request__c = tpaRequest.Id, Language__c = tpaRequest.Client_Language__c));
        tpaReqLoclist.add(new TPA_Request_Localized__c(Record_Localized_For__c = 'vendor', TPA_Request__c = tpaRequest.Id, Language__c = tpaRequest.Vendor_Language__c));
        insert tpaReqLocList;
    }


    /**
     * Name: createTPACountryCodeData
     * @param: codeType, codeName, possibleNames
     * @return: void
     * Desc: Create tpa Country Code data
    **/
    public static void createTPACountryCodeData(String codeType, String codeName, String possibleNames)
    {
        list<TPA_Country_Codes__c> TPACountryCodesList  = new list<TPA_Country_Codes__c>();

        TPA_Country_Codes__c  countryCodeObj = new TPA_Country_Codes__c ();
        countryCodeObj.Name  = codeName;
        countryCodeObj.Code_Type__c = codeType;
        countryCodeObj.Country_Possible_Codes__c  = possibleNames;

        TPACountryCodesList.add(countryCodeObj);

        insert TPACountryCodesList;
    }

    public static List<EmailTemplate> validEmailTemplate;
    public static EmailTemplate accessEmailTemplate(String Name)
    {
        if(validEmailTemplate == null) {
            validEmailTemplate = [SELECT Id, Name, DeveloperName, TemplateType, FolderId, isActive FROM EmailTemplate WHERE Name =: Name OR DeveloperName =: Name];
        }
        EmailTemplate emailTemplateToReturn;
        if(validEmailTemplate != null && validEmailTemplate.size() > 0) {
            emailTemplateToReturn = validEmailTemplate[0];
        }
        else {
            emailTemplateToReturn = new EmailTemplate();
            emailTemplateToReturn.isActive = true;
            emailTemplateToReturn.Name = Name;
            emailTemplateToReturn.DeveloperName = Name.deleteWhitespace();
            emailTemplateToReturn.TemplateType = 'HTML';
            emailTemplateToReturn.FolderId = UserInfo.getUserId();
            emailTemplateToReturn.Subject = 'Test Subject';
            emailTemplateToReturn.HtmlValue = 'Test Content';
            
            insert emailTemplateToReturn;
        }

        return emailTemplateToReturn;
    }

    /**
    * Purpose : Get TPA Contact by TPA Request ID.
    */
    public static TPA_Contact__c getTPAContactByReqId(TPA_Request__c request)
    {
     TPA_Contact__c tpaContact = new TPA_Contact__c(TPA_Request__c = request.Id, Email__c = 'test@mail.com');
        insert tpaContact;
        return tpaContact;
    }

    public static Agreement_Contact__c getTPAAgreementContactByAggId(TPA_Request__c req) {
        Agreement_Contact__c aggContact = new Agreement_Contact__c(TPA_Request__c = req.Id);
        return aggContact;
    }

    public static IMS_TPA_Purpose__c createIMSTpaPurposeData(String BU, String purposeName) {
        IMS_TPA_Purpose__c imsTpaPurpose = new IMS_TPA_Purpose__c(BU__c = BU, Primary_Purpose_Name__c = purposeName, Purpose_Details__c = 'test purpose details', Consulting_Area__c = 'test consulting area', Business_Line__c = 'test business line', Is_Active__c = true);
        insert imsTpaPurpose;
        return imsTpaPurpose;
    }

    public static IMS_TPA_Purpose__c getIMSTpaPurposeData() {
        return new IMS_TPA_Purpose__c();
    }

    public static TPA_Purpose_Category__c createTpaPurposeCategory(String categoryName){
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Alias__c = 'Expert', Category_Name__c = categoryName, isActive__c = true);
        insert tpaPurposeCategory;
        return tpaPurposeCategory;
    }

    public static TPA_Purpose_Category__c getTpaPurposeCategory(String categoryName){
        TPA_Purpose_Category__c tpaPurposeCategory = new TPA_Purpose_Category__c(Category_Name__c = categoryName, isActive__c = true);
        return tpaPurposeCategory;
    }

    public static TPA_Purpose__c createTpaPurpose(String name, TPA_Request__c tpaRequest1, TPA_Purpose_Category__c tpaPurposeCategory, IMS_TPA_Purpose__c imsTpaPurpose, IMS_Legal_Entity__c imsLegalEntity){
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = name,
                                                       Request__c = tpaRequest1.id,
                                                       BU__c = 'United States',
                                                       TPA_Purpose_Category__c = tpaPurposeCategory.id,
                                                       Purpose__c = imsTpaPurpose.id,
                                                       IMS_Legal_Entity__c = imsLegalEntity.Id,
                                                       Prescriber_ID_Number__c = null,
                                                       Prescriber_ID_Number_Details__c = null,
                                                       PrescriberNPINumber__c = null,
                                                       PrescriberNPINumber_Details__c = null,
                                                       OutletReferenceFiles__c = null,
                                                       Other_Reference_File__c = null,
                                                       Other_Details__c = '',
                                                       Other_Text__c = '',
                                                       NCPDPIDorNPIOutletNumber__c = null,
                                                       NCPDPIDorNPIOutletNumber_Details__c = null,
                                                       Managed_Care__c = null,
                                                       Managed_Care_Details__c = null,
                                                       Linked_Data_Description__c = null,
                                                       IMSPrescriberIDNumber__c = null,
                                                       IMSPrescriberIDNumber_Details__c = null,
                                                       FinDr_ID__c = null,
                                                       Extended_Category_Codes__c = null,
                                                       Deliverables_Freq_To_Client__c = null,
                                                       Data_Usage__c = null,
                                                       Data_Assets__c = null,
                                                       Client_Deliverables__c = null,
                                                       Additional_Reference_Info__c = null,
                                                       AMABridgeFile__c = null,
                                                       AMABridgeFile_Details__c = null);
        insert tpaPurpose;
        return tpaPurpose;
    }

    /**
    * Get TPA_Purpose__c record by TPA Request Id.
    */
    public static TPA_Purpose__c createTpaPurposeByReqId(TPA_Request__c tpaRequest1) {
        TPA_Purpose__c tpaPurpose = new TPA_Purpose__c(Name = 'Test TPA Purpose',
                                                       Request__c = tpaRequest1.Id,
                                                       BU__c = 'United States');
        return tpaPurpose;
    }

    public static IMS_Data_Asset__c getImsDataAssetBlank(Boolean isInsert, String assetName) {
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = assetName);
        if(isInsert) {
            insert imsDataAsset;
        }
        return imsDataAsset;
    }

    public static IMS_Data_Asset__c createImsDataAsset(Boolean isNotificationRequired){
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', Is_Notification_Required__c = isNotificationRequired,Is_Active__c = true, IMS_Legal_Entity__c = 'IQVIA Inc.');
        insert imsDataAsset;
        return imsDataAsset;
    }

    /*
    Method creates and returns ims Tpa data asset with Name.
    */
    public static IMS_Data_Asset__c createImsDataAssetWithName(String imsDataAssetName)
    {
      // create test IMS data assets
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(Asset_Name__c = imsDataAssetName, Region__c = 'TEST_REGION', Requires_Manual_Review__c = false, BU__c ='United States', Is_Active__c = true, Geo_Level__c  = 'National', IMS_Legal_Entity__c = 'IQVIA Inc.');
        insert imsDataAsset;
        return imsDataAsset;
    }

    /**
    * Get IMS_Data_Asset__c record without insert.
    */
    public static IMS_Data_Asset__c createImsDataAsset_Template() {
        IMS_Data_Asset__c imsDataAsset = new IMS_Data_Asset__c(BU__c = 'United States', Is_Active__c = true, IMS_Legal_Entity__c = 'IQVIA Ltd.');
        return imsDataAsset;
    }

    public static TPA_Data_Asset__c getTpaDataAsset(Id purpId) {
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Purpose__c = purpId);
        return tpaDataAsset;
    }

    public static TPA_Data_Asset__c createTpaDataAsset(TPA_Request__c tpaRequest1, TPA_Purpose__c tpaPurpose, IMS_Data_Asset__c imsDataAsset, IMS_Legal_Entity__c imsLegalEntity){
        TPA_Data_Asset__c tpaDataAsset = new TPA_Data_Asset__c(Request__c = tpaRequest1.id, Purpose__c = tpaPurpose.id, Data_Asset__c = imsDataAsset.id, IMSLegalEntity__c = imsLegalEntity.Id,
                                                               BU__c = 'United States', Geo_Level__c = 'Sub-National', Asset_NametText__c = 'MIDAS');
        insert tpaDataAsset;
        return tpaDataAsset;
    }

    public static IMS_Secondary_Data_Asset__c getImsSecDataAsset() {
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c();
        return imsSecondaryDataAsset;
    }

    public static IMS_Secondary_Data_Asset__c createIMSSecondaryDataAsset(IMS_Data_Asset__c imsDataAsset, Boolean isAdditionalTermsRequired, String Asset_Name){
        IMS_Secondary_Data_Asset__c imsSecondaryDataAsset = new IMS_Secondary_Data_Asset__c(Primary_Data_Asset__c = imsDataAsset.id, additional_terms_required__c = isAdditionalTermsRequired, Secondary_Asset_Name__c = Asset_Name, Is_Active__c = true, Requires_Manual_Review__c = true, Is_Restricted_Data__c = true);
        insert imsSecondaryDataAsset;
        return imsSecondaryDataAsset;
    }

    public static TPA_Secondary_Data_Asset__c getTpaSecDataAsset() {
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c();
        return tpaSecondaryDataAsset;
    }

    public static TPA_Secondary_Data_Asset__c createTPASecondaryDataAsset(TPA_Data_Asset__c tpaDataAsset, IMS_Secondary_Data_Asset__c imsSecondaryDataAsset, IMS_Legal_Entity__c imsLegalEntity, TPA_Request__c tpaRequest1 ,String Asset_Name){
        TPA_Secondary_Data_Asset__c tpaSecondaryDataAsset = new TPA_Secondary_Data_Asset__c(TPA_Data_Asset__c = tpaDataAsset.id, IMS_Secondary_Data_Asset__c = imsSecondaryDataAsset.id, IMS_Legal_Entity__c = imsLegalEntity.Id,TPA_Request_Secondary_Assets__c = tpaRequest1.id, Secondary_Asset_Name__c = Asset_Name, BrandImpact_Delivery_Date__c = Date.today(), Channel_Dynamics_Delivery_Date__c = Date.today(), Pro_Voice_Delivery_Date__c = Date.today());
        insert tpaSecondaryDataAsset;
        return tpaSecondaryDataAsset;
    }

    public static IMS_TPA_Purpose_Category__c getImsTpaPurpCat() {
        IMS_TPA_Purpose_Category__c imsTpaPurpCat = new IMS_TPA_Purpose_Category__c();
        return imsTpaPurpCat;
    }

    public static IMS_TPA_Purpose_Category__c createImsTpaPurposeCategory(IMS_TPA_Purpose__c imsTpaPurpose, TPA_Purpose_Category__c tpaPurposeCategory) {
        IMS_TPA_Purpose_Category__c imsTpaPurpCat = new IMS_TPA_Purpose_Category__c(IMS_TPA_Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id, isActive__c = true);
        return imsTpaPurpCat;
    }

    public static IMS_TPA_Purpose_Description__c getImsTpaPurpDes() {
        IMS_TPA_Purpose_Description__c imsTpaPurpDes = new IMS_TPA_Purpose_Description__c();
        return imsTpaPurpDes;
    }

    public static IMS_TPA_Purpose_Description__c createImsTpaPurposeDescription(IMS_TPA_Purpose__c imsTpaPurpose, TPA_Purpose_Category__c tpaPurposeCategory) {
        IMS_TPA_Purpose_Description__c imsTpaPurpDes = new IMS_TPA_Purpose_Description__c(Purpose__c = imsTpaPurpose.id, TPA_Purpose_Category__c = tpaPurposeCategory.id, Is_Active__c = true);
        return imsTpaPurpDes;
    }

    public static TPA_Purpose_Description__c getTpaPurpDes() {
        TPA_Purpose_Description__c tpaPurpDes = new TPA_Purpose_Description__c();
        return tpaPurpDes;
    }

    public static TPA_Purpose_Description__c createTpaPurposeDescription(TPA_Purpose__c tpaPurpose, IMS_TPA_Purpose_Description__c imsTpaPurposeDescription) {
        TPA_Purpose_Description__c tpaPurpDes = new TPA_Purpose_Description__c(Purpose__c = tpaPurpose.id, Description__c = imsTpaPurposeDescription.id);
        return tpaPurpDes;
    }

    public static AMA_Contract_Detail__c getAmaContractDetail() {
        AMA_Contract_Detail__c amaContrDetail = new AMA_Contract_Detail__c();
        return amaContrDetail;
    }

    public static TPA_AMA_Client_Vendor_Search_Map__c getTpaAmaClientVendSearchMap() {
        TPA_AMA_Client_Vendor_Search_Map__c tpaAmaClientVendSearchData = new TPA_AMA_Client_Vendor_Search_Map__c();
        return tpaAmaClientVendSearchData;
    }

    public static TPA_Text_Editor__c createTpaTestEditorData(String PageName, String PageContent, String PageTitle, String PageType){

        TPA_Text_Editor__c tpaUseDefinition = new TPA_Text_Editor__c(Page_Name__c = PageName, Content__c = PageContent, Page_Title__c = PageTitle, Page_Type__c = PageType, English_Translation__c = 'Test English Content', Japanese_Translation__c = 'Test Japanese Content');
        insert tpaUseDefinition;
        return tpaUseDefinition;
    }
    public static TPA_Agreement_Additional_Field__c getTPAAgreementAdditionalFieldObj(TPA_Request__c tpaRequest1){
        TPA_Agreement_Additional_Field__c obj = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = tpaRequest1.id);
        insert obj;
        return obj;
    }

    
public static TPA_Agreement_Additional_Field__c returnTPAAgreementAdditionalFieldObj(TPA_Request__c tpaRequest1){
    TPA_Agreement_Additional_Field__c obj = new TPA_Agreement_Additional_Field__c(Related_TPA_Request__c = tpaRequest1.id);
    //insert obj;
    return obj;
}
    public static attachment addAttachmentToParent(Id parentId,string Name)
    {
            Blob b = Blob.valueOf('Test Data');
            Attachment attachment = new Attachment();
            attachment.ParentId = parentId;
            attachment.Name = 'Test' + Name;
            attachment.Body = b;
            insert(attachment);
            return (attachment);
    }

    public static attachment addAttachment(Id parentId,string Name)
    {
            Blob b = Blob.valueOf('Test Data');
            Attachment attachment = new Attachment();
            attachment.ParentId = parentId;
            attachment.Name = Name;
            attachment.Body = b;
            return (attachment);
    }

    /**
     * Get a case record.
     */
    public static Case getCase() {
        Case caseObj = new Case(Origin = 'Test Class',
                                Subject = 'Test Subject',
                                Type = 'TPA',
                                Status = 'New',
                                OwnerId = UserInfo.getUserId());
        return caseObj;
    }

    /**
     * Get a EmailMessage record.
     */
    public static EmailMessage getEmailMessage() {
        Case caseObj = getCase();
        insert caseObj;
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.FromAddress = 'Test@test.com';
        emailMsg.ToAddress = 'test@a-14fozmyxl4psai088lb5b6q3tiv9onsn4eyf9izlq6227wdj46.7-8guleam.na5.case.salesforce.com';
        emailMsg.Subject = 'Test Subject';
        emailMsg.TextBody = 'Test Body';
        emailMsg.ParentId = caseObj.Id;
        return emailMsg;
    }

    public static dsfs__DocuSign_Status__c getDocusignStatus(Id reqId)
    {
        List<dsfs__DocuSign_Status__c> lstStatus = new List<dsfs__DocuSign_Status__c>();
        lstStatus = [select id,TPA_Request__c,dsfs__Subject__c,dsfs__Sender_Email__c,dsfs__Sender__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c limit 1 ];
        if(lstStatus.size() == 0)
        {
            dsfs__DocuSign_Status__c objDocusignStatus = new dsfs__DocuSign_Status__c(
                dsfs__Envelope_Status__c = 'Sent',
                dsfs__DocuSign_Envelope_ID__c = '86D7009C-8254-4835-B52E-F3A98757AAAU',
                dsfs__Subject__c = ' IQVIA TPA Program: TPA-0000, Signature Request for TPA Test A TLLA',
                dsfs__Sender__c ='IQVIA Third Party Access Program',
                dsfs__Sender_Email__c = 'sender.mail@gmail.com',
                TPA_Request__c = reqId
            );
            insert objDocusignStatus;
            return objDocusignStatus;
        }
        else
        {
            return lstStatus[0];
        }
    }

    public static dsfs__DocuSign_Status__c getNewDocusignStatus() {
        return new dsfs__DocuSign_Status__c();
    }

    public static dsfs__DocuSign_Recipient_Status__c getNewDocusignRecipientStatus(dsfs__DocuSign_Status__c objDocusignStatus) {
        return new dsfs__DocuSign_Recipient_Status__c(
            Name ='Test Recipient Name',
            dsfs__Parent_Status_Record__c = objDocusignStatus.id,
            dsfs__DocuSign_Recipient_Email__c = 'test.contact@gmail.com',
            dsfs__Recipient_Status__c = 'Delivered',
            dsfs__Envelope_Id__c = objDocusignStatus.dsfs__DocuSign_Envelope_ID__c
        );
    }


    public static TPA_AMA_Settings__c createAMASetting()
    {
        String templateid = getTestEmailTemplateId();
        system.debug('templateId2: ' + templateId);
        list<TPA_AMA_Settings__c> amaSettingList = new list<TPA_AMA_Settings__c>();//bulk List of custom setting object for bulk insert

        TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c(); //Custom Setting for Contact Fields
        amaSettingObj.Name='CreatedDate';//Static record 1 of custom setting
        amaSettingObj.Mail_Addresses_for_Amendment_To_DBL__c   =  'supriya.johari@metacube.com;chandra.pandey@metacube.com';
        amaSettingObj.Vendor_Renewal_Cancelation_Status__c  = 'Vendor Canceled ?17 AMA-TPA Exp-12/31/16';
        amaSettingObj.Billing_SAP_Report_For_Year__c = '2018';
        amaSettingObj.Dev_Mail_ID__c = 'test1@test.com;test2@test.com';
        amaSettingObj.Send_Renewal_Notification__c = true;
        amaSettingObj.AMA_SAP_Report_Mail_Template_Id__c = templateid;
        amaSettingObj.AMA_SAP_Report_Mail_Template_Id_NextYr__c = templateid;        
        amaSettingObj.To_Address_for_AMA_SAP_Report__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_for_AMA_SAP_Report__c = 'supriya.johari@metacube.com';
        amaSettingObj.Exclude_Test_Records_in_Report__c = true;
        amaSettingObj.CC_address_Vendor_Renewal_Notification__c = 'vendor.renewal@test.com';
        amaSettingObj.Vendor_Renewal_Notification_Template_Id__c = templateid;
        amaSettingObj.Cancelation_Link_For_DBL_Template_ID__c = templateid;
        amaSettingObj.Cancelation_Noti_To_TPUS_Template_ID__c = templateid;
        amaSettingObj.CC_Address_For_Vendor_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_DBL_Cancelation_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_TP_US_Cancelation_Mail__c  = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_All_The_AMA_Mails__c = 'testama@test.com';
        amaSettingObj.CC_Address_For_DBL_Offshore_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.CC_Address_For_Vendor_Offshore_Mail__c = 'supriya.johari@metacube.com';
        amaSettingObj.Revised_Offshore_AMA_Reminder_TempId__c = templateid;
        amaSettingObj.Revised_Offshore_Vendor_Reminder_TempId__c = templateid;
        amaSettingObj.Last_Day_Of_Year__c = '12-31';
        amaSettingObj.Vendor_Canceled_AMA_TPA_EXP_12_31__c = DateTime.newInstance(Date.newInstance(2025, 12, 31), Time.newInstance(0,0,0,0));
        amaSettingObj.Vendor_Cancelation_Reminder_Template_Id__c = templateid;
        amaSettingObj.AMA_Cancelation_Reminder_Template_Id__c = templateid;
        amaSettingObj.AMA_Cancellation_Summary_Receipt_TempId__c = templateid;
        amaSettingObj.DBL_Renewal_Notification_Template_Id__c = templateid;
        amaSettingObj.Offshore_Vendor_Reminder_Template_Id__c = templateid;        

        amaSettingList.add(amaSettingObj);

        insert amaSettingList;
        return amaSettingObj;
    }

    // Get TPA_AMA_Settings__c record without inserting it.
    // public static TPA_AMA_Settings__c getAMASettingTemplate() {
    //     TPA_AMA_Settings__c amaSettingObj = new TPA_AMA_Settings__c();
    //     amaSettingObj.Name = 'CreatedDate';
    //     amaSettingObj.Mail_Addresses_for_Amendment_To_DBL__c = 'test1@test.com;test2@test.com';
    //     amaSettingObj.Vendor_Renewal_Cancelation_Status__c = 'Vendor Canceled ?17 AMA-TPA Exp-12/31/16';
    //     amaSettingObj.Billing_SAP_Report_For_Year__c = '2018';
    //
    //     return amaSettingObj;
    // }

    public static IMS_Master_Legal_Entity__c getImsMasterLegalEntityWithValue(Boolean isInsert, String entityAdd, String entNameTlla, String entTitle, String locGovLaw, String nameForEsign) {
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c();
        if(entityAdd != null) {
            imsMasterLegalEntity.IMS_Entity_Address__c = entityAdd;
        }
        if(entNameTlla != null) {
            imsMasterLegalEntity.Legal_Entity_Name_for_TLLA__c = entNameTlla;
        }
        if(entTitle != null) {
            imsMasterLegalEntity.Legal_Entity_Title__c = entTitle;
        }
        if(locGovLaw != null) {
            imsMasterLegalEntity.Location_of_Governing_Law__c = locGovLaw;
        }
        if(nameForEsign != null) {
            imsMasterLegalEntity.Name_for_ESign__c = nameForEsign;
        }

        if(isInsert) {
            insert imsMasterLegalEntity;
        }
        return imsMasterLegalEntity;
    }

    public static IMS_Master_Legal_Entity__c getImsMasterLegalEntity() {
        IMS_Master_Legal_Entity__c imsMasterLegalEntity = new IMS_Master_Legal_Entity__c(Name = 'IQVIA Ltd.',
                                                                                         Legal_Entity_Name_for_TLLA__c = 'IQVIA Ltd.',
                                                                                         Name_for_ESign__c = 'Test Esign',
                                                                                         Legal_Entity_Title__c = 'test title');
        insert imsMasterLegalEntity;
        return imsMasterLegalEntity;
    }

    public static IMS_Legal_Entity__c getImsLegalEntity(TPA_Request__c testAgreement, IMS_Master_Legal_Entity__c imsMasterLegalEntity) {
        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test',
                                                                     TPA_Request__c = testAgreement.Id,
                                                                     IMS_Master_Legal_Entity__c = imsMasterLegalEntity.Id);
        insert imsLegalEntity;
        return imsLegalEntity;
    }

    /**
    * Get IMS_Legal_Entity__c record without insert
    */
    public static IMS_Legal_Entity__c getImsLegalEntity_Template() {
        IMS_Legal_Entity__c imsLegalEntity = new IMS_Legal_Entity__c(Name = 'Test');
        return imsLegalEntity;
    }

    /**
    * Get TPA_Status_Sequence__c record without insert
    */
    public static TPA_Status_Sequence__c getTpaStatusSequenceRecord(string seqName, string statusValue) {
        TPA_Status_Sequence__c tpaStatusSeq = new TPA_Status_Sequence__c(Name = seqName, Status_Value__c = statusValue);
        return tpaStatusSeq;
    }

    public static Group createGroup( String groupName ) {
        return new Group( Name = groupName );
    }

    /*
    Method queries test Tpa Request.
    */
    public static TPA_Request__c queryTPARequest()
    {
        TPA_Request__c tpaRequest = [SELECT Client_Region__c,
                                           Data_Provided_By__c,
                                           Is_Data_Accessed_Via_IMS_Software__c,
                                           AMA_USPrescriberData__c,
                                           Does_the_request_require_information_con__c,
                                           Is_CPC_Renewal_Notice_Sent__c,
                                           Is_CPC_Expiration_Notice_Sent__c,
                                           Authorized_Signer_Email__c,
                                           Client_Language__c,
                                           Vendor_Language__c,
                                           Is_Submitted__c,
                                           Request_Status__c,
                                           Data_Access_End_Date__c,
                                           TP_Processor_Email__c,
                                           Authorized_Signer_First_Name__c,
                                           Authorized_Signer_Last_Name__c,
                                           Authorized_Signer_Title__c,
                                           Client_Contact_Territory__c,
                                           Client_Project_Name__c,
                                           Data_Delivered_By__c,
                                           Frequency_Of_Delivery__c,
                                           Frequency_of_Delivery_Other__c,
                                           FrequencyOfDeliveryToServiceProvider__c,
                                           FrequencyOfDeliveryToSP_Other__c,
                                           IMS_Data_Country_Location__c,
                                           IMS_Data_Country_Location_Values__c,
                                           List_Of_Uses__c, 
                                           Offerings_With_Category__c,
                                           PurposeWithDataAsset__c,
                                           Secondary_Client_Contact_Territory__c,
                                           Secondary_Location_Required__c,
                                           Total_Deliveries__c,
                                           U_S_Prescriber_Level_Data_Outside_US__c,
                                           Vendor_Billing_Mailing_City__c,
                                           Vendor_Billing_Mailing_Country__c,
                                           Vendor_Billing_Mailing_State_Province__c,
                                           Vendor_Billing_Mailing_Street__c,
                                           Vendor_Billing_Mailing_Zip_Post_Code__c,
                                           Vendor_Company_Name__c,
                                           Vendor_e_mail__c,
                                           Vendor_Contact_Email_Client__c,
                                           Vendor_Contact_First_Name_Client__c,
                                           Vendor_Contact_Last_Name__c,
                                           Vendor_Contact_Last_Name_Client__c,
                                           Vendor_Contact_Phone__c,
                                           Vendor_Contact_Telephone_Client__c,
                                           Vendor_Contact_Title__c,
                                           Vendor_Employee_Country_AMA__c,
                                           Vendor_First_Name__c,
                                           Vendor_Phone__c,
                                           Vendor_Website__c,
                                           Region__c,
                                           Is_Potential_Vendor_Case__c
                                        FROM TPA_Request__c LIMIT 1];
        return tpaRequest;
    }

    /*
    Method queries test Agreement.
    */
    public static TPA_Request__c queryAgreement(TPA_Request__c tpaRequest)
    {
        TPA_Request__c tpaAgg = [Select id,
                                                Name,
                                                Request_Status__c,
                                                Data_access_end_date__c,
                                                Vendor_e_mail__c,
                                                Client_Language__c,
                                                Vendor_Language__c
                                            FROM TPA_Request__c
                                            WHERE Id =: tpaRequest.Id LIMIT 1];
         return tpaAgg;
    }

    /**
     * Method to create TPA_RequestDocument__c record
     */
    public  static TPA_RequestDocument__c getTPARequestDocument(TPA_Request__c tpaRequest) {
        TPA_RequestDocument__c objTPARequestDocument = new TPA_RequestDocument__c(Version__c = 5,
                                                                                  Document_Type__c = 'CP',
                                                                                  Document_Id__c = '015V0000000Dzgj',
                                                                                  TPA_Request_Id__c = tpaRequest.Id);
        return objTPARequestDocument;
    }

    public  static Document getTestDocument(String FolderName) {
        Document testDoc = new Document(Body = Blob.valueOf('Some Text'), ContentType = 'application/pdf',
                                                                                  DeveloperName = 'my_document',
                                                                                 IsPublic = true,
                                                                                  Name = 'My Document');
        testDoc.FolderId = UserInfo.getUserId();
        insert testDoc;
        return testDoc;
    }



    /**
     * Method to create TPA_RequestDocument__c record
     */
    public static TPA_Contact__c getTestTPAContact(TPA_Request__c tpaRequest) {
         TPA_Contact__c tpaContact = new TPA_Contact__c(Type__c ='Additional Vendor Contact',
                                                        Email__c = 'test@gmail.com',
                                                        TPA_Request__c = tpaRequest.Id);
         return tpaContact;
    }

    public static void createTPASettingData()
    {
        list<TPA_Settings__c> TPA_SettingObjList = new list<TPA_Settings__c>();
        EmailTemplate e = UTL_TPA_SetupTestData.accessEmailTemplate('Vendor-Specific Notification: TP Processor Notification of Sales Communication R');
        TPA_Settings__c TPA_SettingObj1 = new TPA_Settings__c(
            Name = 'Test1',
            VendorMessageBoardId__c = 'test id',
            TPA_RequestSubmitted_Email__c = 'testemail@test.com',
            Base_Url__c = String.valueOf(URL.getOrgDomainUrl()),
            Shared_Email__c = 'a.a@a.com',
            VSN_TPProcessorSalesCommunicationResult__c = e.Id,
            TPA_DRN_Mails_Copy_To__c = 'drnemailtest@test.com',
            TPA_Mail_ID__c = 'tpatestemail@test.com',
            TP_US_Mail_Id__c = 'ustestemail@test.com',
            Is_Potential_Vendor_Submitted__c = true,
            TPA_Auto_Exception_Rpt_Recepients_Local__c = 'tpatestemail@metacube.com',
            Manual_Review_For_Special_Client_And_Use__c = '001c0000016NHg9~Prescriber List Match only for overlap analysis, no prescriber communication',
            TPA_External_Client_Reports__c = '00O4C000000JUIk~test@test.com;',
            TPA_External_Client_Reports_Email_Copies__c = 'test1@test.com',
            TPA_Client_Community_Url__c = String.valueOf(URL.getOrgDomainUrl()),
            TPA_Template_Id__c = e.Id,
            IMS_health_logo_url__c = String.valueOf(URL.getOrgDomainUrl())+'/servlet/servlet.FileDownload?file=0150n0000000lMB',
            Enable_Commercial_Review_Automation__c = true,
            TPA_New_Helpful_Hints_Functionality_Date__c = Date.newInstance(2020, 11, 01),
            TPA_Supported_Languages__c = 'English~Japanese~French',
            TPA_50_or_More_Licenses_Email_Ids__c = 'testID1@test.com;testID2@test.com'
        );

        TPA_SettingObjList.add(TPA_SettingObj1);
        insert TPA_SettingObjList;
    }

    public static Address__c createTestAccount(String name, Integer regNum)
    {
        Address__c TestAccount;
        List<Address__c> ListAccount = [Select id, Name From Address__c where vendor_registration_number__c =: regNum  LIMIT 1];
        if(ListAccount.size() == 0)
        {
            TestAccount = new Address__c(Name = name, CurrencyIsoCode = 'USD', recordTypeId = getTPAVendorAddressRecordTypeId,
                                          is_tpa_account__c = true,vendor_registration_number__c = regNum);
            insert TestAccount;
        }
        else
        {
            TestAccount = ListAccount[0];
        }
        return TestAccount;
    }

    public static Contact createTestContact(String lastName, Id accountId )
    {
        Contact testcontact = new Contact(firstName = 'testfirstname', LastName = lastName, AccountId = accountId, Email = 'test@metacube.com');
        insert testcontact;
        return testcontact;
    }

    public static TPA_Request__c createTestTPARequest(Id vendorAccountId )
    {
        TPA_Request__c tpaRequest = new TPA_Request__c(
          OwnerId = UserInfo.getUserId(),
          Client_Region__c = 'US',
          Data_Provided_By__c = 'IQVIA in lieu of Client',
          Is_Data_Accessed_Via_IMS_Software__c = 'Yes',
          AMA_USPrescriberData__c = 'Yes',
          Does_the_request_require_information_con__c = 'Yes',
          Service_Provider_Address__c = vendorAccountId,
          TPA_Request_Marked_as__c = 'Public',
          Vendor_Company_Name__c = 'Test company',
          LastAction__c = 'Request Edited By Client',
          Is_Submitted__c = true
        );
        insert tpaRequest;
        return tpaRequest;
    }

    public static TPA_Request__c CreateTestRequest(Id clientActId, Id AccountId)
    {
        date strtDate = date.today();
        TPA_Request__c TestRequest;

        List<TPA_Request__c> ListAgg = [Select id,Name,TP_Processor_Email__c,OwnerId,Vendor_Contact_First_Name_Client__c,Is_Mail_Feature_Required__c,Service_Provider_Address__c,Data_Access_End_Date__c,Request_Status__c,TPA_Authorised_Signer__c,LastAction__c,Is_Submitted__c From TPA_Request__c
                                                   where Name like 'TestRequest' LIMIT 1];
        if(ListAgg.size() == 0)
        {
            TestRequest = new TPA_Request__c(
                OwnerId = UserInfo.getUserId(),
                Is_Mail_Feature_Required__c = true,
                is_submitted__c = true,
                Data_Access_Start_Date__c=strtDate,Data_Access_End_Date__c=strtDate.addDays(2),
                Requires_Manual_Review__c = false,
                TP_Processor_Email__c = 'a.a@gmail.com',
                TP_Processor_Name__c = 'Test TP Processor',
                Vendor_Contact_e_mail__c = 'vendor.email@gmail.com',
                TPA_Authorised_Signer__c = 'Yes',
                Client_Address__c = clientActId,
                Service_Provider_Address__c = AccountId,
                Authorized_Signer_Email__c = 'email.authorised@gmail.com',
                Request_status__c = 'Awaiting Vendor Signature',
                Vendor_Contact_First_Name_Client__c = 'Test Client First Name'

            );
            insert TestRequest;
        }
        else
        {
            TestRequest = ListAgg[0];
        }

        return TestRequest;
    }

    public static Watch_List__c createWatchList( Id accountId )
    {
        return new Watch_List__c( Vendor_Address__c = accountId );
    }

    public static Apttus__APTS_Template__c createNewTemplate() {
        return new Apttus__APTS_Template__c();
    }

    public static TPA_Logs__c createTpaLog() {
        //TPA_Logs__c tpaLogObj = new TPA_Logs__c(GUID__c = TPAQueryHelper.Guid, Log_Detail__c = 'Test Detail', Log_Type__c = 'Custom', Other_Details__c = 'Other Detail', Record_Id__c = 'By Test Class');
        //insert tpaLogObj;
        return new TPA_Logs__c();
    }
}