// Configuration for allowed tools
// These tools are automatically allowed for all claude commands

export const readOnlyAllowedTools = [
  // Read-only tools
  "Read",
  "Glob",
  "Grep",
  "LS",
  "NotebookRead",
  "WebFetch",
  "WebSearch",
  
  // Read-only bash commands
  "Bash(ls:*)",
  "Bash(cat:*)",
  "Bash(grep:*)",
  "Bash(find:*)",
  "Bash(pwd:*)",
  "Bash(echo:*)",
  "Bash(head:*)",
  "Bash(tail:*)",
  "Bash(wc:*)",
  "Bash(file:*)",
  "Bash(which:*)",
  "Bash(whoami:*)",
  "Bash(date:*)",
  "Bash(env:*)",
  "Bash(printenv:*)",
  "Bash(uname:*)",
  "Bash(hostname:*)",
  "Bash(ps:*)",
  "Bash(tree:*)",
  "Bash(du:*)",
  "Bash(df:*)",
  "Bash(stat:*)",
  "Bash(readlink:*)",
  "Bash(dirname:*)",
  "Bash(basename:*)",
  "Bash(realpath:*)",
  "Bash(git:*)", // git commands are generally read-only (status, log, diff, etc)
];

// Get the final allowed tools based on environment configuration
export function getAllowedTools(userAllowedTools?: string[]): string[] {
  // If user has explicitly allowed all tools, respect that
  if (userAllowedTools?.includes("*")) {
    return ["*"];
  }
  
  // If RISKY_MODE is enabled, allow all tools
  if (Deno.env.get("RISKY_MODE") === "true") {
    return ["*"];
  }
  
  // Otherwise, combine read-only whitelist with any user-specified tools
  const combinedTools = new Set([...readOnlyAllowedTools]);
  
  if (userAllowedTools) {
    userAllowedTools.forEach(tool => combinedTools.add(tool));
  }
  
  return Array.from(combinedTools);
}