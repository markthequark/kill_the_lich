defmodule Ship.Systems.Driver do
  @moduledoc """
  Changes a ship's position based on its velocity.
  """
  @behaviour ECSx.System

  alias Ship.Components.XPosition
  alias Ship.Components.YPosition
  alias Ship.Components.XVelocity
  alias Ship.Components.YVelocity

  @impl ECSx.System
  def run do
    for {entity, x_velocity} <- XVelocity.get_all() do
      x_position = XPosition.get(entity)
      new_x_position = calculate_new_position(x_position, x_velocity)
      XPosition.update(entity, new_x_position)
    end

    for {entity, y_velocity} <- YVelocity.get_all() do
      y_position = YPosition.get(entity)
      new_y_position = calculate_new_position(y_position, y_velocity)
      YPosition.update(entity, new_y_position)
    end
  end

  # Do not let player ship move past the map limit
  defp calculate_new_position(current_position, velocity) do
    new_position = current_position + velocity
    new_position = Enum.min([new_position, 99])

    Enum.max([new_position, 0])
  end
end
