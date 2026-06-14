import { NextResponse } from "next/server";
import { buildHealthResponse } from "@/lib/health";
import { getAppCommit, getAppVersion, getDatabaseUrl } from "@/lib/env";
import { logger } from "@/lib/logger";

export const dynamic = "force-dynamic";

export async function GET() {
  const health = buildHealthResponse({
    version: getAppVersion(),
    commit: getAppCommit(),
    databaseUrl: getDatabaseUrl(),
  });

  logger.info({ route: "/healthz", status: health.status }, "health check");

  return NextResponse.json(health);
}
