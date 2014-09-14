---
layout: post
title: BLAS Data Types
keywords: blas, scientific computing
category: Programming

excerpt: Discussion of how one could wrap a higher-level interface on top of BLAS/LAPACK. 
---

I'm going to shed a little light on what I meant when [in my last post][] I 
said that "BLAS and LAPACK (mostly) support" an O(1) `herm` operation for
matrices.

[in my last post]: /blog/2008/06/06/ann-blas-bindings-for-haskell-version-04/

First I need to tell you about the BLAS data types.  There are two fundamental
data types in BLAS: dense vectors and dense matrices.  

Vectors
-------

A *dense vector* is represented as an array of non-contiguous values, with a
fixed stride between values.  In C, you need three things to represent a vector:
the length of the vector, a pointer to the first element in the vector, and an
integer stride.  The stride is required to be at least 1, and the length has to
be non-negative.  Length is usually represented by a variable called `n`, the
pointer is usually called `x` or `y`, and the stride (or "increment") is
named `incx` for `x` or `incy` for `y`.  So, you could have

    double *data = { 1.6, 1.7, -3.1, -0.2, 2.6, 1.1 };
    int n = 3;
    double *x = data;
    int incx = 2;
    double *y = data + 1;
    int incy = 1;
    
Then, x would be a vector with elements (1.6, -3.1, 2.6), and y would be a
vector with elements (1.7, -3.1, -0.2).  Being able to have a non-unit stride
for vectors turns out to be incredibly useful.

Matrices
--------

Matrices in BLAS are slightly more complicated.  There are two variants: 
*row-major*, and *column-major*.  For CBLAS both are supported equally well,
but most Fortran code (including LAPACK) assumes column-major.  Unfortunately,
a lot of C code stores matrices in row-major order.  The inconsistency turns
out not to be a very big deal for real-valued matrices, but it can cause
trouble for complex-valued ones.  

I'm going to stick with the convention that when I say "matrix" I mean
"column-major matrix".  The important thing to remember is that elements in
the same column are stored contiguously, but elements in the same row are not.
(For row-major, the reverse is true.)

A *dense matrix* is represented by four numbers: the number of rows, the
number of columns, a pointer to the upper-left element, and the 
*leading dimension*.  The numbers of rows and columns are usually given by 
`m` and `n`.  The pointer to the element is usually named `a`, `b`, or `c`.
The leading dimension is named for the pointer it is associated with, and 
would be `lda` to go with `a` or `ldb` to go with `b`.  What's `lda`?  This
is the stride between consecutive elements of the same row.  It must be
greater than or equal to `min(1,m)`.  

An example will clarify things a bit.  Let's say we want to represent the
matrix `a = [ 1 4; 2 5; 3 6 ]`.  In MATLAB notation, this is a 3-by-2 matrix;
the first column is (1, 2, 3), and the second column is (4, 5, 6).  In C, we
would have

    double *data = { 1, 2, 3, 4, 5, 6 };
    int m = 3, n = 2;
    double *a = data
    int lda = 3;
    
Since there is no gap in memory between the last element of the first column
and the first element of the second column, `lda` is equal to `m`.  Now, what
if we want to represent the submatrix `b = a(1:2,1:2)`?  This is easy:

    int mb = 2, nb = 2;
    double *b = a;
    int ldb = 3;
    
We can also similarly represent `c = a(2:3,1:2)`:

    int mc = 2, nc = 2;
    double *c = a + 1;
    int ldc = 3;
    
In general we can represent any submatrix whose row and column indices are
contiguous.

What else can we do with a matrix?  Well, because of the stride parameter, we
can easily represent a row of the matrix `a` (it has stride `lda`), or a
column (it has stride `1`).  We can also represent a diagonal of `a` using 
stride `lda+1`.

Data Types
----------

Now, what did I mean when I said that BLAS "supported" an O(1) herm operation?
First of all, notice that I have been a little vague when I've given the 
definitions for the vector and matrix data types.  Probably most of you were
expecting me to introduce a `struct` at some point.  Sadly, BLAS does not
define any new formal types.  BLAS only defines functions.  The "types" I
talked about above are really just conventions that all of the functions 
adhere to.  So, here's the function signature for `daxpy`, the function that 
performs the operation `y := alpha * x + y`, where `alpha` is a scalar and 
`x` and `y` are vectors:

    void cblas_daxpy (int n, double alpha, 
                      const double *x, int incx, 
                      double *y, int incy);

