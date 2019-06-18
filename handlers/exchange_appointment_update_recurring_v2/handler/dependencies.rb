# Load the Ruby NTLM library unless it has already been loaded.  This
# prevents multiple handlers using the same library from causing problems.
if not defined?(Net::NTLM)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/rubyntlm-0.3.4/lib')
  $:.unshift library_path
  # Require the library
  require 'rubyntlm'
end

# Validate the the loaded Ruby NTLM library is the library that is expected for
# this handler to execute properly.
if not defined?(Net::NTLM::VERSION)
  raise "The Ruby NTLM class does not define the expected VERSION constant."
elsif Net::NTLM::VERSION::STRING != '0.3.4'
  raise "Incompatible library version #{Net::NTLM::VERSION} for Ruby NTLM.  Expecting version 0.3.4."
end



# Load the ruby Multijson library unless it has already been loaded.  This 
# prevents multiple handlers using the same library from causing problems.
if not defined?(MultiJson)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/multi_json-1.7.5/lib')
  $:.unshift library_path
  # Require the library
  require 'multi_json'
end

# Validate the the loaded MultiJson library is the library that is expected for
# this handler to execute properly.
if not defined?(MultiJson::Version)
  raise "The MultiJson class does not define the expected VERSION constant."
elsif MultiJson::Version.to_s != '1.7.5'
  raise "Incompatible library version #{MultiJson::Version} for MultiJson.  Expecting version 1.7.5."
end




# Load the ruby Little Plugger library unless it has already been loaded.  This 
# prevents multiple handlers using the same library from causing problems.
if not defined?(LittlePlugger)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/little-plugger-1.1.4/lib')
  $:.unshift library_path
  # Require the library
  require 'little-plugger'
end

# Validate the the loaded Little Plugger library is the library that is expected
# for this handler to execute properly.
if not defined?(LittlePlugger::VERSION)
  raise "The LittlePlugger class does not define the expected VERSION constant."
elsif LittlePlugger::VERSION.to_s != '1.1.4'
  raise "Incompatible library version #{LittlePlugger::Version} for LittlePlugger.  Expecting version 1.1.4."
end




# Load the ruby Logging library unless it has already been loaded.  This 
# prevents multiple handlers using the same library from causing problems.
if not defined?(Logging)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/logging-2.0.0/lib')
  $:.unshift library_path
  # Require the library
  require 'logging'
end

# Validate the the loaded Logging library is the library that is expected for
# this handler to execute properly.
if not defined?(Logging::VERSION)
  raise "The Logging class does not define the expected VERSION constant."
elsif Logging::VERSION.to_s != '2.0.0'
  raise "Incompatible library version #{Logging::Version} for Logging.  Expecting version 2.0.0."
end




# Load the HTTP Client library unless it has already been loaded.  This
# prevents multiple handlers using the same library from causing problems.
if not defined?(HTTPClient)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/httpclient-2.2.5/lib')
  $:.unshift library_path
  # Require the library
  require 'httpclient'
end

# Validate the the loaded HTTP Client library is the library that is expected 
# for this handler to execute properly.
if not defined?(HTTPClient::VERSION)
  raise "The HTTPClient class does not define the expected VERSION constant."
elsif HTTPClient::VERSION != '2.2.5'
  raise "Incompatible library version #{HTTPClient::VERSION} for HTTPClient.  Expecting version 2.2.5."
end




# Load the ruby MiniPortile library unless it has already been loaded.  This prevents
# multiple handlers using the same library from causing problems.
if not defined?(MiniPortile)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/mini_portile-0.5.1/lib')
  $:.unshift library_path
  # Require the library
  require 'mini_portile'
end

# Validate the the loaded MiniPortile library is the library that is expected for
# this handler to execute properly.
if not defined?(MiniPortile::VERSION)
  raise "The MiniPortile class does not define the expected VERSION constant."
elsif MiniPortile::VERSION != '0.5.1'
  raise "Incompatible library version #{MiniPortile::VERSION} for MiniPortile.  Expecting version 0.5.1"
end



# Load the ruby Nokogiri library unless it has already been loaded.  This prevents
# multiple handlers using the same library from causing problems.
if not defined?(Nokogiri)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/nokogiri-1.6.7.2-java/lib')
  $:.unshift library_path
  # Require the library
  require 'nokogiri'
  require 'nokogiri/version'
end

# Validate the the loaded Nokogiri library is the library that is expected for
# this handler to execute properly.
if not defined?(Nokogiri::VERSION)
  raise "The Nokogiri class does not define the expected VERSION constant."
elsif Nokogiri::VERSION != '1.6.7.2'
  raise "Incompatible library version #{Nokogiri::VERSION} for Nokogiri.  Expecting version 1.6.7.2."
end





# Load the ruby Viewpoint library unless it has already been loaded.  This prevents
# multiple handlers using the same library from causing problems.
if not defined?(Viewpoint)
  # Calculate the location of this file
  handler_path = File.expand_path(File.dirname(__FILE__))
  # Calculate the location of our library and add it to the Ruby load path
  library_path = File.join(handler_path, 'vendor/viewpoint-1.0.0/lib')
  $:.unshift library_path
  # Require the library
  require 'viewpoint'
  require 'viewpoint/version'
  #require 'viewpoint/logging/config' # Uncomment for more specific debug logging
  include Viewpoint::EWS
end

# Validate the the loaded Viewpoint library is the library that is expected for
# this handler to execute properly.
if not defined?(Viewpoint::VERSION)
  raise "The Viewpoint class does not define the expected VERSION constant."
elsif Viewpoint::VERSION != '1.0.0'
  raise "Incompatible library version #{Viewpoint::VERSION} for Viewpoint.  Expecting version 1.0.0."
end



