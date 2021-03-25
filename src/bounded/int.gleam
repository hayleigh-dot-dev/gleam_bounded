////
////
////


import bounded.{Bounded}
import gleam/int.{Int}


// TYPES -----------------------------------------------------------------------


///
pub type BoundedInt = Bounded(Int)


// CREATING BOUNDED VALUES -----------------------------------------------------


///
pub fn by (min: Int, max: Int) -> BoundedInt {
    bounded.by(min, max, int.compare)
}

///
pub fn between (val: Int, min: Int, max: Int) -> BoundedInt {
    bounded.between(val, min, max, int.compare)
}


// PRESET BOUNDED VALUES -------------------------------------------------------


///
pub fn int8 () -> BoundedInt {
    by(-128, 127)
}

///
pub fn uint8 () -> BoundedInt {
    by(0, 255)
}

///
pub fn int16 () -> BoundedInt {
    by(-32768, 32767)
}

///
pub fn uint16 () -> BoundedInt {
    by(0, 65535)
}

///
pub fn int32 () -> BoundedInt {
    by(-2147483648, 2147483647)
}

///
pub fn uint32 () -> BoundedInt {
    by(0, 4294967295)
}

/// Integers in JavaScript have a safe range of `2^53 - 1` to `-(2^53 - 1)`. This
/// bounded constructor will keep you within those constraints if you don't want
/// to deal with serialising and subsequent decoding of `BigInt`s in your JSON.
pub fn js_safe_int () -> BoundedInt {
    by(-9007199254740991, 9007199254740991)
}


// UPDATED BOUNDED VALUES ------------------------------------------------------


///
pub fn increment (bounded_int: BoundedInt) -> BoundedInt {
    bounded.update(bounded_int, fn (n) {
        n + 1
    })
}

///
pub fn decrement (bounded_int: BoundedInt) -> BoundedInt {
    bounded.update(bounded_int, fn (n) {
        n - 1
    })
}