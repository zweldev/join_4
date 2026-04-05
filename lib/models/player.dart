class Player {
  final String id;
  final String name;
  final String symbol;
  final bool isReady;
  final int score;

  Player({
    required this.id,
    required this.name,
    required this.symbol,
    this.isReady = false,
    this.score = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    name: json['name'] as String,
    symbol: json['symbol'] as String,
    isReady: json['isReady'] as bool? ?? false,
    score: json['score'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'symbol': symbol,
    'isReady': isReady,
    'score': score,
  };

  Player copyWith({
    String? id,
    String? name,
    String? symbol,
    bool? isReady,
    int? score,
  }) => Player(
    id: id ?? this.id,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    isReady: isReady ?? this.isReady,
    score: score ?? this.score,
  );
}
