import { useState, useCallback, useEffect } from "react";

interface PermissionDialog {
  isOpen: boolean;
  toolName: string;
  pattern: string;
  toolUseId: string;
}

// Check if risky mode is enabled via environment variable
const isRiskyMode = import.meta.env.VITE_RISKY_MODE === "true";

export function usePermissions() {
  const [allowedTools, setAllowedTools] = useState<string[]>([]);
  const [permissionDialog, setPermissionDialog] =
    useState<PermissionDialog | null>(null);

  // In risky mode, automatically allow all tools
  useEffect(() => {
    if (isRiskyMode) {
      // Set a wildcard pattern that allows everything
      setAllowedTools(["*"]);
    }
  }, []);

  const showPermissionDialog = useCallback(
    (toolName: string, pattern: string, toolUseId: string) => {
      // In risky mode, never show permission dialogs
      if (isRiskyMode) {
        console.warn(
          `🚨 RISKY MODE: Auto-approving tool ${toolName} with pattern ${pattern}`,
        );
        return;
      }

      setPermissionDialog({
        isOpen: true,
        toolName,
        pattern,
        toolUseId,
      });
    },
    [],
  );

  const closePermissionDialog = useCallback(() => {
    setPermissionDialog(null);
  }, []);

  const allowToolTemporary = useCallback(
    (pattern: string) => {
      // In risky mode, everything is already allowed
      if (isRiskyMode) return ["*"];
      return [...allowedTools, pattern];
    },
    [allowedTools],
  );

  const allowToolPermanent = useCallback(
    (pattern: string) => {
      // In risky mode, everything is already allowed
      if (isRiskyMode) return ["*"];
      const updatedAllowedTools = [...allowedTools, pattern];
      setAllowedTools(updatedAllowedTools);
      return updatedAllowedTools;
    },
    [allowedTools],
  );

  const resetPermissions = useCallback(() => {
    // In risky mode, keep wildcard permission
    if (isRiskyMode) {
      setAllowedTools(["*"]);
    } else {
      setAllowedTools([]);
    }
  }, []);

  return {
    allowedTools,
    permissionDialog,
    showPermissionDialog,
    closePermissionDialog,
    allowToolTemporary,
    allowToolPermanent,
    resetPermissions,
    isRiskyMode, // Export this so UI can show warnings
  };
}
