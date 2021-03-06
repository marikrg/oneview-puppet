################################################################################
# (C) Copyright 2017 Hewlett Packard Enterprise Development LP
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

Puppet::Type.newtype(:image_streamer_artifact_bundle) do
  desc "Image Streamer's Artifact Bundle"

  # :nocov:
  ensurable do
    defaultvalues

    newvalue(:found) do
      provider.found
    end

    newvalue(:extract) do
      provider.extract
    end

    newvalue(:download) do
      provider.download
    end

    newvalue(:get_backups) do
      provider.get_backups
    end

    newvalue(:create_backup) do
      provider.create_backup
    end

    newvalue(:create_backup_from_file) do
      provider.create_backup_from_file
    end

    newvalue(:download_backup) do
      provider.download_backup
    end
  end
  # :nocov:

  newparam(:name, namevar: true) do
    desc 'Artifact Bundle name'
  end

  newparam(:data) do
    desc 'Artifact Bundle data hash containing all specifications for the system'
    validate do |value|
      raise('Inserted value for data is not valid') unless value.respond_to?(:[]) && value.respond_to?(:[]=)
    end
  end
end
