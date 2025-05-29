//component controller class
public class LockedGridCompController {
    
    public List <sObject> objItemList {get; 
        set{
            system.debug('I am called');
            objItemList = value;
        }
    }
    
    public Boolean addendum{
        get;
        set{
            addendum = value;
        }
    }
    
    //BEGIN - Locking grid VARS
    public List<LockedGridColDetail> lokcedColList {get; 
        set{
            totalLockedWidth = 0;
            for(LockedGridColDetail lkdCol : value) {
                totalLockedWidth += lkdCol.colWidth;
            }
        }
    }
    
    public List<LockedGridColDetail> unLockedColList {get; 
        set{
            totalUnLockedWidth = 0;
            for(LockedGridColDetail nLkdCol : value) {
                totalUnLockedWidth += nLkdCol.colWidth;
            }
        }
    }
    
    public Integer tableHeight {
        get{
            tableHeight = MAX_TABLE_HEIGHT;
            if (objItemList != null && objItemList.size() >= 0){
                tableHeight = (objItemList.size() * MIN_COL_HEIGHT) + 40;
                tableHeight = (tableHeight < MAX_TABLE_HEIGHT) ?tableHeight  : MAX_TABLE_HEIGHT ;
                tableHeight += 10;
            }
            return tableHeight ;
        } 
    private set;}
    public Integer tableWidth {
        get {
            Integer tWidth = 0;
            tWidth = totalLockedWidth + totalUnLockedWidth  ;
            tWidth = (tWidth > MAX_TABLE_UNLOCKED_WIDTH) ? MAX_TABLE_UNLOCKED_WIDTH : tWidth ;
            return tWidth ;
        }
    }
    
    public Integer totalLockedWidth {get; set;}
    public Integer totalUnLockedWidth {get; set;}
    
    private static final integer MAX_TABLE_UNLOCKED_WIDTH = 99;
    private static final integer MAX_TABLE_HEIGHT = 600;
    private static final integer MIN_COL_HEIGHT = 82;
     //END - Locking grid VARS
           
    public LockedGridCompController(){
    }
}