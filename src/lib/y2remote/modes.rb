require "yast"

Yast.import "Packages"

module Y2Remote
  class Modes
    def self.all
      [VNC, Manager, Web]
    end

    def self.running_modes
      all.select { |m| m.service_enabled? }
    end

    class Base
      include Singleton

      class << self
        def installed?
          Yast::Package.Installed(self.const_get("PACKAGES"))
        end

        def service_enabled?
          return false unless self.const_get("SERVICE")

          Yast::Service.Enabled(self.const_get("SERVICE"))
        end

        def required_packages
          self.const_get("PACKAGES")
        end

        def stop_service!
          return false unless installed?

          if !Yast::Service.Stop(service)
            Yast::Report.Error(
              Yast::Message.CannotStopService(service)
            )
          end
        end

        def restart_service!
          return false unless installed?

          if !Yast::Service.Restart(service)
            Yast::Report.Error(
              Yast::Message.CannotRestartService(service)
            )
          end
        end

        def enable_service!
          return false unless installed?

          if !Yast::Service.Enable(service)
            Yast::Report.Error(
              _("Enabling service %{service} has failed") % { service: service }
            )
            return false
          end

          true
        end

        def disable_service!
          return false unless installed?

          if !Yast::Service.Disable(self.const_get("SERVICE"))
            Yast::Report.Error(
              _("Disabling service %{service} has failed") % { service: service }
            )
            return false
          end

          true
        end
      end
    end

    class VNC < Base
      SERVICE = "xvnc.socket".freeze
      PACKAGES = Yast::Packages.vnc_packages
    end

    class Manager < Base
      SERVICE = "vncmanager".freeze
      PACKAGES = ["vncmanager"].freeze
    end

    class Web < Base
      SERVICE = "xvnc-novnc.socket".freeze
      PACKAGES = ["xorg-x11-Xvnc-novnc"].freeze
    end
  end
end
