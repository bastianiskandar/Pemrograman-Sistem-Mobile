import markdown
import os
import subprocess

md_path = r"c:\Users\Advan\OneDrive\Documents\GitHub\Pemrograman-Sistem-Mobile\Pertemuan 7\laporan_praktikum_7.md"
html_path = r"c:\Users\Advan\OneDrive\Documents\GitHub\Pemrograman-Sistem-Mobile\Pertemuan 7\laporan_praktikum_7.html"
pdf_path = r"c:\Users\Advan\OneDrive\Documents\GitHub\Pemrograman-Sistem-Mobile\Pertemuan 7\Praktikum7_3337240088_BastianYusufIskandar.pdf"

with open(md_path, "r", encoding="utf-8") as f:
    text = f.read()

html_body = markdown.markdown(text, extensions=["tables", "fenced_code", "nl2br"])

css = """
  @page {
    size: A4;
    margin: 14mm 15mm 14mm 15mm;
  }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    color: #1e293b;
    line-height: 1.5;
    font-size: 10pt;
    padding: 0;
    margin: 0;
  }
  h1 {
    color: #0f172a;
    font-size: 18pt;
    border-bottom: 2px solid #2563eb;
    padding-bottom: 5px;
    margin-top: 0;
    margin-bottom: 4px;
    text-align: center;
  }
  h2 {
    color: #1d4ed8;
    font-size: 13pt;
    margin-top: 14px;
    margin-bottom: 6px;
    border-bottom: 1px solid #e2e8f0;
    padding-bottom: 3px;
    page-break-after: avoid;
  }
  h3 {
    color: #334155;
    font-size: 11pt;
    margin-top: 10px;
    margin-bottom: 4px;
    page-break-after: avoid;
  }
  p {
    margin-top: 3px;
    margin-bottom: 6px;
    text-align: justify;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0;
    font-size: 8.8pt;
    page-break-inside: avoid;
  }
  th, td {
    border: 1px solid #cbd5e1;
    padding: 6px 8px;
    text-align: left;
    vertical-align: top;
  }
  th {
    background-color: #f1f5f9;
    color: #0f172a;
    font-weight: 600;
  }
  tr:nth-child(even) {
    background-color: #f8fafc;
  }
  pre {
    background-color: #f8fafc;
    border: 1px solid #e2e8f0;
    border-left: 4px solid #2563eb;
    border-radius: 4px;
    padding: 8px 10px;
    font-size: 8pt;
    font-family: "Cascadia Code", "Consolas", "Courier New", monospace;
    overflow-x: auto;
    page-break-inside: avoid;
    line-height: 1.38;
    margin: 6px 0;
  }
  code {
    font-family: "Cascadia Code", "Consolas", "Courier New", monospace;
    font-size: 8.5pt;
    background-color: #f1f5f9;
    padding: 2px 4px;
    border-radius: 3px;
    color: #0f172a;
  }
  pre code {
    background-color: transparent;
    padding: 0;
    color: inherit;
  }
  ul, ol {
    margin-top: 3px;
    margin-bottom: 6px;
    padding-left: 18px;
  }
  li {
    margin-bottom: 3px;
  }
  hr {
    border: none;
    border-top: 1px solid #e2e8f0;
    margin: 12px 0;
  }
"""

full_html = f"""<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<title>Laporan Praktikum 7 - Pemrograman Mobile</title>
<style>
{css}
</style>
</head>
<body>
{html_body}
</body>
</html>
"""

with open(html_path, "w", encoding="utf-8") as f:
    f.write(full_html)

edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
chrome_path = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
browser_exe = edge_path if os.path.exists(edge_path) else chrome_path

cmd = [
    browser_exe,
    "--headless",
    "--disable-gpu",
    f"--print-to-pdf={pdf_path}",
    "--no-pdf-header-footer",
    html_path
]

res = subprocess.run(cmd, capture_output=True, text=True)
print("PDF Generation return code:", res.returncode)
print("PDF size:", os.path.getsize(pdf_path))
