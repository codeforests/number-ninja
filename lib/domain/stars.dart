/// Stars for a 10-question round (design §5, PRC-06).
int starsFor(int score) {
  if (score >= 10) return 3;
  if (score >= 8) return 2;
  if (score >= 6) return 1;
  return 0;
}
