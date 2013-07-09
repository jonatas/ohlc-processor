defmodule Ohlc do
  def now do
    list_to_binary :httpd_util.rfc1123_date
  end
  defrecord Event, time: nil, price: nil, size: nil
  defrecord Bar, open_time: nil, open: nil, high: nil, low: nil, close: nil, volume: nil do
    def process(Ohlc.Event[] = event) when is_record(event) do
       bar = new open_time: event.time, 
       open: event.price,
        high: event.price,
        low: event.price,
        close: event.price,
        volume: event.size
    end
    def process(Ohlc.Bar[] = bar, Ohlc.Event[] = event) do
      bar |> 
        _high(event.price) |>
          _low(event.price) |>
            _close(event.price) |>
              _sum_volume(event.size)
    end
    def _high(Ohlc.Bar[] = bar, price) do
      if price > bar.high, do: bar = bar.high(price) 
      bar 
    end
    def _low(Ohlc.Bar[] = bar, price) do
      if price < bar.low, do: bar = bar.low(price) 
      bar 
    end
    def _close(Ohlc.Bar[] = bar, price), do: bar = bar.close(price) 
    def _sum_volume(Ohlc.Bar[] = bar, trade_size), do: bar = bar.volume(bar.volume + trade_size) 
  end
end
