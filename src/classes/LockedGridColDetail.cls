public class LockedGridColDetail {
    
    public String colApiName {get; set;}
    public String colName {get;set;}
    public Integer colWidth {get; set;}
    public String colHdrId {get;set;}
    public String colId {get; set;}
    public Boolean showChkBx {get; set;}
    public Boolean showhelpText {get; set;}
    
    public LockedGridColDetail(String inColApiName, String inColName,Integer inColWidth, String inColHdrId, 
                                Boolean inShowChkBx, String inColId){
        this.colApiName = inColApiName;
        this.colName = inColName;
        this.colWidth = inColWidth;
        this.colHdrId = inColHdrId;
        this.showChkBx = inShowChkBx;
        this.colId = inColId;
       	this.showhelpText = false;
    }
    // updated by dheeraj kumar Issue-09948
     public LockedGridColDetail(String inColApiName, String inColName,Integer inColWidth, String inColHdrId, 
                                Boolean inShowChkBx, String inColId, Boolean showhelpText){
        this.colApiName = inColApiName;
        this.colName = inColName;
        this.colWidth = inColWidth;
        this.colHdrId = inColHdrId;
        this.showChkBx = inShowChkBx;
        this.colId = inColId;
        this.showhelpText = showhelpText;
        
    }
    
    
}