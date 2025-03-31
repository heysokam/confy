//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps tests
import { describe, expect, it, spyOn } from 'bun:test'
// @deps version
import { Version, version } from './version'


describe("Version", () => {
  it("should return a 0.0.0 version when `@param M` is null", () => {
    expect(new Version(null)).toEqual({major:0, minor:0, patch:0, tag:null, build:null})
  })

  it("should call version.parse when `@param M` is a string", () => {
    const result = spyOn(version, 'parse')
    expect(result).not.toHaveBeenCalled()
    const M = "4.5.6"
    new Version(M,2,3)
    expect(result).toHaveBeenCalled()
    result.mockClear()
  })

  it("should call version.from when `@param M` is a number", () => {
    const result = spyOn(version, 'from')
    expect(result).not.toHaveBeenCalled()
    const M = 1
    new Version(M,2,3)
    expect(result).toHaveBeenCalled()
    result.mockClear()
  })

  it("should call version.from when `@param M` is an object", () => {
    const result = spyOn(version, 'from')
    expect(result).not.toHaveBeenCalled()
    const M = new Version(4,5,6)
    new Version(M,2,3)
    expect(result).toHaveBeenCalled()
    result.mockClear()
  })

  it.each(version.Specification.Valid)("should return the expected value when calling the toString method :: %s", (...entry) => {
    const Expected = entry[0] as string
    const vers :Version= version.from(entry[1] as number, entry[2] as number, entry[3] as number, entry[4] as string|null, entry[5] as string|null)
    const result = vers.toString()
    expect(result).toBe(Expected)
  })
}) //:: Version


describe("version.parse", () => {
  describe("simple case", () => {
    const simple :Version= version.parse("1.2.3")
    it("should parse the major field as expected", () => { expect(simple.major).toBe(   1) })
    it("should parse the minor field as expected", () => { expect(simple.minor).toBe(   2) })
    it("should parse the patch field as expected", () => { expect(simple.patch).toBe(   3) })
    it("should parse the tag   field as expected", () => { expect(simple.tag  ).toBe(null) })
    it("should parse the build field as expected", () => { expect(simple.build).toBe(null) })
  })

  describe.each(version.Specification.Invalid)("Invalid cases :: %s", (entry) => {
    it("should error when parsing", () => { expect(() => version.parse(entry)).toThrowError() })
  })

  describe.each(version.Specification.Valid)("complex cases :: %s", (...entry) => {
    const simple :Version= version.parse(entry[0] as string)
    it("should parse the major field as expected", () => { expect(simple.major).toBe(entry[1] as number) })
    it("should parse the minor field as expected", () => { expect(simple.minor).toBe(entry[2] as number) })
    it("should parse the patch field as expected", () => { expect(simple.patch).toBe(entry[3] as number) })
    it("should parse the tag   field as expected", () => { expect(simple.tag  ).toBe(entry[4] as string|null  ) })
    it("should parse the build field as expected", () => { expect(simple.build).toBe(entry[5] as string|null) })
  })
})

describe("version.from", () => {
  const M = 42
  const m = 21
  const p = 10
  const t = "alpha"
  const b = "dev.1234"
  const result :Version= version.from(M,m,p,t,b)
  it("should assign `@param M` to the `.major` field of the result",        () => { expect(result.major).toBe(M) })
  it("should assign `@param m` to the `.minor` field of the result",        () => { expect(result.minor).toBe(m) })
  it("should assign `@param p` to the `.patch` field of the result",        () => { expect(result.patch).toBe(p) })
  it("should assign `@param t` to the `.tag`   field of the result",        () => { expect(result.tag  ).toBe(t) })
  it("should assign `@param b` to the `.build` field of the result",        () => { expect(result.build).toBe(b) })
  it("should assign null to the `.tag`   field of the result when omitted", () => { expect(version.from(1,2,3).tag  ).toBe(null) })
  it("should assign null to the `.build` field of the result when omitted", () => { expect(version.from(1,2,3).build).toBe(null) })
})

