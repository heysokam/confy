//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
/**
 * @fileoverview
 * General Purpose Type Declarations for use by confy and usercode
 * */
export type Opaque = { readonly _: unique symbol }
export type Distinct<T> = Opaque & T
export type Path = Distinct<string>

// int aliases
export type i8  = number
export type i16 = number
export type i32 = number
export type i64 = number
// uint aliases
export type u8  = number
export type u16 = number
export type u32 = number
export type u64 = number
export type Sz  = number

