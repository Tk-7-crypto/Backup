/* Created By : Ranu
 * Last modified by : Ranu
 * Dependent Triggers : Market_Definition_Validation on AGLI
 * Dependent classes : SCM_GenerateSelfServiceSelector
 */
public with sharing class ConstantClass {
    
    //Added by Abhishek Bansal : 12-feb-2015 : ER-1564 : Start 
    public static String Retainer_Billing_Model = 'Retainer [31]';
    //Added by Abhishek Bansal : 12-feb-2015 : ER-1564 : End
    
    public static boolean StopAggTriggerOnRolligupRevnYear = false ;// Added by Sandeep Singhal Date 5th July 2013 for Issue-02569 to avoid SOQL 101 on AgLi's Net price change. This flag will be reset in "SCM_Fee_Rollup_Yearly_Revenue" trigger.
    public static boolean IsStopReversibleSyncAgreementToOppty = false;//Issue - 4013 added by jay
    
    //Added By:- Rakesh , Date :-15, Dec , 2014, details:-Issue-05953
    public static boolean allowNameChangeATAgreementCreation = false;
    
    //Added By Naveena ER 797
    //Added By:- Ekta , Date :- April 23, 2015 , Details:- Issue-06887
    public static Boolean hasMasterCodeExcecuted = false ;
    //flag variable to stop recursive trigger call on BNF : ER 797 :05/05/2014
    public static Boolean stopRecursiveTriggerBNF = false;
    
    //flag variable to stop recursive trigger call on Agreement : ER 797 05/05/2014
    public Static Boolean stopRecrsvTriggerAgreement = false;
    //Updated by: Ranu: Issue 2450 : Too many SOQL queries on Add Product functionality. - START
    public static List<User> presentUser = new List<User>();
    public static List<Profile> presentProfile = new List<Profile>();
    
    public static boolean AllowAGLIUpdate = true ;// Added by Sandeep Singhal Date 4 July 2013 ER-0497
    //*******************Added this flag by Sandeep Singhal Date 16 April 2013 To fix issue 1951 To Allow ALGLI and OLI Sync when Agreement gets created for not permitted users (Not having record in Custom Setting Agreement Oppty Map Setting)***********************/    
    public static boolean IsFirstTimeAgreementCreation = false;
    // Added by Sandeep Singhal for issue 02221 ( To Allow Creatigng Agreement lineitem Schedules when 1-1 mapping off)
    public static boolean AllowSchedulCreation_when_MapingOff_AGLICreation = false;
    
    
    
    //Added By Sweta :: Detais:ER-1888 Date:18/06/2015
    public static boolean allow_status_and_Status_Category_to_Update = True;
    /***************** Page Messages ************************************/
    // Create agreement Button on Agreement
    public static String msg_BillTo_ContractTo_required = 'Bill To and Contract To are required fields for converting to SOW';
    
    // Create agreement Button on Agreement :Academia : Issue 5151 : Added by Naveena : 25-08-2014
    public static String msg_ContractTo_required = 'Contract To is required field for converting Academia to SOW';
    
    //Issue_1729 
    //Updated By Rakesh :  12 Sept 2013 :: ER-478
    //**** START *****
    //public static String MSG_MKTDEFS_REQUIRED_SOW = 'Please select market defs for All Agreement Line Items or reset Market Definition options from \'Select Market Def to \'None\' to generate SOW.';
    public static String MSG_MKTDEFS_REQUIRED_SOW = system.Label.Market_Definition_Option_Msg;
    //***** END  **** 
    public static boolean isUpdatedBySystemAdmin = false; //added by ranu ER-441 to stop the code run when user use button - add opportunity OR change opportunity on agreement object
    //Added By Dhruv :10-3-2015 :ER 1667 : This variable will used in SCM_AgreementTriggerHelper so RequestCount and SendForSignatureCount will be increase only once .
    public static boolean isCountForRequestSignatureIncreased=false ; 
    
    //Added by dhruv : ER 2834 :date 22-07-2016 :boolean field to track current agreement record type
    public static string currentAggRecordType ='';
    public static list<dsfs__DocuSign_Envelope_Document__c> listOfEnvelopeDocumentInserted ;
    //Ended By Dhruv   
    
    //Added By Rakesh : 1 Aug 2014 : Issue-4985 :: This variable is used to stop fee schedule calculation of agreement when ever an agreement product
    //is added to agreement. Because fee schedule is calculated at the time of agreement product insertion. So no need to recaluculate fee schedule
    //This varible is used to stop SCM_Fee_AGLI_ToKeepInSync_with_OLI trigger on OLI when we add product using ProductSearchControllerExt class
    public static boolean allow_Update_AggFeeSchedule_WhenOLIGetUpdated = true;
    
    //Added by sweta Details:ER-2834/Issue-9441 Date:15/09/2016
    public static boolean stopRecrsvTriggerAgreementQuestion = false ;
    
   /********************* Pick list vlaues ******************************/
    
    public static String Agreement = 'Agreement' ;
    public static String AggWithProd = 'With Products' ;
    public static String AggWithProdAndATC = 'With Products And Market Definition' ;
    public static String Clone_All = 'With Products And Market Definition And Discount';
    public Static String select_AtLeast_One_Option  = 'Please select atleast one clone option.' ;
    
    //Added By:-Ekta ,Date-4th July,2013 ,Details:-ER-417
    public static Boolean currencyChangedFlag = false;
    
    Public static List<String> segments;
    Public static LIST<String> getOfferingSegmensPickListValues() {
        segments = new List<String>();
        
        //Updated By Rakesh : 23 Jan 2015 : Change segments.add('CES'); hard coded value of 'CES' to System.Label.SCM_Product_Offering_Type
        //segments.add('CES');  //Added By : Ranu Issue_1657
        segments.add(System.Label.SCM_Product_Offering_Type); 
        segments.add('Clinical Trials');
        segments.add('Consumer Health');
        segments.add('Government');
        segments.add('Healthcare Value Solutions');
        segments.add('Management Consulting');
        segments.add('MIDAS and Pricing Insights');
        segments.add('National');
        segments.add('Non Pharma and Barter');
        segments.add('Payer');
        segments.add('Provider');
        segments.add('Real World Evidence Solutions');
        segments.add('Subnational');
        segments.add('Syndicated Analytics');
        segments.add('Syndicated BI Tools');
        return segments;
        
    }
    
    
    //Added By:-Ekta,Date:-6th May,2013,Details:-Issue-02089(Stop from creating new agreement line item on before insert)
    public static Boolean hasCreateAgli=true;
    public static Boolean isAglisDeletedbyOLI = false; //variable which sets to true when agli is eleted as a rsult of oli deletion when sync is on Added ny Ranu Date : 25ht June'13 Issue_02305 ER-410
    //Added By Rakesh : 20 Jan 2014 : Issue-03463
    public static Boolean updateAccountAddress = false;
    
    //Added By Rakesh : 26 Feb 2014 : ER-459
    public static Boolean allowValidationOnDeleteMasterAgg = true;
    
    //Added By Rakesh : 14 March 2015 : Issue-6502
    public static boolean stopAggProductDeletionOnChangePrimaryOpp = false;
    
    //Added By Rakesh : 3 July 2015 : Issue-7293
    public static boolean stopAGLIUpdation_At_6a_OppStage = true; 
    
    /* Added By : Ranu Jain,5th Nov picklist values for Master Agreement on Agreement obj */
    public static String renew = 'Renew';
    public static String amend = 'Amend';
    public static String existing = 'Existing';
    public static String standAlone = 'Stand-alone';
    //Commented By Dhruv : ER 2123 : 6 august 2015 : Commented as NEW agreement type has to be removed :Start
    //public static String newMA = 'New';
    
    
    /* Added By : Ranu Jain,5th Nov
* picklist values for Agreement Category on Agreement obj */
    public static String Multiple_Offering = 'Multiple Offering';
    
    /* Added By : Ranu Jain,5th Nov
	 * picklist values for /* Added By : Ranu Jain,5th Nov
	 * picklist values Account status 
	 */
    public static String sapValidated = 'SAP Validated';
    
    /** Market Def functionality **/
    //Added by :Ranu,date : 12th Feb,2013 Detail : used in : 
    public static String All_MARKETS = 'All Markets';
    public static String SELECTED_MKT_DEF = 'Selected Market Defs';
    public static String N_A = 'N/A';
    
    /********************** Pick list vlaues End *****************************/
    
    /********************** Record Types *************************************/
    // Record type for Market Definition Object
    public static String MFR    = 'MFR' ;
    public static String USC    = 'USC' ;
    public static String BRAND  = 'BRAND' ;
    public static String SPECIALITY  = 'SPECIALITY' ;
    public static String ATC  = 'ATC' ;
    
    public static String SelectOption = '--Select--' ;
    public static List<String> recordType ;
    
    //record type list for Market Definition Object
    public  static  void createRecordTypeLst (){
        recordType = new List<String>();
        recordType.add('ATC');
        recordType.add('BRAND');
        recordType.add('MFR');
        //Added By Rakesh : 11 Nov 2013 : ER-612
        recordType.add('NEC');
        recordType.add('SPECIALITY');
        recordType.add('USC');
    }
    
    
    /* Ranu Jain,Date : 19th Oct 
	 * Record types for Agreement Object 
	 */
    public static String Proposal = 'Proposal';
    public static String SOW = 'SOW';
    //Added below Japan_Master by Naveena : ER 522 : 5 Dec 2014 :begin
    public static String Japan = 'Japan Agreement';
    public static String Japan_Master = 'Japan Master Agreement';
    //Added below Japan_Master by Naveena : ER 522 : 5 Dec 2014 :end
    public static String Master_Agreement = 'Master Agreement';
    //added by smita -  ER 463 2 july - START
    // Updated by Smita Pandey: 24 Dec 2013 - ER 555 - renamed self service to quick contract and full service to standard contract
    public static String Self_Service ='Quick Contract';
    
    //added by jay ER - 785
    public static String Basic_Agreement_Detail = 'Basic Agreement Detail';
    
    
    /************* Boolean Variables *********************************/
    
    // Added by sandeep to fix issue Issue-01101 date 26 oct 2012
    public static Boolean  ToAvoidTriggerCycle = false ; 
    
    /************* Boolean Variables Ends *********************************/
    
    
    
    /********************* General methods used in SCM functionalities *********************************/
    /*
     * 
     * Agreement account address info -  MDMController
     */
    
    
    /* Method Created By: Ranu Jain, Date : 12th July
     * Detail : this method is created to handle wild char search text box
     */
    
    /** Error message declaration **/ 
    private static final String WILD_CHAR_ENTER_MSG = Label.WILD_CHAR_ENTER_MSG;
    
    //Added By Rakesh : 15 oct 2014 : Issue-4709
    public static boolean allowTriggersOn_Term_And_GenAggTerm_Objects = true;
    
    public  static boolean checkForWildChar(String searchByString) {
        String charcntString =  searchByString.replaceAll('\\*','');
        charcntString = charcntString.replaceAll('%','');
        if(charcntString.length() <= 0) {
            
            ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error, WILD_CHAR_ENTER_MSG );
            ApexPages.addMessage(infoMsg);
            // return;     
            return true ;
        }
        return false;
    }
    
    // method convert * to % in any search string 
    public static String wildcardCharSearch(String searchString) {
        if((searchString != '' && searchString != null) && ( searchString.contains('*')) ) {
            searchString = searchString.replace('*','%');
            
        }  
        return searchString;
    }
    
    // Get the ID for a Record Type, given its Name. Note
    // that this is NOT the Developer Name but rather the Name(label).
    public static ID getRecordTypeId(String objType, String name)
    { 
        SObject obj;
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objType);
        if (targetType != null)
        {
            obj = targetType.newSObject();
            Schema.DescribeSObjectResult d = obj.getSObjectType().getDescribe(); 
            if (d != null)
            {
                Map<String, Schema.RecordTypeInfo> rtMap = d.getRecordTypeInfosByName();
                if (rtMap != null) 
                {
                    Schema.RecordTypeInfo rtInfo = rtMap.get(name);
                    if (rtInfo != null) 
                    {
                        return rtInfo.getRecordTypeId();
                    }
                }
            }
        }
        return null;
    }
    
    //added by ranu - 0356 
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ return null; }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        
    }
    
    
    //Method Added by:Ranu Jain Date:12th july'13 Issue 02450 : Too many SOQL queries on Add Product. - START
    public static List<User> getUserDetails(){
        if(presentUser.size() <= 0 )
        {
            //presentUser = [select id,Name, Profile.Name,User_Country__c from User where Id =: UserInfo.getUserId()] ;
            // Updated By sweta Details: Issue-10347 Date:14/02/2017 added ObjUser.Profile.UserLicense.Name field in SOQL
            presentUser = [select id,Name, Profile.Name,User_Country__c,Profile.UserLicense.Name,(SELECT AssigneeId , PermissionSet.Label FROM PermissionSetAssignments) from User where Id =: UserInfo.getUserId()] ;
        }
        system.debug('###@@@&&&123'+ presentUser.size()+ presentUser[0].Id );
        return presentUser;
    }
    
    //Method Added by:Ranu Jain Date:12th july'13 Issue 02450 : Too many SOQL queries on Add Product. - START
    public static List<Profile> getProfileDetails(){
        if(presentProfile.size() <= 0 )
        {
            //Updated By:-Ekta,Date:-8th July ,2014, Details:- Issue - 4756
            presentProfile = [select id , Name from Profile where id = : userinfo.getProfileId()];
        }
        //  system.debug('###@@@&&&123'+ presentUser.size()+ presentUser[0].Id );
        return presentProfile;
    }
    
    
    public static User createUser()
    {
        User u = new User();
        Profile p = [select id from profile where name='System administrator'];
        u = new User (
            alias               = 'testUser',
            email               = 'standarduser@metacube.com',
            emailencodingkey    = 'UTF-8', 
            lastname            = 'Testing',
            languagelocalekey   = 'en_US', 
            localesidkey        = 'en_US',
            profileid           = p.Id,
            timezonesidkey      = 'America/Los_Angeles', 
            username            = 'SCMteststandarduser@metacube.com',
            IsActive            = true,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            employeenumber=String.valueOf(System.currentTimeMillis())
        );
        insert u ;
        return u;
    }
    
    //Method to check if a user is authorize to use 'AUTHOR TOOL'
    //Added by Jyotsna :Issue-03737:Date-25-02-2014 
    //Updated By:-Ekta,Date:-8th July ,2014, Details:- Issue - 4756
    public static Boolean validateAuthorizeUser(string paramUserProfileName ,List<PermissionSetAssignment> PermissionSetList)
    {
        Boolean RetVal = false;
        
        if( paramUserProfileName.contains('client services') || paramUserProfileName.contains('Sales')) {
            RetVal = true;
        }
        
        for(PermissionSetAssignment PermissionAss: PermissionSetList )
        {
            if((PermissionAss.PermissionSet.Label.toLowerCase().contains('read')) 
               && (PermissionAss.PermissionSet.Label.toLowerCase().contains('only')) 
               && (PermissionAss.PermissionSet.Label.toLowerCase().contains('scm')) 
               || ((PermissionAss.PermissionSet.Label.toLowerCase().contains('edit')) 
               && (PermissionAss.PermissionSet.Label.toLowerCase().contains('scm')))) {                   
                RetVal = true;
                break;
            }
        }
        return RetVal;
    }
    
    //Method to return users permission set ie sales , client or legal
    //Added by Naveena :ER 785 :Date-14-07-2014 
    public static String permissionSetUser(string paramUserProfileName ,List<PermissionSetAssignment> PermissionSetList )
    {
        String RetVal = '';
        for(PermissionSetAssignment PermissionAss: PermissionSetList )
        {
            if((PermissionAss.PermissionSet.Label.toLowerCase().contains('scm'))&&(PermissionAss.PermissionSet.Label.toLowerCase().contains('edit'))) {                  
                RetVal = 'sales';
                break;
                
            }
            else if((PermissionAss.PermissionSet.Label.toLowerCase().contains('scm'))&&(PermissionAss.PermissionSet.Label.toLowerCase().contains('read'))&& (PermissionAss.PermissionSet.Label.toLowerCase().contains('only'))) {
                RetVal = 'client';
                break;
            }
            else if (PermissionAss.PermissionSet.Label.toLowerCase().contains('author')&&(PermissionAss.PermissionSet.Label.toLowerCase().contains('scm'))) {
                RetVal = 'author';
                break;
            }
        }
        return RetVal;
    }
    
    //Added By Dhruv :ER 1584 : Date 5-3-2015 started
    //Method will return whether user is valid us user of SCM or not 
    public static boolean isValidUSUser(List<PermissionSetAssignment> PermissionSetList)
    {
        boolean retValue=false ;
        if(PermissionSetList!=null && PermissionSetList.size()>0 )
        {
            for(PermissionSetAssignment PermissionAss: PermissionSetList )
            {          
                if(PermissionAss.PermissionSet.Label.toLowerCase().contains('scm') && PermissionAss.PermissionSet.Label.toLowerCase().contains('us'))
                {                 
                    retValue=true ;
                }
            }
        }
        return retValue;
    }
    
    public static Boolean isFinComAgreement(Agreement__c agg)
    {
       if(agg!=null &&
           !String.isBlank(agg.Agreement_Category__c) && 
           !String.isBlank(agg.IMS_Legal_Entity__c) &&
           agg.Agreement_Category__c == 'FinCom' &&
           (agg.IMS_Legal_Entity__c == 'IMS Health Incorporated'
            //Added by dhruv : ER 3194 : date 02-10-2016
            || agg.IMS_Legal_Entity__c == Label.Quintiles_IMS_Incorporated
            //Added by Prakhar : ER 4045 Branding for Rapid SOW : 3rd November 2017
            || agg.IMS_Legal_Entity__c == Label.Iqvia))
        {
            return true ;
        }
        return false ;
        
    }
    
    //Ended by dhruv : ER 2186 :  dATE 21-9-2015 :    
    
    public static List<User> CreateUser(Integer numUsers,String ProfileType,String sidkey){
        Profile p = [SELECT Id FROM Profile WHERE Name like :'%'+ProfileType+'%' Limit 1];
        List<User> users= new List<User>();
        
        User u = new User();
        // Profile p = [select id from profile where name='System administrator'];
        u = new User (
            alias               = 'testUser',
            email               = 'standarduser@metacube.com',
            emailencodingkey    = 'UTF-8', 
            lastname            = 'Testing',
            languagelocalekey   = sidkey,
            localesidkey        = 'en_US',
            profileid           = p.Id,
            timezonesidkey      = 'America/Los_Angeles',
            username            = 'SCMteststandarduser1@metacube.com', //Updated by Ajinkya Pande on 23rd mar for ER - 4045 Branding Changes for US 10
            IsActive            = true,
            Change_Request_Description__c = 'test',
            Change_Request_Ticket_Number__c ='test description',
            EmployeeNumber ='77777'+String.valueOf(System.currentTimeMillis())
        );
        users.add(u);
        insert users;
        return users;
    }
    
    //Added Method By sweta:: Date:8/05/2015 Details:ER-1584 Phase-2
    /************************Start************************/
    Public static Boolean isSuperUser()
    {    
        List<GroupMember> grpMember = new List<GroupMember>([Select id from GroupMember where Group.Name = :System.Label.SCM_Super_User AND UserOrGroupId = :Userinfo.getUserId()]);
        Boolean isSuperUser=False; 
        if(grpMember != Null && grpMember.size() > 0 )
        {
            isSuperUser = true;
        } 
        return  isSuperUser;   
    }   
    /**************************End ER-1584 Phase-2 ********/     
    
    /*
Added By:-Ekta 
Date:- 19th May , 2015 
Details :- Issue-07033 , return access level of document 
*/
    public static String getAccessofDoc(String action)
    {
        String accessLevel = '';
        Apttus__APTS_Admin__c admin = [Select id from Apttus__APTS_Admin__c where Name = 'APTS_Protection' and (Apttus__Value__c = '1' OR Apttus__Value__c = 'true') limit 1];
        List<Apttus__Agreement_Protection__c> aggProtectionList = new List<Apttus__Agreement_Protection__c>();
        String userPermission = '';
        Set<String> perissionSetList = new Set<String>();
        String profileName = '';
        List<User> userList = ConstantClass.getUserDetails();  
        
        if(userList != Null && userList.size()>0)
        {
            for(PermissionSetAssignment permissionSet : userList[0].PermissionSetAssignments)
            {
                perissionSetList.add(permissionSet.PermissionSet.Label);
            }
            profileName = userList[0].Profile.Name;
        }
        return accessLevel ;
    }
    
    //Added By Dhruv : Date 21-7-2015 : Issue 07534 : Started : Method to change value of two different currency.
    
    //This is the Map which holds currency ISO Code and Conversion rate to USD .
    private static Map<string, decimal> CTCodeToConversionRateMap ;
    
    //This Method will return the map of currency ISO Code and Conversion rate to USD .
    public static Map<string, decimal> getCurrencyConversionMap()
    {
        //If CTCodeToConversionRateMap is not calculated in flow
        if(CTCodeToConversionRateMap == null || CTCodeToConversionRateMap.size() == 0)
        {
            //Initialized CTCodeToConversionRateMap .
            CTCodeToConversionRateMap = new map<string, decimal>();
            
            //Populated map CTCodeToConversionRateMap with ISO code and conversion rate
            for(CurrencyType  ct : [select ISOCode, ConversionRate from CurrencyType ])
            {
                CTCodeToConversionRateMap.put(ct.ISOCode, ct.ConversionRate);
            }
        }
        
        return CTCodeToConversionRateMap;
    }  
    
    //Ended By Dhruv : Date 21-7-2015 : Issue 07534 : Ended
    
    //Added By Dhruv : Issue 7913 : Date 2-9-2015 : If related account is not accessible it will return false :Start
    public static boolean isRelatedAccountAccessible(ID accID)
    {
        //Fetch list if account is accessible or not
        List<UserRecordAccess> AccountAccessList= [SELECT RecordId FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId = :accID AND HasReadAccess = true];
        if(AccountAccessList!=null && AccountAccessList.size()>0)
            return true ;
        else
            return false ;
    }
    //Ended By Dhruv : Issue 7913 : Date 2-9-2015 : If related account is accessible,it will return true :Ended
    
    //Added by dhruv : ER 3029 : date 13-10-2016
    public Static Boolean is_AMA_Record_Type_enabled(String profileName, List<PermissionSetAssignment> PermissionSetList )
    {
        for(PermissionSetAssignment PermissionAss: PermissionSetList )
        {
            if((PermissionAss.PermissionSet.Label.toLowerCase().contains('scm') && PermissionAss.PermissionSet.Label.toLowerCase().contains('author')  && PermissionAss.PermissionSet.Label.toLowerCase().contains('us')) || profileName.toLowerCase().contains('system admin')) 
            {                 
                return true;
            }
        }
        return false;  
    }
    //Ended by dhruv : ER 3029 : date 13-10-2016    
    //Added by dhruv :Issue 9924 : date 02-01-2017 : 
    /*public static void saveErrorRecordForDocusign(Exception e,String RecordID)
    {
        SCM_Log__c scmlog = new SCM_Log__c (Record_Id__c = RecordID, Log_Type__c='Exception', Log_Detail__c=e.getTypeName() + 'Error occured at line number'+e.getLineNumber()+'.Error is '+e.getMessage(), Other_Details__c=e.getStackTraceString());
        insert scmlog;
    }*/
    
    //Ended by dhruv : issue 9924 : Date 02-01-2017 :
	//Added By Rakesh : 12 Feb 2014 : ER-854 : Start
	public static boolean allowSalesOrgUpdateOnBNF_FromSCM = true;
  
	//Method to return map of sales org code and sales org name of MIBNF objects
  public static map<string, string> getSalesOrgNameinBNFSystem1(string objectName)
    {
      map<string, string> salesCodetoSalesOrgNameInBNFMap = new  map<string, string>();
        
        //get IMS_Sales_Org__c picklist using getDescribe
        Schema.DescribeFieldResult fieldResult = (objectName == 'MIBNF') ? MIBNF2__c.IMS_Sales_Org__c.getDescribe(): BNF2__c.IMS_Sales_Org__c.getDescribe() ;
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //Create a map of sales org code and it's values
        for( Schema.PicklistEntry f : ple)
        {
            if( f.getValue().contains('[') && f.getValue().contains(']'))
            {
                salesCodetoSalesOrgNameInBNFMap.put(f.getValue().substringBetween('[',']'), f.getValue()) ;
            }    
        }
        return salesCodetoSalesOrgNameInBNFMap;
    }
	
	
	//Method returns Agreement legal entity if there exist agreement for given opportunity 
    public static string checkAgreementLegalEntityForOpportunity(Id oppId, map<id, Opportunity> oppMapWithAgreements)
    {
      string legalEntity = ((  oppMapWithAgreements.containsKey(oppId)) && (oppMapWithAgreements.get(oppId).Proxy_SCM_Agreements__r != null) && 
                        oppMapWithAgreements.get(oppId).Proxy_SCM_Agreements__r.size() == 1 ) ? oppMapWithAgreements.get(oppId).Proxy_SCM_Agreements__r.get(0).IMS_Legal_Entity__c : '' ;
      return legalEntity;
    }

	//Method return sales org code based on agreement's legal entity
    public static string getSalesOrgCodeforAgreementLegalEntity(string legalEntity)
    {
      string salesOrdCode = '';
      //SCM_BNF_Sales_Org_Mapping__c legalEntityMapping = (!string.isblank(legalEntity)) ? SCM_BNF_Sales_Org_Mapping__c.getValues(legalEntity) : null ;
      //salesOrdCode = (legalEntityMapping != null && legalEntityMapping.IMS_Sales_Org_Code__c != null ) ? legalEntityMapping.IMS_Sales_Org_Code__c : '' ;
      return salesOrdCode;
    } 
    //End : ER-854 by Rakesh  
}