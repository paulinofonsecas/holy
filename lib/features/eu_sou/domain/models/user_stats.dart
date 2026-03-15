class UserStats {
  final int presencaDias;
  final int escritasNotas;
  final int estudosCount;

  const UserStats({
    required this.presencaDias,
    required this.escritasNotas,
    required this.estudosCount,
  });

  const UserStats.empty()
      : presencaDias = 0,
        escritasNotas = 0,
        estudosCount = 0;
}
