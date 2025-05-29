public without sharing class UTL_SalesProgram {
	public static void updateSalesProgram(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<Id> spIds = new Set<Id>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> oppMap1 = new Map<Id, Opportunity>();
        
        for(Opportunity opp : newList){
            // If a sales program exist, insert, update, delete, undelete case
            if(opp.Sales_Program__c != null){
                spIds.add(opp.Sales_Program__c);
                oppMap.put(opp.Id, opp);
            }
            // If a sales program removed or replaced, update only case
            if(oldMap != null && oldMap.get(opp.Id).Sales_Program__c !=null && oldMap.get(opp.Id).Sales_Program__c != opp.Sales_Program__c){
                spIds.add(oldMap.get(opp.Id).Sales_Program__c);
                oppMap1.put(opp.Id, oldMap.get(opp.Id));
            } 
        }
        
        if(spIds.size() > 0){
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new Schema.SObjectType[] {
                    Sales_Program__c.SobjectType
                        }
            );
            
            Map<Id, Sales_Program__c> spMap = new SLT_SalesProgram().getSalesProgramById(spIds);
            Boolean toCommit = false;
            for(Opportunity opp : oppMap.values()){
                Sales_Program__c sp = spMap.get(opp.Sales_Program__c);
                if(Trigger.isInsert || Trigger.isUndelete || Trigger.isDelete){
                    Integer count = Trigger.isDelete ? -1 : 1;
                    updateSalesProgram(sp, opp, count);
                    uow.registerDirty(sp);
                    toCommit = true;
                }else if(Trigger.isUpdate){ 
                    if(opp.Sales_Program__c != oldMap.get(opp.Id).Sales_Program__c ){
                        sp.Total_Potential__c = sp.Total_Potential__c + (opp.Amount == null ? 0 : opp.Amount);
                        sp.TPAP__c = sp.TPAP__c + (opp.Total_Project_Awarded_Price__c == null ? 0 : opp.Total_Project_Awarded_Price__c);
                        if(opp.StageName == CON_CRM.CLOSED_WON_STAGE){
                            sp.Total_Won__c = sp.Total_Won__c + 1;
                        }else if(opp.StageName == CON_CRM.CLOSED_LOST_STAGE){
                            sp.Total_Lost__c = sp.Total_Lost__c + 1;
                        }
                        uow.registerDirty(sp);
                        toCommit = true;
                    }else{
                        Boolean flag = false;
                        if(opp.Amount != oldMap.get(opp.Id).Amount){
                            sp.Total_Potential__c = sp.Total_Potential__c - (oldMap.get(opp.Id).Amount == null ? 0 : oldMap.get(opp.Id).Amount) + (opp.Amount == null ? 0 : opp.Amount);
                            flag = true;
                        }
                        
                        if(opp.Total_Project_Awarded_Price__c != oldMap.get(opp.Id).Total_Project_Awarded_Price__c){
                            sp.TPAP__c = sp.TPAP__c - (oldMap.get(opp.Id).Total_Project_Awarded_Price__c == null ? 0 : oldMap.get(opp.Id).Total_Project_Awarded_Price__c) + (opp.Total_Project_Awarded_Price__c == null ? 0 : opp.Total_Project_Awarded_Price__c);
                            flag = true;
                        }
                        
                        if(opp.StageName == CON_CRM.CLOSED_WON_STAGE && opp.StageName != oldMap.get(opp.Id).StageName){
                            sp.Total_Won__c = sp.Total_Won__c + 1;
                            flag = true;
                        }else if(opp.StageName == CON_CRM.CLOSED_LOST_STAGE && opp.StageName != oldMap.get(opp.Id).StageName){
                            sp.Total_Lost__c = sp.Total_Lost__c + 1;
                            flag = true;
                        }
                        
                        if(oldMap.get(opp.Id).StageName == CON_CRM.CLOSED_WON_STAGE && opp.StageName != oldMap.get(opp.Id).StageName){
                            sp.Total_Won__c = sp.Total_Won__c - 1;
                            flag = true;
                        }else if(oldMap.get(opp.Id).StageName == CON_CRM.CLOSED_LOST_STAGE && opp.StageName != oldMap.get(opp.Id).StageName){
                            sp.Total_Lost__c = sp.Total_Lost__c - 1;
                            flag = true;
                        }
                        
                        if(flag){
                            uow.registerDirty(sp);
                            toCommit = true;
                        }
                    }
                }
            }
            
            for(Opportunity opp : oppMap1.values()){
                Sales_Program__c sp = spMap.get(opp.Sales_Program__c);
                updateSalesProgram(sp, opp, -1);
                uow.registerDirty(sp);
                toCommit = true;
            }
            
            if(toCommit){
                uow.commitWork();
            }
        } 
    }
    
    private static void updateSalesProgram(Sales_Program__c sp, Opportunity opp, Integer count){
        sp.Total_Potential__c = sp.Total_Potential__c - (opp.Amount == null ? 0 : opp.Amount);
        sp.TPAP__c = sp.TPAP__c - (opp.Total_Project_Awarded_Price__c == null ? 0 : opp.Total_Project_Awarded_Price__c);
        if(opp.StageName == CON_CRM.CLOSED_WON_STAGE){
            sp.Total_Won__c = sp.Total_Won__c + count;
        }else if(opp.StageName == CON_CRM.CLOSED_LOST_STAGE){
            sp.Total_Lost__c = sp.Total_Lost__c + count;
        }
    }
}