alias Crm.Repo
alias Crm.Sales.{Lead, Stage, Activity}
alias Crm.Accounts.{User, Role}
alias Crm.Settings.Source

IO.puts("🌱 Seeding database...")

Repo.delete_all(Activity)
Repo.delete_all(Lead)
Repo.delete_all(User)
Repo.delete_all(Stage)
Repo.delete_all(Source)
Repo.delete_all(Role)

roles = [
  %{name: "sales", label: "Sales", description: "Sales team members"},
  %{name: "marketing", label: "Marketing", description: "Marketing team members"},
  %{name: "capture", label: "Lead Capture", description: "Lead generation and capture team"},
  %{name: "admin", label: "Admin", description: "System administrators"}
]

Enum.each(roles, fn r ->
  Repo.insert!(%Role{name: r.name, label: r.label, description: r.description})
end)

role_ids = Repo.all(Role) |> Enum.reduce(%{}, fn r, acc -> Map.put(acc, r.name, r.id) end)

IO.puts("✅ #{length(roles)} roles")

users = [
  %{name: "Ana García", email: "ana.garcia@crm.com", role: "sales", password: "password123"},
  %{name: "Carlos López", email: "carlos.lopez@crm.com", role: "sales", password: "password123"},
  %{
    name: "María Rodríguez",
    email: "maria.rodriguez@crm.com",
    role: "marketing",
    password: "password123"
  },
  %{name: "Juan Pérez", email: "juan.perez@crm.com", role: "capture", password: "password123"},
  %{
    name: "Laura Martínez",
    email: "laura.martinez@crm.com",
    role: "admin",
    password: "password123"
  }
]

Enum.each(users, fn u ->
  %User{}
  |> User.changeset(%{
    name: u.name,
    email: u.email,
    password: u.password,
    role_id: role_ids[u.role],
    active: true
  })
  |> Repo.insert!()
end)

IO.puts("✅ #{length(users)} users")

sources = [
  %{name: "organic", description: "Organic traffic / Direct search"},
  %{name: "facebook", description: "Facebook / Instagram advertising"},
  %{name: "google", description: "Google Ads / SEM"},
  %{name: "partner", description: "Partner referrals"},
  %{name: "direct", description: "Direct contact / Referral"},
  %{name: "other", description: "Other sources"}
]

Enum.each(sources, fn s ->
  Repo.insert!(%Source{name: s.name, description: s.description})
end)

source_ids = Repo.all(Source) |> Enum.reduce(%{}, fn s, acc -> Map.put(acc, s.name, s.id) end)

IO.puts("✅ #{length(sources)} sources")

stages = [
  %{name: "new", label: "New", description: "Lead just entered", order: 0},
  %{
    name: "contacted",
    label: "Contacted",
    description: "Initial contact made",
    order: 1
  },
  %{
    name: "qualified",
    label: "Qualified",
    description: "Fits target profile",
    order: 2
  },
  %{
    name: "meeting",
    label: "Meeting",
    description: "Meeting scheduled",
    order: 3
  },
  %{
    name: "negotiation",
    label: "Negotiation",
    description: "Negotiating terms",
    order: 4
  },
  %{name: "deposit", label: "Deposit", description: "Deposit received", order: 5},
  %{name: "notary", label: "Notary", description: "Notary process", order: 6},
  %{
    name: "management_contract",
    label: "Management Contract",
    description: "Management contract",
    order: 7
  },
  %{name: "won", label: "Won", description: "Deal closed", order: 8},
  %{name: "lost", label: "Lost", description: "Did not convert", order: 9}
]

Enum.each(stages, fn s ->
  Repo.insert!(%Stage{
    name: s.name,
    label: s.label,
    description: s.description,
    order: s.order,
    active: true
  })
end)

stage_ids = Repo.all(Stage) |> Enum.reduce(%{}, fn s, acc -> Map.put(acc, s.name, s.id) end)

IO.puts("✅ #{length(stages)} stages")

