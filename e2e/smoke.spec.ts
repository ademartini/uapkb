import { test, expect } from "@playwright/test";

test.describe("smoke @smoke", () => {
  test("landing page renders expected content", async ({ page }) => {
    await page.goto("/");
    await expect(page.getByRole("heading", { name: "UAPKB" })).toBeVisible();
    await expect(page.getByText(/AI-first reference repository/i)).toBeVisible();
  });

  test("health endpoint returns dependency status shape", async ({ request }) => {
    const response = await request.get("/healthz");
    await expect(response).toBeOK();
    await expect(response.json()).resolves.toMatchObject({
      status: "ok",
      dependencies: {
        database: {
          status: "not_configured",
        },
      },
    });
  });
});
