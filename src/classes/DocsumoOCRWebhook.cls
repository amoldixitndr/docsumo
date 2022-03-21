@RestResource(urlmapping='/response')
global without sharing class DocsumoOCRWebhook {
    @HTTPPost
    global static void processPOST() {
        System.debug('DNC Request: ' + RestContext.request.requestBody);
        ManageOCRService.processWebhook(RestContext.request.requestBody.toString());
    }
}