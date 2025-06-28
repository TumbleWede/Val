---
sidebar_position: 4
---
# Operator Methods
Val has many operator methods that help reduce the code needed to perform operations on Val object.

Using these operator methods also reduces the number of calls per operation, thus being more efficient than performing them manually (as seen in the Val equivalents).

These methods will not check if the operation is valid, so trying to do something devious like dividing a string will result in an error.
# Assignment Operators
Assume `a` is a `Val<T>` and `b` is a `T`, where `T` is any type. If `b` were to be a `Val<T>`, then you would need to call `b:get()` inside each assignment call (e.g. `a:add(b:get())`).
| Name           | Operator    | Val Method  | Val Equivalent        |
| -------------- | ----------- | ----------- | --------------------- |
| Addition       | `a += b`    | `a:add(b)`  | `a:set(a:get() + b)`  |
| Subtraction    | `a -= b`    | `a:sub(b)`  | `a:set(a:get() - b)`  |
| Multiplication | `a *= b`    | `a:mul(b)`  | `a:set(a:get() * b)`  |
| Division       | `a /= b`    | `a:div(b)`  | `a:set(a:get() / b)`  |
| Floor Division | `a //= b`   | `a:idiv(b)` | `a:set(a:get() // b)` |
| Modulus        | `a %= b`    | `a:mod(b)`  | `a:set(a:get() % b)`  |
| Exponentiation | `a ^= b`    | `a:pow(b)`  | `a:set(a:get() ^ b)`  |
| Concatenation  | `a ..= b`   | `a:cat(b)`  | `a:set(a:get() .. b)` |
| Toggling       | `a = not a` | `a:flip()`  | `a:set(not a:get())`  |
# Relational Operators
Assume both `a` and `b` are a `Val<T>`, since these methods are meant to be used exclusively for comparing `Val` objects.
| Name                     | Operator | Val Method | Val Equivalent       |
| ------------------------ | -------- | ---------- | -------------------- |
| Equal to                 | `a == b` | `a:eq(b)`  | `a:get() == b:get()` |
| Less than                | `a < b`  | `a:lt(b)`  | `a:get() < b:get()`  |
| Less than or equal to    | `a <= b` | `a:le(b)`  | `a:get() <= b:get()` |
| Greater than             | `a > b`  | `a:gt(b)`  | `a:get() > b:get()`  |
| Greater than or equal to | `a >= b` | `a:ge(b)`  | `a:get() >= b:get()` |