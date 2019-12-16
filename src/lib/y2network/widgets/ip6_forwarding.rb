# Copyright (c) [2019] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "cwm/common_widgets"
Yast.import "NetworkService"

module Y2Network
  module Widgets
    class IP6Forwarding < CWM::CheckBox
      def initialize(config)
        textdomain "network"

        @config = config
      end

      def init
        self.value = @config.routing.forward_ipv6
        disable if Yast::NetworkService.network_manager?
      end

      def store
        @config.routing.forward_ipv6 = value
      end

      def label
        _("Enable I&Pv6 Forwarding")
      end

      def help
        _(
          "<p>Enable <b>IPv6 Forwarding</b> (forwarding packets from external networks\n" \
            "to the internal one) if this system is a router.\n" \
            "<b>Warning:</b> IPv6 forwarding disables IPv6 stateless address\n" \
            "autoconfiguration (SLAAC).</p>"
        )
      end
    end
  end
end