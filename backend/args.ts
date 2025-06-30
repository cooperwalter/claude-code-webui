import { Command } from "@cliffy/command";

export interface ParsedArgs {
  debug: boolean;
  port: number;
  host: string;
}

export async function parseCliArgs(): Promise<ParsedArgs> {
  // Read version from VERSION file
  let version = "unknown";
  try {
    // Try to read VERSION file from the file system first
    const versionPath = import.meta.dirname + "/VERSION";
    const versionContent = await Deno.readTextFile(versionPath);
    version = versionContent.trim();
  } catch {
    // If that fails (e.g., in compiled binary), use a fallback
    // In production builds, the version should be updated in the package.json
    version = "1.2.0"; // This should match package.json version
  }

  const { options } = await new Command()
    .name("claude-code-webui")
    .version(version)
    .description("Claude Code Web UI Backend Server")
    .option("-p, --port <port:number>", "Port to listen on", {
      default: parseInt(Deno.env.get("PORT") || "8999", 10),
    })
    .option(
      "--host <host:string>",
      "Host address to bind to (use 0.0.0.0 for all interfaces)",
      {
        default: "127.0.0.1",
      },
    )
    .option("-d, --debug", "Enable debug mode")
    .env("DEBUG=<enable:boolean>", "Enable debug mode")
    .parse(Deno.args);

  return {
    debug: options.debug || false,
    port: options.port,
    host: options.host,
  };
}
