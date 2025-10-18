# Sales Dashboard

## Metrics

| Metric                       | Description                                                    | Data Source                  |
| ---------------------------- | -------------------------------------------------------------- | ---------------------------- |
| **Leads per day**            | Number of new leads created each day                           | `leads.inserted_at`          |
| **Conversion by stage**      | % of leads moving from one stage to another                    | `leads.stage`                |
| **Conversion by source**     | Which source/channel generates the most leads and closed deals | `sources`, `leads.source_id` |
| **Activities per user**      | How many activities each salesperson logs                      | `activities.user_id`         |
| **Win rate**                 | Leads with stage = `"Won"` ÷ total leads                       | `leads.stage`                |
| **Active vs inactive leads** | Leads with recent activity (last N days) vs inactive           | `activities.inserted_at`     |

## Filters

The dashboard includes the following filters to allow users to drill down into specific data:

- **Date Range**: Filter data by a specific time period (last 7 days, 30 days, 90 days, or custom range)
- **Owner**: Filter by lead owner/responsible person
- **Source**: Filter by lead source (website, organic, partner, etc.)

All metrics and charts update dynamically based on the selected filters.
