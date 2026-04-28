class NoticeCheckInfo {
  final String ntcLastIdx;

  const NoticeCheckInfo({required this.ntcLastIdx});

  factory NoticeCheckInfo.fromMap(Map<Object?, Object?> map) {
    return NoticeCheckInfo(
      ntcLastIdx: (map['ntc_last_idx'] as String?) ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {'ntc_last_idx': ntcLastIdx};
  }
}
