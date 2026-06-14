export function getDatabaseUrl(): string | undefined {
  const value = process.env.DATABASE_URL?.trim();
  return value || undefined;
}

export function getLogLevel(): string {
  return process.env.LOG_LEVEL?.trim() || "info";
}

export function getAppVersion(): string | undefined {
  const value = process.env.APP_VERSION?.trim();
  return value || undefined;
}

export function getAppCommit(): string | undefined {
  const value = process.env.APP_COMMIT?.trim();
  return value || undefined;
}
