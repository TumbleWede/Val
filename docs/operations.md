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

Additionally, you can also chain these methods together:
```lua
local x = Val.new(2)
x:pow(3):div(4):add(5):mul(6) -- (((x ^ 3) / 4) + 5) * 6
print(x:get()) -- 42
```

# Math Operations
These methods behave the same as assignment operators.
| Name           | Operation                     | Val Method          | Val Equivalent                         |
| -------------- | ----------------------------- | ------------------- | -------------------------------------- |
| Min Value      | `a = math.min(a, b, ...)`     | `a:min(b, ...)`     | `a:set(math.min(a:get(), b, ...))`     |
| Max Value      | `a = math.max(a, b, ...)`     | `a:max(b, ...)`     | `a:set(math.max(a:get(), b, ...))`     |
| Clamp          | `a = math.clamp(a, min, max)` | `a:clamp(min, max)` | `a:set(math.clamp(a:get(), min, max))` |
| Absolute Value | `a = math.abs(a)`             | `a:abs()`           | `a:set(math.abs(a:get()))`             |
| Floor          | `a = math.floor(a)`           | `a:floor()`         | `a:set(math.floor(a:get()))`           |
| Ceiling        | `a = math.ceil(a)`            | `a:ceil()`          | `a:set(math.ceil(a:get()))`            |
| Round          | `a = math.round(a)`           | `a:round()`         | `a:set(math.round(a:get()))`           |
| Snap           | `a = math.round(a / b) * b`   | `a:snap(b)`         | `a:set(math.round(a:get() / b) * b)`   |
| Lerp           | `a = math.lerp(a, b, t)`      | `a:lerp(b, t)`      | `a:set(math.lerp(a:get(), b, t))`      |

# Relational Operators
Assume both `a` and `b` are a `Val<T>`, since these methods are meant to be used exclusively for comparing `Val` objects.
| Name                     | Operator | Val Method | Val Equivalent       |
| ------------------------ | -------- | ---------- | -------------------- |
| Equal to                 | `a == b` | `a:eq(b)`  | `a:get() == b:get()` |
| Less than                | `a < b`  | `a:lt(b)`  | `a:get() < b:get()`  |
| Less than or equal to    | `a <= b` | `a:le(b)`  | `a:get() <= b:get()` |
| Greater than             | `a > b`  | `a:gt(b)`  | `a:get() > b:get()`  |
| Greater than or equal to | `a >= b` | `a:ge(b)`  | `a:get() >= b:get()` |