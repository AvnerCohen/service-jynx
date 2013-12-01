# Service-Jynx

Eurasian Wryneck - ***Jynx torquilla***

![Eurasian Wryneck](jynx.jpg)

**Jinx** - ***A condition or period of bad luck that appears to have been caused by a specific person or thing.***

A simple (yet powerfull) solution, to allow a Ruby application to manage automatic failover and block calls to an external service and return a stubbed data when service is reported as down.

The code is MRI depended and is not thread safe, is is also designed specifically to run on a single VM and manage in memory hashes of data, though it can very well be executed with an external shared persistance counters such as, say, Redis.


````ruby

  if ServiceJynx.alive?(:amazon_s3_service)
   begin
	   HttpParty.get "s3://bucke:username@password/whatever.jpg"
   rescue ResponseError => e
    ServiceJynx.failure!(:amazon_s3_service)
   end
	else
	  "S3 is currently unreachable"
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
ServiceJynx.last_error_count(:name)

````

