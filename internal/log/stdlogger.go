package log

import (
	slog "log"
)

// STDLogger struct
type STDLogger struct {
}

// NewSTDLogger constructor
func NewSTDLogger() STDLogger {
	return STDLogger{}
}

// Infof function of STDLogger
func (s STDLogger) Infof(format string, v ...interface{}) {
	slog.Printf(format, v...)
}

// Debugf function of STDLogger
func (s STDLogger) Debugf(format string, v ...interface{}) {
	slog.Printf(format, v...)
}

// Errorf function of STDLogger
func (s STDLogger) Errorf(format string, v ...interface{}) {
	slog.Printf(format, v...)
}

// Fatalf function of STDLogger
func (s STDLogger) Fatalf(format string, v ...interface{}) {
	slog.Fatalf(format, v...)
}

// Panicf function of STDLogger
func (s STDLogger) Panicf(format string, v ...interface{}) {
	slog.Panicf(format, v...)
}
