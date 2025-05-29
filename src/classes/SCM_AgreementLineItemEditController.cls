/*
 * Author  : Rakesh Saini
 * Purpose : 1. VF page controller for agreement line item Edit Page(ER-468),
 *           2. Controller for Save and copy line item attributes to all Line item on an agreement functionality(ER-477).
 */
public class SCM_AgreementLineItemEditController{
    
    public Boolean canEdit{get;set;}
    private Agreement_Line_item__c agli;
    public String UserProfileName{get;set;}
    public Map<String,Integer> listSize{get;set;}
    public Boolean isClone {get; set;}
    //Added by Vikas Issue 4669 Dated; 19 June 2014
    public String aggId;
    /* Start By Rakesh*/
    public Agreement_Line_item__c agliRecord{get; set;}
    private Map<Id,Agreement_Line_item__c> AgliMap;
    public boolean isPrimaryLineItem {get; set;}
    /* End By Rakesh*/
    


    
    

    
    //Added By Rakesh : 30 Sept 2013 : ER-520
    //*********   START By Rakesh **********
    public List<String> selectedAggProductsForCopyProdSpecification {get; set;}
    public boolean showOtherProducts {get; set;}
    public boolean isAllAggProdSelected {get; set;}
    
    //Method to return list of select options of Agreement products
    public List<selectOption> getAggProductListOption() {
        List<selectOption> AggProductListOptions = new List<selectOption>();
        if(AgliMap != null) {
            AggProductListOptions.add(new selectOption('All', 'Select All'));
            for(Agreement_Line_item__c aggProduct : AgliMap.Values() )
            {
                if(aggProduct.Id != agliRecord.Id)
                {
                     AggProductListOptions.add(new selectOption( aggProduct.Id , aggProduct.ProductId__r.Name ));   
                }               
            }
        }
        return AggProductListOptions;
    }  
    //*********   END By Rakesh ************

    //Added By Rakesh : 4 Dec 2013 : Issue-03235 
    public Agreement_Line_item__c clonedRecord {get; set;}
    
    public Boolean ShowComponentMessage{get;set;} //Added By Rakesh : Issue-2428 :: 10 July 2013.
    
    //Added By:-Ekta, Date:-15th Feb,2013, Details:- ER - 0750
    public String prodWithDiff_DeliveryFrequency {get;set;}
    public String prodWithDiff_DeliveryMedia {get;set;}
    
    //Updated By Rakesh : 21 March 2014 : ER-775 : Add Language to SOQL
    private User userRec;
     
    //Added By Rakesh : 3 June 2014 : QMS-IM1586410
    //****** START : QMS-IM1586410 ****
    public boolean hasDataLevelOther {get; set;}
    public boolean hasChannelOther {get; set;}
    //****** END : QMS-IM1586410 ****** 
    
    //Added By:- Ekta , Date:- 28th Aug,2014, Details:- ER-1001
    public Boolean isZPUBProduct{get;set;}
  
     
    //Added By Dhruv : ER 2326 : 29-10-2015 : Added Field is isUserCountryItaly will be true if user country will be italy --------start
    
