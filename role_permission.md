# Role-Based Access Permissions

## System Roles

- **Admin** - Administrators (full access)
- **Sales** - Sales team
- **Marketing** - Marketing team
- **Capture** - Lead capture team

---

## 🔴 Admin - Can visit EVERYTHING

### Pages with full access:
- ✅ `/` - Lead pipeline (Kanban)
- ✅ `/leads` - Lead pipeline
- ✅ `/leads/new` - Create new lead
- ✅ `/leads/:id` - View lead detail
- ✅ `/leads/:id/edit` - Edit lead
- ✅ `/activities/new` - Create activity
- ✅ `/dashboard` - Metrics dashboard
- ✅ `/export/leads.csv` - Export leads

**Can do**: View, create, edit and delete EVERYTHING

---

## 🔵 Sales - Full operational access

### Pages with full access:
- ✅ `/` - Lead pipeline (Kanban)
- ✅ `/leads` - Lead pipeline
- ✅ `/leads/new` - Create new lead
- ✅ `/leads/:id` - View lead detail
- ✅ `/leads/:id/edit` - Edit lead
- ✅ `/activities/new` - Create activity
- ✅ `/dashboard` - Metrics dashboard
- ✅ `/export/leads.csv` - Export leads

**Can do**: Same as Admin

---

## 🟢 Marketing - View-only and analysis

### Pages they CAN visit:
- ✅ `/` - Lead pipeline (read-only)
- ✅ `/leads` - Lead pipeline (read-only)
- ✅ `/leads/new` - Create new lead
- ✅ `/leads/:id` - View lead detail (read-only)
- ✅ `/dashboard` - Metrics dashboard (limited)
- ✅ `/export/leads.csv` - Export leads (with filters)

### Pages they CANNOT visit:
- ❌ `/leads/:id/edit` - Edit lead
- ❌ `/activities/new` - Create activity

**Can do**: View and create leads, export data. CANNOT edit or create activities.

---

## 🟡 Capture - Lead capture only

### Pages they CAN visit:
- ✅ `/` - Lead pipeline (own leads only)
- ✅ `/leads` - Lead pipeline (own leads only)
- ✅ `/leads/new` - Create new lead
- ✅ `/leads/:id` - View lead detail (own leads only)
- ✅ `/leads/:id/edit` - Edit lead (own leads only)

### Pages they CANNOT visit:
- ❌ `/activities/new` - Create activity
- ❌ `/dashboard` - Metrics dashboard
- ❌ `/export/leads.csv` - Export leads

**Can do**: Create and edit ONLY their own leads. CANNOT view metrics, export or create activities.