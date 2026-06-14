import { describe, expect, it, vi, beforeEach, afterEach } from "vitest";
import { GET } from "@/app/healthz/route";

describe("GET /healthz", () => {
  beforeEach(() => {
    vi.stubEnv("DATABASE_URL", "");
    vi.stubEnv("APP_VERSION", "");
    vi.stubEnv("APP_COMMIT", "");
  });

  afterEach(() => {
    vi.unstubAllEnvs();
  });

  it("returns 200 with dependency status shape when DATABASE_URL is unset", async () => {
    const response = await GET();
    const body = await response.json();

    expect(response.status).toBe(200);
    expect(body).toMatchObject({
      status: "ok",
      version: "dev",
      commit: "unknown",
      dependencies: {
        database: {
          name: "database",
          status: "not_configured",
        },
      },
    });
  });
});
