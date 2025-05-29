public class MDM_Defines
{
    //  ==================================================================
    //  Account defines
    //  ==================================================================
    
    public static final String MdmApprovalEmailAddress = 'mdmhelpdesk@imshealth.com';
    
    // Added By : Himanshu : Issue-02741 : 
    public static Boolean StopBNFTriggerExecution=false;
    
      // Added By : Himanshu Parashar
    // Date: 30 jan 2012
    // SAP Request using wizard
    public static final String Email_Template_DevName_MDM_New_Address_Request_Wizard = 'MDM_New_Address_Request_Wizard';
    public static final String Email_Template_DevName_MDM_New_Address_Request = 'MDM_New_Address_Request';
    public static final String Email_Template_DevName_MDM_New_SAP_Contact_Request= 'MDM_New_SAP_Contact_Request';
    public static final String Email_Template_DevName_MDM_New_Sales_Org_Request= 'MDM_New_Sales_Org_Request';
    public static final Map<String,String> AddressStatus_Map = new Map<String,String>{'NEW' => 'New',
                                                            'SAP_VALIDATED'=>'SAP Validated'};
    //  Account record type ID's                                                        
    public static final String SAP_Validated_Record_Type_Id = '01270000000UGes';
    public static final String New_Account_Record_Type_Id = '012700000009GqP'; 
    public static final String Super_Parent_Record_Type_Id = '012700000009GqU';
    
    //  Set of all countries which are included in synchronisation of accounts
    //  between SAP and SFDC
    public static final Set <String> MDM_Enabled_Countries = new Set<String>();
    
    //  ==================================================================
    //  BNF defines
    //  ==================================================================
    public static final Set<String> EnabledSalesOrgs = new Set<String>();
        //  Set of all sales orgs for which integration has been rolled out, but for which 
    //  Manual_Handling_In_SAP__c flag is always set 
    public static final Set<String> ManualSalesOrgs = new Set<String>(); 
    //  Use the System.Label.iBNF_Enabled_Sales_Orgs custom label to get a list of all sales org codes that are enabled for
    //  the iBNF. Then use the codes to build the EnabledSalesOrgs set 
    
    static
    {
	    //Get all the picklist values of BNF2__c.Sales_Org_Code__c
	    Schema.DescribeFieldResult F = BNF2__c.IMS_Sales_Org__c.getDescribe();
	    List<Schema.PicklistEntry> SalesOrgValues = F.getPicklistValues();
	    List<SelectOption> SalesOrgs = new List<SelectOption>();
	    Map<String,String> SalesOrg_Map = new Map<String,String>();
	    for (Schema.PicklistEntry S:SalesOrgValues) 
	    {
	     	if (S.getValue().contains('[') && S.getValue().contains(']') )
	        {
	        	Integer StartIndex = S.getValue().indexOf('[')+1;
	        	Integer EndIndex = S.getValue().indexOf(']');
	        	String SalesOrgCode = S.getValue().substring(StartIndex,EndIndex);
	        	SalesOrg_Map.put(SalesOrgCode,S.getValue());
	        }
	    }
	    for (String S2:System.Label.iBNF_Enabled_Sales_Orgs.split(','))
	    {
	    	EnabledSalesOrgs.add(SalesOrg_Map.get(S2));
	    }
	    for (String S3:System.label.iBNF_Manual_Sales_Orgs.split(','))
	    {
	    	ManualSalesOrgs.add(SalesOrg_Map.get(S3));
	    }
    }
                                                                               
    
     //  Set of all countries for which integration is not yet rolled out
    public static final Set<String> NonEnabledCountries = new Set<String>{'USA'};   
    public static final String Document_Dev_Name_IMSSFDCGlossary = 'IMSSFDCGlossary';
    //  BNF record type ID's
    public static final String SAP_SD_Integrated_Record_Type_Id = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('SAP SD Integrated').getRecordTypeId();
    public static final String Manual_Setup_In_SAP_Record_Type_Id = Schema.SObjectType.BNF2__c.getRecordTypeInfosByName().get('Manual Setup in SAP').getRecordTypeId();
    
    public static final Map<String,String> BnfStatus_Map = new Map<String,String>{'NEW' => 'New',
                                                            'SUBMITTED'=>'Submitted',
                                                            'ACCEPTED'=>'Accepted',
                                                            'REJECTED'=>'Rejected',
                                                            'LO_ACCEPTED'=>'LO Accepted',
                                                            'LO_REJECTED'=>'LO Rejected',
                                                            'RA_ACCEPTED'=>'RA Accepted',
                                                            'RA_REJECTED'=>'RA Rejected',
                                                            'SAP_REJECTED'=>'SAP Rejected',
                                                            'SAP_CONTRACT_CREATED'=>'SAP Contract Created',
                                                            'SAP_CONTRACT_REJECTED'=>'SAP Contract Rejected',
                                                            'SAP_CONTRACT_CONFIRMED'=>'SAP Contract Confirmed',
                                                            'SAP_CONTRACT_PENDING'=>'SAP Contract Pending',
                                                            'SAP_PENDING'=>'SAP Pending'
                                                            };
                                                                
}