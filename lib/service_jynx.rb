require "service_jynx/version"
require "logger_jynx"

module ServiceJynx

  @counters = {}
  def self.counters
    @counters
  end

  def self.register!(name, options = {})
    @counters[name] = Jynx.new(name, options)
  end  

  def self.flush!
    @counters = {}
  end

  def self.alive?(name)
    @counters[name].alive? == true
  end

  def self.down!(name, reason)
    @counters[name].down!(reason)
  end

  def self.up!(name)
    @counters[name].up!
  end

  def self.failure!(name)
    jynx = @counters[name]
    now = Time.now.to_i
    jynx.errors << now
    jynx.clean_aged(now)
    down!(name, "Max error count (#{jynx.max_errors}) reached at #{Time.now}.") if jynx.errors.count > jynx.max_errors
  end


  class Jynx
    attr_accessor :errors, :name, :time_window_in_seconds, :max_errors, :alive, :down_at, :grace_period
    def initialize(name, options)
      @name = name
      @down_at = 0
      @alive = true
      @errors = []
      opts = {
        time_window_in_seconds: 10,
        max_errors: 40,
        grace_period: 360
        }.merge!(options)
      @time_window_in_seconds = opts[:time_window_in_seconds]
      @max_errors = opts[:max_errors]
      @grace_period = opts[:grace_period]
    end

    ## clean up errors that are older than time_window_in_secons
    def clean_aged(time_now)
      near_past = time_now - @time_window_in_seconds
      @errors = @errors.reverse.select{|time_stamp| time_stamp  > near_past }.reverse.to_a
    end

    def down!(reason)
      @alive = false
      @down_at = Time.now.to_i
      LoggerJynx.logger.error "Shutting down [#{@name}] #{reason} at #{@down_at}."      
    end

    def up!
      LoggerJynx.logger.error "Upping [#{@name}]."      
      @alive = true
      @down_at = 0
    end

    def alive?
      return true if @alive
      near_past = Time.now.to_i - @grace_period
      up! if (@down_at < near_past) and return true
      false
    end

  end



end
