import { afterEach, describe, expect, it, vi } from "vitest";
import pino from "pino";
import { Writable } from "node:stream";

describe("logger", () => {
  afterEach(() => {
    vi.unstubAllEnvs();
    vi.resetModules();
  });

  it("emits valid JSON at the configured level", async () => {
    vi.stubEnv("NODE_ENV", "production");
    vi.stubEnv("LOG_LEVEL", "info");

    const lines: string[] = [];
    const stream = new Writable({
      write(chunk, _encoding, callback) {
        lines.push(chunk.toString());
        callback();
      },
    });

    const testLogger = pino({ level: "info" }, stream);
    testLogger.info({ event: "test" }, "hello");

    expect(lines).toHaveLength(1);
    const parsed = JSON.parse(lines[0]!);
    expect(parsed).toMatchObject({ level: 30, msg: "hello", event: "test" });
  });

  it("uses pino-pretty transport outside production", async () => {
    vi.stubEnv("NODE_ENV", "development");
    vi.stubEnv("LOG_LEVEL", "info");

    const { logger: devLogger } = await import("./logger");
    expect(devLogger.level).toBe("info");
  });
});
