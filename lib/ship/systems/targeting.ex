defmodule Ship.Systems.Targeting do
  @moduledoc """
  Checks the distance of a ship to all other ships.
  If another ship is within the ship's attack range,
  the ship and its target are added to the attack target system

  A ship only attacks 1 other ship at a time.
  It currently targets a random ship within range
  """
  @behaviour ECSx.System

  alias Ship.Components.AttackRange
  alias Ship.Components.AttackTarget
  alias Ship.Components.HealthPoints
  alias Ship.Components.SeekingTarget
  alias Ship.SystemUtils

  @impl ECSx.System
  def run do
    entities = SeekingTarget.get_all()

    Enum.each(entities, &attempt_target/1)
  end

  defp attempt_target(self) do
    case look_for_target(self) do
      nil -> :noop
      {target, _hp} -> add_target(self, target)
    end
  end

  defp look_for_target(self) do
    # For now, we're assuming anything which has HealthPoints can be attacked
    HealthPoints.get_all()
    # ... except your own ship!
    |> Enum.reject(fn {possible_target, _hp} -> possible_target == self end)
    |> Enum.find(fn {possible_target, _hp} ->
      distance_between = SystemUtils.distance_between(possible_target, self)
      range = AttackRange.get(self)

      distance_between < range
    end)
  end

  defp add_target(self, target) do
    SeekingTarget.remove(self)
    AttackTarget.add(self, target)
  end
end
