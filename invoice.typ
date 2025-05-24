

// Dictionary for translations
#let dict = (
  de: (
    invoice: "Rechnung",
    period: "Leistungszeitraum",
    date: "Datum",
    invoice_number: "Rechnungsnummer",
    invoice_due: "Zahlungsziel",
    salutation: "Sehr geehrte Damen und Herren,",
    declaration: "vereinbarungsgemäß berechne ich für meine Leistungen wie folgt:",
    position_name: "Bezeichnung",
    position_amount: "Anzahl",
    position_price: "Price",
    position_net: "Netto",
    vat: "Mehrwertsteuer",
    vat_note: "N",
    subtotal: "Zwischensumme",
    total: "Gesamtsumme",
    payment_instruction: "Zahlbar 14 Tage nach Erhalt per Überweisung unter Angabe der Rechnungsnummer als Verwendungszweck auf das folgende Konto:",
    account_holder: "Kontoinhaber",
    iban: "IBAN",
    bic: "BIC",
    thank_you: "Ich bedanke mich für Ihren Auftrag und freue mich auf die weitere Zusammenarbeit.",
    closing: "Mit freundlichen Grüßen",
    worklog: "Stundenzettel",
    worklog_hours: "Stunden",
    worklog_total_hours: "Gesamtstunden",
    worklog_description: "Beschreibung",
  ),
  en: (
    invoice: "Invoice",
    period: "Performance period",
    date: "Date",
    invoice_number: "Invoice number",
    invoice_due: "Time for payment",
    salutation: "Dear ladies and gentlemen,",
    declaration: "As agreed, I charge for my services as follows:",
    position_name: "Name",
    position_amount: "Amount",
    position_price: "Price",
    position_net: "Net",
    vat: "VAT",
    vat_note: "The tax liability is transferred to the recipient of the service according to § 13b of the German VAT Act (UStG).
The VAT is to be paid by the recipient of the service.",
    subtotal: "Sub-total",
    total: "Total",
    payment_instruction: "Payable 14 days after receipt by bank transfer, stating the invoice number as note to payee, to the following account:",
    account_holder: "Account holder",
    iban: "IBAN",
    bic: "BIC",
    thank_you: "Thank you for your order and I look forward to further cooperation.",
    closing: "Best regards",
    worklog: "Work log",
    worklog_hours: "Hours",
    worklog_total_hours: "Total hours",
    worklog_description: "Description",
  ),
)

// Translate function
#let tr(lang, text) = dict.at(lang).at(text)

#let display-amount(amount) = {
  if amount == none {
    return none
  }

  let a = amount * 100
  let wholes = int(calc.abs(a) / 100)
  let cents = calc.abs(a) - (wholes * 100)
  let sign = if a < 0 { "-" } else { "" }

  if cents >= 10 {
    return sign + str(wholes) + "," + str(cents) + "€"
  } else {
    return sign + str(wholes) + ",0" + str(cents) + " €"
  }
}

#let address_details(recipient) = block(width: 12cm)[
  #recipient.name \
  #if recipient.keys().contains("contact_name") [
    #recipient.contact_name \
  ]
  #recipient.street \
  #recipient.zip #recipient.city \
  #if recipient.keys().contains("country") [
    #recipient.country
  ]
]

#let invoice_details(invoice_info) = place(top + left, dx: 10cm)[
  #let t(text) = tr(invoice_info.language, text);
  #let invoicing_party = invoice_info.invoicing_party;

  #invoicing_party.name \
  #invoicing_party.street \
  #invoicing_party.zip #invoicing_party.city \
  #invoicing_party.phone \
  #link(invoicing_party.website) \
  #link(invoicing_party.email) \
  \
  #block(width: 6cm)[
    *#t("date")*: #h(1fr) #invoice_info.date \
    *#t("invoice_number")*: #h(1fr) #invoice_info.id \
    *#t("invoice_due")*: #h(1fr) #invoice_info.due \
  ]
]

#let invoice_account_details(invoice_info) = align(center)[#block(width: 9cm, inset: 0.5cm)[
    #let t(text) = tr(invoice_info.language, text)
    #let invoicing_party = invoice_info.invoicing_party;

    #par(justify: true)[
      #t("account_holder"): #h(1fr) *#invoicing_party.name*\
      #t("iban"): #h(1fr) *#invoicing_party.iban* \
      #t("bic"): #h(1fr) *#invoicing_party.bic*
    ]
  ]
]

