package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func getenv(name, defaultValue string) string {
	o := os.Getenv(name)
	if "" == o {
		return defaultValue
	}
	return o
}

func main() {
	port := getenv("APP_PORT", "6969")
	log.Printf("Starts at %s", port)
	err := http.ListenAndServe(fmt.Sprintf(":%s", port), nil)

	if err != nil {
		log.Fatalf("Could not start server: %s", err.Error())
	}
}
