import pino from "pino";
import { getLogLevel } from "./env";

function createLogger() {
  const level = getLogLevel();

  if (process.env.NODE_ENV !== "production") {
    return pino({
      level,
      transport: {
        target: "pino-pretty",
        options: {
          colorize: true,
          singleLine: true,
        },
      },
    });
  }

  return pino({ level });
}

export const logger = createLogger();