leads = [
  %{
    name: "Juan García",
    email: "juan.garcia@example.com",
    phone: "+34600123456",
    source: "organic",
    stage: "new",
    owner: "Ana García",
    budget: 50_000
  },
  %{
    name: "María López",
    email: "maria.lopez@example.com",
    phone: "+34600123457",
    source: "facebook",
    stage: "new",
    owner: "Carlos López",
    budget: 75_000
  },
  %{
    name: "Carlos Pérez",
    email: "carlos.perez@example.com",
    phone: "+34600123458",
    source: "google",
    stage: "new",
    owner: "Ana García",
    budget: 100_000
  },
  %{
    name: "Ana Martínez",
    email: "ana.martinez@example.com",
    phone: "+34600123459",
    source: "partner",
    stage: "new",
    owner: nil,
    budget: 125_000
  },
  %{
    name: "Luis Rodríguez",
    email: "luis.rodriguez@example.com",
    phone: "+34600123460",
    source: "organic",
    stage: "new",
    owner: "María Rodríguez",
    budget: 150_000
  },
  %{
    name: "Carmen Sánchez",
    email: "carmen.sanchez@example.com",
    phone: "+34600123461",
    source: "facebook",
    stage: "new",
    owner: "Ana García",
    budget: 80_000
  },
  %{
    name: "José González",
    email: "jose.gonzalez@example.com",
    phone: "+34600123462",
    source: "google",
    stage: "new",
    owner: "Carlos López",
    budget: 90_000
  },
  %{
    name: "Laura Torres",
    email: "laura.torres@example.com",
    phone: "+34600123463",
    source: "organic",
    stage: "new",
    owner: nil,
    budget: 110_000
  },
  %{
    name: "Miguel Ramírez",
    email: "miguel.ramirez@example.com",
    phone: "+34600123464",
    source: "partner",
    stage: "new",
    owner: "María Rodríguez",
    budget: 95_000
  },
  %{
    name: "Isabel Flores",
    email: "isabel.flores@example.com",
    phone: "+34600123465",
    source: "facebook",
    stage: "new",
    owner: "Ana García",
    budget: 85_000
  },
  %{
    name: "Pedro Morales",
    email: "pedro.morales@example.com",
    phone: "+34600123466",
    source: "google",
    stage: "contacted",
    owner: "Carlos López",
    budget: 200_000
  },
  %{
    name: "Sofía Reyes",
    email: "sofia.reyes@example.com",
    phone: "+34600123467",
    source: "organic",
    stage: "contacted",
    owner: "Ana García",
    budget: 180_000
  },
  %{
    name: "Diego Jiménez",
    email: "diego.jimenez@example.com",
    phone: "+34600123468",
    source: "partner",
    stage: "contacted",
    owner: "María Rodríguez",
    budget: 220_000
  },
  %{
    name: "Lucía Ruiz",
    email: "lucia.ruiz@example.com",
    phone: "+34600123469",
    source: "facebook",
    stage: "contacted",
    owner: nil,
    budget: 190_000
  },
  %{
    name: "Javier Cruz",
    email: "javier.cruz@example.com",
    phone: "+34600123470",
    source: "google",
    stage: "contacted",
    owner: "Carlos López",
    budget: 210_000
  },
  %{
    name: "Elena Díaz",
    email: "elena.diaz@example.com",
    phone: "+34600123471",
    source: "organic",
    stage: "contacted",
    owner: "Ana García",
    budget: 175_000
  },
  %{
    name: "Roberto Gómez",
    email: "roberto.gomez@example.com",
    phone: "+34600123472",
    source: "partner",
    stage: "contacted",
    owner: "María Rodríguez",
    budget: 195_000
  },
  %{
    name: "Patricia Rivera",
    email: "patricia.rivera@example.com",
    phone: "+34600123473",
    source: "facebook",
    stage: "contacted",
    owner: "Carlos López",
    budget: 205_000
  },
  %{
    name: "Fernando Castillo",
    email: "fernando.castillo@example.com",
    phone: "+34600123474",
    source: "google",
    stage: "contacted",
    owner: nil,
    budget: 185_000
  },
  %{
    name: "Raquel Herrera",
    email: "raquel.herrera@example.com",
    phone: "+34600123475",
    source: "organic",
    stage: "contacted",
    owner: "Ana García",
    budget: 215_000
  },
  %{
    name: "Antonio Vargas",
    email: "antonio.vargas@example.com",
    phone: "+34600123476",
    source: "partner",
    stage: "qualified",
    owner: "Carlos López",
    budget: 300_000
  },
  %{
    name: "Teresa Romero",
    email: "teresa.romero@example.com",
    phone: "+34600123477",
    source: "facebook",
    stage: "qualified",
    owner: "María Rodríguez",
    budget: 350_000
  },
  %{
    name: "Manuel Navarro",
    email: "manuel.navarro@example.com",
    phone: "+34600123478",
    source: "google",
    stage: "qualified",
    owner: "Ana García",
    budget: 280_000
  },
  %{
    name: "Rosa Ortiz",
    email: "rosa.ortiz@example.com",
    phone: "+34600123479",
    source: "organic",
    stage: "qualified",
    owner: nil,
    budget: 320_000
  },
  %{
    name: "Francisco Ramos",
    email: "francisco.ramos@example.com",
    phone: "+34600123480",
    source: "partner",
    stage: "qualified",
    owner: "Carlos López",
    budget: 290_000
  },
  %{
    name: "Dolores Méndez",
    email: "dolores.mendez@example.com",
    phone: "+34600123481",
    source: "facebook",
    stage: "qualified",
    owner: "María Rodríguez",
    budget: 310_000
  },
  %{
    name: "Andrés Silva",
    email: "andres.silva@example.com",
    phone: "+34600123482",
    source: "google",
    stage: "qualified",
    owner: "Ana García",
    budget: 340_000
  },
  %{
    name: "Cristina Vega",
    email: "cristina.vega@example.com",
    phone: "+34600123483",
    source: "organic",
    stage: "qualified",
    owner: "Carlos López",
    budget: 330_000
  },
  %{
    name: "Rafael Molina",
    email: "rafael.molina@example.com",
    phone: "+34600123484",
    source: "partner",
    stage: "meeting",
    owner: "María Rodríguez",
    budget: 450_000
  },
  %{
    name: "Gloria Castro",
    email: "gloria.castro@example.com",
    phone: "+34600123485",
    source: "facebook",
    stage: "meeting",
    owner: nil,
    budget: 420_000
  },
  %{
    name: "Sergio Ortega",
    email: "sergio.ortega@example.com",
    phone: "+34600123486",
    source: "google",
    stage: "meeting",
    owner: "Ana García",
    budget: 480_000
  },
  %{
    name: "Beatriz Delgado",
    email: "beatriz.delgado@example.com",
    phone: "+34600123487",
    source: "organic",
    stage: "meeting",
    owner: "Carlos López",
    budget: 410_000
  },
  %{
    name: "Ramón Moreno",
    email: "ramon.moreno@example.com",
    phone: "+34600123488",
    source: "partner",
    stage: "meeting",
    owner: "María Rodríguez",
    budget: 460_000
  },
  %{
    name: "Pilar Muñoz",
    email: "pilar.munoz@example.com",
    phone: "+34600123489",
    source: "facebook",
    stage: "meeting",
    owner: "Ana García",
    budget: 440_000
  },
  %{
    name: "Álvaro Álvarez",
    email: "alvaro.alvarez@example.com",
    phone: "+34600123490",
    source: "google",
    stage: "negotiation",
    owner: "Carlos López",
    budget: 600_000
  },
  %{
    name: "Alicia Iglesias",
    email: "alicia.iglesias@example.com",
    phone: "+34600123491",
    source: "organic",
    stage: "negotiation",
    owner: nil,
    budget: 550_000
  },
  %{
    name: "Rubén Fernández",
    email: "ruben.fernandez@example.com",
    phone: "+34600123492",
    source: "partner",
    stage: "negotiation",
    owner: "María Rodríguez",
    budget: 650_000
  },
  %{
    name: "Natalia Serrano",
    email: "natalia.serrano@example.com",
    phone: "+34600123493",
    source: "facebook",
    stage: "negotiation",
    owner: "Ana García",
    budget: 580_000
  },
  %{
    name: "Óscar Blanco",
    email: "oscar.blanco@example.com",
    phone: "+34600123494",
    source: "google",
    stage: "negotiation",
    owner: "Carlos López",
    budget: 620_000
  },
  %{
    name: "Mónica Suárez",
    email: "monica.suarez@example.com",
    phone: "+34600123495",
    source: "organic",
    stage: "won",
    owner: "María Rodríguez",
    budget: 800_000
  },
  %{
    name: "Adrián Gil",
    email: "adrian.gil@example.com",
    phone: "+34600123496",
    source: "partner",
    stage: "won",
    owner: "Ana García",
    budget: 750_000
  },
  %{
    name: "Silvia Prieto",
    email: "silvia.prieto@example.com",
    phone: "+34600123497",
    source: "facebook",
    stage: "won",
    owner: nil,
    budget: 900_000
  },
  %{
    name: "Daniel Pascual",
    email: "daniel.pascual@example.com",
    phone: "+34600123498",
    source: "google",
    stage: "won",
    owner: "Carlos López",
    budget: 850_000
  },
  %{
    name: "Eva Santos",
    email: "eva.santos@example.com",
    phone: "+34600123499",
    source: "organic",
    stage: "won",
    owner: "María Rodríguez",
    budget: 780_000
  },
  %{
    name: "Víctor Rubio",
    email: "victor.rubio@example.com",
    phone: "+34600123500",
    source: "partner",
    stage: "won",
    owner: "Ana García",
    budget: 820_000
  },
  %{
    name: "Julia Carrasco",
    email: "julia.carrasco@example.com",
    phone: "+34600123501",
    source: "facebook",
    stage: "lost",
    owner: "Carlos López",
    budget: 100_000
  },
  %{
    name: "Pablo Gallego",
    email: "pablo.gallego@example.com",
    phone: "+34600123502",
    source: "google",
    stage: "lost",
    owner: nil,
    budget: 150_000
  },
  %{
    name: "Marina Cabrera",
    email: "marina.cabrera@example.com",
    phone: "+34600123503",
    source: "organic",
    stage: "lost",
    owner: "María Rodríguez",
    budget: 120_000
  },
  %{
    name: "Iván León",
    email: "ivan.leon@example.com",
    phone: "+34600123504",
    source: "partner",
    stage: "lost",
    owner: "Ana García",
    budget: 180_000
  },
  %{
    name: "Claudia Núñez",
    email: "claudia.nunez@example.com",
    phone: "+34600123505",
    source: "facebook",
    stage: "lost",
    owner: "Carlos López",
    budget: 140_000
  },
  # New leads for the new stages (Deposit, Notary, Management Contract)
  %{
    name: "Roberto Silva",
    email: "roberto.silva@example.com",
    phone: "+34600123506",
    source: "partner",
    stage: "deposit",
    owner: "Ana García",
    budget: 450_000
  },
  %{
    name: "Natalia Rojas",
    email: "natalia.rojas@example.com",
    phone: "+34600123507",
    source: "organic",
    stage: "deposit",
    owner: "Carlos López",
    budget: 380_000
  },
  %{
    name: "Diego Montero",
    email: "diego.montero@example.com",
    phone: "+34600123508",
    source: "google",
    stage: "deposit",
    owner: "Ana García",
    budget: 520_000
  },
  %{
    name: "Carmen Delgado",
    email: "carmen.delgado@example.com",
    phone: "+34600123509",
    source: "facebook",
    stage: "notary",
    owner: "Carlos López",
    budget: 680_000
  },
  %{
    name: "Andrés Blanco",
    email: "andres.blanco@example.com",
    phone: "+34600123510",
    source: "partner",
    stage: "notary",
    owner: "Ana García",
    budget: 750_000
  },
  %{
    name: "Isabel Moreno",
    email: "isabel.moreno@example.com",
    phone: "+34600123511",
    source: "direct",
    stage: "notary",
    owner: "Carlos López",
    budget: 420_000
  },
  %{
    name: "Fernando Vega",
    email: "fernando.vega@example.com",
    phone: "+34600123512",
    source: "organic",
    stage: "management_contract",
    owner: "Ana García",
    budget: 890_000
  },
  %{
    name: "Lorena Castillo",
    email: "lorena.castillo@example.com",
    phone: "+34600123513",
    source: "google",
    stage: "management_contract",
    owner: "Carlos López",
    budget: 540_000
  },
  %{
    name: "Sergio Parra",
    email: "sergio.parra@example.com",
    phone: "+34600123514",
    source: "partner",
    stage: "management_contract",
    owner: "Ana García",
    budget: 620_000
  },
  %{
    name: "Patricia Soto",
    email: "patricia.soto@example.com",
    phone: "+34600123515",
    source: "facebook",
    stage: "management_contract",
    owner: "Carlos López",
    budget: 710_000
  }
]

