@isTest
private class ProjectCalloutServiceTest {
  //Implement mock callout tests here

  @TestSetup
  static void setup(){
    ServiceTokens__c token = new ServiceTokens__c();
    token.Name = ProjectCalloutService.PROJECT_TOKEN_NAME;
    token.Token__c = 'tokentesting';
    insert token;
    
    Account acc = new Account();
    acc.Name = 'Test Account';
    insert acc;

    Opportunity opp = new Opportunity();
    opp.AccountId = acc.Id;
    opp.Name = 'Test Opportunity';
    opp.Type = 'New Project';
    opp.CloseDate = Date.today();
    opp.StageName = 'Prospecting';
    opp.Amount = 100000;
    insert opp;
  }

  @isTest 
  static void testProjectCalloutNegative(){
    List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'];
    List<Id> opportunityIds = new List<Id>();
    opportunityIds.add(oppList[0].Id);

    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
    Test.startTest();
      ProjectCalloutService.postOpportunityToPMS(opportunityIds);
    Test.stopTest();

    oppList = [SELECT StageName FROM Opportunity WHERE Name = 'Test Opportunity'];
    System.assertEquals('Resubmit Project', oppList[0].StageName);
  }

  @isTest 
  static void testProjectCalloutPositive(){
    List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'];
    List<Id> opportunityIds = new List<Id>();
    opportunityIds.add(oppList[0].Id);

    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
    Test.startTest();
      ProjectCalloutService.postOpportunityToPMS(opportunityIds);
    Test.stopTest();

    oppList = [SELECT StageName FROM Opportunity WHERE Name = 'Test Opportunity'];
    System.assertEquals('Submitted Project', oppList[0].StageName);
  }
}