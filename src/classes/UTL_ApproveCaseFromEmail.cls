global class UTL_ApproveCaseFromEmail implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String plainId = email.plainTextBody;
        Integer result1 = plainId.indexOf(CON_CSM_OneKey.S_NUMBER);
        String caseNumber = plainId.substring(result1+8, result1+16);
        Case newCase = New Case();
        SLT_Case sltCase = new SLT_Case();
        List<case> listOfCase = sltCase.getCaseByCaseNumber(caseNumber);
        if(!listOfCase.isEmpty()) {
            newCase = listOfCase[0];
        }
        String rplyText = plainId.substring(0,50).toUpperCase();
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        if(newCase.status== CON_CSM_OneKey.S_REQUEST_FOR_APPROVAL && 
           (rplyText.contains(CON_CSM_OneKey.S_APPROVE) || rplyText.contains(CON_CSM_OneKey.S_YES) || rplyText.contains(CON_CSM_OneKey.S_APPROVED)))
            req.setAction(CON_CSM_OneKey.S_APPROVE_PROCESS);
        else if(newCase.status== CON_CSM_OneKey.S_REQUEST_FOR_APPROVAL && 
                (rplyText.contains(CON_CSM_OneKey.S_REJECT) || rplyText.contains(CON_CSM_OneKey.S_NO) || rplyText.contains(CON_CSM_OneKey.S_REJECTED))) 
            req.setAction(CON_CSM_OneKey.S_REJECT_PROCESS);
        SLT_ProcessInstanceWorkitem sltProcessInstance = new SLT_ProcessInstanceWorkitem();
        ProcessInstanceWorkitem pItem = new ProcessInstanceWorkitem();
        list<ProcessInstanceWorkitem> listOfPorceessWokItem = sltProcessInstance.getProcessInstanceWorkitemByTargetId(new Set<Id>{newCase.id});
        if(!listOfPorceessWokItem.isEmpty())
        {
            pItem = listOfPorceessWokItem[0];
            req.setWorkitemId(pItem.Id);
            Approval.ProcessResult resultforApproval = Approval.process(req);
            result.success = true;
        }
        return result;
    }
}