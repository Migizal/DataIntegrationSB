@isTest
private class BillingCalloutServiceTest {
  //Implement mock callout tests here

  @TestSetup
  static void createData(){
    
    Opportunity opp = new Opportunity();
    opp.Name = 'Test opp';
    opp.CloseDate = Date.today();
    opp.StageName = 'Prospecting';
    insert opp;

    Project__c proj = new project__c();
    proj.Name = 'Test Proj';
    proj.Billable_Amount__c = 100;
    proj.ProjectRef__c = 'TestRef';
    proj.Status__c = 'Running';
    proj.Opportunity__c =  opp.Id;
    insert proj;

    ServiceCredentials__c serviceCredentials = new serviceCredentials__c();
    serviceCredentials.Name = 'BillingServiceCredential';
    serviceCredentials.Username__c = 'usr1';
    serviceCredentials.Password__c = 'pwd1';
    insert serviceCredentials;
  }

  @isTest
  static void testCalloutPositive(){
    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
    List<Project__c> proj = [SELECT Status__c FROM Project__c WHERE ProjectRef__c = 'TestRef'];
    System.assertEquals(1, proj.size());
    Test.startTest();
    proj[0].Status__c = 'Billable';
    update proj;
    Test.stopTest();
  }

  @isTest
  static void testCalloutNegative(){
    Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
    List<Project__c> proj = [SELECT Status__c FROM Project__c WHERE ProjectRef__c = 'TestRef'];
    System.assertEquals(1, proj.size());
    Test.startTest();
    proj[0].Status__c = 'Running';
    update proj;
    Test.stopTest();

  }


}