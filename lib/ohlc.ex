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
defmodule Ohlc do
  defrecord Event, time: nil, price: nil, size: nil
  defrecord Bar, open_time: nil, open: nil, high: nil, low: nil, close: nil, volume: nil do
    def process(nil) do
    end
    def process(Ohlc.Event[] = event) when is_record(event) do
      Ohlc.Bar.new open_time: event.time, 
        open: event.price,
        high: event.price,
        low: event.price,
        close: event.price,
        volume: event.size
    end
    def process(Ohlc.Bar[] = bar, Ohlc.Event[] = event) do
      price = event.price
      cond do
        price > bar.high -> bar=bar.high(price)
        price < bar.low -> bar=bar.low(price)
      end
      bar |> _close(price) |> _sum_volume(event.size)
    end
    defp _close(Ohlc.Bar[] = bar, price), do: bar.close(price) 
    defp _sum_volume(Ohlc.Bar[] = bar, trade_size), do: bar.volume(bar.volume + trade_size) 
  end
  def now do
    list_to_binary :httpd_util.rfc1123_date
  end
  def load_ticks filename do
    {:ok, file} = File.read(filename)
    file |> String.split("\n") |> Parallel.pmap(&1 |> String.split(",") |> row_to_tick |> Bar.process)
  end
  def row_to_tick row do
    cond do
      length(row) > 1 ->
        [_, time, _,  _, _, price, size] = row
        Event.new time:  binary_to_integer(time), price: binary_to_integer(price), size: binary_to_integer(size)
      true ->
    end
  end
end
