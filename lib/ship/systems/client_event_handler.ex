defmodule Ship.Systems.ClientEventHandler do
  @moduledoc """
  Player input system.
  """
  @behaviour ECSx.System

  alias Ship.Components.ArmorRating
  alias Ship.Components.AttackDamage
  alias Ship.Components.AttackRange
  alias Ship.Components.AttackSpeed
  alias Ship.Components.HealthPoints
  alias Ship.Components.SeekingTarget
  alias Ship.Components.XPosition
  alias Ship.Components.XVelocity
  alias Ship.Components.YPosition
  alias Ship.Components.YVelocity
  alias Ship.Components.PlayerSpawned
  alias Ship.Components.ImageFile
  alias Ship.Components.{RenderWidth, RenderHeight, PlayerWeapon, PlayerName}

  @impl ECSx.System
  def run do
    client_events = ECSx.ClientEvents.get_and_clear()

    Enum.each(client_events, &process_one/1)
  end

  defp process_one({entity, {:spawn_ship, player_struct}}) do
    # currently needed for loading after death
    Ship.Manager.purge_entity(entity)

    # player ships have better stats than the enemy ships
    ArmorRating.add(entity, 2)
    AttackDamage.add(entity, 6)
    AttackRange.add(entity, 15)
    AttackSpeed.add(entity, 1.2)
    HealthPoints.add(entity, 40)
    SeekingTarget.add(entity)
    XPosition.add(entity, Enum.random(1..100))
    YPosition.add(entity, Enum.random(1..100))
    XVelocity.add(entity, 0)
    YVelocity.add(entity, 0)
    RenderWidth.add(entity, 1)
    RenderHeight.add(entity, 2)
    ImageFile.add(entity, "my_spaceship.svg")
    PlayerWeapon.add(entity, "bow")
    PlayerSpawned.add(entity)
    PlayerName.add(entity, player_struct.email)
  end

  defp process_one({player, {:equip_weapon, weapon}}), do: PlayerWeapon.update(player, weapon)

  # Note Y movement will use screen position (increasing Y goes south)
  defp process_one({player, {:move, :north}}), do: YVelocity.update(player, -1)
  defp process_one({player, {:move, :south}}), do: YVelocity.update(player, 1)
  defp process_one({player, {:move, :east}}), do: XVelocity.update(player, 1)
  defp process_one({player, {:move, :west}}), do: XVelocity.update(player, -1)

  defp process_one({player, {:stop_move, :north}}), do: YVelocity.update(player, 0)
  defp process_one({player, {:stop_move, :south}}), do: YVelocity.update(player, 0)
  defp process_one({player, {:stop_move, :east}}), do: XVelocity.update(player, 0)
  defp process_one({player, {:stop_move, :west}}), do: XVelocity.update(player, 0)
end
