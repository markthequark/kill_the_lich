defmodule Ship.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  def setup do
    # Seed persistent components only for the first server start
    # (This will not be run on subsequent app restarts)

    :ok
  end

  def startup do
    # Load ephemeral components during first server start and again
    # on every subsequent app restart
    for _ships <- 1..40 do
      # First generate a unique ID to represent the new entity
      entity = Ecto.UUID.generate()

      # Then use that ID to create the components which make up a ship
      if Enum.random(1..2) == 1 do
        Ship.Components.ImageFile.add(entity, "skele_colour.png")
      else
        Ship.Components.ImageFile.add(entity, "zombie_colour.png")
      end

      Ship.Components.ArmorRating.add(entity, 0)
      Ship.Components.AttackDamage.add(entity, 5)
      Ship.Components.AttackRange.add(entity, 10)
      Ship.Components.AttackSpeed.add(entity, 1.05)
      Ship.Components.HealthPoints.add(entity, 50)
      Ship.Components.SeekingTarget.add(entity)
      Ship.Components.XPosition.add(entity, Enum.random(1..100))
      Ship.Components.YPosition.add(entity, Enum.random(1..100))
      Ship.Components.XVelocity.add(entity, 0)
      Ship.Components.YVelocity.add(entity, 0)
      Ship.Components.RenderWidth.add(entity, 4)
      Ship.Components.RenderHeight.add(entity, 5)
    end

    spawn_lich()
    :ok
  end

  defp spawn_lich do
    lich = Ecto.UUID.generate()

    Ship.Components.ArmorRating.add(lich, 0)
    Ship.Components.HealthPoints.add(lich, 100)

    Ship.Components.XPosition.add(lich, 90)
    Ship.Components.YPosition.add(lich, 10)
    Ship.Components.XVelocity.add(lich, 0)
    Ship.Components.YVelocity.add(lich, 0)
    Ship.Components.RenderWidth.add(lich, 8)
    Ship.Components.RenderHeight.add(lich, 10)
    Ship.Components.ImageFile.add(lich, "lich.png")
    Ship.Components.IsLich.add(lich)
  end

  # Declare all valid Component types
  def components do
    [
      Ship.Components.IsLich,
      Ship.Components.IsPlayer,
      Ship.Components.PlayerWeapon,
      Ship.Components.RenderHeight,
      Ship.Components.RenderWidth,
      Ship.Components.IsProjectile,
      Ship.Components.ProjectileDamage,
      Ship.Components.ProjectileTarget,
      Ship.Components.ImageFile,
      Ship.Components.PlayerSpawned,
      Ship.Components.DestroyedAt,
      Ship.Components.AttackCooldown,
      Ship.Components.AttackTarget,
      Ship.Components.SeekingTarget,
      Ship.Components.AttackSpeed,
      Ship.Components.YVelocity,
      Ship.Components.XVelocity,
      Ship.Components.YPosition,
      Ship.Components.XPosition,
      Ship.Components.AttackRange,
      Ship.Components.AttackDamage,
      Ship.Components.ArmorRating,
      Ship.Components.HealthPoints
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      Ship.Systems.Projectile,
      Ship.Systems.ClientEventHandler,
      Ship.Systems.Destruction,
      Ship.Systems.CooldownExpiration,
      Ship.Systems.Attacking,
      Ship.Systems.Targeting,
      Ship.Systems.Driver
    ]
  end

  def purge_entity(entity) do
    for component <- components() do
      component.remove(entity)
    end
  end
end
