#!/usr/bin/env ruby
require 'erb'
require 'ostruct'

class String
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def yellow;         "\033[33m#{self}\033[0m" end
  def warning;        yellow                   end
  def fatal;          red                      end
  def info;           green                    end
end

class OpenStruct
  def get_binding
    binding
  end
end

class MockSpecObject
    attr_reader :instance, :module_path, :module_name, :all_hiera_data, :config
    attr_accessor :enable_beaker_tests, :parameters, :types, :resources, :type

    def initialize
      @type = OpenStruct.new(:name => 'name', :type => 'some_type')
      @all_hiera_data = {}
      @parameters = []
      @resources = []
    end

    def parameters
      String.new
    end

    def get_binding
      binding
    end

    def module_name
      'module_name'
    end

    def types
      []
    end

    def class_hiera_data(classname)
      data = {}
    end

    # gathers all the class parameters that could be used in hiera data mocking
    def all_hiera_data
      {}
    end

    def enable_beaker_tests?
      true
    end

    # allows the user to use the variable store to resolve the variable if it exists
    def variable_value(key)
      'value'
    end

    def fact_name
      'fact_name'
    end

    def resource_type_name
      type_name
    end

    def type_name
      'test_type_name'
    end

  end

def context
  @context ||= OpenStruct.new(:provider_name => 'provider_name',
   :name => 'some_name',
   :used_facts => [],
   :confines   => [],
   :fact_name => 'fact_name',
   :schema_path => 'some_path',
   :exec_calls  => [],
   :return_type => 'rvalue',
   :methods     => [],
   :properties => {},
   :parameters => {},
   :instance_methods => [],
   :type_name => 'type_name')

end

def erb_files
  Dir.glob(File.join('**','**' '*.erb'))
end

def render_erb_file(template,spec_object)
  File.open(template) do |file|
    renderer = ERB.new(file.read, 0, '-')
    content = renderer.result spec_object.get_binding
  end
end

status = 0
erb_files.each do |file|
  puts "Checking Erb file: #{file}".yellow
  begin
    case file
    when /classes|defines/
      render_erb_file(file,MockSpecObject.new)
    when /acceptance/
      if File.dirname(file) == 'acceptance'
        render_erb_file(file,MockSpecObject.new)
      else
        render_erb_file(file,MockSpecObject.new)
      end
    when /nodes/
      render_erb_file(file,MockSpecObject.new)
    when /shared_contexts/
      render_erb_file(file,MockSpecObject.new)
    when /resource_spec/
      render_erb_file(file,MockSpecObject.new)
    else
      render_erb_file(file, context)
    end
    puts "File: #{file} was validated".green
  rescue Exception => e
    puts e.message.fatal
    status = 1
  end
end
exit status
