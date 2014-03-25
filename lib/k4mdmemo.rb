# -*- coding: utf-8 -*-

require "k4mdmemo/version"
require "active_support/core_ext"
require "active_support/dependencies"

ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

module K4mdmemo
  extend ActiveSupport::Autoload
  autoload :Error
  autoload :Command
  autoload :Server
  autoload :MarkdownRenderer
end
