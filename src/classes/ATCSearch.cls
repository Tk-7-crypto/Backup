/*1.0 Smita Pandey 02/20/2012 Original
* controller class for ATC search screen    
* Last Modified by Sandeep kr Singhal 13 Dec 2012
*/
public class ATCSearch
{
    /**-- Error messge Variables --**/
    
    //Updated By Rakesh : 12 Sept 2013 :: ER-478
    //*** START ****
    //private static final String No_ELEMENTDISPLAY_WARNING = 'Incorrect Agg Line Item ID';
    private static final String No_ELEMENTDISPLAY_WARNING = system.Label.Incorrect_Agg_Line_Item_ID;
    //**** END  ***
    
    private static final String SELECT_PICKLIST_MSG = ' Please select Market Definition code from picklist ' ;
    private static final String WILD_CHAR_ENTER_MSG = Label.WILD_CHAR_ENTER_MSG;
    public boolean charMsg{get;set;} 
    public boolean alertmsgSaveButton{get;set;} 
    
    /**-- Public Properties --**/
    public Boolean checkAll{get;set;}  //propeties value for 'Select All' for upper(Search ATC) table   
    public Boolean checkAllResultLst{get;set;}  //Property used for 'Select All' functionlity for below table  
    public Boolean displaySelectItemLst {get;set;}
    public Integer totalItemSelected{get;set;}
    
    // by Sandeep Singhal for #1759 Date 21 Feb 2013
    Private List<ProcessInstance> procins{get;set;}
    public Boolean ShowComponentMessage{get;set;} 
    public  List<ATCSearchWrapper> lstATC {get;set;}
    public List<List<ATCSearchWrapper>> listOfAllSelectedData{get;set;}
    public Id AgreementRecordType{get;set;}
    public String AgreementMarketDefsOption{get;set;}
    
    public String SearchText{get;set;}
    public String SelectedObject{get;set;}
    
    /**-- valiables for rendering conditions --**/
    public  Boolean ShowAllElement{get;private set;}
    public  Boolean ShowResultTbl{get;private set;}
    
    
    /**-- Private varibles --**/
    private Set<Id> setOfExistingRrcords = new Set<Id>();   //  set of records which are already slected from upper list to lower list 
    List<ATCSearchWrapper> tempList ;
    
    /**-- private String selectedObject; --**/
    private List<SelectOption> optionList ;  
    private List<id> recordTypes ;
    private Agreement_Line_item__c ALI;
    private String searchString ;
    private String recordType ;
    Integer listSize = 0;
    String  ALIId;
    //Added by Vikas Issues=4669 Dated 19 June, 2014
    String aggId;
    //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906
    private Agreement_Line_item__c agliController ;
    //Added by:- Ekta Sharma, Date:-21st Jan,2013
    public String profile{get;set;} 
    public  integer lstHasRecords
    {
        get
        {
            return listSize;
        }
        set;
    }
    
    public PageReference setSelObj() 
    {
        selectedObject = Apexpages.currentPage().getParameters().get('selObjSL');
        return null;
    }
    
    // by Sandeep 5 sept
    Set<string> setOfAttachedATCId ;
    Map<id,List<Agreement_Line_Item_ATCs__c>> MapOfExistingAGLIATC ;
    private List<Agreement_Line_item__c>  ALIList;
    
    
    
    /*** Added by Rakesh : 15 April 2013 ***/
    /*** Start ***/
    public boolean applyToOtherLineItem {get; set;}
    private Map<Id, Agreement_Line_item__c> AGLIIdwithMarketDefMap;
    public List<String> selectedAGLILineItem {get; set;}
    private set<ID> setOfUpdatedALIId = new set<ID>() ;
    public boolean isAllSelected {get; set;}
    /** End **/
    
    /**-- constructor --**/
    
    public ATCSearch(ApexPages.StandardController controller) 
    { 
        
        ShowResultTbl = false;                      
        checkAll = false;   
        checkAllResultLst = false ;
        totalItemSelected = 0 ; 
        charMsg = false;
        ShowAllElement = false; 
        SearchText = '' ; 
        SelectedObject = '';
        profile='';
        //initialization block
        //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906
        agliController  = (Agreement_Line_item__c)controller.getRecord();
        
        // Updated By :sandeep, 6 sept
        
        MapOfExistingAGLIATC = new Map<id,List<Agreement_Line_Item_ATCs__c>>();
        
        listOfAllSelectedData = new List<List<ATCSearchWrapper>>();
        
        lstATC   = new List<ATCSearchWrapper>();              
        ALI = new Agreement_Line_item__c();
        setOfAttachedATCId = new Set<String>();
        // AID to id by sandeep issue 1759 date 21 feb 2013
        if(ApexPages.currentPage().getparameters().get('id') != null)
        {  
            ALIId = ApexPages.currentPage().getparameters().get('id'); 
        }
        //Added by Vikas Issue 4669 Dated 19 June, 2014
        if(ApexPages.currentPage().getParameters().get('aggId') != null) {
            aggId = ApexPages.currentPage().getParameters().get('aggId');
        }
        if(ALIId != null)
        {   ShowAllElement = true ; 
         // check added by Sandeep 2 march 2012
         ALIList = new List<Agreement_Line_item__c>(); 
         
         //fetch the ALI object details that will be updated when ATC Line Items will be added
         //Updated By :Ranu Jain, Date : 12th Feb, Detail : Issue_1578 
         //ALIList = [select Delivery_Rpt_Frequency__c , Data_Period_Start__c ,Data_Period_End__c from Agreement_Line_item__c Where id =: ALIId];
         ALIList = [select AgreementId__c,Delivery_Rpt_Frequency__c , Data_Period_Start__c ,Data_Period_End__c, AgreementId__r.RecordTypeID ,Market_Definition_Options__c from Agreement_Line_item__c Where id =: ALIId];
         AgreementRecordType = ALIList.get(0).AgreementId__r.RecordTypeID;
         AgreementMarketDefsOption = ALIList.get(0).Market_Definition_Options__c;
         // by Sandeep Singhal #1759 Date 21 Feb 2013
         if(ALIList.size()>0)
         {
             procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :ALIList.get(0).AgreementId__c]);
             if(procins.size()>0)
             {
                 ApexPages.addMessage(new ApexPages.Message(apexpages.severity.warning, 'Agreement is submitted for Approval so You are not allowed to add Market definitions.'));
                 ShowAllElement = false;
                 ShowComponentMessage = true;
             }
         }
         //throw new customexception( ' Exception :'+AgreementRecordType  ); 
         //Updated By : Sandeep,date 5th Sep
         tempList = new List<ATCSearchWrapper>();
         
