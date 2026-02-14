import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { describe, expect, it } from "vitest";

const repoRoot = resolve(fileURLToPath(new URL(".", import.meta.url)), "..");

describe("Dockerfile LoongArch support", () => {
  it("includes LoongArch architecture detection", async () => {
    const dockerfile = await readFile(
      resolve(repoRoot, "Dockerfile"),
      "utf8",
    );

    // Check for LoongArch-specific conditions
    expect(dockerfile).toContain("loong64");
    expect(dockerfile).toContain("TARGETARCH");

    // Verify LoongArch-specific build dependencies
    expect(dockerfile).toContain("python3 make g++ pkg-config");

    // Check for conditional Bun installation that skips LoongArch
    expect(dockerfile).toContain('if [ "$ARCH" != "loong64" ]');

    // Verify graceful handling of optional dependencies
    expect(dockerfile).toContain("--no-optional");

    // Check updated comment mentions LoongArch
    expect(dockerfile).toContain("LoongArch");
  });

  it("maintains backward compatibility for existing architectures", async () => {
    const dockerfile = await readFile(
      resolve(repoRoot, "Dockerfile"),
      "utf8",
    );

    // Ensure original functionality is preserved
    expect(dockerfile).toContain("FROM node:22-bookworm");
    expect(dockerfile).toContain("RUN pnpm build");
    expect(dockerfile).toContain("USER node");
    expect(dockerfile).toContain("CMD");
  });

  it("includes proper fallback for Bun installation", async () => {
    const dockerfile = await readFile(
      resolve(repoRoot, "Dockerfile"),
      "utf8",
    );

    // Check for echo message when Bun is not available
    expect(dockerfile).toContain(
      "Bun not available on LoongArch, will use Node for all operations",
    );
  });
});
