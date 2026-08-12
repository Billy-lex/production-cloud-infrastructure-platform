package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

var startTime time.Time

const version = "1.0.0"

func init() {
	startTime = time.Now()
}

// Response is a generic API response wrapper
type Response struct {
	Status  string      `json:"status"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

func main() {
	port    := getEnv("APP_PORT", "8080")
	env     := getEnv("APP_ENV", "development")
	appName := getEnv("APP_NAME", "platform-app")

	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/health", handleHealth)
	http.HandleFunc("/api/info", handleInfo)

	log.Printf("Starting %s [env=%s] on port %s", appName, env, port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, Response{
		Status:  "ok",
		Message: "Welcome to the test application",
	})
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, Response{
		Status:  "healthy",
		Message: "Service is running",
	})
}

func handleInfo(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()

	writeJSON(w, http.StatusOK, Response{
		Status: "ok",
		Data: map[string]interface{}{
			"version":   version,
			"hostname":  hostname,
			"uptime":    time.Since(startTime).String(),
			"timestamp": time.Now().UTC().Format(time.RFC3339),
			"config": map[string]string{
				"app_env":  getEnv("APP_ENV", "development"),
				"app_name": getEnv("APP_NAME", "platform-app"),
				"app_port": getEnv("APP_PORT", "8080"),
			},
		},
	})
}

func writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

// getEnv reads an environment variable with a fallback default value
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
