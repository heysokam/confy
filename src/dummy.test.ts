import { describe, expect, it } from 'bun:test'

describe("Dummy", () => {
  it("should add 1+2", () => { expect(1+2).toBe(3) })
  it("should add 3+4", () => { expect(3+4).not.toBe(3) })
}) //:: Dummy

