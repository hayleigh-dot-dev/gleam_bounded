////
////
////


import gleam/order.{Order, Lt, Eq, Gt}


// TYPES -----------------------------------------------------------------------


/// Represents a value bounded by some minimum and maximum values. 
///
/// Note how this is parameterised by the type variable `a`. By using the exposed
/// constructor functions `bounded` or `between` you can supply a custom comparison
/// function so that you can create _any_ sort of bounded value.
///
/// For common bounded types such as `Bounded(Int)` and `Bounded(Float)` some
/// convinience modules exist to cover them:
///
///   * [`bounded/int`]()
///   * [`bounded/float`]()
///
pub opaque type Bounded(a) {
    Bounded(
        comparator: fn (a, a) -> Order,
        min: a,
        max: a,
        val: a
    )
}


// CREATING BOUNDED VALUES -----------------------------------------------------


/// Create a `Bounded` value bu supplying a minimum and maximum value and a
/// comparison function to be used when setting or updating this value.
///
/// This defaults to using the supplied _minimum_ value as the initival value.
/// Although function parameters are named `min` and `max` for convinience, this
/// will always use whichever value is smaller as the minimum bound as determined
/// by your comparison function.
pub fn by (min: a, max: a, compare: fn (a, a) -> Order) -> Bounded(a) {
    case compare(min, max) {
        Lt -> Bounded(compare, min, max, min)
        Eq -> Bounded(compare, min, max, min)
        Gt -> Bounded(compare, max, min, max)
    }
}

/// Create a `Bounded` value by supplying an initial, minimum, and maximum value
/// and a comparison function. If the initial value is out of bounds it will be
/// clamped to either the supplied `min` or `max` value.
pub fn between (val: a, min: a, max: a, compare: fn(a, a) -> Order) -> Bounded(a) {
    // We can cut down on a load of bloated logic by just creating a bounded
    // value using the `bounded` function above and then calling `set` with the
    // supplied value.
    by(min, max, compare)
        |> set(val)
}


// UPDATED BOUNDED VALUES ------------------------------------------------------


/// Replace the value stored inside a `Bounded` with a new one. If it is out of
/// bounds it will clamp to the existing min or max value.
pub fn set (bounded: Bounded(a), to val: a) -> Bounded(a) {
    let Bounded(comparator, min, max, _) = bounded

    case comparator(min, val) {
        Gt -> Bounded(..bounded, val: min)
        _  -> case comparator(val, max) {
            Gt -> Bounded(..bounded, val: max)
            _  -> Bounded(..bounded, val: val)
        }
    }
}

/// Reset a `Bounded` value to its minimum.
pub fn set_to_min (bounded: Bounded(a)) -> Bounded(a) {
    Bounded(..bounded, val: bounded.min)
}

/// Reset a `Bounded` value to its maximum.
pub fn set_to_max (bounded: Bounded(a)) -> Bounded(a) {
    Bounded(..bounded, val: bounded.max)
}

/// Updated the value sotred inside a `Bounded` by applying a function to it. This
/// will clamp to the existing min or max value if it is out of bounds.
pub fn update (bounded: Bounded(a), by f: fn(a) -> a) -> Bounded(a) {
    set(bounded, to: f(bounded.val))
}


// UNPACKING BOUNDED VALUES ----------------------------------------------------


/// Retrieve the value stored inside a `Bounded`.
pub fn value (of bounded: Bounded(a)) -> a {
    bounded.val
}

/// Retreive the minimum value set by a `Bounded`.
pub fn min (of bounded: Bounded(a)) -> a {
    bounded.min
}

/// Retreive the maximum value set by a `Bounded`.
pub fn max (of bounded: Bounded(a)) -> a {
    bounded.max
}

/// Retreive the comparison function used by a `Bounded`.
pub fn comparator (of bounded: Bounded(a)) -> fn (a, a) -> Order {
    bounded.comparator
}
