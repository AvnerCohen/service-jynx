# Service-Jynx

Eurasian Wryneck - ***Jynx torquilla***

![Eurasian Wryneck](jynx.jpg)

**Jinx** - ***A condition or period of bad luck that appears to have been caused by a specific person or thing.***

A simple (yet powerfull) solution, to allow an application to manage automatic failover and block calls to an external service and return a stubbed data when service is reported as down.

The code is MRI depended and is not thread safe, is is also designed specifically to run on a single VM and manage in memory hashes of data, though it can very well be executed with an external shared persistance counters such as, say, Redis.


````ruby

  if ServiceJynx.alive?(:amazon_s3_service)
	 HttpParty.get "s3://bucke:username@password/whatever.jpg"
	else
	  "S3 is currently unreachable"
	end

````

	 
## Methods

````ruby

ServiceJynx.register!(:name)
ServiceJynx.alive?(:name)
ServiceJynx.failure!(:name)
ServiceJynx.down!(:name)
ServiceJynx.up!(:name)
ServiceJynx.last_error_count(:name)

````