    public Boolean isUserCountryItaly{get;set;}
    public SCM_AgreementLineItemEditController(ApexPages.StandardController controller) {
        canEdit = false;
        
        //Added By Rakesh : 30 Sept 2013 : ER-520
        //*********   START By Rakesh **********
        selectedAggProductsForCopyProdSpecification = new List<String>();
        showOtherProducts = false; 
        //*********   END By Rakesh ER-520 ************
        
        ShowComponentMessage = false;
        
        //Updated By Rakesh : 21 March 2014 : ER-775 : Add LanguageLocaleKey to SOQL
        //User userRec = [select Id,Name,User_Country__c,Region__c,Profile.Name,Business_Unit__c from User where id = :UserInfo.getUserId()];
        userRec = [select Id,Name,User_Country__c,Region__c,Profile.Name,Business_Unit__c, LanguageLocaleKey from User where id = :UserInfo.getUserId()];
        User objUser = ConstantClass.getUserDetails().get(0);
        Boolean RetVal = false;
        String PermissionSetName = '';
        for(PermissionSetAssignment PermissionAss: objUser.PermissionSetAssignments)
        {
            if((PermissionAss.PermissionSet.Label.toLowerCase().contains('scm')) && (PermissionAss.PermissionSet.Label.toLowerCase().contains('japan'))) {                  
                RetVal = true;
                PermissionSetName = PermissionAss.PermissionSet.Label;
                break;
            }
        }
        if(RetVal) {
            this.UserProfileName = PermissionSetName.toLowerCase();
        } else {
            this.UserProfileName = userRec.Profile.Name.toLowerCase();
        }
        
        //Added by Vikas Issue 4669 Dated 19 June 2014
        if(ApexPages.currentPage().getParameters().get('aggId') != null) {
            aggId = ApexPages.currentPage().getParameters().get('aggId');
        }
        // Updated by sumita(to lower case)
        UserProfileName = UserProfileNAme.toLowerCase();
        isClone =  ApexPages.currentPage().getURL().contains ('clone');
        /* Start By Rakesh*/
        agliRecord = (Agreement_Line_item__c)controller.getRecord();
        Id agliID = (ID)controller.getRecord().Id ;

        //Added By Rakesh : 4 Dec 2013 : Issue-03235
        if(isclone)
        {
            clonedRecord = new Agreement_Line_item__c();  
            clonedRecord = agliRecord.clone(false,false,false,true);
            clonedRecord.AgreementId__c = agliRecord.AgreementId__c;
        }
        //END : Issue-03235
        
        //Get all Siblings of an agreement lineitem
        //Updated By Rakesh - 30 Sept 2013 :: ER-520 :: Add ProductId__r.Name to SOQL and Order By ProductId__r.Name Clause
        //Updated By Rakesh : 9 Nov 2013 : ER-636 :: Add Expected_Delivery_Date__c field to SOQL
        //Updated By:- Ekta , Date:- 28th Aug,2014, Details:- ER-1001(Added - ProductId__r.Material_Type__c )
        AgliMap = new Map<Id,Agreement_Line_item__c>([select id, Apts_Delivery_Frequency__c,
                                                                       Delivery_Method__c,
                                                                       Apts_Delivery_Format__c,
                                                                       Apts_Offering_Option__c,
                                                                       APTPS_Historical_Data__c,
                                                                       Back_Data__c,
                                                                       Data_Level__c,
                                                                       Apts_Channel__c,
                                                                       Line_item_date_type__c,
                                                                       Data_Month_Start__c,
                                                                       Data_Month_End__c,
                                                                       Apts_DAP__c,
                                                                       Delivery_Frequency_Other__c,
                                                                       Accelerated_DAP_Days_Other__c,
                                                                       APTPS_Accelerated_DAP_Days__c,
                                                                       Delivery_Method_Other__c,
                                                                       Apts_Custom_Delivery_Creation_Descr__c,
                                                                       Apts_Delivery_Charges_Description__c,
                                                                       Delivery_Format_Other__c,
                                                                       Metric__c,
                                                                       APTPS_Offering_Option_Other__c,
                                                                       APTPS_Historical_Days_Other__c,
                                                                       Data_Level_Other__c,
                                                                       Back_Data_Other__c,
                                                                       Market_Definition_Options__c,
                                                                       // Added these 6 fields by Sandeep for issue 6560 - start
                                                                       USC_Market_Def__c,
                                                                       ATC_Market_Def__c,
                                                                       Brand_Market_Def__c,
                                                                       Manufacturer_Market_Def__c,
                                                                       NEC_Market_Def__c,
                                                                       Speciality_Market_Def__c,
                                                                       // Added these 6 fields by Sandeep for issue 6560 - end
                                                                       APTPS_Channel_Other__c,
                                                                       Apts_Market_Definitions__c,
                                                                       Apts_Additional_Subsetting__c,
                                                                       Apts_Users_Seat_Licenses__c,
                                                                       Apts_Service_Pack__c,    
                                                                       Apts_Report_Generation_Allotment__c,
                                                                       Apts_Addons_Additionals__c,
                                                                       Apts_Extra_Copies__c,    
                                                                       is_Primary_Agreement_Line_Item__c,
                                                                       ProductId__r.Delivery_Frequency__c, 
                                                                       ProductId__r.Material_Type__c, 
                                                                       (select Id, Name, Agreement_Line_Item__c, ATC__c from Agreement_Line_Item_ATCs__r ), //Added by Rakesh : Issue-02401 :: 9 July 2013
                                                                       Data_Period_Start__c,
                                                                       Data_Period_End__c, 
                                                                       //Commented By :- Ekta , Date :- 28th Feb, 2015 , Details :- ER-1584
                                                                       //AgreementId__r.Apts_Service_Review_Flag__c,  // Issue-02428
                                                                       //AgreementId__r.Apts_Legal_Review_Flag__c,    // Issue-02428 
                                                                       //Ended By :- Ekta , Date :- 28th Feb, 2015 , Details :- ER-1584
                                                                       AgreementId__r.Status__c,                                                                //End Issue-2401
                                                                       ProductId__r.Delivery_Media__c ,
                                                                       AgreementId__r.RecordType.Name,//Added by Naveena : ER 747 :01-08-2014
                                                                       Net_Price__c,                   //Added by Naveena :ER 747 ;02-08-2014    
                                                                       AgreementId__r.Related_Opportunity__c,   //Added by Naveena :ER 747 ;09-10-2014 -Issue 5501
                                                            
                                                                       AgreementId__r.User_Country__c, //added by Ranu ER-596 date:24th Sep'13
                                                                       ProductId__r.Name, //Added By Rakesh : 30 Sept 2013 :: ER-520
                                                                       Expected_Delivery_Date__c, //Added By Rakesh : 9 Nov 20113 :: ER-636 
                                                                       AgreementId__r.Agreement_Category__c, //Added by Jyotsna ER-0747 :01-03-2014         
                                                                       Invoicing_Schedule__c, Invoicing_Schedule_Italy__c //Added By Rakesh : 21 April 2014 : Issue-04079 :: Add Invoicing_Schedule__c, Invoicing_Schedule_Italy__c  to SOQL 
                                                            from Agreement_Line_item__c where AgreementId__c = :agliRecord.AgreementId__c order by ProductId__r.Name]); 
        







        List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :agliRecord.AgreementId__c]);
        List<GroupMember> legalUser = new List<GroupMember>();
        List<GroupMember> clientServiceUser = new List<GroupMember>();
        Set<Id> userId = new Set<Id>();
    
        if(AgliMap.get(agliRecord.Id).AgreementId__r.Status__c == 'Activated' && !UserProfileName.contains('system administrator'))
        {
            ApexPages.addMessage(new ApexPages.Message(apexpages.severity.warning, system.Label.Not_Allowed_To_Edit_Agg_Product_of_Active_Agg));
            ShowComponentMessage = true;
        }
             
        
        agli = new Agreement_Line_item__c();
        agli = AgliMap.get(agliID);
        
        //Added By:- Ekta , Date:- 28th Aug,2014, Details:- ER-1001
        if(agli != Null && (agli.ProductId__r.Material_Type__c == 'ZPUB' || agli.ProductId__r.Material_Type__c == 'zpub'))
          isZPUBProduct = true;
        else
          isZPUBProduct = false;
        //Ended By:- Ekta , Date:- 28th Aug,2014, Details:- ER-1001
        
         system.debug('== agli.Data_Level__c : '+ agli.Data_Level__c);
        
       
        isPrimaryLineItem = true; 
        
        //check whether there is already primary agreement LineItem
        for(Agreement_Line_item__c siblingAGLI : AgliMap.values())
        {
            if(siblingAGLI.is_Primary_Agreement_Line_Item__c == true)
            {
                isPrimaryLineItem = false;
                break;
            }
        }
        /* End By Rakesh*/
    
        //Added By Rakesh : 3 June 2014 : QMS-IM1586410
        //****** START : QMS-IM1586410 ****
        hasDataLevelOther = (! string.isBlank(agli.Data_Level__c) && agli.Data_Level__c.contains('Other')) ? true : false;
        hasChannelOther = (! string.isBlank(agli.Apts_Channel__c) && agli.Apts_Channel__c.contains('Other')) ? true : false;
        //****** END : QMS-IM1586410 ******
    
        //Added By Dhruv : ER 2326 : 29-10-2015 : Added Field is isUserCountryItaly will be true if user country will be Italy --------start
        
        if(agliRecord!=null && !String.isBlank(agliRecord.User_Country__c) && agliRecord.User_Country__c.equalsIgnoreCase('italy'))
	        isUserCountryItaly=true ;
	    else 
	    	isUserCountryItaly=false ;
	    	
        //Ended By Dhruv : ER 2326 : 29-10-2015 : Added Field is isUserCountryItaly will be true if user country will be Italy --------end 
        


				
    }
    
    
    //***** Added By Rakesh : 21 April 2014 : Issue-04079 ******
    //**** SATRT : Issue-04079 *****
    public List<SelectOption> getItalianInvoicingSchedule() 
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Map<String,String> italianToEnglishInvoicingScheduleMap = new Map<String,String>();     
        italianToEnglishInvoicingScheduleMap.put('50% upon signature, 50% upon completion', '50% alla firma del contratto, 50% alla consegna');           
        italianToEnglishInvoicingScheduleMap.put('Annual', 'Annuale');
        italianToEnglishInvoicingScheduleMap.put('Monthly', 'Mensile');
        /****Modified by Vikas : 4 June 2014 : Issue-04584 */
        //italianToEnglishInvoicingScheduleMap.put('Once', 'Una Volta');
        //Updated By Rakesh : 27 June 2014  : Issue-4728
        //italianToEnglishInvoicingScheduleMap.put('Once', 'In un’unica soluzione');
        italianToEnglishInvoicingScheduleMap.put('Once', 'In un’unica soluzione alla consegna del servizio');
        italianToEnglishInvoicingScheduleMap.put('Other', 'Altro');
        italianToEnglishInvoicingScheduleMap.put('Quarterly', 'Trimestrale');
        /****Modified by Vikas : 4 June 2014 : Issue-04584 */
        //italianToEnglishInvoicingScheduleMap.put('Semi-Annual', 'Semestrali');
        italianToEnglishInvoicingScheduleMap.put('Semi-Annual', 'Semestrale');
        italianToEnglishInvoicingScheduleMap.put('Weekly', 'Settimanale');
        /****Modified by Vikas : 4 June 2014 : Issue-04584 */
        //italianToEnglishInvoicingScheduleMap.put('Bi-Monthly', 'B--mensile');
        italianToEnglishInvoicingScheduleMap.put('Bi-Monthly', 'Bimestrale');
        
        Schema.DescribeFieldResult fieldResult = Agreement_Line_item__c.Invoicing_Schedule__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','--None--'));         
        
        for(Schema.PicklistEntry f : ple) {
            
            if( !String.isBlank(userRec.LanguageLocaleKey) && userRec.LanguageLocaleKey == 'it' )
            {
                if(italianToEnglishInvoicingScheduleMap.containskey(f.getValue()))
                {
                    options.add( new SelectOption(f.getValue(), italianToEnglishInvoicingScheduleMap.get(f.getValue()) ));  
                }
            } else 
            {
                options.add( new SelectOption(f.getValue(), f.getValue() ));    
            }
        }
        
        return options;
    }
    //***** END : Issue-04079 ******
    
    
    // delivery media picklist values    
    public List<SelectOption> getDeliveryMediaOptions() {

        //System.assert(false,agli.ProductId__r.Delivery_Media__c);
        List<SelectOption> options = new List<SelectOption>(); 
        
        if (agli.ProductId__r.Delivery_Media__c == null || agli.ProductId__r.Delivery_Media__c == '') {
            Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Delivery_Media__c.getDescribe();
            
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            options.add(new SelectOption('','--None--'));         
            
            for(Schema.PicklistEntry f : ple) {
                options.add(new SelectOption(f.getLabel(), f.getValue())); 
 
            }
            // Added by Sadeep Singhal for ER-0385 Date 23 May 2014
            options.add(new SelectOption('Other','Other'));
        }
        else {
            Map<String,String> FieldsvaluesMap=new Map<String,String>();                
            Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Delivery_Media__c.getDescribe();
        
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  
            
            for(Schema.PicklistEntry f : ple){
               FieldsvaluesMap.put(f.getValue().substringBetween('[',']'), f.getValue()); 
            }
            List<String> SupportedDeliveryMedia = agli.ProductId__r.Delivery_Media__c.split(':');

            // Added by Sadeep Singhal for ER-0385 Date 23 May 2014 - Start
            Set<String> DeliveryMediaSet = new Set<String>();
            for(String DeliveryMediaOption : SupportedDeliveryMedia)
            {
            DeliveryMediaSet.add(DeliveryMediaOption);
            }
            // Added by Sadeep Singhal for ER-0385 Date 23 May 2014 - End
                        
            options.add(new SelectOption('','--None--')); 
            
            for (String DeliveryMediaOption : SupportedDeliveryMedia) {
                if(FieldsvaluesMap.containsKey(DeliveryMediaOption))
                    options.add(new SelectOption(FieldsvaluesMap.get(DeliveryMediaOption),FieldsvaluesMap.get(DeliveryMediaOption)));
            }
            
            // Added by Sadeep Singhal for ER-0385 Date 23 May 2014- Start
            if(!DeliveryMediaSet.contains('Other'))
                options.add(new SelectOption('Other','Other'));
        }
        
        return options;
    }
   
    // delivery frequency picklist values   
    public List<SelectOption> getDeliveryProj_Rpt_Frequency_options() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        if (agli.ProductId__r.Delivery_Frequency__c == null || agli.ProductId__r.Delivery_Frequency__c == '') {
            Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            Map<String, String> italianToEnglishDelFreqMap = new Map<String, String>();
            for(Schema.PicklistEntry f : ple) 
            {
                if( f.getValue() == 'Once [O]')
                {
                    italianToEnglishDelFreqMap.put( 'Unica fornitura', 'Once [O]' );
                } 
                if( f.getValue() == 'Weekly Data - Weekly Delivery [WW]' )
                {
                    italianToEnglishDelFreqMap.put( 'Consegna settimanale', 'Weekly Data - Weekly Delivery [WW]' );
                }
                if( f.getValue() == 'Weekly Data - Monthly Delivery [WM]' || f.getValue() == 'Monthly Data - Monthly Delivery [MM]' )
                {
                    italianToEnglishDelFreqMap.put( 'Consegna mensile', 'Weekly Data - Monthly Delivery [WM]' );    
                }
                if( f.getValue() == 'Monthly data - Bi-Monthly delivery [MB]' || f.getValue() == 'First month - Bi-Monthly delivery [1B]' || f.getValue() == 'Second month - Bi-Monthly delivery [2B]' )
                {
                    italianToEnglishDelFreqMap.put( 'Consegna bimestrale', 'Monthly data - Bi-Monthly delivery [MB]' );
                }
                if( f.getValue() == 'Monthly Data - Quarterly Delivery [MQ]' || f.getValue() == 'Quarterly Data - Quarterly Delivery [QQ]' || f.getValue() == 'First month - Quarterly delivery [1Q]' ||
                 f.getValue() == 'Second month - Quarterly delivery [2Q]' || f.getValue() == 'Third month - Quarterly delivery [3Q]' )
                {
                    italianToEnglishDelFreqMap.put( 'Consegna trimestrale', 'Monthly Data - Quarterly Delivery [MQ]' );
                }
                if( f.getValue() == 'Monthly Data - Half Yearly Delivery [MH]' || f.getValue() == 'Quarterly Data - Half Yearly Delivery [QH]' || f.getValue() == 'Half Yearly Data - Half Yearly Delivery [HH]' )
                {
                    italianToEnglishDelFreqMap.put( 'Consegna semestrale', 'Monthly Data - Half Yearly Delivery [MH]' );
                }
                if( f.getValue() == 'Monthly Data - Yearly Delivery [MY]' || f.getValue() == 'Quarterly Data - Yearly Delivery [QY]' ||
                 f.getValue() == 'Half Yearly Data - Yearly Delivery [HY]' || f.getValue() == 'Yearly Data - Yearly Delivery [YY]' )
                {
                    italianToEnglishDelFreqMap.put( 'Consegna annuale', 'Monthly Data - Yearly Delivery [MY]' );
                }
                if( f.getValue() == 'Other')
                {
                    italianToEnglishDelFreqMap.put( 'Altro', 'Other' );
                }
            }
            
            if( !String.isBlank(userRec.LanguageLocaleKey) && userRec.LanguageLocaleKey == 'it' )
            {
                options.add(new SelectOption('','--Nessuno--'));
                for( String delFreqItaly : italianToEnglishDelFreqMap.keySet() ) 
                {
                    options.add(new SelectOption( italianToEnglishDelFreqMap.get(delFreqItaly), delFreqItaly)); 
                }
            } else
            {
                options.add(new SelectOption('','--None--'));         
                for(Schema.PicklistEntry f : ple) 
                {
                    options.add(new SelectOption(f.getLabel(), f.getValue())); 
                }
            }
            //******  END : ER-775  *****
            
        }
        else {
            Map<String,String> FieldsvaluesMap=new Map<String,String>();                
            Schema.DescribeFieldResult fieldResult = OpportunityLineItem.Proj_Rpt_Frequency__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();      
            for(Schema.PicklistEntry f : ple) {
               FieldsvaluesMap.put(f.getValue().substringBetween('[',']'), f.getValue()); 
            }
            
            List<String> SupportedDeliveryFrequency = agli.ProductId__r.Delivery_Frequency__c.split(':');
                
            Map<String, String> italianToEnglishDelFreqMap = new Map<String, String>();
            for( String strSupportedDeliveryFrequency : SupportedDeliveryFrequency) 
            {
                if(FieldsvaluesMap.containsKey(strSupportedDeliveryFrequency))
                {
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Once [O]')
                    {
                        italianToEnglishDelFreqMap.put( 'Unica fornitura', 'Once [O]' );
                    } 
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Weekly Data - Weekly Delivery [WW]' )
                    {
                        italianToEnglishDelFreqMap.put( 'Consegna settimanale', 'Weekly Data - Weekly Delivery [WW]' );
                    }
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Weekly Data - Monthly Delivery [WM]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Monthly Data - Monthly Delivery [MM]' )
                    {
                        italianToEnglishDelFreqMap.put( 'Consegna mensile', 'Weekly Data - Monthly Delivery [WM]' );    
                    }
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Monthly data - Bi-Monthly delivery [MB]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'First month - Bi-Monthly delivery [1B]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Second month - Bi-Monthly delivery [2B]' )
                    {
                        italianToEnglishDelFreqMap.put( 'Consegna bimestrale', 'Monthly data - Bi-Monthly delivery [MB]' );
                    }
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Monthly Data - Quarterly Delivery [MQ]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Quarterly Data - Quarterly Delivery [QQ]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'First month - Quarterly delivery [1Q]' ||
                     FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Second month - Quarterly delivery [2Q]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Third month - Quarterly delivery [3Q]' )
                    {
                        italianToEnglishDelFreqMap.put( 'Consegna trimestrale', 'Monthly Data - Quarterly Delivery [MQ]' );
                    }
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Monthly Data - Half Yearly Delivery [MH]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Quarterly Data - Half Yearly Delivery [QH]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Half Yearly Data - Half Yearly Delivery [HH]' )
                    {
                        italianToEnglishDelFreqMap.put( 'Consegna semestrale', 'Monthly Data - Half Yearly Delivery [MH]' );
                    }
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Monthly Data - Yearly Delivery [MY]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Quarterly Data - Yearly Delivery [QY]' ||
                     FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Half Yearly Data - Yearly Delivery [HY]' || FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Yearly Data - Yearly Delivery [YY]' )
                    {
                        italianToEnglishDelFreqMap.put( 'Consegna annuale', 'Monthly Data - Yearly Delivery [MY]' );
                    }
                    if( FieldsvaluesMap.get(strSupportedDeliveryFrequency) == 'Other')
                    {
                        italianToEnglishDelFreqMap.put( 'Altro', 'Other' );
                    }
                }
            }
            
            if( !String.isBlank(userRec.LanguageLocaleKey) && userRec.LanguageLocaleKey == 'it' )
            {
                options.add(new SelectOption('','--Nessuno--'));
                for( String delFreqItaly : italianToEnglishDelFreqMap.keySet() ) 
                {
                    options.add(new SelectOption( italianToEnglishDelFreqMap.get(delFreqItaly), delFreqItaly)); 
                }
            } else
            {    
                options.add(new SelectOption('','--None--')); 
                for (String strSupportedDeliveryFrequency : SupportedDeliveryFrequency) 
                {
                    if(FieldsvaluesMap.containsKey(strSupportedDeliveryFrequency))
                        options.add(new SelectOption(FieldsvaluesMap.get(strSupportedDeliveryFrequency),FieldsvaluesMap.get(strSupportedDeliveryFrequency)));
                }
            }
            //******  END : ER-775  *****
            
            
            /*
            if(!DeliveryFrequencySet.contains('Other'))
            {
                options.add(new SelectOption('Other','Other'));
            }
            */
        }
        return options;
    }
    
    
    //Added By:-Ekta, Date:-15th Feb,2013, Details:- ER - 0750
    public pageReference isDeliveryMediaAndFrequencyCopyToAllAgli()
    {
         Agreement_Line_item__c tempAgli = new Agreement_Line_item__c();
         prodWithDiff_DeliveryFrequency = '';
         prodWithDiff_DeliveryMedia = '';
                if(selectedAggProductsForCopyProdSpecification != Null && selectedAggProductsForCopyProdSpecification.size()>0)
                {
                    for(String aggProductId : selectedAggProductsForCopyProdSpecification )
                    {
                        if(aggProductId == 'All' && AgliMap != null)
                        {
                           for(Agreement_Line_item__c agli : AgliMap.values())
                           {
                                if(agli.Id != agliRecord.Id)
                                {
                                    //Updated By:-Ekta,Date:-5th March,2014, Details:- Issue-03793
                                    if(agli.ProductId__r.Delivery_Frequency__c != Null && agli.ProductId__r.Delivery_Frequency__c != '' && !agli.ProductId__r.Delivery_Frequency__c.contains(agliRecord.Apts_Delivery_Frequency__c.substringBetween('[',']'))) 
                                        prodWithDiff_DeliveryFrequency +=agli.ProductId__r.Name + ',';                                      
                                    //Updated By:-Ekta,Date:-5th March,2014, Details:- Issue-03793
                                    //Updated By Rakesh : 26 May 2014 : ER-385 ::  Add null check
                                    if(agli.ProductId__r.Delivery_Media__c != Null && agli.ProductId__r.Delivery_Media__c != '' && !string.isBlank(agliRecord.Apts_Delivery_Format__c.substringBetween('[',']')) && !agli.ProductId__r.Delivery_Media__c.contains(agliRecord.Apts_Delivery_Format__c.substringBetween('[',']')))
                                        prodWithDiff_DeliveryMedia +=agli.ProductId__r.Name + ',';    
                                }
                           }
                           break;
                        }
                        else
                        {
                            if(AgliMap != null && AgliMap.containsKey(aggProductId))
                            {
                                tempAgli = AgliMap.get(aggProductId);
                                //Updated By:-Ekta,Date:-5th March,2014, Details:- Issue-03793
                                //Updated By:-Ekta,Date:-8th May,2014, Details:- Null Check
                                if(tempAgli != Null && tempAgli.ProductId__c != Null &&  tempAgli.ProductId__r.Delivery_Frequency__c != Null && tempAgli.ProductId__r.Delivery_Frequency__c != '' && !tempAgli.ProductId__r.Delivery_Frequency__c.contains(agliRecord.Apts_Delivery_Frequency__c.substringBetween('[',']'))) 
                                    prodWithDiff_DeliveryFrequency +=tempAgli.ProductId__r.Name + ',';                                      
                                //Updated By:-Ekta,Date:-5th March,2014, Details:- Issue-03793
                                //Updated By:-Ekta,Date:-8th May,2014, Details:- Null Check
                                if(tempAgli != Null && tempAgli.ProductId__c != Null &&  tempAgli.ProductId__r.Delivery_Media__c != Null && tempAgli.ProductId__r.Delivery_Media__c != '' && !tempAgli.ProductId__r.Delivery_Media__c.contains(agliRecord.Apts_Delivery_Format__c.substringBetween('[',']')))
                                    prodWithDiff_DeliveryMedia +=tempAgli.ProductId__r.Name + ',';
                            }
                        }
                        
                    }
                    if(prodWithDiff_DeliveryFrequency != '')
                        prodWithDiff_DeliveryFrequency = prodWithDiff_DeliveryFrequency.removeEnd(',');
                    if(prodWithDiff_DeliveryMedia != '')
                        prodWithDiff_DeliveryMedia = prodWithDiff_DeliveryMedia.removeEnd(',');
                    
                }
       
        return null;
    }
    
    
    
    /* Start By Rakesh*/
    /*
    *Method to copy all atributes of primary LineItem to all siblings of this line item under a single Agreement
    */

    public pageReference CopyToAllLineItems()
    {
        if(AgliMap != NULL )
        {
            Agreement_Line_Item_ATCs__c newLineItemATC;
            List<Agreement_Line_Item_ATCs__c> lineItemATCList = new List<Agreement_Line_Item_ATCs__c>();            
            Map<ID, Agreement_Line_item__c> selectedAggProductMap = new Map<ID, Agreement_Line_item__c>();
            if(isAllAggProdSelected && AgliMap != null)
            {
                selectedAggProductMap = AgliMap;
            } else
            {
                selectedAggProductMap.put(agliRecord.Id, AgliMap.get(agliRecord.Id));
                for(String aggProductId : selectedAggProductsForCopyProdSpecification )
                {
                    if(AgliMap != null && AgliMap.containsKey(aggProductId))
                    {
                        selectedAggProductMap.put(aggProductId, AgliMap.get(aggProductId));
                    }
                }
            }
            
            for(Agreement_Line_item__c siblingAGLI : selectedAggProductMap.values())
            {
                if(siblingAGLI.ProductId__r.Delivery_Frequency__c != Null && siblingAGLI.ProductId__r.Delivery_Frequency__c != '' && siblingAGLI.ProductId__r.Delivery_Frequency__c.contains(agliRecord.Apts_Delivery_Frequency__c.substringBetween('[',']')))    
                    siblingAGLI.Apts_Delivery_Frequency__c = agliRecord.Apts_Delivery_Frequency__c;             //
                else if(siblingAGLI.ProductId__r.Delivery_Frequency__c == Null || siblingAGLI.ProductId__r.Delivery_Frequency__c.trim() == '' )
                    siblingAGLI.Apts_Delivery_Frequency__c = agliRecord.Apts_Delivery_Frequency__c;                
                siblingAGLI.Delivery_Method__c = agliRecord.Delivery_Method__c;                             //
                if(siblingAGLI.ProductId__r.Delivery_Media__c != Null && siblingAGLI.ProductId__r.Delivery_Media__c != '' && !string.isblank(agliRecord.Apts_Delivery_Format__c.substringBetween('[',']')) && siblingAGLI.ProductId__r.Delivery_Media__c.contains(agliRecord.Apts_Delivery_Format__c.substringBetween('[',']'))) 
                    siblingAGLI.Apts_Delivery_Format__c = agliRecord.Apts_Delivery_Format__c;                   //
                if(siblingAGLI.ProductId__r.Delivery_Media__c == Null || siblingAGLI.ProductId__r.Delivery_Media__c.trim() == '' )
                    siblingAGLI.Apts_Delivery_Format__c = agliRecord.Apts_Delivery_Format__c;     
                
                siblingAGLI.Apts_Offering_Option__c = agliRecord.Apts_Offering_Option__c;                   //
                siblingAGLI.APTPS_Historical_Data__c = agliRecord.APTPS_Historical_Data__c;                 //
                siblingAGLI.Data_Level__c = agliRecord.Data_Level__c;                                       //
                siblingAGLI.Back_Data__c = agliRecord.Back_Data__c;                                         //
                siblingAGLI.Apts_Channel__c = agliRecord.Apts_Channel__c;                                   //
                siblingAGLI.Data_Month_Start__c = agliRecord.Data_Month_Start__c;                           //
                siblingAGLI.Data_Month_End__c = agliRecord.Data_Month_End__c;                               //  
                siblingAGLI.Line_item_date_type__c = agliRecord.Line_item_date_type__c;                     //
                siblingAGLI.Apts_DAP__c = agliRecord.Apts_DAP__c;                                           //
                siblingAGLI.Delivery_Frequency_Other__c = agliRecord.Delivery_Frequency_Other__c;           //  
                siblingAGLI.Accelerated_DAP_Days_Other__c = agliRecord.Accelerated_DAP_Days_Other__c;       //
                siblingAGLI.APTPS_Accelerated_DAP_Days__c = agliRecord.APTPS_Accelerated_DAP_Days__c;       //  
                siblingAGLI.Delivery_Method_Other__c = agliRecord.Delivery_Method_Other__c;                 //
                siblingAGLI.Apts_Custom_Delivery_Creation_Descr__c = agliRecord.Apts_Custom_Delivery_Creation_Descr__c; //
                siblingAGLI.Apts_Delivery_Charges_Description__c = agliRecord.Apts_Delivery_Charges_Description__c;     //
                siblingAGLI.Delivery_Format_Other__c = agliRecord.Delivery_Format_Other__c;                 //
                siblingAGLI.Metric__c = agliRecord.Metric__c;                                               //  
                siblingAGLI.APTPS_Offering_Option_Other__c = agliRecord.APTPS_Offering_Option_Other__c;     //
                siblingAGLI.APTPS_Historical_Days_Other__c = agliRecord.APTPS_Historical_Days_Other__c;     //
                siblingAGLI.Data_Level_Other__c = agliRecord.Data_Level_Other__c;                           //
                siblingAGLI.Back_Data_Other__c = agliRecord.Back_Data_Other__c;                             //
                siblingAGLI.APTPS_Channel_Other__c = agliRecord.APTPS_Channel_Other__c;
                siblingAGLI.Expected_Delivery_Date__c = aglirecord.Expected_Delivery_Date__c;                     //
                siblingAGLI.Invoicing_Schedule__c = agliRecord.Invoicing_Schedule__c;
                
                if(siblingAGLI.Id != AgliMap.get(agliRecord.Id).Id && (!string.isBlank(agliRecord.Market_Definition_Options__c) && agliRecord.Market_Definition_Options__c == 'Selected Market Defs'))
                {
                    if( string.isBlank(siblingAGLI.Apts_Market_Definitions__c)  || siblingAGLI.Market_Definition_Options__c == 'N/A' || siblingAGLI.Market_Definition_Options__c == 'All Markets' )
                    {
                        for(Agreement_Line_Item_ATCs__c linItemATC : AgliMap.get(agliRecord.Id).Agreement_Line_Item_ATCs__r)       
                        {
                            newLineItemATC = linItemATC.clone(false,true,false,true);
                            newLineItemATC.Agreement_Line_Item__c = siblingAGLI.Id ;                                  
                            newLineItemATC.Data_Period_Start__c   = siblingAGLI.Data_Period_Start__c;   
                            newLineItemATC.Data_Period_End__c     = siblingAGLI.Data_Period_End__c;
                            lineItemATCList.add(newLineItemATC);
                        }
                        
                        if(agliRecord.Market_Definition_Options__c == 'Selected Market Defs')
                        {
                            siblingAGLI.Apts_Market_Definitions__c = agliRecord.Apts_Market_Definitions__c;
                        }
                    } 
                }
                                  
                //End 
                
                siblingAGLI.Market_Definition_Options__c = agliRecord.Market_Definition_Options__c;
                siblingAGLI.USC_Market_Def__c = agliRecord.USC_Market_Def__c;
                siblingAGLI.ATC_Market_Def__c = agliRecord.ATC_Market_Def__c;
                siblingAGLI.Brand_Market_Def__c = agliRecord.Brand_Market_Def__c;
                siblingAGLI.Manufacturer_Market_Def__c = agliRecord.Manufacturer_Market_Def__c;
                siblingAGLI.NEC_Market_Def__c = agliRecord.NEC_Market_Def__c;
                siblingAGLI.Speciality_Market_Def__c = agliRecord.Speciality_Market_Def__c;
                siblingAGLI.Market_Definitions_By_Groups__c = agliRecord.Market_Definitions_By_Groups__c;
                
                siblingAGLI.Apts_Additional_Subsetting__c = agliRecord.Apts_Additional_Subsetting__c;       //
                siblingAGLI.Apts_Users_Seat_Licenses__c = agliRecord.Apts_Users_Seat_Licenses__c;           //
                siblingAGLI.Apts_Service_Pack__c = agliRecord.Apts_Service_Pack__c;                         //
                siblingAGLI.Apts_Report_Generation_Allotment__c = agliRecord.Apts_Report_Generation_Allotment__c;   //
                siblingAGLI.Apts_Addons_Additionals__c = agliRecord.Apts_Addons_Additionals__c;             //
                siblingAGLI.Apts_Extra_Copies__c = agliRecord.Apts_Extra_Copies__c;                         //
            
            }
            

            if(isPrimaryLineItem )
            {
                selectedAggProductMap.get(agliRecord.Id).is_Primary_Agreement_Line_Item__c = true;
            }
            
            selectedAggProductMap.get(agliRecord.Id).List_Price__c = agliRecord.List_Price__c;
            selectedAggProductMap.get(agliRecord.Id).Net_Price__c = agliRecord.Net_Price__c;
            selectedAggProductMap.get(agliRecord.Id).Discount_Price__c = agliRecord.Discount_Price__c;
            selectedAggProductMap.get(agliRecord.Id).Additional_Price__c = agliRecord.Additional_Price__c;
            selectedAggProductMap.get(agliRecord.Id).Option_Price__c = agliRecord.Option_Price__c;
            selectedAggProductMap.get(agliRecord.Id).Apts_Delivery_Charges__c = agliRecord.Apts_Delivery_Charges__c;
            selectedAggProductMap.get(agliRecord.Id).CurrencyIsoCode = agliRecord.CurrencyIsoCode;
            selectedAggProductMap.get(agliRecord.Id).Additional_Type_Included_in_Contract__c = agliRecord.Additional_Type_Included_in_Contract__c;
            selectedAggProductMap.get(agliRecord.Id).Apts_Custom_Delivery_Creation_Charges__c = agliRecord.Apts_Custom_Delivery_Creation_Charges__c;
            selectedAggProductMap.get(agliRecord.Id).Apts_Affiliate_Charge__c = agliRecord.Apts_Affiliate_Charge__c;
            selectedAggProductMap.get(agliRecord.Id).Termination_Date__c = agliRecord.Termination_Date__c;
            selectedAggProductMap.get(agliRecord.Id).Cancelation_Reason__c = agliRecord.Cancelation_Reason__c;
            selectedAggProductMap.get(agliRecord.Id).Cancellation_Reason_Other__c = agliRecord.Cancellation_Reason_Other__c;
            selectedAggProductMap.get(agliRecord.Id).Apts_Delivery_Format__c = agliRecord.Apts_Delivery_Format__c;
            selectedAggProductMap.get(agliRecord.Id).Apts_Delivery_Frequency__c = agliRecord.Apts_Delivery_Frequency__c;
            
            try
            {
                if(lineItemATCList.size() >  0)
                {
                    insert lineItemATCList;
                }
                if(selectedAggProductMap.size() > 0)
                {
                    update selectedAggProductMap.values();
                }           
            } catch(Exception e)
            {
                if(String.ValueOf(e.getMessage()).contains(Label.Proposl_SOW_Contract_NOT_MoreThan10Years))
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Proposl_SOW_Contract_NOT_MoreThan10Years); 
                    ApexPages.addMessage(myMsg);
                }
                else
                    ApexPages.addMessages(e);               
                return null; 
            }   
        }
        PageReference pageRef;
        if( ApexPages.currentPage().getParameters().get('isFromFeeScheduleScreen') != null && 
            ApexPages.currentPage().getParameters().get('isFromFeeScheduleScreen') == 'true')
        {
            pageRef = new PageReference('/apex/SCM_Fee_Schedule_page?id='+agliRecord.AgreementId__c);
        } else
        if (aggId != null) {
            pageRef = new PageReference('/'+aggId);
        } else {
            Boolean flagSve = true;
            pageRef = new PageReference('/apex/SCM_AgreementLineItemView?id='+agliRecord.Id+'&sfdc.override=1'+'&frmSave='+flagSve);
        }
        return pageRef;
    }

    public PageReference getValidations () {
        
        showOtherProducts = false;
        if(!isUserCountryItaly && isZPUBProduct && string.Isblank(aglirecord.Apts_Delivery_Frequency__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delivery Frequency : You must enter a value'));
            return null;
        }
    	if(!isUserCountryItaly && isZPUBProduct && string.Isblank(aglirecord.Apts_Delivery_Format__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delivery Media : You must enter a value'));
            return null;
        }
        
        if(!isUserCountryItaly && aglirecord.Apts_Delivery_Frequency__c == 'Other' && string.Isblank(aglirecord.Delivery_Frequency_Other__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delivery Frequency Other : You must enter a value'));
            return null;
        }
        
        if( aglirecord.AgreementId__r.IMS_Legal_Entity__c != 'IMS Health Incorporated' && aglirecord.AgreementId__r.IMS_Legal_Entity__c !=Label.Quintiles_IMS_Incorporated && aglirecord.AgreementId__r.IMS_Legal_Entity__c !=Label.Iqvia && aglirecord.Apts_Delivery_Frequency__c == 'Once [O]' && aglirecord.Expected_Delivery_Date__c == null )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected Delivery Date : You must enter a value'));
            return null;
        }
        if( aglirecord.AgreementId__r.IMS_Legal_Entity__c != 'IMS Health Incorporated'  && aglirecord.AgreementId__r.IMS_Legal_Entity__c !=Label.Quintiles_IMS_Incorporated && aglirecord.AgreementId__r.IMS_Legal_Entity__c !=Label.Iqvia && aglirecord.Apts_Delivery_Frequency__c == 'Once [O]' && aglirecord.Expected_Delivery_Date__c <= aglirecord.Data_Month_End__c )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expected Delivery Date : You must have Expected Delivery Date after Product End Date.'));
            return null;
        }
        if(!isUserCountryItaly && aglirecord.Delivery_Method__c == 'Other' && string.Isblank(aglirecord.Delivery_Method_Other__c))

        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delivery Format Other : You must enter a value'));
            return null;
        }
        if(!isUserCountryItaly && aglirecord.Apts_Offering_Option__c == 'other' && string.Isblank(aglirecord.APTPS_Offering_Option_Other__c) )

        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Offering Option Other : You must enter a value'));
            return null;
        }
        boolean otherDataLevels = false;
        if(!isUserCountryItaly && isZPUBProduct && (agliRecord.Data_Level__c == '' || agliRecord.Data_Level__c == NULL ) )
        {
            system.debug('=== in data lvel validation');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Data Level : You must enter a value'));
            return null;
        }
        if(!isUserCountryItaly && (agliRecord.Data_Level__c != '' && agliRecord.Data_Level__c != NULL) && (agliRecord.Data_Level__c).contains('Other') && string.Isblank(aglirecord.Data_Level_Other__c))
        {
            system.debug('=== in data lvel validation');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Data Level Other : You must enter a value'));
            return null;
        }        
        if(!isUserCountryItaly && isZPUBProduct && (agliRecord.Apts_Channel__c == '' || agliRecord.Apts_Channel__c == NULL ))
        {
            system.debug('=== in data lvel validation');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Channel : You must enter a value'));
            return null;
        }
        if( !isUserCountryItaly && (agliRecord.Apts_Channel__c!= '' && agliRecord.Apts_Channel__c != NULL) && (agliRecord.Apts_Channel__c).contains('Other') && string.Isblank(aglirecord.APTPS_Channel_Other__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Channel Other : You must enter a value'));
            return null;
        }
        if(!isUserCountryItaly && aglirecord.APTPS_Historical_Data__c == 'other' && string.Isblank(aglirecord.APTPS_Historical_Days_Other__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Rolling Historical Data Other : You must enter a value'));
            return null;
        }
        if(!isUserCountryItaly && aglirecord.Back_Data__c == 'other' && string.Isblank(aglirecord.Back_Data_Other__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Back Data Other : You must enter a value'));
            return null;
        }
        if( aglirecord.Apts_DAP__c == 'Accelerated DAP' && aglirecord.APTPS_Accelerated_DAP_Days__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Accelerated DAP Days: Please Enter Accelerated DAP Days'));
            return null;
        }
        if( aglirecord.Apts_DAP__c == 'Accelerated DAP' && ( aglirecord.APTPS_Accelerated_DAP_Days__c < 10 || aglirecord.APTPS_Accelerated_DAP_Days__c > 40))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Accelerated DAP Days: The value should be in the range 10 to 40'));
            return null;
        }
        if(agliRecord.Apts_Offering_Option__c != 'Other')
        {
            agliRecord.APTPS_Offering_Option_Other__c = '';
        }        
        if( (agliRecord.Primary_Reason_for_Change__c != '' && agliRecord.Primary_Reason_for_Change__c != NULL) && (agliRecord.Primary_Reason_for_Change__c).contains('Other') && string.Isblank(aglirecord.Primary_Change_Reason_Other__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Primary Change Reason Other : You must enter a value'));
            return null;
        }
        if( (agliRecord.Secondary_Reasons_for_Change__c != '' && agliRecord.Secondary_Reasons_for_Change__c != NULL) && (agliRecord.Secondary_Reasons_for_Change__c).contains('Other') && string.Isblank(aglirecord.Secondary_Change_Reason_Other__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Secondary Change Reason Other : You must enter a value'));
            return null;
        }
        if(!isUserCountryItaly && aglirecord.Apts_Delivery_Format__c == 'Other' && string.Isblank(aglirecord.Delivery_Format_Other__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delivery Media Other : You must enter a value'));
            return null;
        }
        showOtherProducts = true; 
        return null;
    }

    public PageReference saveLineItem()
    {
        User objUser = ConstantClass.getUserDetails().get(0);
        Boolean RetVal = false;
        for(PermissionSetAssignment PermissionAss: objUser.PermissionSetAssignments)
        {
            if((PermissionAss.PermissionSet.Label.toLowerCase().contains('scm')) && (PermissionAss.PermissionSet.Label.toLowerCase().contains('japan'))) {                  
                RetVal = true;
                break;
            }
        }
        if(!(RetVal || UserProfileName.containsIgnoreCase(System.Label.System_Admin)))
        {
            PageReference pr =  getValidations();
            if( !showOtherProducts )
            {
                return null;
            }
        }
        try
        {
            PageReference pageRef;
            if(!isClone)
            {
                Update aglirecord;
                if( ApexPages.currentPage().getParameters().get('isFromFeeScheduleScreen') != null && 
                    ApexPages.currentPage().getParameters().get('isFromFeeScheduleScreen') == 'true')
                {
                    pageRef = new PageReference('/apex/SCM_Fee_Schedule_page?id='+agliRecord.AgreementId__c);
                } else
                if (aggId != null) {
                    pageRef = new PageReference('/'+aggId);
                } else {
                    Boolean flagSve = true;
                    pageRef = new PageReference('/apex/SCM_AgreementLineItemView?id='+agliRecord.Id+'&sfdc.override=1'+'&frmSave='+flagSve);
                }
            } else if(isClone)
            {
                Id newAggID = clonedRecord.AgreementId__c ;
                clonedRecord = agliRecord.clone(false,false,false,true);
                clonedRecord.AgreementId__c = newAggID;
                clonedRecord.is_Primary_Agreement_Line_Item__c = false;
                insert clonedRecord;
                pageRef = new PageReference('/'+clonedRecord.Id);
            }
            return pageRef;
        } 
        catch(Exception e)
        {
            showOtherProducts = false;            
            if(String.ValueOf(e.getMessage()).contains(Label.Proposl_SOW_Contract_NOT_MoreThan10Years))
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,Label.Proposl_SOW_Contract_NOT_MoreThan10Years); 
                ApexPages.addMessage(myMsg);
            }
            else
                ApexPages.addMessages(e);
            return null; 
        }

    }

    public PageReference cancelLineItem() {
        PageReference pageRef;
        System.debug('****Agreement ID' + aggId);
        if( ApexPages.currentPage().getParameters().get('isFromFeeScheduleScreen') != null && 
            ApexPages.currentPage().getParameters().get('isFromFeeScheduleScreen') == 'true')
        {
            pageRef = new PageReference('/apex/SCM_Fee_Schedule_page?id='+agliRecord.AgreementId__c);
        } else
        if (aggId != null) {
            pageRef = new PageReference('/'+aggId);
        } else {
            pageRef = new PageReference('/'+agliRecord.Id);
        }
        return pageRef;
    }
}