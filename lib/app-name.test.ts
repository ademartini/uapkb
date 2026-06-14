import { describe, expect, it } from "vitest";
import { APP_NAME, getAppTitle } from "./app-name";

describe("app-name", () => {
  it("exports the application name", () => {
    expect(APP_NAME).toBe("UAPKB");
    expect(getAppTitle()).toBe("UAPKB");
  });
});
