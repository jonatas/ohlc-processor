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
       IO.inspect bar
    end
    def process(Ohlc.Bar[] = bar, Ohlc.Event[] = event) do
       if event.price > bar.high, do: bar = bar.high(event.price)
       if event.price > bar.high, do: bar = bar.low(event.price) 
       bar = bar.close event.price
       bar
    end
  end
end
