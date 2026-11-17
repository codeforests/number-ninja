/// Question ids that must no longer be served (BNK-10, FEAT-15 D3). They
/// stay in the bank marked `retired`, so her old results stay readable.
/// Append only; the generator fails if an id here isn't in the bank.
const retiredIds = <String>{};
