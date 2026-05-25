// Package main is the entry point for Traefik, a modern HTTP reverse proxy
// and load balancer that makes deploying microservices easy.
package main

import (
	"fmt"
	"os"
	"runtime"

	"github.com/traefik/traefik/v3/cmd"
	"github.com/traefik/traefik/v3/pkg/version"
)

func main() {
	// Print runtime information for debugging purposes
	if len(os.Args) > 1 && os.Args[1] == "version" {
		printVersion()
		os.Exit(0)
	}

	if err := cmd.Execute(); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

// printVersion outputs the current Traefik version information.
func printVersion() {
	fmt.Printf("Traefik version: %s\n", version.Version)
	fmt.Printf("Codename:        %s\n", version.Codename)
	fmt.Printf("Go version:      %s\n", runtime.Version())
	fmt.Printf("Built:           %s\n", version.BuildDate)
	fmt.Printf("OS/Arch:         %s/%s\n", runtime.GOOS, runtime.GOARCH)
}
