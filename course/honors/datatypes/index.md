---
layout: rscript
title: Data Types
---

Data Types
==========

In the last lesson, we learned about two data types: vectors and data frames.  We also
learned about two different classes of vectors: `numeric` and `factor`.  There are many
other data types in R. Each has a special use, and to be productive in R, you need to be
familiar with the major types and the operations on these types.


Primitive Types
---------------

Each R object has a un underlying "type", which determines the set of possible values
for that object.  You can find the type of an object using the `typeof` function.


The main types include the following:

  * `logical`: a logical value.
    
    <pre><code class="prettyprint">TRUE</code></pre>
    
    
    
    <pre><samp>[1] TRUE
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">FALSE</code></pre>
    
    
    
    <pre><samp>[1] FALSE
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">TRUE | FALSE  # logical 'or'</code></pre>
    
    
    
    <pre><samp>[1] TRUE
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">TRUE &amp; FALSE  # logical 'and'</code></pre>
    
    
    
    <pre><samp>[1] FALSE
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">!TRUE  # logical 'not'</code></pre>
    
    
    
    <pre><samp>[1] FALSE
    </samp></pre>


  * `integer`: an integer (positive or negative).  Many R programmers do not use
    this mode since every `integer` value can be represented as a `double`.
    
    <pre><code class="prettyprint">1L  # suffix integers with an L to distinguish them from doubles</code></pre>
    
    
    
    <pre><samp>[1] 1
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">-7L</code></pre>
    
    
    
    <pre><samp>[1] -7
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">1L:10L  # range of values</code></pre>
    
    
    
    <pre><samp> [1]  1  2  3  4  5  6  7  8  9 10
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">1:10  # (L suffix is optional)</code></pre>
    
    
    
    <pre><samp> [1]  1  2  3  4  5  6  7  8  9 10
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">7%%2  # modulo (remainder)</code></pre>
    
    
    
    <pre><samp>[1] 1
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">7%/%2  # integer division</code></pre>
    
    
    
    <pre><samp>[1] 3
    </samp></pre>


  * `double`: a real number stored in "double-precision floatint point format."
    
    <pre><code class="prettyprint">1</code></pre>
    
    
    
    <pre><samp>[1] 1
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">3.14</code></pre>
    
    
    
    <pre><samp>[1] 3.14
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">-(3 + 8/2) * 7  # arithmetic operations</code></pre>
    
    
    
    <pre><samp>[1] -49
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">2^10  # exponentiation</code></pre>
    
    
    
    <pre><samp>[1] 1024
    </samp></pre>

    A `double` type can store the special values `Inf`, `-Inf`, and `NaN`, which
    represent "positive infinity," "negative infinity," and "not a number":
    
    <pre><code class="prettyprint">1/0</code></pre>
    
    
    
    <pre><samp>[1] Inf
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">-1/0</code></pre>
    
    
    
    <pre><samp>[1] -Inf
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">0/0</code></pre>
    
    
    
    <pre><samp>[1] NaN
    </samp></pre>


  * `complex`: a complex number
    
    <pre><code class="prettyprint">1i  # suffix with i to denote 'imaginary'</code></pre>
    
    
    
    <pre><samp>[1] 0+1i
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">(2i)^2</code></pre>
    
    
    
    <pre><samp>[1] -4+0i
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">sqrt(-1+0i)</code></pre>
    
    
    
    <pre><samp>[1] 0+1i
    </samp></pre>


  * `character`: a sequence of characters, called a "string" in other programming
    languages
    
    <pre><code class="prettyprint">&quot;Hello, World!&quot;  # denote a string with double quotes...</code></pre>
    
    
    
    <pre><samp>[1] &quot;Hello, World!&quot;
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">'abracadabra'    # ...or with single quotes (both forms are equivalent).</code></pre>
    
    
    
    <pre><samp>[1] &quot;abracadabra&quot;
    </samp></pre>


  * `list`: a list of named values (discussed in detail in the next section)
    
    <pre><code class="prettyprint">list(a = 10, b = 11, z = &quot;hello&quot;)</code></pre>
    
    
    
    <pre><samp>$a
    [1] 10
    
    $b
    [1] 11
    
    $z
    [1] &quot;hello&quot;
    </samp></pre>


  * `builtin`, `closure`, `special`: a function or operator (for most purposes, the
    distinctions between these are not important)
    
    <pre><code class="prettyprint">typeof(sqrt)</code></pre>
    
    
    
    <pre><samp>[1] &quot;builtin&quot;
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">typeof(read.csv)</code></pre>
    
    
    
    <pre><samp>[1] &quot;closure&quot;
    </samp></pre>
    
    
    
    <pre><code class="prettyprint">typeof(`&lt;-`)</code></pre>
    
    
    
    <pre><samp>[1] &quot;special&quot;
    </samp></pre>


  * `NULL`: a special type with only one possible value, known as `NULL`
    
    <pre><code class="prettyprint">typeof(NULL)</code></pre>
    
    
    
    <pre><samp>[1] &quot;NULL&quot;
    </samp></pre>


This is not an exhaustive list, but the other modes are exotic and you probably won't
ever encounter them.


Missing Values
--------------
One unique feature of R is its support for "Not Applicable" or "Missing" values.
The `logical`, `integer`, `double`, `complex`, and `character` types can all
represent missing values, using the special constant `NA`.



Conversions
-----------

Often, you don't need to worry too much about the types, because R will implicitly
convert between types for you.  For example, consider the following sequence of
commands

