// Government Advisory model
// Published advisories are pushed to Farmer and Veterinarian alert feeds.

enum AdvisoryStatus { draft, published, expired }
enum AdvisoryTarget { all, district, block, village }

extension AdvisoryStatusExt on AdvisoryStatus {
  String get displayName {
    switch (this) {
      case AdvisoryStatus.draft:
        return 'Draft';
      case AdvisoryStatus.published:
        return 'Published';
      case AdvisoryStatus.expired:
        return 'Expired';
    }
  }
}

extension AdvisoryTargetExt on AdvisoryTarget {
  String get displayName {
    switch (this) {
      case AdvisoryTarget.all:
        return 'All Farmers';
      case AdvisoryTarget.district:
        return 'District';
      case AdvisoryTarget.block:
        return 'Block';
      case AdvisoryTarget.village:
        return 'Village';
    }
  }
}

class Advisory {
  final String advisoryId;
  final String title;
  final String message;
  final AdvisoryTarget target;
  final String? targetLocation; // village/block/district name
  final String language; // en / ta / hi
  final String createdBy; // Officer name
  AdvisoryStatus status;
  final DateTime createdAt;
  DateTime? publishedAt;

  Advisory({
    required this.advisoryId,
    required this.title,
    required this.message,
    required this.target,
    this.targetLocation,
    this.language = 'en',
    required this.createdBy,
    this.status = AdvisoryStatus.draft,
    DateTime? createdAt,
    this.publishedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  void publish() {
    status = AdvisoryStatus.published;
    publishedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'advisoryId': advisoryId,
        'title': title,
        'message': message,
        'target': target.name,
        'targetLocation': targetLocation,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
