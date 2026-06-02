/*
 * IDE shims when node_modules lives in the Docker volume (see docker-compose.override.yml).
 * Full typecheck: docker compose exec -T web yarn check:ts
 */

declare function describe(name: string, fn: () => void): void
declare function it(name: string, fn: () => void): void
declare function beforeEach(fn: () => void): void
declare function afterEach(fn: () => void): void
declare const expect: {
  (actual: unknown): {
    toBe(expected: unknown): void
    toEqual(expected: unknown): void
    toBeFalsy(): void
    toBeTruthy(): void
  }
}
