/**************************************************************************************************/
// This Trigger check MIBNF Comment field for Line Break.
// Created by : Himanshu Parashar
// Date : 19 oct 2011
/**************************************************************************************************/

trigger MIBNF_LineBreak on MIBNF2__c (before insert, before update) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_MIBNF_Trigger__c) {
        for (MIBNF2__c  cBNF : Trigger.new) {
            
            // checking only if the revenue comments is not equal to NULL
            if(cBNF.Comments__c<>NULL)
            {
                
                Integer LB = 0;
                Integer LastSpace = 0;
                String newComment = '';
                Integer enter = 0;
                String comment = cBNF.Comments__c; 
               
                for(Integer i= 0;i<comment.length();i++)
                {          
                    newComment = newComment+comment.substring(i,i+1);
                    LB = LB + 1;
                    
                    // checking if line break                   
                    if((comment.substring(i,i+1)=='\n')||(comment.substring(i,i+1)==' '))
                    {
                        LB = 0;
                        //LastSpace=0;
                    }
                    
                    // if 49 character without space then
                    if(LB==49)
                    {
                        newComment = newComment + ' ';
                        LB=0;
                        LastSpace=0;
                    }
                }
                cBNF.Comments__c = newComment;                 
            }
        }
    }
}