/**
 * This is controller class for VF page VFP_CRM_ExportBillingScheduleItems
 * version : 1.0
 */
public class CNT_CRM_ExportBillingScheduleItems {
public List<oLIBillingScheduleWrapper> oLIBSWrapperData { get; set; }
    public String currencyISOCode { get; set; }
    public CNT_CRM_ExportBillingScheduleItems()
    {
        Map<Id, Integer> oLIIdToSerialNumberMap = new Map<Id, Integer>();
        
        Map<Id, OpportunityLineItem> oliIDtoOLImap = new Map<Id, OpportunityLineItem>();
        
        string exportedData = ApexPages.currentPage().getParameters().get('dataParam'); 
        List<String> oLIIdSet = exportedData.split(',');
        Set<String> oliIdSetNew = new Set<String>(oLIIdSet);
        if(oLIIdSet.size()>0){
            List<Billing_Schedule_Item__c> billingScheduleLineItems = [select  Billing_Schedule__r.OLIId__c, Billing_Date__c,Billing_Amount__c, Invoice_Description__c, CurrencyIsoCode, Billing_Schedule__r.CurrencyIsoCode  from Billing_Schedule_Item__c where Billing_Schedule__r.OLIId__c In :oLIIdSet];
            List<OpportunityLineItem> oLIData = [select id, CurrencyIsoCode, Product_Name__c, ProductCode, Product_Material_Type__c, Delivery_Country__c, TotalPrice from OpportunityLineItem where Id In :oLIIdSet];   
            currencyISOCode = oLIData[0].CurrencyIsoCode; 
            Integer counter = 0;
            for(String oliId : oliIdSetNew){
                counter++;
                oLIIdToSerialNumberMap.put(oliId,counter);
                
            }
			//check which OLI has Billing schedules and which OLI does not have any billing schedule
            Set<ID> oliHavingBillingSchedules = new Set<ID>();
            for(Billing_Schedule_Item__c billingItem : billingScheduleLineItems){
                oliHavingBillingSchedules.add(billingItem.Billing_Schedule__r.OLIId__c);
            }
            if(billingScheduleLineItems.size()>0 ){ 
                if(oLIData.size() > 0){
                    for(OpportunityLineItem olidata1 : oLIData){
                        oliIDtoOLImap.put(olidata1.Id, olidata1);
                    }
                }
                List<oLIBillingScheduleWrapper> oLIBSItemsWrapper = new List<oLIBillingScheduleWrapper>();
                
                for(Billing_Schedule_Item__c bSItems :billingScheduleLineItems){
                    if(oliHavingBillingSchedules.contains(bSItems.Billing_Schedule__r.OLIId__c)){
                        oLIBillingScheduleWrapper oliBSWrapper = new oLIBillingScheduleWrapper();
                        oliBSWrapper.serialNumber = oLIIdToSerialNumberMap.get(bSItems.Billing_Schedule__r.OLIId__c);
                        oliBSWrapper.oliId = bSItems.Billing_Schedule__r.OLIId__c;
                        string tempDate = String.valueof(bSItems.Billing_Date__c);
                        List<String> dateFormate = String.valueOf(tempDate).split('-');
                        oliBSWrapper.billingDate = dateFormate[1] + '-' + dateFormate[2] + '-' + dateFormate[0];
                        oliBSWrapper.billingAmount = bSItems.Billing_Amount__c;
                        oliBSWrapper.invoiceDescription = bSItems.Invoice_Description__c;
                        oliBSWrapper.productName = oliIDtoOLImap.get(bSItems.Billing_Schedule__r.OLIId__c).Product_Name__c;
                        oliBSWrapper.productCode = oliIDtoOLImap.get(bSItems.Billing_Schedule__r.OLIId__c).ProductCode;
                        oliBSWrapper.deliveryCountry = oliIDtoOLImap.get(bSItems.Billing_Schedule__r.OLIId__c).Delivery_Country__c;
                        oliBSWrapper.totalPriceOfOLI = oliIDtoOLImap.get(bSItems.Billing_Schedule__r.OLIId__c).TotalPrice;
                        oLIBSItemsWrapper.add(oliBSWrapper);
                    } 
                }
                for(Id oliIdNotHavingBillingItem : oliIdSetNew){
                    if(!oliHavingBillingSchedules.contains(oliIdNotHavingBillingItem)){
                        oLIBillingScheduleWrapper oliBSWrapper = new oLIBillingScheduleWrapper();
                        oliBSWrapper.oliId = oliIdNotHavingBillingItem;
                        oliBSWrapper.billingDate = null;
                        oliBSWrapper.serialNumber = oLIIdToSerialNumberMap.get(oliIdNotHavingBillingItem);
                        oliBSWrapper.productName = oliIDtoOLImap.get(oliIdNotHavingBillingItem).Product_Name__c;
                        oliBSWrapper.productCode = oliIDtoOLImap.get(oliIdNotHavingBillingItem).ProductCode;
                        oliBSWrapper.deliveryCountry = oliIDtoOLImap.get(oliIdNotHavingBillingItem).Delivery_Country__c;
                        oliBSWrapper.totalPriceOfOLI = oliIDtoOLImap.get(oliIdNotHavingBillingItem).TotalPrice;
                        oLIBSItemsWrapper.add(oliBSWrapper);
                    }
                }
                oLIBSItemsWrapper.sort();
                Map<Integer, List<oLIBillingScheduleWrapper>> serialNoOLIBSData = new Map<Integer, List<oLIBillingScheduleWrapper>>();
                for(oLIBillingScheduleWrapper oliBSData : oLIBSItemsWrapper){
                    if(serialNoOLIBSData.containsKey(oliBSData.serialNumber)){
                        // add the oliBS data to list 
                        List<oLIBillingScheduleWrapper> oliBSDataList = serialNoOLIBSData.get(oliBSData.serialNumber);
                        oliBSDataList.add(oliBSData);
                        serialNoOLIBSData.put(oliBSData.serialNumber, oliBSDataList);
                    } else{
                        serialNoOLIBSData.put(oliBSData.serialNumber, new List<oLIBillingScheduleWrapper>{oliBSData});
                    }
                }
                oLIBSWrapperData = new List<oLIBillingScheduleWrapper>();
                // to reorder the serial number data 
                for(Integer i=0; i<=oLIIdSet.size(); i++){
                    Integer count = 1;
                    for(Integer keyVal : serialNoOLIBSData.keySet()){
                        if(i == count){
                            List<oLIBillingScheduleWrapper> oliListBSdata = serialNoOLIBSData.get(count);
                            oLIBSWrapperData.addAll(oliListBSdata);
                        }
                        count++;
                    }          
                }   
                
            }
            else{
                List<oLIBillingScheduleWrapper> oLIBSItemsWrapper = new List<oLIBillingScheduleWrapper>();
                Integer serialNum = 1;
                for(OpportunityLineItem oli : oLIData){
                    if(oli.Product_Material_Type__c == 'ZREP'){
                        oLIBillingScheduleWrapper oliBSWrapper = new oLIBillingScheduleWrapper();
                        oliBSWrapper.oliId = oli.ID;
                        oliBSWrapper.serialNumber = serialNum;
                        oliBSWrapper.productName = oli.Product_Name__c;
                        oliBSWrapper.productCode = oli.ProductCode;
                        oliBSWrapper.deliveryCountry = oli.Delivery_Country__c;
                        oliBSWrapper.totalPriceOfOLI = oli.TotalPrice;
                        oLIBSItemsWrapper.add(oliBSWrapper);
                    }
                    serialNum++;
                }
                oLIBSWrapperData = oLIBSItemsWrapper;
            }
        }
    }
    public class oLIBillingScheduleWrapper implements Comparable{
        public Integer serialNumber {get;set;}
        public Id oliId {get; set;}
        public String billingDate {get; set;}
        public Decimal billingAmount {get; set;}
        public String invoiceDescription {get; set;}
        public String productName {get; set;}
        public String productCode {get; set;}
        public String deliveryCountry {get;set;}
        public Decimal totalPriceOfOLI {get;set;}
        public Integer compareTo(Object objToCompare){   
            return productName.compareTo(((oLIBillingScheduleWrapper)objToCompare).productName);
        } 
    }
}