<pre><code class="prettyprint">x &lt;- 1:10
x[[2]] &lt;- 3.14</code></pre>

When the first line gets executed, `x` gets created as an `integer` vector.  In the
second line, R converts `x` to a `double` vector so that it can store the value
`3.14`.


Lists
-----

A "list" is a primitive type that stores a sequence of values, along with optional
names for these values.  The power of the list type is that it allows you to represent
complicated objects.


We construct lists using the `list` function:

<pre><code class="prettyprint">abe &lt;- list(first.name = &quot;Abraham&quot;, last.name = &quot;Lincoln&quot;, weight.lb = 180, 
    height.in = 76.8)</code></pre>

In this example, `abe` is a list with four elements, with names
`first.name`, `last.name`, `weight.lb`, and `height.in`.


We access the elements of a list using double square brackets.  We can either specify
the index of the element

<pre><code class="prettyprint">abe[[1]]</code></pre>



<pre><samp>[1] &quot;Abraham&quot;
</samp></pre>



<pre><code class="prettyprint">abe[[2]]</code></pre>



<pre><samp>[1] &quot;Lincoln&quot;
</samp></pre>

or we can specify the name

<pre><code class="prettyprint">abe[[&quot;first.name&quot;]]</code></pre>



<pre><samp>[1] &quot;Abraham&quot;
</samp></pre>



<pre><code class="prettyprint">abe[[&quot;last.name&quot;]]</code></pre>



<pre><samp>[1] &quot;Lincoln&quot;
</samp></pre>

Another way to access an element by name is to use the `$` operator:

<pre><code class="prettyprint">abe$height</code></pre>



<pre><samp>[1] 76.8
</samp></pre>



<pre><code class="prettyprint">abe$weight</code></pre>



<pre><samp>[1] 180
</samp></pre>

Both forms (`abe[["first.name"]]` and `abe$first.name`) are equivalent, but the `$`
form is more common.


As with vectors, we get the number of elements with the `length` function:

<pre><code class="prettyprint">length(abe)</code></pre>



<pre><samp>[1] 4
</samp></pre>


We slice lists with single square brackets:

<pre><code class="prettyprint">abe[1:2]</code></pre>



<pre><samp>$first.name
[1] &quot;Abraham&quot;

$last.name
[1] &quot;Lincoln&quot;
</samp></pre>



<pre><code class="prettyprint">abe[1]</code></pre>



<pre><samp>$first.name
[1] &quot;Abraham&quot;
</samp></pre>

For a vector, the slice `[1]` is logically equivalent to the element
`[[1]]`, but for a list, these entities are distinct.


We can delete a particular element of a list by assigning it the value `NULL`:

<pre><code class="prettyprint">abe[[&quot;last.name&quot;]] &lt;- NULL</code></pre>

This removes the element, and shifts the indexes of subsequent elements

<pre><code class="prettyprint">abe[[2]]</code></pre>



<pre><samp>[1] 180
</samp></pre>



<pre><code class="prettyprint">abe[[3]]</code></pre>



<pre><samp>[1] 76.8
</samp></pre>



Classes
-------

Two types we saw in the previous lesson are not primitive: data frames and factors.  In
fact, a  data frame is a special type of list, and a factor is a special type of integer
vector. These special types are known as "classes".


Every R object is a member of one or more classes.  To find these classes, use the
`class` function:

<pre><code class="prettyprint">class(TRUE)</code></pre>



<pre><samp>[1] &quot;logical&quot;
</samp></pre>



<pre><code class="prettyprint">class(1L)</code></pre>



<pre><samp>[1] &quot;integer&quot;
</samp></pre>



<pre><code class="prettyprint">class(3.14)</code></pre>



<pre><samp>[1] &quot;numeric&quot;
</samp></pre>

(Confusingly, the class for `double` objects is not called `double`; it is called
`numeric`.)


A data frame is a list whose elements are vectors, each with the same length.
A factor is an integer vector taking values in the range `1`..`m`, with each integer
corresponding to a certain level.  R distinguishes between these types and their
underlying representations by assigning them to different classes.

<pre><code class="prettyprint">bikedata &lt;- read.csv(&quot;bikedata.csv&quot;)
typeof(bikedata)</code></pre>



<pre><samp>[1] &quot;list&quot;
</samp></pre>



<pre><code class="prettyprint">class(bikedata)</code></pre>



<pre><samp>[1] &quot;data.frame&quot;
</samp></pre>



<pre><code class="prettyprint">typeof(bikedata$colour)</code></pre>



<pre><samp>[1] &quot;integer&quot;
</samp></pre>



<pre><code class="prettyprint">class(bikedata$colour)</code></pre>



<pre><samp>[1] &quot;factor&quot;
</samp></pre>



The power of classes is that they allow you to change how certain functions behave.
Compare the following two otputs:

<pre><code class="prettyprint">summary(bikedata$colour)</code></pre>



<pre><samp>Black  Blue Green  Grey Other   Red White  NA's 
  262   636   149   531    52   378   333    14 
</samp></pre>



<pre><code class="prettyprint">summary(unclass(bikedata$colour))</code></pre>



<pre><samp>   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
   1.00    2.00    4.00    3.83    6.00    7.00      14 
</samp></pre>

Here, `unclass` is a function that converts to the underlying primitive type.  When
we summarize an object with class `factor`, we report counts for the levels; when
we summarize an object with class `integer`, we report quartiles and other statistics.


Advanced R programmers create new kinds of classes, along with specialized functions to
act on these classes.
