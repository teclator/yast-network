# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2017 SUSE LLC
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact SUSE.
#
# To contact SUSE about this file by physical or electronic mail, you may find
# current contact information at www.suse.com.
# ------------------------------------------------------------------------------

require "y2network/dialogs/remote"

module Y2Network
  module Clients
    class Remote
      include Yast::Logger
      include Yast::I18n
      include Yast::UIShortcuts

      def initialize
        Yast.import "Label"
        Yast.import "Remote"
        Yast.import "Wizard"
        Yast.import "Report"
        Yast.import "SuSEFirewall"

        Yast.import "CommandLine"
        Yast.import "RichText"
        Yast.import "UI"

        textdomain "network"

        Yast::Remote.Read
        Yast::SuSEFirewall.Read
      end

      def run
        log.info("----------------------------------------")
        log.info("Remote client started")

        Y2Network::Dialogs::Remote.new.run
      end
    end
  end
end
