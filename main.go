package main

import (
	"bytes"
	"fmt"
	"os"

	dockerclient "github.com/fsouza/go-dockerclient"
)

func main() {
	// args from https://github.com/gliderlabs/registrator/blob/3181e58ae642b9963711ebf1fe7cb431a3f684b3/consul/consul.go#L74
	if len(os.Args) < 4 {
		fmt.Fprint(os.Stderr, "Please specify <containerid> <port> <cmd>\n")
		os.Exit(3)
	}

	containerid := os.Args[1]
	exposedport := os.Args[2]
	cmd := os.Args[3]
	// fmt.Printf("containerid %s port %s cmd '%s'\n", containerid, exposedport, cmd)

	endpoint := "unix:///var/run/docker.sock"
	client, _ := dockerclient.NewClient(endpoint)
	config := dockerclient.CreateExecOptions{
		Container:    containerid,
		AttachStdin:  true,
		AttachStdout: true,
		AttachStderr: false,
		Tty:          false,
		Cmd:          []string{cmd, exposedport},
		// User:         "a-user",
	}
	execObj, err := client.CreateExec(config)
	if err != nil {
		fmt.Fprintln(os.Stderr, "CreateExec failed")
		os.Exit(2)
	}
	var stdout, stderr bytes.Buffer
	opts := dockerclient.StartExecOptions{
		OutputStream: &stdout,
		ErrorStream:  &stderr,
		// RawTerminal:  true,
	}
	if err = client.StartExec(execObj.ID, opts); err != nil {
		fmt.Fprintln(os.Stderr, "StartExec failed")
		os.Exit(2)
	}
	fmt.Fprintf(os.Stdout, stdout.String())
	fmt.Fprintf(os.Stderr, stderr.String())

	inspect, err := client.InspectExec(execObj.ID)
	if err != nil {
		fmt.Fprintln(os.Stderr, "InspectExec failed")
		os.Exit(2)
	}

	if inspect.ExitCode == 0 {
		os.Exit(0)
	} else if inspect.ExitCode == 1 {
		os.Exit(1)
	} else {
		os.Exit(2)
	}

	// fmt.Fprintf(os.Stdout, "exitcode: %d\n")
	// fmt.Fprintf(os.Stdout, "ID: %s\n", inspect.ID)
	// fmt.Fprintf(os.Stdout, "Running: %t\n", inspect.Running)
}
