import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import { MarkdownRenderer } from "./MarkdownRenderer";

describe("MarkdownRenderer", () => {
  it("renders plain text", () => {
    render(<MarkdownRenderer content="This is plain text" />);
    expect(screen.getByText("This is plain text")).toBeInTheDocument();
  });

  it("renders headings", () => {
    const content = `# Heading 1
## Heading 2
### Heading 3
#### Heading 4`;

    render(<MarkdownRenderer content={content} />);

    const h1 = screen.getByRole("heading", { level: 1 });
    expect(h1).toHaveTextContent("Heading 1");
    expect(h1).toHaveClass("text-2xl", "font-bold");

    const h2 = screen.getByRole("heading", { level: 2 });
    expect(h2).toHaveTextContent("Heading 2");
    expect(h2).toHaveClass("text-xl", "font-bold");

    const h3 = screen.getByRole("heading", { level: 3 });
    expect(h3).toHaveTextContent("Heading 3");
    expect(h3).toHaveClass("text-lg", "font-bold");

    const h4 = screen.getByRole("heading", { level: 4 });
    expect(h4).toHaveTextContent("Heading 4");
    expect(h4).toHaveClass("text-base", "font-bold");
  });

  it("renders bold and italic text", () => {
    const content = "This is **bold** and this is *italic*";
    render(<MarkdownRenderer content={content} />);

    const boldText = screen.getByText("bold");
    expect(boldText.tagName).toBe("STRONG");
    expect(boldText).toHaveClass("font-semibold");

    const italicText = screen.getByText("italic");
    expect(italicText.tagName).toBe("EM");
    expect(italicText).toHaveClass("italic");
  });

  it("renders inline code", () => {
    const content = "This is `inline code` in a sentence";
    render(<MarkdownRenderer content={content} />);

    const codeElement = screen.getByText("inline code");
    expect(codeElement.tagName).toBe("CODE");
    expect(codeElement).toHaveClass(
      "bg-slate-200",
      "dark:bg-slate-700",
      "px-1",
      "py-0.5",
      "rounded",
      "text-sm",
      "font-mono",
    );
  });

  it("renders code blocks", () => {
    const content = `\`\`\`javascript
const x = 42;
console.log(x);
\`\`\``;

    render(<MarkdownRenderer content={content} />);

    const codeBlock = screen.getByText(/const x = 42;/);
    expect(codeBlock.closest("pre")).toBeInTheDocument();
    expect(codeBlock.closest("pre")).toHaveClass(
      "overflow-x-auto",
      "rounded-md",
      "bg-slate-900",
      "p-4",
    );
    expect(codeBlock).toHaveClass("text-sm", "font-mono", "text-slate-100");
  });

  it("renders unordered lists", () => {
    const content = `- Item 1
- Item 2
- Item 3`;

    render(<MarkdownRenderer content={content} />);

    const list = screen.getByRole("list");
    expect(list).toHaveClass("list-disc", "list-inside", "mb-2", "space-y-1");

    const listItems = screen.getAllByRole("listitem");
    expect(listItems).toHaveLength(3);
    expect(listItems[0]).toHaveTextContent("Item 1");
    expect(listItems[0]).toHaveClass("ml-4");
  });

  it("renders ordered lists", () => {
    const content = `1. First item
2. Second item
3. Third item`;

    render(<MarkdownRenderer content={content} />);

    const list = screen.getByRole("list");
    expect(list).toHaveClass(
      "list-decimal",
      "list-inside",
      "mb-2",
      "space-y-1",
    );

    const listItems = screen.getAllByRole("listitem");
    expect(listItems).toHaveLength(3);
  });

  it("renders links", () => {
    const content = "Check out [this link](https://example.com)";
    render(<MarkdownRenderer content={content} />);

    const link = screen.getByRole("link", { name: "this link" });
    expect(link).toHaveAttribute("href", "https://example.com");
    expect(link).toHaveAttribute("target", "_blank");
    expect(link).toHaveAttribute("rel", "noopener noreferrer");
    expect(link).toHaveClass(
      "text-blue-600",
      "dark:text-blue-400",
      "hover:underline",
    );
  });

  it("renders blockquotes", () => {
    const content = "> This is a blockquote";
    render(<MarkdownRenderer content={content} />);

    const blockquote = screen
      .getByText("This is a blockquote")
      .closest("blockquote");
    expect(blockquote).toBeInTheDocument();
    expect(blockquote).toHaveClass(
      "border-l-4",
      "border-slate-400",
      "dark:border-slate-600",
      "pl-4",
      "italic",
    );
  });

  it("renders tables", () => {
    const content = `| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
| Cell 3   | Cell 4   |`;

    render(<MarkdownRenderer content={content} />);

    const table = screen.getByRole("table");
    expect(table).toHaveClass("min-w-full", "border-collapse");

    const headers = screen.getAllByRole("columnheader");
    expect(headers).toHaveLength(2);
    expect(headers[0]).toHaveTextContent("Header 1");
    expect(headers[0]).toHaveClass(
      "border",
      "border-slate-300",
      "dark:border-slate-600",
      "px-4",
      "py-2",
    );

    const cells = screen.getAllByRole("cell");
    expect(cells).toHaveLength(4);
  });

  it("renders horizontal rules", () => {
    const content = `Text before

---

Text after`;

    render(<MarkdownRenderer content={content} />);

    const hr = document.querySelector("hr");
    expect(hr).toBeInTheDocument();
    expect(hr).toHaveClass("my-4", "border-slate-300", "dark:border-slate-600");
  });

  it("applies custom className", () => {
    render(<MarkdownRenderer content="Test" className="custom-class" />);

    const container = document.querySelector(".markdown-content");
    expect(container).toHaveClass("custom-class");
  });

  it("supports GitHub Flavored Markdown", () => {
    const content = `~~strikethrough~~
- [x] Checked item
- [ ] Unchecked item`;

    render(<MarkdownRenderer content={content} />);

    // GFM should render strikethrough
    const strikethrough = screen.getByText("strikethrough");
    expect(strikethrough.tagName).toBe("DEL");

    // Task lists should be rendered
    const listItems = screen.getAllByRole("listitem");
    expect(listItems[0]).toHaveTextContent("Checked item");
    expect(listItems[1]).toHaveTextContent("Unchecked item");
  });
});
