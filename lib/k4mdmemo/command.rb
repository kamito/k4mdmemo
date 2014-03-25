
require 'erb'


module K4mdmemo

  class Command

    COMMAND_METHOD_PREFIX = "exec_"

    attr_reader :current_dir


    def initialize
      @current_dir = Dir::pwd
    end

    def exec(args=[])
      return help() if args.blank?

      command = args.shift
      command_method = "#{COMMAND_METHOD_PREFIX}#{command}".to_sym
      unless self.respond_to?(command_method, true)
        error(:command_not_found)
        return help()
      end

      self.send(command_method, *args)
    end


    private

    # Create new markdown file.
    # @param [String] filename Markdown file name.
    def exec_new(filename=nil)
      return error(:filename_not_found) if filename.blank?

      # Generate markdown source.
      template_path = make_template_path("new_markdown.md.erb")
      md_src = File.read(template_path)
      erb = ERB.new(md_src)
      md_src = erb.result(binding)

      # Generate file.
      now = Time.now
      filename = "#{now.strftime('%Y%m%d%H%M%S')}_#{filename}.md"
      filepath = File.join(current_dir, filename)
      File.open(filepath, 'w') do |io|
        io << md_src
      end

      message("Created new file: #{filename}.")
    end

    # Show help
    def exec_help()
      help()
    end


    # Generate ERB template file path.
    # @param [String] filename template file name.
    # @return [String]
    def make_template_path(filename)
      return File.join(templates_dir, filename)
    end

    # Return templates directory path.
    # @return [String]
    def templates_dir
      return File.join(File.dirname(__FILE__), 'templates')
    end

    # Show message.
    # @param [String|nil] message_ Error message.
    def message(message_)
      puts(message_)
    end

    # Show error message.
    # @param [Symbol|String|nil] key Error message.
    def error(key)
      message_ = (key.is_a?(::Symbol)) ? Error.message(key) : key.to_s
      message("\033[31m#{message_}\033[0m\n\n")
    end

    # Show help
    def help(message_=nil)
      message <<__HELP__
HELP!
__HELP__
    end
  end
end
