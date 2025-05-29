/**
* Controller class of VFP_CRM_NavigateToProductExcel page.
*/
public class CNT_CRM_NavigateToProductExcel {
    
    public string xmlheader {get;set;}
    public string endfile{get;set;}

    public CNT_CRM_NavigateToProductExcel(ApexPages.StandardController controller) {
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
    }
	
    /**
     * This method is used to get the Current time for naming pattern of generated excel.
     * @return  DateTime
     */
    public DateTime getCurrentTime()
    {
        return System.now();
    }
    
}