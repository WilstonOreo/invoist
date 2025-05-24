

// Dictionary for translations
#let dict = (
  de: (
    date: "Datum",
    invoice_number: "Rechnungsnummer",
    invoice_due: "Zahlungsziel",
    invoice: "Rechnung",
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
  ),
  en: (
    date: "Date",
    invoice_number: "Invoice number",
    invoice_due: "Time for payment",
    invoice: "Invoice",
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
  #recipient.street \
  #recipient.zip #recipient.city
]

#let invoice_details(invoice_info, invoicing_party) = place(top + left, dx: 10cm)[
  #let t(text) = tr(invoice_info.language, text)

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

#let invoice_account_details(invoice_info, invoicing_party) = align(center)[#block(width: 9cm, inset: 0.5cm)[
    #let t(text) = tr(invoice_info.language, text)

    #par(justify: true)[
      #t("account_holder"): #h(1fr) *#invoicing_party.name*\
      #t("iban"): #h(1fr) *#invoicing_party.iban* \
      #t("bic"): #h(1fr) *#invoicing_party.bic*
    ]
  ]
]

#let invoice_positions(invoice_info, positions) = [
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

#let invoice_positions_no_tax(invoice_info, positions) = [
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
    table.cell(colspan: 4)[*#t("total"):*], [*#display-amount(sum)*]
  )
]


#let invoice_footer(invoicing_party) = [
  #align(center)[#text(7.5pt)[
      #invoicing_party.name #sym.dot.c #invoicing_party.street #sym.dot.c #invoicing_party.zip #invoicing_party.city #sym.dot.c #invoicing_party.phone #sym.dot.c #invoicing_party.email
    ]]
]



#let invoice(invoice_info, invoicing_party, recipient, positions) = [
  #set text(font: "JetBrains Mono", size: 10pt)

  #set page(
    paper: "a4",
    footer: invoice_footer(invoicing_party),
  )

  #show link: underline

  #let t(text) = tr(invoice_info.language, text)

  #address_details(recipient)

  #block(height: 3.5cm)

  = #t("invoice") #invoice_info.id

  #invoice_details(invoice_info, invoicing_party)

  #block(height: 1cm)

  #t("salutation")

  #t("declaration")

  #block()

  #if invoice_info.vat > 0.0 {
    invoice_positions(invoice_info, positions)
  } else {
    invoice_positions_no_tax(invoice_info, positions)
  }

  #block()

  #if invoice_info.vat <= 0.0 {
    t("vat_note")
    block()
  }

  #t("payment_instruction")

  #invoice_account_details(invoice_info, invoicing_party)

  #t("thank_you")

  #block(height: 0.5cm)

  #t("closing")

  #block(height: 0cm)

  #invoicing_party.name
]
