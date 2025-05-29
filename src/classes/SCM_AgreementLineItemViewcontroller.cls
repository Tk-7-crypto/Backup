/**
  * controller for agreement line item view 
  * created by sumita dabas 1 July 2013
  */
public class SCM_AgreementLineItemViewcontroller{
    
    //Updated by Smita Pandey: 24 Dec 2013 - ER 555 - renamed self service to quick contract and full service to standard contract
    String SELFSERVICE_RECORDTYPE = 'Quick Contract'; //added by ranu date- 6th Aug'13
    public Agreement_Line_item__c agli{get;set;}
    public String UserProfileName{get;set;}
    public Map<String,Integer> relatedListSize{get;set;} 
    public String aggActivated{get;set;}
    public String sowCancelled{get;set;}
    //Added By sweta Details:ER-2124 Date:04/08/2015
    public String userPermission{get;set;}
    public String aggStatusCategory{get;set;}
    //Ended By sweta Details:ER-2124 Date:04/08/2015
    //Updated By :- Ekta , Date :- Feb 21 , 2015 , Details :- ER - 1584
    //public String proposalCancelled{get;set;}
    public String recordTypeName{get;set;}
    public Boolean canChangeProduct{get{
        if(agli.Id != null) {
            aggActivated = agli.AgreementId__r.Status__c;
            recordTypeName = agli.AgreementId__r.RecordType.Name;
        }
        
        //added self service record type check by ranu Issue_02589 date- 6th Aug'13
        //Updated By :- Ekta , Date :- Feb 21 , 2015 , Details :- ER - 1584 ,(Remove Proposal and Quick Contract check )
        //if((recordTypeName == 'Proposal' || RecordTypeName == SELFSERVICE_RECORDTYPE )|| (recordTypeName == 'SOW' && aggActivated != 'Activated'))
        if(recordTypeName == 'SOW' && aggActivated != 'Activated')
        {
            return true;
        }
        else 
            return false;
    }set;}
    public String lastModifiedBy{get;set;}
    public String createdBy{get;set;}
    public Boolean isAggActivated{get{
      if(agli.Id != null) 
        {
                
            if(agli.AgreementId__r.Status__c == 'Activated') 
            {
                return true;
            }
            else
            {
                return false;
            }
       }
       return false;  
    
    
    }set;}
    //Commented By :- Ekta , Date :- Feb 21 , 2015 , Details :- ER - 1584
    /*public Boolean isProposalCancelled{get{
        if(agli.Id != null) 
        {
                
            if(agli.AgreementId__r.APTPS_Proposal_Status__c == 'Cancelled') 
            {
                return true;
            }
            else
            {
                return false;
            }
       }
       return false;  
    
    
    
    }set;}*/
    public Boolean isSowCancelled{get{
        if(agli.Id != null) 
        {
                
            if(agli.AgreementId__r.Status_Category__c == 'Cancelled') 
            {
                return true;
            }
            else
            {
                return false;
            }
       }
       return false;
    } set;}
    
    //Added by Naveena : ER 965 :11-17-2014:start
    public Boolean isFrmSave{get;set;}
    public Boolean isItalyUser{get;set;}
    //Added by Naveena : ER 965 :11-17-2014 :end
    
    //Added By:-Ekta , Date-14th Oct,2013, Details:-Issue-02938
   public boolean isUpdateAgliAllowed
   {
    get
    {
        if(Schema.sObjectType.Agreement_Line_item__c.isUpdateable())  
            return true;

        else
            return false;
    }
    private set;
   }
   //Ended By:-Ekta,Issue-02938
   
     //Added By Rakesh : 4 Dec 2013 : Issue-3235 
  public boolean isCreateAgliAllowed
  {
    get
    {
      if(Schema.sObjectType.Agreement_Line_item__c.isCreateable())  
        return true;

      else
        return false;
    }
    private set;
  }
  //End Issue-3235
   
    //Added By Jay: Issue-3612
    public boolean isVisibleAcceleratedDAPDays
    {
        get
        {
            if((agli.User_Country__c != 'Italy') 
                  && (agli.User_Country__c != 'Canada')
                  &&(agli.Apts_DAP__c == 'Accelerated DAP'))  
                return true;

            else
                return false;
        }
        private set;
    }
    
