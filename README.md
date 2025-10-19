# CRM Sales Pipeline

A lightweight CRM for managing investment leads through a sales funnel, built with Phoenix LiveView.

## Features

- **Kanban Board**: Visual pipeline with 10 stages (New, Contacted, Qualified, Meeting, Negotiation, Deposit, Notary, Management Contract, Won, Lost)
- **CSV Export**: Export leads with stage and activity information using NimbleCSV
- **Drag & Drop**: Move leads between stages seamlessly
- **Real-time Updates**: Live sync across multiple users via PubSub
- **Lead Management**: Track name, email, phone, budget, source, and owner
- **Smart Filters**: Filter by owner, source, or starred leads
- **Role-Based Access Control (RBAC)**: 4 user roles with granular permissions
- **Authentication**: Secure login/logout with session management and password hashing

## Tech Stack

- **Phoenix 1.8.1** with LiveView 1.1.0
- **Elixir 1.18.1** with OTP 27
- **PostgreSQL** for data persistence
- **Tailwind CSS** + DaisyUI for styling
- **JavaScript Hooks** for drag & drop

## Getting Started

### Prerequisites

- Elixir 1.18+ and Erlang/OTP 27+
- PostgreSQL 14+
- Node.js 18+ (for assets)

### Installation

```bash
# Clone the repository
git clone https://github.com/manu1080/crm.git
cd crm

# Install dependencies
mix deps.get
cd assets && npm install && cd ..

# Setup database
mix ecto.setup

# Start the server
mix phx.server
```

Now visit [`localhost:4000`](http://localhost:4000) from your browser.

## Documentation

This project includes comprehensive documentation covering different aspects of the CRM:

### 🔐 Security & Access Control
- **[Role Permissions](role_permission.md)** - User roles, permission matrix, and access control rules

###  Business Rules
- **[Business Rules](business%20rules.md)** - Complete sales pipeline stages, lead activities, and automatic stage transitions

### 📊 Analytics & Reporting
- **[Sales Dashboard](sales_dashboard.md)** - Dashboard metrics, charts, filters, and real-time analytics
- **[Export Reports](report.md)** - CSV export specification, column definitions, and data export features

### 🚀 Future Enhancements
- **[Improvements Roadmap](improvements.md)** - Planned features and enhancements for future releases

## Development

```bash
# Run tests
mix test

# Run with interactive shell
iex -S mix phx.server

# Create new migration
mix ecto.gen.migration migration_name
```

## License

MIT License - see LICENSE file for details
