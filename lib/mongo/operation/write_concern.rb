# Copyright (C) 2014-2016 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mongo
  module Operation

    # Adds behaviour for updating the options and the selector for operations
    # that need to take read preference into account.
    #
    # @since 2.0.0
    module WriteConcern

      private

      def update_selector_for_write_concern(selector, server)
        if write_concern && server.features.collation_enabled?
          selector.merge(writeConcern: write_concern.options)
        else
          selector
        end
      end
    end
  end
end
