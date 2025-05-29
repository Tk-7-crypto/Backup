/****************************************************
*Create By : Sandeep Kr Singhal 20 June 2012
*Purpose :  To Clone All Hierarchy of Agreement Object 
*****************************************************/
public with sharing class Clone_Agreement {    
    
    // Public properties
    public String selectedOption{get;set;}
    // Private properties
    Private String OriginalAggId ; 
    Private Agreement__c newAgreement ;
    Private Map<id ,Agreement_Line_Item__c>  MapOfOriginalAndNewALIs ;
    Private List<Agreement_Line_Item__c> OriginalAgLIs ;
    
    // Constructor
    public clone_Agreement(ApexPages.StandardController controller) {
        OriginalAggId = apexpages.currentpage().getparameters().get('Id');  
        selectedOption = ConstantClass.Agreement ; 
    }
    
    // Options to show on Page
    public List<SelectOption> getCloneOptions()
    {   
        List<SelectOption> optionList = new List<SelectOption>() ;
        optionList.add(new SelectOption(ConstantClass.Agreement, ConstantClass.Agreement)) ;
        optionList.add(new SelectOption(ConstantClass.AggWithProd , ConstantClass.AggWithProd  )) ;
        optionList.add(new SelectOption(ConstantClass.AggWithProdAndATC, ConstantClass.AggWithProdAndATC )) ;
        optionList.add(new SelectOption(ConstantClass.Clone_All, ConstantClass.Clone_All )) ;
        return optionList ; 
    }
    
    // Base method to invock separate methods to clone Objects
    public PageReference cloneObject()
    {   
        Try{
            // To stop Trigger working to set Default Name
            SCM_Static_FlagClass.AllowTriggerTOsetDefaultName= false ; 
            if(OriginalAggId != null)
            {
                if(selectedOption == null)
                {
                    ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error ,ConstantClass.select_AtLeast_One_Option );
                        ApexPages.addMessage(infoMsg);
                        return null ; 
                }
                else            
                {   
                    if(selectedOption == ConstantClass.Agreement)
                        cloneAgreements() ;
                    else if(selectedOption == ConstantClass.AggWithProd )
                        cloneAgreementWithProducts() ;
                    else if(selectedOption == ConstantClass.AggWithProdAndATC)
                        cloneAgreementWithProductAndATCs() ;
                    else if(selectedOption == ConstantClass.Clone_All)
                        cloneAll();
                    if(newAgreement != null)
                        return new pageReference('/'+newAgreement.id) ;
                    else 
                        return null ; 
                }
            }
            else
                return null ; 
                     
        }
        Catch(Exception e )
        {  
           ApexPages.Message infoMsg = new ApexPages.Message(ApexPages.Severity.Error ,e.getMessage() );
                    ApexPages.addMessage(infoMsg);
                    return null ;                    
        }
    }
    // Option1: Clone only Agreement
    private void cloneAgreements()
    {       
       // getting original record to be cloned 
       List<Agreement__c> OriginalAgreements = new List<Agreement__c>([select id ,Account__c ,Other_Party_Signed_By_Unlisted__c , Active__c ,Agreement_Category__c ,Contract_End_Date__c ,Name ,Contract_Start_Date__c ,Agreement_Term__c , Company_Siged_By_c__c ,Company_Signed_By_Unlisted__c , Company_Signed_Title__c ,Contract_Type__c , Other_Party_Signed_By__c ,Other_Party_Signed_Title__c , ownerId , Parent_Agreement__c , recordTypeId , Related_Opportunity__c  from Agreement__c where id =: OriginalAggId limit : limits.getLimitQueryRows()]);
       if(OriginalAgreements.size() > 0)
       {
            newAgreement = new Agreement__c(
            Name    = OriginalAgreements[0].Name ,
            ownerId = OriginalAgreements[0].ownerId ,
            Active__c   = OriginalAgreements[0].Active__c ,             
            recordTypeId = OriginalAgreements[0].recordTypeId ,
            Contract_Type__c = OriginalAgreements[0].Contract_Type__c ,
            Agreement_Term__c  = OriginalAgreements[0].Agreement_Term__c ,
            Account__c = OriginalAgreements[0].Account__c , 
            Company_Signed_By_Unlisted__c = OriginalAgreements[0].Company_Signed_By_Unlisted__c ,
            //Company_Siged_By_c__c = OriginalAgreements[0].Company_Siged_By_c__c ,
            Parent_Agreement__c  = OriginalAgreements[0].Parent_Agreement__c ,
            Contract_End_Date__c = OriginalAgreements[0].Contract_End_Date__c ,
            Agreement_Category__c = OriginalAgreements[0].Agreement_Category__c ,
            Contract_Start_Date__c = OriginalAgreements[0].Contract_Start_Date__c ,          
            Company_Signed_Title__c = OriginalAgreements[0].Company_Signed_Title__c ,
            //Other_Party_Signed_By__c = OriginalAgreements[0].Other_Party_Signed_By__c ,             
            Other_Party_Signed_Title__c  = OriginalAgreements[0].Other_Party_Signed_Title__c ,
            Other_Party_Signed_By_Unlisted__c   = OriginalAgreements[0].Other_Party_Signed_By_Unlisted__c 
            );
            insert newAgreement ;           
       }       
    }
    
    // Option2: Clone Agreement and Agreement Line Item
    private void cloneAgreementWithProducts()
    {
        cloneAgreements();        
        OriginalAgLIs = new List<Agreement_Line_Item__c>([select id ,Contract_End_Date__c ,Contract_Start_Date__c ,CurrencyIsoCode ,Data_Period_End__c ,Data_Period_Start__c ,ProductId__c , Delivery_Rpt_Frequency__c ,Delivery_Media__c from Agreement_Line_Item__c where AgreementId__c =: OriginalAggId limit : limits.getLimitQueryRows() ]);
        if(OriginalAgLIs.size() >0)
        {
            Agreement_Line_Item__c newAgLi ;            
            MapOfOriginalAndNewALIs = new Map<id , Agreement_Line_Item__c>() ;
            
            for(Agreement_Line_Item__c OriginalAgLI : OriginalAgLIs )
            {
                newAgLi = new Agreement_Line_Item__c(               
                Contract_End_Date__c    = OriginalAgLI.Contract_End_Date__c ,
                Contract_Start_Date__c  = OriginalAgLI.Contract_Start_Date__c ,
                CurrencyIsoCode         = OriginalAgLI.CurrencyIsoCode ,
                Data_Period_End__c      = OriginalAgLI.Data_Period_End__c ,
                Data_Period_Start__c    = OriginalAgLI.Data_Period_Start__c ,
                ProductId__c    = OriginalAgLI.ProductId__c ,
                Delivery_Rpt_Frequency__c  = OriginalAgLI.Delivery_Rpt_Frequency__c ,
                Delivery_Media__c       = OriginalAgLI.Delivery_Media__c ,
                AgreementId__c  = newAgreement.id );
                // Map of Original AgLI and cloned AgLI .This map will be used to provide Reference for new child records like AgLI ATC and AgLI Discount objects.
                MapOfOriginalAndNewALIs.put(OriginalAgLI.id , newAgLi) ;
            }
            if(MapOfOriginalAndNewALIs != null && MapOfOriginalAndNewALIs.values().size()> 0) 
            {
                insert MapOfOriginalAndNewALIs.values();
            }
        }
        
    }
    //Option3: Clone Agreement, Agreement Line Item, and Agreement Line Item ATC
    private void cloneAgreementWithProductAndATCs() 
    {
        cloneAgreementWithProducts();
        if(MapOfOriginalAndNewALIs  != null && MapOfOriginalAndNewALIs.values() != null && MapOfOriginalAndNewALIs.values().size()>0)
        {
            // To clone Agreement Line item ATCs 
            List<Agreement_Line_Item_ATCs__c> OriginalAgLIATCs = new List<Agreement_Line_Item_ATCs__c>([select id ,Name , ATC__c,Data_Period_End__c ,Data_Period_Start__c ,Delivery_Frequency__c, Agreement_Line_Item__c from Agreement_Line_Item_ATCs__c where Agreement_Line_Item__c In : OriginalAgLIs limit : limits.getLimitQueryRows() ]) ;
            if(OriginalAgLIATCs.size() >0 )
            {
                Agreement_Line_Item_ATCs__c newAgLIATC ; 
                List<Agreement_Line_Item_ATCs__c> newAggLineItemATCs = new List<Agreement_Line_Item_ATCs__c>() ;
                for(Agreement_Line_Item_ATCs__c  OriginalAgLIATC : OriginalAgLIATCs )
                {
                    newAgLIATC  = new Agreement_Line_Item_ATCs__c () ;                    
                    newAgLIATC.Data_Period_End__c    = OriginalAgLIATC.Data_Period_End__c ;
                    newAgLIATC.Data_Period_Start__c  = OriginalAgLIATC.Data_Period_Start__c ;
                    newAgLIATC.Delivery_Frequency__c =  OriginalAgLIATC.Delivery_Frequency__c ;
                    newAgLIATC.ATC__c = OriginalAgLIATC.ATC__c ;                    
                    // getting Id of newly inserted Agreement line item to populate in agreement line item ATC
                    if(MapOfOriginalAndNewALIs.containsKey(OriginalAgLIATC.Agreement_Line_Item__c) && MapOfOriginalAndNewALIs.get(OriginalAgLIATC.Agreement_Line_Item__c)!= null )
                        newAgLIATC.Agreement_Line_Item__c = MapOfOriginalAndNewALIs.get(OriginalAgLIATC.Agreement_Line_Item__c).id ;
                    newAggLineItemATCs.add(newAgLIATC); 
                    
                }
                if(newAggLineItemATCs.size() >0)
                    Insert newAggLineItemATCs ; 
            }                         
        }
    }
    //Option4: Clone All (Agreement, Agreement Line Item, Agreement Line Item ATC, and Agreement Line Item Discount)
    private void cloneAll()
    {
        cloneAgreementWithProductAndATCs();
        if(MapOfOriginalAndNewALIs  != null && MapOfOriginalAndNewALIs.values() != null && MapOfOriginalAndNewALIs.values().size()>0)
        {
            //To clone Agreement Line Item Discount object 
            //Updated By:-Ekta ,Date:-13th Nov,2013 , Details:- ER - 0566
            //List<Agreement_Line_Item_Discount__c> OriginalAgLIDiscounts = new List<Agreement_Line_Item_Discount__c>([select id ,Discount_Price__c ,Agreement_Line_Item__c , Discount_Type__c from Agreement_Line_Item_Discount__c where Agreement_Line_Item__c In : OriginalAgLIs limit : limits.getLimitQueryRows() ]) ;
            List<Agreement_Line_Item_Discount__c> OriginalAgLIDiscounts = new List<Agreement_Line_Item_Discount__c>([select id ,Discount_Price__c ,Agreement_Line_Item__c  from Agreement_Line_Item_Discount__c where Agreement_Line_Item__c In : OriginalAgLIs limit : limits.getLimitQueryRows() ]) ;
           
            if(OriginalAgLIDiscounts.size() >0 )
            {
                Agreement_Line_Item_Discount__c newAgLIDiscount ; 
                List<Agreement_Line_Item_Discount__c> newAggLineItemDicounts = new List<Agreement_Line_Item_Discount__c>() ;
                for(Agreement_Line_Item_Discount__c  OriginalAgLIDiscount : OriginalAgLIDiscounts )
                {
                    newAgLIDiscount  = new Agreement_Line_Item_Discount__c () ;
                    newAgLIDiscount.CurrencyIsoCode = OriginalAgLIDiscount.CurrencyIsoCode ;
                    //Commented By:-Ekta ,Date:-13th Nov,2013 , Details:- ER - 0566
                    //newAgLIDiscount.Discount_Type__c  = OriginalAgLIDiscount.Discount_Type__c ;
                    // getting Id of newly inserted Agreement line item to populate in agreement line item Discount
                    if(MapOfOriginalAndNewALIs.containsKey(OriginalAgLIDiscount.Agreement_Line_Item__c) && MapOfOriginalAndNewALIs.get(OriginalAgLIDiscount.Agreement_Line_Item__c)!= null )
                        newAgLIDiscount.Agreement_Line_Item__c =  MapOfOriginalAndNewALIs.get(OriginalAgLIDiscount.Agreement_Line_Item__c).id ;
                    newAggLineItemDicounts.add(newAgLIDiscount);
                }
                if(newAggLineItemDicounts.size() >0)
                    Insert newAggLineItemDicounts ; 
            }
        }
    }
}