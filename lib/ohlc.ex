defmodule Ohlc do
  def now do
    list_to_binary :httpd_util.rfc1123_date
  end
  defrecord Event, time: nil, price: nil, size: nil
  defrecord Bar, open_time: nil, open: nil, high: nil, low: nil, close: nil, volume: nil do
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
    def _close(Ohlc.Bar[] = bar, price), do: bar.close(price) 
    def _sum_volume(Ohlc.Bar[] = bar, trade_size), do: bar.volume(bar.volume + trade_size) 
  end
end