    public boolean isVisibleAcceleratedDAPDaysOther
    {
        get
        {
            if((agli.User_Country__c != 'Italy') 
                  && (agli.User_Country__c != 'Canada')
                  &&(agli.Apts_DAP__c == 'Other'))  
                return true;

            else
                return false;
        }
        private set;
    }
    //End Issue-3612
    
    //Added By Rakesh : 21 April 2014 : Issue-4079 
    public string invoicingScheduleString {get; set;}
    
    public SCM_AgreementLineItemViewcontroller(ApexPages.StandardController controller) {
       
        //removed reference of APTPS_Primary_Contact__c by ranu Issue_2212 date-30th july'13
        //Added below Invoicing schedule field in query by Sandeep Singhal ER-0581 Date 3 Oct 2013
        //Updated By Rakesh : 1 Nov 2013 : ER-530 :: Add Attach_Number__c field to SOQL
        //Updated By Rakesh : 9 Nov 2013 : ER-636 :: Add Expected_Delivery_Date__c, AgreementId__r.IMS_Legal_Entity__c fields to SOQL
        //Updated By:-Ekta ,Date:-13th Nov,2013 , Details:- ER - 0566
        //agli = [Select a.Name,a.is_Primary_Agreement_Line_Item__c,a.AgreementId__r.Related_Opportunity__c,a.AgreementId__r.RecordType.Name,a.AgreementId__r.APTPS_Proposal_Status__c,a.AgreementId__r.Status__c,a.AgreementId__r.Status_Category__c,a.ProductId__r.Delivery_Media__c, a.ProductId__r.Delivery_Frequency__c, a.Termination_Date__c, a.SystemModstamp, a.Status__c, a.Start_of_Data_Period__c, a.Service_Plan__c, a.SCM_Fee_ScheduleLabel__c, a.SCM_Fee_Is_AGLI_Schedule_Editable__c, a.RelatedOpportunityLineItem__c, a.Region_Business_Unit__c, a.Redirect_To_Agreement__c,a.Proj_Rpt_Frequency__c, a.Primary_Contact__c, a.Output_Format__c, a.Other_Discount_Type__c, a.Option_Price__c, a.Option_Detail_c__c, a.Option_Detail__c, a.Offering_Type_Territory__c, a.Offering_Segment__c, a.Number_of_Users__c, a.Net_Price__c, a.Net_Price_For_SCM__c, a.Metric__c, a.Market_Definition_Options__c, a.List_Price__c, a.List_Price_For_SCM__c, a.Line_item_date_type__c, a.Line_Item_Start_Formal__c, a.Line_Item_Number__c, a.Line_Item_End_Formal__c, a.Line_Item_Category__c, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.Is_Record_Complete__c, a.IsDeleted, a.Id, a.IMS_Legal_Entity__c, a.Global_Product_Name__c, a.End_of_Data_Period__c, a.End_Date__c, a.Effective_Date__c, a.Display_on_Schedule_of_Service__c, a.Discount_Type__c,a.Invoicing_Schedule__c, a.Discount_Ratio__c, a.Discount_Price__c, a.Delivery_Weeks__c, a.Delivery_Weeks_Other__c, a.Delivery_Rpt_Frequency__c, a.Delivery_Method__c, a.Delivery_Method_Other__c, a.Delivery_Media__c, a.Delivery_Frequency_Other__c, a.Delivery_Format_Other__c, a.Data_Period__c, a.Data_Period_Start__c, a.Data_Period_End__c, a.Data_Package__c, a.Data_Month_Start__c, a.Data_Month_Start_Txt__c, a.Data_Month_End__c, a.Data_Month_End_Date__c, a.Data_Month_Diff__c, a.Data_Month_Begin_Date__c, a.Data_Level__c, a.Data_Level_Other__c, a.Data_Attributes__c, a.Data_Attributes_Other__c, a.CurrencyIsoCode, a.Created_By__c, a.CreatedDate, a.CreatedById, a.Countries_Other__c, a.Copromotion_contract__c, a.Contract_Start_Date__c, a.Contract_End_Date__c, a.Co_promotion_contract__c, a.Co_Promote_Agreement__c, a.Class_Channel__c, a.Class_Channel_Other__c, a.Cancellation_Reason_Other__c, a.Cancelation_Reason__c, a.Back_Data__c, a.Back_Data_Other__c, a.Auto_Research_Fee__c, a.Quantity__c, a.ProductId__c, a.ExtendedPrice__c, a.Description__c, a.AgreementId__c, a.Apts_Users_Seat_Licenses__c, a.Apts_Time_Period_Aged_Data__c, a.Apts_Service_Pack__c, a.Apts_Report_Generation_Allotment__c, a.Apts_Offering_Option__c, a.Apts_Offering_Name__c, a.Apts_Market_Definitions__c, a.Apts_Market_Definition_Type__c, a.Apts_Geographical_Level__c, a.Apts_Extra_Copies__c, a.Apts_Delivery_Frequency__c, a.Apts_Delivery_Format__c, a.Apts_Delivery_Charges__c, a.Apts_Delivery_Charges_Description__c, a.Apts_DAP__c, a.Apts_Custom_Delivery_Creation_Descr__c, a.Apts_Custom_Delivery_Creation_Charges__c, a.Apts_Contract_Signed__c, a.Apts_Channel__c, a.Apts_Audit__c, a.Apts_Affiliate_Charge__c, a.Apts_Addons_Additionals__c, a.Apts_Additional_Subsetting__c, a.Addl_Delivery_Frequency__c, a.Addl_Delivery_Frequency_Other__c, a.Additional_Type__c, a.Additional_Type_Included_in_Contract__c, a.Additional_Reports_Number__c, a.Additional_Price__c, a.Additional_Description__c, a.Add_On_Components__c, a.Add_On_Components_Other__c, a.Access_Period__c, a.Accelerated_DAP_Days_Other__c, a.APTPS_User_Defined_DAP_Days__c, a.APTPS_USCs_Included__c,  a.APTPS_Offering_Option_Other__c, a.APTPS_Line_Item_Updated__c, a.APTPS_Last_Modified_Date_FF__c, a.APTPS_Historical_Days_Other__c, a.APTPS_Historical_Data__c, a.APTPS_Geographical_Level_Other__c, a.APTPS_Created_Date_FF__c, a.APTPS_Channel_Other__c, a.APTPS_Accelerated_DAP_Days__c, Attach_Number__c, Expected_Delivery_Date__c, AgreementId__r.IMS_Legal_Entity__c From Agreement_Line_item__c a where a.id =: (ID)controller.getRecord().Id];
        //Updated By Rakesh : 3 Jan 2014 : Issue-3393(ER-476) : Add Market_Definitions_By_Groups__c field to SOQL
        
        //Updated By Rakesh : 21 April 2014 : Issue-4079 : Add Invoicing_Schedule_Italy__c to SOQL
        //Commented By:- Ekta , Date :- March 3, 2015 , Details:- ER - 1584(Remove APTPS_Proposal_Status__c)
        agli = [Select a.Name,a.is_Primary_Agreement_Line_Item__c,a.User_Country__c,a.AgreementId__r.Related_Opportunity__c,a.AgreementId__r.RecordType.Name,a.AgreementId__r.Status__c,a.AgreementId__r.Status_Category__c,a.ProductId__r.Delivery_Media__c, a.ProductId__r.Delivery_Frequency__c, a.Termination_Date__c, a.SystemModstamp, a.Status__c, a.Start_of_Data_Period__c, a.Service_Plan__c, a.SCM_Fee_ScheduleLabel__c, a.SCM_Fee_Is_AGLI_Schedule_Editable__c, a.RelatedOpportunityLineItem__c, a.Region_Business_Unit__c, a.Redirect_To_Agreement__c,a.Proj_Rpt_Frequency__c, a.Primary_Contact__c, a.Output_Format__c,  a.Option_Price__c, a.Option_Detail_c__c, a.Option_Detail__c, a.Offering_Type_Territory__c, a.Offering_Segment__c, a.Number_of_Users__c, a.Net_Price__c, a.Net_Price_For_SCM__c, a.Metric__c, a.Market_Definition_Options__c, a.List_Price__c, a.List_Price_For_SCM__c, a.Line_item_date_type__c, a.Line_Item_Start_Formal__c, a.Line_Item_Number__c, a.Line_Item_End_Formal__c, a.Line_Item_Category__c, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.Id, a.IMS_Legal_Entity__c, a.Global_Product_Name__c, a.End_of_Data_Period__c, a.End_Date__c, a.Effective_Date__c, a.Display_on_Schedule_of_Service__c,a.Invoicing_Schedule__c, a.Discount_Ratio__c, a.Discount_Price__c, a.Delivery_Weeks__c, a.Delivery_Weeks_Other__c, a.Delivery_Rpt_Frequency__c, a.Delivery_Method__c, a.Delivery_Method_Other__c, a.Delivery_Media__c, a.Delivery_Frequency_Other__c, a.Delivery_Format_Other__c, a.Data_Period__c, a.Data_Period_Start__c, a.Data_Period_End__c, a.Data_Package__c, a.Data_Month_Start__c, a.Data_Month_Start_Txt__c, a.Data_Month_End__c, a.Data_Month_End_Date__c, a.Data_Month_Diff__c, a.Data_Month_Begin_Date__c, a.Data_Level__c, a.Data_Level_Other__c, a.Data_Attributes__c, a.Data_Attributes_Other__c, a.CurrencyIsoCode, a.Created_By__c, a.CreatedDate, a.CreatedById, a.Countries_Other__c, a.Copromotion_contract__c, a.Contract_Start_Date__c, a.Contract_End_Date__c, a.Co_promotion_contract__c, a.Co_Promote_Agreement__c, a.Class_Channel__c, a.Class_Channel_Other__c, a.Cancellation_Reason_Other__c, a.Cancelation_Reason__c, a.Back_Data__c, a.Back_Data_Other__c, a.Auto_Research_Fee__c, a.Quantity__c, a.ProductId__c, a.ExtendedPrice__c, a.Description__c, a.AgreementId__c, a.Apts_Users_Seat_Licenses__c, a.Apts_Time_Period_Aged_Data__c, a.Apts_Service_Pack__c, a.Apts_Report_Generation_Allotment__c, a.Apts_Offering_Option__c, a.Apts_Offering_Name__c, a.Apts_Market_Definitions__c, a.Apts_Market_Definition_Type__c, a.Apts_Geographical_Level__c, a.Apts_Extra_Copies__c, a.Apts_Delivery_Frequency__c, a.Apts_Delivery_Format__c, a.Apts_Delivery_Charges__c, a.Apts_Delivery_Charges_Description__c, a.Apts_DAP__c, a.Apts_Custom_Delivery_Creation_Descr__c, a.Apts_Custom_Delivery_Creation_Charges__c, a.Apts_Contract_Signed__c, a.Apts_Channel__c, a.Apts_Audit__c, a.Apts_Affiliate_Charge__c, a.Apts_Addons_Additionals__c, a.Apts_Additional_Subsetting__c, a.Addl_Delivery_Frequency__c, a.Addl_Delivery_Frequency_Other__c, a.Additional_Type__c, a.Additional_Type_Included_in_Contract__c, a.Additional_Reports_Number__c, a.Additional_Price__c, a.Additional_Description__c, a.Add_On_Components__c, a.Add_On_Components_Other__c, a.Access_Period__c, a.Accelerated_DAP_Days_Other__c, a.APTPS_User_Defined_DAP_Days__c, a.APTPS_USCs_Included__c,  a.APTPS_Offering_Option_Other__c, a.APTPS_Line_Item_Updated__c, a.APTPS_Last_Modified_Date_FF__c, a.APTPS_Historical_Days_Other__c, a.APTPS_Historical_Data__c, a.APTPS_Geographical_Level_Other__c, a.APTPS_Created_Date_FF__c, a.APTPS_Channel_Other__c, a.APTPS_Accelerated_DAP_Days__c, Attach_Number__c, Expected_Delivery_Date__c, AgreementId__r.IMS_Legal_Entity__c, Market_Definitions_By_Groups__c, Invoicing_Schedule_Italy__c From Agreement_Line_item__c a where a.id =: (ID)controller.getRecord().Id];
        
        //Updated By Rakesh : 21 April 2014 : Issue-4079 : Add LanguageLocaleKey to SOQL
        //Updated By sweta Details:ER-2124 Date:13/08/2015
        //User userRec = [select Id,Name,User_Country__c,Region__c,Profile.Name,Business_Unit__c, LanguageLocaleKey from User where id = :UserInfo.getUserId()];
        User userRec = [select Id,Name,User_Country__c,Region__c,Profile.Name,Business_Unit__c, LanguageLocaleKey,(SELECT AssigneeId , PermissionSet.Label FROM PermissionSetAssignments) from User where id = :UserInfo.getUserId()];
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
        
        //Added By sweta Details:ER-2124 Date:13/08/2015
        if(userRec != Null)
            userPermission = ConstantClass.permissionSetUser(userRec.Profile.Name,userRec.PermissionSetAssignments);
        else
            userPermission = '';
        //Ended By sweta Details:ER-2124 Date:13/08/2015
        //Added By Rakesh : 21 April 2014 : Issue-4079 
        //**** START : Issue-4079  *****
        invoicingScheduleString = ( !String.isBlank(userRec.LanguageLocaleKey) && userRec.LanguageLocaleKey == 'it' ) ? agli.Invoicing_Schedule_Italy__c : agli.Invoicing_Schedule__c ;
        //**** END : Issue-4079  *****
        
        lastModifiedBy = agli.LastModifiedDate.format();
        createdBy = agli.CreatedDate.format();
        canChangeProduct = false;
        getRelatedLists();
     
        //Added By sweta Details:ER-2124 Date:14/08/2015
        if(agli!= null && agli.AgreementId__r.Status_Category__c != null)
             aggStatusCategory=agli.AgreementId__r.Status_Category__c;
        else
             aggStatusCategory='';
        //Ended By sweta Details:ER-2124 Date:14/08/2015
        
        if(agli!= null && ApexPages.currentPage().getParameters().get('frmSave')!= null && ApexPages.currentPage().getParameters().get('frmSave')== 'true' && agli.AgreementId__r.RecordTypeId == ConstantClass.getRecordTypeId('Agreement__c' ,ConstantClass.SOW))
            isFrmSave = true;
        else
            isFrmSave = false;  
        //Updated By rakesh : 23 Oct 2015 : Issue-8028 : START
        isItalyUser = (!string.isBlank(UserInfo.getLanguage()) && UserInfo.getLanguage() == 'it')? true : false;        
    }
    
