defmodule Parallel do
  def pmap(collection, fun) do
    me = self
    collection
      |>
    Enum.map(fn (elem) ->
      spawn_link fn -> (me <- { self, fun.(elem) }) end
    end) |>
    Enum.map(fn (pid) ->
      receive do { ^pid, result } -> result end
    end)
  end
end
defmodule OHLC do
  @timeframes []
  def observe(timeframe) do
    @timeframes = [timeframe | @timeframes]
  end
  defrecord Event, time: nil, price: nil, size: nil
  defrecord Bar, open_time: nil, open: nil, high: nil, low: nil, close: nil, volume: nil do
    def process(nil) do
    end
    def process(OHLC.Event[] = event) when is_record(event) do
      OHLC.Bar.new open_time: event.time, 
        open: event.price,
        high: event.price,
        low: event.price,
        close: event.price,
        volume: event.size
    end
    def process(OHLC.Bar[] = bar, OHLC.Event[] = event) do
      price = event.price
      cond do
        price > bar.high -> bar=bar.high(price)
        price < bar.low -> bar=bar.low(price)
      end
      bar |> _close(price) |> _sum_volume(event.size)
    end
    defp _close(OHLC.Bar[] = bar, price), do: bar.close(price) 
    defp _sum_volume(OHLC.Bar[] = bar, trade_size), do: bar.volume(bar.volume + trade_size) 
  end
  def now do
    list_to_binary :httpd_util.rfc1123_date
  end
  def load_ticks filename do
    {:ok, file} = File.open(filename)
    file |> read_first_line
  end
  def read_first_line file do
    string = file |> IO.readline
    parse(string, file)
  end
  def parse(string, file) when string == :eof do
    file |> File.close
  end
  def parse(string, file) do
    string |> String.strip |> String.split(",") |> row_to_tick |> Bar.process
    read_first_line(file)
  end
  def row_to_tick row do
    cond do
      length(row) == 7 ->
        [_, time, _,  _, _, price, size] = row
        Event.new time:  binary_to_integer(time), price: binary_to_integer(price), size: binary_to_integer(size)
      length(row) == 3 ->
        [time, price, size] = row
        Event.new time:  binary_to_integer(time), price: binary_to_float(price), size: binary_to_float(size)
      true ->
    end
  end
end
