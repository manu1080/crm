# Script para verificar y arreglar usuarios sin rol
# Ejecutar con: mix run priv/repo/fix_users_role.exs

alias Crm.Repo
alias Crm.Accounts.{User, Role}
import Ecto.Query

# Buscar usuarios sin rol
users_without_role = Repo.all(from u in User, where: is_nil(u.role_id), preload: :role)

IO.puts("\n=== Usuarios sin rol asignado: #{length(users_without_role)} ===\n")

if length(users_without_role) > 0 do
  # Obtener el rol "admin" como default
  admin_role = Repo.get_by!(Role, name: "admin")
  
  Enum.each(users_without_role, fn user ->
    IO.puts("Usuario: #{user.email} - Asignando rol: Admin")
    
    user
    |> Ecto.Changeset.change(role_id: admin_role.id)
    |> Repo.update!()
  end)
  
  IO.puts("\n✅ Usuarios actualizados con rol Admin\n")
else
  IO.puts("✅ Todos los usuarios tienen rol asignado\n")
end

# Mostrar todos los usuarios con sus roles
IO.puts("\n=== Usuarios en el sistema ===\n")

users = Repo.all(from u in User, preload: :role)

Enum.each(users, fn user ->
  role_name = if user.role, do: user.role.label, else: "SIN ROL"
  IO.puts("  #{user.email} -> #{role_name}")
end)

IO.puts("")
