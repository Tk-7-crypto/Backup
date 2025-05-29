@isTest
public class TST_LockedGridCompController {
    public static testmethod void testCompController() {
        Test.startTest();
        LockedGridCompController comController = new LockedGridCompController();
        
        List<LockedGridColDetail> detailList = new List<LockedGridColDetail>(); 
        
        for(Integer i = 0 ; i < 5; i++) {                                
            detailList.add(new LockedGridColDetail('Name', 'Name' ,120, 'nmHdrId' , 
                                    false , 'nmcolId')); 
        } 
        comController.unLockedColList = detailList;
        List<LockedGridColDetail> lockedDetailList = new List<LockedGridColDetail>(); 
        
        for(Integer i = 0 ; i < 2; i++) {                                
            lockedDetailList.add(new LockedGridColDetail('Name', 'Name' ,120, 'nmHdrId' , 
                                    false , 'nmcolId')); 
        } 
        comController.lokcedColList = lockedDetailList;
        
        //sobject list objItemList 
        List<Account> actList = new List<Account>();
        for(Integer j = 0 ; j < 10; j++) {
            actList.add(new Account(name = 'act' + j));
        }
        comController.objItemList = actList;
        system.debug(comController.tableHeight);
        System.assertEquals(comController.tableHeight , 610);
        system.debug(comController.tableWidth);
        System.assertEquals(comController.tableWidth  , 99);       
        Test.stopTest();
    }
}