         for(Agreement_Line_Item_ATCs__c Markdef : [select id , ATC__r.RecordTypeId,ATC__r.Name_Other__c, ATC__r.RecordType.Name , ATC__c from Agreement_Line_Item_ATCs__c where Agreement_Line_Item__c =: ALIId])
         {
             if(Markdef.ATC__c != null)
                 setOfAttachedATCId.add(Markdef.ATC__c);  
             // by sandeep 6 sept 
             if(MapOfExistingAGLIATC.containskey(Markdef.atc__c))
                 MapOfExistingAGLIATC.get(Markdef.atc__c).add(Markdef);
             else
             {
                 List<Agreement_Line_Item_ATCs__c> TempAgliATCList = new List<Agreement_Line_Item_ATCs__c>();
                 TempAgliATCList.add(Markdef);
                 MapOfExistingAGLIATC.put(Markdef.atc__c ,TempAgliATCList);
             }  
             setOfExistingRrcords.add(Markdef.ATC__c);                              
             
         }                   
         for(ATC__c atc : [select id,ATC_Code__c,Name_Eng__c,Name_Other__c,RecordType.Name ,Level__c, RecordTypeId from ATC__c where ID In: setOfAttachedATCId])
         {
             tempList.add(new ATCSearchWrapper(atc , true));                     
         }
         alertmsgSaveButton = true ;
         
         if(tempList.size()>0) {
             checkAllResultLst = true;
             alertmsgSaveButton = false; // fix Issue - 01132,no alert message if list has any item from database.
             listOfAllSelectedData.add(tempList);
         }else {
             checkAllResultLst = false;
         }
         
