#import "invoice.typ";


// Create an invoice with VAT
#let invoice_info = (
  date: "24.05.2025",
  period: (
    begin: "20.05.2025",
    end: "22.05.2025",
  ),
  id: "1",
  due: "14 days",
  vat: 19.0,
  language: "en",
  invoicing_party: toml("contacts.toml").me,
  recipient: toml("contacts.toml").client_a,
  positions: (
    ("Natural Intelligence Consulting", "3 Tage", "1600,00€/day", 4800.0),
    ("Travel allowance", [], [], 600.0),
  ),
)

// Some styling
#set text(font: "JetBrains Mono", size: 10pt)
#set page(footer: invoice.invoice_footer(invoice_info.invoicing_party))

// Create the invoice
#invoice.invoice(invoice_info)

#pagebreak()

// Create an invoice without VAT but with worklog

#import "worklog.typ";

// Load worklog from csv
#let worklog_data = csv("worklog.csv")

#set text(font: "JetBrains Mono", size: 10pt, lang: "de")

#let invoice_info = (
  date: "24.05.2025",
  id: "2",
  due: "14 days",
  period: worklog.worklog_period(worklog_data),
  vat: 0.0,
  invoicing_party: toml("contacts.toml").me,
  recipient: toml("contacts.toml").client_b,
  positions: (
    ("Expensive stuff", "10", "160€ / piece", 1600.0),
    ("Other expenses", [], [], 750.0),
  ),
)

// Create the invoice with work log
#invoice.invoice(invoice_info)

#pagebreak()

// Attach a worklog table to the invoice
#worklog.worklog_table(worklog_data)
