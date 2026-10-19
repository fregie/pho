// Copyright © 2017 VMware, Inc. All Rights Reserved.
// SPDX-License-Identifier: BSD-2-Clause
//
package nfs

import (
	"fmt"
	"net"
	"sync"
	"testing"
)

func listenAndServe(t *testing.T, port int) (*net.TCPListener, *sync.WaitGroup, error) {

	addr, err := net.ResolveTCPAddr("tcp", fmt.Sprintf("127.0.0.1:%d", port))
	l, err := net.ListenTCP("tcp", addr)
	if err != nil {
		return nil, nil, err
	}
	wg := &sync.WaitGroup{}

	wg.Add(1)
	go func() {
		l.Accept()
		t.Logf("Accepted conn")
		l.Accept()
		t.Logf("Accepted conn")
		wg.Done()
	}()

	return l, wg, nil
}

// test we can bind without colliding
func TestDialService(t *testing.T) {
	listener, wg, err := listenAndServe(t, 6666)
	if err != nil {
		t.Logf("error starting listener: %s", err.Error())
		t.Fail()
		return
	}
	defer listener.Close()

	_, err = dialService("127.0.0.1", 6666)
	if err != nil {
		t.Logf("error dialing: %s", err.Error())
		t.FailNow()
	}

	_, err = dialService("127.0.0.1", 6666)
	if err != nil {
		t.Logf("error dialing: %s", err.Error())
		t.FailNow()
	}

	wg.Wait()
}
