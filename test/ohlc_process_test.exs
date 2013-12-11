Code.require_file "test_helper.exs", __DIR__
Code.require_file "benchmark.ex", __DIR__

defmodule OhlcTest do
  use ExUnit.Case
  require Benchmark
  # see "big",Benchmark.times(2, do: Ohlc.load_ticks(filename))
  defp see what, benchmark do
    IO.inspect(what)
    IO.inspect(benchmark)
    IO.inspect(">>>>>>>>>>>>>")
  end

  test "compute events on bar" do
    trade = Ohlc.Event.new time: Ohlc.now, price: 52.2, size: 5
    bar = Ohlc.Bar.process trade
    assert(bar != nil)
    assert bar.open_time == trade.time
    assert(bar.open == trade.price)
    assert(bar.high == trade.price)
    assert(bar.low == trade.price)
    assert(bar.close == trade.price)
    assert(bar.volume == trade.size)
    last_event = Ohlc.Event.new(time: Ohlc.now, price: 52.9, size: 3)
    bar = Ohlc.Bar.process bar, last_event
    assert bar.open == trade.price
    assert bar.high == last_event.price
    assert bar.close == last_event.price
    assert bar.volume == last_event.size + trade.size
  end
  test "compute 10 events from a file" do
    filename = "test/fixtures/10trades.csv"
    IO.inspect(Ohlc.load_ticks(filename))
  end
  test "compute 100.000 events from a small file" do
    #  filename = "test/fixtures/trades.csv"
    #IO.inspect(Ohlc.load_ticks(filename))
  end
   test "compute 900.000 events from big file" do
     filename = "test/fixtures/ticks.csv"
     #Ohlc.load_ticks(filename)
   end
end
