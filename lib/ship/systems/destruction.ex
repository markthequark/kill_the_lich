defmodule Ship.Systems.Destruction do
  @moduledoc """
  Destroys ships with less than or equal ot 0 health points.
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
  alias Ship.Components.{RenderWidth, RenderHeight, PlayerWeapon, PlayerSpawned}

  @impl ECSx.System
  def run do
    ships = HealthPoints.get_all()

    Enum.each(ships, fn {entity, hp} ->
      if hp <= 0, do: destroy(entity)
    end)
  end

  defp destroy(ship) do
    ArmorRating.remove(ship)
    AttackCooldown.remove(ship)
    AttackDamage.remove(ship)
    AttackRange.remove(ship)
    AttackSpeed.remove(ship)
    AttackTarget.remove(ship)
    HealthPoints.remove(ship)
    SeekingTarget.remove(ship)
    XPosition.remove(ship)
    XVelocity.remove(ship)
    YPosition.remove(ship)
    YVelocity.remove(ship)
    RenderWidth.remove(ship)
    RenderHeight.remove(ship)
    PlayerWeapon.remove(ship)
    PlayerSpawned.remove(ship)

    # when a ship is destroyed, other ships should stop targeting it
    untarget(ship)

    DestroyedAt.add(ship, DateTime.utc_now())
  end

  defp untarget(target) do
    for ship <- AttackTarget.search(target) do
      AttackTarget.remove(ship)
      SeekingTarget.add(ship)
    end

    for projectile <- ProjectileTarget.search(target) do
      ProjectileTarget.remove(projectile)
    end
  end
end
