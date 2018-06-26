/* Print fatal error message and abort */

#include <stdio.h>   // fprintf()
#include <stdlib.h>  // abort()

#include "Python.h"
#include "pystate.h"

// from Python/pystate.c
PyThreadState *_PyThreadState_Current = NULL;

// from Python/ceval.c
volatile int _Py_Ticker = 0; /* so that we hit a "tick" first thing */

// from Python/ceval.c
PyThreadState *
PyEval_SaveThread(void)
{
  return _PyThreadState_Current;
}

void
PyEval_RestoreThread(PyThreadState *tstate)
{
}

// Copied from intobject.c, removed all but the long case.
PyObject *
PyInt_FromSsize_t(Py_ssize_t ival)
{
    return _PyLong_FromSsize_t(ival);
}

// Risky stub!!!
int
PyType_Ready(PyTypeObject *type)
{
  return 0;
}

// from Python/_warnings.c
int
PyErr_WarnEx(PyObject *category, const char *text, Py_ssize_t stack_level)
{
  return 0;
}

// from Python/sysmodule.c
static void
mywrite(char *name, FILE *fp, const char *format, va_list va)
{
    PyObject *file;
    PyObject *error_type, *error_value, *error_traceback;

    PyErr_Fetch(&error_type, &error_value, &error_traceback);
    file = PySys_GetObject(name);
    if (file == NULL || PyFile_AsFile(file) == fp)
        vfprintf(fp, format, va);
    else {
        char buffer[1001];
        const int written = PyOS_vsnprintf(buffer, sizeof(buffer),
                                           format, va);
        if (PyFile_WriteString(buffer, file) != 0) {
            PyErr_Clear();
            fputs(buffer, fp);
        }
        if (written < 0 || (size_t)written >= sizeof(buffer)) {
            const char *truncated = "... truncated";
            if (PyFile_WriteString(truncated, file) != 0) {
                PyErr_Clear();
                fputs(truncated, fp);
            }
        }
    }
    PyErr_Restore(error_type, error_value, error_traceback);
}

void
PySys_WriteStdout(const char *format, ...)
{
    va_list va;

    va_start(va, format);
    mywrite("stdout", stdout, format, va);
    va_end(va);
}

void
PySys_WriteStderr(const char *format, ...)
{
    va_list va;

    va_start(va, format);
    mywrite("stderr", stderr, format, va);
    va_end(va);
}

void
Py_FatalError(const char *msg)
{
    fprintf(stderr, "Fatal Python error: %s\n", msg);
    fflush(stderr); /* it helps in Windows debug build */
    abort();
}

int main() {
    fprintf(stderr, "Hello world");
}
