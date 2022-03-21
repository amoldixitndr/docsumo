@isTest	
public with sharing class ManageOCRServiceTest {
    static Attachment__c attHolder;
    static testMethod void test_getOCR_Positive(){

		Testfactory.createDSTestDataSet();
        attHolder = new Attachment__c(Deal__c = Testfactory.deal.Id);
        insert attHolder;
        insert new Attachment(Name = 'test', ParentId = attHolder.id, Body = Blob.valueOf(''));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DocsumoHttpInitialSubmitResponseGenerator());

        ManageOCRService.getOCR(attHolder.id);
        Test.stopTest();
        System.assertEquals(1, [select id from API_Log__c].size());
        System.debug('Errors ===> ' + [select Errors__c from API_Log__c].Errors__c);
        System.assertEquals(false, [select Has_Errors__c from API_Log__c].Has_Errors__c);
        
    }

    static testMethod void test_getOCR_Positive_v1(){

		Testfactory.createDSTestDataSet();
        attHolder = new Attachment__c(Deal__c = Testfactory.deal.Id);
        insert attHolder;
        insert new Attachment(Name = 'test', ParentId = attHolder.id, Body = Blob.valueOf(''));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DocsumoHttpInitialSubmitResponseGenerator());

        ManageOCRService.getOCR(new List<Attachment__c> {attHolder});
        Test.stopTest();
        System.assertEquals(1, [select id from API_Log__c].size());
        System.debug('Errors ===> ' + [select Errors__c from API_Log__c].Errors__c);
        System.assertEquals(false, [select Has_Errors__c from API_Log__c].Has_Errors__c);
        
    }

    static testMethod void test_getOCR_Negative(){

		Testfactory.createDSTestDataSet();
        attHolder = new Attachment__c(Deal__c = Testfactory.deal.Id);
        insert attHolder;
        insert new Attachment(Name = 'test', ParentId = attHolder.id, Body = Blob.valueOf(''));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DocsumoHttpResponseGeneratorError());

        ManageOCRService.getOCR(attHolder.id);
        Test.stopTest();
        System.assertEquals(1, [select id from API_Log__c].size());
        System.assertEquals(true, [select Has_Errors__c from API_Log__c].Has_Errors__c);
        
    }

    static testMethod void test_processwebhook_Positive(){

		Testfactory.createDSTestDataSet();
        attHolder = new Attachment__c(Deal__c = Testfactory.deal.Id);
        insert attHolder;
        insert new Attachment(Name = 'test', ParentId = attHolder.id, Body = Blob.valueOf(''));
        Test.setMock(HttpCalloutMock.class, new DocsumoHttpInitialSubmitResponseGenerator());
        ManageOCRService.getOCR(attHolder.id);
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        Document_OCR_Request__c dcr = [select id from Document_OCR_Request__c];
        request.requestBody = Blob.valueof('{"meta_data": {"title": "sample_ndr.pdf", "doc_id": "a3f2fc09423f43d8ade9d26b55445ddc", "type": "ndr__lHKCN__TkClE", "user_doc_id": "'+ dcr.id+'", "doc_meta_data": "", "folder_name": "", "created_at": "2021-08-11T18:23:08+00:00", "modified_at": "2021-08-11T18:23:58+00:00", "uploaded_from": "web", "review_url": "https://app.docsumo.com/review-document/a3f2fc09423f43d8ade9d26b55445ddc", "user_id": "6102ec04d44bcec4994b606a", "org_id": "60e68d3ab08a39185b5937a1", "status": "processed", "review_required": false}, "data": {"Basic Information": {"Customer Name": {"value": "", "position": [], "confidence": 0, "review_required": true}, "Current Balance": {"value": 5000.0, "position": [416, 761, 501, 792], "confidence": 0, "review_required": true}, "Settlement Amount": {"value": 1006.0, "position": [1280, 886, 1411, 917], "confidence": 0, "review_required": true}}, "Account Number": {"Original Account Number": {"value": "6879450", "position": [522, 536, 630, 567], "confidence": 0, "review_required": true}, "Reference Number": {"value": "6879450", "position": [522, 536, 630, 567], "confidence": 0, "review_required": true}, "DS ID Number": {"value": "", "position": [], "confidence": 0, "review_required": true}}, "Creditor": {"Original Creditor Name": {"value": "BANK", "position": [624, 667, 700, 698], "confidence": 0, "review_required": true}, "Current Creditor": {"value": "XYZ BANK", "position": [518, 633, 655, 664], "confidence": 0, "review_required": true}, "Collection Agency": {"value": "XYZ, LLC", "position": [721, 198, 902, 252], "confidence": 0, "review_required": true}}, "Payment Detail": {"First Payment Due Date": {"value": "10/31/2019", "position": [], "confidence": 0.84, "review_required": false}, "Final Payment Due Date": {"value": "03/31/2021", "position": [], "confidence": 0.86, "review_required": false}, "Total Payments Term": {"value": "18", "position": [], "confidence": 0, "review_required": false}}, "Payment Table": [{"Date": {"value": "", "position": "", "confidence": 0, "review_required": true}, "Amount": {"value": "", "position": "", "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": "", "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": "", "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": "", "confidence": 0, "review_required": true}}, {"Date": {"value": "10/31/2019", "position": [543, 2500, 1105, 2531], "confidence": 0, "review_required": true}, "Amount": {"value": 10.0, "position": [543, 2500, 1105, 2531], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "11/30/2019", "position": [543, 2533, 1105, 2564], "confidence": 0, "review_required": true}, "Amount": {"value": 10.0, "position": [543, 2533, 1105, 2564], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "12/31/2019", "position": [543, 2566, 1105, 2597], "confidence": 0, "review_required": true}, "Amount": {"value": 10.0, "position": [543, 2566, 1105, 2597], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "01/31/2020", "position": [551, 2600, 1105, 2631], "confidence": 0, "review_required": true}, "Amount": {"value": 10.0, "position": [551, 2600, 1105, 2631], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "02/29/2020", "position": [551, 2633, 1105, 2664], "confidence": 0, "review_required": true}, "Amount": {"value": 10.0, "position": [551, 2633, 1105, 2664], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "03/31/2020", "position": [551, 2666, 1105, 2697], "confidence": 0, "review_required": true}, "Amount": {"value": 10.0, "position": [551, 2666, 1105, 2697], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "04/30/2020", "position": [551, 2699, 1105, 2731], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 2699, 1105, 2731], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "05/31/2020", "position": [551, 2733, 1105, 2764], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 2733, 1105, 2764], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "06/30/2020", "position": [551, 2766, 1105, 2797], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 2766, 1105, 2797], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "07/31/2020", "position": [551, 2799, 1105, 2831], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 2799, 1105, 2831], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "08/31/2020", "position": [551, 2833, 1105, 2864], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 2833, 1105, 2864], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "09/30/2020", "position": [551, 2866, 1105, 2897], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 2866, 1105, 2897], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "10/31/2020", "position": [543, 2899, 1105, 2931], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [543, 2899, 1105, 2931], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "11/30/2020", "position": [543, 2933, 1105, 2964], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [543, 2933, 1105, 2964], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "12/31/2020", "position": [543, 2966, 1105, 2997], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [543, 2966, 1105, 2997], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "01/31/2021", "position": [551, 2999, 1105, 3031], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 2999, 1105, 3031], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "02/28/2021", "position": [551, 3033, 1105, 3064], "confidence": 0, "review_required": true}, "Amount": {"value": 81.0, "position": [551, 3033, 1105, 3064], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}, {"Date": {"value": "03/31/2021", "position": [551, 3066, 1105, 3097], "confidence": 0, "review_required": true}, "Amount": {"value": 85.0, "position": [551, 3066, 1105, 3097], "confidence": 0, "review_required": true}, "No of Terms": {"value": "", "position": [], "confidence": 0, "review_required": true}, "From Date": {"value": "", "position": [], "confidence": 0, "review_required": true}, "To Date": {"value": "", "position": [], "confidence": 0, "review_required": true}}]}, "error": "", "error_code": "", "message": "", "status": "success", "status_code": 200, "event": "doc_status_change"}');
        request.requestUri = '/services/apexrest/response';
        request.httpMethod = 'POST';
        RestContext.request = request;

        DocsumoOCRWebhook.processPOST();
        Test.stopTest();
        System.assertEquals('new', [select Status__c from Document_OCR_Request__c where id =:dcr.id].Status__c);
        
    }

    static testMethod void test_processwebhook_Negative(){

		Testfactory.createDSTestDataSet();
        attHolder = new Attachment__c(Deal__c = Testfactory.deal.Id);
        insert attHolder;
        insert new Attachment(Name = 'test', ParentId = attHolder.id, Body = Blob.valueOf(''));
        RestResponse res = new RestResponse();             
        ManageOCRService.getOCR(attHolder.id);

        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueof('{"meta_data":{"title":"Screenshot_1.png","approved_with_error":false, "doc_id":"5175509c07704201aaf501cd162fda1c","type":"others__OQNyj__wayop","user_doc_id":"'+[select id from Document_OCR_Request__c].id+'","doc_meta_data":"","folder_name":"","created_at":"2021-08-04T13:05:46+00:00","modified_at":"2021-08-04T13:05:46+00:00","uploaded_from":"web","review_url":"https://app.docsumo.com/review-document/5175509c07704201aaf501cd162fda1c","user_id":"60cad7a4e0c444386afaadb7","org_id":"60cad7a4e0c444386afaadb7","status":"erred","err_message":"no text in image"},"data":{},"error":"","error_code":"","message":"","status":"success","status_code":200,"event":"doc_status_change"}');
        request.requestUri = '/services/apexrest/response';
        request.httpMethod = 'POST';
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new DocsumoHttpResponseGeneratorError());
        ManageOCRService.getOCR(attHolder.id);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DocsumoHttpResponseGeneratorError());

        DocsumoOCRWebhook.processPOST();
        Test.stopTest();
        System.assertNotEquals('processed', [select Status__c from Document_OCR_Request__c limit 1].Status__c);

    }

    public class DocsumoHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
                System.assertEquals('POST', req.getMethod());
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"data":{"Account Number":{"Current Account Number":{"confidence":0,"position":[485,3038,714,3066],"review_required":true,"value":"XXXXXXXXXXXX7876"},"Customer Number":{"confidence":0,"position":[],"review_required":true,"value":""},"Original Account Number":{"confidence":0,"position":[485,3038,714,3066],"review_required":true,"value":""},"Reference Number":{"confidence":0,"position":[536,3072,646,3100],"review_required":true,"value":"040768354"}},"Basic Information":{"Current Balance":{"confidence":0,"position":[651,3104,749,3133],"review_required":true,"value":1091.5},"Customer Name":{"confidence":0,"position":[176,2808,438,2834],"review_required":true,"value":"NATIONAL DEBT RELIEF"},"Settlement Amount":{"confidence":0,"position":[560,3294,639,3330],"review_required":true,"value":873.2}},"Creditor":{"Collection Agency":{"confidence":0,"position":[670,3871,1050,3904],"review_required":true,"value":"Weltman, Weinberg & Reis Co., L.P.A"},"Current Creditor":{"confidence":0,"position":[480,3006,663,3033],"review_required":true,"value":"DISCOVER BANK"},"Original Creditor Name":{"confidence":0,"position":[],"review_required":true,"value":""}},"Payment Detail":{"Final Payment Due Date":{"confidence":0,"position":[595,3329,685,3362],"review_required":true,"value":"06/25/2021"},"First Payment Due Date":{"confidence":0,"position":[814,3294,1012,3330],"review_required":true,"value":"10/23/1989"},"Total Payments Term":{"confidence":0,"position":[],"review_required":true,"value":""}},"Payment Table":[{"Amount":{"confidence":0,"position":"","review_required":true,"value":""},"Date":{"confidence":0,"position":"","review_required":true,"value":""},"From Date":{"confidence":0,"position":"","review_required":true,"value":""},"No of Terms":{"confidence":0,"position":"","review_required":true,"value":""},"To Date":{"confidence":0,"position":"","review_required":true,"value":""}}]},"error":"","error_code":"","message":"","meta_data":{"created_at":"Thu, 15 Jul 2021 11:54:44 GMT","doc_id":"80f19a5844784200baf993a4dd83cf00","doc_meta_data":"","folder_name":"","modified_at":"Thu, 15 Jul 2021 11:55:35 GMT","review_required":true,"review_url":"https://app.docsumo.com/review-document/80f19a5844784200baf993a4dd83cf00","status":"reviewing","title":"Weltman (5).pdf","type":"ndr","uploaded_from":"web","user_doc_id":"'+ [select id from Document_OCR_Request__c].id+'","user_id":"60e68da3540517d71dcb0cfd"},"status":"success","status_code":200}');
                res.setStatusCode(200);
                return res;
        }
    }

    public class DocsumoHttpInitialSubmitResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
                System.assertEquals('POST', req.getMethod());
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"data":{"document":[{"created_at":"Wed, 11 Aug 2021 18:02:03 GMT","doc_id":"e90adba99fce4cf6947cf106f6054ce4","doc_meta_data":"","email":"Amol.Dixit@NationalDebtRelief.com","review_url":"https://app.docsumo.com/review-document/e90adba99fce4cf6947cf106f6054ce4/?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiNjEwMmVjMDRkNDRiY2VjNDk5NGI2MDZhIiwiaWF0IjoxNjI4NzA0OTIzLCJleHAiOjE2Mjg5NjQxMjMsIm9yZ19pZCI6IjYwZTY4ZDNhYjA4YTM5MTg1YjU5MzdhMSIsInJvbGUiOiJ0ZW1wX3Rva2VuIiwiZG9jX2lkIjoiZTkwYWRiYTk5ZmNlNGNmNjk0N2NmMTA2ZjYwNTRjZTQifQ.E2oh6vxInso1gZ31zSjT9TjoybItrW3UCV6xeKUBAdw","status":"new","title":"sample_ndr.pdf","type":"ndr__lHKCN__TkClE","user_doc_id":"'+ [select id from Document_OCR_Request__c].id+'","user_id":"6102ec04d44bcec4994b606a"}]},"error":"","error_code":"","message":"","status":"success","status_code":200}');
                res.setStatusCode(200);
                return res;
        }
    }

    public class DocsumoHttpResponseGeneratorError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
                System.assertEquals('POST', req.getMethod());
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');

                res.setBody('{"meta_data":{"title":"Screenshot_1.png","doc_id":"5175509c07704201aaf501cd162fda1c","type":"others__OQNyj__wayop","user_doc_id":"'+ [select id from Document_OCR_Request__c limit 1].id+'","doc_meta_data":"","folder_name":"","created_at":"2021-08-04T13:05:46+00:00","modified_at":"2021-08-04T13:05:46+00:00","uploaded_from":"web","review_url":"https://app.docsumo.com/review-document/5175509c07704201aaf501cd162fda1c","user_id":"60cad7a4e0c444386afaadb7","org_id":"60cad7a4e0c444386afaadb7","status":"erred","err_message":"no text in image"},"data":{},"error":"","error_code":"","message":"","status":"success","status_code":200,"event":"doc_status_change"}');
                res.setStatusCode(200);
                return res;
        }
    }

}