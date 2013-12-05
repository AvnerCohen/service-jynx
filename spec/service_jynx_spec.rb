require 'spec_helper'

# Add when debugging
# require 'pry'
# require 'pry-debugger'

describe ServiceJynx do
  before(:all) do
    ServiceJynx.flush!
  end


  it "should add new services to counter when registerd" do
    jynx = ServiceJynx.counters.fetch(:dummy_service, :ServiceNotFound)
    jynx.should eq(:ServiceNotFound)
    ServiceJynx.register!(:dummy_service)
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    jynx.errors == 0
  end

  it "should allow registering with options" do
    ServiceJynx.register!(:dummy_service, {max_errors: 5})
    jynx = ServiceJynx.counters.fetch(:dummy_service, :ServiceNotFound)
    jynx.max_errors.should eq(5)
  end

  it "should allow checking if service is alive" do
    ServiceJynx.register!(:dummy_service)
    ServiceJynx.alive?(:dummy_service).should eq(true)
  end

  it "should allow shutting down a service" do
    ServiceJynx.register!(:dummy_service)
    ServiceJynx.alive?(:dummy_service).should eq(true)
    ServiceJynx.down!(:dummy_service, "Because of testing")
    ServiceJynx.alive?(:dummy_service).should eq(false)
  end

  it "should allow upping a service" do
    ServiceJynx.register!(:dummy_service)
    ServiceJynx.alive?(:dummy_service).should eq(true)
    ServiceJynx.down!(:dummy_service, "Because of testing")
    ServiceJynx.alive?(:dummy_service).should eq(false)
    ServiceJynx.up!(:dummy_service)
    ServiceJynx.alive?(:dummy_service).should eq(true)
  end

  it "should allow marking a failure" do
    ServiceJynx.register!(:dummy_service)
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    jynx.errors.length.should eq(0)
    ServiceJynx.failure!(:dummy_service)
    jynx.errors.length.should eq(1)
  end

  it "should allow marking multiple failures" do
    ServiceJynx.register!(:dummy_service)
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    jynx.errors.length.should eq(0)
    10.times {ServiceJynx.failure!(:dummy_service)}
    jynx.errors.length.should eq(10)
  end

  it "should allow overrding defaults" do
    ServiceJynx.register!(:dummy_service, {time_window_in_seconds: 999})
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    jynx.time_window_in_seconds.should eq(999)
  end

  it "should clean old errors" do
    ServiceJynx.register!(:dummy_service, {time_window_in_seconds: 2})
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    jynx.errors.length.should eq(0)
    10.times {ServiceJynx.failure!(:dummy_service)}
    jynx.errors.length.should eq(10)
    sleep 5 ## make sure aged errors are cleaned
    10.times {ServiceJynx.failure!(:dummy_service)}
    jynx.errors.length.should eq(10)
  end

  it "should auto disable when errors limit reached old errors" do
    ServiceJynx.register!(:dummy_service, {time_window_in_seconds: 2, max_errors: 20})
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    ServiceJynx.alive?(:dummy_service).should eq(true)
    10.times {ServiceJynx.failure!(:dummy_service)}
    ServiceJynx.alive?(:dummy_service).should eq(true)
    11.times {ServiceJynx.failure!(:dummy_service)}
    ServiceJynx.alive?(:dummy_service).should eq(false)
  end 

  it "should report result for failure" do
    ServiceJynx.register!(:dummy_service, {time_window_in_seconds: 2, max_errors: 3})
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    ServiceJynx.alive?(:dummy_service).should eq(true)
    ServiceJynx.failure!(:dummy_service).should eq(:FAIL_MARKED)
    ServiceJynx.failure!(:dummy_service).should eq(:FAIL_MARKED)
    ServiceJynx.failure!(:dummy_service).should eq(:FAIL_MARKED)
    
    ## After 3 errors, report as down
    ServiceJynx.failure!(:dummy_service).should eq(:WENT_DOWN)
    ServiceJynx.alive?(:dummy_service).should eq(false)
  end  


  it "should auto disable when errors limit reached old errors and restart again when grace period passes" do
    ServiceJynx.register!(:dummy_service, {time_window_in_seconds: 2, max_errors: 20, grace_period: 5})
    jynx = ServiceJynx.counters.fetch(:dummy_service)
    ServiceJynx.alive?(:dummy_service).should eq(true)
    10.times {ServiceJynx.failure!(:dummy_service)}
    ServiceJynx.alive?(:dummy_service).should eq(true)
    11.times {ServiceJynx.failure!(:dummy_service)}
    ServiceJynx.alive?(:dummy_service).should eq(false)
    sleep 7
    ServiceJynx.alive?(:dummy_service).should eq(true)
  end 


end