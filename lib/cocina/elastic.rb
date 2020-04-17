require 'zeitwerk'
require 'cocina/models'
require 'faker'
require 'active_support'
require 'active_support/core_ext/time'
require 'elasticsearch'
require 'json'
require 'thor'
require 'byebug'
require 'zlib'

loader = Zeitwerk::Loader.new
loader.push_dir(File.absolute_path("#{__FILE__}/../.."))
loader.setup # ready!

module Cocina
  module Elastic
  end
end