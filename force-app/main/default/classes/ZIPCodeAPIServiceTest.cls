@isTest
private class ZIPCodeAPIServiceTest {
  @isTest
  static void testFetchZIPCodeData_Success() {
    // Arrange
    HttpResponse mockResponse = new HttpResponse();
    mockResponse.setBody(
      '{"post_code": "12345", "country": "United States", "country_abbreviation": "US", "places": [{"place_name": "New York", "state": "NY"}]}'
    );
    mockResponse.setStatusCode(200);

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(mockResponse)
    );

    Test.startTest();
    // Act
    String result = ZIPCodeAPIService.fetchZIPCodeData('12345');

    Test.stopTest();
    // Assert
    System.assertNotEquals(null, result);
    System.assert(result.contains('United States'));
  }

  @isTest
  static void testFetchZIPCodeData_InvalidZIP() {
    // Arrange
    Test.startTest();
    HttpResponse mockResponse = new HttpResponse();
    mockResponse.setStatusCode(404);
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(mockResponse)
    );

    // Act & Assert
    try {
      ZIPCodeAPIService.fetchZIPCodeData('00000');
      System.assert(false, 'Exception should have been thrown');
    } catch (ZIPCodeAPIService.InvalidResponseException e) {
      Assert.areEqual('Request failed with code 404', e.getMessage());
    }
    Test.stopTest();
  }

  @isTest
  static void testFetchZIPCodeData_CreateRecord() {
    // Arrange
    HttpResponse mockResponse = new HttpResponse();
    mockResponse.setBody(
      '{"post_code": "500017", "country": "India", "country_abbreviation": "IN", "places": [{"place_name": "Hyderabad", "state": "Telangana"}]}'
    );
    mockResponse.setStatusCode(200);
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(mockResponse)
    );

    Test.startTest();
    String result = ZIPCodeAPIService.fetchZIPCodeData('500017');
    Test.stopTest();

    // Assert
    List<ZIPCodeDetails__c> records = [
      SELECT Id, Name, Country__c
      FROM ZIPCodeDetails__c
      WHERE Name = '500017'
    ];
    Assert.areEqual(1, records.size());
    Assert.areEqual('India', records[0].Country__c);
  }

  @isTest
  static void testFetchZIPCodeData_ModifyRecord() {
    // Arrange - Create Initial Record
    insert new ZIPCodeDetails__c(
      Name = '500017',
      Country_Abbreviation__c = 'IN',
      Country__c = 'India'
    );

    HttpResponse mockResponse = new HttpResponse();
    mockResponse.setBody(
      '{"post_code": "500017", "country": "India", "country_abbreviation": "IN", "places": [{"place_name": "Hyderabad", "state": "Telangana"}]}'
    );
    mockResponse.setStatusCode(200);
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(mockResponse)
    );

    Test.startTest();
    String result = ZIPCodeAPIService.fetchZIPCodeData('500017');
    Test.stopTest();

    // Assert
    List<ZIPCodeDetails__c> records = [
      SELECT Id, Country__c
      FROM ZIPCodeDetails__c
      WHERE Name = '500017'
    ];
    Assert.areEqual(1, records.size());
    Assert.areEqual('India', records[0].Country__c);
  }
}