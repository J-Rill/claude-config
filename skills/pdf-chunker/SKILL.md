---
name: pdf-chunker
description: MANDATORY for any task involving reading, analyzing, summarizing, reviewing, or extracting content from a PDF file. Triggers on any PDF input regardless of size. This skill replaces the default PDF reading behavior with a reliable chunked extraction method.
---

# PDF Chunker

**MANDATORY FIRST STEP FOR ANY PDF**: Run the extraction script BEFORE attempting to read or analyze PDF content. Do not skip this step. Do not try to read the PDF directly.

```bash
python <skill_path>/scripts/extract_pdf.py <pdf_path> --output /tmp/extracted.txt
```

Then read `/tmp/extracted.txt` for all subsequent analysis.

This applies to ALL PDFs — small or large. Never attempt to load a PDF into context by any other method.
