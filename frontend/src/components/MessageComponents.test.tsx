import { render, screen } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import { ChatMessageComponent } from "./MessageComponents";
import type { ChatMessage } from "../types";

// Mock the MarkdownRenderer component
vi.mock("./messages/MarkdownRenderer", () => ({
  MarkdownRenderer: ({
    content,
    className,
  }: {
    content: string;
    className?: string;
  }) => (
    <div data-testid="markdown-renderer" className={className}>
      {content}
    </div>
  ),
}));

describe("ChatMessageComponent", () => {
  const baseMessage: ChatMessage = {
    type: "chat",
    role: "assistant",
    content: "Test message content",
    timestamp: Date.now(),
  };

  it("renders user messages with plain text", () => {
    const userMessage: ChatMessage = {
      ...baseMessage,
      role: "user",
    };

    render(<ChatMessageComponent message={userMessage} />);

    expect(screen.getByText("User")).toBeInTheDocument();
    expect(screen.getByText("Test message content")).toBeInTheDocument();
    // Should use pre tag for user messages
    const preElement = screen.getByText("Test message content").closest("pre");
    expect(preElement).toBeInTheDocument();
    expect(preElement).toHaveClass(
      "whitespace-pre-wrap",
      "text-sm",
      "font-mono",
    );
  });

  it("renders assistant messages with markdown renderer", () => {
    render(<ChatMessageComponent message={baseMessage} />);

    expect(screen.getByText("Claude")).toBeInTheDocument();
    // Should use MarkdownRenderer for assistant messages
    const markdownRenderer = screen.getByTestId("markdown-renderer");
    expect(markdownRenderer).toBeInTheDocument();
    expect(markdownRenderer).toHaveTextContent("Test message content");
    expect(markdownRenderer).toHaveClass("text-sm", "leading-relaxed");
  });

  it("renders markdown content correctly", () => {
    const markdownMessage: ChatMessage = {
      ...baseMessage,
      content:
        "# Heading\n\nThis is **bold** text and *italic* text.\n\n```javascript\nconst x = 42;\n```",
    };

    render(<ChatMessageComponent message={markdownMessage} />);

    const markdownRenderer = screen.getByTestId("markdown-renderer");
    expect(markdownRenderer).toHaveTextContent("# Heading");
    expect(markdownRenderer).toHaveTextContent(
      "This is **bold** text and *italic* text.",
    );
    expect(markdownRenderer).toHaveTextContent("const x = 42;");
  });

  it("applies correct styling based on message role", () => {
    const { rerender } = render(<ChatMessageComponent message={baseMessage} />);

    // Assistant message should have gray background
    let container = screen.getByText("Claude").closest(".bg-slate-200");
    expect(container).toBeInTheDocument();

    // User message should have blue background
    const userMessage: ChatMessage = {
      ...baseMessage,
      role: "user",
    };
    rerender(<ChatMessageComponent message={userMessage} />);
    container = screen.getByText("User").closest(".bg-blue-600");
    expect(container).toBeInTheDocument();
  });

  it("displays timestamp for messages", () => {
    render(<ChatMessageComponent message={baseMessage} />);

    // The timestamp component should be rendered
    const timestampElement = document.querySelector(".text-xs.opacity-70");
    expect(timestampElement).toBeInTheDocument();
  });
});