         if(ALIList.size()>0) {
             ALI = ALIList[0] ;
         }                                           
        }
        if( (ALIId == null) || (( ALIList!=null)  && (ALIList.size() == 0)) ) 
        {                       
            ApexPages.Message infoMsg = new ApexPages.Message(apexpages.severity.warning, No_ELEMENTDISPLAY_WARNING );
            ApexPages.addMessage(infoMsg);
            return ;    
        }  
        
        /* Updated By : Ranu Jain,Date: 28 Aug  issue : 00814 */
        List<RecordType> recordtyplst = [SELECT Id,Name FROM RecordType WHERE SobjectType='ATC__c' ]; // query to get record types for ATC Object
        recordTypes = new List<id>(); 
        getRecordTypes(recordtyplst); // method calling to parse record type list retrieved by query
        selectedObject = String.valueOf(recordTypes.get(0)); // default value for record type pick list is 'ATC'
        
        
        /****** Added by Rakesh : 15 April 2013*****/  
        //Start      
        //get AgreementLineItem with MarketDef record.
        AGLIIdwithMarketDefMap = new Map<ID, Agreement_Line_item__c>([select Id, Name, Delivery_Rpt_Frequency__c, Data_Period_Start__c, Data_Period_End__c, ProductId__r.Name, (select id, Name, Agreement_Line_Item__c, ATC__c from Agreement_Line_Item_ATCs__r ) from Agreement_Line_item__c where AgreementId__c = : ALIList.get(0).AgreementId__c ]);
        selectedAGLILineItem = new List<String>();
        applyToOtherLineItem = false;
        //End
    }
    
    // Options for record  to show on Page
    public List<SelectOption> getObjectList()
    {
        optionList = new List<SelectOption>() ;                         
        ConstantClass.createRecordTypeLst();   // this class contains list of record type Name as constant to be displayed
        for(Integer i = 0; i < recordTypes.size(); i++) 
        {
            //if(recordTypes.get(i).isAvailable==true) {         
            optionList.add(new SelectOption(recordTypes.get(i),ConstantClass.recordType.get(i))) ;   
            // }   
        }
        return optionList ; 
    }
    public void getRecordTypes(List<RecordType> recordtyplst) {
        for(RecordType rectyp: recordtyplst)
        {
            recordTypes.add(rectyp.id);  
        }
    }
    
    //action function handler to fetch data on the basis of search criteria
    public pageReference SearchMarketDefinition()
    {    
        ShowResultTbl = true;  
        checkAll = false;
        charMsg = false;
        
        /* if(selectedObject != '' || selectedObject != null) {
ShowAllElement = false ;                    
ApexPages.Message infoMsg = new ApexPages.Message(apexpages.severity.warning, No_ELEMENTDISPLAY_WARNING );
ApexPages.addMessage(infoMsg);
return ;        
}
*/
        // Added by Sandeep 7 th Sept 2012
        if(selectedObject == null)
        {
            if(recordTypes != null && recordTypes.size()>0)
                selectedObject =  String.valueOf(recordTypes.get(0));               
            if(ALIList != null && ALIList.size()>0)
                ALI  = ALIList[0];
        }
        //Added By:Ekta ,Date:-20th Feb,2013,Issue-01761
        try{
            if(ALI != null && selectedObject != '' && selectedObject != null)
            {   
                //fetch the atc codes based on the search text entered and add to the wrapper list
                
                if(searchText != '' && searchText != null)
                {   
                    searchString  = searchText.trim(); 
                    if(!checkForWildChar(searchString)){ // method calling to check that search string contains at least one Char. 
                        // bny sandeep 7 sept
                        lstATC   = new List<ATCSearchWrapper>(); 
                        //Added By:Ekta ,Date:-20th Feb,2013,Issue-01761
                        if(profile==null || profile=='')
                        {
                            ShowResultTbl = false;    
                        }
                        else
                        {
                            BuildingWrapperList(selectedObject);
                        }
                        
                    } else {
                        return null;
                        
                    }
                }
            }
        }
        catch(Exception e)
        {
            ShowResultTbl = false;
        }
        
        return null ;
    }
    
    /* Method Created By: Ranu Jain, Date : 12th July
* Detail : this method is created to handle wild char in "Please Type Market Definition:"  Search text box.
*/
    public  boolean checkForWildChar(String searchByString) {
        String charcntString =  searchByString.replaceAll('\\*','');
        charcntString = charcntString.replaceAll('%','');
        if(charcntString.length() <= 0) {
            ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error, WILD_CHAR_ENTER_MSG );
            ApexPages.addMessage(infoMsg);
            
            return true ;
        }
        return false;
    }
    
    /* Created By : Ranu Jain, Date : 7th Sep 
Detail : this method is created to display render uotput panel which desplay eror message for refine Search String
and intialise the 'lstATC' to display none result
*/
    public pageReference callErrorMsg() {
        
        lstATC = new List<ATCSearchWrapper>();
        displaySelectItemLst = false;
        lstHasRecords = 0;
        charMsg = true;  
        return null;
    }
    
    public pageReference callErrorMsg2() {
        
        lstATC = new List<ATCSearchWrapper>();
        displaySelectItemLst = false;
        charMsg = false;  
        lstHasRecords = 0;
        return null;
    }
    
    
    
    /**-- This method is used to build a wrapper list to show separate tables on pages --**/
    private void BuildingWrapperList(String ObejectName)
    {           
        //Added By Rakesh : 30 Jan 2014 : Issue-03329(ER-0647)
        //This set contains string combination of Name ( English ) ' _ 'RecordtypeId
        set<string> uniqueIDSetForBrandsAndMFR = new set<string>();
        
        if(SearchText != null)
            searchString = ContractMgmt_ComMethodClass.modifySearchStr(searchText.trim());
        
        // Dclaration of properties
        Boolean ExistsFlag ;
        Integer i=0 ;
        ATCSearchWrapper ATCobjWrapper ;
        
        //List<ATC__c> lst = database.query('select id,RecordTypeId,ATC_Code__c,level__c,name_eng__c,name_other__c from atc__c where RecordTypeId =: ObejectName limit 1000 ');
        
        //Updated By:-Ekta Sharma,Date:-21st Jan,2012,Details:-add ORDER BY ATC_Code__c for Issue:-01601 
        //Updated by Naveena : Issue 6342 : 2/12/2015 :added 'Active__c' check in query
        String query='select id,RecordTypeId,RecordType.Name, ATC_Code__c,level__c,name_eng__c,name_other__c from atc__c where (ATC_Code__c like : searchString OR Name_Eng__c like : searchString ) and Active__c = true and  RecordTypeId =: ObejectName ORDER BY ATC_Code__c';
        User objUser = ConstantClass.getUserDetails().get(0);
        Boolean RetVal = false;
        for(PermissionSetAssignment PermissionAss: objUser.PermissionSetAssignments)
        {
            if((PermissionAss.PermissionSet.Label.toLowerCase().contains('scm')) && (PermissionAss.PermissionSet.Label.toLowerCase().contains('japan'))) {                  
                RetVal = true;
                break;
            }
        }
        if(RetVal)
        {
            query +=',Name_Other__c limit 1000';
        }                     
        else
        {
            query +=',Name_Eng__c limit 1000';
        }
        for( ATC__c obj :Database.query(query))
        {
            if(setOfExistingRrcords!=null && !setOfExistingRrcords.contains(obj.id))
            {
                //Added By Rakesh : 28 Jan 2014 : Issue-3328(ER-0647) :: Add if condition not to show Brands and Manufactures in table if Name( English ) is blank.
                //Updated By Rakesh :: 30 Jan 2014 : Issue-03329(ER-0647) :: Add a check if set contains this Brand or MFR, then don't add market def to wrapper list to show on page
                //if( !( (obj.RecordType.Name == 'Brand' || obj.RecordType.Name == 'Manufacturer') && string.isBlank(obj.name_eng__c))) 
                if( !( (obj.RecordType.Name == 'Brand' || obj.RecordType.Name == 'Manufacturer') && (string.isBlank(obj.name_eng__c) || uniqueIDSetForBrandsAndMFR.contains(obj.Name_Eng__c+'_'+obj.RecordType.Name) )))
                {
                    ATCobjWrapper = new ATCSearchWrapper(obj);
                    lstATC.add(ATCobjWrapper);
                    //Added By Rakesh :: 30 Jan 2014 : Issue-03329(ER-0647)
                    uniqueIDSetForBrandsAndMFR.add(obj.Name_Eng__c+'_'+obj.RecordType.Name);
                    displaySelectItemLst = true;
                }
            }  
        }
        listSize = lstATC.size();
    }
    
    /****** Added by Rakesh : 15 April 2015 ******/
    //Start
    /***  ER-0339
Method to return list of select options of AgreementLineItem
***/
    public List<selectOption> getAGLIListOption() {
        List<selectOption> AGLILstOption = new List<selectOption>();
        if(AGLIIdwithMarketDefMap != null) {
            AGLILstOption.add(new selectOption('All', 'Select All'));
            //Added by Rakesh :: Issue 02022
            //start
            List<selectOption> AGLILstOptionSorted = new List<selectOption>();
            if(ALIList.get(0).AgreementId__c != null) {
                for(Agreement_Line_item__c agli :[select Id, ProductId__r.Name from Agreement_Line_item__c where AgreementId__c = : ALIList.get(0).AgreementId__c order by ProductId__r.Name] ) {
                    //Updated By Rakesh : 30 July 2013 :: Issue-02457 :: Add "agli.Id != ALIId" to if condition
                    if(AGLIIdwithMarketDefMap.containsKey(agli.Id) && agli.Id != ALIId) {
                        AGLILstOptionSorted.add(new selectOption(agli.Id, AGLIIdwithMarketDefMap.get(agli.Id).ProductId__r.Name ));
                    }
                }
            }
            AGLILstOption.addAll(AGLILstOptionSorted);
            //end 
        }
        return AGLILstOption;
    }
    //End
    
    
    
    /* Updated By : Ranu Jain, Date : 27th Aug  
Detail : add button handler to add the Market Definitions to the selected list */
    
    public void AddSelected()
    {   
        checkAllResultLst = true;
        charMsg = false;
        displaySelectItemLst = true;
        
        // four list are used to store records for record type : ATC,Brand,MFR,Speciality,USC 
        List<ATCSearchWrapper> marDefATCLst   = new List<ATCSearchWrapper>();
        List<ATCSearchWrapper> marDefBrandLst = new List<ATCSearchWrapper>();
        List<ATCSearchWrapper> marDefMFRLst   = new List<ATCSearchWrapper>();
        List<ATCSearchWrapper> marDefSpecialityLst   = new List<ATCSearchWrapper>();
        List<ATCSearchWrapper> marDefUSCLst   = new List<ATCSearchWrapper>();
        
        //Added By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612)
        List<ATCSearchWrapper> marDefNECLst   = new List<ATCSearchWrapper>();
        
        
        
        for(List<ATCSearchWrapper> lstOfAllSelectedItems : listOfAllSelectedData) {
            for( ATCSearchWrapper marketDef : lstOfAllSelectedItems){
                
                if(!marketDef.selectedFlag){
                    checkAllResultLst = false;
                    break;      
                }
                
            }
        }
        
        //Updated By: Ranu Jain,Date : 24th Sep, Detail : fix Issue-00963 : added market definitions should appear at the top of the list
        
        if(listOfAllSelectedData.size() > 0 && tempList.size() > 0) {
            
            listOfAllSelectedData.remove( listOfAllSelectedData.size()-1 );
            
        }
        
        // To add item in Target list and remove from source list simultanoustly    
        if(lstATC != null && lstATC.size() >0)
        {
            for(integer i=0; i< lstATC.size(); i++)
            {
                //recalculate the values if the row is selected
                if(lstATC[i].selectedFlag)
                {
                    // add item if record type is 'ATC'
                    if(selectedObject == recordTypes.get(0)  ) { 
                        if(marDefATCLst.size() < 1000 ) { 
                            marDefATCLst.add(lstATC[i]);
                        }  
                    }else if(selectedObject == recordTypes.get(1)) {  // add item if record type is 'Brnad'
                        if(marDefBrandLst.size() < 1000 ) { 
                            marDefBrandLst.add(lstATC[i]);  
                        }   
                    }else if(selectedObject == recordTypes.get(2)) {  // add item if record type is 'MFR'
                        if(marDefMFRLst.size() < 1000 ) {   
                            marDefMFRLst.add(lstATC[i]);  
                        }
                    }
                    //Added By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) ******** START ********
                    else if(selectedObject == recordTypes.get(3))     // add item if record type is 'NEC' 
                    { 
                        if(marDefNECLst.size() < 1000 ) {
                            marDefNECLst.add(lstATC[i]); 
                        }   
                    }
                    //*********** END : Issue-03198(ER-0612) *********
                    //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) :: Change RecordType index from 3 to 4 
                    //else if(selectedObject == recordTypes.get(3)) {  // add item if record type is 'Speciality'
                    else if(selectedObject == recordTypes.get(4)) {
                        if(marDefSpecialityLst.size() < 1000 ) {
                            marDefSpecialityLst.add(lstATC[i]); 
                        }   
                    } 
                    //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) :: Change RecordType index from 4 to 5
                    //else if(selectedObject == recordTypes.get(4)){  // add item if record type is 'USC'
                    else if(selectedObject == recordTypes.get(5)){
                        if(marDefUSCLst.size() < 1000 ) {
                            marDefUSCLst.add(lstATC[i]);
                        }
                    }
                    setOfExistingRrcords.add(lstATC[i].ATC.Id);
                    lstATC.remove(i);  // item which are added to below table to insert in AgreementLineitem ATC will be removed from upper table
                    i--;
                }//End of If
                
            }
            // add all record type list to list of list of wrapper object
            if( marDefATCLst != null &&  marDefATCLst.size() > 0) {
                listOfAllSelectedData.add(marDefATCLst);
            }else if(marDefBrandLst != null &&  marDefBrandLst.size() > 0) {
                listOfAllSelectedData.add(marDefBrandLst);    
            }else if(marDefMFRLst != null && marDefMFRLst.size() > 0) {
                listOfAllSelectedData.add(marDefMFRLst);     
            }else if(marDefSpecialityLst != null && marDefSpecialityLst.size() > 0) {
                listOfAllSelectedData.add(marDefSpecialityLst);       
            }else if( marDefUSCLst != null &&  marDefUSCLst.size() > 0) {
                listOfAllSelectedData.add(marDefUSCLst);      
            }
            
            //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) :: ***  START ** Add marDefNECLst list to listOfAllSelectedData list 
            else if( marDefNECLst != null &&  marDefNECLst.size() > 0) {
                listOfAllSelectedData.add(marDefNECLst);      
            }
            //****** END : Issue-03198(ER-0612) ******
            
            if(lstATC.size() == 0) {
                checkAll  = false ;
            }
        }//end of IF
        
        listOfAllSelectedData.add(tempList);
        
        
        listSize = lstATC.size();
    }//end of If
    
    
    /**-- remove the atcs from the selected list --**/   
    public void RemoveSelected()
    {           
        ATCSearchWrapper obj ;
        if(searchString != null)
        {
            List<List<ATCSearchWrapper>> temList = new List<List<ATCSearchWrapper>>();
            for(List<ATCSearchWrapper> lstOfAllSelectedItems : listOfAllSelectedData) //iterating over the list of list of wrapper object
            {
                for(integer i=0; i< lstOfAllSelectedItems.size(); i++) // iterating over the list of perticular record type
                {                   
                    //recalculate the values if the row is selected
                    if(lstOfAllSelectedItems[i].selectedFlag)
                    {
                        lstOfAllSelectedItems[i].selectedFlag = false;
                        
                        //in case the item to be removed matches the current search criteria add the item back to top list
                        
                        if( ( lstOfAllSelectedItems[i].ATC.ATC_Code__c.toLowerCase().startsWith(searchString.toLowerCase().replace('%','')) && (lstOfAllSelectedItems[i].ATC.recordTypeId == selectedObject) ) || ((lstOfAllSelectedItems[i].ATC.Name_Eng__c != null)  && lstOfAllSelectedItems[i].ATC.Name_Eng__c.toLowerCase().startsWith(searchString.toLowerCase().replace('%','')) && (lstOfAllSelectedItems[i].ATC.recordTypeId == selectedObject) )   )
                        {                           
                            lstATC.add(lstOfAllSelectedItems[i]);
                            listSize = lstATC.size();
                        }
                        lstOfAllSelectedItems.remove(i);  
                        i--;
                    }
                }
                if(lstOfAllSelectedItems.size() > 0) { 
                    temList.add(lstOfAllSelectedItems); 
                }
            }
            if(temList.size() > 0) {
                listOfAllSelectedData = temList ;
            }else {
                listOfAllSelectedData = new List<List<ATCSearchWrapper>>();
            }
            if(listOfAllSelectedData.size() == 0){
                checkAllResultLst = false ;     
            }
        }
    }//end of function
    
    //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906 
    public List<Agreement_Line_Item_ATCs__c> lstALIATCs ;
    public List<Agreement_Line_Item_ATCs__c> ListToDeleteExistingAGLIATCs ;
    
    /**-- Add button handler to add the selected atcs to the agreement line item --**/
    public pageReference AddLineItemATCs()
    {
        try
        { 
            //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906 
            lstALIATCs = new List<Agreement_Line_Item_ATCs__c>();
            ListToDeleteExistingAGLIATCs =  new List<Agreement_Line_Item_ATCs__c>();
            //Ended By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906 
            //Commented By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906 
            //List<Agreement_Line_Item_ATCs__c> lstALIATCs = new List<Agreement_Line_Item_ATCs__c>();
            //commented by Rakesh
            //set<Id> ATCIds = new set<ID>();  // list of those ATC ids already present in Agreement line item ATCs
            // by sandeep 6 sept 
            //Commented By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906 
            //List<Agreement_Line_Item_ATCs__c> ListToDeleteExistingAGLIATCs =  new List<Agreement_Line_Item_ATCs__c>();
            
            //fetch existing atc codes associated with the agreement line item
            if(ALIId!=null)
            {  
                //commented by Rakesh   
                /*for(Agreement_Line_Item_ATCs__c objLineItemATC :[select atc__c,ATC__r.Name_Other__c,Delivery_Frequency__c ,Data_Period_Start__c,Data_Period_End__c from Agreement_Line_Item_ATCs__c where Agreement_Line_Item__c = :ALIId ])
{                   
ATCIds.add(objLineItemATC.atc__c);                      
}*/
                
                //Rakesh : 15 April 2013 :: ER-0339
                List<String> AGLIListSelected = new List<String>();
                Map<String, Agreement_Line_Item_ATCs__c> ATCIdwithAGLIMarketDefMap ;
                
                //if apply changes to other Line Item checkbox is selected  
                if(applyToOtherLineItem) {
                    //if select All option is selected
                    if(isAllSelected) {
                        //add all the agreementLineItem id to final selected AGLIListSelected 
                        for(ID ids : AGLIIdwithMarketDefMap.keySet() ) {
                            AGLIListSelected.add(ids);
                        }   
                    }  else {
                        AGLIListSelected.addAll(selectedAGLILineItem);
                        //Added by Rakesh : Issue-02457 : 30 July 2013
                        AGLIListSelected.add(this.ALIId);
                    }
                } else {
                    //if apply changes to other Line Item checkbox is not selected then apply changes to only cuurent agreement
                    AGLIListSelected.add(this.ALIId);
                }
                
                
                
                Agreement_Line_Item_ATCs__c objLineItemATC ;
                
                //Updated by Rakesh : 15 April 2013 :: ER-0339
                //for final selected AgreementLineItems
                for(String AGLIId : AGLIListSelected) {
                    setOfUpdatedALIId.add(AGLIId);
                    if(AGLIIdwithMarketDefMap != null) {               
                        //create a map of ATCId's with their marketDef record(Junction Object)
                        ATCIdwithAGLIMarketDefMap =  new Map<String, Agreement_Line_Item_ATCs__c>();
                        for(Agreement_Line_Item_ATCs__c AGLIMarkDef : AGLIIdwithMarketDefMap.get(AGLIId).Agreement_Line_Item_ATCs__r ) {
                            
                            if( !ATCIdwithAGLIMarketDefMap.containsKey(AGLIMarkDef.ATC__c)) {
                                ATCIdwithAGLIMarketDefMap.put(AGLIMarkDef.ATC__c, AGLIMarkDef);
                            } 
                        }
                    }    
                    //if the selected atc codes do not already exist for the agreement line item create new records in agreement line item atc    
                    for(List<ATCSearchWrapper> lstOfAllSelectedItems:listOfAllSelectedData) {   // iterating on the list of list used to display all selected item from all records type in below table
                        for(ATCSearchWrapper objWrapper : lstOfAllSelectedItems)
                        {                           
                            if(objWrapper.selectedFlag )
                            {   
                                if( objWrapper.ATC.Id != null  && !ATCIdwithAGLIMarketDefMap.containsKey(objWrapper.ATC.Id)) // TO skip ATC code who are already attached with Agreement line item 
                                {
                                    objLineItemATC =  new Agreement_Line_Item_ATCs__c();
                                    objLineItemATC.Agreement_Line_Item__c = AGLIId ;
                                    
                                    objLineItemATC.Delivery_Frequency__c  = AGLIIdwithMarketDefMap.get(AGLIId).Delivery_Rpt_Frequency__c;
                                    
                                    objLineItemATC.Data_Period_Start__c   = AGLIIdwithMarketDefMap.get(AGLIId).Data_Period_Start__c;
                                    
                                    objLineItemATC.Data_Period_End__c     = AGLIIdwithMarketDefMap.get(AGLIId).Data_Period_End__c;
                                    
                                    objLineItemATC.ATC__c = objWrapper.ATC.id;
                                    lstALIATCs.add(objLineItemATC);                 
                                }
                            }  // by sandeep 6 sept  
                            else                        
                            {
                                // TO skip ATC code who are already attached with Agreement line item
                                // && MapOfExistingAGLIATC != null && MapOfExistingAGLIATC.KeySet().contains(objWrapper.ATC.Id) 
                                if( objWrapper.ATC.Id != null && ATCIdwithAGLIMarketDefMap.containsKey(objWrapper.ATC.Id))
                                {
                                    ListToDeleteExistingAGLIATCs.add(ATCIdwithAGLIMarketDefMap.get(objWrapper.ATC.Id));                                  
                                } 
                            }
                            
                        }
                    }
                } //end of outer for loop
            }//end of if
            
            // by sandeep 6 sept
            // To UnMap existing records 
            if(ListToDeleteExistingAGLIATCs.size()>0) {
                delete ListToDeleteExistingAGLIATCs ; 
                //commented by Rakesh : 16 April 2013 
                // updateMarketDefinition();
            }
            
            // by sandeep 6 sept
            if(lstALIATCs.size() > 0) {
                
                upsert lstALIATCs;
                //commented by Rakesh : 16 April 2013
                //  updateMarketDefinition();  // pass list of all data to be inserted as an arguement. 
            } 
            
            //Added by Rakesh : 15 April 2013 :: ER-0339 
            //Commented By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906
            //if(ListToDeleteExistingAGLIATCs.size() > 0 || lstALIATCs.size() > 0)  {
            updateMarketDefinition();
            //Commented By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906     
            // }
            
            //Updated by Vikas Issue 4669 Dated 19 June 2014
            PageReference ref;  
            if (aggId != null) {
                ref =  new PageReference('/' + aggId);
                return ref;
            } else if(ALIId != null) {
                ref =  new PageReference('/' + ALIId);
                return ref;
            } else {
                return null;
            }
        }catch(Exception e)
        {
            ApexPages.addMessages(e);
            return null; 
        } 
    }
    
    
    /* Created By : Ranu Jain,Date: 21st Aug 
Detail : This method is created to updated 'Market Definitions' field of Agreement Line Item Object which store comma seperated values of all atc code to which it is associated
Updated By : Ranu Jain, Date : 10 sep,Detail : fix Issue-00901
*/
    /** Updated by Rakesh : 16 April 2013 :: ER - 0339 **/
    private void updateMarketDefinition()  {
        String MarketdefUpdate;
        String MarketdefUpdateATC;
        String MarketdefUpdateUSC;
        String MarketdefUpdateBrand;
        String MarketdefUpdateMFR;
        String MarketdefUpdateSpetiality;
        
        //Added By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) 
        string MarketdefNECUpdate;
        
        Try
        { 
            //Updated by Rakesh : 15 April 2013 :: ER-0339 
            //Updated By:- Ekta , Date :- 22nd July , 2015 , Details:-Issue-07530
            List<Agreement_Line_item__c> AGLIIdwithMarketDefListNew = [select Id,  (select ATC__c, ATC__r.ATC_Code__c, ATC__r.Name_Eng__c, ATC__r.recordTypeId   from Agreement_Line_Item_ATCs__r Order by ATC__r.ATC_Code__c,ATC__r.Name_Eng__c) from Agreement_Line_item__c where id in :setOfUpdatedALIId];         
            List<Agreement_Line_item__c> ALIListToUpdate = new List<Agreement_Line_item__c>();
            Agreement_Line_item__c Aggli;
            
            //for all AgrementLineItems
            for(Agreement_Line_item__c AGLIRecord : AGLIIdwithMarketDefListNew ) {
                
                //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612)
                //MarketdefUpdate = MarketdefUpdateATC = MarketdefUpdateUSC = MarketdefUpdateBrand = MarketdefUpdateMFR = MarketdefUpdateSpetiality =  '';
                //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906 
                Aggli = new Agreement_Line_item__c(id = AGLIRecord.Id);
                //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906
                if((lstALIATCs != null && lstALIATCs.size() > 0) || (ListToDeleteExistingAGLIATCs != Null && ListToDeleteExistingAGLIATCs.size() > 0))
                {
                    
                    MarketdefUpdate = MarketdefUpdateATC = MarketdefUpdateUSC = MarketdefUpdateBrand = MarketdefUpdateMFR = MarketdefUpdateSpetiality = MarketdefNECUpdate = '';
                    
                    //set Marketdef of ALI according to ATC's record type     
                    for(Agreement_Line_Item_ATCs__c AliAtc :  AGLIRecord.Agreement_Line_Item_ATCs__r) {
                        //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) :: Change RecordType index from 4 to 5
                        //if(AliAtc.ATC__r.recordTypeId == recordTypes.get(4) ){           // fix Issue-00901 USC
                        if(AliAtc.ATC__r.recordTypeId == recordTypes.get(5) ){
                            //Updated By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                            MarketdefUpdateUSC = MarketdefUpdateUSC +  AliAtc.ATC__r.ATC_Code__c +' '+AliAtc.ATC__r.Name_Eng__c+';'+' ';     
                        }else if(AliAtc.ATC__r.recordTypeId == recordTypes.get(0)){
                            //Updated By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                            MarketdefUpdateATC = MarketdefUpdateATC + AliAtc.ATC__r.ATC_Code__c +' '+AliAtc.ATC__r.Name_Eng__c+';'+' ';         
                        }else if(AliAtc.ATC__r.recordTypeId == recordTypes.get(1)){
                            //Updated By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                            //Updated By:- Ekta , Date :- 22nd July , 2015 , Details:-Issue-07530(Remove one extra space)
                            MarketdefUpdateBrand = MarketdefUpdateBrand + AliAtc.ATC__r.Name_Eng__c +';';       
                        }
                        else if(AliAtc.ATC__r.recordTypeId == recordTypes.get(2)){
                            //Updated By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                            //Updated By:- Ekta , Date :- 22nd July , 2015 , Details:-Issue-07530(Remove one extra space)
                            MarketdefUpdateMFR = MarketdefUpdateMFR + AliAtc.ATC__r.Name_Eng__c+';';   
                        }
                        //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) :: Change RecordType index from 3 to 4
                        //else if(AliAtc.ATC__r.recordTypeId == recordTypes.get(3)){
                        else if(AliAtc.ATC__r.recordTypeId == recordTypes.get(4)){
                            //Updated By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                            //Updated By:- Ekta , Date :- 22nd July , 2015 , Details:-Issue-07530(Remove one extra space)
                            MarketdefUpdateSpetiality = MarketdefUpdateSpetiality +AliAtc.ATC__r.Name_Eng__c +';';     
                        }
                        //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) :: For NEC Market Def ****  START  ****
                        else if(AliAtc.ATC__r.recordTypeId == recordTypes.get(3)){
                            //Updated By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                            MarketdefNECUpdate = MarketdefNECUpdate + AliAtc.ATC__r.ATC_Code__c +' '+AliAtc.ATC__r.Name_Eng__c+';'+' ';      
                        }
                        //**** END : Issue-03198(ER-0612)  *****
                    } 
                    
                    //Updated By Rakesh : 21 Nov 2013 : Issue-03198(ER-0612) :: Add NEC Market Def   
                    //MarketdefUpdate = MarketdefUpdateUSC+MarketdefUpdateATC+MarketdefUpdateBrand+MarketdefUpdateMFR+MarketdefUpdateSpetiality;
                    //Updated By Rakesh : 27 Dec 2013 : ER-476
                    //MarketdefUpdate = MarketdefUpdateUSC+MarketdefUpdateATC+MarketdefUpdateBrand+MarketdefUpdateMFR+MarketdefNECUpdate+MarketdefUpdateSpetiality;
                    //Updated By Rakesh : 3 Jan 2014 : Issue-03393(ER-476)
                    //MarketdefUpdate = (!String.isBlank(MarketdefUpdateUSC)?'USC : ':'')+MarketdefUpdateUSC+(!String.isBlank(MarketdefUpdateUSC)?' ':'')+(!String.isBlank(MarketdefUpdateATC)?'ATC : ':'')+MarketdefUpdateATC+(!String.isBlank(MarketdefUpdateATC)?' ':'')+(!String.isBlank(MarketdefUpdateBrand)?'BRAND : ':'')+MarketdefUpdateBrand+(!String.isBlank(MarketdefUpdateBrand)?' ':'')+(!String.isBlank(MarketdefUpdateMFR)?'MFR : ':'')+MarketdefUpdateMFR+(!String.isBlank(MarketdefUpdateMFR)?' ':'')+(!String.isBlank(MarketdefNECUpdate)?'NEC : ':'')+MarketdefNECUpdate+(!String.isBlank(MarketdefNECUpdate)?' ':'')+(!String.isBlank(MarketdefUpdateSpetiality)?'SPETIALITY : ':'')+MarketdefUpdateSpetiality; 
                    
                    //Added By:- Ekta , Date :- 22nd July , 2015 , Details:-Issue-07530
                    if(MarketdefUpdateBrand != Null && MarketdefUpdateBrand != '')
                        MarketdefUpdateBrand = sortMarketDef(MarketdefUpdateBrand );
                    if(MarketdefUpdateMFR != Null && MarketdefUpdateMFR != '')
                        MarketdefUpdateMFR = sortMarketDef(MarketdefUpdateMFR );    
                    if(MarketdefUpdateSpetiality != Null && MarketdefUpdateSpetiality != '')
                        MarketdefUpdateSpetiality = sortMarketDef(MarketdefUpdateSpetiality );
                    //Ended By:- Ekta , Date :- 22nd July , 2015 , Details:-Issue-07530
                    MarketdefUpdate = (!String.isBlank(MarketdefUpdateUSC)?'USC : ':'')+MarketdefUpdateUSC+(!String.isBlank(MarketdefUpdateATC)?'ATC : ':'')+MarketdefUpdateATC+(!String.isBlank(MarketdefUpdateBrand)?'BRAND : ':'')+MarketdefUpdateBrand+(!String.isBlank(MarketdefUpdateMFR)?'MFR : ':'')+MarketdefUpdateMFR+(!String.isBlank(MarketdefNECUpdate)?'NEC : ':'')+MarketdefNECUpdate+(!String.isBlank(MarketdefUpdateSpetiality)?'SPETIALITY : ':'')+MarketdefUpdateSpetiality + ';';
                    
                    
                    if(MarketdefUpdate != '') {
                        MarketdefUpdate = MarketdefUpdate.replaceAll('null;','');
                        MarketdefUpdate = MarketdefUpdate.substring(0, MarketdefUpdate.lastIndexOf(';') );
                    }
                    
                    //Updated By Rakesh : 3 Jan 2014 : Issue-03393(ER-476)
                    //Aggli = new Agreement_Line_item__c(id = AGLIRecord.Id, Apts_Market_Definitions__c = '');//[select id from Agreement_Line_item__c where id =: ALIId]; // Agreement Line Item on which filed is to be updated
                    Aggli = new Agreement_Line_item__c(id = AGLIRecord.Id, Apts_Market_Definitions__c = '', 
                                                       ATC_Market_Def__c = '',
                                                       Brand_Market_Def__c = '',
                                                       Manufacturer_Market_Def__c = '',
                                                       NEC_Market_Def__c = '',
                                                       Speciality_Market_Def__c = '',
                                                       USC_Market_Def__c = '',
                                                       Market_Definitions_By_Groups__c = ''
                                                      );
                    
                    //Aggli.Apts_Market_Definitions__c = '';
                    Aggli.Apts_Market_Definitions__c = MarketdefUpdate ;
                    //Added By Rakesh : 3 Jan 2014 : Issue-03393(ER-476)
                    //******* START *******
                    //Updated By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                    Aggli.ATC_Market_Def__c = (!String.isBlank(MarketdefUpdateATC)? MarketdefUpdateATC.substring(0, MarketdefUpdateATC.lastIndexOf(';') ).replaceAll('null','') : '');
                    Aggli.Brand_Market_Def__c = (!String.isBlank(MarketdefUpdateBrand)? MarketdefUpdateBrand.substring(0, MarketdefUpdateBrand.lastIndexOf(';') ).replaceAll('null;','').replaceAll('null','') : '');
                    Aggli.Manufacturer_Market_Def__c = (!String.isBlank(MarketdefUpdateMFR)? MarketdefUpdateMFR.substring(0, MarketdefUpdateMFR.lastIndexOf(';') ).replaceAll('null;','').replaceAll('null','') : '');
                    Aggli.NEC_Market_Def__c = (!String.isBlank(MarketdefNECUpdate)? MarketdefNECUpdate.substring(0, MarketdefNECUpdate.lastIndexOf(';') ).replaceAll('null','') : '');
                    Aggli.Speciality_Market_Def__c = (!String.isBlank(MarketdefUpdateSpetiality)? MarketdefUpdateSpetiality.substring(0, MarketdefUpdateSpetiality.lastIndexOf(';') ).replaceAll('null;','').replaceAll('null','') : '');
                    Aggli.USC_Market_Def__c = (!String.isBlank(MarketdefUpdateUSC)? MarketdefUpdateUSC.substring(0, MarketdefUpdateUSC.lastIndexOf(';') ).replaceAll('null','') : '');
                    //Ended By:-Ekta, Date:-4th July, 2014, Details:-Er-888
                    string MarketdefUpdateByGroup = (!String.isBlank(Aggli.USC_Market_Def__c)?'<b>USC : </b>'+Aggli.USC_Market_Def__c+'<br/>':'')+
                        (!String.isBlank(Aggli.ATC_Market_Def__c)?'<b>ATC : </b>'+Aggli.ATC_Market_Def__c+'<br/>':'')+
                        (!String.isBlank(Aggli.Brand_Market_Def__c)?'<b>BRAND : </b>'+Aggli.Brand_Market_Def__c+'<br/>':'')+
                        (!String.isBlank(Aggli.Manufacturer_Market_Def__c)?'<b>MFR : </b>'+Aggli.Manufacturer_Market_Def__c+'<br/>':'')+
                        (!String.isBlank(Aggli.NEC_Market_Def__c)?'<b>NEC : </b>'+Aggli.NEC_Market_Def__c+'<br/>':'')+
                        //Updated By Rakesh : 9 Jan 2014 : Issue-03427 :: Change text from SPETIALITY to SPECIALITY
                        //(!String.isBlank(Aggli.Speciality_Market_Def__c)?'<b>SPETIALITY : </b>'+Aggli.Speciality_Market_Def__c:'');
                        (!String.isBlank(Aggli.Speciality_Market_Def__c)?'<b>SPECIALITY : </b>'+Aggli.Speciality_Market_Def__c:'');
                    
                    Aggli.Market_Definitions_By_Groups__c = MarketdefUpdateByGroup;
                    //****** END : Issue-03393(ER-476) *******
                    
                    /* Updated by :Ranu, Issue_1578 
* Detail : If user delete all market defs then 'Market Def Options' picklist is set to
* '--None--'
*/
                    
                    if(MarketdefUpdate == '' || MarketdefUpdate == Null ) {
                        Aggli.Market_Definition_Options__c = Null;    
                    }
                    //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906 (added { )
                }
                //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906
                Aggli.Apts_Additional_Subsetting__c = agliController.Apts_Additional_Subsetting__c;
                
                ALIListToUpdate.add(Aggli);
            }  
            //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906
            if(ALIListToUpdate != Null && ALIListToUpdate.size() > 0)
                update ALIListToUpdate;
        }catch(Exception e) {
            //Added By:-Ekta , Date :- 25th June , 2015 , Details:- ER - 1906
            throw e ;
        }              
    }
    
    //Added By:- Ekta , Date :- 22nd July , 2015 , Details:-Issue-07530
    public String sortMarketDef(String MarketDef)
    {
        List<String> listforSorting = new List<String>();
        if(MarketDef != Null)
            listforSorting.addAll(MarketDef.trim().split(';'));
        listforSorting.sort();
        MarketDef = '';
        for(Integer countSize = 0 ;countSize<listforSorting.size() ;countSize++)
            MarketDef = MarketDef+listforSorting[countSize]+';'+' ';
        system.debug(MarketDef +'****test****'+listforSorting);
        return MarketDef;
    }
    /**-- cancel button handler --**/
    public pageReference CancelATCSearch()
    {
        //Updated by Vikas Issue 4669 Dated 20 June 2014
        PageReference ref;  
        if (aggId != null) {
            ref =  new PageReference('/' + aggId);
            return ref;
        } else if(ALIId != null) {
            ref =  new PageReference('/' + ALIId);
            return ref;
        } else {
            return null;
        }
    }
    
    /**-- wrapper class to show ATC Searh results --**/
    public class ATCSearchWrapper
    {
        //public properties
        public ATC__c ATC {get;set;}                
        public boolean selectedFlag {get;set;}
        //constructor
        public ATCSearchWrapper(ATC__c objATC)
        {   
            ATC = objATC;
            selectedFlag =  false;       
        }
        public ATCSearchWrapper(ATC__c objATC,boolean flg)
        {   
            ATC = objATC;
            selectedFlag =  flg;       
        }               
    }
}