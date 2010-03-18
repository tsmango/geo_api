class GeoAPI
  API_VERSION = "v1"
  API_URL     = "http://api.geoapi.com/#{API_VERSION}/"
  
  class << self
    attr_accessor :apikey
  end
  
  # Wraps GeoAPI's Simple Search API method.
  # 
  # @param [Hash] accepts all parameters accepted by the Simple Search.
  #   GoeAPI Documentation: http://docs.geoapi.com/Simple-Search
  # 
  # @param params [Float] :lat
  #   Latitude of the coordinate set, required.
  # @param params [Float] :lon
  #   Longitude of the coordinate set, required.
  # @param params [String] :radius
  #   Format: floating point number followed by unit abbreviation, required.
  # @param params [Integer] :limit
  #   Default value is 10, maximum value is 100.
  # @param params [String] :type
  #   Allowed values are business, POI, intersection, neighborhood, city, and user-entity.
  # 
  # @return [Hash] the parsed response of a Simple Search.
  def self.search(params = {})
    get(API_URL + 'search?' + authenticate(params).to_params)
  end
  
  # Wraps GeoAPI's Keyword Search API method and automatically scopes to lat/lon.
  # 
  # @param [Hash] accepts all parameters accepted by the Keyword Search.
  #   GeoAPI Documentation: http://docs.geoapi.com/Keyword-Search
  # 
  # @param params [Float] :lat
  #   Latitude of the coordinate set, required.
  # @param params [Float] :lon
  #   Longitude of the coordinate set, required.
  # @param params [String] :q
  #   The string you're searching for.
  # @param params [Integer] :limit
  #   Default value is 10, maximum value is 100.
  # @param params [String] :type
  #   Allowed values are any or business.
  # 
  # @return [Hash] the parsed response of a Keyword Search.
  def self.keyword(params = {})
    if (parents = parent_guids(:lat => params[:lat], :lon => params[:lon])).size > 0
      get(API_URL + "e/#{parents.first}/keyword-search?" + authenticate(params).to_params)
    else
      get(API_URL + 'keyword-search?' + authenticate(params).to_params)
    end
  end
  
  # Wraps GeoAPI's MQL Search API method.
  # 
  # @param [Hash] accepts all parameters accepted by the MQL Search.
  #   GoeAPI Documentation: http://docs.geoapi.com/MQL-Search
  # 
  # @param params [Float] :lat
  #   Latitude of the coordinate set, required.
  # @param params [Float] :lon
  #   Longitude of the coordinate set, required.
  # @param params [String] :radius
  #   Format: floating point number followed by unit abbreviation, required.
  # @param params [Integer] :limit
  #   Default value is 10, maximum value is 100.
  # @param params [Array[Hash]] :entity
  #   ie: :entity => [:type => 'business', :guid => nil]
  # 
  # @return [Hash] the parsed response of a MQL Search.
  def self.q(params = {})
    get(API_URL + 'q?' + authenticate({:q => URI.escape(params.to_json)}).to_params)
  end
  
  # Wraps GeoAPI's Parents API methods.
  # 
  # @param [Hash] accepts all parameters accepted by the Parents' methods.
  #   GeoAPI Documentation http://docs.geoapi.com/Parents-Methods
  #   Note: This method wraps both the lat/lon as well as the guid methods,
  #   but it's only possible to use either the lat/lon or guid in one call.
  # 
  # @param params [Float] :lat
  #   Latitude of the coordinate set, required.
  # @param params [Float] :lon
  #   Longitude of the coordinate set, required.
  # 
  # @param params [String] :guid
  #   The guid of the entity to get the parent of.
  # 
  # @return [Hash] the parsed response of a Parents API call.
  def self.parents(params = {})
    if params[:guid].blank?
      get(API_URL + 'parents?' + authenticate(params).to_params)
    else
      get(API_URL + "e/#{params.delete(:guid)}/parents?" + authenticate(params).to_params)
    end
  end
  
  # Wraps GeoAPI's Parents API method, returns guids only.
  # 
  # @param [Hash] accepts all parameters accepted by the Parents' lat/lon method.
  #   GeoAPI Documentation http://docs.geoapi.com/Parents-Methods
  # 
  # @param params [Float] :lat
  #   Latitude of the coordinate set, required.
  # @param params [Float] :lon
  #   Longitude of the coordinate set, required.
  # 
  # @return [Array] the guids of all parents for the given lat/lon.
  def self.parent_guids(params = {})
    parents(params)['result']['parents'].collect{|parent| parent['guid']}
  end
  
  # Wraps GeoAPI's Listing View API method.
  # 
  # @param [Hash] accepts all parameters accepted by the Listing View method.
  #  GeoAPI Documentation http://docs.geoapi.com/Listing-View
  # 
  # @param params [String] :guid
  #   The guid of the listing to view, required.
  # 
  # @return [Hash] the parsed response of a Listing View.
  def self.listing(params = {})
    get(API_URL + "e/#{params.delete(:guid)}/view/listing?" + authenticate(params).to_params)
  end
  
  
  private
  
  # Performs a GET request and parses the returned json.
  # 
  # @param [String] :url
  #   Where the GET request should be made to.
  # 
  # @return [Hash] the parsed json returned by the GET request.
  def self.get(url)
    JSON.parse(RestClient.get(url))
  end
  
  # Merges a set of parameters with the API_KEY defined.
  # 
  # @param [Hash] :params
  #   The parameters that should be merged with the API_KEY.
  # 
  # @return [Hash] the params merged with the :apikey.
  def self.authenticate(params = {})
    params.merge(:apikey => self.apikey)
  end
end