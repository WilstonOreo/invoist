
#let invoice(invoice_info, invoicing_party, recipient, positions) = [

  #set text(font: "JetBrains Mono", size: 10pt)

  #set page(
    paper: "a4",
    header: [],
    footer: align(center)[#text(7.5pt)[
        #invoicing_party.name #sym.dot.c #invoicing_party.street #sym.dot.c #invoicing_party.zip #invoicing_party.city #sym.dot.c #invoicing_party.phone #sym.dot.c #invoicing_party.email
      ]],
    number-align: center,
  )

  #show link: underline


  #block(width: 12cm)[
    #recipient.name \
    #recipient.street \
    #recipient.zip #recipient.city
  ]

  #block(height: 3.5cm)

  = Rechnung #invoice_info.id

  #let invoice_details(body) = context {
    place(top + left, dx: 10cm, body)
  }

  #invoice_details[
    #invoicing_party.name \
    #invoicing_party.street \
    #invoicing_party.zip #invoicing_party.city \
    #invoicing_party.phone \
    #link(invoicing_party.website) \
    #link(invoicing_party.email) \
    \
    #block(width: 6cm)[
      *Datum*: #h(1fr) #invoice_info.date \
      *Rechnungsnummer*: #h(1fr) #invoice_info.id \
      *Zahlungsziel*: #h(1fr) #invoice_info.due \
    ]
  ]


  #block(height: 1cm)

  Sehr geehrte Damen und Herren,


  vereinbarungsgemäß berechne ich für meine Leistungen wie folgt:

  #show table.cell.where(y: 0): strong
  #set table(
    stroke: (x, y) => if y == 0 or y == positions.len() or y == positions.len() + 3 {
      (bottom: 0.7pt + black)
    },
    align: (x, y) => (
      if x > 1 { right } else { left }
    ),
  )

  #let position_row(pos) = {
    [table.cell()[Test]]
    [table.cell()[Test]]
  }

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

  #let sum = positions.map(p => p.at(3)).sum()

  #block()

  #table(
    columns: (0.6cm, 8.0cm, 2cm, 3.0cm, 2.5cm),
    table.header(
      [\#],
      [Bezeichnung],
      [Anzahl],
      [Preis],
      [Netto],
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
    [*Zwischensumme:*], [], [], [], [#display-amount(sum)],
    [], [], [], [], [],
    [Mehrwertsteuer:], [], [#invoice_info.vat %], [], [#display-amount(invoice_info.vat / 100.0 * sum)],
    [*Gesamtsumme:*], [], [], [], [#display-amount((100.0 + invoice_info.vat) / 100.0 * sum)]
  )

  #block()

  Zahlbar 14 Tage nach Erhalt per Überweisung unter Angabe der Rechnungsnummer als
  Verwendungszweck auf das folgende Konto:

  #align(center)[#block(width: 9cm, inset: 0.5cm)[
      #par(justify: true)[
        Kontoinhaber: #h(1fr) *#invoicing_party.name*\
        IBAN: #h(1fr) *#invoicing_party.iban* \
        BIC: #h(1fr) *#invoicing_party.bic*
      ]
    ]]

  Ich bedanke mich für Ihren Auftrag und freue mich auf die weitere Zusammenarbeit.

  #block(height: 0.5cm)

  Mit freundlichen Grüßen

  #block(height: 0cm)

  #invoicing_party.name

]
