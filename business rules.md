## 🔹 Typical Pipeline Stages for Leads

### 1. New / Captured
→ Lead has just entered the system; no direct contact yet.  
- Basic info only: source, contact, declared interest.  
- **Typical action:** first call or introductory email.

### 2. Contacted
→ Initial communication established (call, WhatsApp, email).  
- Goal: validate if there’s genuine interest and budget.  
- **Typical action:** schedule a meeting or send information.

### 3. Qualified / Interested
→ Lead fits the target profile.  
- **Typical action:** present offer or investment options.

### 4. Meeting / Offer Sent
→ A meeting has taken place or a proposal was shared.  
- Conversion metrics often measured here.  
- Some CRMs auto-advance leads after a completed meeting.

### 5. Negotiation / In Progress
→ Lead is evaluating or negotiating terms, pending docs or approval.  
- May involve multiple follow-ups or reminders.  
- **Typical action:** update status, send follow-up email.

### 6. Deposit
→ Lead has accepted the offer and made an initial deposit or reservation payment.  
- Payment confirmation received and recorded.  
- **Typical action:** prepare documents for notary appointment, send next steps.

### 7. Notary
→ Legal documentation and notary appointment scheduled or in progress.  
- Property deed or contract being formalized.  
- **Typical action:** coordinate with legal team, confirm appointment date.

### 8. Management Contract
→ Final property management or investment management contract being prepared.  
- All legal documents signed, finalizing administrative details.  
- **Typical action:** set up management account, assign property manager.

### 9. Won (Closed Won)
→ Full investment or purchase process completed.  

### 10. Lost (Closed Lost)
→ Lead did not convert.  

## 🎯 Core Lead Activities & Stage Actions

**Note:** All activities automatically update the lead's `last_activity_at` timestamp.

| Activity | Description | Typical Action on Lead |
|-----------|--------------|------------------------|
| **Call logged** | Record a phone call (outbound or inbound) | Updates *last_activity_at* |
| **Meeting completed** | Meeting held or demo done | Auto-advance to **Qualified** if currently *Contacted* + Updates *last_activity_at* |
| **Offer sent** | Proposal or investment sent to the lead | Auto-advance to **Meeting** + Updates *last_activity_at* |
| **Offer accepted** | Lead accepts an offer or terms | Auto-advance to **Deposit** + Updates *last_activity_at* |
| **Deposit received** | Initial deposit or reservation payment confirmed | Auto-advance to **Notary** + Updates *last_activity_at* |
| **Notary scheduled** | Notary appointment scheduled and documents ready | Auto-advance to **Management Contract** + Updates *last_activity_at* |
| **Contract signed** | Final management contract signed | Auto-advance to **Won** + Updates *last_activity_at* |
| **Offer rejected** | Lead rejects the proposal | Auto-advance to **Lost** + Updates *last_activity_at* |
| **Reminder set** | Schedule a follow-up | No stage change + Updates *last_activity_at* |
| **Note added** | Internal note or update | Updates *last_activity_at* |
| **Lead lost** | Manually mark as lost | Auto-advance to **Lost** + Updates *last_activity_at* |
| **Lead reactivated** | Reopen a previously lost or inactive lead | Auto-advance to **Contacted** + Updates *last_activity_at* |
| **Email sent** | Email sent to lead | Updates *last_activity_at* |
| **WhatsApp sent** | WhatsApp message sent to lead | Updates *last_activity_at* |

---


## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    User Creates Activity                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Activities.create_activity/1                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Multi.new()                                           │  │
│  │  ├─ :stage_change (update lead.stage_id if needed)   │  │
│  │  ├─ :activity (insert activity record)               │  │
│  │  └─ :update_lead_activity_time (set last_activity_at)│  │
│  └───────────────────────────────────────────────────────┘  │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│         Phoenix.PubSub.broadcast("leads", :lead_updated)     │
└──────────────────────────┬──────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌───────────┐   ┌───────────┐   ┌───────────┐
    │  Index    │   │   Show    │   │  Other    │
    │ LiveView  │   │ LiveView  │   │ Clients   │
    └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
          │               │               │
          └───────────────┴───────────────┘
                     │
                     ▼
          UI updates automatically
```