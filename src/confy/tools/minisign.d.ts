//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
/**
 * @description Type Declaration file for mlugg/setup-zig/minisign.js
 * */

export default minisign; export declare namespace minisign {
  export type Base64 = string
  export type Key = {
    id   :Buffer<ArrayBufferLike>
    key  :Buffer<ArrayBufferLike>
  }
  export type Signature = {
    algorithm  :Buffer<ArrayBufferLike>
    key_id     :Buffer<ArrayBufferLike>
    signature  :Buffer<ArrayBufferLike>
  }

  /**
   * @description
   * Parse a minisign key represented as a base64 string.
   * @throws Throws exceptions on invalid keys.
   * */
  export function parseKey (key_str :Base64): minisign.Key;

  /**
   * @description
   * Parse a buffer containing the contents of a minisign signature file.
   * @throws Throws exceptions on invalid signature files.
   * */
  export function parseSignature (sig_buf: Buffer<ArrayBufferLike>): minisign.Signature;


  /**
   * @description
   * Verifies the signature of a buffer using a parsed key, a parsed signature file, and a raw file buffer.
   * @throws Nothing. Does not throw.
   * @returns 'true' if the signature is valid for this file, 'false' otherwise.
   * */
  export function verifySignature (
    pubkey       : minisign.Key,
    signature    : minisign.Signature,
    file_content : Buffer<ArrayBufferLike>,
  ) :boolean;
}

