# Service-Jynx
[![Build Status](https://secure.travis-ci.org/AvnerCohen/service-jynx.png)](http://travis-ci.org/AvnerCohen/service-jynx)

Eurasian Wryneck - ***Jynx torquilla***

![Eurasian Wryneck](jynx.jpg)

**Jinx** - ***A condition or period of bad luck that appears to have been caused by a specific person or thing.***

A simple solution, to allow a Ruby application to manage automatic failover and block calls to an external service and return a stubbed data when service is reported as down.

The code is MRI depended and is not thread safe(!), is is also designed specifically to run on a single VM and manage in memory hashes of data, though it can very well be executed with an external shared persistance counters such as, say, Redis.


````ruby

  def index
    begin
      response = {country: "Israel"}
      if ServiceJynx.alive?("inbox")
        response = {country: HTTParty.get("https://api.github.com/users/AvnerCohen", :timeout => 20)["location"]}
      else
        response.merge!({error: "service down ! #{__method__}"})
      end
    rescue Exception => e 
      ServiceJynx.failure!("inbox")
      response.merge!({error: "exception occured, #{__method__}"})
    ensure
      render json: response and return
    end
  end

````


## Complete Use case extracted

[1] Register the service for Jynx monitoring at application start time:

````
  opts = {
    time_window_in_seconds: 20,
    max_errors: 10,
    grace_period: 60
  }
  ServiceJynx.register!("github_api", opts)
````

[2] Define a module that wraps your HTTP calls to have a generic safe api

````
module HttpInternalWrapper
  extend self
    def get_api(service_name, url, &on_error_block)
      if ServiceJynx.alive?(service_name)
            HTTParty.get(url, :timeout => 20)
      else
        on_error_block.call("#{service_name}_service set as down.")
      end
    rescue Exception => e
      ServiceJynx.failure!(service_name)
      on_error_block.call("Exception in #{service_name}_service exceution - #{e.message}")
    end
end
````

[3] Execute with a stubbed on_error_block that gets executed on failure or service down

````
HttpInternalWrapper.get_api("github_api", "https://api.github.com/users/AvnerCohen") do |msg|
  @logger.error "#{msg} -- #{path} failed at #{__method__} !!"
  {error: "Github api is currently unavailable"} # stub an empty hash with error messages
end
````


## Defaults

Defined when registering a service:

***time_window_in_seconds***: **10**

***max_errors***: **40**

***grace_period***: **360**


Defaults means that *40 errors* during *10 seconds*	would turn the service automatically off, for 5 minutes.

## Methods

````ruby

ServiceJynx.register!(:name, {time_window_in_seconds: 360,  max_errors: 40})
ServiceJynx.alive?(:name)
ServiceJynx.failure!(:name)
ServiceJynx.down!(:name)
ServiceJynx.up!(:name)

````

