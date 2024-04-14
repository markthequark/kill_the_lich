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
  alias Ship.Components.{RenderWidth, RenderHeight, PlayerWeapon}

  @impl ECSx.System
  def run do
    client_events = ECSx.ClientEvents.get_and_clear()

    Enum.each(client_events, &process_one/1)
  end

  defp process_one({player, :spawn_ship}) do
    # currently needed for loading after death
    Ship.Manager.purge_entity(player)

    # player ships have better stats than the enemy ships
    ArmorRating.add(player, 2)
    AttackDamage.add(player, 6)
    AttackRange.add(player, 15)
    AttackSpeed.add(player, 1.2)
    HealthPoints.add(player, 40)
    SeekingTarget.add(player)
    XPosition.add(player, Enum.random(1..100))
    YPosition.add(player, Enum.random(1..100))
    XVelocity.add(player, 0)
    YVelocity.add(player, 0)
    RenderWidth.add(player, 1)
    RenderHeight.add(player, 2)
    ImageFile.add(player, "my_spaceship.svg")
    PlayerWeapon.add(player, "bow")
    PlayerSpawned.add(player)
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
