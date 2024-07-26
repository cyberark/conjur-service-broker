module github.com/cyberark/conjur-service-broker/buildpack-health-check

go 1.22

require github.com/cyberark/conjur-api-go v0.12.3

require (
	github.com/alessio/shellescape v1.4.1 // indirect
	github.com/bgentry/go-netrc v0.0.0-20140422174119-9fd32a8b3d3d // indirect
	github.com/danieljoos/wincred v1.1.2 // indirect
	github.com/godbus/dbus/v5 v5.1.0 // indirect
	github.com/kr/text v0.2.0 // indirect
	github.com/sirupsen/logrus v1.8.1 // indirect
	github.com/zalando/go-keyring v0.2.3-0.20230503081219-17db2e5354bd // indirect
	golang.org/x/sys v0.8.0 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
)

replace golang.org/x/sys v0.0.0-20191026070338-33540a1f6037 => golang.org/x/sys v0.8.0

replace golang.org/x/sys v0.0.0-20211214234402-4825e8c3871d => golang.org/x/sys v0.8.0

replace golang.org/x/sys v0.8.0 => golang.org/x/sys v0.8.0
