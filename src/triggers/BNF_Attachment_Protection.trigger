//  Trigger to prevent attachments from being added/edited/deleted from BNF's which
//  have been submitted for approval or have already been approved.
trigger BNF_Attachment_Protection on Attachment (before update, before delete) 
{
     if((Mulesoft_Integration_Control__c.getInstance().Is_Mulesoft_User__c || !Mulesoft_Integration_Control__c.getInstance().Ignore_Validation_Rules__c)){ 
        Map <Id,Id> Parent_Id_Map = new Map<Id,Id>();
        String ErrorMessage;
        if (Trigger.isDelete)
        {
            for (Attachment A:Trigger.old)
            {
                if(A.ParentId.getSObjectType().getDescribe().getName()=='BNF2__c' ||A.ParentId.getSObjectType().getDescribe().getName()=='MIBNF_Component__c' )
                {
                Parent_Id_Map.put(A.ParentId, A.ParentId);
                }
            }
        }
        else
        {
            for (Attachment A:Trigger.new)
            {
                if(A.ParentId.getSObjectType().getDescribe().getName()=='BNF2__c' ||A.ParentId.getSObjectType().getDescribe().getName()=='MIBNF_Component__c' )
                {
                Parent_Id_Map.put(A.ParentId, A.ParentId);
                }
            }
        }
        //Map <Id,BNF2__c> Parent_Map = new Map<Id,BNF2__c>([select Id, BNF_Status__c from BNF2__c where Id in :Parent_Id_Map.keySet()]); 
        Map <Id,sObject> Parent_Map = new Map<Id,sObject>();
        for(BNF2__c bnfObj : [select Id, BNF_Status__c from BNF2__c where Id in :Parent_Id_Map.keySet()]){
            Parent_Map.put(bnfObj.Id, bnfObj);
        }
        
        for(MIBNF_Component__c bnfObj : [select Id, BNF_Status__c from MIBNF_Component__c where Id in :Parent_Id_Map.keySet()]){
            Parent_Map.put(bnfObj.Id, bnfObj);
        }
        
        Map<Id,Id> ProcessInstanceWorkitem_Map = new Map<Id,Id>();
        for (ProcessInstanceWorkitem  P:[select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem  where ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId in :Parent_Id_Map.keySet()])
        {
            ProcessInstanceWorkitem_Map.put(P.ProcessInstance.TargetObjectId,P.Id);
        }
        if (Trigger.isUpdate)
        {    
            Map<String, BNF_Attachment_Type__c> docTypeMap = BNF_Attachment_Type__c.getAll();
            Set<String> filePrefixSet = docTypeMap.keySet();
            for (Attachment A:Trigger.New)
            {
                if (Parent_Map.containsKey(A.ParentId) && !BNF_Approval_Extension.BnfAttachmentCheckOverride && (A.ParentId.getSObjectType().getDescribe().getName()=='BNF2__c' ||A.ParentId.getSObjectType().getDescribe().getName()=='MIBNF_Component__c' ))
                {            
                    if (Parent_Map.get(A.ParentId).get('BNF_Status__c') == 'Accepted' || 
                        Parent_Map.get(A.ParentId).get('BNF_Status__c') == 'SAP Contract Confirmed' ||
                        ProcessInstanceWorkitem_Map.containsKey(A.ParentId))
                    {                    
                        ErrorMessage = 'Attachments cannot be edited when the BNF is accepted or is being approved.';
                        A.addError(ErrorMessage);                      
                    }
                    else if (Pattern.matches('bnf_[0-9]*_accepted_by_[^(\\.pdf)]*\\.pdf',Trigger.oldMap.get(A.Id).Name.toLowerCase()))
                    {
                        ErrorMessage = 'BNF PDF snapshot files cannot be modified';
                        A.addError(ErrorMessage);
                    }                
                }
                
                //BNF File Attachment Functionality - Do not allow removal of special prefix in file name
                //Sam Duncan    2012-09-17     
                for (String S:filePrefixSet)
                {
                    if (Trigger.oldMap.get(a.Id).name.toUpperCase().contains(S.toUpperCase()) && 
                        !a.name.toUpperCase().contains(S.toUpperCase()) && (A.ParentId.getSObjectType().getDescribe().getName()=='BNF2__c' ||A.ParentId.getSObjectType().getDescribe().getName()=='MIBNF_Component__c' ))
                    {
                        a.addError('BNF attachment type prefix cannot be modified. You can modify the filename after the \' '+ S.toUpperCase() + '\' prefix.');
                    }
                }
                //END - BNF File Attachment Functionality - Do not allow removal of special prefix in file name
            }
        }
        else if (Trigger.isDelete)
        {
            for (Attachment A:Trigger.old)
            {
                if (Parent_Map.containsKey(A.ParentId) && (A.ParentId.getSObjectType().getDescribe().getName()=='BNF2__c' ||A.ParentId.getSObjectType().getDescribe().getName()=='MIBNF_Component__c' ))
                {   
                    // // Updated  by  -- Issue-10609 -- 29 march 2017         
                    if (Parent_Map.get(A.ParentId).get('BNF_Status__c') == 'Accepted' || 
                        Parent_Map.get(A.ParentId).get('BNF_Status__c') == 'SAP Contract Confirmed' ||
                        ProcessInstanceWorkitem_Map.containsKey(A.ParentId))
                    {
                        A.addError('Attachments cannot be deleted from an accepted BNF or when the BNF is being approved.');
                    }
                    else if (Pattern.matches('bnf_[0-9]*_accepted_by_[^(\\.pdf)]*\\.pdf',A.Name.toLowerCase()))
                    {
                        ErrorMessage = 'BNF PDF snapshot files cannot be deleted';
                        A.addError(ErrorMessage);
                    }
                }
            }       
        }
    }
}