/**
 * Generates a pseudo random number between 0 and 1 from a given integer seed by creating chaos using calculations
 * @param {number} seed The seed can be any float greater than 1
 * @returns a pseudo random number between 0 and 1
 */
export function randomFromSeed(seed) {
    let prime1 = 42394160293;
    let prime2 = 12941604139;
    let limitingNumber = 16777215;

    // Limit max seed to prevent lag
    seed %= prime1;

    return ((seed * prime1) % limitingNumber ^ (seed * prime2) % limitingNumber) * prime1 % prime2 / prime2;
}