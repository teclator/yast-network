# encoding: utf-8

require "yast"
require "y2remote/modes"

module Y2Network
  class Remote
    include Singleton
    include Yast::Logger
    include Yast::I18n

    XDM_SERVICE_NAME = "display-manager".freeze
    GRAPHICAL_TARGET = "graphical".freeze

    PKG_CONTAINING_FW_SERVICES = "xorg-x11-Xvnc".freeze

    # Currently, all attributes (enablement of remote access)
    # are applied on vnc1 even vnchttpd1 configuration

    # [Symbol] Remote administration mode, :disabled, :xvnc or :vncmanager
    attr_accessor :modes

    def initialize
      import_modules

      textdomain "network"

      @modes = []
      @web_enabled = false
    end

    # Checks if remote administration is currently allowed
    def enabled?
      !disabled?
    end

    # Checks if remote administration is currently disallowed
    def disabled?
      @modes.empty?
    end

    # Read the current status
    # @return true on success
    def read
      display_manager_remote_access =
        Yast::SCR.Read(Yast.path(".sysconfig.displaymanager.DISPLAYMANAGER_REMOTE_ACCESS")) == "yes"

      xdm = Yast::Service.Enabled(XDM_SERVICE_NAME)

      if xdm && display_manager_remote_access
        @modes = Y2Remote.running_modes
      end

      true
    end

    # Update the SCR according to network settings
    # @return true on success
    def write
      return false unless configure_display_manager

      restart_services if Yast::Mode.normal

      true
    end

    # Updates the VNC and xdm configuration
    #
    # Called from #Write. Ensures that required packages are installed,
    # enables vnc services and xdm and writes the configuration files,
    # reporting any error in the process.
    #
    # @return [Boolean] true if success, false otherwise
    def configure_display_manager
      if enabled?
        # Install required packages
        packages = @modes.map { |m| m.required_packages }

        if !Yast::Package.InstallAll(packages)
          log.error "Installing of required packages failed"
          return false
        end

        Y2Remote.all.each do |mode|
          @modes.include?(mode) ? mode.enable_service! : mode.disable_service!
        end

      end

      # Set DISPLAYMANAGER_REMOTE_ACCESS in sysconfig/displaymanager
      Yast::SCR.Write(
        Yast.path(".sysconfig.displaymanager.DISPLAYMANAGER_REMOTE_ACCESS"),
        enabled? ? "yes" : "no"
      )
      Yast::SCR.Write(
        Yast.path(".sysconfig.displaymanager.DISPLAYMANAGER_ROOT_LOGIN_REMOTE"),
        enabled? ? "yes" : "no"
      )
      Yast::SCR.Write(Yast.path(".sysconfig.displaymanager"), nil)

       true
    end

    def restart_display_manager
      if Yast::Service.active?(XDM_SERVICE_NAME)
        Yast::Report.Error(
          Yast::Message.CannotRestartService(XDM_SERVICE_NAME)
        ) if !Yast::Service.Reload(XDM_SERVICE_NAME)

        Yast::Report.Warning(
          _(
            "Your display manager must be restarted.\n" \
            "To take the changes in remote administration into account, \n" \
            "please restart it manually or log out and log in again."
          )
        )
      else
        Yast::Report.Error(
          Yast::Message.CannotRestartService(XDM_SERVICE_NAME)
        ) if !Yast::Service.Restart(XDM_SERVICE_NAME)
      end
    end

    # Restarts services, reporting errors to the user
    def restart_services
      Yast::SystemdTarget.set_default(GRAPHICAL_TARGET) if enabled?

      Y2Remote::Modes.all.map do |mode|
        @modes.include?(mode) ? mode.restart_service! : mode.stop_service!
      end

      restart_display_manager if enabled?
    end

    # Create summary
    # @return summary text
    def summary
      # description in proposal
      enabled? ? _("Remote administration is enabled.") : _("Remote administration is disabled.")
    end

  private

    def import_modules
      Yast.import "Mode"
      Yast.import "Package"
      Yast.import "Packages"
      Yast.import "Service"
      Yast.import "SuSEFirewall"
      Yast.import "Progress"
      Yast.import "Linuxrc"
      Yast.import "Message"
      Yast.import "SystemdTarget"
    end
  end
end
