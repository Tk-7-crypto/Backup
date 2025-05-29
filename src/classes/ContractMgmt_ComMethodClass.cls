/* Created By : Ranu Jain, Date : 6th Sep 
 * Detail : This class is created to store general methods which can be called from any class of Contract Mgmt.
 * this class is being used : ATC Search 
*/
public with sharing class ContractMgmt_ComMethodClass {
    
    /** Method to remove all single quotes from Strings **/
    public static String modifySearchStr (String searchByString)
    {
        
        if(searchByString.contains('\''))
            searchByString =string.escapeSingleQuotes(searchByString);
        String modifiedSearchByString = searchByString;
        if(searchByString.contains('*')){
            
            modifiedSearchByString = searchByString.replace('*', '%');
        }
        else {
            modifiedSearchByString = modifiedSearchByString+'%';
        }
        return modifiedSearchByString;
    }
    

}