Only primitive types appear in the argument list.  The only way to tell that
the function operates on vectors is by looking at the names of the arguments
and reading the documentation.  This is annoying.  Let's fix that by defining
our own vector type:

    typedef struct 
    {
        double *data;
        int size;
        int stride;
        int is_conj;
    } vector_t;
    
(Ignore `is_conj` for now; the rest should be self-explanatory).  Now, we can
simplify `daxpy` a bit:

    void my_daxpy (double alpha, const vector_t *x, 
                   vector_t *y);
    
You can imagine that this will clean up a lot of our code.  Let's see if we can
use the same trick for matrices using `dgemv`, the function to multiply a matrix
by a vector, as an example.  Specifically, the function performs the operation
`y := alpha * op(A) * x + beta * y` where `op` is either "transpose", "herm", or "identity" ("herm" means conjugate transpose).

Here is the signature:

    void cblas_dgemv (enum CBLAS_ORDER order,
                      enum CBLAS_TRANSPOSE transa, 
                      int m, int n,
                      double alpha, const double *a, int lda,
                      const double *x, int incx,
                      double beta, double *y, int incy);
                      
There are twelve parameters.  Barf.  Can we clean this up?  Absolutely.  Here's
the vector type we are going to use:

    typedef struct
    {
        double *data;
        int size1;
        int size2;
        int lda;
        int is_herm;
    } matrix_t;
    
I have introduced a boolean field `is_herm` to indicate whether the matrix has
been transposed and conjugated.  This eliminates `transa` from the call 
signature:
    
    void my_dgemv (double alpha, 
                   const matrix_t *a, const vector_t *x,
                   double beta, 
                   const vector_t *y);
                   
We have eliminated seven parameters from the call, and we have only sacrificed
a little bit of functionality.  We have gained the ability to do run-time
dimension checking for the arguments.  

The feature we have lost is the ability to use "transpose".  We can only do
"identity" and "herm".  Why did I use a boolean for `is_herm` rather than the
more general `CBLAS_TRANSPOSE` type?  Because now we can have a function

    void make_herm (matrix_t *a);
    
that takes the `herm` of a matrix as on O(1) operation.  It would be nice to
have `make_trans` be an O(1) operation, too.  Sadly, because BLAS does not support "conjugate" as the `op` type in a multiplication, we can either have
`trans` be O(1) or we can have `herm` be O(1), but we cannot have both.  I think
giving up `trans` is worth simplifying the interface.

(Astute readers will notice that for `gemv`, it is possible to get `conj(a)` by using "row-major" as the order and "herm" as the transpose type.  This trick does not extend to `dgemm`, the function that multiplies two matrices.)

Now I have to come back to why `vector_t` has an `is_conj` field.  This is
necessary if we want getting a row or a column of a matrix to be an O(1)
operation for "herm-ed" matrices.  

Extending BLAS
--------------

BLAS *almost* supports the simplifications in the API we've made by introducing
`vector_t` and `matrix_t`.  We need the following functionality ourselves to
make the simplifications work.  Here are the functions we need to add:

 * `y := alpha * conj(x) + beta * y`
 * `y := alpha * op(A) * conj(x) + beta * y`
 * `conj(y) := alpha * op(A) * x + beta * conj(y)`

The second function is missing when `y` has non-unit stride, and the third is
missing when `x` has non-unit stride.  This is because we can always cast a
vector as a matrix when it is conjugated.  If the vector is not conjugated, we
can only perform the cast if the stride is one. (Columns are stored contiguously
for normal matrices, but not for herm-ed matrices.)  Once the vectors have been
casted to matrices, we can call `gemm`.  

Summary
-------

The BLAS API is painfully verbose.  By adding our own data types and giving up
the ability to take the transpose of the matrix, we can get a far simpler
interface with nearly all of the power.  The approach I describe here is the one
I use in the [blas bindings for Haskell][].

[blas bindings for Haskell]: http://hackage.haskell.org/cgi-bin/hackage-scripts/package/blas
