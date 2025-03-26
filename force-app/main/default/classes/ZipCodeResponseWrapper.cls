public class ZipCodeResponseWrapper {
  public String post_code;
  public String country;
  public String country_abbreviation;
  public List<Place> places;

  public class Place {
    public String place_name;
    public String longitude;
    public String state;
    public String state_abbreviation;
    public String latitude;
  }

  public static ZipCodeResponseWrapper parse(String jsonResponse) {
    String formattedJson = jsonResponse
      .replace('post code', 'post_code')
      .replace('country abbreviation', 'country_abbreviation')
      .replace('place name', 'place_name')
      .replace('state abbreviation', 'state_abbreviation');

    return (ZipCodeResponseWrapper) JSON.deserialize(
      formattedJson,
      ZipCodeResponseWrapper.class
    );
  }
}