
#import "tr.typ": tr

/// Display an amount
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

/// Output address details for an invoice recipient
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

/// Output invoice details
#let invoice_details(invoice_info) = place(top + left, dx: 10cm)[
  #let invoicing_party = invoice_info.invoicing_party;

  #invoicing_party.name \
  #invoicing_party.street \
  #invoicing_party.zip #invoicing_party.city \
  #invoicing_party.phone \
  #link(invoicing_party.website) \
  #link(invoicing_party.email) \
  \
  #block(width: 6cm)[
    *#tr("date")*: #h(1fr) #invoice_info.date \
    *#tr("invoice_number")*: #h(1fr) #invoice_info.id \
    *#tr("invoice_due")*: #h(1fr) #invoice_info.due \
  ]
]

/// Output payment account details
#let invoice_account_details(invoice_info) = align(center)[#block(width: 9cm, inset: 0.5cm)[
    #let invoicing_party = invoice_info.invoicing_party;

    #par(justify: true)[
      #tr("account_holder"): #h(1fr) *#invoicing_party.name*\
      #tr("iban"): #h(1fr) *#invoicing_party.iban* \
      #tr("bic"): #h(1fr) *#invoicing_party.bic*
    ]
  ]
]

/// Output table of invoice positions (with VAT)
#let invoice_positions_vat(invoice_info) = [
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
      [#tr("position_name")],
      [#tr("position_amount")],
      [#tr("position_price")],
      [#tr("position_net")],
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
    table.cell(colspan: 4)[*#tr("subtotal"):*], [#display-amount(sum)],
    [], [], [], [], [],
    table.cell(colspan: 2)[*#tr("vat"):*], [#invoice_info.vat %], [], [#display-amount(invoice_info.vat / 100.0 * sum)],
    table.cell(colspan: 4)[*#tr("total"):*], [*#display-amount((100.0 + invoice_info.vat) / 100.0 * sum)*]
  )
]

/// Output table of invoice positions (no VAT)
#let invoice_positions_no_vat(invoice_info) = [
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

  #table(
    columns: (0.6cm, 8.0cm, 2cm, 3.0cm, 2.5cm),
    table.header(
      [\#],
      [#tr("position_name")],
      [#tr("position_amount")],
      [#tr("position_price")],
      [#tr("position_net")],
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
    table.cell(colspan: 4)[*#tr("total"):*], [*#display-amount(sum)*]
  )
]

#let invoice_positions(invoice_info) = [
  #if invoice_info.keys().contains("vat") and invoice_info.vat > 0.0 {
    invoice_positions_vat(invoice_info)
  } else {
    invoice_positions_no_vat(invoice_info)
  }
]

/// Invoice header displays page number if there is more than one page
#let invoice_header() = context [
  #align(right)[
    #let count = counter(page).final().last();
    #if count > 1 {
      counter(page).display()
    }
  ]
]

/// Display invoicing party's details in the footer
#let invoice_footer(invoicing_party) = [
  #align(center)[#text(7.0pt)[
      #invoicing_party.name #sym.dot.c #invoicing_party.street #sym.dot.c #invoicing_party.zip #invoicing_party.city #sym.dot.c #invoicing_party.email #sym.dot.c VAT-ID: #invoicing_party.vat
    ]]
]

/// Create an invoice from an invoice info dict
#let invoice(invoice_info) = [
  #show link: underline

  #address_details(invoice_info.recipient)

  #block(height: 3.5cm)

  = #tr("invoice") #invoice_info.id

  #if invoice_info.keys().contains("period") [
    #let period = invoice_info.period;
    #if period.keys().contains("end") [
      === #tr("period") #period.begin -- #period.end
    ] else [
      === #tr("period") #period.begin
    ]
  ]

  #invoice_details(invoice_info)

  #block(height: 1cm)

  #tr("salutation")

  #tr("declaration")

  #block()

  #invoice_positions(invoice_info)

  #block()

  #if not invoice_info.keys().contains("vat") or invoice_info.vat <= 0.0 {
    tr("vat_note")
    block()
  }

  #tr("payment_instruction")

  #invoice_account_details(invoice_info)

  #tr("thank_you")

  #block(height: 0.5cm)

  #tr("closing")

  #block(height: 0cm)

  #invoice_info.invoicing_party.name
]

