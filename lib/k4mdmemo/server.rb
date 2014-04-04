# -*- coding: utf-8 -*-

require "rack"
require "redcarpet"


module K4mdmemo

  class Server

    class << self

      # rackup
      # @param [Array] args Arguments
      def rackup(args)
        options = parse_rack_options(args)
        Rack::Server.start(options)
      end

      # Parse rack options.
      # Separate with "--"
      # @param [Array] args Arguments
      # @return [Hash] options
      def parse_rack_options(args=[])
        rack_args = []
        start_adding = false
        args.each do |arg|
          rack_args << arg if start_adding
          start_adding = true if arg == '--'
        end

        opt_parser = ::Rack::Server::Options.new
        options = default_options
        options[:config] = config_path
        args.clear if ENV.include?("REQUEST_METHOD")
        options.merge! opt_parser.parse!(rack_args)
        ENV["RACK_ENV"] = options[:environment]

        return options
      end

      # Default Rack options.
      # @return [Hash]
      def default_options
        {
          :environment => ENV['RACK_ENV'] || "development",
          :pid         => nil,
          :Port        => 9292,
          :Host        => "0.0.0.0",
          :AccessLog   => [],
          :config      => "config.ru"
        }
      end

      def config_path
        File.join(File.dirname(__FILE__), 'server/config.ru')
      end
    end


    ROUTES = {
      "/"  => :get_index,
      "/(.*)(\..*)?" => :get_show,
    }


    def initialize(app=nil)
      @app = app
    end

    # Rack interface method.
    def call(env)
      req = ::Rack::Request.new(env)
      route_method = nil
      matched = nil
      ROUTES.each do |route, method|
        r = Regexp.new("^#{route}$")
        matched = r.match(req.path)
        if matched
          route_method = method.to_sym
          break
        end
      end

      response = nil
      if self.respond_to?(route_method, true)
        response = self.send(route_method, req, matched)
      end

      # 404 not found
      response = gen_404_response() if response.blank?

      # response finished
      response.finish
    end

    # GET: /
    # @param [Rack::Request] request Request
    # @param [MatchData|nil] matched URL matched.
    # @return [Rack::Response]
    def get_index(request, matched=nil)
      root = Dir.pwd
      path = File.join(root, "*/*.md")

      # bindings
      @files = Dir.glob(path).map do |file|
        file_id = file.gsub(root, "")
        file_id = file_id.gsub(/\.md$/, "").gsub(/^\//, "")
        dat = {
          id: file_id,
          name: File.basename(file),
          path: file,
        }
        File.open(file) do |f|
          title = f.gets
          title = title.gsub(/^\#\s+/, "").gsub(/\s+\#$/, "")
          dat[:title] = title
        end
        dat
      end
      @files.sort!{|a, b| a[:id] <=> b[:id] }

      src = File.read(make_template_path("index.html.erb"))
      erb = ERB.new(src)
      body = erb.result(binding)
      return gen_response(body)
    end

    # GET: /:filename
    # @param [Rack::Request] request Request
    # @param [MatchData|nil] matched URL matched.
    # @return [Rack::Response]
    def get_show(request, matched=nil)
      file_id = matched[1]
      filename = "#{file_id}.md"
      filepath = File.join(Dir.pwd, filename)

      # Return 404 response when file not found.
      gen_404_response() if File.exists?(filepath)

      # bindings
      @file_id  = file_id
      @filename = filename
      @src = File.read(filepath)
      @html = markdown_to_html(@src)

      # to html
      src = File.read(make_template_path("show.html.erb"))
      erb = ERB.new(src)
      body = erb.result(binding)
      return gen_response(body)
    end

    # Convert Markdown source to HTML.
    # @param [String] src Markdown source.
    def markdown_to_html(src)
      render_options = {
        prettify: true,
      }
      renderer = MarkdownRenderer.new(render_options)
      extensions = {
        autolink: true,
        tables: true,
        fenced_code_blocks: true,
        strikethrough: true,
        underline: true,
        quote: true,
        footnotes: true,
      }
      md = ::Redcarpet::Markdown.new(renderer, extensions)
      html = md.render(src)
      return html
    end


    # Generate Rack::Response
    # @param [String] body Response body.
    # @param [Fixnum] status Status code.
    # @param [Hash] headers Headers.
    # @return [Rack::Response]
    def gen_response(body, status=200, headers={})
      response = Rack::Response.new do |r|
        r.status = status
        r['Content-Type'] = "text/html" unless headers.key?('Content-Type')
        headers.each do |key, val|
          r[key] = val
        end
        r.write body
      end
      return response
    end

    # Generate 404 Response
    # @return [Rack::Response]
    def gen_404_response()
      response = gen_response("<h1>404 Not Found</h1>", 404)
      return response
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
      return File.join(File.dirname(__FILE__), 'server/templates')
    end
  end
end
