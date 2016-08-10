################################################################################
# (C) Copyright 2016 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'login'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'common'))
require 'oneview-sdk'

Puppet::Type.type(:oneview_server_profile_template).provide(:ruby) do
  mk_resource_methods

  def initialize(*args)
    super(*args)
    @client = OneviewSDK::Client.new(login)
    @resourcetype = OneviewSDK::ServerProfileTemplate
    @data = {}
  end

  def exists?
    @data = data_parse
    spt = if resource['ensure'] == :present
            resource_update(@data, @resourcetype)
            @resourcetype.find_by(@client, unique_id)
          else
            @resourcetype.find_by(@client, @data)
          end
    !spt.empty?
  end

  def create
    spt = @resourcetype.new(@client, @data)
    true if spt.create
  end

  def destroy
    spt = @resourcetype.find_by(@client, unique_id)
    spt.first.delete
  end

  def found
    find_resources
  end

  def get_available_hardware
    spt = get_spt('Server Profile Templates Available Hardware')
    Puppet.notice(spt.available_hardware) unless spt.available_hardware.empty?
  end

  # Creates and returns a new server profile based on the current template
  def set_new_profile
    spt = get_spt('New Server Profile From Template')
    # assigns a default name in case the user has not declared one
    sp_name = "Server Profile from #{spt['name']}"
    sp_name = @data['serverProfileName'] if @data['serverProfileName']
    sp = spt.new_profile(sp_name)
    if sp.create
      Puppet.notice('A new Server Profile has been successfully created.')
      true
    else
      Puppet.warning('The Server profile could not be created.')
      false
    end
  end

  # Needs the attr connectionName
  def remove_connection
    unless data['connections']
      Puppet.warning('There are no connections settings in the manifest.')
      return false
    end
    spt = get_spt('Server Profile Templates Remove Connections')
    @data['connections'].each do |con|
      network = objectfromstring(con['type']).new(@client, name: con['name'])
      spt.remove_connection(network)
    end
  end

  # Needs the attr network name, type and its options
  def set_connection
    unless @data['connections']
      Puppet.warning('There are no connections settings in the manifest.')
      return false
    end
    spt = get_spt('Server Profile Templates Set Connections')
    @data['connections'].each do |con|
      options = {}
      options = con['options'] if con['options']
      network = objectfromstring(con['type']).new(@client, name: con['name'])
      true if spt.add_connection(network, options)
    end
  end

  # Needs the firmware driver name and its options
  def set_firmware_driver
    spt = get_spt('Server Profile Templates Set Firmware Driver')
    unless @data['firmwareDriver']
      Puppet.warning('There are no firmware drivers in the manifest.')
      return false
    end
    firmware = @data['firmwareDriver']
    options = []
    options = firmware['options'] if firmware['options']
    fd = OneviewSDK::FirmwareDriver.new(@client, name: firmware['name'])
    fd.retrieve!
    spt.set_firmware_driver(fd, options)
  end

  # Needs the enclosure group name
  def set_enclosure_group
    spt = get_spt('Server Profile Templates Set Enclosure Group')
    unless @data['enclosureGroup']
      Puppet.warning('There are no enclosure groups in the manifest.')
      return false
    end
    eg = OneviewSDK::EnclosureGroup.new(@client, name: @data['enclosureGroup'])
    eg.retrieve!
    spt.set_enclosure_group(eg)
  end

  # Needs the server hardware type name
  def set_server_hardware_type
    spt = get_spt('Server Profile Templates Set Server Hardware Type')
    unless data['serverHardwareType']
      Puppet.warning('There are no server hardware types in the manifest.')
      return false
    end
    sht = OneviewSDK::ServerHardwareType.new(@client, name: @data['serverHardwareType'])
    sht.retrieve!
    spt.set_server_hardware_type(sht)
  end

  # Gets the server profile template by its name, retrieves it and sends back the Object
  # Fails if the spt does not exist in the Appliance
  def get_spt(message = nil)
    Puppet.notice("\n\n#{message}\n") if message
    spt = OneviewSDK::ServerProfileTemplate.new(@client, unique_id)
    raise 'No Server Profile Templates were found in Oneview Appliance.' unless spt.retrieve!
    spt
  end
end