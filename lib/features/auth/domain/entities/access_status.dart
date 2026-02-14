enum AccessStatus { notFound, active, gracePeriod, inactiveExpired }

extension AccessStatusX on AccessStatus {
  bool get canLogIn =>
      this == AccessStatus.active || this == AccessStatus.gracePeriod;

  static AccessStatus fromRpc(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return AccessStatus.active;
      case 'GRACE_PERIOD':
        return AccessStatus.gracePeriod;
      case 'INACTIVE_EXPIRED':
        return AccessStatus.inactiveExpired;
      case 'NOT_FOUND':
      default:
        return AccessStatus.notFound;
    }
  }
}
