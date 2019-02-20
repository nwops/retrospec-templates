require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'
require 'rspec-puppet-facts'

include RspecPuppetFacts

# Uncomment this to show coverage report, also useful for debugging
#at_exit { RSpec::Puppet::Coverage.report! }

# @return [String] - the path to the fixtures directory
def fixtures_dir
  @fixtures_dir ||= File.join(File.dirname(__FILE__), 'fixtures')
end

# @return [String] = the path the directory of external facterdb facts
def mock_facts
  @mock_facts ||= File.join(fixtures_dir, 'facterdb_facts')
end

# @return [Hash] - returns a hash of testable operating systems
# uncomment and replace empty hash
# modify to your liking, default to all supported
# operating systems defined in the metadata.json file
def test_on
  @test_on ||= {}
  # {hardwaremodels: ['x86_64'],
  # supported_os: [
  #     {
  #         'operatingsystem' => 'Ubuntu',
  #         'operatingsystemrelease' => ['14.04'],
  #     },
  # ]},
end

ENV['FACTERDB_SEARCH_PATHS'] = mock_facts

default_facts = {
    puppetversion: Puppet.version,
    facterversion: Facter.version,
}

default_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml'))
default_module_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml'))

if File.exist?(default_facts_path) && File.readable?(default_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_facts_path)))
end

if File.exist?(default_module_facts_path) && File.readable?(default_module_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_module_facts_path)))
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.formatter = 'documentation'
  c.mock_with :rspec
  c.before :each do
    # set to strictest setting for testing
    # by default Puppet runs at warning level
    Puppet.settings[:strict] = :warning
  end
end