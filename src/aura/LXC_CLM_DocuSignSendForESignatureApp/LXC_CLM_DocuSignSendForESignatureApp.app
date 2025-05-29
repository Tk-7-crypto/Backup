<aura:application extends="force:slds">   
    <aura:attribute name="agreementId" type="String"/>
    <aura:attribute name="envelopeId" type="String"/>
    <c:LXC_CLM_DocuSignSendForESignature agrId="{!v.agreementId}" envId="{!v.envelopeId}"/>	
</aura:application>