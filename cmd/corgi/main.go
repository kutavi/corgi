package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/mux"
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

	r := mux.NewRouter()

	err := http.ListenAndServe(fmt.Sprintf(":%s", port), r)

	if err != nil {
		log.Fatalf("Could not start server: %s", err.Error())
	}
}
