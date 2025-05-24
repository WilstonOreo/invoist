#import "tr.typ": tr

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

#let worklog(worklog) = [
  #show link: underline

  #set table(
    stroke: (x, y) => if y == 0 or y == worklog.len() {
      (bottom: 0.7pt + black)
    },
  )

  #let period = period_from_worklog(worklog)
  #let sum = worklog.map(p => decimal(p.at(1))).sum()

  #if period.keys().contains("end") [
    = #tr("worklog") #period.begin -- #period.end
  ] else [
    = #tr("worklog") #period.begin
  ]

  #block()

  #table(
    columns: (4.0cm, 2.0cm, 11.0cm),
    table.header(
      [#tr("date")],
      [#tr("worklog_hours")],
      [#tr("worklog_description")],
    ),
    ..worklog
      .map(p => (
        p.at(0),
        p.at(1),
        p.at(3),
      ))
      .flatten(),
    table.cell()[*#tr("worklog_total_hours"):*], [*#sum*]
  )
]
