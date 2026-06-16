import { describe, expect, it } from "vitest";
import { buildHealthResponse, resolveBuildMetadata } from "./health";

describe("buildHealthResponse", () => {
  it("returns healthy status when DATABASE_URL is unset", () => {
    const response = buildHealthResponse();

    expect(response).toMatchObject({
      status: "ok",
      dependencies: {
        database: {
          name: "database",
          status: "not_configured",
        },
      },
    });
  });

  it("includes placeholder build metadata when env vars are unset", () => {
    const response = buildHealthResponse();

    expect(response.version).toBe("dev");
    expect(response.commit).toBe("unknown");
  });

  it("uses provided build metadata", () => {
    const response = buildHealthResponse({
      version: "1.2.3",
      commit: "abc123",
      databaseUrl: "postgres://example",
    });

    expect(response).toMatchObject({
      status: "ok",
      version: "1.2.3",
      commit: "abc123",
      dependencies: {
        database: { status: "not_configured" },
      },
    });
  });
});

describe("resolveBuildMetadata", () => {
  it("never returns undefined fields", () => {
    expect(resolveBuildMetadata({})).toEqual({
      version: "dev",
      commit: "unknown",
    });
  });
});
