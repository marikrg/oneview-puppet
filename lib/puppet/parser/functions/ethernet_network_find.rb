require 'oneview-sdk'

module Puppet::Parser::Functions
  newfunction(:ethernet_network_find) do |args|

    options = args[0]

    options.each { |key,value| options[key] = nil if value == 'nil' } ## Removes quotes from nil values inside the hash
    options.each { |key,value| options[key] = false if value == 'false' } ## Removes quotes from false values inside the hash

    # Find recently created network by name
    matches = OneviewSDK::EthernetNetwork.find_by(@client, name: options['name'])
    ethernet2 = matches.first

    if ethernet2
      puts "\nFound ethernet-network by name: '#{options["name"]}'.\n  uri = '#{ethernet2[:uri]}'"
    else
      puts "\nThere is no ethernet network named #{options['name']}.\n"
    end



  end
end
