/*
 * Version       : 1.0
 * Description   : Apex Controller for Mikado component.
 */
public with sharing class CNT_CSM_Mikado {
    
     @AuraEnabled
    public static List<CSM_QI_Folder__c> getMikadoFolders(){
        List<CSM_QI_Folder__c> mikadoFolders =  new List<CSM_QI_Folder__c> ();
        mikadoFolders =  [select Id, Name  from CSM_QI_Folder__c];
        return mikadoFolders;
    }
    
}