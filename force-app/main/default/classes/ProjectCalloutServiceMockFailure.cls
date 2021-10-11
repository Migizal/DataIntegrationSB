global class ProjectCalloutServiceMockFailure implements HttpCalloutMock {
   //Implement http mock callout failure here
   global HttpResponse respond(HttpRequest request){
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(500);
      res.setStatus('Error');
      return res;
   } 
}