package log

// Logger interface
type Logger interface {
	Infof(format string, v ...interface{})
	Debugf(format string, v ...interface{})
	Errorf(format string, v ...interface{})
	Fatalf(format string, v ...interface{})
	Panicf(format string, v ...interface{})
}

var defaultLogger Logger = NewSTDLogger()

// SetDefaultLogger set the default logger
func SetDefaultLogger(l Logger) {
	defaultLogger = l
}

// DefaultLogger returns the default logger
func DefaultLogger(l Logger) Logger {
	return defaultLogger
}

// Infof logs to default logger
func Infof(format string, v ...interface{}) {
	defaultLogger.Infof(format, v...)
}

// Debugf logs to default logger
func Debugf(format string, v ...interface{}) {
	defaultLogger.Debugf(format, v...)
}

// Errorf logs to default logger
func Errorf(format string, v ...interface{}) {
	defaultLogger.Errorf(format, v...)
}

// Fatalf logs to default logger
func Fatalf(format string, v ...interface{}) {
	defaultLogger.Fatalf(format, v...)
}

// Panicf logs to default logger
func Panicf(format string, v ...interface{}) {
	defaultLogger.Panicf(format, v...)
}
