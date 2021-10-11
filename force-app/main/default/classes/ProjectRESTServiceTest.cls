@isTest
private class ProjectRESTServiceTest {
  //Implement Apex REST service tests here

  @TestSetup
  static void setup(){
    Account acc = new Account();
    acc.Name = 'test account';
    insert acc;

    Opportunity opp = new Opportunity();
    opp.AccountId = acc.Id;
    opp.Name = 'test opportunity';
    opp.Amount = 100000;
    opp.CloseDate = Date.today();
    opp.Type = 'New Project';
    opp.StageName = 'Prspecting';
    insert opp; 
  }

  @isTest 
  static void testProjectRestServiceNegative(){

    RestRequest request = new RestRequest();
    request.httpMethod = 'POST';
    request.requestURI = '/services/apexrest/project';

    RestContext.request = request;

    Test.startTest();
    String response = ProjectRESTService.postProjectData(
      'Test ref 1', 
      'test proj name', 
      'test opp id', 
      Date.today(), 
      Date.today().addDays(3), 
      120000, 
      'Running');
    Test.stopTest();

    System.assertEquals('Invalid id: test opp id', response);
  }

  @isTest 
  static void testRestCalloutPositive(){
    RestRequest request = new RestRequest();
    request.httpMethod = 'POST';
    request.requestURI = '/services/apexrest/project';

    RestContext.request = request;

    Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'test opportunity'];

    Test.startTest();
    String response = ProjectRESTService.postProjectData(
      'Test ref 1', 
      'test proj name', 
      opp.Id, 
      Date.today(), 
      Date.today().addDays(3), 
      120000, 
      'Running');
    Test.stopTest();

    opp = [SELECT DeliveryInstallationStatus__c FROM Opportunity WHERE Id = :opp.Id];

    System.assertEquals('In progress', opp.DeliveryInstallationStatus__c);
    System.assertEquals('OK', response);
  }
}