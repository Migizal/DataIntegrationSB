public class ProjectCalloutService {
    public static Id opportunityId;
    public static final String PROJECT_TOKEN_NAME = 'ProjectServiceToken';
    //Complete the implementation for business and callout logic
    @InvocableMethod
	public static void postOpportunityToPMS(List<Id> opportunityIds){
        opportunityId = opportunityIds.get(0);
        Opportunity oppInfo = [SELECT Id, Name, account.Name, closeDate, amount 
                                FROM Opportunity WHERE Id = :opportunityId
                                ];
        Id jobId = System.enqueueJob(new QueueablePMSCall(oppInfo));   
    }

    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts
    {
        private String jsonOpp;
        private Opportunity opportunityObject;
        
        public QueueablePMSCall(Opportunity oppInfo)
        {
            opportunityObject = oppInfo;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();

            gen.writeStringField('opportunityId', oppInfo.Id);
            gen.writeStringField('opportunityName', oppInfo.Name);
            gen.writeStringField('accountName', oppInfo.Account.Name);
            gen.writeDateTimeField('closeDate', oppInfo.CloseDate);
            gen.writeNumberField('amount', oppInfo.Amount);

            gen.writeEndObject();

            jsonOpp = gen.getAsString();
            System.debug('jsonOpp:' + jsonOpp);
        }

        public void execute(QueueableContext context){
            ServiceTokens__c token = ServiceTokens__c.getValues('ProjectServiceToken');
            System.debug(token.Token__c);

            //Http Request Object
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:ProjectService/'+token.Token__c);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(jsonOpp);

            //Http Object
            Http http = new Http();
            HttpResponse response = http.send(request);
            if(response.getStatusCode() != 201){
                System.debug('Error from ' + request.getEndpoint() + ': ' +
                    response.getStatusCode() + ' ' + response.getStatus());

                Opportunity opportunityFailed = [SELECT Id, StageName FROM Opportunity WHERE Id = :opportunityObject.Id];
                opportunityFailed.StageName = 'Resubmit Project';
                update opportunityFailed;
            }
            else {
                Opportunity opportunityCreated = [SELECT Id, Stagename FROM Opportunity WHERE Id = :opportunityObject.Id];
                opportunityCreated.StageName = 'Submitted Project';
                update opportunityCreated;
            }
        }
    }
}