    public PageReference cancelUncancel() {
         //updated by Vikas ER-1001 Dated 11 Sept 2014
        return new Pagereference('/apex/CancelAgreementLineItem?id='+agli.Id+'&aggId='+agli.AgreementId__c);
        //end ER-1001
    }
          

    public PageReference editAgli() {
        return new PageReference('/apex/SCM_agreementLineItemEdit?id='+agli.Id);
        
    }
    
    public PageReference delAgli(){
        try {
            delete agli;
            return new PageReference('/'+ Schema.getGlobalDescribe().get('Agreement__c').getDescribe().getKeyPrefix()+'/o');
        }
        catch(Exception e){
            //Added By Rakesh: 6 July 2015 : Issue-7293
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    public PageReference cloneRecord() {
        return new PageReference('/apex/SCM_AgreementLineItemEdit?id='+agli.Id+'&clone=true');   
    }
        
    public PageReference selectMarketDef() {
 
        return new PageReference('/apex/ATC_Search?id='+agli.Id);
    }
    
    public PageReference copyToAll () {
        return new PageReference('/apex/SCM_CopyToAllLineItem?id='+agli.Id);
    }

    public void getRelatedLists() {
        Agreement_Line_item__c agliwithRelatedLists = [Select Id,
                                                            (Select Id from Agreement_Line_Item_ATCs__r Limit 500),
                                                            (Select Id from Histories limit 500),
                                                            (Select Id from Agreement_Line_Item_Discounts__r Limit 500)
                                                            from Agreement_Line_item__c where id =: agli.Id ];
                                                            
        if(agliwithRelatedLists != null  ) 
        {                                           
            relatedListSize=new Map<String,Integer>();
            relatedListSize.put('Agreement_Line_Item_ATCs__r',agliwithRelatedLists.Agreement_Line_Item_ATCs__r.size());
            relatedListSize.put('Agreement_Line_Item_Discounts__r',agliwithRelatedLists.Agreement_Line_Item_Discounts__r.size());
            relatedListSize.put('Histories',agliwithRelatedLists.Histories.size());
        }
    }
}