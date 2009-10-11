# CodeBeautifier
# Franck Verrot
require 'time'
require File.join(File.dirname(__FILE__), 'beautifying')

class CodeBeautifier
  include Beautifying

  DEFAULT_CONTENT_TYPES = ["text/html", "application/xml"]
  DEFAULT_INDENT_LEN = 4
  def initialize(app, content_types = DEFAULT_CONTENT_TYPES, spaces = DEFAULT_INDENT_LEN, &block)
    @app = app
    @spaces = spaces
    @content_types = content_types
    evaluate &block
  end

  def spaces val
    @spaces = val
  end

  def content_types cts
    @content_types = cts
  end

  # make this middleware thread-safe
  def call(env)
    dup._call(env)
  end

  def _call(env)
    status, headers, response = @app.call(env)
    
    content_type ||= headers["Content-Type"]
    content_length ||= headers["Content-Length"]
    headers["Last-Modified"] = Time.now.httpdate

    #TODO: implement filtering restriction based on content types
    unless content_length.nil?
      my_response = beautify(response.body,@spaces)
      headers["Content-Length"] = my_response.length.to_s
      [status, headers, my_response]
    else
      [status, headers, response]
    end
  end

  def evaluate(&block)
    @self_before_instance_eval = eval "self", block.binding
    instance_eval &block
  end

  def method_missing(method, *args, &block)
    @self_before_instance_eval.send method, *args, &block
  end
end

