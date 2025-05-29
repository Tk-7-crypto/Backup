/****************************************************************************************
Name            : Address Wrapper class for MIBNF
Author          : Himanshu (Metacube)
Created Date    : July 15, 2014
Revision History: 
                : 
Usage           : This Class is used to pass wrapper object to MIBNF Show message component to display message
                : 
                :  
****************************************************************************************/
public Class AddressWrapper
{
   public Map<String, Address__c> map_Filled_Addresses;
   
   public AddressWrapper(Map<String,Address__c> Filled_Addresses)
   {
       map_Filled_Addresses= new Map<String,Address__c>();
       map_Filled_Addresses=Filled_Addresses;
   }

}