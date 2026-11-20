/// Buying Plus in the app (FEAT-30 PD-10). FEAT-35 adds the store
/// implementation (RevenueCat, ADR-09) and refreshes the entitlement after
/// a buy; until then [UnavailablePurchaseService] is the only one.
abstract class PurchaseService {
  /// Whether this device can buy Plus in the app.
  bool get available;

  /// What the store sells (empty when not [available]).
  Future<List<PlusOffer>> offers();

  Future<PurchaseOutcome> buy(PlusOffer offer);

  Future<void> restore();

  /// The store's "manage subscription" page, if any.
  Uri? get manageUrl;
}

/// One thing to buy, as SCR-20 lists it.
class PlusOffer {
  const PlusOffer({required this.id, required this.title, required this.price});

  final String id;
  final String title;

  /// Shown as the store gives it (local currency).
  final String price;
}

enum PurchaseOutcome { bought, cancelled, failed, unavailable }

/// Nothing to buy yet: SCR-20 says "coming soon".
class UnavailablePurchaseService implements PurchaseService {
  const UnavailablePurchaseService();

  @override
  bool get available => false;

  @override
  Future<List<PlusOffer>> offers() async => const [];

  @override
  Future<PurchaseOutcome> buy(PlusOffer offer) async =>
      PurchaseOutcome.unavailable;

  @override
  Future<void> restore() async {}

  @override
  Uri? get manageUrl => null;
}
