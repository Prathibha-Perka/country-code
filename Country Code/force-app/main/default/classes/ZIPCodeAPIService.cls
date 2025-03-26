public with sharing class ZIPCodeAPIService {
  /**
   * @description Fetch ZIP code data using an external API and store in Salesforce if not from US
   * @param zipCode
   * @return String
   */
  @AuraEnabled
  public static string fetchZIPCodeData(String zipCode) {
    if (String.isBlank(zipCode)) {
      throw new AuraHandledException('ZIP Code cannot be blank');
    }

    // Map for country determination
    Map<String, String> countryMap = new Map<String, String>{
      '0' => 'US',
      '1' => 'US',
      '2' => 'CA',
      '3' => 'MX',
      '4' => 'US',
      '5' => 'IN',
      '7' => 'RU',
      '8' => 'CN',
      '9' => 'AU'
    };
    String firstDigit = zipCode.substring(0, 1);
    String countryAbbreviation = countryMap.get(firstDigit);

    if (String.isBlank(countryAbbreviation)) {
      throw new AuraHandledException('Invalid ZIP Code or unsupported country');
    }

    String url =
      'callout:AccessPro__Authorize_Zippopotam' +'/'+
      countryAbbreviation +
      '/' +
      zipCode;

    HttpRequest request = new HttpRequest();
    request.setEndpoint(url);
    request.setMethod('GET');

    System.HttpResponse response = new HttpResponse();
    try {
      response = new Http().send(request);
    } catch (CalloutException cx) {
      throw new CalloutException(cx.getMessage());
    }
    // Validate the response status code
    if (response.getStatusCode() != 200) {
      throw new InvalidResponseException(
        'Request failed with code ' + response.getStatusCode()
      );
    }
    // Parse the response using the wrapper class
    ZipCodeResponseWrapper responseWrapper;
    try {
      responseWrapper = ZipCodeResponseWrapper.parse(response.getBody());
    } catch (Exception ex) {
      throw new AuraHandledException('Failed to parse API response.');
    }

    // Validate if the response contains a valid post code
    if (String.isBlank(responseWrapper.post_code)) {
      throw new AuraHandledException('Post Code is blank');
    }

    // Return directly if country is US
    if (responseWrapper.country_abbreviation?.equalsIgnoreCase('US')) {
      return JSON.serialize(responseWrapper);
    }
    ZIPCodeDetails__c record = new ZIPCodeDetails__c(
      Name = responseWrapper.post_code,
      Country_Abbreviation__c = responseWrapper.country_abbreviation,
      Country__c = responseWrapper.country,
      Response__c = JSON.serialize(responseWrapper.places)
    );
    if (record <> null) {
      insert record;
    }
    return JSON.serialize(responseWrapper);
  }
  /**
   * @description Custom exception for handling invalid API responses
   */
  @TestVisible
  private class InvalidResponseException extends Exception {
  }

}