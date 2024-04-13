defmodule ShipWeb.GameLive do
  use ShipWeb, :live_view

  alias Ship.Components.HullPoints
  alias Ship.Components.XPosition
  alias Ship.Components.YPosition
  alias Ship.Components.PlayerSpawned

  def mount(_params, %{"player_token" => token} = _session, socket) do
    # This context function was generated by phx.gen.auth
    player = Ship.Players.get_player_by_session_token(token)

    socket =
      socket
      |> assign(player_entity: player.id)
        # Keeping a set of currently held keys will allow us to prevent duplicate keydown events
      |> assign(keys: MapSet.new())
      |> assign_loading_state()

    # We don't want these calls to be made on both the initial static page render and again after
    # the LiveView is connected, so we wrap them in `connected?/1` to prevent duplication
    if connected?(socket) do
      ECSx.ClientEvents.add(player.id, :spawn_ship)
      send(self(), :first_load)
    end

    {:ok, socket}
  end

  def handle_info(:first_load, socket) do
    # Don't start fetching components until after spawn is complete!
    :ok = wait_for_spawn(socket.assigns.player_entity)

    socket =
      socket
      |> assign_player_ship()
      |> assign(loading: false)

    # We want to keep up-to-date on this info
    :timer.send_interval(50, :refresh)

    {:noreply, socket}
  end

  def handle_info(:refresh, socket) do
    {:noreply, assign_player_ship(socket)}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    if MapSet.member?(socket.assigns.keys, key) do
      # Already holding this key - do nothing
      {:noreply, socket}
    else
      # We only want to add a client event if the key is defined by the `keydown/1` helper below
      maybe_add_client_event(socket.assigns.player_entity, key, &keydown/1)
      {:noreply, assign(socket, keys: MapSet.put(socket.assigns.keys, key))}
    end
  end

  def handle_event("keyup", %{"key" => key}, socket) do
    # We don't have to worry about duplicate keyup events
    # But once again, we will only add client events for keys that actually do something
    maybe_add_client_event(socket.assigns.player_entity, key, &keyup/1)
    {:noreply, assign(socket, keys: MapSet.delete(socket.assigns.keys, key))}
  end

  defp assign_loading_state(socket) do
    assign(socket,
      x_coord: nil,
      y_coord: nil,
      current_hp: nil,
      # whether the loading screen is shown
      loading: true
    )
  end

  defp assign_player_ship(socket) do
    # This will run every 50ms to keep the client assigns updated
    x = XPosition.get(socket.assigns.player_entity)
    y = YPosition.get(socket.assigns.player_entity)
    hp = HullPoints.get(socket.assigns.player_entity)

    assign(socket, x_coord: x, y_coord: y, current_hp: hp)
  end

  defp wait_for_spawn(player_entity) do
    if PlayerSpawned.exists?(player_entity) do
      :ok
    else
      Process.sleep(10)
      wait_for_spawn(player_entity)
    end
  end

  defp maybe_add_client_event(player_entity, key, fun) do
    case fun.(key) do
      :noop -> :ok
      event -> ECSx.ClientEvents.add(player_entity, event)
    end
  end

  defp keydown(key) when key in ~w(w W ArrowUp), do: {:move, :north}
  defp keydown(key) when key in ~w(a A ArrowLeft), do: {:move, :west}
  defp keydown(key) when key in ~w(s S ArrowDown), do: {:move, :south}
  defp keydown(key) when key in ~w(d D ArrowRight), do: {:move, :east}
  defp keydown(_key), do: :noop

  defp keyup(key) when key in ~w(w W ArrowUp), do: {:stop_move, :north}
  defp keyup(key) when key in ~w(a A ArrowLeft), do: {:stop_move, :west}
  defp keyup(key) when key in ~w(s S ArrowDown), do: {:stop_move, :south}
  defp keyup(key) when key in ~w(d D ArrowRight), do: {:stop_move, :east}
  defp keyup(_key), do: :noop

  def render(assigns) do
    ~H"""
    <div id="game" phx-window-keydown="keydown" phx-window-keyup="keyup">
      <%= if @loading do %>
        <p>Loading...</p>
      <% else %>
        <p>Player ID: <%= @player_entity %></p>
        <p>Player Coords: <%= inspect({@x_coord, @y_coord}) %></p>
        <p>Hull Points: <%= @current_hp %></p>
      <% end %>
    </div>
    """
  end
end