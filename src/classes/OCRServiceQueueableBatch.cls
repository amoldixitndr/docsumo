public without sharing class OCRServiceQueueableBatch implements Queueable, Database.AllowsCallouts{
    public static final String 	SEPARATION_KEY 	= '------NDRBoundary7MA4YWxkTrZu0gW';
    public static final Docsumo_API_Config__mdt configMetadata = [select API_Key__c, Endpoint_URL__c from Docsumo_API_Config__mdt limit 1 ];
    public Id attachmentId;
    public Id dOCRReq;

    public OCRServiceQueueableBatch(Id attachmentId, Id dOCRReq){
        this.attachmentId = attachmentId;
        this.dOCRReq = dOCRReq;
    }

    public void execute(QueueableContext context) {

            makeOCRRequest(this.attachmentId, this.dOCRReq, true);

    }

    public void makeOCRRequest(Id attachmentId, Id dOCRReq, Boolean recursion){
        //  Compose the http request
        HttpRequest httpRequest = new HttpRequest();
        System.debug('attachmentId:: ' + attachmentId + '::' + dOCRReq);
        Attachment attchmentObj = [select body,Name from Attachment where parentId =: attachmentId limit 1];
        httpRequest.setbody(''+SEPARATION_KEY+'\r\nContent-Disposition: form-data; name=\"file\"\r\n\r\n'+EncodingUtil.base64Encode(attchmentObj.body)+'\r\n'+SEPARATION_KEY+
        '\r\nContent-Disposition: form-data; name=\"filename\"\r\n\r\n'+attchmentObj.Name+'\r\n'+SEPARATION_KEY+
        //'\r\nContent-Disposition: form-data; name=\"type\"\r\n\r\nndr__lHKCN__TkClE__FcaEd\r\n'+SEPARATION_KEY+
        '\r\nContent-Disposition: form-data; name=\"type\"\r\n\r\nndr\r\n'+SEPARATION_KEY+
        '\r\nContent-Disposition: form-data; name=\"user_doc_id\"\r\n\r\n'+dOCRReq+'\r\n'+SEPARATION_KEY+
        '\r\nContent-Disposition: form-data; name=\"review_token\"\r\n\r\ntrue\r\n'+SEPARATION_KEY+
        '\r\nContent-Disposition: form-data; name=\"file_type\"\r\n\r\nbase64\r\n'+SEPARATION_KEY+'--');

        httpRequest.setEndpoint(configMetadata.Endpoint_URL__c);
        //httpRequest.setHeader('Content-Type','multipart/form-data; boundary=' + SEPARATION_KEY.substring(1, SEPARATION_KEY.length()-1));
        httpRequest.setHeader('Content-Type','multipart/form-data; boundary=----NDRBoundary7MA4YWxkTrZu0gW');
        httpRequest.setMethod('POST');
        httpRequest.setHeader('apikey',configMetadata.API_Key__c);
        httpRequest.setTimeout(120000);

        System.debug('Request==>' + httpRequest.getBody());

        Http h = new Http();
        HttpResponse hr = h.send(httpRequest);
        System.debug('Response==>' + hr.getBody());

        API_Log__c log = new API_Log__c();

        if(hr.getStatusCode() == 200){
            OCRResponse response = (OCRResponse )JSON.deserialize(hr.getBody(), OCRResponse.class);
            if(response.status != 'success'){
                log.Has_Errors__c = true;
                log.Errors__c = hr.getStatus()+ ' :: '+hr.getStatusCode();
            }
            try{
                update new Document_OCR_Request__c(id=dOCRReq, Review_URL__c = response.data.document[0].review_url + '&client=true&ext_user='+Userinfo.getUserId(), 
                Docsumo_Doc_Id__c = response.data.document[0].doc_id, Status__c = response.data.document[0].status, User_Id__c = response.data.document[0].user_id); 
            }catch(Exception e){
                log.Has_Errors__c = true;
                log.Errors__c = e.getMessage()+ ' :: '+e.getStackTraceString();
            }
        }else{

            log.Has_Errors__c = true;
            log.Errors__c = hr.getStatus()+ ' :: '+hr.getStatusCode();
        }

        log.Class_Name__c = 'OCRServiceQueueableBatch';
        log.Action__c = 'Docsumo upload';
        //log.Request_Body__c = JSON.serializePretty(JSON.deserializeUntyped(httpRequest.getBody()));
        try{
            if(hr.getBody().length() < 10000){
                log.Response_Body__c = JSON.serializePretty(JSON.deserializeUntyped(hr.getBody()));
            }else{
                log.Response_Body__c = JSON.serializePretty(JSON.deserializeUntyped(hr.getBody().substring(0, 1000)));
            }
        }catch(Exception e){
            if(hr.getBody().length() < 10000){
                log.Response_Body__c = hr.getBody();
            }else{
                log.Response_Body__c = hr.getBody().substring(0, 1000);
            }
        }

        log.Document_OCR_Request__c = dOCRReq;
        log.Request_Method__c = 'POST';
        log.Response_Status_Code__c = hr.getStatusCode();
        log.Request_URI__c = configMetadata.Endpoint_URL__c;

        if(recursion && hr.getStatusCode() != 200){
            makeOCRRequest(attachmentId, dOCRReq, false);
        }else{
            insert log;
        }

    }

    public class OCRResponse{
        public cls_data data;
        public String error;	//
        public String error_code;	//
        public String message;	//
        public String status;	//success
        public Integer status_code;	//200
    }
        class cls_data {
            public cls_document[] document;
        }
        class cls_document {
            public String created_at;	//Fri, 30 Jul 2021 19:03:14 GMT
            public String doc_id;	//6f2df3b751e646368d00cda63324c0da
            public String doc_meta_data;	//
            public String email;	//Amol.Dixit@NationalDebtRelief.com
            public String review_url;	//https://app.docsumo.com/review-document/6f2df3b751e646368d00cda63324c0da
            public String status;	//new
            public String title;	//!!HEATHER.pdf
            public String type;	//invoice
            public String user_doc_id;  
            public String user_id;	//6102ec04d44bcec4994b606a
        }
}