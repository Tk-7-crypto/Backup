@isTest
public class TST_LockedGridColDetail {
    public static testmethod void testConstructorWith6Param(){
        Test.startTest();
        LockedGridColDetail details = new LockedGridColDetail('Name', 'Name' ,120, 'nmHdrId' , 
                                                              false , 'nmcolId');
        System.assertEquals(details.colApiName , 'Name');    
        Test.stopTest();
    }
    public static testmethod void testConstructorWith7Param(){
        Test.startTest();
        LockedGridColDetail details = new LockedGridColDetail('Name', 'Name' ,120, 'nmHdrId' , 
                                                              false , 'nmcolId',true);
        System.assertEquals(details.showhelpText , true);    
        Test.stopTest();
    }
}