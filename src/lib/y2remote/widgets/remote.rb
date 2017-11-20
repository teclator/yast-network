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

require "yast"
require "cwm"
require "y2remote/remote"

Yast.import "Remote"
Yast.import "Popup"
Yast.import "CWMFirewallInterfaces"

module Y2Remote
  module Widgets
    class RemoteSettings < CWM::CustomWidget
      def initialize
        textdomain "network"

        @allow_web ||= AllowWeb.new
        @remote = Y2Remote::Remote.instance
      end

      def opt
        [:notify]
      end

      def handle(event)
        case event["ID"]
        when :disallow
          @allow_web.disable
        when :allow_with_manager, :allow_without_vncmanager
          @allow_web.enable
        end

        nil
      end

      def store
        if disallow?
          @remote.disable!
          return
        end

        allow_manager? ? @remote.enable_manager! : @remote.enable!

        @remote.enable_web! if allow_web?

        nil
      end

      def contents
        RadioButtonGroup(
          VBox(
            # Small spacing (bsc#988904)
            VSpacing(0.3),
            # RadioButton label
            Left(
              RadioButton(
                Id(:allow_with_vncmanager),
                Opt(:notify),
                _("&Allow Remote Administration With Session Management"),
                Yast::Remote.IsEnabled && Yast::Remote.EnabledVncManager
              )
            ),
            # RadioButton label
            Left(
              RadioButton(
                Id(:allow_without_vncmanager),
                Opt(:notify),
                _("&Allow Remote Administration Without Session Management"),
                Yast::Remote.IsEnabled && !Yast::Remote.EnabledVncManager
              )
            ),
            # RadioButton label
            Left(
              RadioButton(
                Id(:disallow),
                Opt(:notify),
                _("&Do Not Allow Remote Administration"),
                Yast::Remote.IsDisabled
              )
            ),
            VSpacing(1),
            Left(@allow_web)
          )
        )
      end

      def help
        Yast::Builtins.sformat(
          _(
            "<p><b><big>Remote Administration Settings</big></b></p>\n" \
              "<p>If this feature is enabled, you can\n" \
              "administer this machine remotely from another machine. Use a VNC\n" \
              "client, such as krdc (connect to <tt>&lt;hostname&gt;:%1</tt>), or\n" \
              "a Java-capable Web browser (connect to <tt>https://&lt;hostname&gt;:%2/</tt>).</p>\n" \
              "<p>Without Session Management, only one user can be connected\n"\
              "at a time to a session, and that session is terminated when the VNC client\n" \
              "disconnects.</p>" \
              "<p>With Session Management, multiple users can interact with a single\n" \
              "session, and the session may persist even if noone is connected.</p>"
          ),
          5901,
          5801
        )
      end
    private

      def disallow?
        Yast::UI.QueryWidget(Id(:disallow), :Value)
      end

      def allow?
        !disallow?
      end

      def allow_without_manager?
        Yast::UI.QueryWidget(Id(:allow_without_vncmanager), :Value)
      end

      def allow_manager?
        Yast::UI.QueryWidget(Id(:allow_vncmanager), :Value)
      end

      def allow_web?
        allow? && @allow_web.value
      end
    end

    class AllowWeb < CWM::CheckBox
      def label
        _("Enable access using a &web browser")
      end

      def opt
        [:notify]
      end

      def init
        self.disable if !Yast::Remote.IsEnabled
      end
    end

    class RemoteFirewall < CWM::CustomWidget
      attr_accessor :cwm_interfaces
      def initialize
        @cwm_interfaces = Yast::CWMFirewallInterfaces.CreateOpenFirewallWidget(
         "services" => ["service:vnc-httpd", "service:vnc-server"],
         "display_details" => true
        )
      end

      def init
        Yast::CWMFirewallInterfaces.OpenFirewallInit(@cwm_interfaces, "")
      end

      def contents
        @cwm_interfaces["custom_widget"]
      end

      def help
        @cwm_interfaces["help"]
      end

      def handle(event)
        Yast::CWMFirewallInterfaces.OpenFirewallHandle(@cwm_interfaces, "", event)
      end
    end
  end
end
