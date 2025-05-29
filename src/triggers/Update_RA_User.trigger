Trigger Update_RA_User on BNF2__c (before insert, before update)
{
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {  
        Map<Id,String> RA_Id_Map = new Map<Id,String>();
        for (BNF2__c BNF : Trigger.new)
        {
            RA_Id_Map.put(BNF.Revenue_Analyst__c,BNF.Revenue_Analyst__c);
        }
        Map<Id,Revenue_Analyst__c> RA_Map = new Map<Id,Revenue_Analyst__c>([select Id,Revenue_Analyst_Email__c,Name,User__c,User_2__c,User_3__c,User_4__c,User_5__c,User_6__c,User_7__c,User_8__c,User_9__c,User_10__c,
                                                                            User__r.isactive,User_2__r.isactive,User_3__r.isactive,User_4__r.isactive,User_5__r.isactive,User_6__r.isactive,
                                                                            User_7__r.isactive,User_8__r.isactive,User_9__r.isactive,User_10__r.isactive, owner.type from Revenue_Analyst__c where Id in :RA_Id_Map.keySet()]);
        
        // updated by dheeraj kumar 12 April 2017                                                           
        for (BNF2__c BNF : Trigger.new)
        {
            
            if (RA_Map.containsKey(BNF.Revenue_Analyst__c) == true)
            {
                // updated by dheeraj kumar 12 April 2017
                
                if(Trigger.isUpdate) {
                    if( BNF.BNF_Status__c != Trigger.oldMap.get(BNF.id).BNF_Status__c && BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED')) {
                        if(RA_Map.get(BNF.Revenue_Analyst__c).owner.type == 'Queue') {
                            BNF.Current_RA_Email__c = RA_Map.get(BNF.Revenue_Analyst__c).Revenue_Analyst_Email__c;
                            
                        } else if (RA_Map.get(BNF.Revenue_Analyst__c).owner.type != 'Queue') {
                            BNF.Current_RA_Email__c = null;
                        }	    			
                    } else {
                        BNF.Current_RA_Email__c = RA_Map.get(BNF.Revenue_Analyst__c).Revenue_Analyst_Email__c;
                    }        		
                }        	
                
                
                System.debug('BNF.Current_RA_Email__c----'+BNF.Current_RA_Email__c);
                // commented by dheeraj kumar 12 April 2017
                // Update Revenue analyst email on IBNF
                //BNF.Current_RA_Email__C = RA_Map.get(BNF.Revenue_Analyst__c).Revenue_Analyst_Email__c;
                //Find at least one active user out of ten users on related revenue analyst records
                String Temp_RA_User;
                IF(RA_Map.get(BNF.Revenue_Analyst__c).User__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_2__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_2__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_2__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_3__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_3__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_3__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_4__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_4__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_4__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_5__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_5__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_5__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_6__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_6__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_6__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_7__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_7__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_7__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_8__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_8__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_8__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_9__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_9__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_9__c;
                else if(RA_Map.get(BNF.Revenue_Analyst__c).User_10__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_10__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Revenue_Analyst__c).User_10__c;
                
                else
                    System.Debug('No Active user found for BNF');
                IF(Temp_RA_User !=null)
                {
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User__r.Isactive )
                        BNF.Revenue_Analyst_del__c = RA_Map.get(BNF.Revenue_Analyst__c).User__c;
                    else
                        BNF.Revenue_Analyst_del__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_2__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_2__r.Isactive )
                        BNF.Revenue_Analyst_User_2__c = RA_Map.get(BNF.Revenue_Analyst__c).User_2__c;
                    else
                        BNF.Revenue_Analyst_User_2__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_3__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_3__r.isactive)
                        BNF.Revenue_Analyst_User_3__c = RA_Map.get(BNF.Revenue_Analyst__c).User_3__c;
                    else
                        BNF.Revenue_Analyst_User_3__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_4__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_4__r.isactive)
                        BNF.Revenue_Analyst_User_4__c = RA_Map.get(BNF.Revenue_Analyst__c).User_4__c;
                    else
                        BNF.Revenue_Analyst_User_4__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_5__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_5__r.isactive)
                        BNF.Revenue_Analyst_User_5__c = RA_Map.get(BNF.Revenue_Analyst__c).User_5__c;
                    else
                        BNF.Revenue_Analyst_User_5__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_6__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_6__r.isactive)
                        BNF.Revenue_Analyst_User_6__c = RA_Map.get(BNF.Revenue_Analyst__c).User_6__c;
                    else
                        BNF.Revenue_Analyst_User_6__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_7__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_7__r.isactive)
                        BNF.Revenue_Analyst_User_7__c = RA_Map.get(BNF.Revenue_Analyst__c).User_7__c;
                    else
                        BNF.Revenue_Analyst_User_7__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_8__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_8__r.isactive)
                        BNF.Revenue_Analyst_User_8__c = RA_Map.get(BNF.Revenue_Analyst__c).User_8__c;
                    else
                        BNF.Revenue_Analyst_User_8__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_9__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_9__r.isactive)
                        BNF.Revenue_Analyst_User_9__c = RA_Map.get(BNF.Revenue_Analyst__c).User_9__c;
                    else
                        BNF.Revenue_Analyst_User_9__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Revenue_Analyst__c).User_10__c !=null && RA_Map.get(BNF.Revenue_Analyst__c).User_10__r.isactive)
                        BNF.Revenue_Analyst_User_10__c = RA_Map.get(BNF.Revenue_Analyst__c).User_10__c;
                    else
                        BNF.Revenue_Analyst_User_10__c = Temp_RA_User;
                }
            }        
            else
            {
                System.Debug('No user found for BNF');
            }
        }
    }
}