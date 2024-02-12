// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tweet.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$TweetModel {
  BigInt get deterministicId => throw UnimplementedError();
  Ed25519HDPublicKey get author => throw UnimplementedError();
  BigInt get timestamp => throw UnimplementedError();
  String get topic => throw UnimplementedError();
  String get content => throw UnimplementedError();
  Ed25519HDPublicKey get owner => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU64().write(writer, deterministicId);
    const BPublicKey().write(writer, author);
    const BU64().write(writer, timestamp);
    const BString().write(writer, topic);
    const BString().write(writer, content);
    const BPublicKey().write(writer, owner);

    return writer.toArray();
  }
}

class _TweetModel extends TweetModel {
  _TweetModel({
    required this.deterministicId,
    required this.author,
    required this.timestamp,
    required this.topic,
    required this.content,
    required this.owner,
  }) : super._();

  @override
  final BigInt deterministicId;
  @override
  final Ed25519HDPublicKey author;
  @override
  final BigInt timestamp;
  @override
  final String topic;
  @override
  final String content;
  @override
  final Ed25519HDPublicKey owner;
}

class BTweetModel implements BType<TweetModel> {
  const BTweetModel();

  @override
  void write(BinaryWriter writer, TweetModel value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  TweetModel read(BinaryReader reader) {
    return TweetModel(
      deterministicId: const BU64().read(reader),
      author: const BPublicKey().read(reader),
      timestamp: const BU64().read(reader),
      topic: const BString().read(reader),
      content: const BString().read(reader),
      owner: const BPublicKey().read(reader),
    );
  }
}

TweetModel _$TweetModelFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BTweetModel().read(reader);
}
