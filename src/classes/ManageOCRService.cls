global without sharing class ManageOCRService {


    @InvocableMethod(label='Document OCR Request' description='Document OCR Request' category='Document_OCR_Request__c')
    global static void getOCR(List<Attachment__c> attchmentList){

        Document_OCR_Request__c dOCRReq = new Document_OCR_Request__c(Attachment__c = attchmentList[0].id, Attachment_Std__c = [select Id from Attachment where parentId =: attchmentList[0].id limit 1].id);
        insert dOCRReq;

        OCRServiceQueueableBatch updateJob = new OCRServiceQueueableBatch(attchmentList[0].id, dOCRReq.id);
        ID jobID = System.enqueueJob(updateJob);

    }

    public static void getOCR(Id attchmentId){

        Document_OCR_Request__c dOCRReq = new Document_OCR_Request__c(Attachment__c = attchmentId, Attachment_Std__c = [select Id from Attachment where parentId =: attchmentId limit 1].id);
        insert dOCRReq;

        OCRServiceQueueableBatch updateJob = new OCRServiceQueueableBatch(attchmentId, dOCRReq.id);
        ID jobID = System.enqueueJob(updateJob);

    }
    
    public static void processWebhook(String jsonResponse){
        String responseBody;
        Integer responseCode;
        System.debug('jsonResponse==>' + jsonResponse);
        Document_OCR_Request__c sOCRReq = new Document_OCR_Request__c();

        try{
        Map<String, Object> jsonParseSource = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        sOCRReq.Id = (String)((Map<String, Object>)jsonParseSource.get('meta_data')).get('user_doc_id');
        List<Document_OCR_Request_PS_Row__c> dOCRPSRowList = new List<Document_OCR_Request_PS_Row__c>();
        if(sOCRReq.Id  != null){
            List<Docsumo_Response_Field_Mapping__mdt> mappingList = [select Data_Type__c, Field_API_Name__c, Field_Label__c, Header__c from Docsumo_Response_Field_Mapping__mdt];
            for(Docsumo_Response_Field_Mapping__mdt fmapping : mappingList){
                if (fmapping.Data_Type__c == 'Table'){
                    List<Object> paymentRowList = (List<Object>)((Map<String, Object>)jsonParseSource.get('data')).get(fmapping.Header__c);

                    sOCRReq.put(fmapping.Field_API_Name__c, (Json.serializePretty(((Map<String, Object>)jsonParseSource.get('data')).get(fmapping.Header__c))));
                    //Map<String, Object> dataTableMap = ((Map<String, Object>)(headerMap1).get(fmapping.Field_Label__c));//((Map<String, Object>)jsonParseSource.get('data')).get(fmapping.Header__c);
                    if(paymentRowList != null){
                        for(Object pr : paymentRowList){
                            Map<String, Object> paymentRow = (Map<String, Object>)pr; 
                            Document_OCR_Request_PS_Row__c psRow = new Document_OCR_Request_PS_Row__c();
                            Map<String, Object> paymentDateRow = (Map<String, Object>) paymentRow.get('Date');
                            if(paymentDateRow != null && paymentDateRow.get('value') != null && paymentDateRow.get('value') != ''){
                                psRow.Payment_Due_Date__c =  date.parse((String)paymentDateRow.get('value'));
                            }
                            Map<String, Object> amountRow = (Map<String, Object>) paymentRow.get('Amount');
                            if(amountRow != null && amountRow.get('value') != null && amountRow.get('value') != ''){
                                psRow.Payment_Amount__c =  (decimal)amountRow.get('value');
                            }
                            system.debug('paymentDateRow===>' + paymentDateRow);
                            system.debug('amountRow===>' + amountRow);
                            psRow.Document_OCR_Request__c = sOCRReq.Id;
                            if(psRow.Payment_Due_Date__c != null && psRow.Payment_Amount__c != null){
                                dOCRPSRowList.add(psRow);

                            }
                        }
                    }
                    continue;
                }
                Map<String, Object> headerMap = (Map<String, Object>)((Map<String, Object>)jsonParseSource.get('data')).get(fmapping.Header__c);
                if(headerMap != null){
                    System.debug('fmapping==>' + fmapping + '::' + headerMap);
                    if(fmapping.Data_Type__c == 'Text'){
                        String strValue = (String)((Map<String, Object>)(headerMap).get(fmapping.Field_Label__c)).get('value');
                        if(strValue != null && strValue != ''){
                            sOCRReq.put(fmapping.Field_API_Name__c, strValue);
                        }
                    }else if(fmapping.Data_Type__c == 'Date'){
                        String strValue = (String)((Map<String, Object>)(headerMap).get(fmapping.Field_Label__c)).get('value');
                        if(strValue != null && strValue != ''){
                            sOCRReq.put(fmapping.Field_API_Name__c, date.parse(strValue));
                        }
                    }else if(fmapping.Data_Type__c == 'Currency' || fmapping.Data_Type__c == 'Number'){
                        String decimalValue = (String.valueOf(((Map<String, Object>)(headerMap).get(fmapping.Field_Label__c)).get('value')));

                        if(decimalValue != null && decimalValue != ''){
                            sOCRReq.put(fmapping.Field_API_Name__c, Decimal.valueOf(decimalValue.replace('$','').removeEnd('.').replace(',','')));
                        }
                    }else if(fmapping.Data_Type__c == 'Boolean'){
                        Boolean strValue = (Boolean)((Map<String, Object>)(headerMap).get(fmapping.Field_Label__c)).get('value');
                        if(strValue != null){
                            sOCRReq.put(fmapping.Field_API_Name__c, strValue);
                        }
                    }

                }
        }

            sOCRReq.Status__c = (String)((Map<String, Object>)jsonParseSource.get('meta_data')).get('status');
            sOCRReq.Manual_Review_Completed_By_User__c = (String)((Map<String, Object>)jsonParseSource.get('meta_data')).get('ext_user');
            sOCRReq.Approved_with_Error__c = (Boolean)((Map<String, Object>)jsonParseSource.get('meta_data')).get('approved_with_error');
            sOCRReq.Error_Message__c = (String)((Map<String, Object>)jsonParseSource.get('meta_data')).get('err_message');
            sOCRReq.Docsumo_Doc_Id__c = (String)((Map<String, Object>)jsonParseSource.get('meta_data')).get('doc_id');
            System.debug('sOCRReq===>' + sOCRReq + ':: dOCRPSRowList :: ' + dOCRPSRowList);
            delete [select id from Document_OCR_Request_PS_Row__c where Document_OCR_Request__c =: sOCRReq.Id];
            insert dOCRPSRowList;
            update sOCRReq;
            responseBody = '{"Success" : true}';
            responseCode = 200;

        }else{
            // If success, return the response code end error.
            responseBody = '{"Success" : false, "Error" : "Document id not found"}';
            responseCode = 400;
            
        }
   }catch(Exception e){
        // If success, return the response code end error.
        responseBody = '{"Success" : false, "Error" : "'+ e.getMessage()+ ' :: ' + e.getStackTraceString() +'"}';
        responseCode = 400;
    }
    
    System.debug('responseBody==>'+ responseBody);
    if(RestContext.response != null && responseBody != null){
        RestContext.response.responseBody = Blob.valueOf(responseBody);
        insert new API_Log__c(Class_Name__c = 'ManageOCRService', Action__c = 'processWebhook', Request_Body__c = JSON.serializePretty(JSON.deserializeUntyped(jsonResponse)), Document_OCR_Request__c = sOCRReq.id, Request_Method__c = 'GET', Has_Errors__c = true, Errors__c = responseBody);
    }
    if(!Test.isrunningTest())
    RestContext.response.statusCode = 200;    



    }

}