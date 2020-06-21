package log

import (
	"fmt"
	"os"
)

// NoLogger struct
type NoLogger struct{}

// NewNoLogger NoLogger Constructor
func NewNoLogger() NoLogger {
	return NoLogger{}
}

// Infof NoLogger function
func (n NoLogger) Infof(format string, v ...interface{}) {}

// Debugf NoLogger function
func (n NoLogger) Debugf(format string, v ...interface{}) {}

// Errorf NoLogger function
func (n NoLogger) Errorf(format string, v ...interface{}) {}

// Fatalf NoLogger function
func (n NoLogger) Fatalf(format string, v ...interface{}) {
	os.Exit(1)
}

// Panicf NoLogger function
func (n NoLogger) Panicf(format string, v ...interface{}) {
	panic(fmt.Sprintf(format, v...))
}
