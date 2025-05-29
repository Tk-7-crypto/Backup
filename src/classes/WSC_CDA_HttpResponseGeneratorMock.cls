/**
 * @author   : Sweta Sharma
 * Purpose   : ER-3556 Mock WebService class for docusign callouts in CDA.
 * 
 */
@isTest
global class WSC_CDA_HttpResponseGeneratorMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        if (req.getEndpoint().endsWith('/documents')){
            res.setBody('{"envelopeId": "682caf2b-73d5-4441-8e04-065451cb7667","envelopeDocuments" : [{ "documentId" :"123456","name": "Signed-on-PaperCDA-000133_Customer Mutual CDA Template_2017-05-24.pdf","type": "content",  "uri": "/envelopes/80825477-12B2-45A1-876E-B0A4D5FFEF89/documents/1","order": "1","pages": "2", "availableDocumentTypes": [  {"type": "electronic",   "isDefault": "true" }],      "display": "inline","includeInDownload": "true",  "signerMustAcknowledge": "no_interaction" }], "status": "OK"}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }else if (req.getEndpoint().endsWith('/documents/123456')){
            res.setBody('{"envelopeId": "682caf2b-73d5-4441-8e04-065451cb7667","envelopeDocuments" : [{ "documentId" :"123456","name": "Signed-on-PaperCDA-000133_Customer Mutual CDA Template_2017-05-24.pdf","type": "content",  "uri": "/envelopes/80825477-12B2-45A1-876E-B0A4D5FFEF89/documents/1","order": "1","pages": "2", "availableDocumentTypes": [  {"type": "electronic",   "isDefault": "true" }],      "display": "inline","includeInDownload": "true",  "signerMustAcknowledge": "no_interaction" }], "status": "OK"}');
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        else {
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String NS_SF = 'urn:partner.soap.sforce.com';
            dom.XmlNode envelope = doc.createRootElement('Envelope', null, null);
            dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
            dom.XmlNode faultElm = body.addChildElement('Fault', soapNS, null);
            dom.XmlNode loginResponseElm = body.addChildElement('loginResponse', NS_SF, null);
            dom.XmlNode resultElm = loginResponseElm.addChildElement('result', NS_SF, null);
            resultElm.addChildElement('sessionId', NS_SF, null);
            resultElm.addChildElement('serverUrl', NS_SF, null);
            res.setBody(doc.toXmlString());
            //res.setBody('<?xml version="1.0"?><Body xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Fault xmlns="http://schemas.xmlsoap.org/soap/envelope/"><faultstring>fault</faultstring></Fault><loginResponse><result><sessionId>test123</sessionId><serverUrl>/envelopes/80825477-12B2-45A1-876E-B0A4D5FFEF89/documents/1</serverUrl></result></loginResponse></Body>');
            res.setStatusCode(201);
        }
        return res;
    }
}