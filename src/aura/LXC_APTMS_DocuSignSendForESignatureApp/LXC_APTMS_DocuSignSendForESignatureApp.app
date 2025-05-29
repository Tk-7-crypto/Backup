<aura:application extends="force:slds">   
    <aura:attribute name="agreementId" type="String"/>
    <aura:attribute name="envelopeId" type="String"/>
    <c:LXC_APTMS_DocuSignSendForESignature agrId="{!v.agreementId}" envId="{!v.envelopeId}"/>	
</aura:application>