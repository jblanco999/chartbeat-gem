require 'crack'
require 'rest-client'

class Chartbeat
  YESTERDAY         = Time.now.to_i - 86400
  BASE_URI          = 'api.chartbeat.com'
  METHODS           = [:pages, :pathsummary, :recent, :summize, :quickstats, :toppages, :histogram, :summary]
  DASHAPI_METHODS   = [:alerts, :snapshots, :stats, :data_series, :day_data_series]
  DEFAULT_ARG_VALS  = {:path => '/', :keys => 'n', :types => 'n', :since => YESTERDAY,
    :timestamp => YESTERDAY, :days => 1, :minutes => 20, :type => 'path',
    :breaks => 'n', :limit => 10}
  DEPRECATED_METHODS= [:summize]

  # c = Chartbeat.new :apikey => 'yourkey', :host => 'yourdomain.com'
  def initialize(opts = {})
    raise RuntimeError, "You must provide an API key and host" unless opts[:apikey] && opts[:host]
    @apikey = opts[:apikey]
    @host = opts[:host]
  end

  def method_missing(m, *args)
    super unless METHODS.include?(m) || DASHAPI_METHODS.include?(m)

    if DEPRECATED_METHODS.include?(m)
      warn "#{m} is a deprecated method. Use with caution!"
    end

    query = Hash[*args]
    query_to_perform = {:apikey => @apikey, :host => @host}
    DEFAULT_ARG_VALS.each do |k,v|

      if query.has_key?(k)
      v = query[k]
      end
      query_to_perform[k] = v
    end
    prefix = DASHAPI_METHODS.include?(m) ? '/historical/dashapi' : ''
    data = Crack::JSON.parse(RestClient.get("http://" + BASE_URI + prefix + '/' + m.to_s + '/', :params => query_to_perform))
  end

end
