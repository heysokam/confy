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
