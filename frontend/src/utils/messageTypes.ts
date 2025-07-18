import type { SDKMessage } from "../types";

// Type guard functions for SDKMessage
export function isSystemMessage(
  data: SDKMessage,
): data is Extract<SDKMessage, { type: "system" }> {
  return data.type === "system";
}

export function isAssistantMessage(
  data: SDKMessage,
): data is Extract<SDKMessage, { type: "assistant" }> {
  return data.type === "assistant";
}

export function isResultMessage(
  data: SDKMessage,
): data is Extract<SDKMessage, { type: "result" }> {
  return data.type === "result";
}

export function isUserMessage(
  data: SDKMessage,
): data is Extract<SDKMessage, { type: "user" }> {
  return data.type === "user";
}

// Helper function to check if tool_result contains permission error
export function isPermissionError(content: string): boolean {
  return (
    content.includes("requested permissions") ||
    content.includes("haven't granted it yet") ||
    content.includes("permission denied")
  );
}
