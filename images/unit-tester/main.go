package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("Hello from your custom built Linux kernel.")
	time.Sleep(time.Second * 1)
	fmt.Println("Booting on a Go binary!")
	for {
	}
}
