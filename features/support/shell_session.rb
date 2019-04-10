class ShellSession
  def self.execute(cmd, env = nil)
    ShellSession.new.execute(cmd, env)
  end

  def initialize
    @commands = []
    @output = []
  end

  def execute(cmd, env = nil)
    if env
      success = system(env, cmd)
    else
      @commands << "$ #{cmd}"
      @output << `#{cmd}`
      success = $?.exitstatus.zero?
    end

    raise log unless success

    self
  end

  def output
    @output.join("\n")
  end

  def log
    # Interleave the commands executed with their output
    @commands.zip(@output).flatten.compact.join("\n")
  end
end
