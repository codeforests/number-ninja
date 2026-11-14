/// The current time. Everything with dates or timers takes one (NFR-08).
typedef Clock = DateTime Function();

DateTime systemClock() => DateTime.now();