leads
|> Enum.with_index()
|> Enum.each(fn {lead, index} ->
  Repo.insert!(%Lead{
    name: lead.name,
    email: lead.email,
    phone: lead.phone,
    source_id: source_ids[lead.source],
    stage_id: stage_ids[lead.stage],
    owner: lead.owner,
    budget: lead.budget,
    starred: index < 8
  })
end)

IO.puts("✅ #{length(leads)} leads (8 starred)")

# ============================================
# SECTION 6: Activities
# ============================================

# Get some leads to add activities
all_leads = Repo.all(Lead)
lead_sample = Enum.take(all_leads, 25)

activities = [
  # Lead 1: First contact activities
  %{
    lead_id: Enum.at(lead_sample, 0).id,
    type: "call_logged",
    description: "Initial contact made. Interested in real estate investment opportunities.",
    stage_change_from_id: nil,
    stage_change_to_id: stage_ids["contacted"]
  },
  %{
    lead_id: Enum.at(lead_sample, 0).id,
    type: "email_sent",
    description: "Sent investment portfolio and property brochures.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 2: Qualification process
  %{
    lead_id: Enum.at(lead_sample, 1).id,
    type: "meeting_completed",
    description: "Initial qualification meeting. Budget confirmed at €75k.",
    stage_change_from_id: stage_ids["contacted"],
    stage_change_to_id: stage_ids["qualified"]
  },
  %{
    lead_id: Enum.at(lead_sample, 1).id,
    type: "note_added",
    description:
      "Looking for 2-bedroom apartment in Barcelona city center. Timeline: 3-6 months.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 3: Meeting scheduled
  %{
    lead_id: Enum.at(lead_sample, 2).id,
    type: "meeting_completed",
    description: "Property viewing scheduled for next week. Showed 3 options.",
    stage_change_from_id: stage_ids["qualified"],
    stage_change_to_id: stage_ids["meeting"]
  },
  %{
    lead_id: Enum.at(lead_sample, 2).id,
    type: "whatsapp_sent",
    description: "Sent additional photos and floor plans via WhatsApp.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 4: Offer sent
  %{
    lead_id: Enum.at(lead_sample, 3).id,
    type: "offer_sent",
    description:
      "Formal offer sent for property in Eixample district. €95,000 with 10% down payment.",
    stage_change_from_id: stage_ids["meeting"],
    stage_change_to_id: stage_ids["negotiation"]
  },
  %{
    lead_id: Enum.at(lead_sample, 3).id,
    type: "call_logged",
    description: "Follow-up call. Client reviewing offer with family.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 5: Won deal
  %{
    lead_id: Enum.at(lead_sample, 4).id,
    type: "offer_accepted",
    description: "Client accepted the offer! Down payment received.",
    stage_change_from_id: stage_ids["negotiation"],
    stage_change_to_id: stage_ids["won"]
  },
  %{
    lead_id: Enum.at(lead_sample, 4).id,
    type: "note_added",
    description:
      "Contract signed. Closing scheduled for end of month. Total deal value: €120,000.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 6: Lost opportunity
  %{
    lead_id: Enum.at(lead_sample, 5).id,
    type: "offer_rejected",
    description: "Client found another property through competitor.",
    stage_change_from_id: stage_ids["negotiation"],
    stage_change_to_id: stage_ids["lost"]
  },
  %{
    lead_id: Enum.at(lead_sample, 5).id,
    type: "lead_lost",
    description:
      "Lost reason: Price too high. Requested to stay in touch for future opportunities.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 7: Multiple touches
  %{
    lead_id: Enum.at(lead_sample, 6).id,
    type: "call_logged",
    description: "Initial outreach call. Very interested, good budget.",
    stage_change_from_id: stage_ids["new"],
    stage_change_to_id: stage_ids["contacted"]
  },
  %{
    lead_id: Enum.at(lead_sample, 6).id,
    type: "email_sent",
    description: "Sent welcome email with company presentation.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },
  %{
    lead_id: Enum.at(lead_sample, 6).id,
    type: "reminder_set",
    description: "Set reminder to follow up next week after client returns from vacation.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 8: Quick progression
  %{
    lead_id: Enum.at(lead_sample, 7).id,
    type: "meeting_completed",
    description:
      "Video call completed. Client is relocating from Madrid, needs property quickly.",
    stage_change_from_id: stage_ids["contacted"],
    stage_change_to_id: stage_ids["qualified"]
  },
  %{
    lead_id: Enum.at(lead_sample, 7).id,
    type: "offer_sent",
    description: "Sent 2 pre-approved options matching criteria. Both in Sant Martí district.",
    stage_change_from_id: stage_ids["qualified"],
    stage_change_to_id: stage_ids["meeting"]
  },

  # Lead 9: Reactivation
  %{
    lead_id: Enum.at(lead_sample, 8).id,
    type: "lead_reactivated",
    description: "Lead contacted us again after 2 months. Still interested.",
    stage_change_from_id: stage_ids["lost"],
    stage_change_to_id: stage_ids["contacted"]
  },
  %{
    lead_id: Enum.at(lead_sample, 8).id,
    type: "whatsapp_sent",
    description: "Sent updated property listings via WhatsApp.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 10: Documentation phase
  %{
    lead_id: Enum.at(lead_sample, 9).id,
    type: "note_added",
    description: "Collecting documentation for financing approval. Bank pre-approval received.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },
  %{
    lead_id: Enum.at(lead_sample, 9).id,
    type: "email_sent",
    description: "Sent checklist of required documents for final approval.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 11: High value opportunity
  %{
    lead_id: Enum.at(lead_sample, 10).id,
    type: "call_logged",
    description: "Premium lead. Budget €200k+. Looking for luxury apartment.",
    stage_change_from_id: stage_ids["new"],
    stage_change_to_id: stage_ids["contacted"]
  },
  %{
    lead_id: Enum.at(lead_sample, 10).id,
    type: "meeting_completed",
    description: "Showed premium properties in Sarrià-Sant Gervasi. Very interested.",
    stage_change_from_id: stage_ids["contacted"],
    stage_change_to_id: stage_ids["qualified"]
  },

  # Lead 12: Follow-up needed
  %{
    lead_id: Enum.at(lead_sample, 11).id,
    type: "reminder_set",
    description: "Client asked to be contacted in 2 weeks after tax return.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 13: Partnership referral
  %{
    lead_id: Enum.at(lead_sample, 12).id,
    type: "note_added",
    description: "Partner referral from mortgage broker. High trust level, hot lead.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },
  %{
    lead_id: Enum.at(lead_sample, 12).id,
    type: "call_logged",
    description: "Excellent first call. Ready to move forward quickly.",
    stage_change_from_id: stage_ids["new"],
    stage_change_to_id: stage_ids["contacted"]
  },

  # Lead 14: Objections handling
  %{
    lead_id: Enum.at(lead_sample, 13).id,
    type: "call_logged",
    description: "Addressing concerns about market conditions and property values.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },
  %{
    lead_id: Enum.at(lead_sample, 13).id,
    type: "email_sent",
    description: "Sent market analysis report and ROI projections.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 15: International client
  %{
    lead_id: Enum.at(lead_sample, 14).id,
    type: "whatsapp_sent",
    description: "Client based in UK. Communication via WhatsApp. Sent video tours.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },
  %{
    lead_id: Enum.at(lead_sample, 14).id,
    type: "meeting_completed",
    description: "Virtual meeting completed. Discussed legal requirements for foreign buyers.",
    stage_change_from_id: stage_ids["contacted"],
    stage_change_to_id: stage_ids["qualified"]
  },

  # Lead 16: Roberto Silva - Deposit stage
  %{
    lead_id: Enum.at(lead_sample, 15).id,
    type: "offer_sent",
    description: "Investment proposal sent for €450,000 property with 8% projected ROI.",
    stage_change_from_id: stage_ids["negotiation"],
    stage_change_to_id: stage_ids["meeting"]
  },
  %{
    lead_id: Enum.at(lead_sample, 15).id,
    type: "offer_accepted",
    description: "Client accepted offer! Ready to proceed with deposit.",
    stage_change_from_id: stage_ids["meeting"],
    stage_change_to_id: stage_ids["deposit"]
  },

  # Lead 17: Natalia Rojas - Deposit stage
  %{
    lead_id: Enum.at(lead_sample, 16).id,
    type: "call_logged",
    description: "Client confirmed deposit amount and payment method. Wire transfer in progress.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },
  %{
    lead_id: Enum.at(lead_sample, 16).id,
    type: "offer_accepted",
    description: "Offer accepted. Waiting for deposit confirmation.",
    stage_change_from_id: stage_ids["negotiation"],
    stage_change_to_id: stage_ids["deposit"]
  },

  # Lead 18: Diego Montero - Deposit stage
  %{
    lead_id: Enum.at(lead_sample, 17).id,
    type: "offer_accepted",
    description: "€520,000 offer accepted. Deposit payment scheduled for tomorrow.",
    stage_change_from_id: stage_ids["meeting"],
    stage_change_to_id: stage_ids["deposit"]
  },
  %{
    lead_id: Enum.at(lead_sample, 17).id,
    type: "email_sent",
    description: "Sent bank details and deposit instructions.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 19: Carmen Delgado - Notary stage
  %{
    lead_id: Enum.at(lead_sample, 18).id,
    type: "deposit_received",
    description: "Deposit of €68,000 confirmed. Preparing documents for notary.",
    stage_change_from_id: stage_ids["deposit"],
    stage_change_to_id: stage_ids["notary"]
  },
  %{
    lead_id: Enum.at(lead_sample, 18).id,
    type: "call_logged",
    description: "Coordinating with legal team for notary appointment next week.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 20: Andrés Blanco - Notary stage
  %{
    lead_id: Enum.at(lead_sample, 19).id,
    type: "deposit_received",
    description: "Full deposit received. Notary appointment scheduled for Friday.",
    stage_change_from_id: stage_ids["deposit"],
    stage_change_to_id: stage_ids["notary"]
  },
  %{
    lead_id: Enum.at(lead_sample, 19).id,
    type: "email_sent",
    description: "Sent notary appointment details and required documents checklist.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 21: Isabel Moreno - Notary stage
  %{
    lead_id: Enum.at(lead_sample, 20).id,
    type: "deposit_received",
    description: "Deposit confirmed. Preparing deed and contracts for notary signature.",
    stage_change_from_id: stage_ids["deposit"],
    stage_change_to_id: stage_ids["notary"]
  },

  # Lead 22: Fernando Vega - Management Contract stage
  %{
    lead_id: Enum.at(lead_sample, 21).id,
    type: "notary_scheduled",
    description: "Notary appointment completed successfully. All legal documents signed.",
    stage_change_from_id: stage_ids["notary"],
    stage_change_to_id: stage_ids["management_contract"]
  },
  %{
    lead_id: Enum.at(lead_sample, 21).id,
    type: "call_logged",
    description:
      "Reviewing management contract terms. Client satisfied with property manager assignment.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 23: Lorena Castillo - Management Contract stage
  %{
    lead_id: Enum.at(lead_sample, 22).id,
    type: "notary_scheduled",
    description: "Legal process complete. Setting up management account and services.",
    stage_change_from_id: stage_ids["notary"],
    stage_change_to_id: stage_ids["management_contract"]
  },
  %{
    lead_id: Enum.at(lead_sample, 22).id,
    type: "email_sent",
    description: "Sent property management agreement draft for review.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  },

  # Lead 24: Sergio Parra - Management Contract stage
  %{
    lead_id: Enum.at(lead_sample, 23).id,
    type: "notary_scheduled",
    description: "Property deed registered. Finalizing management service agreement.",
    stage_change_from_id: stage_ids["notary"],
    stage_change_to_id: stage_ids["management_contract"]
  },

  # Lead 25: Patricia Soto - Management Contract stage
  %{
    lead_id: Enum.at(lead_sample, 24).id,
    type: "notary_scheduled",
    description: "All legal formalities completed. Management contract being prepared.",
    stage_change_from_id: stage_ids["notary"],
    stage_change_to_id: stage_ids["management_contract"]
  },
  %{
    lead_id: Enum.at(lead_sample, 24).id,
    type: "call_logged",
    description: "Discussed ongoing property management services and monthly reporting.",
    stage_change_from_id: nil,
    stage_change_to_id: nil
  }
]

Enum.each(activities, fn activity ->
  Repo.insert!(%Activity{
    lead_id: activity.lead_id,
    type: activity.type,
    description: activity.description,
    stage_change_from_id: activity.stage_change_from_id,
    stage_change_to_id: activity.stage_change_to_id
  })
end)

IO.puts("✅ #{length(activities)} activities")
IO.puts("🎉 Done!")
