# 📊 CRM Export Reports

## CSV Export Specification

### Lead Export with Stage and Activities

This document defines the structure for exporting leads with their associated stage information and activity history.

## CSV Columns

### Lead Information (Core Fields)

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `id` | Integer | Lead unique identifier | 123 |
| `name` | String | Lead full name | "Juan García" |
| `email` | String | Lead email address | "juan.garcia@example.com" |
| `phone` | String | Lead phone number | "+34600123456" |
| `owner` | String | Assigned sales rep | "Ana García" |
| `budget` | Integer | Lead budget in euros | 50000 |
| `starred` | Boolean | Is lead starred? | true/false |
| `created_at` | DateTime | Lead creation date | "2025-01-15 10:30:00" |
| `last_activity_at` | DateTime | Last interaction date | "2025-03-20 14:45:00" |

### Stage Information

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `stage_label` | String | Current stage display label | "Deposit" |

### Source Information

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `source_name` | String | Lead source internal name | "organic" |

### Activity Summary

| Column Name | Type | Description | Example |
|-------------|------|-------------|---------|
| `total_activities` | Integer | Total number of activities | 12 |
| `last_activity_type` | String | Type of last activity | "deposit_received" |
| `last_activity_description` | String | Last activity description | "Deposit of €68,000 confirmed" |
| `last_activity_date` | DateTime | When last activity occurred | "2025-03-20 14:45:00" |

## CSV Example Output

```csv
id,name,email,phone,owner,budget,starred,created_at,last_activity_at,stage_label,source_name,total_activities,last_activity_type,last_activity_description,last_activity_date
123,"Juan García","juan.garcia@example.com","+34600123456","Ana García",50000,true,"2025-01-15 10:30:00","2025-03-20 14:45:00","Deposit","organic",12,"deposit_received","Deposit of €68,000 confirmed","2025-03-20 14:45:00"
```

## Export Features

### Filtering

The export should respect the same filters applied in the UI:
- **Date Range**: Export only leads created within selected date range
- **Owner**: Export only leads assigned to specific owner
- **Source**: Export only leads from specific source
- **Stage**: Export only leads in specific stage(s)

### Sorting

Default sort order: `created_at DESC` (newest first)

### File Naming Convention

Format: `crm_leads_export_YYYYMMDD_HHMMSS.csv`

Example: `crm_leads_export_20251018_143025.csv`
