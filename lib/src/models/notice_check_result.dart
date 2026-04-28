sealed class NoticeCheckResult {
  const NoticeCheckResult();
}

final class HasNewNotice extends NoticeCheckResult {
  final int latestIndex;

  const HasNewNotice(this.latestIndex);
}

final class NoNewNotice extends NoticeCheckResult {
  const NoNewNotice();
}

final class NoticeCheckError extends NoticeCheckResult {
  const NoticeCheckError();
}
