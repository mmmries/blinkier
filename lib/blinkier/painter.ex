defmodule Blinkier.Painter do
  use GenServer
  require Logger
  @interval 20

  def start_link(i2c_name) do
    GenServer.start_link(__MODULE__, i2c_name)
  end

  def init(i2c_name) do
    {:ok, hts221} = HTS221.start_link(i2c_name)
    {:ok, %{hts221: hts221, count: 1}, @interval}
  end

  def handle_info(:timeout, state) do
    if screen_ready?() do
      paint(state)
    end
    state = listen_to_joystick(state)
    {:noreply, state, @interval}
  end

  def handle_info({:input_event, _joystick, [{:ev_key, :key_up, 1}]}, state) do
    state = %{state | count: state.count + 1}
    {:noreply, state, @interval}
  end

  def handle_info({:input_event, _joystick, [{:ev_key, :key_down, 1}]}, state) do
    state = %{state | count: state.count - 1}
    {:noreply, state, @interval}
  end

  def handle_info(other, state) do
    Logger.error("#{__MODULE__} received unexpected message: #{inspect(other)}")
    {:noreply, state, @interval}
  end

  #@red <<0, 0xf8>>
  #@blue <<0xf8, 0>>
  #@green <<0xe0, 0x07>>
  @screen "/dev/fb1"

  def paint(state) do
    #num_pixels = round((HTS221.humidity(state.hts221) / 100.0) * 64)
    #temp = HTS221.temperature(state.hts221, scale: :fahrenheit)
    #temp_ratio = clamp((temp - 75.0) / 20.0)
    #hue = 240 + trunc(temp_ratio * 119)
    #rgb = Chameleon.HSV.new(hue, 100, 90) |> Chameleon.Color.RGB.from()
    #pixel = rgb_to_pixel(rgb)
    pixel = rgb_to_pixel(Chameleon.RGB.new(255, 0, 0))
    num_pixels = state.count
    blank = :binary.copy(<<0, 0>>, 64 - num_pixels)
    pixels = :binary.copy(pixel, num_pixels)
    File.write(@screen, [pixels, blank])
  end

  def screen_ready? do
    File.exists?(@screen)
  end

  defp clamp(num) when num < 0.0, do: 0.0
  defp clamp(num) when num > 1.0, do: 1.0
  defp clamp(num), do: num

  defp listen_to_joystick(%{joystick: _} = state), do: state
  defp listen_to_joystick(state) do
    if File.exists?("/dev/input/event1") do
      {:ok, joystick} = InputEvent.start_link("/dev/input/event1")
      Map.put(state, :joystick, joystick)
    else
      state
    end
  end

  def rgb_to_pixel(%Chameleon.RGB{r: r, g: g, b: b}) do
    use Bitwise, only_operators: true
    blue = (b >>> 3)
    green = (g >>> 2)
    red = (r >>> 3)
    <<b1, b2>> = <<red::unsigned-integer-size(5), green::unsigned-integer-size(6), blue::unsigned-integer-size(5)>>
    <<b2, b1>>
  end
end
