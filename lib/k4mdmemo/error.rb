# -*- coding: utf-8 -*-

module K4mdmemo

  DEFAULT_ERROR_MESSAGE = "Error"

  ERRORS = {
    command_not_found:  "Command not found.",
    filename_not_found: "Please input filename.",
  }

  class Error

    class << self
      def message(key)
        ERRORS[key.to_sym] || DEFAULT_ERROR_MESSAGE
      end
    end
  end
end
