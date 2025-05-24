#import "@preview/invoist:0.1.0" as invoist

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
  invoicing_party: toml("contacts.toml").me,
  recipient: toml("contacts.toml").client_a,
  positions: (
    ("Natural Intelligence Consulting", "3 Tage", "1600,00€/day", 4800.0),
    ("Travel allowance", [], [], 600.0),
  ),
)

// Some styling
#set text(font: "JetBrains Mono", size: 10pt)
#set page(footer: invoist.invoice_footer(invoice_info.invoicing_party))

// Create the invoice
#invoist.invoice(invoice_info)
