//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________

export default Shuffle; export namespace Shuffle {
  /**
   * @description Shuffles the given {@param arr} using the Knuth / FisherYates algorithm
   * @link https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
   * */
  export function FisherYates <T>(arr :T[]) :T[] {
    const withRandom = arr.map((val :T) => [val, Math.random()])                       // Transform into [[val1, rand], [val2, rand], ..]
    const sorted     = withRandom.sort((A,B) => (A[1] as number) - (B[1] as number));  // Sort ascending by the random number
    return sorted.map(a => a[0] as T);                                                 // Extract the values back into a flat array
  }
}

