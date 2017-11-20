#!/usr/bin/env ruby
#
# encoding: utf-8

# Copyright (c) [2017] SUSE LLC
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

require "yast"
require "installation/proposal_client"

module Y2Network
  module Clients
    class RemoteProposal ::Installation::ProposalClient
      include Yast::I18n
      include Yast::Logger

      def initialize
        Yast.import "UI"
        Yast.import "Remote"
        Yast.import "Wizard"

        textdomain "network"

      end

      def description
        {
          # RichText label
          "rich_text_title" => _("VNC Remote Administration"),
          # Menu label
          "menu_title"      => _("VNC &Remote Administration"),
          "id"              => "admin_stuff"
        }
      end

      # create a textual proposal
      def make_proposal(attrs)
        @force_reset = attrs["force_reset"] || false

        if @force_reset
          Remote.Reset
        else
          Remote.Propose
        end

        { "raw_proposal" => [Remote.Summary] }
      end
        # run the module
        elsif @func == "AskUser"
      def ask_user(param)
        @result = Y2Network::Dialogs::Proposal.new

        log.debug("result=%1", @result)

        { "workflow_sequence" => @result }
      end

      def write
        Remote.Write
      end
    end
  end
end
