trigger MIBNF_Component_Update_RA_User on MIBNF_Component__c (before insert, before update)
{
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        Set<Id> MIBNF_Id_Set = new Set<Id>();
        Map<Id,String> RA_Id_Map = new Map<Id,String>();
        
        for (MIBNF_Component__c BNF : Trigger.new)
        {
            BNF.RA_User__c = BNF.Revenue_Analyst__c;
            MIBNF_Id_Set.add(BNF.MIBNF__c);
            RA_Id_Map.put(BNF.Comp_Revenue_Analyst__c,BNF.Comp_Revenue_Analyst__c);
        }
        
        Map<Id,MIBNF2__c> MIBNF_Map = new Map<Id,MIBNF2__c>([select Id,SAP_Master_Contract__c,Revenue_Analyst__c,Revenue_Analyst__r.User__r.Id,Opportunity__c from MIBNF2__c where Id in :MIBNF_Id_Set]);
        // updated by dheeraj kumar 21 april 2017
        Map<Id,Revenue_Analyst__c> RA_Map = new Map<Id,Revenue_Analyst__c>([select Id,Name,User__c,user__r.email, Revenue_Analyst_Email__c, User_2__c,User_3__c, User_4__c, User_5__c, User_6__c, User_7__c, 
                                                                            User_8__c, User_9__c, User_10__c,User__r.isactive, User_2__r.isactive, User_3__r.isactive,
                                                                            User_4__r.isactive, User_5__r.isactive, User_6__r.isactive, User_7__r.isactive,User_8__r.isactive, User_9__r.isactive,
                                                                            User_10__r.isactive, owner.type from Revenue_Analyst__c where Id in :RA_Id_Map.keySet()]);
        for (MIBNF_Component__c BNF : Trigger.new)
        {
            if (BNF.SAP_Master_Contract__c == null && MIBNF_Map.get(BNF.MIBNF__c).SAP_Master_Contract__c != null)
            {
                BNF.SAP_Master_Contract__c = MIBNF_Map.get(BNF.MIBNF__c).SAP_Master_Contract__c;
            }
            
            if (BNF.Comp_Revenue_Analyst__c==null || BNF.Comp_Revenue_Analyst__c!=MIBNF_Map.get(BNF.MIBNF__c).Revenue_Analyst__c && BNF.BNF_Status__c=='New')
            {
                BNF.Comp_Revenue_Analyst_user__c =MIBNF_Map.get(BNF.MIBNF__c).Revenue_Analyst__r.User__r.Id;
                BNF.Comp_Revenue_Analyst__c =MIBNF_Map.get(BNF.MIBNF__c).Revenue_Analyst__c;           
            }
            
            if(BNF.First_RA_Email__c==null && BNF.BNF_Status__c==MDM_Defines.BnfStatus_Map.get('SUBMITTED') && RA_Map.containsKey(BNF.Comp_Revenue_Analyst__c))
            {
                //BNF.First_RA_Email__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__r.email;
                BNF.First_RA_Email__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).Revenue_Analyst_Email__c;
            }
            
            if (RA_Map.containsKey(BNF.Comp_Revenue_Analyst__c) == true)
            {
                //BNF.Comp_Revenue_Analyst_user__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__c;
                // Update Revenue analyst email on IBNF
                //  commented by dheeraj kumar 21 april 2017
                // BNF.Current_RA_Email__C = RA_Map.get(BNF.Comp_Revenue_Analyst__c).Revenue_Analyst_Email__c;
                //Find at least one active user out of ten users on related revenue analyst records
                
                
                // updated by dheeraj kumar 12 April 2017
                
                if(Trigger.isUpdate) {
                    if( BNF.BNF_Status__c != Trigger.oldMap.get(BNF.id).BNF_Status__c && BNF.BNF_Status__c == MDM_Defines.BnfStatus_Map.get('SUBMITTED')) {
                        if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).owner.type == 'Queue') {
                            BNF.Current_RA_Email__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).Revenue_Analyst_Email__c;
                            
                        } else if (RA_Map.get(BNF.Comp_Revenue_Analyst__c).owner.type != 'Queue') {
                            BNF.Current_RA_Email__c = null;
                        }                   
                    } else {
                        BNF.Current_RA_Email__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).Revenue_Analyst_Email__c;
                    }               
                }   
                
                String Temp_RA_User;
                IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_2__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_2__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_2__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_3__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_3__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_3__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_4__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_4__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_4__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_5__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_5__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_5__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_6__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_6__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_6__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_7__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_7__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_7__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_8__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_8__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_8__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_9__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_9__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_9__c;
                else if(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_10__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_10__r.isactive)
                    Temp_RA_User = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_10__c;
                
                else
                    System.Debug('No Active user found for BNF');
                
                IF(Temp_RA_User !=null) {
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__r.Isactive )
                        BNF.Comp_Revenue_Analyst_user__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User__c;
                    else
                        BNF.Comp_Revenue_Analyst_user__c = Temp_RA_User;
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_2__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_2__r.Isactive )
                        BNF.Comp_Revenue_Analyst_user_2__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_2__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_2__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_3__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_3__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_3__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_3__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_3__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_4__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_4__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_4__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_4__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_4__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_5__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_5__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_5__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_5__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_5__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_6__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_6__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_6__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_6__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_6__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_7__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_7__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_7__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_7__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_7__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_8__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_8__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_8__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_8__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_8__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_9__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_9__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_9__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_9__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_9__c = Temp_RA_User;
                    
                    IF(RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_10__c !=null && RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_10__r.isactive)
                        BNF.Comp_Revenue_Analyst_user_10__c = RA_Map.get(BNF.Comp_Revenue_Analyst__c).User_10__c;
                    else
                        BNF.Comp_Revenue_Analyst_user_10__c = Temp_RA_User;
                }                                  
            } 
            
            BNF.Opportunity__c = MIBNF_Map.get(BNF.MIBNF__c).Opportunity__c;
        }  
    }  
}