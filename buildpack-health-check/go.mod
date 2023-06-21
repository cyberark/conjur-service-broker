module github.com/cyberark/conjur-service-broker/buildpack-health-check

go 1.20

require github.com/cyberark/conjur-api-go v0.10.2

require (
	github.com/bgentry/go-netrc v0.0.0-20140422174119-9fd32a8b3d3d // indirect
	github.com/sirupsen/logrus v1.8.1 // indirect
	golang.org/x/sys v0.8.0 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
)

replace golang.org/x/sys v0.0.0-20191026070338-33540a1f6037 => golang.org/x/sys v0.8.0

replace golang.org/x/sys v0.0.0-20211214234402-4825e8c3871d => golang.org/x/sys v0.8.0

replace golang.org/x/sys v0.8.0 => golang.org/x/sys v0.8.0
