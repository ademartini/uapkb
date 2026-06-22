import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import Home from "@/app/page";

describe("Home", () => {
  it("renders the UAPKB heading", () => {
    render(<Home />);
    expect(screen.getByRole("heading", { level: 1, name: "UAPKB" })).toBeInTheDocument();
  });

  it("renders the tagline", () => {
    render(<Home />);
    expect(screen.getByText(/AI-first reference repository/i)).toBeInTheDocument();
  });

  it("renders a non-functional green button", () => {
    render(<Home />);
    expect(screen.getByRole("button", { name: "Do nothing" })).toBeInTheDocument();
  });
});
