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
