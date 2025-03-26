public class MockHttpResponseGenerator implements HttpCalloutMock {
  private HttpResponse mockResponse;
  public MockHttpResponseGenerator(HttpResponse response) {
    this.mockResponse = response;
  }
  public HttpResponse respond(HttpRequest request) {
    return mockResponse;
  }
}