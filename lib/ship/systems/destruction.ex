defmodule Ship.Systems.Destruction do
  @moduledoc """
  Destroys entities with less than or equal ot 0 health points.
  """
  @behaviour ECSx.System

  alias Ship.Components.ArmorRating
  alias Ship.Components.AttackCooldown
  alias Ship.Components.AttackDamage
  alias Ship.Components.AttackRange
  alias Ship.Components.AttackSpeed
  alias Ship.Components.AttackTarget
  alias Ship.Components.DestroyedAt
  alias Ship.Components.HealthPoints
  alias Ship.Components.SeekingTarget
  alias Ship.Components.XPosition
  alias Ship.Components.XVelocity
  alias Ship.Components.YPosition
  alias Ship.Components.YVelocity
  alias Ship.Components.ProjectileTarget
  alias Ship.Components.ProjectileDamage
  alias Ship.Components.{RenderWidth, RenderHeight, PlayerWeapon, PlayerSpawned, ImageFile}
  alias Ship.Components.{IsLich, IsPlayer, IsProjectile}

  @impl ECSx.System
  def run do
    entities = HealthPoints.get_all()

    Enum.each(entities, fn {entity, hp} ->
      if hp <= 0, do: destroy(entity)
    end)
  end

  defp destroy(entity) do
    Ship.Manager.purge_entity(entity)

    # when a ship is destroyed, other ships should stop targeting it
    untarget(entity)

    DestroyedAt.add(entity, DateTime.utc_now())
  end

  defp untarget(target) do
    for entity <- AttackTarget.search(target) do
      AttackTarget.remove(entity)
      SeekingTarget.add(entity)
    end

    for projectile <- ProjectileTarget.search(target) do
      ProjectileTarget.remove(projectile)
    end
  end
end
