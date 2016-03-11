class TimerProcess
  attr_reader :name
  
  def initialize(process_csv)
    @name = process_csv.shift[0]
    @steps = []
    process_csv.each do |step_data|
      backlight = :off
      case step_data[4].upcase
        when "Y"
          backlight = :on
        when "H"
          backlight = :half
      end
      @steps.push TimerProcessStep.new(self, step_data[1], step_data[0], step_data[2].to_i, step_data[3].upcase == "Y" ? true : false, backlight)
    end
  end
  
  def [](idx)
    @steps[idx]
  end
  
  def each_step
    @steps.each do |step|
      yield step
    end
  end
  
  def steps
    @steps
  end
end

class TimerProcessStep
  attr_reader :process, :short_name, :long_name, :tweakable, :backlight, :phrases
  attr_accessor :seconds

  def initialize(process, short_name, long_name, seconds, tweakable, backlight)
    @process = process
    @short_name = short_name
    @long_name = long_name
    @seconds = seconds
    @tweakable = tweakable
    @backlight = backlight
    
    setup_phrases
  end
  
  def setup_phrases
    @phrases = Hash.new
    @phrases[:ready_to_start] = "Ready to start #{@process.name} #{@long_name.downcase} for #{secs_to_ms_words(@seconds)}."
    @phrases[:time_left] = "%s left"
    @phrases[:light_safe] = "Paper is now light safe."
    @phrases[:aborted] = "#{@long_name.downcase} aborted."
    @phrases[:complete] = "#{@process.name} #{@long_name.downcase} complete."
  end
  
  def run
    start_time = Time.now
    while(Time.now - start_time < @seconds) do
      secs_elapsed = (Time.now - start_time).to_i
      secs_left = @seconds - secs_elapsed
      
      yield secs_left
      sleep 1
    end
  end
end
