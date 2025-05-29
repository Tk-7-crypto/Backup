/****************************************************************************************
Name            : MultiSheetExcelForIbnfController
Author          : Bhavesh Mittal
Created Date    : Dec 04, 2020
Use             : Component controller, used some variables
****************************************************************************************/
public class MultiSheetExcelForIbnfController{
    public string xmlheader {get;set;}
    public List<OpportunityLineItem> opptyli {get;set;}
    public BNF2__c BNF {get;set;}
    public Boolean isnewbnf {get;set;}
    public Map<String,List<Billing_Schedule_Item__c>> billingscheduleitems;
    public String billingscheduleitemsstring ;
    public Map<String,List<OpportunityLineItemSchedule>> revenuescheduleitems;
    public String revenuescheduleitemsstring ;
    public string endfile{get;set;}
    public MultiSheetExcelForIbnfController(){
        //VF page gives some issues directly using the below code there, so wrap up in variable
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
    }
    
    Public String getBillingscheduleitemsstring() {
        if(billingscheduleitemsstring != null) {
        	billingscheduleitems = (Map<String,List<Billing_Schedule_Item__c>>)JSON.deserializeStrict(billingscheduleitemsstring, Map<String,List<Billing_Schedule_Item__c>>.class);
        }
        return billingscheduleitemsstring;
    }
    
    public void setBillingscheduleitemsstring(String billingscheduleitemsstring) {
        this.billingscheduleitemsstring = billingscheduleitemsstring;
    }
    
    public Map<String,List<Billing_Schedule_Item__c>> getBillingscheduleitems() {
        billingscheduleitemsstring = getBillingscheduleitemsstring();
        return billingscheduleitems;
    }
    
    Public String getRevenuescheduleitemsstring() {
        if(revenuescheduleitemsstring != null) {
        	revenuescheduleitems = (Map<String,List<OpportunityLineItemSchedule>>)JSON.deserializeStrict(revenuescheduleitemsstring, Map<String,List<OpportunityLineItemSchedule>>.class);   
        }
        return revenuescheduleitemsstring;
    }
    
    public void setRevenuescheduleitemsstring(String revenuescheduleitemsstring) {
        this.revenuescheduleitemsstring = revenuescheduleitemsstring;
    }
    
    public Map<String,List<OpportunityLineItemSchedule>> getRevenuescheduleitems() {
        revenuescheduleitemsstring = getRevenuescheduleitemsstring();
        return revenuescheduleitems;
    }

}