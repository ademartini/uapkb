export type DependencyStatus = "ok" | "error" | "not_configured";

export interface DependencyHealth {
  name: string;
  status: DependencyStatus;
}

export type OverallStatus = "ok" | "degraded" | "error";

export interface HealthResponse {
  status: OverallStatus;
  version: string;
  commit: string;
  dependencies: {
    database: DependencyHealth;
  };
}

export interface HealthInput {
  version?: string;
  commit?: string;
  databaseUrl?: string;
}

const PLACEHOLDER_VERSION = "dev";
const PLACEHOLDER_COMMIT = "unknown";

export function resolveBuildMetadata(input: Pick<HealthInput, "version" | "commit">): {
  version: string;
  commit: string;
} {
  return {
    version: input.version?.trim() || PLACEHOLDER_VERSION,
    commit: input.commit?.trim() || PLACEHOLDER_COMMIT,
  };
}

export function resolveDatabaseStatus(databaseUrl?: string): DependencyStatus {
  if (!databaseUrl?.trim()) {
    return "not_configured";
  }

  // Connectivity check deferred until Neon is provisioned.
  return "not_configured";
}

export function buildHealthResponse(input: HealthInput = {}): HealthResponse {
  const { version, commit } = resolveBuildMetadata(input);
  const databaseStatus = resolveDatabaseStatus(input.databaseUrl);

  return {
    status: "ok",
    version,
    commit,
    dependencies: {
      database: {
        name: "database",
        status: databaseStatus,
      },
    },
  };
}
