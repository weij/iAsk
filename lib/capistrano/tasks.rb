
require File.expand_path("../helpers", __FILE__)

Dir.glob(File.join(File.dirname(__FILE__), '/recipes/*.rb')).sort.each { |f| load f }

