/* Print fatal error message and abort */

#include <stdio.h>

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
