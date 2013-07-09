Code.require_file "test_helper.exs", __DIR__

defmodule OhlcTest do
  use ExUnit.Case

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
end