#let invoice_positions(invoice_info) = [
  #let positions = invoice_info.positions;

  #show table.cell.where(y: 0): strong
  #set table(
    stroke: (x, y) => if y == 0 or y == positions.len() or y == positions.len() + 3 {
      (bottom: 0.7pt + black)
    },
    align: (x, y) => (
      if x > 1 { right } else { left }
    ),
  )

  #let sum = positions.map(p => p.at(3)).sum()
  #let t(text) = tr(invoice_info.language, text)

  #table(
    columns: (0.6cm, 8.0cm, 2cm, 3.0cm, 2.5cm),
    table.header(
      [\#],
      [#t("position_name")],
      [#t("position_amount")],
      [#t("position_price")],
      [#t("position_net")],
    ),
    ..positions
      .map(p => (
        {
          let position_counter = counter("position")
          position_counter.step()
          [#context position_counter.display()]
        },
        p.at(0),
        p.at(1),
        p.at(2),
        [#display-amount(p.at(3))],
      ))
      .flatten(),
    table.cell(colspan: 4)[*#t("subtotal"):*], [#display-amount(sum)],
    [], [], [], [], [],
    table.cell(colspan: 2)[*#t("vat"):*], [#invoice_info.vat %], [], [#display-amount(invoice_info.vat / 100.0 * sum)],
    table.cell(colspan: 4)[*#t("total"):*], [*#display-amount((100.0 + invoice_info.vat) / 100.0 * sum)*]
  )
]

#let invoice_positions_no_tax(invoice_info) = [
  #let positions = invoice_info.positions;

  #set table(
    stroke: (x, y) => if y == 0 or y == positions.len() or y == positions.len() + 3 {
      (bottom: 0.7pt + black)
    },
    align: (x, y) => (
      if x > 1 { right } else { left }
    ),
  )

  #let sum = positions.map(p => p.at(3)).sum()
  #let t(text) = tr(invoice_info.language, text)

  #table(
    columns: (0.6cm, 8.0cm, 2cm, 3.0cm, 2.5cm),
    table.header(
      [\#],
      [#t("position_name")],
      [#t("position_amount")],
      [#t("position_price")],
      [#t("position_net")],
    ),
    ..positions
      .map(p => (
        {
          let position_counter = counter("position")
          position_counter.step()
          [#context position_counter.display()]
        },
        p.at(0),
        p.at(1),
        p.at(2),
        [#display-amount(p.at(3))],
      ))
      .flatten(),
    table.cell(colspan: 4)[*#t("total"):*], [*#display-amount(sum)*]
  )
]

#let invoice_header() = context [
  #align(right)[
    #let count = counter(page).final().last();
    #if count > 1 {
      counter(page).display()
    }
  ]
]


#let invoice_footer(invoicing_party) = [
  #align(center)[#text(7.5pt)[
      #invoicing_party.name #sym.dot.c #invoicing_party.street #sym.dot.c #invoicing_party.zip #invoicing_party.city #sym.dot.c #invoicing_party.phone #sym.dot.c #invoicing_party.email
    ]]
]


#let invoice_page_style(invoice_info) = [
  #set text(font: "JetBrains Mono", size: 10pt)
  #show link: underline

  #set page(
    paper: "a4",
    footer: invoice_footer(invoice_info.invoicing_party),
  )
]

#let invoice(invoice_info) = [
  #let t(text) = tr(invoice_info.language, text)
  #show link: underline

  #address_details(invoice_info.recipient)

  #block(height: 3.5cm)

  = #t("invoice") #invoice_info.id

  #if invoice_info.keys().contains("period") [
    #let period = invoice_info.period;
    #if period.keys().contains("end") [
      === #t("period") #period.begin -- #period.end
    ] else [
      === #t("period") #period.begin
    ]
  ]

  #invoice_details(invoice_info)

  #block(height: 1cm)

  #t("salutation")

  #t("declaration")

  #block()

  #if invoice_info.vat > 0.0 {
    invoice_positions(invoice_info)
  } else {
    invoice_positions_no_tax(invoice_info)
  }

  #block()

  #if invoice_info.vat <= 0.0 {
    t("vat_note")
    block()
  }

  #t("payment_instruction")

  #invoice_account_details(invoice_info)

  #t("thank_you")

  #block(height: 0.5cm)

  #t("closing")

  #block(height: 0cm)

  #invoice_info.invoicing_party.name
]


// Return period with begin and end from worklog
#let period_from_worklog(worklog) = {
  let first = worklog.first().at(0).split(" ").at(0)
  let last = worklog.last().at(0).split(" ").at(0)
  if first == last {
    (
      begin: first,
    )
  } else {
    (
      begin: first,
      end: last,
    )
  }
}

#let worklog(worklog, language) = [
  #show link: underline

  #let t(text) = tr(language, text)
  #set table(
    stroke: (x, y) => if y == 0 or y == worklog.len() {
      (bottom: 0.7pt + black)
    },
  )

  #let period = period_from_worklog(worklog)
  #let sum = worklog.map(p => decimal(p.at(1))).sum()

  #if period.keys().contains("end") [
    = #t("worklog") #period.begin -- #period.end
  ] else [
    = #t("worklog") #period.begin
  ]

  #block()

  #table(
    columns: (4.0cm, 2.0cm, 11.0cm),
    table.header(
      [#t("date")],
      [#t("worklog_hours")],
      [#t("worklog_description")],
    ),
    ..worklog
      .map(p => (
        p.at(0),
        p.at(1),
        p.at(3),
      ))
      .flatten(),
    table.cell()[*#t("worklog_total_hours"):*], [*#sum*]
  )
]
